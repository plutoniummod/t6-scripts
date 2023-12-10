// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\createfx\mp_village_fx;
#include clientscripts\mp\_fx;

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_mp_light_dust_motes_md"] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
    level._effect["fx_mp_express_train_blow_dust"] = loadfx( "maps/mp_maps/fx_mp_express_train_blow_dust" );
    level._effect["fx_mp_village_grass"] = loadfx( "maps/mp_maps/fx_mp_village_grass" );
    level._effect["fx_mp_village_papers"] = loadfx( "maps/mp_maps/fx_mp_village_papers" );
    level._effect["fx_mp_village_dust_sm"] = loadfx( "maps/mp_maps/fx_mp_village_dust_sm" );
    level._effect["fx_mp_village_dust_ceiling"] = loadfx( "maps/mp_maps/fx_mp_village_dust_ceiling" );
    level._effect["fx_insects_swarm_lg_light"] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
    level._effect["fx_mp_elec_spark_burst_md_runner"] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_md_runner" );
    level._effect["fx_mp_village_vista_dust"] = loadfx( "maps/mp_maps/fx_mp_village_vista_dust" );
    level._effect["fx_mp_village_smoke_fire_lg"] = loadfx( "maps/mp_maps/fx_mp_village_smoke_fire_lg" );
    level._effect["fx_mp_carrier_smoke_fire_sm"] = loadfx( "maps/mp_maps/fx_mp_carrier_smoke_fire_sm" );
    level._effect["fx_mp_village_smoke_fire_med"] = loadfx( "maps/mp_maps/fx_mp_village_smoke_fire_med" );
    level._effect["fx_mp_slums_fire_sm"] = loadfx( "maps/mp_maps/fx_mp_slums_fire_sm" );
    level._effect["fx_mp_village_barrel_fire"] = loadfx( "maps/mp_maps/fx_mp_village_barrel_fire" );
    level._effect["fx_mp_slums_dark_smoke_sm"] = loadfx( "maps/mp_maps/fx_mp_slums_dark_smoke_sm" );
    level._effect["fx_mp_village_smoke_tower"] = loadfx( "maps/mp_maps/fx_mp_village_smoke_tower" );
    level._effect["fx_mp_village_smoke_med"] = loadfx( "maps/mp_maps/fx_mp_village_smoke_med" );
    level._effect["fx_mp_village_smoke_xsm"] = loadfx( "maps/mp_maps/fx_mp_village_smoke_xsm" );
    level._effect["fx_mp_smoke_vista"] = loadfx( "maps/mp_maps/fx_mp_smoke_vista" );
    level._effect["fx_smk_tin_hat_sm"] = loadfx( "smoke/fx_smk_tin_hat_sm" );
    level._effect["fx_mp_village_single_glare"] = loadfx( "maps/mp_maps/fx_mp_village_single_glare" );
    level._effect["fx_window_god_ray"] = loadfx( "light/fx_window_god_ray" );
    level._effect["fx_window_god_ray_village"] = loadfx( "light/fx_window_god_ray_village" );
    level._effect["fx_window_god_ray_sm"] = loadfx( "light/fx_window_god_ray_sm" );
    level._effect["fx_drone_rectangle_light_03"] = loadfx( "light/fx_drone_rectangle_light_03" );
    level._effect["fx_village_tube_light"] = loadfx( "light/fx_village_tube_light" );
    level._effect["fx_village_tube_light_sq"] = loadfx( "light/fx_village_tube_light_sq" );
    level._effect["fx_village_rectangle_light_01"] = loadfx( "light/fx_village_rectangle_light_01" );
    level._effect["fx_mp_village_hole_god_ray"] = loadfx( "maps/mp_maps/fx_mp_village_hole_god_ray" );
    level._effect["fx_mp_village_statue_water"] = loadfx( "maps/mp_maps/fx_mp_village_statue_water" );
    level._effect["fx_lf_mp_village_sun1"] = loadfx( "lens_flares/fx_lf_mp_village_sun1" );
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["sparking_wires_med"] = %fxanim_gp_wirespark_med_anim;
    level.scr_anim["fxanim_props"]["windsock"] = %fxanim_gp_windsock_anim;
    level.scr_anim["fxanim_props"]["wire_coil_01"] = %fxanim_gp_wire_coil_01_anim;
    level.scr_anim["fxanim_props"]["sign_sway_lrg"] = %fxanim_gp_sign_sway_lrg_anim;
}

main()
{
    clientscripts\mp\createfx\mp_village_fx::main();
    clientscripts\mp\_fx::reportnumeffects();
    precache_createfx_fx();
    precache_fxanim_props();
    disablefx = getdvarint( _hash_C9B177D6 );

    if ( !isdefined( disablefx ) || disablefx <= 0 )
        precache_scripted_fx();
}
