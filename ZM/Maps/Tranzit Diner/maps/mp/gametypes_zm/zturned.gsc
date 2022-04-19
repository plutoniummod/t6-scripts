// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_zm_gametype;

main()
{
    maps\mp\gametypes_zm\_zm_gametype::main();
    level.onprecachegametype = ::onprecachegametype;
    level.onstartgametype = ::onstartgametype;
    level._game_module_player_damage_callback = maps\mp\gametypes_zm\_zm_gametype::game_module_player_damage_callback;
    level._game_module_custom_spawn_init_func = maps\mp\gametypes_zm\_zm_gametype::custom_spawn_init_func;
    maps\mp\gametypes_zm\_zm_gametype::post_gametype_main( "zturned" );
}

onprecachegametype()
{
    precacheshellshock( "tabun_gas_mp" );
    level thread maps\mp\gametypes_zm\_zm_gametype::init();
    maps\mp\gametypes_zm\_zm_gametype::rungametypeprecache( "zturned" );
}

onstartgametype()
{
    maps\mp\gametypes_zm\_zm_gametype::setup_classic_gametype();
    maps\mp\gametypes_zm\_zm_gametype::rungametypemain( "zturned" );
}
