// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zm_tomb;
#include maps\mp\zm_tomb_classic;

init()
{
    add_map_gamemode( "zclassic", maps\mp\zm_tomb::zstandard_preinit, undefined, undefined );
    add_map_location_gamemode( "zclassic", "tomb", maps\mp\zm_tomb_classic::precache, maps\mp\zm_tomb_classic::main );
}
