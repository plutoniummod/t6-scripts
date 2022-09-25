// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud;
#include maps\mp\zombies\_zm;

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

callback_prehostmigrationsave()
{
    undo_link_changes();
    disablezombies( 1 );

    if ( is_true( level._hm_should_pause_spawning ) )
        flag_set( "spawn_zombies" );

    for ( i = 0; i < level.players.size; i++ )
        level.players[i] enableinvulnerability();
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
    redo_link_changes();
    setslowmotion( 1, 1, 0 );
    makedvarserverinfo( "ui_guncycle", 0 );
    level.hostmigrationreturnedplayercount = 0;

    if ( level.gameended )
    {
/#
        println( "Migration starting at time " + gettime() + ", but game has ended, so no countdown." );
#/
        return;
    }

    sethostmigrationstatus( 1 );
    level notify( "host_migration_begin" );

    for ( i = 0; i < level.players.size; i++ )
    {
        if ( isdefined( level.hostmigration_link_entity_callback ) )
        {
            if ( !isdefined( level.players[i]._host_migration_link_entity ) )
                level.players[i]._host_migration_link_entity = level.players[i] [[ level.hostmigration_link_entity_callback ]]();
        }

        level.players[i] thread hostmigrationtimerthink();
    }

    if ( isdefined( level.hostmigration_ai_link_entity_callback ) )
    {
        zombies = getaiarray( level.zombie_team );

        if ( isdefined( zombies ) && zombies.size > 0 )
        {
            foreach ( zombie in zombies )
            {
                if ( !isdefined( zombie._host_migration_link_entity ) )
                    zombie._host_migration_link_entity = zombie [[ level.hostmigration_ai_link_entity_callback ]]();
            }
        }
    }

    if ( level.inprematchperiod )
        level waittill( "prematch_over" );
/#
    println( "Migration starting at time " + gettime() );
#/
    level.hostmigrationtimer = 1;
    thread locktimer();
    zombies = getaiarray( level.zombie_team );

    if ( isdefined( zombies ) && zombies.size > 0 )
    {
        foreach ( zombie in zombies )
        {
            if ( isdefined( zombie._host_migration_link_entity ) )
            {
                ent = spawn( "script_origin", zombie.origin );
                ent.angles = zombie.angles;
                zombie linkto( ent );
                ent linkto( zombie._host_migration_link_entity, "tag_origin", zombie._host_migration_link_entity worldtolocalcoords( ent.origin ), ent.angles + zombie._host_migration_link_entity.angles );
                zombie._host_migration_link_helper = ent;
                zombie linkto( zombie._host_migration_link_helper );
            }
        }
    }

    level endon( "host_migration_begin" );
    level._hm_should_pause_spawning = flag( "spawn_zombies" );

    if ( level._hm_should_pause_spawning )
        flag_clear( "spawn_zombies" );

    hostmigrationwait();

    foreach ( player in level.players )
        player thread post_migration_become_vulnerable();

    zombies = getaiarray( level.zombie_team );

    if ( isdefined( zombies ) && zombies.size > 0 )
    {
        foreach ( zombie in zombies )
        {
            if ( isdefined( zombie._host_migration_link_entity ) )
            {
                zombie unlink();
                zombie._host_migration_link_helper delete();
                zombie._host_migration_link_helper = undefined;
                zombie._host_migration_link_entity = undefined;
            }
        }
    }

    enablezombies( 1 );

    if ( level._hm_should_pause_spawning )
        flag_set( "spawn_zombies" );

    level.hostmigrationtimer = undefined;
    level._hm_should_pause_spawning = undefined;
    sethostmigrationstatus( 0 );
/#
    println( "Migration finished at time " + gettime() );
#/
    level notify( "host_migration_end" );
}

post_migration_become_vulnerable()
{
    self endon( "disconnect" );
    wait 3;
    self disableinvulnerability();
}

matchstarttimerconsole_internal( counttime, matchstarttimer )
{
    waittillframeend;
    level endon( "match_start_timer_beginning" );

    while ( counttime > 0 && !level.gameended )
    {
        matchstarttimer thread maps\mp\gametypes_zm\_hud::fontpulse( level );
        wait( matchstarttimer.inframes * 0.05 );
        matchstarttimer setvalue( counttime );
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
    matchstarttimer maps\mp\gametypes_zm\_hud::fontpulseinit();
    counttime = int( duration );

    if ( counttime >= 2 )
        matchstarttimerconsole_internal( counttime, matchstarttimer );
    else
    {

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

    thread matchstarttimerconsole( "match_starting_in", 5.0 );
    wait 5;
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

    if ( isdefined( self._host_migration_link_entity ) )
    {
        ent = spawn( "script_origin", self.origin );
        ent.angles = self.angles;
        self linkto( ent );
        ent linkto( self._host_migration_link_entity, "tag_origin", self._host_migration_link_entity worldtolocalcoords( ent.origin ), ent.angles + self._host_migration_link_entity.angles );
        self._host_migration_link_helper = ent;
/#
        println( "Linking player to ent " + self._host_migration_link_entity.targetname );
#/
    }

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
    {
        self freezecontrols( 0 );
        self.hostmigrationcontrolsfrozen = 0;
/#
        println( " Host migration unfreeze controls" );
#/
    }

    if ( isdefined( self._host_migration_link_entity ) )
    {
        self unlink();
        self._host_migration_link_helper delete();
        self._host_migration_link_helper = undefined;

        if ( isdefined( self._host_migration_link_entity._post_host_migration_thread ) )
            self thread [[ self._host_migration_link_entity._post_host_migration_thread ]]( self._host_migration_link_entity );

        self._host_migration_link_entity = undefined;
    }
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

    assert( duration > 0 );
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

    if ( gettime() != endtime )
    {
/#
        println( "SCRIPT WARNING: gettime() = " + gettime() + " NOT EQUAL TO endtime = " + endtime );
#/
    }

    waittillhostmigrationdone();
    return gettime() - starttime;
}

waitlongdurationwithgameendtimeupdate( duration )
{
    if ( duration == 0 )
        return;

    assert( duration > 0 );
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

find_alternate_player_place( v_origin, min_radius, max_radius, max_height, ignore_targetted_nodes )
{
    found_node = undefined;
    a_nodes = getnodesinradiussorted( v_origin, max_radius, min_radius, max_height, "pathnodes" );

    if ( isdefined( a_nodes ) && a_nodes.size > 0 )
    {
        a_player_volumes = getentarray( "player_volume", "script_noteworthy" );
        index = a_nodes.size - 1;

        for ( i = index; i >= 0; i-- )
        {
            n_node = a_nodes[i];

            if ( ignore_targetted_nodes == 1 )
            {
                if ( isdefined( n_node.target ) )
                    continue;
            }

            if ( !positionwouldtelefrag( n_node.origin ) )
            {
                if ( maps\mp\zombies\_zm_utility::check_point_in_enabled_zone( n_node.origin, 1, a_player_volumes ) )
                {
                    v_start = ( n_node.origin[0], n_node.origin[1], n_node.origin[2] + 30 );
                    v_end = ( n_node.origin[0], n_node.origin[1], n_node.origin[2] - 30 );
                    trace = bullettrace( v_start, v_end, 0, undefined );

                    if ( trace["fraction"] < 1 )
                    {
                        override_abort = 0;

                        if ( isdefined( level._chugabud_reject_node_override_func ) )
                            override_abort = [[ level._chugabud_reject_node_override_func ]]( v_origin, n_node );

                        if ( !override_abort )
                        {
                            found_node = n_node;
                            break;
                        }
                    }
                }
            }
        }
    }

    return found_node;
}

hostmigration_put_player_in_better_place()
{
    spawnpoint = undefined;
    spawnpoint = find_alternate_player_place( self.origin, 50, 150, 64, 1 );

    if ( !isdefined( spawnpoint ) )
        spawnpoint = find_alternate_player_place( self.origin, 150, 400, 64, 1 );

    if ( !isdefined( spawnpoint ) )
        spawnpoint = find_alternate_player_place( self.origin, 50, 400, 256, 0 );

    if ( !isdefined( spawnpoint ) )
        spawnpoint = maps\mp\zombies\_zm::check_for_valid_spawn_near_team( self, 1 );

    if ( !isdefined( spawnpoint ) )
    {
        match_string = "";
        location = level.scr_zm_map_start_location;

        if ( ( location == "default" || location == "" ) && isdefined( level.default_start_location ) )
            location = level.default_start_location;

        match_string = level.scr_zm_ui_gametype + "_" + location;
        spawnpoints = [];
        structs = getstructarray( "initial_spawn", "script_noteworthy" );

        if ( isdefined( structs ) )
        {
            foreach ( struct in structs )
            {
                if ( isdefined( struct.script_string ) )
                {
                    tokens = strtok( struct.script_string, " " );

                    foreach ( token in tokens )
                    {
                        if ( token == match_string )
                            spawnpoints[spawnpoints.size] = struct;
                    }
                }
            }
        }

        if ( !isdefined( spawnpoints ) || spawnpoints.size == 0 )
            spawnpoints = getstructarray( "initial_spawn_points", "targetname" );

        assert( isdefined( spawnpoints ), "Could not find initial spawn points!" );
        spawnpoint = maps\mp\zombies\_zm::getfreespawnpoint( spawnpoints, self );
    }

    if ( isdefined( spawnpoint ) )
        self setorigin( spawnpoint.origin );
}
