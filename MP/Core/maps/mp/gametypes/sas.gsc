// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_globallogic;
#include maps\mp\gametypes\_callbacksetup;
#include maps\mp\gametypes\_wager;
#include maps\mp\gametypes\_globallogic_score;
#include maps\mp\_scoreevents;
#include maps\mp\gametypes\_globallogic_audio;
#include maps\mp\gametypes\_gameobjects;
#include maps\mp\gametypes\_spawning;
#include maps\mp\gametypes\_spawnlogic;
#include maps\mp\gametypes\_persistence;

main()
{
    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::setupcallbacks();
    maps\mp\gametypes\_globallogic::setupcallbacks();
    registertimelimit( 0, 1440 );
    registerscorelimit( 0, 5000 );
    registerroundlimit( 0, 10 );
    registerroundwinlimit( 0, 10 );
    registernumlives( 0, 100 );
    level.onstartgametype = ::onstartgametype;
    level.onspawnplayer = ::onspawnplayer;
    level.onspawnplayerunified = ::onspawnplayerunified;
    level.onplayerdamage = ::onplayerdamage;
    level.onplayerkilled = ::onplayerkilled;
    level.onwagerawards = ::onwagerawards;
    level.pointsperprimarykill = getgametypesetting( "pointsPerPrimaryKill" );
    level.pointspersecondarykill = getgametypesetting( "pointsPerSecondaryKill" );
    level.pointsperprimarygrenadekill = getgametypesetting( "pointsPerPrimaryGrenadeKill" );
    level.pointspermeleekill = getgametypesetting( "pointsPerMeleeKill" );
    level.setbacks = getgametypesetting( "setbacks" );

    switch ( getgametypesetting( "gunSelection" ) )
    {
        case 0:
            level.setbackweapon = undefined;
            break;
        case 1:
            level.setbackweapon = getreffromitemindex( getbaseweaponitemindex( "hatchet_mp" ) ) + "_mp";
            break;
        case 2:
            level.setbackweapon = getreffromitemindex( getbaseweaponitemindex( "crossbow_mp" ) ) + "_mp";
            break;
        case 3:
            level.setbackweapon = getreffromitemindex( getbaseweaponitemindex( "knife_ballistic_mp" ) ) + "_mp";
            break;
        default:
            assert( 1, "Invalid setting for gunSelection" );
            break;
    }

    game["dialog"]["gametype"] = "sns_start";
    game["dialog"]["wm_humiliation"] = "mpl_wager_bankrupt";
    game["dialog"]["wm_humiliated"] = "sns_hum";
    level.givecustomloadout = ::givecustomloadout;
    precachestring( &"MP_HUMILIATION" );
    precachestring( &"MP_HUMILIATED" );
    precachestring( &"MP_BANKRUPTED" );
    precachestring( &"MP_BANKRUPTED_OTHER" );
    precacheshader( "hud_acoustic_sensor" );
    precacheshader( "hud_us_stungrenade" );
    setscoreboardcolumns( "pointstowin", "kills", "deaths", "tomahawks", "humiliated" );
}

givecustomloadout()
{
    self notify( "sas_spectator_hud" );
    defaultweapon = "crossbow_mp";
    self maps\mp\gametypes\_wager::setupblankrandomplayer( 1, 1, defaultweapon );
    self giveweapon( defaultweapon );
    self setweaponammoclip( defaultweapon, 3 );
    self setweaponammostock( defaultweapon, 3 );
    secondaryweapon = "knife_ballistic_mp";
    self giveweapon( secondaryweapon );
    self setweaponammostock( secondaryweapon, 2 );
    offhandprimary = "hatchet_mp";
    self setoffhandprimaryclass( offhandprimary );
    self giveweapon( offhandprimary );
    self setweaponammoclip( offhandprimary, 1 );
    self setweaponammostock( offhandprimary, 1 );
    self giveweapon( "knife_mp" );
    self switchtoweapon( defaultweapon );
    self setspawnweapon( defaultweapon );
    self.killswithsecondary = 0;
    self.killswithprimary = 0;
    self.killswithbothawarded = 0;
    return defaultweapon;
}

onplayerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
    if ( sweapon == "crossbow_mp" && smeansofdeath == "MOD_IMPACT" )
    {
        if ( isdefined( eattacker ) && isplayer( eattacker ) )
        {
            if ( !isdefined( eattacker.pers["sticks"] ) )
                eattacker.pers["sticks"] = 1;
            else
                eattacker.pers["sticks"]++;

            eattacker.sticks = eattacker.pers["sticks"];
        }
    }

    return idamage;
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    if ( isdefined( attacker ) && isplayer( attacker ) && attacker != self )
    {
        baseweaponname = getreffromitemindex( getbaseweaponitemindex( sweapon ) ) + "_mp";

        if ( smeansofdeath == "MOD_MELEE" )
            attacker maps\mp\gametypes\_globallogic_score::givepointstowin( level.pointspermeleekill );
        else if ( baseweaponname == "crossbow_mp" )
        {
            attacker.killswithprimary++;

            if ( attacker.killswithbothawarded == 0 && attacker.killswithsecondary > 0 )
            {
                attacker.killswithbothawarded = 1;
                maps\mp\_scoreevents::processscoreevent( "kill_with_crossbow_and_ballistic_sas", attacker, self, sweapon );
            }

            attacker maps\mp\gametypes\_globallogic_score::givepointstowin( level.pointsperprimarykill );
        }
        else if ( baseweaponname == "hatchet_mp" )
        {
            if ( maps\mp\gametypes\_globallogic::istopscoringplayer( self ) )
                maps\mp\_scoreevents::processscoreevent( "kill_leader_with_axe_sas", attacker, self, sweapon );
            else
                maps\mp\_scoreevents::processscoreevent( "kill_with_axe_sas", attacker, self, sweapon );

            attacker maps\mp\gametypes\_globallogic_score::givepointstowin( level.pointsperprimarygrenadekill );
        }
        else
        {
            if ( baseweaponname == "knife_ballistic_mp" )
            {
                attacker.killswithsecondary++;

                if ( attacker.killswithbothawarded == 0 && attacker.killswithprimary > 0 )
                {
                    attacker.killswithbothawarded = 1;
                    maps\mp\_scoreevents::processscoreevent( "kill_with_crossbow_and_ballistic_sas", attacker, self, sweapon );
                }
            }

            attacker maps\mp\gametypes\_globallogic_score::givepointstowin( level.pointspersecondarykill );
        }

        if ( isdefined( level.setbackweapon ) && baseweaponname == level.setbackweapon )
        {
            self.pers["humiliated"]++;
            self.humiliated = self.pers["humiliated"];

            if ( level.setbacks == 0 )
                self maps\mp\gametypes\_globallogic_score::setpointstowin( 0 );
            else
                self maps\mp\gametypes\_globallogic_score::givepointstowin( level.setbacks * -1 );

            attacker playlocalsound( game["dialog"]["wm_humiliation"] );
            self playlocalsound( game["dialog"]["wm_humiliation"] );
            self maps\mp\gametypes\_globallogic_audio::leaderdialogonplayer( "wm_humiliated" );
        }
    }
    else
    {
        self.pers["humiliated"]++;
        self.humiliated = self.pers["humiliated"];

        if ( level.setbacks == 0 )
            self maps\mp\gametypes\_globallogic_score::setpointstowin( 0 );
        else
            self maps\mp\gametypes\_globallogic_score::givepointstowin( level.setbacks * -1 );

        self thread maps\mp\gametypes\_wager::queuewagerpopup( &"MP_HUMILIATED", 0, &"MP_BANKRUPTED", "wm_humiliated" );
        self playlocalsound( game["dialog"]["wm_humiliated"] );
    }
}

onstartgametype()
{
    setdvar( "scr_xpscale", 0 );
    setclientnamemode( "auto_change" );
    setobjectivetext( "allies", &"OBJECTIVES_SAS" );
    setobjectivetext( "axis", &"OBJECTIVES_SAS" );

    if ( level.splitscreen )
    {
        setobjectivescoretext( "allies", &"OBJECTIVES_SAS" );
        setobjectivescoretext( "axis", &"OBJECTIVES_SAS" );
    }
    else
    {
        setobjectivescoretext( "allies", &"OBJECTIVES_SAS_SCORE" );
        setobjectivescoretext( "axis", &"OBJECTIVES_SAS_SCORE" );
    }

    setobjectivehinttext( "allies", &"OBJECTIVES_SAS_HINT" );
    setobjectivehinttext( "axis", &"OBJECTIVES_SAS_HINT" );
    allowed[0] = "sas";
    maps\mp\gametypes\_gameobjects::main( allowed );
    maps\mp\gametypes\_spawning::create_map_placed_influencers();
    level.spawnmins = ( 0, 0, 0 );
    level.spawnmaxs = ( 0, 0, 0 );
    newspawns = getentarray( "mp_wager_spawn", "classname" );

    if ( newspawns.size > 0 )
    {
        maps\mp\gametypes\_spawnlogic::addspawnpoints( "allies", "mp_wager_spawn" );
        maps\mp\gametypes\_spawnlogic::addspawnpoints( "axis", "mp_wager_spawn" );
    }
    else
    {
        maps\mp\gametypes\_spawnlogic::addspawnpoints( "allies", "mp_dm_spawn" );
        maps\mp\gametypes\_spawnlogic::addspawnpoints( "axis", "mp_dm_spawn" );
    }

    maps\mp\gametypes\_spawning::updateallspawnpoints();
    level.mapcenter = maps\mp\gametypes\_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
    setmapcenter( level.mapcenter );
    spawnpoint = maps\mp\gametypes\_spawnlogic::getrandomintermissionpoint();
    setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
    level.usestartspawns = 0;
    level.displayroundendtext = 0;

    if ( isdefined( game["roundsplayed"] ) && game["roundsplayed"] > 0 )
    {
        game["dialog"]["gametype"] = undefined;
        game["dialog"]["offense_obj"] = undefined;
        game["dialog"]["defense_obj"] = undefined;
    }
}

onspawnplayerunified()
{
    maps\mp\gametypes\_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn )
{
    spawnpoints = maps\mp\gametypes\_spawnlogic::getteamspawnpoints( self.pers["team"] );
    spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_dm( spawnpoints );

    if ( predictedspawn )
        self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
    else
        self spawn( spawnpoint.origin, spawnpoint.angles, "sas" );
}

onwagerawards()
{
    tomahawks = self maps\mp\gametypes\_globallogic_score::getpersstat( "tomahawks" );

    if ( !isdefined( tomahawks ) )
        tomahawks = 0;

    self maps\mp\gametypes\_persistence::setafteractionreportstat( "wagerAwards", tomahawks, 0 );
    sticks = self maps\mp\gametypes\_globallogic_score::getpersstat( "sticks" );

    if ( !isdefined( sticks ) )
        sticks = 0;

    self maps\mp\gametypes\_persistence::setafteractionreportstat( "wagerAwards", sticks, 1 );
    bestkillstreak = self maps\mp\gametypes\_globallogic_score::getpersstat( "best_kill_streak" );

    if ( !isdefined( bestkillstreak ) )
        bestkillstreak = 0;

    self maps\mp\gametypes\_persistence::setafteractionreportstat( "wagerAwards", bestkillstreak, 2 );
}
