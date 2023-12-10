// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_fxanim_dlc4;
#include clientscripts\mp\createfx\mp_takeoff_fx;
#include clientscripts\mp\_fx;

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_light_exit_sign"] = loadfx( "light/fx_light_exit_sign_glow" );
    level._effect["fx_light_flour_glow_cool"] = loadfx( "light/fx_tak_light_flour_glow_cool" );
    level._effect["fx_tak_light_flour_glow_cool_sm"] = loadfx( "light/fx_tak_light_flour_glow_cool_sm" );
    level._effect["fx_light_upl_flour_glow_v_shape_cool"] = loadfx( "light/fx_light_upl_flour_glow_v_shape_cool" );
    level._effect["fx_light_recessed_blue"] = loadfx( "light/fx_light_recessed_blue" );
    level._effect["fx_light_recessed_cool_sm_soft"] = loadfx( "light/fx_light_recessed_cool_sm_soft" );
    level._effect["fx_mp_tak_glow_blue"] = loadfx( "maps/mp_maps/fx_mp_tak_glow_blue" );
    level._effect["fx_mp_tak_glow_orange"] = loadfx( "maps/mp_maps/fx_mp_tak_glow_orange" );
    level._effect["fx_mp_tak_glow_yellow"] = loadfx( "maps/mp_maps/fx_mp_tak_glow_yellow" );
    level._effect["fx_mp_tak_glow_red"] = loadfx( "maps/mp_maps/fx_mp_tak_glow_red" );
    level._effect["fx_tak_light_flour_glow_ceiling"] = loadfx( "light/fx_tak_light_flour_glow_ceiling" );
    level._effect["fx_tak_light_flour_sqr_lg"] = loadfx( "light/fx_tak_light_flour_sqr_lg" );
    level._effect["fx_tak_light_flour_rnd_lg"] = loadfx( "light/fx_tak_light_flour_rnd_lg" );
    level._effect["fx_tak_light_tv_glow_blue"] = loadfx( "light/fx_tak_light_tv_glow_blue" );
    level._effect["fx_tak_light_tv_glow_blue_flckr"] = loadfx( "light/fx_tak_light_tv_glow_blue_flckr" );
    level._effect["fx_drone_light_yellow"] = loadfx( "light/fx_drone_light_yellow" );
    level._effect["fx_tak_light_sign_glow_blue"] = loadfx( "light/fx_tak_light_sign_glow_blue" );
    level._effect["fx_tak_light_blue_stair"] = loadfx( "light/fx_tak_light_blue_stair" );
    level._effect["fx_tak_light_blue_stair_sm"] = loadfx( "light/fx_tak_light_blue_stair_sm" );
    level._effect["fx_tak_light_blue"] = loadfx( "light/fx_tak_light_blue" );
    level._effect["fx_tak_light_blue_pulse"] = loadfx( "light/fx_tak_light_blue_pulse" );
    level._effect["fx_tak_light_blue_pulse_curve"] = loadfx( "light/fx_tak_light_blue_pulse_curve" );
    level._effect["fx_light_beacon_yellow"] = loadfx( "light/fx_light_beacon_yellow" );
    level._effect["fx_light_beacon_red_blink_fst_sm"] = loadfx( "light/fx_light_beacon_red_blink_fst_sm" );
    level._effect["fx_tak_light_modern_sconce"] = loadfx( "light/fx_tak_light_modern_sconce" );
    level._effect["fx_tak_light_spotlight"] = loadfx( "light/fx_tak_light_spotlight" );
    level._effect["fx_tak_light_wall_ext"] = loadfx( "light/fx_tak_light_wall_ext" );
    level._effect["fx_mp_light_dust_motes_md"] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
    level._effect["fx_mp_tak_dust_ground"] = loadfx( "maps/mp_maps/fx_mp_tak_dust_ground" );
    level._effect["fx_tak_water_fountain_pool_sm"] = loadfx( "water/fx_tak_water_fountain_pool_sm" );
    level._effect["fx_paper_interior_short_sm"] = loadfx( "debris/fx_paper_interior_short_sm" );
    level._effect["fx_paper_exterior_short_sm_fst"] = loadfx( "debris/fx_paper_exterior_short_sm_fst" );
    level._effect["fx_insects_swarm_md_light"] = loadfx( "bio/insects/fx_insects_swarm_md_light" );
    level._effect["fx_mp_vent_heat_distort"] = loadfx( "maps/mp_maps/fx_mp_vent_heat_distort" );
    level._effect["fx_mp_tak_steam_loading_dock"] = loadfx( "maps/mp_maps/fx_mp_tak_steam_loading_dock" );
    level._effect["fx_mp_vent_steam_line"] = loadfx( "maps/mp_maps/fx_mp_vent_steam_line" );
    level._effect["fx_mp_vent_steam_line_sm"] = loadfx( "maps/mp_maps/fx_mp_vent_steam_line_sm" );
    level._effect["fx_mp_vent_steam_line_lg"] = loadfx( "maps/mp_maps/fx_mp_vent_steam_line_lg" );
    level._effect["fx_mp_steam_amb_xlg"] = loadfx( "maps/mp_maps/fx_mp_steam_amb_xlg" );
    level._effect["fx_mp_tak_steam_hvac"] = loadfx( "maps/mp_maps/fx_mp_tak_steam_hvac" );
    level._effect["fx_lf_mp_overflow_sun1"] = loadfx( "lens_flares/fx_lf_mp_overflow_sun1" );
    level._effect["fx_lf_mp_takeoff_sun1"] = loadfx( "lens_flares/fx_lf_mp_takeoff_sun1" );
    level._effect["fx_mp_tak_shuttle_thruster_lg"] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_lg" );
    level._effect["fx_mp_tak_shuttle_thruster_md"] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_md" );
    level._effect["fx_mp_tak_shuttle_thruster_sm"] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_sm" );
    level._effect["fx_mp_tak_shuttle_thruster_smk_grnd"] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_smk_grnd" );
    level._effect["fx_mp_tak_shuttle_thruster_steam"] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_steam" );
    level._effect["fx_mp_tak_shuttle_thruster_steam_w"] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_thruster_steam_w" );
    level._effect["fx_mp_tak_shuttle_frame_light"] = loadfx( "maps/mp_maps/fx_mp_tak_shuttle_frame_light" );
    level._effect["fx_mp_tak_steam_nozzle"] = loadfx( "maps/mp_maps/fx_mp_tak_steam_nozzle" );
}

#using_animtree("fxanim_props_dlc4");

precache_fxanim_props_dlc4()
{
    level.scr_anim["fxanim_props_dlc4"]["decont_blasters"] = %fxanim_mp_takeoff_decont_blasters_anim;
    level.scr_anim["fxanim_props_dlc4"]["scaffold_wires_01"] = %fxanim_mp_takeoff_scaffold_wires_01_anim;
    level.scr_anim["fxanim_props_dlc4"]["crane_hooks"] = %fxanim_mp_takeoff_crane_hooks_anim;
    level.scr_anim["fxanim_props_dlc4"]["rattling_sign"] = %fxanim_mp_takeoff_rattling_sign_anim;
    level.scr_anim["fxanim_props_dlc4"]["radar01"] = %fxanim_mp_takeoff_satellite_dish_01_anim;
    level.scr_anim["fxanim_props_dlc4"]["radar02"] = %fxanim_mp_takeoff_satellite_dish_02_anim;
    level.scr_anim["fxanim_props_dlc4"]["radar03"] = %fxanim_mp_takeoff_satellite_dish_03_anim;
    level.scr_anim["fxanim_props_dlc4"]["radar04"] = %fxanim_mp_takeoff_satellite_dish_04_anim;
    level.scr_anim["fxanim_props_dlc4"]["radar05"] = %fxanim_mp_takeoff_satellite_dish_05_anim;
    level.scr_anim["fxanim_props_dlc4"]["banners"] = %fxanim_mp_takeoff_banner_01_anim;
    level.scr_anim["fxanim_props_dlc4"]["planets"] = %fxanim_mp_takeoff_planets_anim;
    level.scr_anim["fxanim_props_dlc4"]["banners_lrg"] = %fxanim_mp_takeoff_banner_lrg_anim;
}

fxanim_init( localclientnum )
{
    for (;;)
    {
        level waittill( "snap_processed", snapshotlocalclientnum );

        if ( snapshotlocalclientnum == localclientnum )
            break;
    }

    level thread clientscripts\mp\_fxanim_dlc4::fxanim_init_dlc( localclientnum );
    radar = getent( localclientnum, "fxanim_dlc4_radar", "targetname" );

    if ( isdefined( radar ) )
    {
        if ( !isdefined( level.radar_waits ) )
        {
            level.radar_waits = [];

            for ( i = 1; i < 6; i++ )
                level.radar_waits[i] = randomfloatrange( 5, 10 );
        }

        radar thread fxanim_radar_think( localclientnum );
    }

    decont_blasters = getent( localclientnum, "fxanim_dlc4_blasters", "targetname" );

    if ( isdefined( decont_blasters ) )
        decont_blasters thread fxanim_decontamination_think( localclientnum );

    planets_candidates = getentarray( localclientnum, "fxanim_dlc4", "targetname" );

    if ( isdefined( planets_candidates ) && planets_candidates.size > 0 )
    {
        foreach ( planets_candidate in planets_candidates )
        {
            if ( planets_candidate.model == "fxanim_mp_takeoff_planets_mod" )
                planets_candidate thread fxanim_planets_think( localclientnum );
        }
    }

    level thread playexploderonstart();
}

#using_animtree("fxanim_props");

precache_fx_anims()
{
    level.scr_anim = [];
    level.scr_anim["fxanim_props"]["seagull_circle_01"] = %fxanim_gp_seagull_circle_01_anim;
    level.scr_anim["fxanim_props"]["seagull_circle_02"] = %fxanim_gp_seagull_circle_02_anim;
    level.scr_anim["fxanim_props"]["seagull_circle_03"] = %fxanim_gp_seagull_circle_03_anim;
    level.scr_anim["fxanim_props"]["windsock"] = %fxanim_gp_windsock_anim;
    level.fx_anim_level_init = ::fxanim_init;
}

#using_animtree("fxanim_props_dlc4");

fxanim_radar_think( localclientnum )
{
    self endon( "death" );
    self endon( "entityshutdown" );
    self endon( "delete" );
    self waittill_dobj( localclientnum );
    self useanimtree( #animtree );
    anim_index = 1;

    for (;;)
    {
        self setflaggedanimrestart( "radar_done" + anim_index, level.scr_anim["fxanim_props_dlc4"]["radar0" + anim_index], 1.0, 0.0, 1.0 );

        for (;;)
        {
            self waittill( "radar_done" + anim_index, note );

            if ( note == "end" )
                break;
        }

        wait( level.radar_waits[anim_index] );
        self clearanim( level.scr_anim["fxanim_props_dlc4"]["radar0" + anim_index], 0 );
        anim_index++;

        if ( anim_index > 5 )
            anim_index = 1;
    }
}

fxanim_decontamination_think( localclientnum )
{
    self waittill_dobj( localclientnum );
    self useanimtree( #animtree );
    self animflaggedscripted( "nozzle", level.scr_anim["fxanim_props_dlc4"]["decont_blasters"], 1.0, 0.0, 1.0 );
    self.nozzletags = [];
    self.nozzletags["one"] = "nozzle_01_tag_jnt";
    self.nozzletags["two"] = "nozzle_02_tag_jnt";
    self.nozzletags["three"] = "nozzle_03_tag_jnt";
    self.nozzletags["four"] = "nozzle_04_tag_jnt";
    self.nozzlefxid = [];

    for (;;)
    {
        self waittill( "nozzle", note );

        if ( note == "end" )
            continue;

        tokens = strtok( note, "_" );

        if ( tokens.size != 4 )
            continue;

        foundchange = 0;

        if ( tokens[3] == "off" || tokens[3] == "on" )
        {
            foundchange = 1;
            change = tokens[3];
        }

        if ( foundchange == 0 || tokens[0] != "nozzles" )
            continue;

        foreach ( token in tokens )
        {
            if ( isdefined( self.nozzletags[token] ) )
            {
                if ( change == "on" )
                {
                    self.nozzlefxid[token] = playfxontag( localclientnum, level._effect["fx_mp_tak_steam_nozzle"], self, self.nozzletags[token] );
                    continue;
                }

                stopfx( localclientnum, self.nozzlefxid[token] );
                self.nozzlefxid[token] = undefined;
            }
        }
    }
}

main()
{
    clientscripts\mp\createfx\mp_takeoff_fx::main();
    clientscripts\mp\_fx::reportnumeffects();
    precache_createfx_fx();
    precache_fx_anims();
    precache_fxanim_props_dlc4();
    disablefx = getdvarint( _hash_C9B177D6 );

    if ( !isdefined( disablefx ) || disablefx <= 0 )
        precache_scripted_fx();
}

playexploderonstart()
{
    clientscripts\mp\_fx::activate_exploder( 2001 );
    clientscripts\mp\_fx::activate_exploder( 2002 );
}

fxanim_planets_think( localclientnum )
{
    self waittill_dobj( localclientnum );
    playfxontag( localclientnum, level._effect["fx_mp_tak_glow_blue"], self, "earth_jnt" );
    playfxontag( localclientnum, level._effect["fx_mp_tak_glow_red"], self, "jupiter_jnt" );
    playfxontag( localclientnum, level._effect["fx_mp_tak_glow_red"], self, "mars_jnt" );
    playfxontag( localclientnum, level._effect["fx_mp_tak_glow_yellow"], self, "mercury_jnt" );
    playfxontag( localclientnum, level._effect["fx_mp_tak_glow_blue"], self, "neptune_jnt" );
    playfxontag( localclientnum, level._effect["fx_mp_tak_glow_yellow"], self, "saturn_jnt" );
    playfxontag( localclientnum, level._effect["fx_mp_tak_glow_blue"], self, "uranus_jnt" );
    playfxontag( localclientnum, level._effect["fx_mp_tak_glow_yellow"], self, "venus_jnt" );
}
