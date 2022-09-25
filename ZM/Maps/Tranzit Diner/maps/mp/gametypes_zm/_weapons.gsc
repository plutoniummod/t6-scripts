// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_weapon_utils;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\_sticky_grenade;
#include maps\mp\_bb;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\_challenges;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\gametypes_zm\_globallogic_utils;
#include maps\mp\gametypes_zm\_shellshock;
#include maps\mp\gametypes_zm\_gameobjects;

init()
{
    precacheitem( "knife_mp" );
    precacheitem( "knife_held_mp" );
    precacheitem( "dogs_mp" );
    precacheitem( "dog_bite_mp" );
    precacheitem( "explosive_bolt_mp" );
    precachemodel( "t6_wpn_claymore_world_detect" );
    precachemodel( "t6_wpn_c4_world_detect" );
    precachemodel( "t5_weapon_scrambler_world_detect" );
    precachemodel( "t6_wpn_tac_insert_detect" );
    precachemodel( "t6_wpn_taser_mine_world_detect" );
    precachemodel( "t6_wpn_motion_sensor_world_detect" );
    precachemodel( "t6_wpn_trophy_system_world_detect" );
    precachemodel( "t6_wpn_bouncing_betty_world_detect" );
    precachemodel( "t5_weapon_camera_head_world" );
    precacheitem( "scavenger_item_mp" );
    precacheitem( "scavenger_item_hack_mp" );
    precacheshader( "hud_scavenger_pickup" );
    precacheshellshock( "default" );
    precacheshellshock( "concussion_grenade_mp" );
    precacheshellshock( "tabun_gas_mp" );
    precacheshellshock( "tabun_gas_nokick_mp" );
    precacheshellshock( "proximity_grenade" );
    precacheshellshock( "proximity_grenade_exit" );
    level.missileentities = [];
    level.hackertooltargets = [];

    if ( !isdefined( level.grenadelauncherdudtime ) )
        level.grenadelauncherdudtime = 0;

    if ( !isdefined( level.throwngrenadedudtime ) )
        level.throwngrenadedudtime = 0;

    level thread onplayerconnect();
    maps\mp\gametypes_zm\_weaponobjects::init();

    if ( !is_false( level._uses_sticky_grenades ) )
        maps\mp\_sticky_grenade::init();
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player.usedweapons = 0;
        player.lastfiretime = 0;
        player.hits = 0;
        player scavenger_hud_create();
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self.concussionendtime = 0;
        self.hasdonecombat = 0;
        self.shielddamageblocked = 0;
        self thread watchweaponusage();
        self thread watchgrenadeusage();
        self thread watchmissileusage();
        self thread watchweaponchange();
        self thread watchturretuse();
        self thread watchriotshielduse();
        self thread trackweapon();
        self.droppeddeathweapon = undefined;
        self.tookweaponfrom = [];
        self.pickedupweaponkills = [];
        self thread updatestowedweapon();
    }
}

watchturretuse()
{
    self endon( "death" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "turretownerchange", turret );

        self thread watchfortowfire( turret );
    }
}

watchfortowfire( turret )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "turretownerchange" );

    while ( true )
    {
        self waittill( "turret_tow_fire" );

        self thread watchmissleunlink( turret );

        self waittill( "turret_tow_unlink" );
    }
}

watchmissleunlink( turret )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "turretownerchange" );

    self waittill( "turret_tow_unlink" );

    self relinktoturret( turret );
}

watchweaponchange()
{
    self endon( "death" );
    self endon( "disconnect" );
    self.lastdroppableweapon = self getcurrentweapon();
    self.hitsthismag = [];
    weapon = self getcurrentweapon();

    if ( isprimaryweapon( weapon ) && !isdefined( self.hitsthismag[weapon] ) )
        self.hitsthismag[weapon] = weaponclipsize( weapon );

    while ( true )
    {
        previous_weapon = self getcurrentweapon();

        self waittill( "weapon_change", newweapon );

        if ( maydropweapon( newweapon ) )
            self.lastdroppableweapon = newweapon;

        if ( newweapon != "none" )
        {
            if ( ( isprimaryweapon( newweapon ) || issidearm( newweapon ) ) && !isdefined( self.hitsthismag[newweapon] ) )
                self.hitsthismag[newweapon] = weaponclipsize( newweapon );
        }
    }
}

watchriotshielduse()
{

}

updatelastheldweapontimings( newtime )
{
    if ( isdefined( self.currentweapon ) && isdefined( self.currentweaponstarttime ) )
    {
        totaltime = int( ( newtime - self.currentweaponstarttime ) / 1000 );

        if ( totaltime > 0 )
        {
            self addweaponstat( self.currentweapon, "timeUsed", totaltime );
            self.currentweaponstarttime = newtime;
        }
    }
}

updateweapontimings( newtime )
{
    if ( self is_bot() )
        return;

    updatelastheldweapontimings( newtime );

    if ( !isdefined( self.staticweaponsstarttime ) )
        return;

    totaltime = int( ( newtime - self.staticweaponsstarttime ) / 1000 );

    if ( totaltime < 0 )
        return;

    self.staticweaponsstarttime = newtime;

    if ( isdefined( self.weapon_array_grenade ) )
    {
        for ( i = 0; i < self.weapon_array_grenade.size; i++ )
            self addweaponstat( self.weapon_array_grenade[i], "timeUsed", totaltime );
    }

    if ( isdefined( self.weapon_array_inventory ) )
    {
        for ( i = 0; i < self.weapon_array_inventory.size; i++ )
            self addweaponstat( self.weapon_array_inventory[i], "timeUsed", totaltime );
    }

    if ( isdefined( self.killstreak ) )
    {
        for ( i = 0; i < self.killstreak.size; i++ )
        {
            killstreakweapon = level.menureferenceforkillstreak[self.killstreak[i]];

            if ( isdefined( killstreakweapon ) )
                self addweaponstat( killstreakweapon, "timeUsed", totaltime );
        }
    }

    if ( level.rankedmatch && level.perksenabled )
    {
        perksindexarray = [];
        specialtys = self.specialty;

        if ( !isdefined( specialtys ) )
            return;

        if ( !isdefined( self.class ) )
            return;

        if ( isdefined( self.class_num ) )
        {
            for ( numspecialties = 0; numspecialties < level.maxspecialties; numspecialties++ )
            {
                perk = self getloadoutitem( self.class_num, "specialty" + ( numspecialties + 1 ) );

                if ( perk != 0 )
                    perksindexarray[perk] = 1;
            }

            perkindexarraykeys = getarraykeys( perksindexarray );

            for ( i = 0; i < perkindexarraykeys.size; i++ )
            {
                if ( perksindexarray[perkindexarraykeys[i]] == 1 )
                    self adddstat( "itemStats", perkindexarraykeys[i], "stats", "timeUsed", "statValue", totaltime );
            }
        }
    }
}

trackweapon()
{
    currentweapon = self getcurrentweapon();
    currenttime = gettime();
    spawnid = getplayerspawnid( self );

    while ( true )
    {
        event = self waittill_any_return( "weapon_change", "death", "disconnect" );
        newtime = gettime();

        if ( event == "weapon_change" )
        {
            self maps\mp\_bb::commitweapondata( spawnid, currentweapon, currenttime );
            newweapon = self getcurrentweapon();

            if ( newweapon != "none" && newweapon != currentweapon )
            {
                updatelastheldweapontimings( newtime );
                currentweapon = newweapon;
                currenttime = newtime;
            }
        }
        else
        {
            if ( event != "disconnect" )
            {
                self maps\mp\_bb::commitweapondata( spawnid, currentweapon, currenttime );
                updateweapontimings( newtime );
            }

            return;
        }
    }
}

maydropweapon( weapon )
{
    if ( level.disableweapondrop == 1 )
        return false;

    if ( weapon == "none" )
        return false;

    if ( ishackweapon( weapon ) )
        return false;

    invtype = weaponinventorytype( weapon );

    if ( invtype != "primary" )
        return false;

    if ( weapon == "none" )
        return false;

    return true;
}

dropweaponfordeath( attacker )
{
    if ( level.disableweapondrop == 1 )
        return;

    weapon = self.lastdroppableweapon;

    if ( isdefined( self.droppeddeathweapon ) )
        return;

    if ( !isdefined( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: not defined" );
#/
        return;
    }

    if ( weapon == "none" )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: weapon == none" );
#/
        return;
    }

    if ( !self hasweapon( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: don't have it anymore (" + weapon + ")" );
#/
        return;
    }

    if ( !self anyammoforweaponmodes( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: no ammo for weapon modes" );
#/
        return;
    }

    if ( !shoulddroplimitedweapon( weapon, self ) )
        return;

    clipammo = self getweaponammoclip( weapon );
    stockammo = self getweaponammostock( weapon );
    clip_and_stock_ammo = clipammo + stockammo;

    if ( !clip_and_stock_ammo )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: no ammo" );
#/
        return;
    }

    stockmax = weaponmaxammo( weapon );

    if ( stockammo > stockmax )
        stockammo = stockmax;

    item = self dropitem( weapon );

    if ( !isdefined( item ) )
    {
/#
        iprintlnbold( "dropItem: was not able to drop weapon " + weapon );
#/
        return;
    }
/#
    if ( getdvar( _hash_8F7FC88 ) == "1" )
        println( "dropped weapon: " + weapon );
#/
    droplimitedweapon( weapon, self, item );
    self.droppeddeathweapon = 1;
    item itemweaponsetammo( clipammo, stockammo );
    item.owner = self;
    item.ownersattacker = attacker;
    item thread watchpickup();
    item thread deletepickupafterawhile();
}

dropweapontoground( weapon )
{
    if ( !isdefined( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: not defined" );
#/
        return;
    }

    if ( weapon == "none" )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: weapon == none" );
#/
        return;
    }

    if ( !self hasweapon( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: don't have it anymore (" + weapon + ")" );
#/
        return;
    }

    if ( !self anyammoforweaponmodes( weapon ) )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: no ammo for weapon modes" );
#/
        switch ( weapon )
        {
            case "mp40_blinged_mp":
            case "minigun_mp":
            case "m32_mp":
            case "m220_tow_mp":
            case "m202_flash_mp":
                self takeweapon( weapon );
                break;
            default:
                break;
        }

        return;
    }

    if ( !shoulddroplimitedweapon( weapon, self ) )
        return;

    clipammo = self getweaponammoclip( weapon );
    stockammo = self getweaponammostock( weapon );
    clip_and_stock_ammo = clipammo + stockammo;

    if ( !clip_and_stock_ammo )
    {
/#
        if ( getdvar( _hash_8F7FC88 ) == "1" )
            println( "didn't drop weapon: no ammo" );
#/
        return;
    }

    stockmax = weaponmaxammo( weapon );

    if ( stockammo > stockmax )
        stockammo = stockmax;

    item = self dropitem( weapon );
/#
    if ( getdvar( _hash_8F7FC88 ) == "1" )
        println( "dropped weapon: " + weapon );
#/
    droplimitedweapon( weapon, self, item );
    item itemweaponsetammo( clipammo, stockammo );
    item.owner = self;
    item thread watchpickup();
    item thread deletepickupafterawhile();
}

deletepickupafterawhile()
{
    self endon( "death" );
    wait 60;

    if ( !isdefined( self ) )
        return;

    self delete();
}

getitemweaponname()
{
    classname = self.classname;
    assert( getsubstr( classname, 0, 7 ) == "weapon_" );
    weapname = getsubstr( classname, 7 );
    return weapname;
}

watchpickup()
{
    self endon( "death" );
    weapname = self getitemweaponname();

    while ( true )
    {
        self waittill( "trigger", player, droppeditem );

        if ( isdefined( droppeditem ) )
            break;
    }
/#
    if ( getdvar( _hash_8F7FC88 ) == "1" )
        println( "picked up weapon: " + weapname + ", " + isdefined( self.ownersattacker ) );
#/
    assert( isdefined( player.tookweaponfrom ) );
    assert( isdefined( player.pickedupweaponkills ) );
    droppedweaponname = droppeditem getitemweaponname();

    if ( isdefined( player.tookweaponfrom[droppedweaponname] ) )
    {
        droppeditem.owner = player.tookweaponfrom[droppedweaponname];
        droppeditem.ownersattacker = player;
        player.tookweaponfrom[droppedweaponname] = undefined;
    }

    droppeditem thread watchpickup();

    if ( isdefined( self.ownersattacker ) && self.ownersattacker == player )
    {
        player.tookweaponfrom[weapname] = self.owner;
        player.pickedupweaponkills[weapname] = 0;
    }
    else
    {
        player.tookweaponfrom[weapname] = undefined;
        player.pickedupweaponkills[weapname] = undefined;
    }
}

itemremoveammofromaltmodes()
{
    origweapname = self getitemweaponname();
    curweapname = weaponaltweaponname( origweapname );

    for ( altindex = 1; curweapname != "none" && curweapname != origweapname; altindex++ )
    {
        self itemweaponsetammo( 0, 0, altindex );
        curweapname = weaponaltweaponname( curweapname );
    }
}

dropoffhand()
{
    grenadetypes = [];

    for ( index = 0; index < grenadetypes.size; index++ )
    {
        if ( !self hasweapon( grenadetypes[index] ) )
            continue;

        count = self getammocount( grenadetypes[index] );

        if ( !count )
            continue;

        self dropitem( grenadetypes[index] );
    }
}

watchweaponusage()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self.usedkillstreakweapon = [];
    self.usedkillstreakweapon["minigun_mp"] = 0;
    self.usedkillstreakweapon["m32_mp"] = 0;
    self.usedkillstreakweapon["m202_flash_mp"] = 0;
    self.usedkillstreakweapon["m220_tow_mp"] = 0;
    self.usedkillstreakweapon["mp40_blinged_mp"] = 0;
    self.killstreaktype = [];
    self.killstreaktype["minigun_mp"] = "minigun_mp";
    self.killstreaktype["m32_mp"] = "m32_mp";
    self.killstreaktype["m202_flash_mp"] = "m202_flash_mp";
    self.killstreaktype["m220_tow_mp"] = "m220_tow_mp";
    self.killstreaktype["mp40_blinged_mp"] = "mp40_blinged_drop_mp";

    for (;;)
    {
        self waittill( "weapon_fired", curweapon );

        self.lastfiretime = gettime();
        self.hasdonecombat = 1;

        if ( maps\mp\gametypes_zm\_weapons::isprimaryweapon( curweapon ) || maps\mp\gametypes_zm\_weapons::issidearm( curweapon ) )
        {
            if ( isdefined( self.hitsthismag[curweapon] ) )
                self thread updatemagshots( curweapon );
        }

        switch ( weaponclass( curweapon ) )
        {
            case "rifle":
                if ( curweapon == "crossbow_explosive_mp" )
                {
                    level.globalcrossbowfired++;
                    self addweaponstat( curweapon, "shots", 1 );
                    self thread begingrenadetracking();
                    continue;
                }
            case "spread":
            case "smg":
            case "pistol":
            case "mg":
                self trackweaponfire( curweapon );
                level.globalshotsfired++;
                continue;
            case "rocketlauncher":
            case "grenade":
                self addweaponstat( curweapon, "shots", 1 );
                continue;
            default:
                continue;
        }
    }
}

updatemagshots( weaponname )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "updateMagShots_" + weaponname );
    self.hitsthismag[weaponname]--;
    wait 0.05;
    self.hitsthismag[weaponname] = weaponclipsize( weaponname );
}

checkhitsthismag( weaponname )
{
    self endon( "death" );
    self endon( "disconnect" );
    self notify( "updateMagShots_" + weaponname );
    waittillframeend;

    if ( isdefined( self.hitsthismag[weaponname] ) && self.hitsthismag[weaponname] == 0 )
    {
        if ( !sessionmodeiszombiesgame() )
        {
            weaponclass = getweaponclass( weaponname );
            maps\mp\_challenges::fullclipnomisses( weaponclass, weaponname );
        }

        self.hitsthismag[weaponname] = weaponclipsize( weaponname );
    }
}

trackweaponfire( curweapon )
{
    shotsfired = 1;

    if ( isdefined( self.laststandparams ) && self.laststandparams.laststandstarttime == gettime() )
    {
        self.hits = 0;
        return;
    }

    pixbeginevent( "trackWeaponFire" );

    if ( is_true( level.pers_upgrade_sniper ) )
        maps\mp\zombies\_zm_pers_upgrades_functions::pers_sniper_player_fires( curweapon, self.hits );

    self addweaponstat( curweapon, "shots", shotsfired );
    self addweaponstat( curweapon, "hits", self.hits );

    if ( isdefined( level.add_client_stat ) )
    {
        self [[ level.add_client_stat ]]( "total_shots", shotsfired );
        self [[ level.add_client_stat ]]( "hits", self.hits );
    }
    else
    {
        self addplayerstat( "total_shots", shotsfired );
        self addplayerstat( "hits", self.hits );
        self addplayerstat( "misses", int( max( 0, shotsfired - self.hits ) ) );
    }

    self incrementplayerstat( "total_shots", shotsfired );
    self incrementplayerstat( "hits", self.hits );
    self incrementplayerstat( "misses", int( max( 0, shotsfired - self.hits ) ) );
    self maps\mp\_bb::bbaddtostat( "shots", shotsfired );
    self maps\mp\_bb::bbaddtostat( "hits", self.hits );
    self.hits = 0;
    pixendevent();
}

checkhit( sweapon )
{
    switch ( weaponclass( sweapon ) )
    {
        case "smg":
        case "rifle":
        case "pistol":
        case "mg":
            self.hits++;
            break;
        case "spread":
        case "pistol spread":
            self.hits = 1;
            break;
        default:
            break;
    }

    waittillframeend;

    if ( isdefined( self.hitsthismag ) && isdefined( self.hitsthismag[sweapon] ) )
        self thread checkhitsthismag( sweapon );

    if ( sweapon == "bazooka_mp" || isstrstart( sweapon, "t34" ) || isstrstart( sweapon, "panzer" ) )
        self addweaponstat( sweapon, "hits", 1 );
}

watchgrenadeusage()
{
    self endon( "death" );
    self endon( "disconnect" );
    self.throwinggrenade = 0;
    self.gotpullbacknotify = 0;
    self thread beginothergrenadetracking();
    self thread watchforthrowbacks();
    self thread watchforgrenadeduds();
    self thread watchforgrenadelauncherduds();

    for (;;)
    {
        self waittill( "grenade_pullback", weaponname );

        self addweaponstat( weaponname, "shots", 1 );
        self.hasdonecombat = 1;
        self.throwinggrenade = 1;
        self.gotpullbacknotify = 1;

        if ( weaponname == "satchel_charge_mp" )
            self thread beginsatcheltracking();

        self thread begingrenadetracking();
    }
}

watchmissileusage()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "missile_fire", missile, weapon_name );

        self.hasdonecombat = 1;
        assert( isdefined( missile ) );
        level.missileentities[level.missileentities.size] = missile;
        missile thread watchmissiledeath();
    }
}

watchmissiledeath()
{
    self waittill( "death" );

    arrayremovevalue( level.missileentities, self );
}

dropweaponstoground( origin, radius )
{
    weapons = getdroppedweapons();

    for ( i = 0; i < weapons.size; i++ )
    {
        if ( distancesquared( origin, weapons[i].origin ) < radius * radius )
        {
            trace = bullettrace( weapons[i].origin, weapons[i].origin + vectorscale( ( 0, 0, -1 ), 2000.0 ), 0, weapons[i] );
            weapons[i].origin = trace["position"];
        }
    }
}

dropgrenadestoground( origin, radius )
{
    grenades = getentarray( "grenade", "classname" );

    for ( i = 0; i < grenades.size; i++ )
    {
        if ( distancesquared( origin, grenades[i].origin ) < radius * radius )
            grenades[i] launch( vectorscale( ( 1, 1, 1 ), 5.0 ) );
    }
}

watchgrenadecancel()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "grenade_fire" );

    self waittill( "weapon_change" );

    self.throwinggrenade = 0;
    self.gotpullbacknotify = 0;
}

begingrenadetracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    starttime = gettime();
    self thread watchgrenadecancel();

    self waittill( "grenade_fire", grenade, weaponname );

    assert( isdefined( grenade ) );
    level.missileentities[level.missileentities.size] = grenade;
    grenade thread watchmissiledeath();

    if ( grenade maps\mp\gametypes_zm\_weaponobjects::ishacked() )
        return;

    bbprint( "mpequipmentuses", "gametime %d spawnid %d weaponname %s", gettime(), getplayerspawnid( self ), weaponname );

    if ( gettime() - starttime > 1000 )
        grenade.iscooked = 1;

    switch ( weaponname )
    {
        case "sticky_grenade_zm":
        case "frag_grenade_zm":
            self addweaponstat( weaponname, "used", 1 );
        case "explosive_bolt_zm":
            grenade.originalowner = self;
            break;
    }

    if ( weaponname == "sticky_grenade_zm" || weaponname == "frag_grenade_zm" )
    {
        grenade setteam( self.pers["team"] );
        grenade setowner( self );
    }

    self.throwinggrenade = 0;
}

beginothergrenadetracking()
{

}

checkstucktoplayer( deleteonteamchange, awardscoreevent, weaponname )
{
    self endon( "death" );

    self waittill( "stuck_to_player", player );

    if ( isdefined( player ) )
    {
        if ( deleteonteamchange )
            self thread stucktoplayerteamchange( player );

        if ( awardscoreevent && isdefined( self.originalowner ) )
        {
            if ( self.originalowner isenemyplayer( player ) )
            {

            }
        }

        self.stucktoplayer = player;
    }
}

checkhatchetbounce()
{
    self endon( "stuck_to_player" );
    self endon( "death" );

    self waittill( "grenade_bounce" );

    self.bounced = 1;
}

stucktoplayerteamchange( player )
{
    self endon( "death" );
    player endon( "disconnect" );
    originalteam = player.pers["team"];

    while ( true )
    {
        player waittill( "joined_team" );

        if ( player.pers["team"] != originalteam )
        {
            self detonate();
            return;
        }
    }
}

beginsatcheltracking()
{
    self endon( "death" );
    self endon( "disconnect" );
    self waittill_any( "grenade_fire", "weapon_change" );
    self.throwinggrenade = 0;
}

watchforthrowbacks()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "grenade_fire", grenade, weapname );

        if ( self.gotpullbacknotify )
        {
            self.gotpullbacknotify = 0;
            continue;
        }

        if ( !issubstr( weapname, "frag_" ) )
            continue;

        grenade.threwback = 1;
        grenade.originalowner = self;
    }
}

registergrenadelauncherduddvar( dvarstring, defaultvalue, minvalue, maxvalue )
{
    dvarstring = "scr_" + dvarstring + "_grenadeLauncherDudTime";

    if ( getdvar( dvarstring ) == "" )
        setdvar( dvarstring, defaultvalue );

    if ( getdvarint( dvarstring ) > maxvalue )
        setdvar( dvarstring, maxvalue );
    else if ( getdvarint( dvarstring ) < minvalue )
        setdvar( dvarstring, minvalue );

    level.grenadelauncherdudtimedvar = dvarstring;
    level.grenadelauncherdudtimemin = minvalue;
    level.grenadelauncherdudtimemax = maxvalue;
    level.grenadelauncherdudtime = getdvarint( level.grenadelauncherdudtimedvar );
}

registerthrowngrenadeduddvar( dvarstring, defaultvalue, minvalue, maxvalue )
{
    dvarstring = "scr_" + dvarstring + "_thrownGrenadeDudTime";

    if ( getdvar( dvarstring ) == "" )
        setdvar( dvarstring, defaultvalue );

    if ( getdvarint( dvarstring ) > maxvalue )
        setdvar( dvarstring, maxvalue );
    else if ( getdvarint( dvarstring ) < minvalue )
        setdvar( dvarstring, minvalue );

    level.throwngrenadedudtimedvar = dvarstring;
    level.throwngrenadedudtimemin = minvalue;
    level.throwngrenadedudtimemax = maxvalue;
    level.throwngrenadedudtime = getdvarint( level.throwngrenadedudtimedvar );
}

registerkillstreakdelay( dvarstring, defaultvalue, minvalue, maxvalue )
{
    dvarstring = "scr_" + dvarstring + "_killstreakDelayTime";

    if ( getdvar( dvarstring ) == "" )
        setdvar( dvarstring, defaultvalue );

    if ( getdvarint( dvarstring ) > maxvalue )
        setdvar( dvarstring, maxvalue );
    else if ( getdvarint( dvarstring ) < minvalue )
        setdvar( dvarstring, minvalue );

    level.killstreakrounddelay = getdvarint( dvarstring );
}

turngrenadeintoadud( weapname, isthrowngrenade, player )
{
    if ( level.grenadelauncherdudtime >= maps\mp\gametypes_zm\_globallogic_utils::gettimepassed() / 1000 && !isthrowngrenade )
    {
        if ( issubstr( weapname, "gl_" ) || weapname == "china_lake_mp" )
        {
            timeleft = int( level.grenadelauncherdudtime - maps\mp\gametypes_zm\_globallogic_utils::gettimepassed() / 1000 );

            if ( !timeleft )
                timeleft = 1;

            player iprintlnbold( &"MP_LAUNCHER_UNAVAILABLE_FOR_N", " " + timeleft + " ", &"EXE_SECONDS" );
            self makegrenadedud();
        }
    }
    else if ( level.throwngrenadedudtime >= maps\mp\gametypes_zm\_globallogic_utils::gettimepassed() / 1000 && isthrowngrenade )
    {
        if ( weapname == "frag_grenade_mp" || weapname == "sticky_grenade_mp" )
        {
            if ( isdefined( player.suicide ) && player.suicide )
                return;

            timeleft = int( level.throwngrenadedudtime - maps\mp\gametypes_zm\_globallogic_utils::gettimepassed() / 1000 );

            if ( !timeleft )
                timeleft = 1;

            player iprintlnbold( &"MP_GRENADE_UNAVAILABLE_FOR_N", " " + timeleft + " ", &"EXE_SECONDS" );
            self makegrenadedud();
        }
    }
}

watchforgrenadeduds()
{
    self endon( "spawned_player" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "grenade_fire", grenade, weapname );

        grenade turngrenadeintoadud( weapname, 1, self );
    }
}

watchforgrenadelauncherduds()
{
    self endon( "spawned_player" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "grenade_launcher_fire", grenade, weapname );

        grenade turngrenadeintoadud( weapname, 0, self );
    }
}

getdamageableents( pos, radius, dolos, startradius )
{
    ents = [];

    if ( !isdefined( dolos ) )
        dolos = 0;

    if ( !isdefined( startradius ) )
        startradius = 0;

    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        if ( !isalive( players[i] ) || players[i].sessionstate != "playing" )
            continue;

        playerpos = players[i].origin + vectorscale( ( 0, 0, 1 ), 32.0 );
        distsq = distancesquared( pos, playerpos );

        if ( distsq < radius * radius && ( !dolos || weapondamagetracepassed( pos, playerpos, startradius, undefined ) ) )
        {
            newent = spawnstruct();
            newent.isplayer = 1;
            newent.isadestructable = 0;
            newent.isadestructible = 0;
            newent.isactor = 0;
            newent.entity = players[i];
            newent.damagecenter = playerpos;
            ents[ents.size] = newent;
        }
    }

    grenades = getentarray( "grenade", "classname" );

    for ( i = 0; i < grenades.size; i++ )
    {
        entpos = grenades[i].origin;
        distsq = distancesquared( pos, entpos );

        if ( distsq < radius * radius && ( !dolos || weapondamagetracepassed( pos, entpos, startradius, grenades[i] ) ) )
        {
            newent = spawnstruct();
            newent.isplayer = 0;
            newent.isadestructable = 0;
            newent.isadestructible = 0;
            newent.isactor = 0;
            newent.entity = grenades[i];
            newent.damagecenter = entpos;
            ents[ents.size] = newent;
        }
    }

    destructibles = getentarray( "destructible", "targetname" );

    for ( i = 0; i < destructibles.size; i++ )
    {
        entpos = destructibles[i].origin;
        distsq = distancesquared( pos, entpos );

        if ( distsq < radius * radius && ( !dolos || weapondamagetracepassed( pos, entpos, startradius, destructibles[i] ) ) )
        {
            newent = spawnstruct();
            newent.isplayer = 0;
            newent.isadestructable = 0;
            newent.isadestructible = 1;
            newent.isactor = 0;
            newent.entity = destructibles[i];
            newent.damagecenter = entpos;
            ents[ents.size] = newent;
        }
    }

    destructables = getentarray( "destructable", "targetname" );

    for ( i = 0; i < destructables.size; i++ )
    {
        entpos = destructables[i].origin;
        distsq = distancesquared( pos, entpos );

        if ( distsq < radius * radius && ( !dolos || weapondamagetracepassed( pos, entpos, startradius, destructables[i] ) ) )
        {
            newent = spawnstruct();
            newent.isplayer = 0;
            newent.isadestructable = 1;
            newent.isadestructible = 0;
            newent.isactor = 0;
            newent.entity = destructables[i];
            newent.damagecenter = entpos;
            ents[ents.size] = newent;
        }
    }

    return ents;
}

weapondamagetracepassed( from, to, startradius, ignore )
{
    trace = weapondamagetrace( from, to, startradius, ignore );
    return trace["fraction"] == 1;
}

weapondamagetrace( from, to, startradius, ignore )
{
    midpos = undefined;
    diff = to - from;

    if ( lengthsquared( diff ) < startradius * startradius )
        midpos = to;

    dir = vectornormalize( diff );
    midpos = from + ( dir[0] * startradius, dir[1] * startradius, dir[2] * startradius );
    trace = bullettrace( midpos, to, 0, ignore );

    if ( getdvarint( _hash_A1C40B1 ) != 0 )
    {
        if ( trace["fraction"] == 1 )
            thread debugline( midpos, to, ( 1, 1, 1 ) );
        else
        {
            thread debugline( midpos, trace["position"], ( 1, 0.9, 0.8 ) );
            thread debugline( trace["position"], to, ( 1, 0.4, 0.3 ) );
        }
    }

    return trace;
}

damageent( einflictor, eattacker, idamage, smeansofdeath, sweapon, damagepos, damagedir )
{
    if ( self.isplayer )
    {
        self.damageorigin = damagepos;
        self.entity thread [[ level.callbackplayerdamage ]]( einflictor, eattacker, idamage, 0, smeansofdeath, sweapon, damagepos, damagedir, "none", 0, 0 );
    }
    else if ( self.isactor )
    {
        self.damageorigin = damagepos;
        self.entity thread [[ level.callbackactordamage ]]( einflictor, eattacker, idamage, 0, smeansofdeath, sweapon, damagepos, damagedir, "none", 0, 0 );
    }
    else if ( self.isadestructible )
    {
        self.damageorigin = damagepos;
        self.entity dodamage( idamage, damagepos, eattacker, einflictor, 0, smeansofdeath, 0, sweapon );
    }
    else
    {
        if ( self.isadestructable && ( sweapon == "claymore_mp" || sweapon == "airstrike_mp" ) )
            return;

        self.entity damage_notify_wrapper( idamage, eattacker, ( 0, 0, 0 ), ( 0, 0, 0 ), "mod_explosive", "", "" );
    }
}

debugline( a, b, color )
{
/#
    for ( i = 0; i < 600; i++ )
    {
        line( a, b, color );
        wait 0.05;
    }
#/
}

onweapondamage( eattacker, einflictor, sweapon, meansofdeath, damage )
{
    self endon( "death" );
    self endon( "disconnect" );

    switch ( sweapon )
    {
        case "concussion_grenade_mp":
            radius = 512;

            if ( self == eattacker )
                radius *= 0.5;

            scale = 1 - distance( self.origin, einflictor.origin ) / radius;

            if ( scale < 0 )
                scale = 0;

            time = 2 + 4 * scale;
            wait 0.05;

            if ( self hasperk( "specialty_stunprotection" ) )
                time *= 0.1;

            self thread playconcussionsound( time );

            if ( self mayapplyscreeneffect() )
                self shellshock( "concussion_grenade_mp", time, 0 );

            self.concussionendtime = gettime() + time * 1000;
            break;
        default:
            maps\mp\gametypes_zm\_shellshock::shellshockondamage( meansofdeath, damage );
            break;
    }
}

playconcussionsound( duration )
{
    self endon( "death" );
    self endon( "disconnect" );
    concussionsound = spawn( "script_origin", ( 0, 0, 1 ) );
    concussionsound.origin = self.origin;
    concussionsound linkto( self );
    concussionsound thread deleteentonownerdeath( self );
    concussionsound playsound( "" );
    concussionsound playloopsound( "" );

    if ( duration > 0.5 )
        wait( duration - 0.5 );

    concussionsound playsound( "" );
    concussionsound stoploopsound( 0.5 );
    wait 0.5;
    concussionsound notify( "delete" );
    concussionsound delete();
}

deleteentonownerdeath( owner )
{
    self endon( "delete" );

    owner waittill( "death" );

    self delete();
}

monitor_dog_special_grenades()
{

}

isprimaryweapon( weaponname )
{
    return isdefined( level.primary_weapon_array[weaponname] );
}

issidearm( weaponname )
{
    return isdefined( level.side_arm_array[weaponname] );
}

isinventory( weaponname )
{
    return isdefined( level.inventory_array[weaponname] );
}

isgrenade( weaponname )
{
    return isdefined( level.grenade_array[weaponname] );
}

isexplosivebulletweapon( weaponname )
{
    if ( weaponname == "chopper_minigun_mp" || weaponname == "cobra_20mm_mp" || weaponname == "littlebird_guard_minigun_mp" || weaponname == "cobra_20mm_comlink_mp" )
        return true;

    return false;
}

getweaponclass_array( current )
{
    if ( isprimaryweapon( current ) )
        return level.primary_weapon_array;
    else if ( issidearm( current ) )
        return level.side_arm_array;
    else if ( isgrenade( current ) )
        return level.grenade_array;
    else
        return level.inventory_array;
}

updatestowedweapon()
{
    self endon( "spawned" );
    self endon( "killed_player" );
    self endon( "disconnect" );
    self.tag_stowed_back = undefined;
    self.tag_stowed_hip = undefined;
    team = self.pers["team"];
    class = self.pers["class"];

    while ( true )
    {
        self waittill( "weapon_change", newweapon );

        self.weapon_array_primary = [];
        self.weapon_array_sidearm = [];
        self.weapon_array_grenade = [];
        self.weapon_array_inventory = [];
        weaponslist = self getweaponslist();

        for ( idx = 0; idx < weaponslist.size; idx++ )
        {
            switch ( weaponslist[idx] )
            {
                case "zipline_mp":
                case "mp40_blinged_mp":
                case "minigun_mp":
                case "m32_mp":
                case "m220_tow_mp":
                case "m202_flash_mp":
                    continue;
                default:
                    break;
            }

            if ( isprimaryweapon( weaponslist[idx] ) )
            {
                self.weapon_array_primary[self.weapon_array_primary.size] = weaponslist[idx];
                continue;
            }

            if ( issidearm( weaponslist[idx] ) )
            {
                self.weapon_array_sidearm[self.weapon_array_sidearm.size] = weaponslist[idx];
                continue;
            }

            if ( isgrenade( weaponslist[idx] ) )
            {
                self.weapon_array_grenade[self.weapon_array_grenade.size] = weaponslist[idx];
                continue;
            }

            if ( isinventory( weaponslist[idx] ) )
            {
                self.weapon_array_inventory[self.weapon_array_inventory.size] = weaponslist[idx];
                continue;
            }

            if ( isweaponprimary( weaponslist[idx] ) )
                self.weapon_array_primary[self.weapon_array_primary.size] = weaponslist[idx];
        }

        detach_all_weapons();
        stow_on_back();
        stow_on_hip();
    }
}

forcestowedweaponupdate()
{
    detach_all_weapons();
    stow_on_back();
    stow_on_hip();
}

detachcarryobjectmodel()
{
    if ( isdefined( self.carryobject ) && isdefined( self.carryobject maps\mp\gametypes_zm\_gameobjects::getvisiblecarriermodel() ) )
    {
        if ( isdefined( self.tag_stowed_back ) )
        {
            self detach( self.tag_stowed_back, "tag_stowed_back" );
            self.tag_stowed_back = undefined;
        }
    }
}

detach_all_weapons()
{
    if ( isdefined( self.tag_stowed_back ) )
    {
        clear_weapon = 1;

        if ( isdefined( self.carryobject ) )
        {
            carriermodel = self.carryobject maps\mp\gametypes_zm\_gameobjects::getvisiblecarriermodel();

            if ( isdefined( carriermodel ) && carriermodel == self.tag_stowed_back )
            {
                self detach( self.tag_stowed_back, "tag_stowed_back" );
                clear_weapon = 0;
            }
        }

        if ( clear_weapon )
            self clearstowedweapon();

        self.tag_stowed_back = undefined;
    }

    if ( isdefined( self.tag_stowed_hip ) )
    {
        detach_model = getweaponmodel( self.tag_stowed_hip );
        self detach( detach_model, "tag_stowed_hip_rear" );
        self.tag_stowed_hip = undefined;
    }
}

non_stowed_weapon( weapon )
{
    if ( self hasweapon( "knife_ballistic_mp" ) && weapon != "knife_ballistic_mp" )
        return true;

    if ( self hasweapon( "knife_held_mp" ) && weapon != "knife_held_mp" )
        return true;

    return false;
}

stow_on_back( current )
{
    current = self getcurrentweapon();
    self.tag_stowed_back = undefined;
    weaponoptions = 0;
    index_weapon = "";

    if ( isdefined( self.carryobject ) && isdefined( self.carryobject maps\mp\gametypes_zm\_gameobjects::getvisiblecarriermodel() ) )
    {
        self.tag_stowed_back = self.carryobject maps\mp\gametypes_zm\_gameobjects::getvisiblecarriermodel();
        self attach( self.tag_stowed_back, "tag_stowed_back", 1 );
        return;
    }
    else if ( non_stowed_weapon( current ) || self.hasriotshield )
        return;
    else
    {
        for ( idx = 0; idx < self.weapon_array_primary.size; idx++ )
        {
            temp_index_weapon = self.weapon_array_primary[idx];
            assert( isdefined( temp_index_weapon ), "Primary weapon list corrupted." );

            if ( temp_index_weapon == current )
                continue;

            if ( current == "none" )
                continue;

            if ( issubstr( current, "gl_" ) || issubstr( temp_index_weapon, "gl_" ) || issubstr( current, "mk_" ) || issubstr( temp_index_weapon, "mk_" ) || issubstr( current, "dualoptic_" ) || issubstr( temp_index_weapon, "dualoptic_" ) || issubstr( current, "ft_" ) || issubstr( temp_index_weapon, "ft_" ) )
            {
                index_weapon_tok = strtok( temp_index_weapon, "_" );
                current_tok = strtok( current, "_" );

                for ( i = 0; i < index_weapon_tok.size; i++ )
                {
                    if ( !issubstr( current, index_weapon_tok[i] ) || index_weapon_tok.size != current_tok.size )
                    {
                        i = 0;
                        break;
                    }
                }

                if ( i == index_weapon_tok.size )
                    continue;
            }

            index_weapon = temp_index_weapon;
            assert( isdefined( self.curclass ), "Player missing current class" );

            if ( issubstr( index_weapon, self.pers["primaryWeapon"] ) && issubstr( self.curclass, "CUSTOM" ) )
                self.tag_stowed_back = getweaponmodel( index_weapon, self getloadoutitem( self.class_num, "primarycamo" ) );
            else
            {
                stowedmodelindex = getweaponstowedmodel( index_weapon );
                self.tag_stowed_back = getweaponmodel( index_weapon, stowedmodelindex );
            }

            if ( issubstr( self.curclass, "CUSTOM" ) )
                weaponoptions = self calcweaponoptions( self.class_num, 0 );
        }
    }

    if ( !isdefined( self.tag_stowed_back ) )
        return;

    self setstowedweapon( index_weapon );
}

stow_on_hip()
{
    current = self getcurrentweapon();
    self.tag_stowed_hip = undefined;

    for ( idx = 0; idx < self.weapon_array_inventory.size; idx++ )
    {
        if ( self.weapon_array_inventory[idx] == current )
            continue;

        if ( !self getweaponammostock( self.weapon_array_inventory[idx] ) )
            continue;

        self.tag_stowed_hip = self.weapon_array_inventory[idx];
    }

    if ( !isdefined( self.tag_stowed_hip ) )
        return;

    if ( self.tag_stowed_hip == "satchel_charge_mp" || self.tag_stowed_hip == "claymore_mp" || self.tag_stowed_hip == "bouncingbetty_mp" )
    {
        self.tag_stowed_hip = undefined;
        return;
    }

    weapon_model = getweaponmodel( self.tag_stowed_hip );
    self attach( weapon_model, "tag_stowed_hip_rear", 1 );
}

stow_inventory( inventories, current )
{
    if ( isdefined( self.inventory_tag ) )
    {
        detach_model = getweaponmodel( self.inventory_tag );
        self detach( detach_model, "tag_stowed_hip_rear" );
        self.inventory_tag = undefined;
    }

    if ( !isdefined( inventories[0] ) || self getweaponammostock( inventories[0] ) == 0 )
        return;

    if ( inventories[0] != current )
    {
        self.inventory_tag = inventories[0];
        weapon_model = getweaponmodel( self.inventory_tag );
        self attach( weapon_model, "tag_stowed_hip_rear", 1 );
    }
}

weapons_get_dvar_int( dvar, def )
{
    return int( weapons_get_dvar( dvar, def ) );
}

weapons_get_dvar( dvar, def )
{
    if ( getdvar( dvar ) != "" )
        return getdvarfloat( dvar );
    else
    {
        setdvar( dvar, def );
        return def;
    }
}

player_is_driver()
{
    if ( !isalive( self ) )
        return false;

    if ( self isremotecontrolling() )
        return false;

    vehicle = self getvehicleoccupied();

    if ( isdefined( vehicle ) )
    {
        seat = vehicle getoccupantseat( self );

        if ( isdefined( seat ) && seat == 0 )
            return true;
    }

    return false;
}

loadout_get_class_num()
{
    assert( isplayer( self ) );
    assert( isdefined( self.class ) );

    if ( isdefined( level.classtoclassnum[self.class] ) )
        return level.classtoclassnum[self.class];

    class_num = int( self.class[self.class.size - 1] ) - 1;

    if ( -1 == class_num )
        class_num = 9;

    return class_num;
}

loadout_get_offhand_weapon( stat )
{
    if ( isdefined( level.givecustomloadout ) )
        return "weapon_null_mp";

    class_num = self loadout_get_class_num();
    index = 0;

    if ( isdefined( level.tbl_weaponids[index] ) && isdefined( level.tbl_weaponids[index]["reference"] ) )
        return level.tbl_weaponids[index]["reference"] + "_mp";

    return "weapon_null_mp";
}

loadout_get_offhand_count( stat )
{
    if ( isdefined( level.givecustomloadout ) )
        return 0;

    class_num = self loadout_get_class_num();
    count = 0;
    return count;
}

scavenger_think()
{
    self endon( "death" );

    self waittill( "scavenger", player );

    primary_weapons = player getweaponslistprimaries();
    offhand_weapons_and_alts = array_exclude( player getweaponslist( 1 ), primary_weapons );
    arrayremovevalue( offhand_weapons_and_alts, "knife_mp" );
    player playsound( "fly_equipment_pickup_npc" );
    player playlocalsound( "fly_equipment_pickup_plr" );
    player.scavenger_icon.alpha = 1;
    player.scavenger_icon fadeovertime( 2.5 );
    player.scavenger_icon.alpha = 0;
    scavenger_lethal_proc = 1;
    scavenger_tactical_proc = 1;

    if ( !isdefined( player.scavenger_lethal_proc ) )
    {
        player.scavenger_lethal_proc = 0;
        player.scavenger_tactical_proc = 0;
    }

    loadout_primary = player loadout_get_offhand_weapon( "primarygrenade" );
    loadout_primary_count = player loadout_get_offhand_count( "primarygrenadecount" );
    loadout_secondary = player loadout_get_offhand_weapon( "specialgrenade" );
    loadout_secondary_count = player loadout_get_offhand_count( "specialgrenadeCount" );

    for ( i = 0; i < offhand_weapons_and_alts.size; i++ )
    {
        weapon = offhand_weapons_and_alts[i];

        if ( ishackweapon( weapon ) )
            continue;

        switch ( weapon )
        {
            case "sticky_grenade_mp":
            case "satchel_charge_mp":
            case "hatchet_mp":
            case "frag_grenade_mp":
            case "claymore_mp":
            case "bouncingbetty_mp":
                if ( isdefined( player.grenadetypeprimarycount ) && player.grenadetypeprimarycount < 1 )
                    continue;

                if ( player getweaponammostock( weapon ) != loadout_primary_count )
                {
                    if ( player.scavenger_lethal_proc < scavenger_lethal_proc )
                    {
                        player.scavenger_lethal_proc++;
                        continue;
                    }

                    player.scavenger_lethal_proc = 0;
                    player.scavenger_tactical_proc = 0;
                }
            case "willy_pete_mp":
            case "trophy_system_mp":
            case "tabun_gas_mp":
            case "sensor_grenade_mp":
            case "proximity_grenade_mp":
            case "pda_hack_mp":
            case "nightingale_mp":
            case "flash_grenade_mp":
            case "emp_grenade_mp":
            case "concussion_grenade_mp":
                if ( isdefined( player.grenadetypesecondarycount ) && player.grenadetypesecondarycount < 1 )
                    continue;

                if ( weapon == loadout_secondary && player getweaponammostock( weapon ) != loadout_secondary_count )
                {
                    if ( player.scavenger_tactical_proc < scavenger_tactical_proc )
                    {
                        player.scavenger_tactical_proc++;
                        continue;
                    }

                    player.scavenger_tactical_proc = 0;
                    player.scavenger_lethal_proc = 0;
                }

                maxammo = weaponmaxammo( weapon );
                stock = player getweaponammostock( weapon );

                if ( isdefined( level.customloadoutscavenge ) )
                    maxammo = self [[ level.customloadoutscavenge ]]( weapon );
                else if ( weapon == loadout_primary )
                    maxammo = loadout_primary_count;
                else if ( weapon == loadout_secondary )
                    maxammo = loadout_secondary_count;

                if ( stock < maxammo )
                {
                    ammo = stock + 1;

                    if ( ammo > maxammo )
                        ammo = maxammo;

                    player setweaponammostock( weapon, ammo );
                    player thread maps\mp\_challenges::scavengedgrenade();
                }

                continue;
            default:
                if ( islauncherweapon( weapon ) )
                {
                    stock = player getweaponammostock( weapon );
                    start = player getfractionstartammo( weapon );
                    clip = weaponclipsize( weapon );
                    clip *= getdvarfloatdefault( "scavenger_clip_multiplier", 2 );
                    clip = int( clip );
                    maxammo = weaponmaxammo( weapon );

                    if ( stock < maxammo - clip )
                    {
                        ammo = stock + clip;
                        player setweaponammostock( weapon, ammo );
                    }
                    else
                        player setweaponammostock( weapon, maxammo );
                }

                continue;
        }
    }

    for ( i = 0; i < primary_weapons.size; i++ )
    {
        weapon = primary_weapons[i];

        if ( ishackweapon( weapon ) || weapon == "kniferang_mp" )
            continue;

        stock = player getweaponammostock( weapon );
        start = player getfractionstartammo( weapon );
        clip = weaponclipsize( weapon );
        clip *= getdvarfloatdefault( "scavenger_clip_multiplier", 2 );
        clip = int( clip );
        maxammo = weaponmaxammo( weapon );

        if ( stock < maxammo - clip )
        {
            ammo = stock + clip;
            player setweaponammostock( weapon, ammo );
            continue;
        }

        player setweaponammostock( weapon, maxammo );
    }
}

scavenger_hud_create()
{
    if ( level.wagermatch )
        return;

    self.scavenger_icon = newclienthudelem( self );
    self.scavenger_icon.horzalign = "center";
    self.scavenger_icon.vertalign = "middle";
    self.scavenger_icon.x = -16;
    self.scavenger_icon.y = 16;
    self.scavenger_icon.alpha = 0;
    width = 32;
    height = 16;

    if ( self issplitscreen() )
    {
        width = int( width * 0.5 );
        height = int( height * 0.5 );
        self.scavenger_icon.x = -8;
    }

    self.scavenger_icon setshader( "hud_scavenger_pickup", width, height );
}

dropscavengerfordeath( attacker )
{
    if ( sessionmodeiszombiesgame() )
        return;

    if ( level.wagermatch )
        return;

    if ( !isdefined( attacker ) )
        return;

    if ( attacker == self )
        return;

    if ( level.gametype == "hack" )
        item = self dropscavengeritem( "scavenger_item_hack_mp" );
    else
        item = self dropscavengeritem( "scavenger_item_mp" );

    item thread scavenger_think();
}

addlimitedweapon( weapon_name, owner, num_drops )
{
    limited_info = spawnstruct();
    limited_info.weapon = weapon_name;
    limited_info.drops = num_drops;
    owner.limited_info = limited_info;
}

shoulddroplimitedweapon( weapon_name, owner )
{
    limited_info = owner.limited_info;

    if ( !isdefined( limited_info ) )
        return true;

    if ( limited_info.weapon != weapon_name )
        return true;

    if ( limited_info.drops <= 0 )
        return false;

    return true;
}

droplimitedweapon( weapon_name, owner, item )
{
    limited_info = owner.limited_info;

    if ( !isdefined( limited_info ) )
        return;

    if ( limited_info.weapon != weapon_name )
        return;

    limited_info.drops -= 1;
    owner.limited_info = undefined;
    item thread limitedpickup( limited_info );
}

limitedpickup( limited_info )
{
    self endon( "death" );

    self waittill( "trigger", player, item );

    if ( !isdefined( item ) )
        return;

    player.limited_info = limited_info;
}
