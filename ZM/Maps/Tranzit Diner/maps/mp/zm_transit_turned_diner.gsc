// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\gametypes_zm\zcleansed;

precache()
{

}

main()
{
    getspawnpoints();
    maps\mp\gametypes_zm\_zm_gametype::setup_standard_objects( "diner" );

    if ( getdvar( "ui_gametype" ) == "zcleansed" )
        maps\mp\zombies\_zm_game_module::set_current_game_module( level.game_module_cleansed_index );
    else
        maps\mp\zombies\_zm_game_module::set_current_game_module( level.game_module_turned_index );

    setdvar( "aim_target_player_enabled", 1 );
    diner_front_door = getentarray( "auto2278", "targetname" );
    array_thread( diner_front_door, ::self_delete );
    diner_side_door = getentarray( "auto2278", "targetname" );
    array_thread( diner_side_door, ::self_delete );
    garage_all_door = getentarray( "auto2279", "targetname" );
    array_thread( garage_all_door, ::self_delete );
    level.cleansed_loadout = getgametypesetting( "cleansedLoadout" );

    if ( level.cleansed_loadout )
    {
        level.humanify_custom_loadout = maps\mp\gametypes_zm\zcleansed::gunprogressionthink;
        level.cleansed_zombie_round = 5;
    }
    else
    {
        level.humanify_custom_loadout = maps\mp\gametypes_zm\zcleansed::shotgunloadout;
        level.cleansed_zombie_round = 2;
    }

    collision = spawn( "script_model", ( -5000, -6700, 0 ), 1 );
    collision setmodel( "zm_collision_transit_diner_survival" );
    collision disconnectpaths();
}

getspawnpoints()
{
    level._turned_zombie_respawnpoints = getstructarray( "initial_spawn_points", "targetname" );
    level._turned_powerup_spawnpoints = [];
    level._turned_powerup_spawnpoints[0] = spawnstruct();
    level._turned_powerup_spawnpoints[0].origin = ( -6072, -7808, 8 );
    level._turned_powerup_spawnpoints[1] = spawnstruct();
    level._turned_powerup_spawnpoints[1].origin = ( -5408, -6824, -53.5431 );
    level._turned_powerup_spawnpoints[2] = spawnstruct();
    level._turned_powerup_spawnpoints[2].origin = ( -4760, -7144, -64 );
    level._turned_powerup_spawnpoints[3] = spawnstruct();
    level._turned_powerup_spawnpoints[3].origin = ( -4864, -7864, -62.35 );
}

onendgame()
{

}
