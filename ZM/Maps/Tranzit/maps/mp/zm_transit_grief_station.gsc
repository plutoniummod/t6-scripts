// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\gametypes_zm\zmeat;

precache()
{
    precachemodel( "zm_collision_transit_busdepot_survival" );
}

station_treasure_chest_init()
{
    chest1 = getstruct( "depot_chest", "script_noteworthy" );
    level.chests = [];
    level.chests[level.chests.size] = chest1;
    maps\mp\zombies\_zm_magicbox::treasure_chest_init( "depot_chest" );
}

main()
{
    maps\mp\gametypes_zm\_zm_gametype::setup_standard_objects( "station" );
    station_treasure_chest_init();
    level.enemy_location_override_func = ::enemy_location_override;
    collision = spawn( "script_model", ( -6896, 4744, 0 ), 1 );
    collision setmodel( "zm_collision_transit_busdepot_survival" );
    collision disconnectpaths();
    flag_wait( "initial_blackscreen_passed" );
    nodes = getnodearray( "classic_only_traversal", "targetname" );

    foreach ( node in nodes )
        unlink_nodes( node, getnode( node.target, "targetname" ) );

    level thread maps\mp\zombies\_zm_perks::perk_machine_removal( "specialty_quickrevive", "p_glo_tools_chest_tall" );
    maps\mp\zombies\_zm_game_module::turn_power_on_and_open_doors();
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
