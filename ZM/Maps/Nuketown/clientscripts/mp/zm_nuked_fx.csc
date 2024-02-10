// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\createfx\zm_nuked_fx;
#include clientscripts\mp\_fx;

precache_util_fx()
{

}

precache_scripted_fx()
{
    level._effect["eye_glow"] = loadfx( "misc/fx_zombie_eye_single" );
    level._effect["blue_eyes"] = loadfx( "maps/zombie/fx_zombie_eye_single_blue" );
    level._effect["headshot"] = loadfx( "impacts/fx_flesh_hit" );
    level._effect["headshot_nochunks"] = loadfx( "misc/fx_zombie_bloodsplat" );
    level._effect["bloodspurt"] = loadfx( "misc/fx_zombie_bloodspurt" );
    level._effect["animscript_gib_fx"] = loadfx( "weapon/bullet/fx_flesh_gib_fatal_01" );
    level._effect["animscript_gibtrail_fx"] = loadfx( "trail/fx_trail_blood_streak" );
    level._effect["fire_devil_lg"] = loadfx( "maps/zombie/fx_zmb_fire_devil_lg" );
    level._effect["fire_devil_sm"] = loadfx( "maps/zombie/fx_zmb_fire_devil_sm" );
    level._effect["perk_meteor"] = loadfx( "maps/zombie/fx_zmb_trail_perk_meteor" );
    level._effect["fx_mp_elec_spark_burst_xsm_thin"] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin" );
    level._effect["wire_spark"] = loadfx( "electrical/fx_elec_wire_spark_burst_xsm" );
}

precache_createfx_fx()
{
    level._effect["fx_zm_nuked_exp_perk_impact_int_shockwave"] = loadfx( "explosions/fx_zm_nuked_exp_perk_impact_int_shockwave" );
    level._effect["fx_zm_nuked_exp_perk_impact_int"] = loadfx( "explosions/fx_zm_nuked_exp_perk_impact_int" );
    level._effect["fx_zm_nuked_exp_perk_impact_ext"] = loadfx( "explosions/fx_zm_nuked_exp_perk_impact_ext" );
    level._effect["fx_zm_nuked_perk_impact_ceiling_dust"] = loadfx( "dirt/fx_zm_nuked_perk_impact_ceiling_dust" );
    level._effect["fx_lf_zmb_nuke_sun"] = loadfx( "lens_flares/fx_lf_zmb_nuke_sun" );
    level._effect["fx_zm_nuked_water_stream_radioactive_thin"] = loadfx( "water/fx_zm_nuked_water_drip_radioactive" );
    level._effect["fx_zm_nuked_water_stream_radioactive_spatter"] = loadfx( "water/fx_zm_nuked_water_drip_radioactive_spatter" );
    level._effect["fx_zmb_nuke_nuclear_lightning_runner"] = loadfx( "maps/zombie/fx_zmb_nuke_nuclear_lightning_runner" );
    level._effect["fx_zmb_nuke_radioactive_embers_crater"] = loadfx( "maps/zombie/fx_zmb_nuke_radioactive_embers_crater" );
    level._effect["fx_zmb_nuke_radioactive_embers"] = loadfx( "maps/zombie/fx_zmb_nuke_radioactive_embers" );
    level._effect["fx_zmb_nuke_linger_core"] = loadfx( "maps/zombie/fx_zmb_nuke_linger_core" );
    level._effect["fx_zmb_nuke_sand_blowing_lg"] = loadfx( "maps/zombie/fx_zmb_nuke_sand_blowing_lg" );
    level._effect["fx_zmb_nuke_debris_streamer_volume"] = loadfx( "maps/zombie/fx_zmb_nuke_debris_streamer_volume" );
    level._effect["fx_zmb_nuke_burning_ash_gusty"] = loadfx( "maps/zombie/fx_zmb_nuke_burning_ash_gusty" );
    level._effect["fx_zmb_nuke_radioactive_ash_gusty"] = loadfx( "maps/zombie/fx_zmb_nuke_radioactive_ash_gusty" );
    level._effect["fx_zmb_nuke_sand_windy_hvy_md"] = loadfx( "maps/zombie/fx_zmb_nuke_sand_windy_hvy_md" );
    level._effect["fx_zmb_nuke_sand_windy_hvy_sm"] = loadfx( "maps/zombie/fx_zmb_nuke_sand_windy_hvy_sm" );
    level._effect["fx_embers_falling_md"] = loadfx( "env/fire/fx_embers_falling_md" );
    level._effect["fx_embers_falling_sm"] = loadfx( "env/fire/fx_embers_falling_sm" );
    level._effect["fx_ash_embers_falling_radioactive_md"] = loadfx( "debris/fx_ash_embers_falling_radioactive_md" );
    level._effect["fx_ash_embers_falling_radioactive_sm"] = loadfx( "debris/fx_ash_embers_falling_radioactive_sm" );
    level._effect["fx_mp_elec_spark_burst_xsm_thin_runner"] = loadfx( "maps/mp_maps/fx_mp_elec_spark_burst_xsm_thin_runner" );
    level._effect["fx_elec_spark_wire_xsm_runner"] = loadfx( "electrical/fx_elec_spark_wire_xsm_runner" );
    level._effect["fx_zm_elec_arc_vert"] = loadfx( "electrical/fx_zm_elec_arc_vert" );
    level._effect["fx_elec_transformer_sparks_runner"] = loadfx( "electrical/fx_elec_transformer_sparks_runner" );
    level._effect["fx_zmb_nuke_fire_windblown_md"] = loadfx( "fire/fx_zmb_nuke_fire_windblown_md" );
    level._effect["fx_fire_xsm"] = loadfx( "fire/fx_fire_xsm_no_flicker" );
    level._effect["fx_fire_line_xsm"] = loadfx( "fire/fx_fire_line_xsm_no_flicker" );
    level._effect["fx_fire_sm_smolder"] = loadfx( "fire/fx_zm_fire_sm_smolder_near" );
    level._effect["fx_fire_line_sm"] = loadfx( "fire/fx_nic_fire_line_sm" );
    level._effect["fx_fire_wall_wood_ext_md"] = loadfx( "fire/fx_fire_wall_wood_ext_md" );
    level._effect["fx_fire_ceiling_md"] = loadfx( "fire/fx_nic_fire_ceiling_md" );
    level._effect["fx_fire_ceiling_edge_md"] = loadfx( "fire/fx_nic_fire_ceiling_edge_md" );
    level._effect["fx_nic_fire_ceiling_edge_sm"] = loadfx( "fire/fx_nic_fire_ceiling_edge_sm" );
    level._effect["fx_nic_fire_building_md_dist"] = loadfx( "fire/fx_nic_fire_building_md_dist" );
    level._effect["fx_fire_fireplace_md"] = loadfx( "fire/fx_fire_fireplace_md" );
    level._effect["fx_fire_wood_floor_int"] = loadfx( "fire/fx_fire_wood_floor_int" );
    level._effect["fx_fire_ceiling_rafter_md"] = loadfx( "fire/fx_nic_fire_ceiling_rafter_md" );
    level._effect["fx_fire_eaves_md"] = loadfx( "fire/fx_nic_fire_eaves_md" );
    level._effect["fx_fire_eaves_md_left"] = loadfx( "fire/fx_nic_fire_eaves_md_left" );
    level._effect["fx_fire_eaves_md_right"] = loadfx( "fire/fx_nic_fire_eaves_md_right" );
    level._effect["fx_fire_line_xsm_pole"] = loadfx( "fire/fx_nic_fire_line_xsm_pole" );
    level._effect["fx_fire_line_sm_pole"] = loadfx( "fire/fx_nic_fire_line_sm_pole" );
    level._effect["fx_fire_pole_md_long"] = loadfx( "fire/fx_nic_fire_pole_md_long" );
    level._effect["fx_fire_smolder_area_sm"] = loadfx( "fire/fx_fire_smolder_area_sm" );
    level._effect["fx_smk_wood_sm_black"] = loadfx( "smoke/fx_smk_wood_sm_black" );
    level._effect["fx_smk_fire_lg_black"] = loadfx( "smoke/fx_smk_fire_lg_black" );
    level._effect["fx_smk_plume_md_blk_wispy_dist"] = loadfx( "smoke/fx_smk_plume_md_blk_wispy_dist" );
    level._effect["fx_smk_smolder_rubble_md_int"] = loadfx( "smoke/fx_smk_smolder_rubble_md_int_cheap" );
    level._effect["fx_smk_hallway_md_dark"] = loadfx( "smoke/fx_smk_hallway_md_dark" );
    level._effect["fx_smk_linger_lit"] = loadfx( "smoke/fx_smk_linger_lit" );
    level._effect["fx_smk_linger_lit_slow"] = loadfx( "smoke/fx_smk_linger_lit_slow" );
    level._effect["fx_smk_linger_lit_slow_bright"] = loadfx( "smoke/fx_smk_linger_lit_slow_bright" );
    level._effect["fx_smk_linger_lit_z"] = loadfx( "smoke/fx_smk_linger_lit_z" );
    level._effect["fx_smk_smolder_gray_fast"] = loadfx( "smoke/fx_smk_smolder_gray_fast" );
    level._effect["fx_smk_smolder_gray_slow"] = loadfx( "smoke/fx_smk_smolder_gray_slow" );
    level._effect["fx_zmb_fog_low_radiation_140x300"] = loadfx( "fog/fx_zmb_fog_low_radiation_140x300" );
    level._effect["fx_zm_nuked_light_ray_md_wide"] = loadfx( "light/fx_zm_nuked_light_ray_md_wide" );
    level._effect["fx_zm_nuked_light_ray_md_wide_streak"] = loadfx( "light/fx_zm_nuked_light_ray_md_wide_streak" );
    level._effect["fx_light_ray_grate_warm"] = loadfx( "light/fx_zm_nuked_light_ray_streaks" );
    level._effect["fx_light_flour_glow_cool_sngl_shrt"] = loadfx( "light/fx_light_flour_glow_cool_sngl_shrt" );
    level._effect["fx_zm_nuked_light_ray_streaks_1s"] = loadfx( "light/fx_zm_nuked_light_ray_streaks_1s" );
    level._effect["fx_zm_nuked_light_ray_md_wide_streak_1s"] = loadfx( "light/fx_zm_nuked_light_ray_md_wide_streak_1s" );
    level._effect["fx_mp_nuked_hose_spray"] = loadfx( "maps/mp_maps/fx_mp_nuked_hose_spray" );
    level._effect["fx_ash_embers_up_lg"] = loadfx( "debris/fx_ash_embers_up_lg" );
    level._effect["fx_ash_burning_falling_interior"] = loadfx( "debris/fx_ash_burning_falling_interior" );
    level._effect["fx_zmb_nuke_fire_med"] = loadfx( "maps/zombie/fx_zmb_nuke_fire_med" );
    level._effect["fx_zmb_tranzit_fire_lrg"] = loadfx( "maps/zombie/fx_zmb_tranzit_fire_lrg" );
    level._effect["fx_zmb_tranzit_fire_med"] = loadfx( "maps/zombie/fx_zmb_tranzit_fire_med" );
    level._effect["fx_cloud_cover_volume"] = loadfx( "maps/zombie/fx_zmb_nuke_cloud_cover_volume" );
    level._effect["fx_cloud_cover_volume_sm"] = loadfx( "maps/zombie/fx_zmb_nuke_cloud_cover_volume_sm" );
    level._effect["fx_cloud_cover_flat"] = loadfx( "maps/zombie/fx_zmb_nuke_cloud_cover_flat" );
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["pant01_fast"] = %fxanim_gp_pant01_fast_anim;
    level.scr_anim["fxanim_props"]["shirt01_fast"] = %fxanim_gp_shirt01_fast_anim;
    level.scr_anim["fxanim_props"]["sheet_med"] = %fxanim_gp_cloth_sheet_med_fast_anim;
    level.scr_anim["fxanim_props"]["wirespark_long"] = %fxanim_gp_wirespark_long_anim;
    level.scr_anim["fxanim_props"]["wirespark_med"] = %fxanim_gp_wirespark_med_anim;
    level.scr_anim["fxanim_props"]["roaches"] = %fxanim_gp_roaches_anim;
    level.scr_anim["fxanim_props"]["wht_shutters"] = %fxanim_zom_nuketown_shutters_anim;
    level.scr_anim["fxanim_props"]["wht_shutters02"] = %fxanim_zom_nuketown_shutters02_anim;
    level.scr_anim["fxanim_props"]["win_curtains"] = %fxanim_zom_curtains_anim;
    level.scr_anim["fxanim_props"]["cabinets_brwn"] = %fxanim_zom_nuketown_cabinets_brwn_anim;
    level.scr_anim["fxanim_props"]["cabinets_brwn02"] = %fxanim_zom_nuketown_cabinets_brwn02_anim;
    level.scr_anim["fxanim_props"]["cabinets_red"] = %fxanim_zom_nuketown_cabinets_red_anim;
    level.scr_anim["fxanim_props"]["porch"] = %fxanim_zom_nuketown_porch_anim;
    level.scr_anim["fxanim_props"]["roofvent"] = %fxanim_gp_roofvent_small_wobble_anim;
    level.nuked_fxanims = [];
    level.nuked_fxanims["fxanim_mp_dustdevil_anim"] = %fxanim_mp_dustdevil_anim;
}

play_fx_prop_anims( localclientnum )
{
    fxanim_dustdevils = getentarray( localclientnum, "fxanim_mp_dustdevil", "targetname" );
    array_thread( fxanim_dustdevils, ::fxanim_think, localclientnum );
    fxanim_props = getentarray( localclientnum, "fxanim", "targetname" );
    array_thread( fxanim_props, ::fxanim_props_think, localclientnum );
}

fxanim_think( localclientnum )
{
    self endon( "death" );
    self endon( "entityshutdown" );
    self endon( "delete" );
    wait 3;
    self useanimtree( #animtree );
    sound_origin = self gettagorigin( "dervish_jnt" );
    ent = spawn( 0, sound_origin, "script_origin" );
    ent linkto( self, "dervish_jnt" );

    for (;;)
    {
        wait_time = randomfloatrange( 15, 30 );
        wait( wait_time );
        self setanimrestart( level.nuked_fxanims["fxanim_mp_dustdevil_anim"], 1.0, 0.0, 1.0 );
        sound_id = ent playsound( 0, "amb_fire_tornado" );
        effect_to_use = undefined;

        switch ( randomint( 2 ) )
        {
            case 0:
                effect_to_use = level._effect["fire_devil_sm"];
                break;
            case 1:
                effect_to_use = level._effect["fire_devil_lg"];
                break;
            default:
                effect_to_use = level._effect["fire_devil_lg"];
        }

        dust = playfxontag( localclientnum, effect_to_use, self, "dervish_jnt" );
        wait 12;
        stopsound( sound_id );
        stopfx( localclientnum, dust );
    }

    ent delete();
}

fxanim_props_think( localclientnum )
{
    self endon( "death" );
    self endon( "entityshutdown" );
    self endon( "delete" );
    wait 3;

    if ( isdefined( self.fxanim_wait ) )
        wait( self.fxanim_wait );

    if ( isdefined( self.fxanim_scene_1 ) && self.fxanim_scene_1 == "porch" )
    {
        wait( randomintrange( 5, 10 ) * 1000 );
        playsound( 0, "zmb_porch_collapse", self.origin );
    }

    self useanimtree( #animtree );

    if ( isdefined( level.scr_anim["fxanim_props"][self.fxanim_scene_1] ) )
    {
        if ( issubstr( self.fxanim_scene_1, "wire" ) )
            self thread fxanim_wire_think( localclientnum );
        else
            self setflaggedanim( "nuketown_fxanim", level.scr_anim["fxanim_props"][self.fxanim_scene_1], 1.0, 0.0, 1.0 );
    }
}

fxanim_wire_think( localclientnum )
{
    self endon( "death" );
    self endon( "entityshutdown" );
    self endon( "delete" );
    self waittill_dobj( localclientnum );
    self useanimtree( #animtree );
    wait 2;
    self setflaggedanim( "wire_fx", level.scr_anim["fxanim_props"][self.fxanim_scene_1], 1.0, 0.0, 1.0 );

    for (;;)
    {
        wait( randomintrange( 4, 5 ) );

        if ( self.fxanim_scene_1 == "wirespark_long" )
        {
            playfxontag( localclientnum, level._effect["wire_spark"], self, "long_spark_06_jnt" );
            continue;
        }

        if ( self.fxanim_scene_1 == "wirespark_med" )
            playfxontag( localclientnum, level._effect["wire_spark"], self, "med_spark_06_jnt" );
    }
}

main()
{
    clientscripts\mp\createfx\zm_nuked_fx::main();
    clientscripts\mp\_fx::reportnumeffects();
    precache_util_fx();
    precache_createfx_fx();
    precache_fxanim_props();
    disablefx = getdvarint( #"disable_fx" );

    if ( !isdefined( disablefx ) || disablefx <= 0 )
        precache_scripted_fx();

    waitforclient( 0 );
    players = level.localplayers;

    for ( i = 0; i < players.size; i++ )
        play_fx_prop_anims( i );
}
