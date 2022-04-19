// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud;

debug_script_structs()
{
/#
    if ( isdefined( level.struct ) )
    {
        println( "*** Num structs " + level.struct.size );
        println( "" );

        for ( i = 0; i < level.struct.size; i++ )
        {
            struct = level.struct[i];

            if ( isdefined( struct.targetname ) )
            {
                println( "---" + i + " : " + struct.targetname );
                continue;
            }

            println( "---" + i + " : " + "NONE" );
        }
    }
    else
        println( "*** No structs defined." );
#/
}

updatetimerpausedness()
{
    shouldbestopped = isdefined( level.hostmigrationtimer );

    if ( !level.timerstopped && shouldbestopped )
    {
        level.timerstopped = 1;
        level.timerpausetime = gettime();
    }
    else if ( level.timerstopped && !shouldbestopped )
    {
        level.timerstopped = 0;
        level.discardtime += gettime() - level.timerpausetime;
    }
}

callback_hostmigrationsave()
{

}

pausetimer()
{
    level.migrationtimerpausetime = gettime();
}

resumetimer()
{
    level.discardtime += gettime() - level.migrationtimerpausetime;
}

locktimer()
{
    level endon( "host_migration_begin" );
    level endon( "host_migration_end" );

    for (;;)
    {
        currtime = gettime();
        wait 0.05;

        if ( !level.timerstopped && isdefined( level.discardtime ) )
            level.discardtime += gettime() - currtime;
    }
}

callback_hostmigration()
{
    setslowmotion( 1, 1, 0 );
    makedvarserverinfo( "ui_guncycle", 0 );
    level.hostmigrationreturnedplayercount = 0;

    if ( level.inprematchperiod )
        level waittill( "prematch_over" );

    if ( level.gameended )
    {
/#
        println( "Migration starting at time " + gettime() + ", but game has ended, so no countdown." );
#/
        return;
    }
/#
    println( "Migration starting at time " + gettime() );
#/
    level.hostmigrationtimer = 1;
    sethostmigrationstatus( 1 );
    level notify( "host_migration_begin" );
    thread locktimer();
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];
        player thread hostmigrationtimerthink();
    }

    level endon( "host_migration_begin" );
    hostmigrationwait();
    level.hostmigrationtimer = undefined;
    sethostmigrationstatus( 0 );
/#
    println( "Migration finished at time " + gettime() );
#/
    recordmatchbegin();
    level notify( "host_migration_end" );
}

matchstarttimerconsole_internal( counttime, matchstarttimer )
{
    waittillframeend;
    visionsetnaked( "mpIntro", 0 );
    level endon( "match_start_timer_beginning" );

    while ( counttime > 0 && !level.gameended )
    {
        matchstarttimer thread maps\mp\gametypes\_hud::fontpulse( level );
        wait( matchstarttimer.inframes * 0.05 );
        matchstarttimer setvalue( counttime );

        if ( counttime == 2 )
            visionsetnaked( getdvar( "mapname" ), 3.0 );

        counttime--;
        wait( 1 - matchstarttimer.inframes * 0.05 );
    }
}

matchstarttimerconsole( type, duration )
{
    level notify( "match_start_timer_beginning" );
    wait 0.05;
    matchstarttext = createserverfontstring( "objective", 1.5 );
    matchstarttext setpoint( "CENTER", "CENTER", 0, -40 );
    matchstarttext.sort = 1001;
    matchstarttext settext( game["strings"]["waiting_for_teams"] );
    matchstarttext.foreground = 0;
    matchstarttext.hidewheninmenu = 1;
    matchstarttext settext( game["strings"][type] );
    matchstarttimer = createserverfontstring( "objective", 2.2 );
    matchstarttimer setpoint( "CENTER", "CENTER", 0, 0 );
    matchstarttimer.sort = 1001;
    matchstarttimer.color = ( 1, 1, 0 );
    matchstarttimer.foreground = 0;
    matchstarttimer.hidewheninmenu = 1;
    matchstarttimer maps\mp\gametypes\_hud::fontpulseinit();
    counttime = int( duration );

    if ( counttime >= 2 )
    {
        matchstarttimerconsole_internal( counttime, matchstarttimer );
        visionsetnaked( getdvar( "mapname" ), 3.0 );
    }
    else
    {
        visionsetnaked( "mpIntro", 0 );
        visionsetnaked( getdvar( "mapname" ), 1.0 );
    }

    matchstarttimer destroyelem();
    matchstarttext destroyelem();
}

hostmigrationwait()
{
    level endon( "game_ended" );

    if ( level.hostmigrationreturnedplayercount < level.players.size * 2 / 3 )
    {
        thread matchstarttimerconsole( "waiting_for_teams", 20.0 );
        hostmigrationwaitforplayers();
    }

    level notify( "host_migration_countdown_begin" );
    thread matchstarttimerconsole( "match_starting_in", 5.0 );
    wait 5;
}

waittillhostmigrationcountdown()
{
    level endon( "host_migration_end" );

    if ( !isdefined( level.hostmigrationtimer ) )
        return;

    level waittill( "host_migration_countdown_begin" );
}

hostmigrationwaitforplayers()
{
    level endon( "hostmigration_enoughplayers" );
    wait 15;
}

hostmigrationtimerthink_internal()
{
    level endon( "host_migration_begin" );
    level endon( "host_migration_end" );
    self.hostmigrationcontrolsfrozen = 0;

    while ( !isalive( self ) )
        self waittill( "spawned" );

    self.hostmigrationcontrolsfrozen = 1;
    self freezecontrols( 1 );

    level waittill( "host_migration_end" );
}

hostmigrationtimerthink()
{
    self endon( "disconnect" );
    level endon( "host_migration_begin" );
    hostmigrationtimerthink_internal();

    if ( self.hostmigrationcontrolsfrozen )
        self freezecontrols( 0 );
}

waittillhostmigrationdone()
{
    if ( !isdefined( level.hostmigrationtimer ) )
        return 0;

    starttime = gettime();

    level waittill( "host_migration_end" );

    return gettime() - starttime;
}

waittillhostmigrationstarts( duration )
{
    if ( isdefined( level.hostmigrationtimer ) )
        return;

    level endon( "host_migration_begin" );
    wait( duration );
}

waitlongdurationwithhostmigrationpause( duration )
{
    if ( duration == 0 )
        return;
/#
    assert( duration > 0 );
#/
    starttime = gettime();
    endtime = gettime() + duration * 1000;

    while ( gettime() < endtime )
    {
        waittillhostmigrationstarts( ( endtime - gettime() ) / 1000 );

        if ( isdefined( level.hostmigrationtimer ) )
        {
            timepassed = waittillhostmigrationdone();
            endtime += timepassed;
        }
    }
/#
    if ( gettime() != endtime )
        println( "SCRIPT WARNING: gettime() = " + gettime() + " NOT EQUAL TO endtime = " + endtime );
#/
    waittillhostmigrationdone();
    return gettime() - starttime;
}

waitlongdurationwithhostmigrationpauseemp( duration )
{
    if ( duration == 0 )
        return;
/#
    assert( duration > 0 );
#/
    starttime = gettime();
    empendtime = gettime() + duration * 1000;
    level.empendtime = empendtime;

    while ( gettime() < empendtime )
    {
        waittillhostmigrationstarts( ( empendtime - gettime() ) / 1000 );

        if ( isdefined( level.hostmigrationtimer ) )
        {
            timepassed = waittillhostmigrationdone();

            if ( isdefined( empendtime ) )
                empendtime += timepassed;
        }
    }
/#
    if ( gettime() != empendtime )
        println( "SCRIPT WARNING: gettime() = " + gettime() + " NOT EQUAL TO empendtime = " + empendtime );
#/
    waittillhostmigrationdone();
    level.empendtime = undefined;
    return gettime() - starttime;
}

waitlongdurationwithgameendtimeupdate( duration )
{
    if ( duration == 0 )
        return;
/#
    assert( duration > 0 );
#/
    starttime = gettime();
    endtime = gettime() + duration * 1000;

    while ( gettime() < endtime )
    {
        waittillhostmigrationstarts( ( endtime - gettime() ) / 1000 );

        while ( isdefined( level.hostmigrationtimer ) )
        {
            endtime += 1000;
            setgameendtime( int( endtime ) );
            wait 1;
        }
    }
/#
    if ( gettime() != endtime )
        println( "SCRIPT WARNING: gettime() = " + gettime() + " NOT EQUAL TO endtime = " + endtime );
#/
    while ( isdefined( level.hostmigrationtimer ) )
    {
        endtime += 1000;
        setgameendtime( int( endtime ) );
        wait 1;
    }

    return gettime() - starttime;
}
