// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\createfx\mp_drone_fx;
#include clientscripts\mp\_fx;

precache_scripted_fx()
{
    level._effect["fx_mp_drone_robot_sparks"] = loadfx( "maps/mp_maps/fx_mp_drone_robot_sparks" );
}

precache_createfx_fx()
{
    level._effect["fx_leaves_falling_mangrove_lg_dark"] = loadfx( "env/foliage/fx_leaves_falling_mangrove_lg_dark" );
    level._effect["fx_mp_vent_steam"] = loadfx( "maps/mp_maps/fx_mp_vent_steam" );
    level._effect["fx_hvac_steam_md"] = loadfx( "smoke/fx_hvac_steam_md" );
    level._effect["fx_mp_water_drip_light_shrt"] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_shrt" );
    level._effect["fx_fog_street_cool_slw_md"] = loadfx( "fog/fx_fog_street_cool_slw_md" );
    level._effect["fx_light_emrgncy_floodlight"] = loadfx( "light/fx_light_emrgncy_floodlight" );
    level._effect["fx_insects_swarm_dark_lg"] = loadfx( "bio/insects/fx_insects_swarm_dark_lg" );
    level._effect["fx_mp_fog_low"] = loadfx( "maps/mp_maps/fx_mp_fog_low" );
    level._effect["fx_insects_swarm_md_light"] = loadfx( "bio/insects/fx_insects_swarm_md_light" );
    level._effect["fx_lf_dockside_sun1"] = loadfx( "lens_flares/fx_lf_mp_drone_sun1" );
    level._effect["fx_light_floodlight_rnd_cool_glw_dim"] = loadfx( "light/fx_light_floodlight_rnd_cool_glw_dim" );
    level._effect["fx_mp_steam_pipe_md"] = loadfx( "maps/mp_maps/fx_mp_steam_pipe_md" );
    level._effect["fx_mp_light_dust_motes_md"] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
    level._effect["fx_mp_light_dust_motes_sm"] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_sm" );
    level._effect["fx_mp_fog_cool_ground"] = loadfx( "maps/mp_maps/fx_mp_fog_cool_ground" );
    level._effect["fx_red_button_flash"] = loadfx( "light/fx_red_button_flash" );
    level._effect["fx_mp_distant_cloud"] = loadfx( "maps/mp_maps/fx_mp_distant_cloud_lowmem" );
    level._effect["fx_light_god_ray_mp_drone"] = loadfx( "env/light/fx_light_god_ray_mp_drone" );
    level._effect["fx_ceiling_circle_light_glare"] = loadfx( "light/fx_ceiling_circle_light_glare" );
    level._effect["fx_drone_rectangle_light"] = loadfx( "light/fx_drone_rectangle_light" );
    level._effect["fx_drone_rectangle_light_02"] = loadfx( "light/fx_drone_rectangle_light_02" );
    level._effect["fx_mp_water_drip_light_long"] = loadfx( "maps/mp_maps/fx_mp_water_drip_light_long" );
    level._effect["fx_pc_panel_lights_runner"] = loadfx( "props/fx_pc_panel_lights_runner" );
    level._effect["fx_drone_red_ring_console"] = loadfx( "light/fx_drone_red_ring_console" );
    level._effect["fx_blue_light_flash"] = loadfx( "light/fx_blue_light_flash" );
    level._effect["fx_window_god_ray"] = loadfx( "light/fx_window_god_ray" );
    level._effect["fx_mp_drone_interior_steam"] = loadfx( "maps/mp_maps/fx_mp_drone_interior_steam" );
    level._effect["fx_pc_panel_heli"] = loadfx( "props/fx_pc_panel_heli" );
    level._effect["fx_red_light_flash"] = loadfx( "light/fx_red_light_flash" );
    level._effect["fx_drone_rectangle_light_blue"] = loadfx( "light/fx_drone_rectangle_light_blue" );
    level._effect["fx_mp_distant_cloud_vista"] = loadfx( "maps/mp_maps/fx_mp_distant_cloud_vista_lowmem" );
    level._effect["fx_drone_rectangle_light_blue_4"] = loadfx( "light/fx_drone_rectangle_light_blue_4" );
    level._effect["fx_drone_rectangle_light_yellow"] = loadfx( "light/fx_drone_rectangle_light_yellow" );
    level._effect["fx_ceiling_circle_light_led"] = loadfx( "light/fx_ceiling_circle_light_led" );
    level._effect["fx_drone_red_ring_console_runner"] = loadfx( "light/fx_drone_red_ring_console_runner" );
    level._effect["fx_light_beacon_red_blink_fst"] = loadfx( "light/fx_light_beacon_red_blink_fst" );
    level._effect["fx_wall_water_ground"] = loadfx( "water/fx_wall_water_ground" );
    level._effect["fx_drone_rectangle_light_03"] = loadfx( "light/fx_drone_rectangle_light_03" );
    level._effect["fx_drone_red_blink"] = loadfx( "light/fx_drone_red_blink" );
    level._effect["fx_light_god_ray_mp_drone2"] = loadfx( "env/light/fx_light_god_ray_mp_drone2" );
    level._effect["fx_drone_rectangle_light_skinny"] = loadfx( "light/fx_drone_rectangle_light_skinny" );
    level._effect["fx_mp_drone_rapid"] = loadfx( "maps/mp_maps/fx_mp_drone_rapid" );
    level._effect["fx_mp_distant_cloud_vista_lg"] = loadfx( "maps/mp_maps/fx_mp_distant_cloud_vista_lg_lowmem" );
    level._effect["fx_light_exit_sign"] = loadfx( "light/fx_light_exit_sign_glow" );
    level._effect["fx_drone_light_yellow"] = loadfx( "light/fx_drone_light_yellow" );
}

main()
{
    clientscripts\mp\createfx\mp_drone_fx::main();
    clientscripts\mp\_fx::reportnumeffects();
    precache_createfx_fx();
    precache_fxanim_props();
    disablefx = getdvarint( _hash_C9B177D6 );

    if ( !isdefined( disablefx ) || disablefx <= 0 )
        precache_scripted_fx();
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["vines_aquilaria"] = %fxanim_gp_vines_aquilaria_anim;
    level.scr_anim["fxanim_props"]["vines_strangler_fig"] = %fxanim_gp_vines_strangler_fig_anim;
    level.drone_anims = [];
    level.drone_anims["fxanim_mp_drone_factory_link_anim"] = %fxanim_mp_drone_factory_link_anim;
    level.drone_anims["fxanim_mp_drone_factory_welder_01_anim"] = %fxanim_mp_drone_factory_welder_01_anim;
    level.drone_anims["fxanim_mp_drone_factory_welder_02_anim"] = %fxanim_mp_drone_factory_welder_02_anim;
    level.drone_anims["fxanim_mp_drone_factory_welder_03_anim"] = %fxanim_mp_drone_factory_welder_03_anim;
    level.drone_anims["fxanim_mp_drone_factory_welder_04_anim"] = %fxanim_mp_drone_factory_welder_04_anim;
    level.drone_anims["fxanim_mp_drone_factory_suction_01_anim"] = %fxanim_mp_drone_factory_suction_01_anim;
    level.drone_anims["fxanim_mp_drone_factory_suction_02_anim"] = %fxanim_mp_drone_factory_suction_02_anim;
    level.drone_anims["fxanim_mp_drone_factory_suction_03_anim"] = %fxanim_mp_drone_factory_suction_03_anim;
    level.drone_anims["fxanim_mp_drone_factory_suction_04_anim"] = %fxanim_mp_drone_factory_suction_04_anim;
    level.drone_anims["fxanim_mp_drone_factory_link_anim_off"] = %fxanim_mp_drone_factory_link_off_anim;
    level.drone_anims["fxanim_mp_drone_factory_welder_01_anim_off"] = %fxanim_mp_drone_factory_welder_01_off_anim;
    level.drone_anims["fxanim_mp_drone_factory_welder_02_anim_off"] = %fxanim_mp_drone_factory_welder_02_off_anim;
    level.drone_anims["fxanim_mp_drone_factory_welder_03_anim_off"] = %fxanim_mp_drone_factory_welder_03_off_anim;
    level.drone_anims["fxanim_mp_drone_factory_welder_04_anim_off"] = %fxanim_mp_drone_factory_welder_04_off_anim;
    level.drone_anims["fxanim_mp_drone_factory_suction_01_anim_off"] = %fxanim_mp_drone_factory_suction_01_off_anim;
    level.drone_anims["fxanim_mp_drone_factory_suction_02_anim_off"] = %fxanim_mp_drone_factory_suction_02_off_anim;
    level.drone_anims["fxanim_mp_drone_factory_suction_03_anim_off"] = %fxanim_mp_drone_factory_suction_03_off_anim;
    level.drone_anims["fxanim_mp_drone_factory_suction_04_anim_off"] = %fxanim_mp_drone_factory_suction_04_off_anim;
    level.scr_anim["fxanim_props"]["vines_strangler_fig_alt"] = %fxanim_gp_vines_strangler_fig_alt_anim;
    level.fx_anim_level_init = ::fxanim_init;
}

fxanim_init( localclientnum )
{
    level waittill( "snap_processed" );

    models = getentarray( localclientnum, "drone_fxanim", "targetname" );

    foreach ( model in models )
    {
        if ( model.model == "fxanim_mp_drone_factory_link_mod" )
            model drone_link( localclientnum );

        if ( isdefined( model.script_animation ) )
        {
            if ( issubstr( model.script_animation, "drone_factory_welder" ) )
            {
                model thread drone_animate_fx( localclientnum );
                continue;
            }

            model thread drone_animation( localclientnum );
        }
    }
}

drone_animation( localclientnum )
{
    self waittill_dobj( localclientnum );
    assert( isdefined( level.drone_anims[self.script_animation] ) );
    self useanimtree( #animtree );

    if ( getgametypesetting( "allowMapScripting" ) )
        self animscripted( level.drone_anims[self.script_animation], 1.0, 0.0, 1.0 );
    else
        self animscripted( level.drone_anims[self.script_animation + "_off"], 1.0, 0.0, 1.0 );
}

drone_link( localclientnum )
{
    self waittill_dobj( localclientnum );
    models = getentarray( localclientnum, "drone_linkto", "targetname" );

    foreach ( model in models )
    {
        model waittill_dobj( localclientnum );
        model linkto( self, model.script_noteworthy );
    }
}

drone_animate_fx( localclientnum )
{
    self endon( "death" );
    self endon( "entityshutdown" );
    self endon( "delete" );
    self waittill_dobj( localclientnum );
    self useanimtree( #animtree );

    if ( getgametypesetting( "allowMapScripting" ) )
        self animflaggedscripted( "fx", level.drone_anims[self.script_animation], 1.0, 0.0, 1.0 );
    else
        self animflaggedscripted( "fx", level.drone_anims[self.script_animation + "_off"], 1.0, 0.0, 1.0 );

    for (;;)
    {
        self waittill( "fx", note );

        switch ( note )
        {
            case "tack_weld_10":
            case "tack_weld_09":
            case "tack_weld_08":
            case "tack_weld_07":
            case "tack_weld_06":
            case "tack_weld_05":
            case "tack_weld_04":
            case "tack_weld_03":
            case "tack_weld_02":
            case "tack_weld_01":
            case "seam_weld_04_stop":
            case "seam_weld_04_start":
            case "seam_weld_03_stop":
            case "seam_weld_03_start":
            case "seam_weld_02_stop":
            case "seam_weld_02_start":
            case "seam_weld_01_stop":
            case "seam_weld_01_start":
                playfxontag( localclientnum, level._effect["fx_mp_drone_robot_sparks"], self, "tag_fx" );
                break;
        }
    }
}
