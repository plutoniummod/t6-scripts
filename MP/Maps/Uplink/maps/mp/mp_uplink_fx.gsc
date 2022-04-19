// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\createfx\mp_uplink_fx;

main()
{
    precache_fxanim_props();
    precache_fxanim_props_dlc3();
    precache_scripted_fx();
    precache_createfx_fx();
    maps\mp\createfx\mp_uplink_fx::main();
}

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_mp_uplink_rain_med_fast_os"] = loadfx( "weather/fx_mp_uplink_rain_med_fast_os" );
    level._effect["fx_mp_uplink_rain_med_fast_os_vista"] = loadfx( "weather/fx_mp_uplink_rain_med_fast_os_vista" );
    level._effect["fx_mp_uplink_rain_med_fast_neg_os"] = loadfx( "weather/fx_mp_uplink_rain_med_fast_neg_os" );
    level._effect["fx_mp_uplink_rain_med_fast_neg_os_vista"] = loadfx( "weather/fx_mp_uplink_rain_med_fast_neg_os_vista" );
    level._effect["fx_mp_upl_rain_gust_md"] = loadfx( "maps/mp_maps/fx_mp_upl_rain_gust_md" );
    level._effect["fx_mp_upl_rain_gust_lg"] = loadfx( "maps/mp_maps/fx_mp_upl_rain_gust_lg" );
    level._effect["fx_mp_upl_rain_gust_lg_neg"] = loadfx( "maps/mp_maps/fx_mp_upl_rain_gust_lg" );
    level._effect["fx_mp_upl_rain_gust_md_neg"] = loadfx( "maps/mp_maps/fx_mp_upl_rain_gust_md_neg" );
    level._effect["fx_mp_upl_rain_splash_50"] = loadfx( "maps/mp_maps/fx_mp_upl_rain_splash_50" );
    level._effect["fx_mp_upl_rain_splash_100"] = loadfx( "maps/mp_maps/fx_mp_upl_rain_splash_100" );
    level._effect["fx_mp_upl_rain_splash_200"] = loadfx( "maps/mp_maps/fx_mp_upl_rain_splash_200" );
    level._effect["fx_mp_upl_rain_splash_300"] = loadfx( "maps/mp_maps/fx_mp_upl_rain_splash_300" );
    level._effect["fx_mp_upl_rain_splash_400"] = loadfx( "maps/mp_maps/fx_mp_upl_rain_splash_400" );
    level._effect["fx_water_pipe_gutter_md"] = loadfx( "water/fx_water_pipe_gutter_md" );
    level._effect["fx_mp_water_roof_spill_lg_hvy"] = loadfx( "maps/mp_maps/fx_mp_water_roof_spill_lg_hvy" );
    level._effect["fx_mp_water_roof_spill_lg_hvy_lng"] = loadfx( "maps/mp_maps/fx_mp_water_roof_spill_lg_hvy_lng" );
    level._effect["fx_mp_water_roof_spill_md_hvy"] = loadfx( "maps/mp_maps/fx_mp_water_roof_spill_md_hvy" );
    level._effect["fx_mp_water_roof_spill_splash_shrt"] = loadfx( "maps/mp_maps/fx_mp_water_roof_spill_splash_shrt" );
    level._effect["fx_mp_water_roof_spill_splash_xshrt"] = loadfx( "maps/mp_maps/fx_mp_water_roof_spill_splash_xshrt" );
    level._effect["fx_mp_fog_cool_ground"] = loadfx( "maps/mp_maps/fx_mp_fog_cool_ground" );
    level._effect["fx_mp_distant_cloud_vista"] = loadfx( "maps/mp_maps/fx_mp_upl_distant_cloud_vista" );
    level._effect["fx_mp_uplink_lightning_lg"] = loadfx( "weather/fx_mp_uplink_lightning_lg" );
    level._effect["fx_mp_upl_window_rain1_splash"] = loadfx( "maps/mp_maps/fx_mp_upl_window_rain1_splash" );
    level._effect["fx_mp_uplink_rain_window_roof_med"] = loadfx( "weather/fx_mp_uplink_rain_window_roof_med" );
    level._effect["fx_mp_uplink_rain_window_gust"] = loadfx( "weather/fx_mp_uplink_rain_window_gust" );
    level._effect["fx_mp_upl_cloud_geo"] = loadfx( "maps/mp_maps/fx_mp_upl_cloud_geo" );
    level._effect["fx_lf_mp_uplink_sun1"] = loadfx( "lens_flares/fx_lf_mp_uplink_sun1" );
    level._effect["fx_lf_mp_uplink_anamorphic"] = loadfx( "lens_flares/fx_lf_mp_uplink_anamorphic" );
    level._effect["fx_lf_mp_uplink_anamorphic2"] = loadfx( "lens_flares/fx_lf_mp_uplink_anamorphic2" );
    level._effect["fx_mp_upl_rain_lit_corona"] = loadfx( "maps/mp_maps/fx_mp_upl_rain_lit_corona" );
    level._effect["fx_drone_rectangle_light"] = loadfx( "light/fx_light_flour_glow_yellow" );
    level._effect["fx_light_flour_glow_yellow_sm"] = loadfx( "light/fx_light_flour_glow_yellow_sm" );
    level._effect["fx_light_flour_glow_yellow_xsm"] = loadfx( "light/fx_light_flour_glow_yellow_xsm" );
    level._effect["fx_drone_rectangle_light_03"] = loadfx( "light/fx_drone_rectangle_light_03" );
    level._effect["fx_drone_rectangle_light_blue"] = loadfx( "maps/mp_maps/fx_mp_upl_rectangle_light_blue" );
    level._effect["fx_light_beacon_yellow"] = loadfx( "light/fx_light_beacon_yellow" );
    level._effect["fx_light_beacon_red_blink_fst"] = loadfx( "light/fx_light_beacon_red_blink_fst" );
    level._effect["fx_light_beacon_red_blink_fst_sm"] = loadfx( "light/fx_light_beacon_red_blink_fst_sm" );
    level._effect["fx_light_exit_sign"] = loadfx( "light/fx_light_exit_sign_gLow" );
    level._effect["fx_light_recessed_cool"] = loadfx( "maps/mp_maps/fx_mp_upl_light_recessed_cool" );
    level._effect["fx_light_recessed_blue"] = loadfx( "light/fx_light_recessed_blue" );
    level._effect["fx_light_window_glow"] = loadfx( "light/fx_light_window_glow" );
    level._effect["fx_mp_upl_window_ray_cool"] = loadfx( "maps/mp_maps/fx_mp_upl_window_ray_cool" );
    level._effect["fx_light_floodlight_sqr_wrm"] = loadfx( "maps/mp_maps/fx_mp_upl_floodlight_sqr_warm" );
    level._effect["fx_light_floodlight_sqr_cool"] = loadfx( "maps/mp_maps/fx_mp_upl_floodlight_sqr_cool" );
    level._effect["fx_light_floodlight_sqr_cool_thin"] = loadfx( "maps/mp_maps/fx_mp_upl_floodlight_sqr_cool_thin" );
    level._effect["fx_light_floodlight_sqr_cool_sm"] = loadfx( "maps/mp_maps/fx_mp_upl_floodlight_sqr_cool_sm" );
    level._effect["fx_light_floodlight_sqr_cool_md"] = loadfx( "maps/mp_maps/fx_mp_upl_floodlight_sqr_cool_md" );
    level._effect["fx_mp_upl_floodlight_yellow"] = loadfx( "maps/mp_maps/fx_mp_upl_floodlight_yellow" );
    level._effect["fx_upl_light_ray_sun_window_1s"] = loadfx( "light/fx_upl_light_ray_sun_window_1s" );
    level._effect["fx_upl_light_ray_sun_window_lg_1s"] = loadfx( "light/fx_upl_light_ray_sun_window_lg_1s" );
    level._effect["fx_mp_upl_generator_grays"] = loadfx( "maps/mp_maps/fx_mp_upl_generator_grays" );
    level._effect["fx_light_flour_glow_v_shape_cool_sm"] = loadfx( "light/fx_light_flour_glow_v_shape_cool_sm" );
    level._effect["fx_light_flour_glow_v_shape_cool"] = loadfx( "light/fx_light_upl_flour_glow_v_shape_cool" );
    level._effect["fx_light_gray_yllw_ribbon"] = loadfx( "light/fx_light_gray_yllw_ribbon" );
    level._effect["fx_light_gray_blue_ribbon"] = loadfx( "light/fx_light_gray_blue_ribbon" );
    level._effect["fx_mp_upl_waterfall01"] = loadfx( "maps/mp_maps/fx_mp_upl_waterfall01" );
    level._effect["fx_mp_upl_waterfall02"] = loadfx( "maps/mp_maps/fx_mp_upl_waterfall02" );
    level._effect["fx_mp_upl_waterfall_splash_bttm"] = loadfx( "maps/mp_maps/fx_mp_upl_waterfall_splash_bttm" );
    level._effect["fx_mp_upl_waterfall_splash_fst"] = loadfx( "maps/mp_maps/fx_mp_upl_waterfall_splash_fst" );
    level._effect["fx_mp_upl_waterfall_splash_md"] = loadfx( "maps/mp_maps/fx_mp_upl_waterfall_splash_md" );
    level._effect["fx_mp_upl_waterfall_vista"] = loadfx( "maps/mp_maps/fx_mp_upl_waterfall_vista" );
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["ant_rooftop"] = %fxanim_gp_antenna_rooftop_anim;
}

#using_animtree("fxanim_props_dlc3");

precache_fxanim_props_dlc3()
{
    level.scr_anim["fxanim_props_dlc3"]["uplink_gate"] = %fxanim_mp_uplink_gate_anim;
    level.scr_anim["fxanim_props_dlc3"]["uplink_gate_b"] = %fxanim_mp_uplink_gate_b_anim;
    level.scr_anim["fxanim_props_dlc3"]["cliff_sign"] = %fxanim_mp_uplink_cliff_sign_anim;
    level.scr_anim["fxanim_props_dlc3"]["radar01"] = %fxanim_mp_uplink_vista_radar01_anim;
    level.scr_anim["fxanim_props_dlc3"]["radar02"] = %fxanim_mp_uplink_vista_radar02_anim;
    level.scr_anim["fxanim_props_dlc3"]["radar03"] = %fxanim_mp_uplink_vista_radar03_anim;
    level.scr_anim["fxanim_props_dlc3"]["radar04"] = %fxanim_mp_uplink_vista_radar04_anim;
    level.scr_anim["fxanim_props_dlc3"]["radar05"] = %fxanim_mp_uplink_vista_radar05_anim;
    level.scr_anim["fxanim_props_dlc3"]["sat_dish2"] = %fxanim_gp_satellite_dish2_anim;
    level.scr_anim["fxanim_props_dlc3"]["ant_rooftop2_small"] = %fxanim_gp_antenna_rooftop2_small_anim;
    level.scr_anim["fxanim_props_dlc3"]["fence01"] = %fxanim_mp_uplink_fence01_anim;
    level.scr_anim["fxanim_props_dlc3"]["fence02"] = %fxanim_mp_uplink_fence02_anim;
    level.scr_anim["fxanim_props_dlc3"]["vines_01"] = %fxanim_mp_uplink_vines_01_anim;
    level.scr_anim["fxanim_props_dlc3"]["vines_02"] = %fxanim_mp_uplink_vines_02_anim;
}
