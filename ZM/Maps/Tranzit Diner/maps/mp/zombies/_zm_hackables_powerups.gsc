// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_equip_hacker;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_powerups;

unhackable_powerup( name )
{
    ret = 0;

    switch ( name )
    {
        case "random_weapon":
        case "lose_points_team":
        case "bonus_points_team":
        case "bonus_points_player":
            ret = 1;
            break;
    }

    return ret;
}

hack_powerups()
{
    while ( true )
    {
        level waittill( "powerup_dropped", powerup );

        if ( !unhackable_powerup( powerup.powerup_name ) )
        {
            struct = spawnstruct();
            struct.origin = powerup.origin;
            struct.radius = 65;
            struct.height = 72;
            struct.script_float = 5;
            struct.script_int = 5000;
            struct.powerup = powerup;
            powerup thread powerup_pickup_watcher( struct );
            maps\mp\zombies\_zm_equip_hacker::register_pooled_hackable_struct( struct, ::powerup_hack );
        }
    }
}

powerup_pickup_watcher( powerup_struct )
{
    self endon( "hacked" );

    self waittill( "death" );

    maps\mp\zombies\_zm_equip_hacker::deregister_hackable_struct( powerup_struct );
}

powerup_hack( hacker )
{
    self.powerup notify( "hacked" );

    if ( isdefined( self.powerup.zombie_grabbable ) && self.powerup.zombie_grabbable )
    {
        self.powerup notify( "powerup_timedout" );
        origin = self.powerup.origin;
        self.powerup delete();
        self.powerup = maps\mp\zombies\_zm_net::network_safe_spawn( "powerup", 1, "script_model", origin );

        if ( isdefined( self.powerup ) )
        {
            self.powerup maps\mp\zombies\_zm_powerups::powerup_setup( "full_ammo" );
            self.powerup thread maps\mp\zombies\_zm_powerups::powerup_timeout();
            self.powerup thread maps\mp\zombies\_zm_powerups::powerup_wobble();
            self.powerup thread maps\mp\zombies\_zm_powerups::powerup_grab();
        }
    }
    else if ( self.powerup.powerup_name == "full_ammo" )
        self.powerup maps\mp\zombies\_zm_powerups::powerup_setup( "fire_sale" );
    else
        self.powerup maps\mp\zombies\_zm_powerups::powerup_setup( "full_ammo" );

    maps\mp\zombies\_zm_equip_hacker::deregister_hackable_struct( self );
}
