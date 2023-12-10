// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_fxanim_dlc;
#include clientscripts\mp\createfx\mp_magma_fx;
#include clientscripts\mp\_fx;

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_mp_magma_ash_ember_lg"] = loadfx( "maps/mp_maps/fx_mp_magma_ash_ember_lg" );
    level._effect["fx_mp_magma_ash_ember_detail"] = loadfx( "maps/mp_maps/fx_mp_magma_ash_ember_detail" );
    level._effect["fx_mp_magma_ash_ember_door"] = loadfx( "maps/mp_maps/fx_mp_magma_ash_ember_door" );
    level._effect["fx_mp_magma_ash_int"] = loadfx( "maps/mp_maps/fx_mp_magma_ash_int" );
    level._effect["fx_mp_magma_ash_ground"] = loadfx( "maps/mp_maps/fx_mp_magma_ash_ground" );
    level._effect["fx_mp_magma_lava_edge_fire_100"] = loadfx( "maps/mp_maps/fx_mp_magma_lava_edge_fire_100" );
    level._effect["fx_mp_magma_lava_edge_fire_200_dist"] = loadfx( "maps/mp_maps/fx_mp_magma_lava_edge_fire_200_dist" );
    level._effect["fx_mp_magma_lava_edge_fire_50"] = loadfx( "maps/mp_maps/fx_mp_magma_lava_edge_fire_50" );
    level._effect["fx_mp_magma_ball_falling_sky"] = loadfx( "maps/mp_maps/fx_mp_magma_ball_falling_sky" );
    level._effect["fx_mp_magma_ball_falling_sky_wall"] = loadfx( "maps/mp_maps/fx_mp_magma_ball_falling_sky_wall" );
    level._effect["fx_mp_magma_ball_falling_tunnel"] = loadfx( "maps/mp_maps/fx_mp_magma_ball_falling_tunnel" );
    level._effect["fx_mp_magma_ball_falling_vista"] = loadfx( "maps/mp_maps/fx_mp_magma_ball_falling_vista" );
    level._effect["fx_mp_magma_splat_wall_fire"] = loadfx( "maps/mp_maps/fx_mp_magma_splat_wall_fire" );
    level._effect["fx_mp_magma_splat_grnd_fire"] = loadfx( "maps/mp_maps/fx_mp_magma_splat_grnd_fire" );
    level._effect["fx_mp_magma_volcano_smoke"] = loadfx( "maps/mp_maps/fx_mp_magma_volcano_smoke" );
    level._effect["fx_mp_magma_volcano_erupt"] = loadfx( "maps/mp_maps/fx_mp_magma_volcano_erupt" );
    level._effect["fx_mp_magma_distort_geo_lg"] = loadfx( "maps/mp_maps/fx_mp_magma_distort_geo_lg" );
    level._effect["fx_mp_magma_distort_geo_md"] = loadfx( "maps/mp_maps/fx_mp_magma_distort_geo_md" );
    level._effect["fx_mp_magma_distort_geo_sm"] = loadfx( "maps/mp_maps/fx_mp_magma_distort_geo_sm" );
    level._effect["fx_mp_magma_fire_med"] = loadfx( "maps/mp_maps/fx_mp_magma_fire_med" );
    level._effect["fx_mp_magma_fire_lg"] = loadfx( "maps/mp_maps/fx_mp_magma_fire_lg" );
    level._effect["fx_mp_magma_fire_xlg"] = loadfx( "maps/mp_maps/fx_mp_magma_fire_xlg" );
    level._effect["fx_mp_elec_spark_burst_xsm_thin"] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin" );
    level._effect["fx_mp_elec_spark_burst_xsm_thin_runner"] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin_runner" );
    level._effect["fx_mp_elec_spark_burst_md_runner"] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_md_runner" );
    level._effect["fx_mp_magma_smk_whisp"] = loadfx( "maps/mp_maps/fx_mp_magma_smk_whisp" );
    level._effect["fx_mp_magma_smk_smolder"] = loadfx( "maps/mp_maps/fx_mp_magma_smk_smolder" );
    level._effect["fx_mp_magma_smk_smolder_med"] = loadfx( "maps/mp_maps/fx_mp_magma_smk_smolder_med" );
    level._effect["fx_mp_magma_smk_smolder_low"] = loadfx( "maps/mp_maps/fx_mp_magma_smk_smolder_low" );
    level._effect["fx_mp_magma_smk_plume_md_vista"] = loadfx( "maps/mp_maps/fx_mp_magma_smk_plume_md_vista" );
    level._effect["fx_mp_magma_smk_smolder_vista"] = loadfx( "maps/mp_maps/fx_mp_magma_smk_smolder_vista" );
    level._effect["fx_mp_magma_smk_smolder_vista_lt"] = loadfx( "maps/mp_maps/fx_mp_magma_smk_smolder_vista_lt" );
    level._effect["fx_mp_magma_steam_ocean"] = loadfx( "maps/mp_maps/fx_mp_magma_steam_ocean" );
    level._effect["fx_mp_magma_steam_ocean_cool"] = loadfx( "maps/mp_maps/fx_mp_magma_steam_ocean_cool" );
    level._effect["fx_mp_magma_steam_ocean_md"] = loadfx( "maps/mp_maps/fx_mp_magma_steam_ocean_md" );
    level._effect["fx_mp_magma_smk_steam_vista"] = loadfx( "maps/mp_maps/fx_mp_magma_smk_steam_vista" );
    level._effect["fx_mp_magma_steam_fish"] = loadfx( "maps/mp_maps/fx_mp_magma_steam_fish" );
    level._effect["fx_mp_magma_steam_vent_w"] = loadfx( "maps/mp_maps/fx_mp_magma_steam_vent_w" );
    level._effect["fx_mp_magma_steam_vent_int"] = loadfx( "maps/mp_maps/fx_mp_magma_steam_vent_int" );
    level._effect["fx_mp_magma_smk_volcano_sm"] = loadfx( "maps/mp_maps/fx_mp_magma_smk_volcano_sm" );
    level._effect["fx_lf_mp_magma_sun1"] = loadfx( "lens_flares/fx_lf_mp_magma_sun1" );
    level._effect["fx_lf_mp_magma_volcano"] = loadfx( "lens_flares/fx_lf_mp_magma_volcano" );
    level._effect["fx_mp_distant_cloud_vista_lg"] = loadfx( "maps/mp_maps/fx_mp_magma_volcano_fog" );
    level._effect["fx_drone_light_yellow"] = loadfx( "light/fx_drone_light_yellow" );
    level._effect["fx_light_mag_ceiling_light"] = loadfx( "light/fx_light_mag_ceiling_light" );
    level._effect["fx_light_recessed_cool_sm_soft"] = loadfx( "light/fx_light_recessed_cool_sm_soft" );
    level._effect["fx_light_streetlight_glow_cool"] = loadfx( "light/fx_light_streetlight_glow_cool" );
    level._effect["fx_mp_light_police_car_japan"] = loadfx( "maps/mp_maps/fx_mp_light_police_car_japan" );
    level._effect["fx_light_stair_blue"] = loadfx( "light/fx_light_stair_blue" );
    level._effect["fx_mp_magma_light_bench_blue"] = loadfx( "maps/mp_maps/fx_mp_magma_light_bench_blue" );
    level._effect["fx_light_recessed_purple"] = loadfx( "light/fx_light_recessed_purple" );
    level._effect["fx_mp_magma_light_recessed_flat"] = loadfx( "maps/mp_maps/fx_mp_magma_light_recessed_flat" );
    level._effect["fx_light_flour_glow_v_shape_cool"] = loadfx( "light/fx_light_flour_glow_v_shape_cool" );
    level._effect["fx_mp_magma_vending_machine_lg"] = loadfx( "maps/mp_maps/fx_mp_magma_vending_machine_lg" );
    level._effect["fx_mp_magma_vending_machine_med"] = loadfx( "maps/mp_maps/fx_mp_magma_vending_machine_med" );
    level._effect["fx_mp_magma_toilet_sign"] = loadfx( "maps/mp_maps/fx_mp_magma_toilet_sign" );
    level._effect["fx_mp_magma_track_light"] = loadfx( "maps/mp_maps/fx_mp_magma_track_light" );
    level._effect["fx_fire_torso"] = loadfx( "fire/fx_fire_ai_torso_magma" );
    level._effect["fx_fire_arm_left"] = loadfx( "fire/fx_fire_ai_arm_left_magma" );
    level._effect["fx_fire_arm_right"] = loadfx( "fire/fx_fire_ai_arm_right_magma" );
    level._effect["fx_fire_leg_left"] = loadfx( "fire/fx_fire_ai_leg_left_magma" );
    level._effect["fx_fire_leg_right"] = loadfx( "fire/fx_fire_ai_leg_right_magma" );
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["sparking_wires_med"] = %fxanim_gp_wirespark_med_anim;
    level.scr_anim["fxanim_props"]["sparking_wires_long"] = %fxanim_gp_wirespark_long_anim;
    level.scr_anim["fxanim_props"]["japan_sign_square"] = %fxanim_mp_magma_japan_sign_square_anim;
    level.scr_anim["fxanim_props"]["squid_sign_eyes_01"] = %fxanim_mp_magma_squid_sign_eyes_01_anim;
    level.scr_anim["fxanim_props"]["squid_sign_eyes_02"] = %fxanim_mp_magma_squid_sign_eyes_02_anim;
    level.scr_anim["fxanim_props"]["japan_sign_fish"] = %fxanim_mp_magma_japan_sign_fish_anim;
}

#using_animtree("fxanim_props_dlc");

precache_fxanim_props_dlc()
{
    level.scr_anim["fxanim_props_dlc"]["hanging_lantern_01"] = %fxanim_mp_magma_hanging_lantern_01_anim;
    level.scr_anim["fxanim_props_dlc"]["hanging_lantern_02"] = %fxanim_mp_magma_hanging_lantern_02_anim;
    level.scr_anim["fxanim_props_dlc"]["train_wire_01"] = %fxanim_mp_magma_train_wire_01_anim;
    level.scr_anim["fxanim_props_dlc"]["train_wire_02"] = %fxanim_mp_magma_train_wire_02_anim;
    level.scr_anim["fxanim_props_dlc"]["train_wire_03"] = %fxanim_mp_magma_train_wire_03_anim;
    level.scr_anim["fxanim_props_dlc"]["sushi_conveyor"] = %fxanim_mp_magma_sushi_conveyor_anim;
    level.fx_anim_level_init = clientscripts\mp\_fxanim_dlc::fxanim_init_dlc;
    level.fx_anim_level_dlc_init = ::fxanim_level_init;
}

main()
{
    clientscripts\mp\createfx\mp_magma_fx::main();
    clientscripts\mp\_fx::reportnumeffects();
    precache_createfx_fx();
    precache_fxanim_props();
    precache_fxanim_props_dlc();
    disablefx = getdvarint( _hash_C9B177D6 );

    if ( !isdefined( disablefx ) || disablefx <= 0 )
        precache_scripted_fx();
}

fxanim_level_init( localclientnum )
{
    fxanims = getentarray( localclientnum, "fxanim_level", "targetname" );

    if ( !isdefined( level.fxanim_waits ) )
    {
        level.fxanim_waits = [];
        level.fxanim_speeds = [];

        for ( i = 0; i < fxanims.size; i++ )
        {
            level.fxanim_waits[i] = randomfloatrange( 0.1, 1.5 );
            level.fxanim_speeds[i] = randomfloatrange( 0.75, 1.4 );
        }
    }

    for ( i = 0; i < fxanims.size; i++ )
    {
        assert( isdefined( fxanims[i].fxanim_scene_1 ) );

        switch ( fxanims[i].fxanim_scene_1 )
        {
            case "sparking_wires_med":
                fxanims[i] thread fxanim_wire_think( localclientnum, i, "med_spark_06_jnt" );
                break;
            case "sparking_wires_long":
                fxanims[i] thread fxanim_wire_think( localclientnum, i, "long_spark_06_jnt" );
                break;
        }
    }
}

#using_animtree("fxanim_props");

fxanim_wire_think( localclientnum, index, bone )
{
    self endon( "death" );
    self endon( "entityshutdown" );
    self endon( "delete" );
    self waittill_dobj( localclientnum );
    self useanimtree( #animtree );
    wait( level.fxanim_waits[index] );
    self setflaggedanim( "wire_fx", level.scr_anim["fxanim_props"][self.fxanim_scene_1], 1.0, 0.0, level.fxanim_speeds[index] );

    for (;;)
    {
        self waittill( "wire_fx", note );

        playfxontag( localclientnum, level._effect["fx_mp_elec_spark_burst_xsm_thin"], self, bone );
    }
}
