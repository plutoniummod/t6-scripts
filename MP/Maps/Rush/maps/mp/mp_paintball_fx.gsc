// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\createfx\mp_paintball_fx;

main()
{
    precache_fxanim_props();
    precache_fxanim_props_dlc3();
    precache_scripted_fx();
    precache_createfx_fx();
    maps\mp\createfx\mp_paintball_fx::main();
}

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_pntbll_light_ray_sun_wide_wndw"] = loadfx( "light/fx_pntbll_light_ray_sun_wide_wndw" );
    level._effect["fx_pntbll_light_ray_sun_md_lng"] = loadfx( "light/fx_pntbll_light_ray_sun_md_lng" );
    level._effect["fx_pntbll_light_ray_sun_md_lng_1s"] = loadfx( "light/fx_pntbll_light_ray_sun_md_lng_1s" );
    level._effect["fx_pntbll_light_ray_sun_md_xlng_1s"] = loadfx( "light/fx_pntbll_light_ray_sun_md_xlng_1s" );
    level._effect["fx_pntbll_light_ray_sun_md_lng_wd_1s"] = loadfx( "light/fx_pntbll_light_ray_sun_md_lng_wd_1s" );
    level._effect["fx_pntbll_light_ray_sun_md_lng_wd"] = loadfx( "light/fx_pntbll_light_ray_sun_md_lng_wd" );
    level._effect["fx_pntbll_light_ray_sun_lg_lng_wide"] = loadfx( "light/fx_pntbll_light_ray_sun_lg_lng_wide" );
    level._effect["fx_pntbll_light_ray_sun_lg_lng_wide_ln"] = loadfx( "light/fx_pntbll_light_ray_sun_lg_lng_wide_ln" );
    level._effect["fx_pntbll_light_ray_sun_md_lng_bright"] = loadfx( "light/fx_pntbll_light_ray_sun_md_lng_bright" );
    level._effect["fx_pntbll_light_ray_tree_md_lng"] = loadfx( "light/fx_pntbll_light_ray_tree_md_lng" );
    level._effect["fx_pntbll_light_ray_tree_md_lng_thin"] = loadfx( "light/fx_pntbll_light_ray_tree_md_lng_thin" );
    level._effect["fx_pntbll_light_ray_tree_md_xlng_thin"] = loadfx( "light/fx_pntbll_light_ray_tree_md_xlng_thin" );
    level._effect["fx_pntbll_light_ray_camo_net_md"] = loadfx( "light/fx_pntbll_light_ray_camo_net_md" );
    level._effect["fx_pntbll_light_ray_camo_net_lng_dim"] = loadfx( "light/fx_pntbll_light_ray_camo_net_lng_dim" );
    level._effect["fx_pntbll_light_ray_shop_md_lng_thin"] = loadfx( "light/fx_pntbll_light_ray_shop_md_lng_thin" );
    level._effect["fx_pntbll_light_ray_shop_md_lng_dim"] = loadfx( "light/fx_pntbll_light_ray_shop_md_lng_dim" );
    level._effect["fx_pntbll_light_ray_shop_md_lng_wide"] = loadfx( "light/fx_pntbll_light_ray_shop_md_lng_wide" );
    level._effect["fx_light_flour_glow_yellow"] = loadfx( "light/fx_light_flour_glow_yellow" );
    level._effect["fx_mp_light_dust_motes_md"] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
    level._effect["fx_light_dust_motes_xsm_short"] = loadfx( "light/fx_concert_dust_motes_xsm_short" );
    level._effect["fx_light_dust_motes_sm"] = loadfx( "light/fx_light_dust_motes_sm" );
    level._effect["fx_dust_motes_blowing_sm"] = loadfx( "debris/fx_dust_motes_blowing_sm" );
    level._effect["fx_insects_swarm_md_light"] = loadfx( "bio/insects/fx_insects_swarm_md_light" );
    level._effect["fx_insects_swarm_lg_light"] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
    level._effect["fx_mp_pntbll_steam_thck_md"] = loadfx( "maps/mp_maps/fx_mp_pntbll_steam_thck_md" );
    level._effect["fx_mp_pntbll_steam_thck_sm"] = loadfx( "maps/mp_maps/fx_mp_pntbll_steam_thck_sm" );
    level._effect["fx_mp_pntbll_steam_thck_xsm"] = loadfx( "maps/mp_maps/fx_mp_pntbll_steam_thck_xsm" );
    level._effect["fx_mp_pntbll_steam_thck_gray"] = loadfx( "maps/mp_maps/fx_mp_pntbll_steam_thck_gray" );
    level._effect["fx_mp_steam_vent_ceiling"] = loadfx( "maps/mp_maps/fx_mp_steam_vent_ceiling" );
    level._effect["fx_mp_steam_vent_ceiling_lg"] = loadfx( "maps/mp_maps/fx_mp_steam_vent_ceiling_lg" );
    level._effect["fx_mp_vent_steam_lite_wind"] = loadfx( "maps/mp_maps/fx_mp_vent_steam_lite_wind" );
    level._effect["fx_mp_pntbll_smk_truck_md"] = loadfx( "maps/mp_maps/fx_mp_pntbll_smk_truck_md" );
    level._effect["fx_mp_pntbll_smk_truck_sm"] = loadfx( "maps/mp_maps/fx_mp_pntbll_smk_truck_sm" );
    level._effect["fx_leaves_falling_pine_nowind"] = loadfx( "foliage/fx_leaves_falling_pine_nowind" );
    level._effect["fx_mp_light_police_car"] = loadfx( "maps/mp_maps/fx_mp_light_police_car" );
    level._effect["fx_light_stadium_flood"] = loadfx( "light/fx_light_stadium_flood" );
    level._effect["fx_light_stadium_flood_flckr"] = loadfx( "light/fx_light_stadium_flood_flckr" );
    level._effect["fx_light_recessed_cool_sm_soft"] = loadfx( "light/fx_light_recessed_cool_sm_soft" );
    level._effect["fx_light_track_omni"] = loadfx( "light/fx_light_track_omni" );
    level._effect["fx_mp_pntbll_paint_drips"] = loadfx( "maps/mp_maps/fx_mp_pntbll_paint_drips" );
    level._effect["fx_lf_mp_paintball_sun1"] = loadfx( "lens_flares/fx_lf_mp_paintball_sun1" );
    level._effect["fx_mp_light_police_car"] = loadfx( "maps/mp_maps/fx_mp_light_police_car" );
}

precache_fxanim_props()
{
    level.scr_anim = [];
    level.scr_anim["fxanim_props"] = [];
}

#using_animtree("fxanim_props_dlc3");

precache_fxanim_props_dlc3()
{
    level.scr_anim["fxanim_props_dlc3"]["wires_01"] = %fxanim_mp_paint_wires_01_anim;
    level.scr_anim["fxanim_props_dlc3"]["wires_02"] = %fxanim_mp_paint_wires_02_anim;
    level.scr_anim["fxanim_props_dlc3"]["shop_banners"] = %fxanim_paint_shop_banner_01_anim;
    level.scr_anim["fxanim_props_dlc3"]["shop_banners_wall"] = %fxanim_paint_shop_banner_02_anim;
    level.scr_anim["fxanim_props_dlc3"]["wires_03"] = %fxanim_mp_paint_wires_03_anim;
}
