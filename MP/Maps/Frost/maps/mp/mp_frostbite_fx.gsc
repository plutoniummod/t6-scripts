// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\createfx\mp_frostbite_fx;

main()
{
    precache_fxanim_props();
    precache_fxanim_props_dlc4();
    precache_scripted_fx();
    precache_createfx_fx();
    maps\mp\createfx\mp_frostbite_fx::main();
}

precache_scripted_fx()
{
    level._effect["water_splash"] = loadfx( "bio/player/fx_player_water_splash_mp_frost" );
}

precache_createfx_fx()
{
    level._effect["fx_lf_mp_frostbite_sun"] = loadfx( "lens_flares/fx_lf_mp_frostbite_sun" );
    level._effect["fx_mp_frostbite_snow_ledge_runner"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_ledge_runner" );
    level._effect["fx_mp_frostbite_snow_chunk_runner"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_chunk_runner" );
    level._effect["fx_mp_frostbite_snow_gust_runner"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_gust_runner" );
    level._effect["fx_mp_frostbite_snow_fog"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_fog" );
    level._effect["fx_mp_frostbite_snow_flurries"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_flurries" );
    level._effect["fx_mp_frostbite_snow_flurries_fine"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_flurries_fine" );
    level._effect["fx_mp_frostbite_snow_flurries_window"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_flurries_window" );
    level._effect["fx_mp_frostbite_snow_flurries_vista"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_flurries_vista" );
    level._effect["fx_mp_frostbite_snow_gust_sm_runner"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_gust_sm_runner" );
    level._effect["fx_mp_frostbite_snow_swirl_runner"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_swirl_runner" );
    level._effect["fx_mp_frostbite_ground_blow"] = loadfx( "maps/mp_maps/fx_mp_frostbite_ground_blow" );
    level._effect["fx_mp_frostbite_snow_gust_tree"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_gust_tree" );
    level._effect["fx_mp_frostbite_snow_gust_roof"] = loadfx( "maps/mp_maps/fx_mp_frostbite_snow_gust_roof" );
    level._effect["fx_mp_frostbite_ice_fall_runner"] = loadfx( "maps/mp_maps/fx_mp_frostbite_ice_fall_runner" );
    level._effect["fx_mp_frostbite_ice_fall_sm_runner"] = loadfx( "maps/mp_maps/fx_mp_frostbite_ice_fall_sm_runner" );
    level._effect["fx_mp_frostbite_lamp_post"] = loadfx( "maps/mp_maps/fx_mp_frostbite_lamp_post" );
    level._effect["fx_frostbite_circle_light_glare"] = loadfx( "light/fx_frostbite_circle_light_glare" );
    level._effect["fx_frostbite_circle_light_glare_flr"] = loadfx( "light/fx_frostbite_circle_light_glare_flr" );
    level._effect["fx_mp_frostbite_lamp_int"] = loadfx( "maps/mp_maps/fx_mp_frostbite_lamp_int" );
    level._effect["fx_frostbite_exit_sign"] = loadfx( "light/fx_frostbite_exit_sign" );
    level._effect["fx_mp_frostbite_sign_glow"] = loadfx( "maps/mp_maps/fx_mp_frostbite_sign_glow" );
    level._effect["fx_mp_frostbite_sign_glow_flick"] = loadfx( "maps/mp_maps/fx_mp_frostbite_sign_glow_flick" );
    level._effect["fx_light_track_omni"] = loadfx( "light/fx_light_track_omni" );
    level._effect["fx_mp_frostbite_chimney_smk"] = loadfx( "maps/mp_maps/fx_mp_frostbite_chimney_smk" );
    level._effect["fx_mp_frostbite_chimney_smk_dark"] = loadfx( "maps/mp_maps/fx_mp_frostbite_chimney_smk_dark" );
    level._effect["fx_mp_frostbite_chimney_smk_vista"] = loadfx( "maps/mp_maps/fx_mp_frostbite_chimney_smk_vista" );
    level._effect["fx_mp_frostbite_steam"] = loadfx( "maps/mp_maps/fx_mp_frostbite_steam" );
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["laundry"] = %fxanim_gp_dryer_loop_anim;
    level.scr_anim["fxanim_props"]["dock_chain"] = %fxanim_mp_ver_stair_chain_sign_anim;
}

#using_animtree("fxanim_props_dlc4");

precache_fxanim_props_dlc4()
{
    level.scr_anim["fxanim_props_dlc4"]["pennants_01"] = %fxanim_mp_frost_pennants_01_anim;
    level.scr_anim["fxanim_props_dlc4"]["pennants_02"] = %fxanim_mp_frost_pennants_02_anim;
    level.scr_anim["fxanim_props_dlc4"]["candy_sign"] = %fxanim_mp_frost_candy_sign_anim;
    level.scr_anim["fxanim_props_dlc4"]["crane01"] = %fxanim_mp_frostbite_crane_01_anim;
    level.scr_anim["fxanim_props_dlc4"]["crane02"] = %fxanim_mp_frostbite_crane_02_anim;
    level.scr_anim["fxanim_props_dlc4"]["crane03"] = %fxanim_mp_frostbite_crane_03_anim;
    level.scr_anim["fxanim_props_dlc4"]["crane04"] = %fxanim_mp_frostbite_crane_04_anim;
    level.scr_anim["fxanim_props_dlc4"]["crane05"] = %fxanim_mp_frostbite_crane_05_anim;
    level.scr_anim["fxanim_props_dlc4"]["river_ice"] = %fxanim_mp_frost_ice_anim;
    level.scr_anim["fxanim_props_dlc4"]["river_ice2"] = %fxanim_mp_frost_ice_02_anim;
    level.scr_anim["fxanim_props_dlc4"]["gate"] = %fxanim_mp_frost_gate_anim;
}
