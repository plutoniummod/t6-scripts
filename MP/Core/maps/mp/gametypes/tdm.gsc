// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_globallogic;
#include maps\mp\gametypes\_callbacksetup;
#include maps\mp\gametypes\_gameobjects;
#include maps\mp\gametypes\_spawning;
#include maps\mp\gametypes\_spawnlogic;
#include maps\mp\gametypes\_globallogic_score;
#include maps\mp\gametypes\_globallogic_audio;

main()
{
    if ( getdvar( "mapname" ) == "mp_background" )
        return;

    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::setupcallbacks();
    maps\mp\gametypes\_globallogic::setupcallbacks();
    registerroundswitch( 0, 9 );
    registertimelimit( 0, 1440 );
    registerscorelimit( 0, 50000 );
    registerroundlimit( 0, 10 );
    registerroundwinlimit( 0, 10 );
    registernumlives( 0, 100 );
    maps\mp\gametypes\_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
    level.scoreroundbased = getgametypesetting( "roundscorecarry" ) == 0;
    level.teamscoreperkill = getgametypesetting( "teamScorePerKill" );
    level.teamscoreperdeath = getgametypesetting( "teamScorePerDeath" );
    level.teamscoreperheadshot = getgametypesetting( "teamScorePerHeadshot" );
    level.teambased = 1;
    level.overrideteamscore = 1;
    level.onstartgametype = ::onstartgametype;
    level.onspawnplayer = ::onspawnplayer;
    level.onspawnplayerunified = ::onspawnplayerunified;
    level.onroundendgame = ::onroundendgame;
    level.onroundswitch = ::onroundswitch;
    level.onplayerkilled = ::onplayerkilled;
    game["dialog"]["gametype"] = "tdm_start";
    game["dialog"]["gametype_hardcore"] = "hctdm_start";
    game["dialog"]["offense_obj"] = "generic_boost";
    game["dialog"]["defense_obj"] = "generic_boost";
    setscoreboardcolumns( "score", "kills", "deaths", "kdratio", "assists" );
}

onstartgametype()
{
    setclientnamemode( "auto_change" );

    if ( !isdefined( game["switchedsides"] ) )
        game["switchedsides"] = 0;

    if ( game["switchedsides"] )
    {
        oldattackers = game["attackers"];
        olddefenders = game["defenders"];
        game["attackers"] = olddefenders;
        game["defenders"] = oldattackers;
    }

    allowed[0] = "tdm";
    level.displayroundendtext = 0;
    maps\mp\gametypes\_gameobjects::main( allowed );
    maps\mp\gametypes\_spawning::create_map_placed_influencers();
    level.spawnmins = ( 0, 0, 0 );
    level.spawnmaxs = ( 0, 0, 0 );

    foreach ( team in level.teams )
    {
        setobjectivetext( team, &"OBJECTIVES_TDM" );
        setobjectivehinttext( team, &"OBJECTIVES_TDM_HINT" );

        if ( level.splitscreen )
            setobjectivescoretext( team, &"OBJECTIVES_TDM" );
        else
            setobjectivescoretext( team, &"OBJECTIVES_TDM_SCORE" );

        maps\mp\gametypes\_spawnlogic::addspawnpoints( team, "mp_tdm_spawn" );
        maps\mp\gametypes\_spawnlogic::placespawnpoints( maps\mp\gametypes\_spawning::gettdmstartspawnname( team ) );
    }

    maps\mp\gametypes\_spawning::updateallspawnpoints();
/#
    level.spawn_start = [];

    foreach ( team in level.teams )
        level.spawn_start[team] = maps\mp\gametypes\_spawnlogic::getspawnpointarray( maps\mp\gametypes\_spawning::gettdmstartspawnname( team ) );
#/
    level.mapcenter = maps\mp\gametypes\_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
    setmapcenter( level.mapcenter );
    spawnpoint = maps\mp\gametypes\_spawnlogic::getrandomintermissionpoint();
    setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );

    if ( !isoneround() )
    {
        level.displayroundendtext = 1;

        if ( isscoreroundbased() )
            maps\mp\gametypes\_globallogic_score::resetteamscores();
    }
}

onspawnplayerunified( question )
{
    self.usingobj = undefined;

    if ( level.usestartspawns && !level.ingraceperiod && !level.playerqueuedrespawn )
        level.usestartspawns = 0;

    spawnteam = self.pers["team"];

    if ( game["switchedsides"] )
        spawnteam = getotherteam( spawnteam );

    if ( isdefined( question ) )
        question = 1;

    if ( isdefined( question ) )
        question = -1;

    if ( isdefined( spawnteam ) )
        spawnteam = spawnteam;

    if ( !isdefined( spawnteam ) )
        spawnteam = -1;

    maps\mp\gametypes\_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn, question )
{
    pixbeginevent( "TDM:onSpawnPlayer" );
    self.usingobj = undefined;

    if ( isdefined( question ) )
        question = 1;

    if ( isdefined( question ) )
        question = -1;

    spawnteam = self.pers["team"];

    if ( isdefined( spawnteam ) )
        spawnteam = spawnteam;

    if ( !isdefined( spawnteam ) )
        spawnteam = -1;

    if ( level.ingraceperiod )
    {
        spawnpoints = maps\mp\gametypes\_spawnlogic::getspawnpointarray( maps\mp\gametypes\_spawning::gettdmstartspawnname( spawnteam ) );

        if ( !spawnpoints.size )
            spawnpoints = maps\mp\gametypes\_spawnlogic::getspawnpointarray( maps\mp\gametypes\_spawning::getteamstartspawnname( spawnteam, "mp_sab_spawn" ) );

        if ( !spawnpoints.size )
        {
            if ( game["switchedsides"] )
                spawnteam = getotherteam( spawnteam );

            spawnpoints = maps\mp\gametypes\_spawnlogic::getteamspawnpoints( spawnteam );
            spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_nearteam( spawnpoints );
        }
        else
            spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_random( spawnpoints );
    }
    else
    {
        if ( game["switchedsides"] )
            spawnteam = getotherteam( spawnteam );

        spawnpoints = maps\mp\gametypes\_spawnlogic::getteamspawnpoints( spawnteam );
        spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_nearteam( spawnpoints );
    }

    if ( predictedspawn )
        self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
    else
        self spawn( spawnpoint.origin, spawnpoint.angles, "tdm" );

    pixendevent();
}

onendgame( winningteam )
{
    if ( isdefined( winningteam ) && isdefined( level.teams[winningteam] ) )
        maps\mp\gametypes\_globallogic_score::giveteamscoreforobjective( winningteam, 1 );
}

onroundswitch()
{
    game["switchedsides"] = !game["switchedsides"];

    if ( level.roundscorecarry == 0 )
    {
        foreach ( team in level.teams )
            [[ level._setteamscore ]]( team, game["roundswon"][team] );
    }
}

onroundendgame( roundwinner )
{
    if ( level.roundscorecarry == 0 )
    {
        foreach ( team in level.teams )
            [[ level._setteamscore ]]( team, game["roundswon"][team] );

        winner = maps\mp\gametypes\_globallogic::determineteamwinnerbygamestat( "roundswon" );
    }
    else
        winner = maps\mp\gametypes\_globallogic::determineteamwinnerbyteamscore();

    return winner;
}

onscoreclosemusic()
{
    teamscores = [];

    while ( !level.gameended )
    {
        scorelimit = level.scorelimit;
        scorethreshold = scorelimit * 0.1;
        scorethresholdstart = abs( scorelimit - scorethreshold );
        scorelimitcheck = scorelimit - 10;
        topscore = 0;
        runnerupscore = 0;

        foreach ( team in level.teams )
        {
            score = [[ level._getteamscore ]]( team );

            if ( score > topscore )
            {
                runnerupscore = topscore;
                topscore = score;
                continue;
            }

            if ( score > runnerupscore )
                runnerupscore = score;
        }

        scoredif = topscore - runnerupscore;

        if ( scoredif <= scorethreshold && scorethresholdstart <= topscore )
        {
            thread maps\mp\gametypes\_globallogic_audio::set_music_on_team( "TIME_OUT", "both" );
            thread maps\mp\gametypes\_globallogic_audio::actionmusicset();
            return;
        }

        wait 1;
    }
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    if ( isplayer( attacker ) == 0 || attacker.team == self.team )
        return;

    attacker maps\mp\gametypes\_globallogic_score::giveteamscoreforobjective( attacker.team, level.teamscoreperkill );
    self maps\mp\gametypes\_globallogic_score::giveteamscoreforobjective( self.team, level.teamscoreperdeath * -1 );

    if ( smeansofdeath == "MOD_HEAD_SHOT" )
        attacker maps\mp\gametypes\_globallogic_score::giveteamscoreforobjective( attacker.team, level.teamscoreperheadshot );
}
