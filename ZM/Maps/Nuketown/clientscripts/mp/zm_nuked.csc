// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_weapons;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zm_nuked_ffotd;
#include clientscripts\mp\zm_nuked_fx;
#include clientscripts\mp\zm_nuked_amb;
#include clientscripts\mp\zm_nuked_standard;
#include clientscripts\mp\zombies\_zm;
#include clientscripts\mp\_sticky_grenade;
#include clientscripts\mp\zombies\_zm_weap_cymbal_monkey;
#include clientscripts\mp\zombies\_zm_weap_tazer_knuckles;

main()
{
    level thread clientscripts\mp\zm_nuked_ffotd::main_start();
    level.default_start_location = "nuked";
    level.default_game_mode = "zstandard";
    level._no_water_risers = 1;
    level.zombiemode_using_doubletap_perk = 1;
    level.zombiemode_using_juggernaut_perk = 1;
    level.zombiemode_using_revive_perk = 1;
    level.zombiemode_using_sleightofhand_perk = 1;
    level.zombiemode_using_perk_intro_fx = 1;
    level.riser_fx_on_client = 1;
    start_zombie_stuff();
    init_gamemodes();
    clientscripts\mp\zm_nuked_fx::main();
    thread clientscripts\mp\zm_nuked_amb::main();
    setsaveddvar( "sm_sunsamplesizenear", 0.25 );
    zombe_gametype_premain();
    level thread clientscripts\mp\zm_nuked_ffotd::main_end();
    waitforclient( 0 );
    level thread init_fog_vol_to_visionset();
    level thread intermission_settings();
}

init_fog_vol_to_visionset()
{
    init_fog_vol_to_visionset_monitor( "zm_nuked", 2 );
    fog_vol_to_visionset_set_suffix( "" );
    fog_vol_to_visionset_set_info( 0, "zm_nuked" );
}

init_gamemodes()
{
    add_map_gamemode( "zstandard", undefined, undefined );
    add_map_location_gamemode( "zstandard", "nuked", clientscripts\mp\zm_nuked_standard::precache, undefined, clientscripts\mp\zm_nuked_standard::main );
}

start_zombie_stuff()
{
    level.raygun2_included = 1;
    include_weapons();
    include_powerups();
    clientscripts\mp\zombies\_zm::init();
    register_clientflags();
    register_clientflag_callbacks();
    registerclientfield( "world", "zombie_eye_change", 4000, 1, "int", ::zombie_eye_clientfield, 1 );
    level thread clientscripts\mp\_sticky_grenade::main();
    level.legacy_cymbal_monkey = 1;
    clientscripts\mp\zombies\_zm_weap_cymbal_monkey::init();
    clientscripts\mp\zombies\_zm_weap_tazer_knuckles::init();
}

zombie_eye_clientfield( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    level._override_eye_fx = level._effect["blue_eyes"];
}

register_clientflags()
{

}

register_clientflag_callbacks()
{

}

include_weapons()
{
    include_weapon( "knife_zm", 0 );
    include_weapon( "frag_grenade_zm", 0 );
    include_weapon( "claymore_zm", 0 );
    include_weapon( "sticky_grenade_zm", 0 );
    include_weapon( "m1911_zm", 0 );
    include_weapon( "m1911_upgraded_zm", 0 );
    include_weapon( "python_zm" );
    include_weapon( "python_upgraded_zm", 0 );
    include_weapon( "judge_zm" );
    include_weapon( "judge_upgraded_zm", 0 );
    include_weapon( "kard_zm" );
    include_weapon( "kard_upgraded_zm", 0 );
    include_weapon( "fiveseven_zm" );
    include_weapon( "fiveseven_upgraded_zm", 0 );
    include_weapon( "beretta93r_zm", 0 );
    include_weapon( "beretta93r_upgraded_zm", 0 );
    include_weapon( "fivesevendw_zm" );
    include_weapon( "fivesevendw_upgraded_zm", 0 );
    include_weapon( "ak74u_zm", 0 );
    include_weapon( "ak74u_upgraded_zm", 0 );
    include_weapon( "mp5k_zm", 0 );
    include_weapon( "mp5k_upgraded_zm", 0 );
    include_weapon( "qcw05_zm" );
    include_weapon( "qcw05_upgraded_zm", 0 );
    include_weapon( "870mcs_zm", 0 );
    include_weapon( "870mcs_upgraded_zm", 0 );
    include_weapon( "rottweil72_zm", 0 );
    include_weapon( "rottweil72_upgraded_zm", 0 );
    include_weapon( "saiga12_zm" );
    include_weapon( "saiga12_upgraded_zm", 0 );
    include_weapon( "srm1216_zm" );
    include_weapon( "srm1216_upgraded_zm", 0 );
    include_weapon( "m14_zm", 0 );
    include_weapon( "m14_upgraded_zm", 0 );
    include_weapon( "saritch_zm" );
    include_weapon( "saritch_upgraded_zm", 0 );
    include_weapon( "m16_zm", 0 );
    include_weapon( "m16_gl_upgraded_zm", 0 );
    include_weapon( "xm8_zm" );
    include_weapon( "xm8_upgraded_zm", 0 );
    include_weapon( "type95_zm" );
    include_weapon( "type95_upgraded_zm", 0 );
    include_weapon( "tar21_zm" );
    include_weapon( "tar21_upgraded_zm", 0 );
    include_weapon( "galil_zm" );
    include_weapon( "galil_upgraded_zm", 0 );
    include_weapon( "fnfal_zm" );
    include_weapon( "fnfal_upgraded_zm", 0 );
    include_weapon( "dsr50_zm" );
    include_weapon( "dsr50_upgraded_zm", 0 );
    include_weapon( "barretm82_zm" );
    include_weapon( "barretm82_upgraded_zm", 0 );
    include_weapon( "rpd_zm" );
    include_weapon( "rpd_upgraded_zm", 0 );
    include_weapon( "hamr_zm" );
    include_weapon( "hamr_upgraded_zm", 0 );
    include_weapon( "usrpg_zm" );
    include_weapon( "usrpg_upgraded_zm", 0 );
    include_weapon( "m32_zm" );
    include_weapon( "m32_upgraded_zm", 0 );
    include_weapon( "hk416_zm" );
    include_weapon( "hk416_upgraded_zm", 0 );
    include_weapon( "lsat_zm" );
    include_weapon( "lsat_upgraded_zm", 0 );
    include_weapon( "cymbal_monkey_zm" );
    include_weapon( "ray_gun_zm" );
    include_weapon( "ray_gun_upgraded_zm", 0 );
    include_weapon( "tazer_knuckles_zm", 0 );
    include_weapon( "knife_ballistic_zm" );
    include_weapon( "knife_ballistic_upgraded_zm", 0 );
    include_weapon( "knife_ballistic_bowie_zm", 0 );
    include_weapon( "knife_ballistic_bowie_upgraded_zm", 0 );

    if ( is_true( level.raygun2_included ) && !isdemoplaying() )
    {
        include_weapon( "raygun_mark2_zm", hasdlcavailable( "dlc3" ) );
        include_weapon( "raygun_mark2_upgraded_zm", 0 );
    }
}

include_powerups()
{
    include_powerup( "nuke" );
    include_powerup( "insta_kill" );
    include_powerup( "double_points" );
    include_powerup( "full_ammo" );
    include_powerup( "fire_sale" );
}

intermission_settings()
{
    level waittill( "znfg" );
    players = getlocalplayers();

    for ( i = 0; i < players.size; i++ )
        setworldfogactivebank( i, 2 );
}
