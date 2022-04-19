// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_satchel_charge;
#include maps\mp\_proximity_grenade;
#include maps\mp\_bouncingbetty;
#include maps\mp\_trophy_system;
#include maps\mp\_sensor_grenade;
#include maps\mp\_ballistic_knife;
#include maps\mp\killstreaks\_rcbomb;
#include maps\mp\killstreaks\_qrdrone;
#include maps\mp\killstreaks\_emp;
#include maps\mp\_challenges;
#include maps\mp\_scoreevents;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\_scrambler;
#include maps\mp\gametypes\_globallogic_player;
#include maps\mp\gametypes\_damagefeedback;
#include maps\mp\_entityheadicons;
#include maps\mp\gametypes\_globallogic_audio;
#include maps\mp\_vehicles;
#include maps\mp\gametypes\_dev;

init()
{
/#
    debug = weapons_get_dvar_int( "scr_weaponobject_debug", "0" );
#/
    coneangle = weapons_get_dvar_int( "scr_weaponobject_coneangle", "70" );
    mindist = weapons_get_dvar_int( "scr_weaponobject_mindist", "20" );
    graceperiod = weapons_get_dvar( "scr_weaponobject_graceperiod", "0.6" );
    radius = weapons_get_dvar_int( "scr_weaponobject_radius", "192" );
    level thread onplayerconnect();
    level.watcherweapons = [];
    level.watcherweapons = getwatcherweapons();
    level.watcherweaponnames = [];
    level.watcherweaponnames = getwatchernames( level.watcherweapons );
    level.retrievableweapons = [];
    level.retrievableweapons = getretrievableweapons();
    level.retrievableweaponnames = [];
    level.retrievableweaponnames = getwatchernames( level.retrievableweapons );
    level.weaponobjects_headicon_offset = [];
    level.weaponobjects_headicon_offset["default"] = vectorscale( ( 0, 0, 1 ), 20.0 );
    level.weaponobjectexplodethisframe = 0;

    if ( getdvar( "scr_deleteexplosivesonspawn" ) == "" )
        setdvar( "scr_deleteexplosivesonspawn", 1 );

    level.deleteexplosivesonspawn = getdvarint( "scr_deleteexplosivesonspawn" );

    if ( sessionmodeiszombiesgame() )
        return;

    precachestring( &"MP_DEFUSING_EXPLOSIVE" );
    level.claymorefxid = loadfx( "weapon/claymore/fx_claymore_laser" );
    level._equipment_spark_fx = loadfx( "weapon/grenade/fx_spark_disabled_weapon" );
    level._equipment_emp_destroy_fx = loadfx( "weapon/emp/fx_emp_explosion_equip" );
    level._equipment_explode_fx = loadfx( "explosions/fx_exp_equipment" );
    level._equipment_explode_fx_lg = loadfx( "explosions/fx_exp_equipment_lg" );
    level._effect["powerLight"] = loadfx( "weapon/crossbow/fx_trail_crossbow_blink_red_os" );
    setupretrievablehintstrings();
    level.weaponobjects_headicon_offset["acoustic_sensor_mp"] = vectorscale( ( 0, 0, 1 ), 25.0 );
    level.weaponobjects_headicon_offset["sensor_grenade_mp"] = vectorscale( ( 0, 0, 1 ), 25.0 );
    level.weaponobjects_headicon_offset["camera_spike_mp"] = vectorscale( ( 0, 0, 1 ), 35.0 );
    level.weaponobjects_headicon_offset["claymore_mp"] = vectorscale( ( 0, 0, 1 ), 20.0 );
    level.weaponobjects_headicon_offset["bouncingbetty_mp"] = vectorscale( ( 0, 0, 1 ), 20.0 );
    level.weaponobjects_headicon_offset["satchel_charge_mp"] = vectorscale( ( 0, 0, 1 ), 10.0 );
    level.weaponobjects_headicon_offset["scrambler_mp"] = vectorscale( ( 0, 0, 1 ), 20.0 );
    level.weaponobjects_headicon_offset["trophy_system_mp"] = vectorscale( ( 0, 0, 1 ), 35.0 );
    level.weaponobjects_hacker_trigger_width = 32;
    level.weaponobjects_hacker_trigger_height = 32;
}

getwatchernames( weapons )
{
    names = [];

    foreach ( index, weapon in weapons )
        names[index] = getsubstr( weapon, 0, weapon.size - 3 );

    return names;
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

setupretrievablehintstrings()
{
    createretrievablehint( "hatchet", &"MP_HATCHET_PICKUP" );
    createretrievablehint( "claymore", &"MP_CLAYMORE_PICKUP" );
    createretrievablehint( "bouncingbetty", &"MP_BOUNCINGBETTY_PICKUP" );
    createretrievablehint( "trophy_system", &"MP_TROPHY_SYSTEM_PICKUP" );
    createretrievablehint( "acoustic_sensor", &"MP_ACOUSTIC_SENSOR_PICKUP" );
    createretrievablehint( "camera_spike", &"MP_CAMERA_SPIKE_PICKUP" );
    createretrievablehint( "satchel_charge", &"MP_SATCHEL_CHARGE_PICKUP" );
    createretrievablehint( "scrambler", &"MP_SCRAMBLER_PICKUP" );
    createretrievablehint( "proximity_grenade", &"MP_SHOCK_CHARGE_PICKUP" );
    createdestroyhint( "trophy_system", &"MP_TROPHY_SYSTEM_DESTROY" );
    createdestroyhint( "sensor_grenade", &"MP_SENSOR_GRENADE_DESTROY" );
    createhackerhint( "claymore_mp", &"MP_CLAYMORE_HACKING" );
    createhackerhint( "bouncingbetty_mp", &"MP_BOUNCINGBETTY_HACKING" );
    createhackerhint( "trophy_system_mp", &"MP_TROPHY_SYSTEM_HACKING" );
    createhackerhint( "acoustic_sensor_mp", &"MP_ACOUSTIC_SENSOR_HACKING" );
    createhackerhint( "camera_spike_mp", &"MP_CAMERA_SPIKE_HACKING" );
    createhackerhint( "satchel_charge_mp", &"MP_SATCHEL_CHARGE_HACKING" );
    createhackerhint( "scrambler_mp", &"MP_SCRAMBLER_HACKING" );
}

onplayerconnect()
{
    if ( isdefined( level._weaponobjects_on_player_connect_override ) )
    {
        level thread [[ level._weaponobjects_on_player_connect_override ]]();
        return;
    }

    for (;;)
    {
        level waittill( "connecting", player );

        player.usedweapons = 0;
        player.hits = 0;
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        pixbeginevent( "onPlayerSpawned" );

        if ( !isdefined( self.watchersinitialized ) )
        {
            self createbasewatchers();
            self maps\mp\_satchel_charge::createsatchelwatcher();
            self maps\mp\_proximity_grenade::createproximitygrenadewatcher();
            self maps\mp\_bouncingbetty::createbouncingbettywatcher();
            self maps\mp\_trophy_system::createtrophysystemwatcher();
            self maps\mp\_sensor_grenade::createsensorgrenadewatcher();
            self createclaymorewatcher();
            self creatercbombwatcher();
            self createqrdronewatcher();
            self createplayerhelicopterwatcher();
            self createballisticknifewatcher();
            self createhatchetwatcher();
            self createtactinsertwatcher();
            self setupretrievablewatcher();
            self thread watchweaponobjectusage();
            self.watchersinitialized = 1;
        }

        self resetwatchers();
        pixendevent();
    }
}

resetwatchers()
{
    if ( !isdefined( self.weaponobjectwatcherarray ) )
        return undefined;

    team = self.team;

    foreach ( watcher in self.weaponobjectwatcherarray )
        resetweaponobjectwatcher( watcher, team );
}

createbasewatchers()
{
    foreach ( index, weapon in level.watcherweapons )
        self createweaponobjectwatcher( level.watcherweaponnames[index], weapon, self.team );

    foreach ( index, weapon in level.retrievableweapons )
        self createweaponobjectwatcher( level.retrievableweaponnames[index], weapon, self.team );
}

setupretrievablewatcher()
{
    for ( i = 0; i < level.retrievableweapons.size; i++ )
    {
        watcher = getweaponobjectwatcherbyweapon( level.retrievableweapons[i] );

        if ( !isdefined( watcher.onspawnretrievetriggers ) )
            watcher.onspawnretrievetriggers = ::onspawnretrievableweaponobject;

        if ( !isdefined( watcher.ondestroyed ) )
            watcher.ondestroyed = ::ondestroyed;

        if ( !isdefined( watcher.pickup ) )
            watcher.pickup = ::pickup;
    }
}

createballisticknifewatcher()
{
    watcher = self createuseweaponobjectwatcher( "knife_ballistic", "knife_ballistic_mp", self.team );
    watcher.onspawn = maps\mp\_ballistic_knife::onspawn;
    watcher.detonate = ::deleteent;
    watcher.onspawnretrievetriggers = maps\mp\_ballistic_knife::onspawnretrievetrigger;
    watcher.storedifferentobject = 1;
}

createhatchetwatcher()
{
    watcher = self createuseweaponobjectwatcher( "hatchet", "hatchet_mp", self.team );
    watcher.detonate = ::deleteent;
    watcher.onspawn = ::voidonspawn;
    watcher.ondamage = ::voidondamage;
    watcher.onspawnretrievetriggers = ::onspawnhatchettrigger;
}

createtactinsertwatcher()
{
    watcher = self createuseweaponobjectwatcher( "tactical_insertion", "tactical_insertion_mp", self.team );
    watcher.playdestroyeddialog = 0;
}

creatercbombwatcher()
{
    watcher = self createuseweaponobjectwatcher( "rcbomb", "rcbomb_mp", self.team );
    watcher.altdetonate = 0;
    watcher.headicon = 0;
    watcher.ismovable = 1;
    watcher.ownergetsassist = 1;
    watcher.playdestroyeddialog = 0;
    watcher.deleteonkillbrush = 0;
    watcher.detonate = maps\mp\killstreaks\_rcbomb::blowup;
    watcher.stuntime = 1;
}

createqrdronewatcher()
{
    watcher = self createuseweaponobjectwatcher( "qrdrone", "qrdrone_turret_mp", self.team );
    watcher.altdetonate = 0;
    watcher.headicon = 0;
    watcher.ismovable = 1;
    watcher.ownergetsassist = 1;
    watcher.playdestroyeddialog = 0;
    watcher.deleteonkillbrush = 0;
    watcher.detonate = maps\mp\killstreaks\_qrdrone::qrdrone_blowup;
    watcher.ondamage = maps\mp\killstreaks\_qrdrone::qrdrone_damagewatcher;
    watcher.stuntime = 5;
}

createplayerhelicopterwatcher()
{
    watcher = self createuseweaponobjectwatcher( "helicopter_player", "helicopter_player_mp", self.team );
    watcher.altdetonate = 1;
    watcher.headicon = 0;
}

createclaymorewatcher()
{
    watcher = self createproximityweaponobjectwatcher( "claymore", "claymore_mp", self.team );
    watcher.watchforfire = 1;
    watcher.detonate = ::claymoredetonate;
    watcher.activatesound = "wpn_claymore_alert";
    watcher.hackable = 1;
    watcher.hackertoolradius = level.equipmenthackertoolradius;
    watcher.hackertooltimems = level.equipmenthackertooltimems;
    watcher.reconmodel = "t6_wpn_claymore_world_detect";
    watcher.ownergetsassist = 1;
    detectionconeangle = weapons_get_dvar_int( "scr_weaponobject_coneangle" );
    watcher.detectiondot = cos( detectionconeangle );
    watcher.detectionmindist = weapons_get_dvar_int( "scr_weaponobject_mindist" );
    watcher.detectiongraceperiod = weapons_get_dvar( "scr_weaponobject_graceperiod" );
    watcher.detonateradius = weapons_get_dvar_int( "scr_weaponobject_radius" );
    watcher.stun = ::weaponstun;
    watcher.stuntime = 1;
}

waittillnotmoving_and_notstunned()
{
    for ( prevorigin = self.origin; 1; prevorigin = self.origin )
    {
        wait 0.15;

        if ( self.origin == prevorigin && !self isstunned() )
            break;
    }
}

voidonspawn( unused0, unused1 )
{

}

voidondamage( unused0 )
{

}

deleteent( attacker, emp )
{
    self delete();
}

clearfxondeath( fx )
{
    fx endon( "death" );
    self waittill_any( "death", "hacked" );
    fx delete();
}

deleteweaponobjectarray()
{
    if ( isdefined( self.objectarray ) )
    {
        for ( i = 0; i < self.objectarray.size; i++ )
        {
            if ( isdefined( self.objectarray[i] ) )
            {
                if ( isdefined( self.objectarray[i].minemover ) )
                {
                    if ( isdefined( self.objectarray[i].minemover.killcament ) )
                        self.objectarray[i].minemover.killcament delete();

                    self.objectarray[i].minemover delete();
                }

                self.objectarray[i] delete();
            }
        }
    }

    self.objectarray = [];
}

claymoredetonate( attacker, weaponname )
{
    from_emp = maps\mp\killstreaks\_emp::isempkillstreakweapon( weaponname );

    if ( !isdefined( from_emp ) || !from_emp )
    {
        if ( isdefined( attacker ) )
        {
            if ( self.owner isenemyplayer( attacker ) )
            {
                attacker maps\mp\_challenges::destroyedexplosive( weaponname );
                maps\mp\_scoreevents::processscoreevent( "destroyed_claymore", attacker, self.owner, weaponname );
            }
        }
    }

    maps\mp\gametypes\_weaponobjects::weapondetonate( attacker, weaponname );
}

weapondetonate( attacker, weaponname )
{
    from_emp = maps\mp\killstreaks\_emp::isempweapon( weaponname );

    if ( from_emp )
    {
        self delete();
        return;
    }

    if ( isdefined( attacker ) )
    {
        if ( isdefined( self.owner ) && attacker != self.owner )
            self.playdialog = 1;

        if ( isplayer( attacker ) )
            self detonate( attacker );
        else
            self detonate();
    }
    else if ( isdefined( self.owner ) && isplayer( self.owner ) )
    {
        self.playdialog = 0;
        self detonate( self.owner );
    }
    else
        self detonate();
}

waitanddetonate( object, delay, attacker, weaponname )
{
    object endon( "death" );
    object endon( "hacked" );
    from_emp = maps\mp\killstreaks\_emp::isempweapon( weaponname );

    if ( from_emp && !( isdefined( object.name ) && object.name == "qrdrone_turret_mp" ) )
    {
        object setclientflag( 15 );
        object setclientflag( 9 );
        object.stun_fx = 1;
        playfx( level._equipment_emp_destroy_fx, object.origin + vectorscale( ( 0, 0, 1 ), 5.0 ), ( 0, randomfloat( 360 ), 0 ) );
        delay = 1.1;
    }

    if ( delay )
        wait( delay );

    if ( isdefined( object.detonated ) && object.detonated == 1 )
        return;

    if ( !isdefined( self.detonate ) )
        return;

    if ( isdefined( attacker ) && isplayer( attacker ) && isdefined( attacker.pers["team"] ) && isdefined( object.owner ) && isdefined( object.owner.pers["team"] ) )
    {
        if ( level.teambased )
        {
            if ( attacker.pers["team"] != object.owner.pers["team"] )
                attacker notify( "destroyed_explosive" );
        }
        else if ( attacker != object.owner )
            attacker notify( "destroyed_explosive" );
    }

    object.detonated = 1;
    object [[ self.detonate ]]( attacker, weaponname );
}

detonateweaponobjectarray( forcedetonation, weapon )
{
    undetonated = [];

    if ( isdefined( self.objectarray ) )
    {
        for ( i = 0; i < self.objectarray.size; i++ )
        {
            if ( isdefined( self.objectarray[i] ) )
            {
                if ( self.objectarray[i] isstunned() && forcedetonation == 0 )
                {
                    undetonated[undetonated.size] = self.objectarray[i];
                    continue;
                }

                if ( isdefined( weapon ) )
                {
                    if ( weapon ishacked() && weapon.name != self.objectarray[i].name )
                    {
                        undetonated[undetonated.size] = self.objectarray[i];
                        continue;
                    }
                    else if ( self.objectarray[i] ishacked() && weapon.name != self.objectarray[i].name )
                    {
                        undetonated[undetonated.size] = self.objectarray[i];
                        continue;
                    }
                }

                self thread waitanddetonate( self.objectarray[i], 0.1, undefined, weapon );
            }
        }
    }

    self.objectarray = undetonated;
}

addweaponobjecttowatcher( watchername, weapon )
{
    watcher = getweaponobjectwatcher( watchername );
/#
    assert( isdefined( watcher ), "Weapon object watcher " + watchername + " does not exist" );
#/
    self addweaponobject( watcher, weapon );
}

addweaponobject( watcher, weapon )
{
    if ( !isdefined( watcher.storedifferentobject ) )
        watcher.objectarray[watcher.objectarray.size] = weapon;

    weapon.owner = self;
    weapon.detonated = 0;
    weapon.name = watcher.weapon;

    if ( isdefined( watcher.ondamage ) )
        weapon thread [[ watcher.ondamage ]]( watcher );
    else
        weapon thread weaponobjectdamage( watcher );

    weapon.ownergetsassist = watcher.ownergetsassist;

    if ( isdefined( watcher.onspawn ) )
        weapon thread [[ watcher.onspawn ]]( watcher, self );

    if ( isdefined( watcher.onspawnfx ) )
        weapon thread [[ watcher.onspawnfx ]]();

    if ( isdefined( watcher.reconmodel ) )
        weapon thread attachreconmodel( watcher.reconmodel, self );

    if ( isdefined( watcher.onspawnretrievetriggers ) )
        weapon thread [[ watcher.onspawnretrievetriggers ]]( watcher, self );

    if ( watcher.hackable )
        weapon thread hackerinit( watcher );

    if ( isdefined( watcher.stun ) )
        weapon thread watchscramble( watcher );

    if ( watcher.playdestroyeddialog )
    {
        weapon thread playdialogondeath( self );
        weapon thread watchobjectdamage( self );
    }

    if ( watcher.deleteonkillbrush )
    {
        if ( isdefined( level.deleteonkillbrushoverride ) )
            weapon thread [[ level.deleteonkillbrushoverride ]]( self, watcher );
        else
            weapon thread deleteonkillbrush( self );
    }
}

watchscramble( watcher )
{
    self endon( "death" );
    self endon( "hacked" );
    self waittillnotmoving();

    if ( self maps\mp\_scrambler::checkscramblerstun() )
        self thread stunstart( watcher );
    else
        self stunstop();

    for (;;)
    {
        level waittill_any( "scrambler_spawn", "scrambler_death", "hacked" );

        if ( isdefined( self.owner ) && self.owner isempjammed() )
            continue;

        if ( self maps\mp\_scrambler::checkscramblerstun() )
        {
            self thread stunstart( watcher );
            continue;
        }

        self stunstop();
    }
}

deleteweaponobjecthelper( weapon_ent )
{
    if ( !isdefined( weapon_ent.name ) )
        return;

    watcher = self getweaponobjectwatcherbyweapon( weapon_ent.name );

    if ( !isdefined( watcher ) )
        return;

    watcher.objectarray = deleteweaponobject( watcher, weapon_ent );
}

deleteweaponobject( watcher, weapon_ent )
{
    temp_objectarray = watcher.objectarray;
    watcher.objectarray = [];
    j = 0;

    for ( i = 0; i < temp_objectarray.size; i++ )
    {
        if ( !isdefined( temp_objectarray[i] ) || temp_objectarray[i] == weapon_ent )
            continue;

        watcher.objectarray[j] = temp_objectarray[i];
        j++;
    }

    return watcher.objectarray;
}

weaponobjectdamage( watcher )
{
    self endon( "death" );
    self endon( "hacked" );
    self setcandamage( 1 );
    self.maxhealth = 100000;
    self.health = self.maxhealth;
    attacker = undefined;

    while ( true )
    {
        self waittill( "damage", damage, attacker, direction_vec, point, type, modelname, tagname, partname, weaponname, idflags );

        if ( isdefined( weaponname ) )
        {
            switch ( weaponname )
            {
                case "proximity_grenade_mp":
                case "flash_grenade_mp":
                case "concussion_grenade_mp":
                    if ( watcher.stuntime > 0 )
                        self thread stunstart( watcher, watcher.stuntime );

                    if ( level.teambased && self.owner.team != attacker.team )
                    {
                        if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
                            attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();
                    }
                    else if ( !level.teambased && self.owner != attacker )
                    {
                        if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
                            attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();
                    }

                    continue;
                case "willy_pete_mp":
                    continue;
                case "emp_grenade_mp":
                    if ( level.teambased && self.owner.team != attacker.team )
                    {
                        if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
                            attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();
                    }
                    else if ( !level.teambased && self.owner != attacker )
                    {
                        if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
                            attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();
                    }

                    break;
                default:
                    break;
            }
        }

        if ( !isplayer( attacker ) && isdefined( attacker.owner ) )
            attacker = attacker.owner;

        if ( level.teambased && isplayer( attacker ) )
        {
            if ( !level.hardcoremode && self.owner.team == attacker.pers["team"] && self.owner != attacker )
                continue;
        }

        if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
            attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();

        if ( !isvehicle( self ) && !friendlyfirecheck( self.owner, attacker ) )
            continue;

        break;
    }

    if ( level.weaponobjectexplodethisframe )
        wait( 0.1 + randomfloat( 0.4 ) );
    else
        wait 0.05;

    if ( !isdefined( self ) )
        return;

    level.weaponobjectexplodethisframe = 1;
    thread resetweaponobjectexplodethisframe();
    self maps\mp\_entityheadicons::setentityheadicon( "none" );

    if ( isdefined( type ) && ( issubstr( type, "MOD_GRENADE_SPLASH" ) || issubstr( type, "MOD_GRENADE" ) || issubstr( type, "MOD_EXPLOSIVE" ) ) )
        self.waschained = 1;

    if ( isdefined( idflags ) && idflags & level.idflags_penetration )
        self.wasdamagedfrombulletpenetration = 1;

    self.wasdamaged = 1;
    watcher thread waitanddetonate( self, 0.0, attacker, weaponname );
}

playdialogondeath( owner )
{
    owner endon( "death" );
    owner endon( "disconnect" );
    self endon( "hacked" );

    self waittill( "death" );

    if ( isdefined( self.playdialog ) && self.playdialog )
        owner maps\mp\gametypes\_globallogic_audio::leaderdialogonplayer( "equipment_destroyed", "item_destroyed" );
}

watchobjectdamage( owner )
{
    owner endon( "death" );
    owner endon( "disconnect" );
    self endon( "hacked" );
    self endon( "death" );

    while ( true )
    {
        self waittill( "damage", damage, attacker );

        if ( isdefined( attacker ) && isplayer( attacker ) && attacker != owner )
            self.playdialog = 1;
        else
            self.playdialog = 0;
    }
}

stunstart( watcher, time )
{
    self endon( "death" );

    if ( self isstunned() )
        return;

    if ( isdefined( self.camerahead ) )
        self.camerahead setclientflag( 9 );

    self setclientflag( 9 );

    if ( isdefined( watcher.stun ) )
        self thread [[ watcher.stun ]]();

    if ( watcher.name == "rcbomb" )
        self.owner freezecontrolswrapper( 1 );

    if ( isdefined( time ) )
        wait( time );
    else
        return;

    if ( watcher.name == "rcbomb" )
        self.owner freezecontrolswrapper( 0 );

    self stunstop();
}

stunstop()
{
    self notify( "not_stunned" );

    if ( isdefined( self.camerahead ) )
        self.camerahead clearclientflag( 9 );

    self clearclientflag( 9 );
}

weaponstun()
{
    self endon( "death" );
    self endon( "not_stunned" );
    origin = self gettagorigin( "tag_fx" );

    if ( !isdefined( origin ) )
        origin = self.origin + vectorscale( ( 0, 0, 1 ), 10.0 );

    self.stun_fx = spawn( "script_model", origin );
    self.stun_fx setmodel( "tag_origin" );
    self thread stunfxthink( self.stun_fx );
    wait 0.1;
    playfxontag( level._equipment_spark_fx, self.stun_fx, "tag_origin" );
    self.stun_fx playsound( "dst_disable_spark" );
}

stunfxthink( fx )
{
    fx endon( "death" );
    self waittill_any( "death", "not_stunned" );
    fx delete();
}

isstunned()
{
    return isdefined( self.stun_fx );
}

resetweaponobjectexplodethisframe()
{
    wait 0.05;
    level.weaponobjectexplodethisframe = 0;
}

getweaponobjectwatcher( name )
{
    if ( !isdefined( self.weaponobjectwatcherarray ) )
        return undefined;

    for ( watcher = 0; watcher < self.weaponobjectwatcherarray.size; watcher++ )
    {
        if ( self.weaponobjectwatcherarray[watcher].name == name )
            return self.weaponobjectwatcherarray[watcher];
    }

    return undefined;
}

getweaponobjectwatcherbyweapon( weapon )
{
    if ( !isdefined( self.weaponobjectwatcherarray ) )
        return undefined;

    for ( watcher = 0; watcher < self.weaponobjectwatcherarray.size; watcher++ )
    {
        if ( isdefined( self.weaponobjectwatcherarray[watcher].weapon ) && self.weaponobjectwatcherarray[watcher].weapon == weapon )
            return self.weaponobjectwatcherarray[watcher];

        if ( isdefined( self.weaponobjectwatcherarray[watcher].weapon ) && isdefined( self.weaponobjectwatcherarray[watcher].altweapon ) && self.weaponobjectwatcherarray[watcher].altweapon == weapon )
            return self.weaponobjectwatcherarray[watcher];
    }

    return undefined;
}

resetweaponobjectwatcher( watcher, ownerteam )
{
    if ( level.deleteexplosivesonspawn == 1 )
    {
        self notify( "weapon_object_destroyed" );
        watcher deleteweaponobjectarray();
    }

    watcher.ownerteam = ownerteam;
}

createweaponobjectwatcher( name, weapon, ownerteam )
{
    if ( !isdefined( self.weaponobjectwatcherarray ) )
        self.weaponobjectwatcherarray = [];

    weaponobjectwatcher = getweaponobjectwatcher( name );

    if ( !isdefined( weaponobjectwatcher ) )
    {
        weaponobjectwatcher = spawnstruct();
        self.weaponobjectwatcherarray[self.weaponobjectwatcherarray.size] = weaponobjectwatcher;
        weaponobjectwatcher.name = name;
        weaponobjectwatcher.type = "use";
        weaponobjectwatcher.weapon = weapon;
        weaponobjectwatcher.weaponidx = getweaponindexfromname( weapon );
        weaponobjectwatcher.watchforfire = 0;
        weaponobjectwatcher.hackable = 0;
        weaponobjectwatcher.altdetonate = 0;
        weaponobjectwatcher.detectable = 1;
        weaponobjectwatcher.headicon = 1;
        weaponobjectwatcher.stuntime = 0;
        weaponobjectwatcher.activatesound = undefined;
        weaponobjectwatcher.ignoredirection = undefined;
        weaponobjectwatcher.immediatedetonation = undefined;
        weaponobjectwatcher.deploysound = getweaponfiresound( weaponobjectwatcher.weaponidx );
        weaponobjectwatcher.deploysoundplayer = getweaponfiresoundplayer( weaponobjectwatcher.weaponidx );
        weaponobjectwatcher.pickupsound = getweaponpickupsound( weaponobjectwatcher.weaponidx );
        weaponobjectwatcher.pickupsoundplayer = getweaponpickupsoundplayer( weaponobjectwatcher.weaponidx );
        weaponobjectwatcher.altweapon = undefined;
        weaponobjectwatcher.ownergetsassist = 0;
        weaponobjectwatcher.playdestroyeddialog = 1;
        weaponobjectwatcher.deleteonkillbrush = 1;
        weaponobjectwatcher.deleteondifferentobjectspawn = 1;
        weaponobjectwatcher.enemydestroy = 0;
        weaponobjectwatcher.onspawn = undefined;
        weaponobjectwatcher.onspawnfx = undefined;
        weaponobjectwatcher.onspawnretrievetriggers = undefined;
        weaponobjectwatcher.ondetonated = undefined;
        weaponobjectwatcher.detonate = undefined;
        weaponobjectwatcher.stun = undefined;
        weaponobjectwatcher.ondestroyed = undefined;

        if ( !isdefined( weaponobjectwatcher.objectarray ) )
            weaponobjectwatcher.objectarray = [];
    }

    resetweaponobjectwatcher( weaponobjectwatcher, ownerteam );
    return weaponobjectwatcher;
}

createuseweaponobjectwatcher( name, weapon, ownerteam )
{
    weaponobjectwatcher = createweaponobjectwatcher( name, weapon, ownerteam );
    weaponobjectwatcher.type = "use";
    weaponobjectwatcher.onspawn = ::onspawnuseweaponobject;
    return weaponobjectwatcher;
}

createproximityweaponobjectwatcher( name, weapon, ownerteam )
{
    weaponobjectwatcher = createweaponobjectwatcher( name, weapon, ownerteam );
    weaponobjectwatcher.type = "proximity";
    weaponobjectwatcher.onspawn = ::onspawnproximityweaponobject;
    detectionconeangle = weapons_get_dvar_int( "scr_weaponobject_coneangle" );
    weaponobjectwatcher.detectiondot = cos( detectionconeangle );
    weaponobjectwatcher.detectionmindist = weapons_get_dvar_int( "scr_weaponobject_mindist" );
    weaponobjectwatcher.detectiongraceperiod = weapons_get_dvar( "scr_weaponobject_graceperiod" );
    weaponobjectwatcher.detonateradius = weapons_get_dvar_int( "scr_weaponobject_radius" );
    return weaponobjectwatcher;
}

commononspawnuseweaponobject( watcher, owner )
{
    if ( watcher.detectable )
    {
        if ( isdefined( watcher.ismovable ) && watcher.ismovable )
            self thread weaponobjectdetectionmovable( owner.pers["team"] );
        else
            self thread weaponobjectdetectiontrigger_wait( owner.pers["team"] );

        if ( watcher.headicon && level.teambased )
        {
            self waittillnotmoving();
            offset = level.weaponobjects_headicon_offset["default"];

            if ( isdefined( level.weaponobjects_headicon_offset[self.name] ) )
                offset = level.weaponobjects_headicon_offset[self.name];

            if ( isdefined( self ) )
                self maps\mp\_entityheadicons::setentityheadicon( owner.pers["team"], owner, offset );
        }
    }
}

onspawnuseweaponobject( watcher, owner )
{
    self commononspawnuseweaponobject( watcher, owner );
}

onspawnproximityweaponobject( watcher, owner )
{
    self thread commononspawnuseweaponobject( watcher, owner );
    self thread proximityweaponobjectdetonation( watcher );
/#
    if ( getdvarint( "scr_weaponobject_debug" ) )
        self thread proximityweaponobjectdebug( watcher );
#/
}

watchweaponobjectusage()
{
    self endon( "disconnect" );

    if ( !isdefined( self.weaponobjectwatcherarray ) )
        self.weaponobjectwatcherarray = [];

    self thread watchweaponobjectspawn();
    self thread watchweaponprojectileobjectspawn();
    self thread watchweaponobjectdetonation();
    self thread watchweaponobjectaltdetonation();
    self thread watchweaponobjectaltdetonate();
    self thread deleteweaponobjectson();
}

watchweaponobjectspawn()
{
    self notify( "watchWeaponObjectSpawn" );
    self endon( "watchWeaponObjectSpawn" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "grenade_fire", weapon, weapname );

        switch ( weapname )
        {
            case "tactical_insertion_mp":
            case "scrambler_mp":
            case "camera_spike_mp":
            case "bouncingbetty_mp":
            case "acoustic_sensor_mp":
                break;
            case "trophy_system_mp":
            case "sensor_grenade_mp":
            case "satchel_charge_mp":
            case "proximity_grenade_mp":
            case "claymore_mp":
            case "bouncingbetty_mp":
                for ( i = 0; i < self.weaponobjectwatcherarray.size; i++ )
                {
                    if ( self.weaponobjectwatcherarray[i].weapon != weapname )
                        continue;

                    objectarray_size = self.weaponobjectwatcherarray[i].objectarray.size;

                    for ( j = 0; j < objectarray_size; j++ )
                    {
                        if ( !isdefined( self.weaponobjectwatcherarray[i].objectarray[j] ) )
                            self.weaponobjectwatcherarray[i].objectarray = deleteweaponobject( self.weaponobjectwatcherarray[i], weapon );
                    }

                    numallowed = 2;

                    if ( weapname == "proximity_grenade_mp" )
                        numallowed = weapons_get_dvar_int( "scr_proximityGrenadeMaxInstances" );

                    if ( isdefined( self.weaponobjectwatcherarray[i].detonate ) && self.weaponobjectwatcherarray[i].objectarray.size > numallowed - 1 )
                        self.weaponobjectwatcherarray[i] thread waitanddetonate( self.weaponobjectwatcherarray[i].objectarray[0], 0.1, undefined, weapname );
                }

                break;
            default:
                break;
        }

        if ( !self ishacked() )
        {
            if ( weapname == "claymore_mp" || weapname == "satchel_charge_mp" || weapname == "bouncingbetty_mp" )
                self addweaponstat( weapname, "used", 1 );
        }

        watcher = getweaponobjectwatcherbyweapon( weapname );

        if ( isdefined( watcher ) )
            self addweaponobject( watcher, weapon );
    }
}

anyobjectsinworld( weapon )
{
    objectsinworld = 0;

    for ( i = 0; i < self.weaponobjectwatcherarray.size; i++ )
    {
        if ( self.weaponobjectwatcherarray[i].weapon != weapon )
            continue;

        if ( isdefined( self.weaponobjectwatcherarray[i].detonate ) && self.weaponobjectwatcherarray[i].objectarray.size > 0 )
        {
            objectsinworld = 1;
            break;
        }
    }

    return objectsinworld;
}

watchweaponprojectileobjectspawn()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "missile_fire", weapon, weapname );

        watcher = getweaponobjectwatcherbyweapon( weapname );

        if ( isdefined( watcher ) )
        {
            self addweaponobject( watcher, weapon );
            objectarray_size = watcher.objectarray.size;

            for ( j = 0; j < objectarray_size; j++ )
            {
                if ( !isdefined( watcher.objectarray[j] ) )
                    watcher.objectarray = deleteweaponobject( watcher, weapon );
            }

            if ( isdefined( watcher.detonate ) && watcher.objectarray.size > 3 )
                watcher thread waitanddetonate( watcher.objectarray[0], 0.1 );
        }
    }
}

proximityweaponobjectdebug( watcher )
{
/#
    self waittillnotmoving();
    self thread showcone( acos( watcher.detectiondot ), watcher.detonateradius, ( 1, 0.85, 0 ) );
    self thread showcone( 60, 256, ( 1, 0, 0 ) );
#/
}

vectorcross( v1, v2 )
{
/#
    return ( v1[1] * v2[2] - v1[2] * v2[1], v1[2] * v2[0] - v1[0] * v2[2], v1[0] * v2[1] - v1[1] * v2[0] );
#/
}

showcone( angle, range, color )
{
/#
    self endon( "death" );
    start = self.origin;
    forward = anglestoforward( self.angles );
    right = vectorcross( forward, ( 0, 0, 1 ) );
    up = vectorcross( forward, right );
    fullforward = forward * range * cos( angle );
    sideamnt = range * sin( angle );

    while ( true )
    {
        prevpoint = ( 0, 0, 0 );

        for ( i = 0; i <= 20; i++ )
        {
            coneangle = i / 20.0 * 360;
            point = start + fullforward + sideamnt * ( right * cos( coneangle ) + up * sin( coneangle ) );

            if ( i > 0 )
            {
                line( start, point, color );
                line( prevpoint, point, color );
            }

            prevpoint = point;
        }

        wait 0.05;
    }
#/
}

weaponobjectdetectionmovable( ownerteam )
{
    self endon( "end_detection" );
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "hacked" );

    if ( level.oldschool )
        return;

    if ( !level.teambased )
        return;

    self.detectid = "rcBomb" + gettime() + randomint( 1000000 );

    while ( !level.gameended )
    {
        wait 1;
        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            player = players[i];

            if ( isai( player ) )
                continue;

            if ( isdefined( self.model_name ) && player hasperk( "specialty_detectexplosive" ) )
            {
                switch ( self.model_name )
                {
                    case "t6_wpn_claymore_world_detect":
                    case "t6_wpn_c4_world_detect":
                        break;
                    default:
                        continue;
                }
            }
            else
                continue;

            if ( player.team == ownerteam )
                continue;

            if ( isdefined( player.bombsquadids[self.detectid] ) )
                continue;
        }
    }
}

seticonpos( item, icon, heightincrease )
{
    icon.x = item.origin[0];
    icon.y = item.origin[1];
    icon.z = item.origin[2] + heightincrease;
}

weaponobjectdetectiontrigger_wait( ownerteam )
{
    self endon( "death" );
    self endon( "hacked" );
    waittillnotmoving();

    if ( level.oldschool )
        return;

    self thread weaponobjectdetectiontrigger( ownerteam );
}

weaponobjectdetectiontrigger( ownerteam )
{
    trigger = spawn( "trigger_radius", self.origin - vectorscale( ( 0, 0, 1 ), 128.0 ), 0, 512, 256 );
    trigger.detectid = "trigger" + gettime() + randomint( 1000000 );
    trigger sethintlowpriority( 1 );
    self waittill_any( "death", "hacked" );
    trigger notify( "end_detection" );

    if ( isdefined( trigger.bombsquadicon ) )
        trigger.bombsquadicon destroy();

    trigger delete();
}

hackertriggersetvisibility( owner )
{
    self endon( "death" );
/#
    assert( isplayer( owner ) );
#/
    ownerteam = owner.pers["team"];

    for (;;)
    {
        if ( level.teambased )
        {
            self setvisibletoallexceptteam( ownerteam );
            self setexcludeteamfortrigger( ownerteam );
        }
        else
        {
            self setvisibletoall();
            self setteamfortrigger( "none" );
        }

        if ( isdefined( owner ) )
            self setinvisibletoplayer( owner );

        level waittill_any( "player_spawned", "joined_team" );
    }
}

hackernotmoving()
{
    self endon( "death" );
    self waittillnotmoving();
    self notify( "landed" );
}

hackerinit( watcher )
{
    self thread hackernotmoving();
    event = self waittill_any_return( "death", "landed" );

    if ( event == "death" )
        return;

    triggerorigin = self.origin;

    if ( isdefined( self.name ) && self.name == "satchel_charge_mp" )
        triggerorigin = self gettagorigin( "tag_fx" );

    self.hackertrigger = spawn( "trigger_radius_use", triggerorigin, level.weaponobjects_hacker_trigger_width, level.weaponobjects_hacker_trigger_height );
/#

#/
    self.hackertrigger sethintlowpriority( 1 );
    self.hackertrigger setcursorhint( "HINT_NOICON", self );
    self.hackertrigger setignoreentfortrigger( self );
    self.hackertrigger enablelinkto();
    self.hackertrigger linkto( self );

    if ( isdefined( level.hackerhints[self.name] ) )
        self.hackertrigger sethintstring( level.hackerhints[self.name].hint );
    else
        self.hackertrigger sethintstring( &"MP_GENERIC_HACKING" );

    self.hackertrigger setperkfortrigger( "specialty_disarmexplosive" );
    self.hackertrigger thread hackertriggersetvisibility( self.owner );
    self thread hackerthink( self.hackertrigger, watcher );
}

hackerthink( trigger, watcher )
{
    self endon( "death" );

    for (;;)
    {
        trigger waittill( "trigger", player, instant );

        if ( !isdefined( instant ) && !trigger hackerresult( player, self.owner ) )
            continue;

        self.owner hackerremoveweapon( self );
        self.owner maps\mp\gametypes\_globallogic_audio::leaderdialogonplayer( "hacked_equip", "item_destroyed" );
        self.hacked = 1;
        self setmissileowner( player );
        self setteam( player.pers["team"] );
        self.owner = player;

        if ( isweaponequipment( self.name ) || self.name == "proximity_grenade_mp" )
        {
            maps\mp\_scoreevents::processscoreevent( "hacked", player );
            player addweaponstat( "pda_hack_mp", "CombatRecordStat", 1 );
            player maps\mp\_challenges::hackedordestroyedequipment();
        }

        if ( self.name == "satchel_charge_mp" && isdefined( player.lowermessage ) )
        {
            player.lowermessage settext( &"PLATFORM_SATCHEL_CHARGE_DOUBLE_TAP" );
            player.lowermessage.alpha = 1;
            player.lowermessage fadeovertime( 2.0 );
            player.lowermessage.alpha = 0;
        }

        self notify( "hacked", player );
        level notify( "hacked", self, player );

        if ( self.name == "camera_spike_mp" && isdefined( self.camerahead ) )
            self.camerahead notify( "hacked", player );
/#

#/
        if ( isdefined( watcher.stun ) )
        {
            self thread stunstart( watcher, 0.75 );
            wait 0.75;
        }
        else
            wait 0.05;

        if ( isdefined( player ) && player.sessionstate == "playing" )
            player notify( "grenade_fire", self, self.name, 1 );
        else
            watcher thread waitanddetonate( self, 0.0 );

        return;
    }
}

hackerunfreezeplayer( player )
{
    self endon( "hack_done" );

    self waittill( "death" );

    if ( isdefined( player ) )
    {
        player freeze_player_controls( 0 );
        player enableweapons();
    }
}

hackerresult( player, owner )
{
    success = 1;
    time = gettime();
    hacktime = getdvarfloat( "perk_disarmExplosiveTime" );

    if ( !canhack( player, owner, 1 ) )
        return 0;

    self thread hackerunfreezeplayer( player );

    while ( time + hacktime * 1000 > gettime() )
    {
        if ( !canhack( player, owner, 0 ) )
        {
            success = 0;
            break;
        }

        if ( !player usebuttonpressed() )
        {
            success = 0;
            break;
        }

        if ( !isdefined( self ) )
        {
            success = 0;
            break;
        }

        player freeze_player_controls( 1 );
        player disableweapons();

        if ( !isdefined( self.progressbar ) )
        {
            self.progressbar = player createprimaryprogressbar();
            self.progressbar.lastuserate = -1;
            self.progressbar showelem();
            self.progressbar updatebar( 0.01, 1 / hacktime );
            self.progresstext = player createprimaryprogressbartext();
            self.progresstext settext( &"MP_HACKING" );
            self.progresstext showelem();
            player playlocalsound( "evt_hacker_hacking" );
        }

        wait 0.05;
    }

    if ( isdefined( player ) )
    {
        player freeze_player_controls( 0 );
        player enableweapons();
    }

    if ( isdefined( self.progressbar ) )
    {
        self.progressbar destroyelem();
        self.progresstext destroyelem();
    }

    if ( isdefined( self ) )
        self notify( "hack_done" );

    return success;
}

canhack( player, owner, weapon_check )
{
    if ( !isdefined( player ) )
        return false;

    if ( !isplayer( player ) )
        return false;

    if ( !isalive( player ) )
        return false;

    if ( !isdefined( owner ) )
        return false;

    if ( owner == player )
        return false;

    if ( level.teambased && player.team == owner.team )
        return false;

    if ( isdefined( player.isdefusing ) && player.isdefusing )
        return false;

    if ( isdefined( player.isplanting ) && player.isplanting )
        return false;

    if ( isdefined( player.proxbar ) && !player.proxbar.hidden )
        return false;

    if ( isdefined( player.revivingteammate ) && player.revivingteammate == 1 )
        return false;

    if ( !player isonground() )
        return false;

    if ( player isinvehicle() )
        return false;

    if ( player isweaponviewonlylinked() )
        return false;

    if ( !player hasperk( "specialty_disarmexplosive" ) )
        return false;

    if ( player isempjammed() )
        return false;

    if ( isdefined( player.laststand ) && player.laststand )
        return false;

    if ( weapon_check )
    {
        if ( player isthrowinggrenade() )
            return false;

        if ( player isswitchingweapons() )
            return false;

        if ( player ismeleeing() )
            return false;

        weapon = player getcurrentweapon();

        if ( !isdefined( weapon ) )
            return false;

        if ( weapon == "none" )
            return false;

        if ( isweaponequipment( weapon ) && player isfiring() )
            return false;

        if ( isweaponspecificuse( weapon ) )
            return false;
    }

    return true;
}

hackerremoveweapon( weapon )
{
    for ( i = 0; i < self.weaponobjectwatcherarray.size; i++ )
    {
        if ( self.weaponobjectwatcherarray[i].weapon != weapon.name )
            continue;

        objectarray_size = self.weaponobjectwatcherarray[i].objectarray.size;

        for ( j = 0; j < objectarray_size; j++ )
            self.weaponobjectwatcherarray[i].objectarray = deleteweaponobject( self.weaponobjectwatcherarray[i], weapon );

        return;
    }
}

proximityweaponobjectdetonation( watcher )
{
    self endon( "death" );
    self endon( "hacked" );
    self waittillnotmoving();

    if ( isdefined( watcher.activationdelay ) )
        wait( watcher.activationdelay );

    damagearea = spawn( "trigger_radius", self.origin + ( 0, 0, 0 - watcher.detonateradius ), level.aitriggerspawnflags | level.vehicletriggerspawnflags, watcher.detonateradius, watcher.detonateradius * 2 );
    damagearea enablelinkto();
    damagearea linkto( self );
    self thread deleteondeath( damagearea );
    up = anglestoup( self.angles );
    traceorigin = self.origin + up;

    while ( true )
    {
        damagearea waittill( "trigger", ent );

        if ( getdvarint( "scr_weaponobject_debug" ) != 1 )
        {
            if ( isdefined( self.owner ) && ent == self.owner )
                continue;

            if ( isdefined( self.owner ) && isvehicle( ent ) && isdefined( ent.owner ) && self.owner == ent.owner )
                continue;

            if ( !friendlyfirecheck( self.owner, ent, 0 ) )
                continue;
        }

        if ( lengthsquared( ent getvelocity() ) < 10 && !isdefined( watcher.immediatedetonation ) )
            continue;

        if ( !ent shouldaffectweaponobject( self, watcher ) )
            continue;

        if ( self isstunned() )
            continue;

        if ( isplayer( ent ) && !isalive( ent ) )
            continue;

        if ( ent damageconetrace( traceorigin, self ) > 0 )
            break;
    }

    if ( isdefined( watcher.activatesound ) )
        self playsound( watcher.activatesound );

    if ( isdefined( watcher.activatefx ) )
        self setclientflag( 4 );

    ent thread deathdodger( watcher.detectiongraceperiod );
    wait( watcher.detectiongraceperiod );

    if ( isplayer( ent ) && ent hasperk( "specialty_delayexplosive" ) )
        wait( getdvarfloat( "perk_delayExplosiveTime" ) );

    self maps\mp\_entityheadicons::setentityheadicon( "none" );
    self.origin = traceorigin;

    if ( isdefined( self.owner ) && isplayer( self.owner ) )
        self [[ watcher.detonate ]]( self.owner );
    else
        self [[ watcher.detonate ]]();
}

shouldaffectweaponobject( object, watcher )
{
    radius = getweaponexplosionradius( watcher.weapon );
    distancesqr = distancesquared( self.origin, object.origin );

    if ( radius * radius < distancesqr )
        return 0;

    pos = self.origin + vectorscale( ( 0, 0, 1 ), 32.0 );

    if ( isdefined( watcher.ignoredirection ) )
        return 1;

    dirtopos = pos - object.origin;
    objectforward = anglestoforward( object.angles );
    dist = vectordot( dirtopos, objectforward );

    if ( dist < watcher.detectionmindist )
        return 0;

    dirtopos = vectornormalize( dirtopos );
    dot = vectordot( dirtopos, objectforward );
    return dot > watcher.detectiondot;
}

deathdodger( graceperiod )
{
    self endon( "death" );
    self endon( "disconnect" );
    wait( 0.2 + graceperiod );
    self notify( "death_dodger" );
}

deleteondeath( ent )
{
    self waittill_any( "death", "hacked" );
    wait 0.05;

    if ( isdefined( ent ) )
        ent delete();
}

testkillbrushonstationary( killbrusharray, player )
{
    player endon( "disconnect" );
    self endon( "death" );

    self waittill( "stationary" );

    wait 0.1;

    for ( i = 0; i < killbrusharray.size; i++ )
    {
        if ( self istouching( killbrusharray[i] ) )
        {
            if ( self.origin[2] > player.origin[2] )
                break;

            if ( isdefined( self ) )
                self delete();

            return;
        }
    }
}

deleteonkillbrush( player )
{
    player endon( "disconnect" );
    self endon( "death" );
    self endon( "stationary" );
    killbrushes = getentarray( "trigger_hurt", "classname" );
    self thread testkillbrushonstationary( killbrushes, player );

    while ( true )
    {
        for ( i = 0; i < killbrushes.size; i++ )
        {
            if ( self istouching( killbrushes[i] ) )
            {
                if ( self.origin[2] > player.origin[2] )
                    break;

                if ( isdefined( self ) )
                    self delete();

                return;
            }
        }

        wait 0.1;
    }
}

watchweaponobjectaltdetonation()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "alt_detonate" );

        if ( !isalive( self ) )
            continue;

        for ( watcher = 0; watcher < self.weaponobjectwatcherarray.size; watcher++ )
        {
            if ( self.weaponobjectwatcherarray[watcher].altdetonate )
                self.weaponobjectwatcherarray[watcher] detonateweaponobjectarray( 0 );
        }
    }
}

watchweaponobjectaltdetonate()
{
    self endon( "disconnect" );
    self endon( "detonated" );
    level endon( "game_ended" );
    buttontime = 0;

    for (;;)
    {
        self waittill( "doubletap_detonate" );

        if ( !isalive( self ) )
            continue;

        self notify( "alt_detonate" );
        wait 0.05;
    }
}

watchweaponobjectdetonation()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "detonate" );

        if ( self isusingoffhand() )
            weap = self getcurrentoffhand();
        else
            weap = self getcurrentweapon();

        watcher = getweaponobjectwatcherbyweapon( weap );

        if ( isdefined( watcher ) )
            watcher detonateweaponobjectarray( 0 );
    }
}

deleteweaponobjectson()
{
    while ( true )
    {
        msg = self waittill_any_return( "disconnect", "joined_team", "joined_spectators", "death" );

        if ( msg == "death" )
            continue;

        if ( !isdefined( self.weaponobjectwatcherarray ) )
            return;

        watchers = [];

        for ( watcher = 0; watcher < self.weaponobjectwatcherarray.size; watcher++ )
        {
            weaponobjectwatcher = spawnstruct();
            watchers[watchers.size] = weaponobjectwatcher;
            weaponobjectwatcher.objectarray = [];

            if ( isdefined( self.weaponobjectwatcherarray[watcher].objectarray ) )
                weaponobjectwatcher.objectarray = self.weaponobjectwatcherarray[watcher].objectarray;
        }

        wait 0.05;

        for ( watcher = 0; watcher < watchers.size; watcher++ )
            watchers[watcher] deleteweaponobjectarray();

        if ( msg == "disconnect" )
            return;
    }
}

saydamaged( orig, amount )
{
/#
    for ( i = 0; i < 60; i++ )
    {
        print3d( orig, "damaged! " + amount );
        wait 0.05;
    }
#/
}

showheadicon( trigger )
{
    triggerdetectid = trigger.detectid;
    useid = -1;

    for ( index = 0; index < 4; index++ )
    {
        detectid = self.bombsquadicons[index].detectid;

        if ( detectid == triggerdetectid )
            return;

        if ( detectid == "" )
            useid = index;
    }

    if ( useid < 0 )
        return;

    self.bombsquadids[triggerdetectid] = 1;
    self.bombsquadicons[useid].x = trigger.origin[0];
    self.bombsquadicons[useid].y = trigger.origin[1];
    self.bombsquadicons[useid].z = trigger.origin[2] + 24 + 128;
    self.bombsquadicons[useid] fadeovertime( 0.25 );
    self.bombsquadicons[useid].alpha = 1;
    self.bombsquadicons[useid].detectid = trigger.detectid;

    while ( isalive( self ) && isdefined( trigger ) && self istouching( trigger ) )
        wait 0.05;

    if ( !isdefined( self ) )
        return;

    self.bombsquadicons[useid].detectid = "";
    self.bombsquadicons[useid] fadeovertime( 0.25 );
    self.bombsquadicons[useid].alpha = 0;
    self.bombsquadids[triggerdetectid] = undefined;
}

friendlyfirecheck( owner, attacker, forcedfriendlyfirerule )
{
    if ( !isdefined( owner ) )
        return true;

    if ( !level.teambased )
        return true;

    friendlyfirerule = level.friendlyfire;

    if ( isdefined( forcedfriendlyfirerule ) )
        friendlyfirerule = forcedfriendlyfirerule;

    if ( friendlyfirerule != 0 )
        return true;

    if ( attacker == owner )
        return true;

    if ( isplayer( attacker ) )
    {
        if ( !isdefined( attacker.pers["team"] ) )
            return true;

        if ( attacker.pers["team"] != owner.pers["team"] )
            return true;
    }
    else if ( isai( attacker ) )
    {
        if ( attacker.aiteam != owner.pers["team"] )
            return true;
    }
    else if ( isvehicle( attacker ) )
    {
        if ( isdefined( attacker.owner ) && isplayer( attacker.owner ) )
        {
            if ( attacker.owner.pers["team"] != owner.pers["team"] )
                return true;
        }
        else
        {
            occupant_team = attacker maps\mp\_vehicles::vehicle_get_occupant_team();

            if ( occupant_team != owner.pers["team"] )
                return true;
        }
    }

    return false;
}

onspawnhatchettrigger( watcher, player )
{
    self endon( "death" );
    self setowner( player );
    self setteam( player.pers["team"] );
    self.owner = player;
    self.oldangles = self.angles;
    self waittillnotmoving();
    waittillframeend;

    if ( player.pers["team"] == "spectator" )
        return;

    triggerorigin = self.origin;
    triggerparentent = undefined;

    if ( isdefined( self.stucktoplayer ) )
    {
        if ( isalive( self.stucktoplayer ) || !isdefined( self.stucktoplayer.body ) )
        {
            if ( isalive( self.stucktoplayer ) )
            {
                triggerparentent = self;
                self unlink();
                self.angles = self.oldangles;
                self launch( vectorscale( ( 1, 1, 1 ), 5.0 ) );
                self waittillnotmoving();
                waittillframeend;
            }
            else
                triggerparentent = self.stucktoplayer;
        }
        else
            triggerparentent = self.stucktoplayer.body;
    }

    if ( isdefined( triggerparentent ) )
        triggerorigin = triggerparentent.origin + vectorscale( ( 0, 0, 1 ), 10.0 );

    self.hatchetpickuptrigger = spawn( "trigger_radius", triggerorigin, 0, 50, 50 );
    self.hatchetpickuptrigger enablelinkto();
    self.hatchetpickuptrigger linkto( self );

    if ( isdefined( triggerparentent ) )
        self.hatchetpickuptrigger linkto( triggerparentent );

    self thread watchhatchettrigger( self.hatchetpickuptrigger, watcher.pickup, watcher.pickupsoundplayer, watcher.pickupsound );
/#
    thread switch_team( self, watcher.weapon, player );
#/
    self thread watchshutdown( player );
}

watchhatchettrigger( trigger, callback, playersoundonuse, npcsoundonuse )
{
    self endon( "delete" );
    self endon( "hacked" );

    while ( true )
    {
        trigger waittill( "trigger", player );

        if ( !isalive( player ) )
            continue;

        if ( !player isonground() )
            continue;

        if ( isdefined( trigger.claimedby ) && player != trigger.claimedby )
            continue;

        if ( !player hasweapon( self.name ) )
            continue;

        curr_ammo = player getweaponammostock( "hatchet_mp" );
        maxammo = weaponmaxammo( "hatchet_mp" );

        if ( player.grenadetypeprimary == "hatchet_mp" )
            maxammo = player.grenadetypeprimarycount;
        else if ( isdefined( player.grenadetypesecondary ) && player.grenadetypesecondary == "hatchet_mp" )
            maxammo = player.grenadetypesecondarycount;

        if ( curr_ammo >= maxammo )
            continue;

        if ( isdefined( playersoundonuse ) )
            player playlocalsound( playersoundonuse );

        if ( isdefined( npcsoundonuse ) )
            player playsound( npcsoundonuse );

        self thread [[ callback ]]( player );
    }
}

onspawnretrievableweaponobject( watcher, player )
{
    self endon( "death" );
    self endon( "hacked" );

    if ( ishacked() )
    {
        self thread watchshutdown( player );
        return;
    }

    self setowner( player );
    self setteam( player.pers["team"] );
    self.owner = player;
    self.oldangles = self.angles;
    self waittillnotmoving();

    if ( isdefined( watcher.activationdelay ) )
        wait( watcher.activationdelay );

    waittillframeend;

    if ( player.pers["team"] == "spectator" )
        return;

    triggerorigin = self.origin;
    triggerparentent = undefined;

    if ( isdefined( self.stucktoplayer ) )
    {
        if ( isalive( self.stucktoplayer ) || !isdefined( self.stucktoplayer.body ) )
            triggerparentent = self.stucktoplayer;
        else
            triggerparentent = self.stucktoplayer.body;
    }

    if ( isdefined( triggerparentent ) )
        triggerorigin = triggerparentent.origin + vectorscale( ( 0, 0, 1 ), 10.0 );
    else
    {
        up = anglestoup( self.angles );
        triggerorigin = self.origin + up;
    }

    self.pickuptrigger = spawn( "trigger_radius_use", triggerorigin );
    self.pickuptrigger sethintlowpriority( 1 );
    self.pickuptrigger setcursorhint( "HINT_NOICON", self );
    self.pickuptrigger enablelinkto();
    self.pickuptrigger linkto( self );
    self.pickuptrigger setinvisibletoall();
    self.pickuptrigger setvisibletoplayer( player );

    if ( isdefined( level.retrievehints[watcher.name] ) )
        self.pickuptrigger sethintstring( level.retrievehints[watcher.name].hint );
    else
        self.pickuptrigger sethintstring( &"MP_GENERIC_PICKUP" );

    if ( level.teambased )
        self.pickuptrigger setteamfortrigger( player.pers["team"] );
    else
        self.pickuptrigger setteamfortrigger( "none" );

    if ( isdefined( triggerparentent ) )
        self.pickuptrigger linkto( triggerparentent );

    if ( watcher.enemydestroy )
    {
        self.enemytrigger = spawn( "trigger_radius_use", triggerorigin );
        self.enemytrigger setcursorhint( "HINT_NOICON", self );
        self.enemytrigger enablelinkto();
        self.enemytrigger linkto( self );
        self.enemytrigger setinvisibletoplayer( player );

        if ( level.teambased )
        {
            self.enemytrigger setexcludeteamfortrigger( player.team );
            self.enemytrigger.triggerteamignore = self.team;
        }

        if ( isdefined( level.destroyhints[watcher.name] ) )
            self.enemytrigger sethintstring( level.destroyhints[watcher.name].hint );
        else
            self.enemytrigger sethintstring( &"MP_GENERIC_DESTROY" );

        self thread watchusetrigger( self.enemytrigger, watcher.ondestroyed );
    }

    self thread watchusetrigger( self.pickuptrigger, watcher.pickup, watcher.pickupsoundplayer, watcher.pickupsound );
/#
    thread switch_team( self, watcher.weapon, player );
#/
    if ( isdefined( watcher.pickup_trigger_listener ) )
        self thread [[ watcher.pickup_trigger_listener ]]( self.pickuptrigger, player );

    self thread watchshutdown( player );
}

watch_trigger_visibility( triggers, weap_name )
{
    self notify( "watchTriggerVisibility" );
    self endon( "watchTriggerVisibility" );
    self endon( "death" );
    self endon( "hacked" );
    max_ammo = weaponmaxammo( weap_name );
    start_ammo = weaponstartammo( weap_name );
    ammo_to_check = 0;

    while ( true )
    {
        players = level.players;

        for ( i = 0; i < players.size; i++ )
        {
            if ( players[i] hasweapon( weap_name ) )
            {
                ammo_to_check = max_ammo;

                if ( self.owner == players[i] )
                {
                    curr_ammo = players[i] getweaponammostock( weap_name ) + players[i] getweaponammoclip( weap_name );

                    if ( weap_name == "hatchet_mp" )
                        curr_ammo = players[i] getweaponammostock( weap_name );

                    if ( curr_ammo < ammo_to_check )
                    {
                        triggers["owner_pickup"] setvisibletoplayer( players[i] );
                        triggers["enemy_pickup"] setinvisibletoplayer( players[i] );
                    }
                    else
                    {
                        triggers["owner_pickup"] setinvisibletoplayer( players[i] );
                        triggers["enemy_pickup"] setinvisibletoplayer( players[i] );
                    }
                }
                else
                {
                    curr_ammo = players[i] getweaponammostock( weap_name ) + players[i] getweaponammoclip( weap_name );

                    if ( weap_name == "hatchet_mp" )
                        curr_ammo = players[i] getweaponammostock( weap_name );

                    if ( curr_ammo < ammo_to_check )
                    {
                        triggers["owner_pickup"] setinvisibletoplayer( players[i] );
                        triggers["enemy_pickup"] setvisibletoplayer( players[i] );
                    }
                    else
                    {
                        triggers["owner_pickup"] setinvisibletoplayer( players[i] );
                        triggers["enemy_pickup"] setinvisibletoplayer( players[i] );
                    }
                }

                continue;
            }

            triggers["owner_pickup"] setinvisibletoplayer( players[i] );
            triggers["enemy_pickup"] setinvisibletoplayer( players[i] );
        }

        wait 0.05;
    }
}

destroyent()
{
    self delete();
}

pickup( player )
{
    if ( self.name != "hatchet_mp" && isdefined( self.owner ) && self.owner != player )
        return;

    self notify( "picked_up" );
    self.playdialog = 0;
    self destroyent();
    player giveweapon( self.name );
    clip_ammo = player getweaponammoclip( self.name );
    clip_max_ammo = weaponclipsize( self.name );

    if ( clip_ammo < clip_max_ammo )
        clip_ammo++;

    player setweaponammoclip( self.name, clip_ammo );
}

ondestroyed( attacker )
{
    playfx( level._effect["tacticalInsertionFizzle"], self.origin );
    self playsound( "dst_tac_insert_break" );
    self.owner maps\mp\gametypes\_globallogic_audio::leaderdialogonplayer( "equipment_destroyed", "item_destroyed" );
    self delete();
}

watchshutdown( player )
{
    self waittill_any( "death", "hacked" );
    pickuptrigger = self.pickuptrigger;
    hackertrigger = self.hackertrigger;
    hatchetpickuptrigger = self.hatchetpickuptrigger;
    enemytrigger = self.enemytrigger;

    if ( isdefined( pickuptrigger ) )
        pickuptrigger delete();

    if ( isdefined( hackertrigger ) )
    {
        if ( isdefined( hackertrigger.progressbar ) )
        {
            hackertrigger.progressbar destroyelem();
            hackertrigger.progresstext destroyelem();
        }

        hackertrigger delete();
    }

    if ( isdefined( hatchetpickuptrigger ) )
        hatchetpickuptrigger delete();

    if ( isdefined( enemytrigger ) )
        enemytrigger delete();
}

watchusetrigger( trigger, callback, playersoundonuse, npcsoundonuse )
{
    self endon( "delete" );
    self endon( "hacked" );

    while ( true )
    {
        trigger waittill( "trigger", player );

        if ( !isalive( player ) )
            continue;

        if ( !player isonground() )
            continue;

        if ( isdefined( trigger.triggerteam ) && player.pers["team"] != trigger.triggerteam )
            continue;

        if ( isdefined( trigger.triggerteamignore ) && player.team == trigger.triggerteamignore )
            continue;

        if ( isdefined( trigger.claimedby ) && player != trigger.claimedby )
            continue;

        grenade = player.throwinggrenade;
        isequipment = isweaponequipment( player getcurrentweapon() );

        if ( isdefined( isequipment ) && isequipment )
            grenade = 0;

        if ( player usebuttonpressed() && !grenade && !player meleebuttonpressed() )
        {
            if ( isdefined( playersoundonuse ) )
                player playlocalsound( playersoundonuse );

            if ( isdefined( npcsoundonuse ) )
                player playsound( npcsoundonuse );

            self thread [[ callback ]]( player );
        }
    }
}

createretrievablehint( name, hint )
{
    retrievehint = spawnstruct();
    retrievehint.name = name;
    retrievehint.hint = hint;
    level.retrievehints[name] = retrievehint;
}

createhackerhint( name, hint )
{
    hackerhint = spawnstruct();
    hackerhint.name = name;
    hackerhint.hint = hint;
    level.hackerhints[name] = hackerhint;
}

createdestroyhint( name, hint )
{
    destroyhint = spawnstruct();
    destroyhint.name = name;
    destroyhint.hint = hint;
    level.destroyhints[name] = destroyhint;
}

attachreconmodel( modelname, owner )
{
    if ( !isdefined( self ) )
        return;

    reconmodel = spawn( "script_model", self.origin );
    reconmodel.angles = self.angles;
    reconmodel setmodel( modelname );
    reconmodel.model_name = modelname;
    reconmodel linkto( self );
    reconmodel setcontents( 0 );
    reconmodel resetreconmodelvisibility( owner );
    reconmodel thread watchreconmodelfordeath( self );
    reconmodel thread resetreconmodelonevent( "joined_team", owner );
    reconmodel thread resetreconmodelonevent( "player_spawned", owner );
    self.reconmodelentity = reconmodel;
}

resetreconmodelvisibility( owner )
{
    if ( !isdefined( self ) )
        return;

    self setinvisibletoall();
    self setforcenocull();

    if ( !isdefined( owner ) )
        return;

    for ( i = 0; i < level.players.size; i++ )
    {
        if ( !level.players[i] hasperk( "specialty_detectexplosive" ) && !level.players[i] hasperk( "specialty_showenemyequipment" ) )
            continue;

        if ( level.players[i].team == "spectator" )
            continue;

        hasreconmodel = 0;

        if ( level.players[i] hasperk( "specialty_detectexplosive" ) )
        {
            switch ( self.model_name )
            {
                case "t6_wpn_claymore_world_detect":
                case "t6_wpn_c4_world_detect":
                    hasreconmodel = 1;
                    break;
                default:
                    break;
            }
        }

        if ( level.players[i] hasperk( "specialty_showenemyequipment" ) )
        {
            switch ( self.model_name )
            {
                case "t6_wpn_trophy_system_world_detect":
                case "t6_wpn_taser_mine_world_detect":
                case "t6_wpn_tac_insert_detect":
                case "t6_wpn_motion_sensor_world_detect":
                case "t6_wpn_claymore_world_detect":
                case "t6_wpn_c4_world_detect":
                case "t6_wpn_bouncing_betty_world_detect":
                case "t5_weapon_scrambler_world_detect":
                    hasreconmodel = 1;
                    break;
                default:
                    break;
            }
        }

        if ( !hasreconmodel )
            continue;

        isenemy = 1;

        if ( level.teambased )
        {
            if ( level.players[i].team == owner.team )
                isenemy = 0;
        }
        else if ( level.players[i] == owner )
            isenemy = 0;

        if ( isenemy )
            self setvisibletoplayer( level.players[i] );
    }
}

watchreconmodelfordeath( parentent )
{
    self endon( "death" );
    parentent waittill_any( "death", "hacked" );
    self delete();
}

resetreconmodelonevent( eventname, owner )
{
    self endon( "death" );

    for (;;)
    {
        level waittill( eventname, newowner );

        if ( isdefined( newowner ) )
            owner = newowner;

        self resetreconmodelvisibility( owner );
    }
}

switch_team( entity, weapon_name, owner )
{
/#
    self notify( "stop_disarmthink" );
    self endon( "stop_disarmthink" );
    self endon( "death" );
    setdvar( "scr_switch_team", "" );

    while ( true )
    {
        wait 0.5;
        devgui_int = getdvarint( "scr_switch_team" );

        if ( devgui_int != 0 )
        {
            team = "autoassign";
            player = maps\mp\gametypes\_dev::getormakebot( team );

            if ( !isdefined( player ) )
            {
                println( "Could not add test client" );
                wait 1;
                continue;
            }

            entity.owner hackerremoveweapon( entity );
            entity.hacked = 1;
            entity setowner( player );
            entity setteam( player.pers["team"] );
            entity.owner = player;
            entity notify( "hacked", player );
            level notify( "hacked", entity, player );

            if ( entity.name == "camera_spike_mp" && isdefined( entity.camerahead ) )
                entity.camerahead notify( "hacked", player );

            wait 0.05;

            if ( isdefined( player ) && player.sessionstate == "playing" )
                player notify( "grenade_fire", self, self.name );

            setdvar( "scr_switch_team", "0" );
        }
    }
#/
}
