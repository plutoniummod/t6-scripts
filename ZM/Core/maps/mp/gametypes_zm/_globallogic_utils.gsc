// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\gametypes_zm\_globallogic_score;

waittillslowprocessallowed()
{
    while ( level.lastslowprocessframe == gettime() )
        wait 0.05;

    level.lastslowprocessframe = gettime();
}

testmenu()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        wait 10.0;
        notifydata = spawnstruct();
        notifydata.titletext = &"MP_CHALLENGE_COMPLETED";
        notifydata.notifytext = "wheee";
        notifydata.sound = "mp_challenge_complete";
        self thread maps\mp\gametypes_zm\_hud_message::notifymessage( notifydata );
    }
}

testshock()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        wait 3.0;
        numshots = randomint( 6 );

        for ( i = 0; i < numshots; i++ )
        {
            iprintlnbold( numshots );
            self shellshock( "frag_grenade_mp", 0.2 );
            wait 0.1;
        }
    }
}

testhps()
{
    self endon( "death" );
    self endon( "disconnect" );
    hps = [];
    hps[hps.size] = "radar_mp";
    hps[hps.size] = "artillery_mp";
    hps[hps.size] = "dogs_mp";

    for (;;)
    {
        hp = "radar_mp";
        wait 20.0;
    }
}

timeuntilroundend()
{
    if ( level.gameended )
    {
        timepassed = ( gettime() - level.gameendtime ) / 1000;
        timeremaining = level.postroundtime - timepassed;

        if ( timeremaining < 0 )
            return 0;

        return timeremaining;
    }

    if ( level.inovertime )
        return undefined;

    if ( level.timelimit <= 0 )
        return undefined;

    if ( !isdefined( level.starttime ) )
        return undefined;

    timepassed = ( gettimepassed() - level.starttime ) / 1000;
    timeremaining = level.timelimit * 60 - timepassed;
    return timeremaining + level.postroundtime;
}

gettimeremaining()
{
    return level.timelimit * 60 * 1000 - gettimepassed();
}

registerpostroundevent( eventfunc )
{
    if ( !isdefined( level.postroundevents ) )
        level.postroundevents = [];

    level.postroundevents[level.postroundevents.size] = eventfunc;
}

executepostroundevents()
{
    if ( !isdefined( level.postroundevents ) )
        return;

    for ( i = 0; i < level.postroundevents.size; i++ )
        [[ level.postroundevents[i] ]]();
}

getvalueinrange( value, minvalue, maxvalue )
{
    if ( value > maxvalue )
        return maxvalue;
    else if ( value < minvalue )
        return minvalue;
    else
        return value;
}

assertproperplacement()
{
/#
    numplayers = level.placement["all"].size;

    for ( i = 0; i < numplayers - 1; i++ )
    {
        if ( isdefined( level.placement["all"][i] ) && isdefined( level.placement["all"][i + 1] ) )
        {
            if ( level.placement["all"][i].score < level.placement["all"][i + 1].score )
            {
                println( "^1Placement array:" );

                for ( i = 0; i < numplayers; i++ )
                {
                    player = level.placement["all"][i];
                    println( "^1" + i + ". " + player.name + ": " + player.score );
                }
/#
                assertmsg( "Placement array was not properly sorted" );
#/
                break;
            }
        }
    }
#/
}

isvalidclass( class )
{
    if ( level.oldschool || sessionmodeiszombiesgame() )
    {
        assert( !isdefined( class ) );
        return 1;
    }

    return isdefined( class ) && class != "";
}

playtickingsound( gametype_tick_sound )
{
    self endon( "death" );
    self endon( "stop_ticking" );
    level endon( "game_ended" );
    time = level.bombtimer;

    while ( true )
    {
        self playsound( gametype_tick_sound );

        if ( time > 10 )
        {
            time -= 1;
            wait 1;
        }
        else if ( time > 4 )
        {
            time -= 0.5;
            wait 0.5;
        }
        else if ( time > 1 )
        {
            time -= 0.4;
            wait 0.4;
        }
        else
        {
            time -= 0.3;
            wait 0.3;
        }

        maps\mp\gametypes_zm\_hostmigration::waittillhostmigrationdone();
    }
}

stoptickingsound()
{
    self notify( "stop_ticking" );
}

gametimer()
{
    level endon( "game_ended" );

    level waittill( "prematch_over" );

    level.starttime = gettime();
    level.discardtime = 0;

    if ( isdefined( game["roundMillisecondsAlreadyPassed"] ) )
    {
        level.starttime -= game["roundMillisecondsAlreadyPassed"];
        game["roundMillisecondsAlreadyPassed"] = undefined;
    }

    prevtime = gettime();

    while ( game["state"] == "playing" )
    {
        if ( !level.timerstopped )
            game["timepassed"] += gettime() - prevtime;

        prevtime = gettime();
        wait 1.0;
    }
}

gettimepassed()
{
    if ( !isdefined( level.starttime ) )
        return 0;

    if ( level.timerstopped )
        return level.timerpausetime - level.starttime - level.discardtime;
    else
        return gettime() - level.starttime - level.discardtime;
}

pausetimer()
{
    if ( level.timerstopped )
        return;

    level.timerstopped = 1;
    level.timerpausetime = gettime();
}

resumetimer()
{
    if ( !level.timerstopped )
        return;

    level.timerstopped = 0;
    level.discardtime += gettime() - level.timerpausetime;
}

getscoreremaining( team )
{
    assert( isplayer( self ) || isdefined( team ) );
    scorelimit = level.scorelimit;

    if ( isplayer( self ) )
        return scorelimit - maps\mp\gametypes_zm\_globallogic_score::_getplayerscore( self );
    else
        return scorelimit - getteamscore( team );
}

getscoreperminute( team )
{
    assert( isplayer( self ) || isdefined( team ) );
    scorelimit = level.scorelimit;
    timelimit = level.timelimit;
    minutespassed = gettimepassed() / 60000 + 0.0001;

    if ( isplayer( self ) )
        return maps\mp\gametypes_zm\_globallogic_score::_getplayerscore( self ) / minutespassed;
    else
        return getteamscore( team ) / minutespassed;
}

getestimatedtimeuntilscorelimit( team )
{
    assert( isplayer( self ) || isdefined( team ) );
    scoreperminute = self getscoreperminute( team );
    scoreremaining = self getscoreremaining( team );

    if ( !scoreperminute )
        return 999999;

    return scoreremaining / scoreperminute;
}

rumbler()
{
    self endon( "disconnect" );

    while ( true )
    {
        wait 0.1;
        self playrumbleonentity( "damage_heavy" );
    }
}

waitfortimeornotify( time, notifyname )
{
    self endon( notifyname );
    wait( time );
}

waitfortimeornotifynoartillery( time, notifyname )
{
    self endon( notifyname );
    wait( time );

    while ( isdefined( level.artilleryinprogress ) )
    {
        assert( level.artilleryinprogress );
        wait 0.25;
    }
}

isheadshot( sweapon, shitloc, smeansofdeath, einflictor )
{
    if ( shitloc != "head" && shitloc != "helmet" )
        return false;

    switch ( smeansofdeath )
    {
        case "MOD_MELEE":
        case "MOD_BAYONET":
            return false;
        case "MOD_IMPACT":
            if ( sweapon != "knife_ballistic_mp" )
                return false;
    }

    return true;
}

gethitlocheight( shitloc )
{
    switch ( shitloc )
    {
        case "neck":
        case "helmet":
        case "head":
            return 60;
        case "torso_upper":
        case "right_hand":
        case "right_arm_upper":
        case "right_arm_lower":
        case "left_hand":
        case "left_arm_upper":
        case "left_arm_lower":
        case "gun":
            return 48;
        case "torso_lower":
            return 40;
        case "right_leg_upper":
        case "left_leg_upper":
            return 32;
        case "right_leg_lower":
        case "left_leg_lower":
            return 10;
        case "right_foot":
        case "left_foot":
            return 5;
    }

    return 48;
}

debugline( start, end )
{
/#
    for ( i = 0; i < 50; i++ )
    {
        line( start, end );
        wait 0.05;
    }
#/
}

isexcluded( entity, entitylist )
{
    for ( index = 0; index < entitylist.size; index++ )
    {
        if ( entity == entitylist[index] )
            return true;
    }

    return false;
}

waitfortimeornotifies( desireddelay )
{
    startedwaiting = gettime();
    waitedtime = ( gettime() - startedwaiting ) / 1000;

    if ( waitedtime < desireddelay )
    {
        wait( desireddelay - waitedtime );
        return desireddelay;
    }
    else
        return waitedtime;
}

logteamwinstring( wintype, winner )
{
    log_string = wintype;

    if ( isdefined( winner ) )
        log_string = log_string + ", win: " + winner;

    foreach ( team in level.teams )
        log_string = log_string + ", " + team + ": " + game["teamScores"][team];

    logstring( log_string );
}
