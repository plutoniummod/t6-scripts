// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_scoreevents;
#include maps\mp\_challenges;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\gametypes\_rank;
#include maps\mp\gametypes\_globallogic_score;

init()
{
    level.scoreeventcallbacks = [];
    level.scoreeventgameendcallback = ::ongameend;
    registerscoreeventcallback( "playerKilled", maps\mp\_scoreevents::scoreeventplayerkill );
}

scoreeventtablelookupint( index, scoreeventcolumn )
{
    return int( tablelookup( "mp/scoreInfo.csv", 0, index, scoreeventcolumn ) );
}

scoreeventtablelookup( index, scoreeventcolumn )
{
    return tablelookup( "mp/scoreInfo.csv", 0, index, scoreeventcolumn );
}

getscoreeventcolumn( gametype )
{
    columnoffset = getcolumnoffsetforgametype( gametype );
    assert( columnoffset >= 0 );

    if ( columnoffset >= 0 )
        columnoffset += 0;

    return columnoffset;
}

getxpeventcolumn( gametype )
{
    columnoffset = getcolumnoffsetforgametype( gametype );
    assert( columnoffset >= 0 );

    if ( columnoffset >= 0 )
        columnoffset += 1;

    return columnoffset;
}

getcolumnoffsetforgametype( gametype )
{
    foundgamemode = 0;

    if ( !isdefined( level.scoreeventtableid ) )
        level.scoreeventtableid = getscoreeventtableid();

    assert( isdefined( level.scoreeventtableid ) );

    if ( !isdefined( level.scoreeventtableid ) )
        return -1;

    gamemodecolumn = 11;

    for (;;)
    {
        column_header = tablelookupcolumnforrow( level.scoreeventtableid, 0, gamemodecolumn );

        if ( column_header == "" )
        {
            gamemodecolumn = 11;
            break;
        }

        if ( column_header == level.gametype + " score" )
        {
            foundgamemode = 1;
            break;
        }

        gamemodecolumn += 2;
    }

    assert( foundgamemode, "Could not find gamemode in scoreInfo.csv:" + gametype );
    return gamemodecolumn;
}

getscoreeventtableid()
{
    scoreinfotableloaded = 0;
    scoreinfotableid = tablelookupfindcoreasset( "mp/scoreInfo.csv" );

    if ( isdefined( scoreinfotableid ) )
        scoreinfotableloaded = 1;

    assert( scoreinfotableloaded, "Score Event Table is not loaded: " + "mp/scoreInfo.csv" );
    return scoreinfotableid;
}

isregisteredevent( type )
{
    if ( isdefined( level.scoreinfo[type] ) )
        return true;
    else
        return false;
}

shouldaddrankxp( player )
{
    if ( !isdefined( level.rankcap ) || level.rankcap == 0 )
        return true;

    if ( player.pers["plevel"] > 0 || player.pers["rank"] > level.rankcap )
        return false;

    return true;
}

processscoreevent( event, player, victim, weapon )
{
    pixbeginevent( "processScoreEvent" );
    scoregiven = 0;

    if ( !isplayer( player ) )
    {
/#
        assertmsg( "processScoreEvent called on non player entity: " + event );
#/
        return scoregiven;
    }

    player thread maps\mp\_challenges::eventreceived( event );

    if ( isregisteredevent( event ) )
    {
        allowplayerscore = 0;

        if ( !isdefined( weapon ) || maps\mp\killstreaks\_killstreaks::iskillstreakweapon( weapon ) == 0 )
            allowplayerscore = 1;
        else
            allowplayerscore = maps\mp\gametypes\_rank::killstreakweaponsallowedscore( event );

        if ( allowplayerscore )
        {
            scoregiven = maps\mp\gametypes\_globallogic_score::giveplayerscore( event, player, victim, weapon, undefined );
            isscoreevent = scoregiven > 0;
        }
    }

    if ( shouldaddrankxp( player ) )
        player addrankxp( event, weapon, isscoreevent );

    pixendevent();
    return scoregiven;
}

registerscoreeventcallback( callback, func )
{
    if ( !isdefined( level.scoreeventcallbacks[callback] ) )
        level.scoreeventcallbacks[callback] = [];

    level.scoreeventcallbacks[callback][level.scoreeventcallbacks[callback].size] = func;
}

scoreeventplayerkill( data, time )
{
    victim = data.victim;
    attacker = data.attacker;
    time = data.time;
    level.numkills++;
    victim = data.victim;
    attacker.lastkilledplayer = victim;
    wasdefusing = data.wasdefusing;
    wasplanting = data.wasplanting;
    wasonground = data.victimonground;
    meansofdeath = data.smeansofdeath;

    if ( isdefined( data.sweapon ) )
    {
        weapon = data.sweapon;
        weaponclass = getweaponclass( data.sweapon );
        killstreak = getkillstreakfromweapon( data.sweapon );
    }

    victim.anglesondeath = victim getplayerangles();

    if ( meansofdeath == "MOD_GRENADE" || meansofdeath == "MOD_GRENADE_SPLASH" || meansofdeath == "MOD_EXPLOSIVE" || meansofdeath == "MOD_EXPLOSIVE_SPLASH" || meansofdeath == "MOD_PROJECTILE" || meansofdeath == "MOD_PROJECTILE_SPLASH" )
    {
        if ( weapon == "none" && isdefined( data.victim.explosiveinfo["weapon"] ) )
            weapon = data.victim.explosiveinfo["weapon"];
    }

    if ( level.teambased )
    {
        attacker.lastkilltime = time;

        if ( isdefined( victim.lastkilltime ) && victim.lastkilltime > time - 3000 )
        {
            if ( isdefined( victim.lastkilledplayer ) && victim.lastkilledplayer isenemyplayer( attacker ) == 0 && attacker != victim.lastkilledplayer )
            {
                processscoreevent( "kill_enemy_who_killed_teammate", attacker, victim, weapon );
                victim recordkillmodifier( "avenger" );
            }
        }

        if ( isdefined( victim.damagedplayers ) )
        {
            keys = getarraykeys( victim.damagedplayers );

            for ( i = 0; i < keys.size; i++ )
            {
                key = keys[i];

                if ( key == attacker.clientid )
                    continue;

                if ( !isdefined( victim.damagedplayers[key].entity ) )
                    continue;

                if ( attacker isenemyplayer( victim.damagedplayers[key].entity ) )
                    continue;

                if ( time - victim.damagedplayers[key].time < 1000 )
                {
                    processscoreevent( "kill_enemy_injuring_teammate", attacker, victim, weapon );

                    if ( isdefined( victim.damagedplayers[key].entity ) )
                    {
                        victim.damagedplayers[key].entity.lastrescuedby = attacker;
                        victim.damagedplayers[key].entity.lastrescuedtime = time;
                    }

                    victim recordkillmodifier( "defender" );
                }
            }
        }
    }

    switch ( weapon )
    {
        case "hatchet_mp":
            attacker.pers["tomahawks"]++;
            attacker.tomahawks = attacker.pers["tomahawks"];
            processscoreevent( "hatchet_kill", attacker, victim, weapon );

            if ( isdefined( data.victim.explosiveinfo["projectile_bounced"] ) && data.victim.explosiveinfo["projectile_bounced"] == 1 )
            {
                level.globalbankshots++;
                processscoreevent( "bounce_hatchet_kill", attacker, victim, weapon );
            }

            break;
        case "knife_ballistic_mp":
            if ( meansofdeath == "MOD_PISTOL_BULLET" || meansofdeath == "MOD_HEAD_SHOT" )
                processscoreevent( "ballistic_knife_kill", attacker, victim, data.sweapon );

            attacker addweaponstat( weapon, "ballistic_knife_kill", 1 );
            break;
        case "supplydrop_mp":
        case "inventory_supplydrop_mp":
            if ( meansofdeath == "MOD_HIT_BY_OBJECT" || meansofdeath == "MOD_CRUSH" )
                processscoreevent( "kill_enemy_with_care_package_crush", attacker, victim, weapon );
            else
                processscoreevent( "kill_enemy_with_hacked_care_package", attacker, victim, weapon );

            break;
    }

    if ( isdefined( data.victimweapon ) )
    {
        if ( data.victimweapon == "minigun_mp" )
            processscoreevent( "killed_death_machine_enemy", attacker, victim, weapon );
        else if ( data.victimweapon == "m32_mp" )
            processscoreevent( "killed_multiple_grenade_launcher_enemy", attacker, victim, weapon );
    }

    attacker thread updatemultikills( weapon, weaponclass, killstreak );

    if ( level.numkills == 1 )
    {
        victim recordkillmodifier( "firstblood" );
        processscoreevent( "first_kill", attacker, victim, weapon );
    }
    else
    {
        if ( isdefined( attacker.lastkilledby ) )
        {
            if ( attacker.lastkilledby == victim )
            {
                level.globalpaybacks++;
                processscoreevent( "revenge_kill", attacker, victim, weapon );
                attacker addweaponstat( weapon, "revenge_kill", 1 );
                victim recordkillmodifier( "revenge" );
                attacker.lastkilledby = undefined;
            }
        }

        if ( victim maps\mp\killstreaks\_killstreaks::isonakillstreak() )
        {
            level.globalbuzzkills++;
            processscoreevent( "stop_enemy_killstreak", attacker, victim, weapon );
            victim recordkillmodifier( "buzzkill" );
        }

        if ( isdefined( victim.lastmansd ) && victim.lastmansd == 1 )
        {
            processscoreevent( "final_kill_elimination", attacker, victim, weapon );

            if ( isdefined( attacker.lastmansd ) && attacker.lastmansd == 1 )
                processscoreevent( "elimination_and_last_player_alive", attacker, victim, weapon );
        }
    }

    if ( is_weapon_valid( meansofdeath, weapon, weaponclass ) )
    {
        if ( isdefined( victim.vattackerorigin ) )
            attackerorigin = victim.vattackerorigin;
        else
            attackerorigin = attacker.origin;

        disttovictim = distancesquared( victim.origin, attackerorigin );
        weap_min_dmg_range = get_distance_for_weapon( weapon, weaponclass );

        if ( disttovictim > weap_min_dmg_range )
        {
            attacker maps\mp\_challenges::longdistancekill();

            if ( weapon == "hatchet_mp" )
                attacker maps\mp\_challenges::longdistancehatchetkill();

            processscoreevent( "longshot_kill", attacker, victim, weapon );
            attacker addweaponstat( weapon, "longshot_kill", 1 );
            attacker.pers["longshots"]++;
            attacker.longshots = attacker.pers["longshots"];
            victim recordkillmodifier( "longshot" );
        }
    }

    if ( isalive( attacker ) )
    {
        if ( attacker.health < attacker.maxhealth * 0.35 )
        {
            attacker.lastkillwheninjured = time;
            processscoreevent( "kill_enemy_when_injured", attacker, victim, weapon );
            attacker addweaponstat( weapon, "kill_enemy_when_injured", 1 );

            if ( attacker hasperk( "specialty_bulletflinch" ) )
                attacker addplayerstat( "perk_bulletflinch_kills", 1 );
        }
    }
    else if ( isdefined( attacker.deathtime ) && attacker.deathtime + 800 < time && !attacker isinvehicle() )
    {
        level.globalafterlifes++;
        processscoreevent( "kill_enemy_after_death", attacker, victim, weapon );
        victim recordkillmodifier( "posthumous" );
    }

    if ( attacker.cur_death_streak >= 3 )
    {
        level.globalcomebacks++;
        processscoreevent( "comeback_from_deathstreak", attacker, victim, weapon );
        victim recordkillmodifier( "comeback" );
    }

    if ( isdefined( victim.beingmicrowavedby ) && weapon != "microwave_turret_mp" )
    {
        if ( victim.beingmicrowavedby != attacker && attacker isenemyplayer( victim.beingmicrowavedby ) == 0 )
        {
            scoregiven = processscoreevent( "microwave_turret_assist", victim.beingmicrowavedby, victim, weapon );

            if ( isdefined( scoregiven ) && isdefined( victim.beingmicrowavedby ) )
                victim.beingmicrowavedby maps\mp\_challenges::earnedmicrowaveassistscore( scoregiven );
        }
        else
            attacker maps\mp\_challenges::killwhiledamagingwithhpm();
    }

    if ( meansofdeath == "MOD_MELEE" && weapon != "riotshield_mp" )
    {
        attacker.pers["stabs"]++;
        attacker.stabs = attacker.pers["stabs"];
        vangles = victim.anglesondeath[1];
        pangles = attacker.anglesonkill[1];
        anglediff = angleclamp180( vangles - pangles );

        if ( anglediff > -30 && anglediff < 70 )
        {
            level.globalbackstabs++;
            processscoreevent( "backstabber_kill", attacker, victim, weapon );
            attacker addweaponstat( weapon, "backstabber_kill", 1 );
            attacker.pers["backstabs"]++;
            attacker.backstabs = attacker.pers["backstabs"];
        }
    }
    else
    {
        if ( isdefined( victim.firsttimedamaged ) && victim.firsttimedamaged == time )
        {
            if ( weaponclass == "weapon_sniper" )
            {
                attacker thread updateoneshotmultikills( victim, weapon, victim.firsttimedamaged );
                attacker addweaponstat( weapon, "kill_enemy_one_bullet", 1 );
            }
        }

        if ( isdefined( attacker.tookweaponfrom[weapon] ) && isdefined( attacker.tookweaponfrom[weapon].previousowner ) )
        {
            pickedupweapon = attacker.tookweaponfrom[weapon];

            if ( pickedupweapon.previousowner == victim )
            {
                processscoreevent( "kill_enemy_with_their_weapon", attacker, victim, weapon );
                attacker addweaponstat( weapon, "kill_enemy_with_their_weapon", 1 );

                if ( isdefined( pickedupweapon.sweapon ) && isdefined( pickedupweapon.smeansofdeath ) )
                {
                    if ( pickedupweapon.sweapon == "knife_held_mp" && pickedupweapon.smeansofdeath == "MOD_MELEE" )
                        attacker addweaponstat( "knife_held_mp", "kill_enemy_with_their_weapon", 1 );
                }
            }
        }
    }

    if ( wasdefusing )
        processscoreevent( "killed_bomb_defuser", attacker, victim, weapon );
    else if ( wasplanting )
        processscoreevent( "killed_bomb_planter", attacker, victim, weapon );

    specificweaponkill( attacker, victim, weapon, killstreak );

    if ( !isdefined( killstreak ) && isdefined( attacker.dtptime ) && attacker.dtptime + 5000 > time )
    {
        attacker.dtptime = 0;

        if ( attacker getstance() == "prone" )
            processscoreevent( "kill_enemy_recent_dive_prone", attacker, self, weapon );
    }

    if ( isdefined( killstreak ) )
        victim recordkillmodifier( "killstreak" );

    attacker.cur_death_streak = 0;
    attacker disabledeathstreak();
}

specificweaponkill( attacker, victim, weapon, killstreak )
{
    switchweapon = weapon;

    if ( isdefined( killstreak ) )
        switchweapon = killstreak;

    switch ( switchweapon )
    {
        case "explosive_bolt_mp":
        case "crossbow_mp":
            if ( isdefined( victim.explosiveinfo["stuckToPlayer"] ) && victim.explosiveinfo["stuckToPlayer"] == victim )
                event = "crossbow_kill";
            else
                return;

            break;
        case "rcbomb_mp":
            event = "rcxd_kill";
            break;
        case "remote_missile_mp":
            event = "remote_missile_kill";
            break;
        case "missile_drone_mp":
            event = "missile_drone_kill";
            break;
        case "autoturret_mp":
            event = "sentry_gun_kill";
            break;
        case "planemortar_mp":
            event = "plane_mortar_kill";
            break;
        case "minigun_mp":
        case "inventory_minigun_mp":
            event = "death_machine_kill";
            break;
        case "m32_mp":
        case "inventory_m32_mp":
            event = "multiple_grenade_launcher_kill";
            break;
        case "qrdrone_mp":
            event = "qrdrone_kill";
            break;
        case "ai_tank_drop_mp":
            event = "aitank_kill";
            break;
        case "helicopter_guard_mp":
            event = "helicopter_guard_kill";
            break;
        case "straferun_mp":
            event = "strafe_run_kill";
            break;
        case "remote_mortar_mp":
            event = "remote_mortar_kill";
            break;
        case "helicopter_player_gunner_mp":
            event = "helicopter_gunner_kill";
            break;
        case "dogs_mp":
            event = "dogs_kill";
            break;
        case "missile_swarm_mp":
            event = "missile_swarm_kill";
            break;
        case "helicopter_comlink_mp":
            event = "helicopter_comlink_kill";
            break;
        case "microwaveturret_mp":
            event = "microwave_turret_kill";
            break;
        default:
            return;
    }

    processscoreevent( event, attacker, victim, weapon );
}

multikill( killcount, weapon )
{
    assert( killcount > 1 );
    self maps\mp\_challenges::multikill( killcount, weapon );

    if ( killcount > 8 )
        processscoreevent( "multikill_more_than_8", self, undefined, weapon );
    else
        processscoreevent( "multikill_" + killcount, self, undefined, weapon );

    self recordmultikill( killcount );
}

uninterruptedobitfeedkills( attacker, sweapon )
{
    self endon( "disconnect" );
    wait 0.1;
    waittillslowprocessallowed();
    wait 0.1;
    maps\mp\_scoreevents::processscoreevent( "uninterrupted_obit_feed_kills", attacker, self, sweapon );
}

is_weapon_valid( meansofdeath, weapon, weaponclass )
{
    valid_weapon = 0;

    if ( get_distance_for_weapon( weapon, weaponclass ) == 0 )
        valid_weapon = 0;
    else if ( meansofdeath == "MOD_PISTOL_BULLET" || meansofdeath == "MOD_RIFLE_BULLET" )
        valid_weapon = 1;
    else if ( meansofdeath == "MOD_HEAD_SHOT" )
        valid_weapon = 1;
    else if ( weapon == "hatchet_mp" && meansofdeath == "MOD_IMPACT" )
        valid_weapon = 1;

    return valid_weapon;
}

updatemultikills( weapon, weaponclass, killstreak )
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self notify( "updateRecentKills" );
    self endon( "updateRecentKills" );
    baseweaponname = getreffromitemindex( getbaseweaponitemindex( weapon ) ) + "_mp";

    if ( !isdefined( self.recentkillcount ) )
        self.recentkillcount = 0;

    if ( !isdefined( self.recentkillcountweapon ) || self.recentkillcountweapon != baseweaponname )
    {
        self.recentkillcountsameweapon = 0;
        self.recentkillcountweapon = baseweaponname;
    }

    if ( !isdefined( killstreak ) )
    {
        self.recentkillcountsameweapon++;
        self.recentkillcount++;
    }

    if ( !isdefined( self.recent_lmg_smg_killcount ) )
        self.recent_lmg_smg_killcount = 0;

    if ( !isdefined( self.recentremotemissilekillcount ) )
        self.recentremotemissilekillcount = 0;

    if ( !isdefined( self.recentremotemissileattackerkillcount ) )
        self.recentremotemissileattackerkillcount = 0;

    if ( !isdefined( self.recentrcbombkillcount ) )
        self.recentrcbombkillcount = 0;

    if ( !isdefined( self.recentrcbombattackerkillcount ) )
        self.recentrcbombattackerkillcount = 0;

    if ( !isdefined( self.recentmglkillcount ) )
        self.recentmglkillcount = 0;

    if ( isdefined( weaponclass ) )
    {
        if ( weaponclass == "weapon_lmg" || weaponclass == "weapon_smg" )
        {
            if ( self playerads() < 1.0 )
                self.recent_lmg_smg_killcount++;
        }
    }

    if ( isdefined( killstreak ) )
    {
        switch ( killstreak )
        {
            case "remote_missile_mp":
                self.recentremotemissilekillcount++;
                break;
            case "rcbomb_mp":
                self.recentrcbombkillcount++;
                break;
            case "m32_mp":
            case "inventory_m32_mp":
                self.recentmglkillcount++;
                break;
        }
    }

    if ( self.recentkillcountsameweapon == 2 )
        self addweaponstat( weapon, "multikill_2", 1 );
    else if ( self.recentkillcountsameweapon == 3 )
        self addweaponstat( weapon, "multikill_3", 1 );

    self waittilltimeoutordeath( 4.0 );

    if ( self.recent_lmg_smg_killcount >= 3 )
        self maps\mp\_challenges::multi_lmg_smg_kill();

    if ( self.recentrcbombkillcount >= 2 )
        self maps\mp\_challenges::multi_rcbomb_kill();

    if ( self.recentmglkillcount >= 3 )
        self maps\mp\_challenges::multi_mgl_kill();

    if ( self.recentremotemissilekillcount >= 3 )
        self maps\mp\_challenges::multi_remotemissile_kill();

    if ( self.recentkillcount > 1 )
        self multikill( self.recentkillcount, weapon );

    self.recentkillcount = 0;
    self.recentkillcountsameweapon = 0;
    self.recentkillcountweapon = undefined;
    self.recent_lmg_smg_killcount = 0;
    self.recentremotemissilekillcount = 0;
    self.recentremotemissileattackerkillcount = 0;
    self.recentrcbombkillcount = 0;
    self.recentmglkillcount = 0;
}

waittilltimeoutordeath( timeout )
{
    self endon( "death" );
    wait( timeout );
}

updateoneshotmultikills( victim, weapon, firsttimedamaged )
{
    self endon( "death" );
    self endon( "disconnect" );
    self notify( "updateoneshotmultikills" + firsttimedamaged );
    self endon( "updateoneshotmultikills" + firsttimedamaged );

    if ( !isdefined( self.oneshotmultikills ) )
        self.oneshotmultikills = 0;

    self.oneshotmultikills++;
    wait 1.0;

    if ( self.oneshotmultikills > 1 )
        processscoreevent( "kill_enemies_one_bullet", self, victim, weapon );
    else
        processscoreevent( "kill_enemy_one_bullet", self, victim, weapon );

    self.oneshotmultikills = 0;
}

get_distance_for_weapon( weapon, weaponclass )
{
    distance = 0;

    switch ( weaponclass )
    {
        case "weapon_smg":
            distance = 1562500;
            break;
        case "weapon_assault":
            distance = 2250000;
            break;
        case "weapon_lmg":
            distance = 2250000;
            break;
        case "weapon_sniper":
            distance = 3062500;
            break;
        case "weapon_pistol":
            distance = 490000;
            break;
        case "weapon_cqb":
            distance = 422500;
            break;
        case "weapon_special":
            if ( weapon == "knife_ballistic_mp" )
                distance = 2250000;
            else if ( weapon == "crossbow_mp" )
                distance = 2250000;
            else if ( weapon == "metalstorm_mp" )
                distance = 3062500;

            break;
        case "weapon_grenade":
            if ( weapon == "hatchet_mp" )
                distance = 6250000;

            break;
        default:
            distance = 0;
            break;
    }

    return distance;
}

decrementlastobituaryplayercountafterfade()
{
    level endon( "reset_obituary_count" );
    wait 5;
    level.lastobituaryplayercount--;
    assert( level.lastobituaryplayercount >= 0 );
}

ongameend( data )
{
    player = data.player;
    winner = data.winner;

    if ( isdefined( winner ) )
    {
        if ( level.teambased )
        {
            if ( winner != "tie" && player.team == winner )
            {
                processscoreevent( "won_match", player );
                return;
            }
        }
        else
        {
            placement = level.placement["all"];
            topthreeplayers = min( 3, placement.size );

            for ( index = 0; index < topthreeplayers; index++ )
            {
                if ( level.placement["all"][index] == player )
                {
                    processscoreevent( "won_match", player );
                    return;
                }
            }
        }
    }

    processscoreevent( "completed_match", player );
}
