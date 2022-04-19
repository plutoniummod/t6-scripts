// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_craftables;
#include maps\mp\zm_tomb_craftables;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_magicbox;

precache()
{
    if ( isdefined( level.createfx_enabled ) && level.createfx_enabled )
        return;

    maps\mp\zombies\_zm_craftables::init();
    maps\mp\zm_tomb_craftables::randomize_craftable_spawns();
    maps\mp\zm_tomb_craftables::include_craftables();
    maps\mp\zm_tomb_craftables::init_craftables();
}

main()
{
    maps\mp\gametypes_zm\_zm_gametype::setup_standard_objects( "tomb" );
    maps\mp\zombies\_zm_game_module::set_current_game_module( level.game_module_standard_index );
    level thread maps\mp\zombies\_zm_craftables::think_craftables();
    flag_wait( "initial_blackscreen_passed" );
}

zm_treasure_chest_init()
{
    chest1 = getstruct( "start_chest", "script_noteworthy" );
    level.chests = [];
    level.chests[level.chests.size] = chest1;
    maps\mp\zombies\_zm_magicbox::treasure_chest_init( "start_chest" );
}
