// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\createfx\mp_pod_fx;

main()
{
    precache_fxanim_props();
    precache_fxanim_props_dlc4();
    precache_scripted_fx();
    precache_createfx_fx();
    maps\mp\createfx\mp_pod_fx::main();
}

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_mp_pod_glass_drop_trail"] = loadfx( "maps/mp_maps/fx_mp_pod_glass_drop_trail" );
    level._effect["fx_mp_pod_glass_drop_runner"] = loadfx( "maps/mp_maps/fx_mp_pod_glass_drop_runner" );
    level._effect["fx_mp_pod_water_spill"] = loadfx( "maps/mp_maps/fx_mp_pod_water_spill" );
    level._effect["fx_mp_pod_water_spill_02"] = loadfx( "maps/mp_maps/fx_mp_pod_water_spill_02" );
    level._effect["fx_mp_pod_water_spill_splash"] = loadfx( "maps/mp_maps/fx_mp_pod_water_spill_splash" );
    level._effect["fx_mp_water_drip_light_shrt"] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_shrt" );
    level._effect["fx_mp_water_drip_light_long"] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_long" );
    level._effect["fx_mp_pod_water_drips"] = loadfx( "maps/mp_maps/fx_mp_pod_water_drips" );
    level._effect["fx_fog_drift_slow"] = loadfx( "fog/fx_fog_drift_slow" );
    level._effect["fx_fog_drift_slow_md"] = loadfx( "fog/fx_fog_drift_slow_md" );
    level._effect["fx_fog_drift_slow_sm"] = loadfx( "fog/fx_fog_drift_slow_sm" );
    level._effect["fx_fog_drift_slow_vista"] = loadfx( "fog/fx_fog_drift_slow_vista" );
    level._effect["fx_insects_swarm_md_light"] = loadfx( "bio/insects/fx_insects_swarm_md_light" );
    level._effect["fx_insects_swarm_lg_light"] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
    level._effect["fx_insects_fireflies_mp"] = loadfx( "bio/insects/fx_insects_fireflies_mp" );
    level._effect["fx_insects_flies_dragonflies"] = loadfx( "bio/insects/fx_insects_flies_dragonflies" );
    level._effect["fx_insects_roaches"] = loadfx( "bio/insects/fx_insects_roaches" );
    level._effect["fx_insects_roaches_fast"] = loadfx( "bio/insects/fx_insects_roaches_fast" );
    level._effect["fx_insects_roaches_short"] = loadfx( "bio/insects/fx_insects_roaches_short" );
    level._effect["fx_mp_light_dust_motes_md"] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
    level._effect["fx_lf_mp_pod_sun"] = loadfx( "lens_flares/fx_lf_mp_pod_sun" );
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim = [];
    level.scr_anim["fxanim_props"]["seagull_circle_01"] = %fxanim_gp_seagull_circle_01_anim;
    level.scr_anim["fxanim_props"]["seagull_circle_02"] = %fxanim_gp_seagull_circle_02_anim;
    level.scr_anim["fxanim_props"]["seagull_circle_03"] = %fxanim_gp_seagull_circle_03_anim;
    level.scr_anim["fxanim_props"]["sheet_med"] = %fxanim_gp_cloth_sheet_med_anim;
}

#using_animtree("fxanim_props_dlc4");

precache_fxanim_props_dlc4()
{
    level.scr_anim["fxanim_props_dlc4"]["wire_01"] = %fxanim_mp_pod_wire_01_anim;
    level.scr_anim["fxanim_props_dlc4"]["wire_02"] = %fxanim_mp_pod_wire_02_anim;
    level.scr_anim["fxanim_props_dlc4"]["wire_03"] = %fxanim_mp_pod_wire_03_anim;
    level.scr_anim["fxanim_props_dlc4"]["wire_04"] = %fxanim_mp_pod_wire_04_anim;
    level.scr_anim["fxanim_props_dlc4"]["wire_05"] = %fxanim_mp_pod_wire_05_anim;
    level.scr_anim["fxanim_props_dlc4"]["wire_06"] = %fxanim_mp_pod_wire_06_anim;
    level.scr_anim["fxanim_props_dlc4"]["wire_07"] = %fxanim_mp_pod_wire_07_anim;
    level.scr_anim["fxanim_props_dlc4"]["wire_08"] = %fxanim_mp_pod_wire_08_anim;
    level.scr_anim["fxanim_props_dlc4"]["wire_09"] = %fxanim_mp_pod_wire_09_anim;
    level.scr_anim["fxanim_props_dlc4"]["shirt03"] = %fxanim_gp_shirts03_anim;
    level.scr_anim["fxanim_props_dlc4"]["vine_clump_01"] = %fxanim_mp_pod_vine_clump_01_anim;
    level.scr_anim["fxanim_props_dlc4"]["vine_clump_02"] = %fxanim_mp_pod_vine_clump_02_anim;
    level.scr_anim["fxanim_props_dlc4"]["vine_clump_long"] = %fxanim_mp_pod_vine_clump_long_anim;
    level.scr_anim["fxanim_props_dlc4"]["vine_med_leafy"] = %fxanim_mp_pod_vine_med_leafy_anim;
    level.scr_anim["fxanim_props_dlc4"]["vine_med_bare"] = %fxanim_mp_pod_vine_med_bare_anim;
    level.scr_anim["fxanim_props_dlc4"]["vine_long_leafy"] = %fxanim_mp_pod_vine_long_leafy_anim;
    level.scr_anim["fxanim_props_dlc4"]["vine_long_bare"] = %fxanim_mp_pod_vine_long_bare_anim;
    level.scr_anim["fxanim_props_dlc4"]["bushy_clump_01"] = %fxanim_mp_pod_bushy_clump_01_anim;
    level.scr_anim["fxanim_props_dlc4"]["bushy_clump_02"] = %fxanim_mp_pod_bushy_clump_02_anim;
    level.scr_anim["fxanim_props_dlc4"]["vine_loops_pod"] = %fxanim_mp_pod_vine_loops_pod_anim;
    level.scr_anim["fxanim_props_dlc4"]["pool_wires"] = %fxanim_mp_pod_pool_wires_anim;
}
