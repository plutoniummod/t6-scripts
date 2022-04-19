// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_ai_dogs;
#include maps\mp\zombies\_zm;

main()
{
    maps\mp\gametypes_zm\_zm_gametype::main();
    level.onprecachegametype = ::onprecachegametype;
    level.onstartgametype = ::onstartgametype;
    level._game_module_custom_spawn_init_func = maps\mp\gametypes_zm\_zm_gametype::custom_spawn_init_func;
    level._game_module_stat_update_func = maps\mp\zombies\_zm_stats::survival_classic_custom_stat_update;
    maps\mp\gametypes_zm\_zm_gametype::post_gametype_main( "zstandard" );
}

onprecachegametype()
{
    level.playersuicideallowed = 1;
    level.canplayersuicide = ::canplayersuicide;
    level.suicide_weapon = "death_self_zm";
    precacheitem( "death_self_zm" );
    maps\mp\zombies\_zm_ai_dogs::init();
    maps\mp\gametypes_zm\_zm_gametype::rungametypeprecache( "zstandard" );
}

onstartgametype()
{
    maps\mp\gametypes_zm\_zm_gametype::setup_classic_gametype();
    maps\mp\gametypes_zm\_zm_gametype::rungametypemain( "zstandard", ::zstandard_main );
}

zstandard_main()
{
    level.dog_rounds_allowed = getgametypesetting( "allowdogs" );

    if ( level.dog_rounds_allowed )
        maps\mp\zombies\_zm_ai_dogs::enable_dog_rounds();

    level thread maps\mp\zombies\_zm::round_start();
    level thread maps\mp\gametypes_zm\_zm_gametype::kill_all_zombies();
}
