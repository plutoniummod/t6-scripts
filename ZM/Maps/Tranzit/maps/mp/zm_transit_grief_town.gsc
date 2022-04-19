// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_race_utility;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\gametypes_zm\zmeat;

precache()
{
    precachemodel( "zm_collision_transit_town_survival" );
}

town_treasure_chest_init()
{
    chest1 = getstruct( "town_chest", "script_noteworthy" );
    chest2 = getstruct( "town_chest_2", "script_noteworthy" );
    setdvar( "disable_rope", 1 );
    setdvar( "disableLookAtEntityLogic", 1 );
    level.chests = [];
    level.chests[level.chests.size] = chest1;
    level.chests[level.chests.size] = chest2;
    maps\mp\zombies\_zm_magicbox::treasure_chest_init( "town_chest" );
}

main()
{
    maps\mp\gametypes_zm\_zm_gametype::setup_standard_objects( "town" );
    town_treasure_chest_init();
    level.enemy_location_override_func = ::enemy_location_override;
    collision = spawn( "script_model", ( 1363, 471, 0 ), 1 );
    collision setmodel( "zm_collision_transit_town_survival" );
    collision disconnectpaths();
    flag_wait( "initial_blackscreen_passed" );
    maps\mp\zombies\_zm_game_module::turn_power_on_and_open_doors();
    flag_wait( "start_zombie_round_logic" );
    wait 1;
    level notify( "revive_on" );
    wait_network_frame();
    level notify( "doubletap_on" );
    wait_network_frame();
    level notify( "marathon_on" );
    wait_network_frame();
    level notify( "juggernog_on" );
    wait_network_frame();
    level notify( "sleight_on" );
    wait_network_frame();
    level notify( "Pack_A_Punch_on" );
/#
    level thread maps\mp\gametypes_zm\zmeat::spawn_level_meat_manager();
#/
}

enemy_location_override( zombie, enemy )
{
    location = enemy.origin;

    if ( is_true( self.reroute ) )
    {
        if ( isdefined( self.reroute_origin ) )
            location = self.reroute_origin;
    }

    return location;
}
