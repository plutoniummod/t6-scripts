// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_globallogic_utils;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\gametypes_zm\_globallogic_audio;
#include maps\mp\gametypes_zm\_spawnlogic;

getwinningteamfromloser( losing_team )
{
    if ( level.multiteam )
        return "tie";
    else if ( losing_team == "axis" )
        return "allies";

    return "axis";
}

default_onforfeit( team )
{
    level.gameforfeited = 1;
    level notify( "forfeit in progress" );
    level endon( "forfeit in progress" );
    level endon( "abort forfeit" );
    forfeit_delay = 20.0;
    announcement( game["strings"]["opponent_forfeiting_in"], forfeit_delay, 0 );
    wait 10.0;
    announcement( game["strings"]["opponent_forfeiting_in"], 10.0, 0 );
    wait 10.0;
    endreason = &"";

    if ( !isdefined( team ) )
    {
        setdvar( "ui_text_endreason", game["strings"]["players_forfeited"] );
        endreason = game["strings"]["players_forfeited"];
        winner = level.players[0];
    }
    else if ( isdefined( level.teams[team] ) )
    {
        endreason = game["strings"][team + "_forfeited"];
        setdvar( "ui_text_endreason", endreason );
        winner = getwinningteamfromloser( team );
    }
    else
    {
/#
        assert( isdefined( team ), "Forfeited team is not defined" );
#/
/#
        assert( 0, "Forfeited team " + team + " is not allies or axis" );
#/
        winner = "tie";
    }

    level.forcedend = 1;

    if ( isplayer( winner ) )
        logstring( "forfeit, win: " + winner getxuid() + "(" + winner.name + ")" );
    else
        maps\mp\gametypes_zm\_globallogic_utils::logteamwinstring( "forfeit", winner );

    thread maps\mp\gametypes_zm\_globallogic::endgame( winner, endreason );
}

default_ondeadevent( team )
{
    if ( isdefined( level.teams[team] ) )
    {
        eliminatedstring = game["strings"][team + "_eliminated"];
        iprintln( eliminatedstring );
        makedvarserverinfo( "ui_text_endreason", eliminatedstring );
        setdvar( "ui_text_endreason", eliminatedstring );
        winner = getwinningteamfromloser( team );
        maps\mp\gametypes_zm\_globallogic_utils::logteamwinstring( "team eliminated", winner );
        thread maps\mp\gametypes_zm\_globallogic::endgame( winner, eliminatedstring );
    }
    else
    {
        makedvarserverinfo( "ui_text_endreason", game["strings"]["tie"] );
        setdvar( "ui_text_endreason", game["strings"]["tie"] );
        maps\mp\gametypes_zm\_globallogic_utils::logteamwinstring( "tie" );

        if ( level.teambased )
            thread maps\mp\gametypes_zm\_globallogic::endgame( "tie", game["strings"]["tie"] );
        else
            thread maps\mp\gametypes_zm\_globallogic::endgame( undefined, game["strings"]["tie"] );
    }
}

default_onalivecountchange( team )
{

}

default_onroundendgame( winner )
{
    return winner;
}

default_ononeleftevent( team )
{
    if ( !level.teambased )
    {
        winner = maps\mp\gametypes_zm\_globallogic_score::gethighestscoringplayer();

        if ( isdefined( winner ) )
            logstring( "last one alive, win: " + winner.name );
        else
            logstring( "last one alive, win: unknown" );

        thread maps\mp\gametypes_zm\_globallogic::endgame( winner, &"MP_ENEMIES_ELIMINATED" );
    }
    else
    {
        for ( index = 0; index < level.players.size; index++ )
        {
            player = level.players[index];

            if ( !isalive( player ) )
                continue;

            if ( !isdefined( player.pers["team"] ) || player.pers["team"] != team )
                continue;

            player maps\mp\gametypes_zm\_globallogic_audio::leaderdialogonplayer( "sudden_death" );
        }
    }
}

default_ontimelimit()
{
    winner = undefined;

    if ( level.teambased )
    {
        winner = maps\mp\gametypes_zm\_globallogic::determineteamwinnerbygamestat( "teamScores" );
        maps\mp\gametypes_zm\_globallogic_utils::logteamwinstring( "time limit", winner );
    }
    else
    {
        winner = maps\mp\gametypes_zm\_globallogic_score::gethighestscoringplayer();

        if ( isdefined( winner ) )
            logstring( "time limit, win: " + winner.name );
        else
            logstring( "time limit, tie" );
    }

    makedvarserverinfo( "ui_text_endreason", game["strings"]["time_limit_reached"] );
    setdvar( "ui_text_endreason", game["strings"]["time_limit_reached"] );
    thread maps\mp\gametypes_zm\_globallogic::endgame( winner, game["strings"]["time_limit_reached"] );
}

default_onscorelimit()
{
    if ( !level.endgameonscorelimit )
        return false;

    winner = undefined;

    if ( level.teambased )
    {
        winner = maps\mp\gametypes_zm\_globallogic::determineteamwinnerbygamestat( "teamScores" );
        maps\mp\gametypes_zm\_globallogic_utils::logteamwinstring( "scorelimit", winner );
    }
    else
    {
        winner = maps\mp\gametypes_zm\_globallogic_score::gethighestscoringplayer();

        if ( isdefined( winner ) )
            logstring( "scorelimit, win: " + winner.name );
        else
            logstring( "scorelimit, tie" );
    }

    makedvarserverinfo( "ui_text_endreason", game["strings"]["score_limit_reached"] );
    setdvar( "ui_text_endreason", game["strings"]["score_limit_reached"] );
    thread maps\mp\gametypes_zm\_globallogic::endgame( winner, game["strings"]["score_limit_reached"] );
    return true;
}

default_onspawnspectator( origin, angles )
{
    if ( isdefined( origin ) && isdefined( angles ) )
    {
        self spawn( origin, angles );
        return;
    }

    spawnpointname = "mp_global_intermission";
    spawnpoints = getentarray( spawnpointname, "classname" );
/#
    assert( spawnpoints.size, "There are no mp_global_intermission spawn points in the map.  There must be at least one." );
#/
    spawnpoint = maps\mp\gametypes_zm\_spawnlogic::getspawnpoint_random( spawnpoints );
    self spawn( spawnpoint.origin, spawnpoint.angles );
}

default_onspawnintermission()
{
    spawnpointname = "mp_global_intermission";
    spawnpoints = getentarray( spawnpointname, "classname" );
    spawnpoint = spawnpoints[0];

    if ( isdefined( spawnpoint ) )
        self spawn( spawnpoint.origin, spawnpoint.angles );
    else
    {
/#
        maps\mp\_utility::error( "NO " + spawnpointname + " SPAWNPOINTS IN MAP" );
#/
    }
}

default_gettimelimit()
{
    return clamp( getgametypesetting( "timeLimit" ), level.timelimitmin, level.timelimitmax );
}
