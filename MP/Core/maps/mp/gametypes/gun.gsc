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
#include maps\mp\gametypes\_rank;
#include maps\mp\gametypes\_gameobjects;
#include maps\mp\gametypes\_spawning;
#include maps\mp\gametypes\_spawnlogic;
#include maps\mp\gametypes\_persistence;

main()
{
    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::setupcallbacks();
    maps\mp\gametypes\_globallogic::setupcallbacks();
    level.onstartgametype = ::onstartgametype;
    level.onspawnplayer = ::onspawnplayer;
    level.onspawnplayerunified = ::onspawnplayerunified;
    level.onplayerkilled = ::onplayerkilled;
    level.onwagerawards = ::onwagerawards;
    level.onendgame = ::onendgame;
    game["dialog"]["gametype"] = "gg_start";
    game["dialog"]["wm_promoted"] = "gg_promote";
    game["dialog"]["wm_humiliation"] = "mpl_wager_humiliate";
    game["dialog"]["wm_humiliated"] = "sns_hum";
    level.givecustomloadout = ::givecustomloadout;
    precachestring( &"MPUI_PLAYER_KILLED" );
    precachestring( &"MP_GUN_NEXT_LEVEL" );
    precachestring( &"MP_GUN_PREV_LEVEL" );
    precachestring( &"MP_GUN_PREV_LEVEL_OTHER" );
    precachestring( &"MP_HUMILIATION" );
    precachestring( &"MP_HUMILIATED" );
    precacheitem( "minigun_wager_mp" );
    precacheitem( "m32_wager_mp" );
    level.setbacksperdemotion = getgametypesetting( "setbacks" );
    gunlist = getgametypesetting( "gunSelection" );

    if ( gunlist == 3 )
        gunlist = randomintrange( 0, 3 );

    switch ( gunlist )
    {
        case 0:
            addguntoprogression( "beretta93r_mp+tacknife" );
            addguntoprogression( "kard_dw_mp" );
            addguntoprogression( "judge_mp+steadyaim" );
            addguntoprogression( "ksg_mp+fastads" );
            addguntoprogression( "srm1216_mp+extclip" );
            addguntoprogression( "insas_mp+grip" );
            addguntoprogression( "evoskorpion_mp+steadyaim" );
            addguntoprogression( "qcw05_mp+reflex" );
            addguntoprogression( "hk416_mp+mms" );
            addguntoprogression( "xm8_mp+holo" );
            addguntoprogression( "saritch_mp+acog" );
            addguntoprogression( "qbb95_mp+rangefinder" );
            addguntoprogression( "mk48_mp+dualoptic", "dualoptic_mk48_mp+dualoptic" );
            addguntoprogression( "svu_mp+ir" );
            addguntoprogression( "dsr50_mp+vzoom" );
            addguntoprogression( "ballista_mp+is" );
            addguntoprogression( "smaw_mp" );
            addguntoprogression( "usrpg_mp" );
            addguntoprogression( "crossbow_mp" );
            addguntoprogression( "knife_ballistic_mp" );
            break;
        case 1:
            addguntoprogression( "fiveseven_mp" );
            addguntoprogression( "fnp45_mp" );
            addguntoprogression( "kard_mp" );
            addguntoprogression( "beretta93r_mp" );
            addguntoprogression( "judge_mp" );
            addguntoprogression( "ksg_mp" );
            addguntoprogression( "870mcs_mp" );
            addguntoprogression( "saiga12_mp" );
            addguntoprogression( "srm1216_mp" );
            addguntoprogression( "mp7_mp" );
            addguntoprogression( "evoskorpion_mp" );
            addguntoprogression( "pdw57_mp" );
            addguntoprogression( "insas_mp" );
            addguntoprogression( "vector_mp" );
            addguntoprogression( "qcw05_mp" );
            addguntoprogression( "m32_wager_mp" );
            addguntoprogression( "smaw_mp" );
            addguntoprogression( "usrpg_mp" );
            addguntoprogression( "crossbow_mp" );
            addguntoprogression( "knife_ballistic_mp" );
            break;
        case 2:
            addguntoprogression( "hk416_mp" );
            addguntoprogression( "scar_mp" );
            addguntoprogression( "tar21_mp" );
            addguntoprogression( "an94_mp" );
            addguntoprogression( "type95_mp" );
            addguntoprogression( "xm8_mp" );
            addguntoprogression( "sig556_mp" );
            addguntoprogression( "sa58_mp" );
            addguntoprogression( "saritch_mp" );
            addguntoprogression( "hamr_mp" );
            addguntoprogression( "lsat_mp" );
            addguntoprogression( "qbb95_mp" );
            addguntoprogression( "mk48_mp" );
            addguntoprogression( "svu_mp" );
            addguntoprogression( "as50_mp" );
            addguntoprogression( "dsr50_mp" );
            addguntoprogression( "ballista_mp+is" );
            addguntoprogression( "usrpg_mp" );
            addguntoprogression( "crossbow_mp" );
            addguntoprogression( "knife_ballistic_mp" );
            break;
    }

    registertimelimit( 0, 1440 );
    registerroundlimit( 0, 10 );
    registerroundwinlimit( 0, 10 );
    registernumlives( 0, 100 );
    setscoreboardcolumns( "pointstowin", "kills", "deaths", "stabs", "humiliated" );
}

addguntoprogression( gunname, altname )
{
    if ( !isdefined( level.gunprogression ) )
        level.gunprogression = [];

    newweapon = spawnstruct();
    newweapon.names = [];
    newweapon.names[newweapon.names.size] = gunname;

    if ( isdefined( altname ) )
        newweapon.names[newweapon.names.size] = altname;

    level.gunprogression[level.gunprogression.size] = newweapon;
}

givecustomloadout( takeallweapons, alreadyspawned )
{
    chooserandombody = 0;

    if ( !isdefined( alreadyspawned ) || !alreadyspawned )
        chooserandombody = 1;

    if ( !isdefined( self.gunprogress ) )
        self.gunprogress = 0;

    currentweapon = level.gunprogression[self.gunprogress].names[0];
    self maps\mp\gametypes\_wager::setupblankrandomplayer( takeallweapons, chooserandombody, currentweapon );
    self disableweaponcycling();
    self giveweapon( currentweapon );
    self switchtoweapon( currentweapon );
    self giveweapon( "knife_mp" );

    if ( !isdefined( alreadyspawned ) || !alreadyspawned )
        self setspawnweapon( currentweapon );

    if ( isdefined( takeallweapons ) && !takeallweapons )
        self thread takeoldweapons( currentweapon );
    else
        self enableweaponcycling();

    return currentweapon;
}

takeoldweapons( currentweapon )
{
    self endon( "disconnect" );
    self endon( "death" );

    for (;;)
    {
        self waittill( "weapon_change", newweapon );

        if ( newweapon != "none" )
            break;
    }

    weaponslist = self getweaponslist();

    for ( i = 0; i < weaponslist.size; i++ )
    {
        if ( weaponslist[i] != currentweapon && weaponslist[i] != "knife_mp" )
            self takeweapon( weaponslist[i] );
    }

    self enableweaponcycling();
}

promoteplayer( weaponused )
{
    self endon( "disconnect" );
    self endon( "cancel_promotion" );
    level endon( "game_ended" );
    wait 0.05;

    for ( i = 0; i < level.gunprogression[self.gunprogress].names.size; i++ )
    {
        if ( weaponused == level.gunprogression[self.gunprogress].names[i] || weaponused == "explosive_bolt_mp" && ( level.gunprogression[self.gunprogress].names[i] == "crossbow_mp" || level.gunprogression[self.gunprogress].names[i] == "crossbow_mp+reflex" || level.gunprogression[self.gunprogress].names[i] == "crossbow_mp+acog" ) )
        {
            if ( self.gunprogress < level.gunprogression.size - 1 )
            {
                self.gunprogress++;

                if ( isalive( self ) )
                    self thread givecustomloadout( 0, 1 );

                self thread maps\mp\gametypes\_wager::queuewagerpopup( &"MPUI_PLAYER_KILLED", 0, &"MP_GUN_NEXT_LEVEL" );
            }

            pointstowin = self.pers["pointstowin"];

            if ( pointstowin < level.scorelimit )
            {
                self maps\mp\gametypes\_globallogic_score::givepointstowin( level.gungamekillscore );
                maps\mp\_scoreevents::processscoreevent( "kill_gun", self );
            }

            self.lastpromotiontime = gettime();
            return;
        }
    }
}

demoteplayer()
{
    self endon( "disconnect" );
    self notify( "cancel_promotion" );
    startinggunprogress = self.gunprogress;

    for ( i = 0; i < level.setbacksperdemotion; i++ )
    {
        if ( self.gunprogress <= 0 )
            break;

        self maps\mp\gametypes\_globallogic_score::givepointstowin( level.gungamekillscore * -1 );
        self.gunprogress--;
    }

    if ( startinggunprogress != self.gunprogress && isalive( self ) )
        self thread givecustomloadout( 0, 1 );

    self.pers["humiliated"]++;
    self.humiliated = self.pers["humiliated"];
    self thread maps\mp\gametypes\_wager::queuewagerpopup( &"MP_HUMILIATED", 0, &"MP_GUN_PREV_LEVEL", "wm_humiliated" );
    self playlocalsound( game["dialog"]["wm_humiliation"] );
    self maps\mp\gametypes\_globallogic_audio::leaderdialogonplayer( "wm_humiliated" );
}

onplayerkilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    if ( smeansofdeath == "MOD_SUICIDE" || smeansofdeath == "MOD_TRIGGER_HURT" )
    {
        self thread demoteplayer();
        return;
    }

    if ( isdefined( attacker ) && isplayer( attacker ) )
    {
        if ( attacker == self )
        {
            self thread demoteplayer();
            return;
        }

        if ( isdefined( attacker.lastpromotiontime ) && attacker.lastpromotiontime + 3000 > gettime() )
            maps\mp\_scoreevents::processscoreevent( "kill_in_3_seconds_gun", attacker, self, sweapon );

        if ( smeansofdeath == "MOD_MELEE" )
        {
            if ( maps\mp\gametypes\_globallogic::istopscoringplayer( self ) )
                maps\mp\_scoreevents::processscoreevent( "knife_leader_gun", attacker, self, sweapon );
            else
                maps\mp\_scoreevents::processscoreevent( "humiliation_gun", attacker, self, sweapon );

            attacker playlocalsound( game["dialog"]["wm_humiliation"] );
            self thread demoteplayer();
        }
        else
            attacker thread promoteplayer( sweapon );
    }
}

onstartgametype()
{
    level.gungamekillscore = maps\mp\gametypes\_rank::getscoreinfovalue( "kill_gun" );
    registerscorelimit( level.gunprogression.size * level.gungamekillscore, level.gunprogression.size * level.gungamekillscore );
    setdvar( "scr_xpscale", 0 );
    setdvar( "ui_weapon_tiers", level.gunprogression.size );
    makedvarserverinfo( "ui_weapon_tiers", level.gunprogression.size );
    setclientnamemode( "auto_change" );
    setobjectivetext( "allies", &"OBJECTIVES_GUN" );
    setobjectivetext( "axis", &"OBJECTIVES_GUN" );

    if ( level.splitscreen )
    {
        setobjectivescoretext( "allies", &"OBJECTIVES_GUN" );
        setobjectivescoretext( "axis", &"OBJECTIVES_GUN" );
    }
    else
    {
        setobjectivescoretext( "allies", &"OBJECTIVES_GUN_SCORE" );
        setobjectivescoretext( "axis", &"OBJECTIVES_GUN_SCORE" );
    }

    setobjectivehinttext( "allies", &"OBJECTIVES_GUN_HINT" );
    setobjectivehinttext( "axis", &"OBJECTIVES_GUN_HINT" );
    allowed[0] = "gun";
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
    level.quickmessagetoall = 1;
}

onspawnplayerunified()
{
    maps\mp\gametypes\_spawning::onspawnplayer_unified();
    self thread infiniteammo();
}

onspawnplayer( predictedspawn )
{
    spawnpoints = maps\mp\gametypes\_spawnlogic::getteamspawnpoints( self.pers["team"] );
    spawnpoint = maps\mp\gametypes\_spawnlogic::getspawnpoint_dm( spawnpoints );

    if ( predictedspawn )
        self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
    else
    {
        self spawn( spawnpoint.origin, spawnpoint.angles, "gun" );
        self thread infiniteammo();
    }
}

infiniteammo()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        wait 0.1;
        weapon = self getcurrentweapon();
        self givemaxammo( weapon );
    }
}

onwagerawards()
{
    stabs = self maps\mp\gametypes\_globallogic_score::getpersstat( "stabs" );

    if ( !isdefined( stabs ) )
        stabs = 0;

    self maps\mp\gametypes\_persistence::setafteractionreportstat( "wagerAwards", stabs, 0 );
    headshots = self maps\mp\gametypes\_globallogic_score::getpersstat( "headshots" );

    if ( !isdefined( headshots ) )
        headshots = 0;

    self maps\mp\gametypes\_persistence::setafteractionreportstat( "wagerAwards", headshots, 1 );
    bestkillstreak = self maps\mp\gametypes\_globallogic_score::getpersstat( "best_kill_streak" );

    if ( !isdefined( bestkillstreak ) )
        bestkillstreak = 0;

    self maps\mp\gametypes\_persistence::setafteractionreportstat( "wagerAwards", bestkillstreak, 2 );
}

onendgame( winningplayer )
{
    if ( isdefined( winningplayer ) && isplayer( winningplayer ) )
        [[ level._setplayerscore ]]( winningplayer, [[ level._getplayerscore ]]( winningplayer ) + level.gungamekillscore );
}
