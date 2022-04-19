// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_mgturret;
#include maps\mp\zombies\_zm_buildables;

init()
{
    if ( !maps\mp\zombies\_zm_equipment::is_equipment_included( "equip_turret_zm" ) )
        return;

    precachemodel( "p6_anim_zm_buildable_turret" );
    precacheturret( "zombie_bullet_crouch_zm" );
    level.turret_name = "equip_turret_zm";
    maps\mp\zombies\_zm_equipment::register_equipment( "equip_turret_zm", &"ZOMBIE_EQUIP_TURRET_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_TURRET_HOWTO", "turret_zm_icon", "turret", undefined, ::transferturret, ::dropturret, ::pickupturret, ::placeturret );
    maps\mp\zombies\_zm_equipment::add_placeable_equipment( "equip_turret_zm", "p6_anim_zm_buildable_turret" );
    level thread onplayerconnect();
    maps\mp\gametypes_zm\_weaponobjects::createretrievablehint( "equip_turret", &"ZOMBIE_EQUIP_TURRET_PICKUP_HINT_STRING" );
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );
    self thread setupwatchers();

    for (;;)
    {
        self waittill( "spawned_player" );

        self thread watchturretuse();
    }
}

setupwatchers()
{
    self waittill( "weapon_watchers_created" );

    watcher = maps\mp\gametypes_zm\_weaponobjects::getweaponobjectwatcher( "equip_turret" );
    watcher.onspawnretrievetriggers = maps\mp\zombies\_zm_equipment::equipment_onspawnretrievableweaponobject;
}

watchturretuse()
{
    self notify( "watchTurretUse" );
    self endon( "watchTurretUse" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "equipment_placed", weapon, weapname );

        if ( weapname == level.turret_name )
        {
            self cleanupoldturret();
            self.buildableturret = weapon;
            self thread startturretdeploy( weapon );
        }
    }
}

cleanupoldturret()
{
    if ( isdefined( self.buildableturret ) )
    {
        if ( isdefined( self.buildableturret.stub ) )
        {
            thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.buildableturret.stub );
            self.buildableturret.stub = undefined;
        }

        if ( isdefined( self.buildableturret.turret ) )
        {
            if ( isdefined( self.buildableturret.turret.sound_ent ) )
                self.buildableturret.turret.sound_ent delete();

            self.buildableturret.turret delete();
        }

        if ( isdefined( self.buildableturret.sound_ent ) )
        {
            self.buildableturret.sound_ent delete();
            self.buildableturret.sound_ent = undefined;
        }

        self.buildableturret delete();
        self.turret_health = undefined;
    }
    else if ( isdefined( self.turret ) )
    {
        self.turret notify( "stop_burst_fire_unmanned" );
        self.turret delete();
    }

    self.turret = undefined;
    self notify( "turret_cleanup" );
}

watchforcleanup()
{
    self notify( "turret_cleanup" );
    self endon( "turret_cleanup" );
    self waittill_any( "death_or_disconnect", "equip_turret_zm_taken", "equip_turret_zm_pickup" );
    cleanupoldturret();
}

placeturret( origin, angles )
{
    item = self maps\mp\zombies\_zm_equipment::placed_equipment_think( "p6_anim_zm_buildable_turret", "equip_turret_zm", origin, angles );

    if ( isdefined( item ) )
        item.owner = self;

    return item;
}

dropturret()
{
    item = self maps\mp\zombies\_zm_equipment::dropped_equipment_think( "p6_anim_zm_buildable_turret", "equip_turret_zm", self.origin, self.angles );

    if ( isdefined( item ) )
        item.turret_health = self.turret_health;

    self.turret_health = undefined;
    return item;
}

pickupturret( item )
{
    item.owner = self;
    self.turret_health = item.turret_health;
    item.turret_health = undefined;
}

transferturret( fromplayer, toplayer )
{
    buildableturret = toplayer.buildableturret;
    turret = toplayer.turret;
    toplayer.buildableturret = fromplayer.buildableturret;
    toplayer.turret = fromplayer.turret;
    fromplayer.buildableturret = buildableturret;
    fromplayer.turret = turret;
    toplayer.buildableturret.original_owner = toplayer;
    toplayer notify( "equip_turret_zm_taken" );
    toplayer thread startturretdeploy( toplayer.buildableturret );
    fromplayer notify( "equip_turret_zm_taken" );

    if ( isdefined( fromplayer.buildableturret ) )
    {
        fromplayer thread startturretdeploy( fromplayer.buildableturret );
        fromplayer.buildableturret.original_owner = fromplayer;
        fromplayer.buildableturret.owner = fromplayer;
    }
    else
        fromplayer maps\mp\zombies\_zm_equipment::equipment_release( "equip_turret_zm" );

    turret_health = toplayer.turret_health;
    toplayer.turret_health = fromplayer.turret_health;
    fromplayer.turret_health = turret_health;
}

startturretdeploy( weapon )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "equip_turret_zm_taken" );
    self thread watchforcleanup();

    if ( !isdefined( self.turret_health ) )
        self.turret_health = 60;

    if ( isdefined( weapon ) )
    {
        weapon hide();
        wait 0.1;

        if ( isdefined( weapon.power_on ) && weapon.power_on )
            weapon.turret notify( "stop_burst_fire_unmanned" );

        if ( !isdefined( weapon ) )
            return;

        if ( isdefined( self.turret ) )
        {
            self.turret notify( "stop_burst_fire_unmanned" );
            self.turret notify( "turret_deactivated" );
            self.turret delete();
        }

        turret = spawnturret( "misc_turret", weapon.origin, "zombie_bullet_crouch_zm" );
        turret.turrettype = "sentry";
        turret setturrettype( turret.turrettype );
        turret setmodel( "p6_anim_zm_buildable_turret" );
        turret.origin = weapon.origin;
        turret.angles = weapon.angles;
        turret linkto( weapon );
        turret makeunusable();
        turret.owner = self;
        turret setowner( turret.owner );
        turret maketurretunusable();
        turret setmode( "auto_nonai" );
        turret setdefaultdroppitch( 45.0 );
        turret setconvergencetime( 0.3 );
        turret setturretteam( self.team );
        turret.team = self.team;
        turret.damage_own_team = 1;
        turret.turret_active = 1;
        weapon.turret = turret;
        self.turret = turret;

        if ( isdefined( level.equipment_turret_needs_power ) && level.equipment_turret_needs_power )
        {
            weapon.power_on = 0;
            maps\mp\zombies\_zm_power::add_temp_powered_item( ::turret_power_on, ::turret_power_off, ::turret_in_range, maps\mp\zombies\_zm_power::cost_high, 1, weapon.power_on, weapon );
        }
        else
            weapon.power_on = 1;

        if ( weapon.power_on )
            turret thread maps\mp\zombies\_zm_mgturret::burst_fire_unmanned();
        else
            self iprintlnbold( &"ZOMBIE_NEED_LOCAL_POWER" );

        if ( !( isdefined( level.equipment_turret_needs_power ) && level.equipment_turret_needs_power ) )
            self thread turretdecay( weapon );

        self thread maps\mp\zombies\_zm_buildables::delete_on_disconnect( weapon );

        while ( isdefined( weapon ) )
        {
            if ( !is_true( weapon.power_on ) )
            {
                if ( isdefined( self.buildableturret.sound_ent ) )
                {
                    self.buildableturret.sound_ent playsound( "wpn_zmb_turret_stop" );
                    self.buildableturret.sound_ent delete();
                    self.buildableturret.sound_ent = undefined;
                }
            }

            wait 0.1;
        }

        if ( isdefined( self.buildableturret.sound_ent ) )
        {
            self.buildableturret.sound_ent playsound( "wpn_zmb_turret_stop" );
            self.buildableturret.sound_ent delete();
            self.buildableturret.sound_ent = undefined;
        }

        if ( isdefined( turret ) )
        {
            turret notify( "stop_burst_fire_unmanned" );
            turret notify( "turret_deactivated" );
            turret delete();
        }

        self.turret = undefined;
        self notify( "turret_cleanup" );
    }
}

turret_in_range( delta, origin, radius )
{
    if ( distancesquared( self.target.origin, origin ) < radius * radius )
        return true;

    return false;
}

turret_power_on( origin, radius )
{
/#
    println( "^1ZM POWER: turret on\\n" );
#/
    if ( !isdefined( self.target ) )
        return;

    self.target.power_on = 1;
    self.target.turret thread maps\mp\zombies\_zm_mgturret::burst_fire_unmanned();
    player = self.target.turret.owner;

    if ( !isdefined( player.buildableturret.sound_ent ) )
        player.buildableturret.sound_ent = spawn( "script_origin", self.target.turret.origin );

    player.buildableturret.sound_ent playsound( "wpn_zmb_turret_start" );
    player.buildableturret.sound_ent playloopsound( "wpn_zmb_turret_loop", 2 );
}

turret_power_off( origin, radius )
{
/#
    println( "^1ZM POWER: turret off\\n" );
#/
    if ( !isdefined( self.target ) )
        return;

    self.target.power_on = 0;
    self.target.turret notify( "stop_burst_fire_unmanned" );
    player = self.target.turret.owner;

    if ( isdefined( player.buildableturret.sound_ent ) )
    {
        player.buildableturret.sound_ent playsound( "wpn_zmb_turret_stop" );
        player.buildableturret.sound_ent delete();
        player.buildableturret.sound_ent = undefined;
    }
}

turretdecay( weapon )
{
    self endon( "death" );
    self endon( "disconnect" );

    while ( isdefined( weapon ) )
    {
        if ( weapon.power_on )
        {
            self.turret_health--;

            if ( self.turret_health <= 0 )
            {
                self cleanupoldturret();
                self thread maps\mp\zombies\_zm_equipment::equipment_release( "equip_turret_zm" );
                return;
            }
        }

        wait 1;
    }
}

debugturret( radius )
{
/#
    while ( isdefined( self ) )
    {
        circle( self.origin, radius, ( 1, 1, 1 ), 0, 1, 1 );
        wait 0.05;
    }
#/
}
