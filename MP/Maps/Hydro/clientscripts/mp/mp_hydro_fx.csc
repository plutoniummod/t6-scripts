// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\createfx\mp_hydro_fx;
#include clientscripts\mp\_fx;

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_mp_hydro_dam_water_bottom"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_bottom" );
    level._effect["fx_mp_hydro_dam_water_top"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_top" );
    level._effect["fx_mp_hydro_dam_water_top_side"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_top_side" );
    level._effect["fx_mp_hydro_dam_water_top_side_b"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_top_side_b" );
    level._effect["fx_mp_hydro_dam_water_top_b"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_top_b" );
    level._effect["fx_mp_hydro_dam_water_spray"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_spray" );
    level._effect["fx_mp_hydro_dam_water_drip_splash"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_drip_splash" );
    level._effect["fx_mp_hydro_dam_water_strip"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_strip" );
    level._effect["fx_mp_hydro_dam_water_strip2"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_strip2" );
    level._effect["fx_mp_hydro_dam_water_corner"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_corner" );
    level._effect["fx_mp_hydro_dam_water_corner2"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_corner2" );
    level._effect["fx_mp_hydro_dam_water_wall"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_wall" );
    level._effect["fx_mp_hydro_dam_river_top"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_river_top" );
    level._effect["fx_mp_hydro_dam_river_top_b"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_river_top_b" );
    level._effect["fx_mp_hydro_dam_river_flat"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_river_flat" );
    level._effect["fx_mp_hydro_dam_river_flat2"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_river_flat2" );
    level._effect["fx_mp_hydro_flood_blast01_spill"] = loadfx( "maps/mp_maps/fx_mp_hydro_flood_blast01_spill" );
    level._effect["fx_mp_hydro_flood_blast01"] = loadfx( "maps/mp_maps/fx_mp_hydro_flood_blast01" );
    level._effect["fx_mp_hydro_flood_blast02"] = loadfx( "maps/mp_maps/fx_mp_hydro_flood_blast02" );
    level._effect["fx_mp_hydro_flood_water_spill"] = loadfx( "maps/mp_maps/fx_mp_hydro_flood_water_spill" );
    level._effect["fx_mp_hydro_flood_mist_tail"] = loadfx( "maps/mp_maps/fx_mp_hydro_flood_mist_tail" );
    level._effect["fx_mp_hydro_flood_blast_end"] = loadfx( "maps/mp_maps/fx_mp_hydro_flood_blast_end" );
    level._effect["fx_mp_hydro_hatch_spray"] = loadfx( "maps/mp_maps/fx_mp_hydro_hatch_spray" );
    level._effect["fx_mp_vent_heat_distort"] = loadfx( "maps/mp_maps/fx_mp_vent_heat_distort" );
    level._effect["fx_mp_hydro_splash_edge"] = loadfx( "maps/mp_maps/fx_mp_hydro_splash_edge" );
    level._effect["fx_mp_hydro_water_pipe"] = loadfx( "maps/mp_maps/fx_mp_hydro_water_pipe" );
    level._effect["fx_mp_hydro_dam_water_vista"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_vista" );
    level._effect["fx_mp_hydro_dam_water_top_vista"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_water_top_vista" );
    level._effect["fx_mp_hydro_dam_steam"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_steam" );
    level._effect["fx_mp_hydro_dam_steam2"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_steam2" );
    level._effect["fx_mp_hydro_dam_steam2_green"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_steam2_green" );
    level._effect["fx_mp_hydro_dam_steam3"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_steam3" );
    level._effect["fx_mp_hydro_dam_steam_big"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_steam_big" );
    level._effect["fx_mp_hydro_dam_steam_big2"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_steam_big2" );
    level._effect["fx_mp_hydro_dam_steam_xlrg"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_steam_xlrg" );
    level._effect["fx_mp_hydro_dam_steam_vista"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_steam_vista" );
    level._effect["fx_fog_street_sm_area_low"] = loadfx( "fog/fx_fog_street_sm_area_low" );
    level._effect["fx_mp_hydro_hvac_steam"] = loadfx( "maps/mp_maps/fx_mp_hydro_hvac_steam" );
    level._effect["fx_mp_hydro_steam_behind_glass1"] = loadfx( "maps/mp_maps/fx_mp_hydro_steam_behind_glass1" );
    level._effect["fx_mp_hydro_steam_behind_glass2"] = loadfx( "maps/mp_maps/fx_mp_hydro_steam_behind_glass2" );
    level._effect["fx_mp_hydro_light_warning"] = loadfx( "maps/mp_maps/fx_mp_hydro_light_warning" );
    level._effect["fx_mp_hydro_light_warning_blnk"] = loadfx( "maps/mp_maps/fx_mp_hydro_light_warning_blnk" );
    level._effect["fx_mp_hydro_light_warning_sm"] = loadfx( "maps/mp_maps/fx_mp_hydro_light_warning_sm" );
    level._effect["fx_mp_hydro_light_warning_blnk_sm"] = loadfx( "maps/mp_maps/fx_mp_hydro_light_warning_blnk_sm" );
    level._effect["fx_drone_light_yellow"] = loadfx( "light/fx_drone_light_yellow" );
    level._effect["fx_drone_red_blink"] = loadfx( "light/fx_drone_red_blink" );
    level._effect["fx_mp_hydro_dam_tunnel_glare"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_tunnel_glare" );
    level._effect["fx_mp_hydro_dam_tunnel_glare_green"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_tunnel_glare_green" );
    level._effect["fx_mp_hydro_dam_tunnel_glare_green2"] = loadfx( "maps/mp_maps/fx_mp_hydro_dam_tunnel_glare_green2" );
    level._effect["fx_light_god_ray_mp_hydro"] = loadfx( "env/light/fx_light_god_ray_mp_hydro" );
    level._effect["fx_light_god_ray_mp_hydro_sm"] = loadfx( "env/light/fx_light_god_ray_mp_hydro_sm" );
    level._effect["fx_village_tube_light"] = loadfx( "light/fx_village_tube_light" );
    level._effect["fx_hydro_tube_light"] = loadfx( "light/fx_hydro_tube_light" );
    level._effect["fx_mp_fan_light_shaft_anim"] = loadfx( "light/fx_mp_fan_light_shaft_anim" );
    level._effect["fx_lf_mp_hydro_sun1"] = loadfx( "lens_flares/fx_lf_mp_hydro_sun1" );
    level._effect["fx_mp_light_dust_motes_md"] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
    level._effect["fx_mp_carrier_spark_bounce_runner"] = loadfx( "maps/mp_maps/fx_mp_carrier_spark_bounce_runner" );
    level._effect["fx_mp_hydro_killstreak_spillway_1"] = loadfx( "maps/mp_maps/fx_mp_hydro_killstreak_spillway_1" );
    level._effect["fx_mp_hydro_killstreak_spillway_2"] = loadfx( "maps/mp_maps/fx_mp_hydro_killstreak_spillway_2" );
    level._effect["fx_mp_hydro_killstreak_spillway_mid"] = loadfx( "maps/mp_maps/fx_mp_hydro_killstreak_spillway_mid" );
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["wirespark_med"] = %fxanim_gp_wirespark_med_anim;
    level.scr_anim["fxanim_props"]["wires_long"] = %fxanim_mp_hydro_wires_long_anim;
    level.scr_anim["fxanim_props"]["wires_med"] = %fxanim_mp_hydro_wires_med_anim;
    level.scr_anim["fxanim_props"]["seagull_circle_01"] = %fxanim_gp_seagull_circle_01_anim;
    level.scr_anim["fxanim_props"]["seagull_circle_02"] = %fxanim_gp_seagull_circle_02_anim;
    level.scr_anim["fxanim_props"]["seagull_circle_03"] = %fxanim_gp_seagull_circle_03_anim;
    level.scr_anim["fxanim_props"]["wires_med_02"] = %fxanim_mp_hydro_wires_med_02_anim;
    level.scr_anim["fxanim_props"]["wires_long_02"] = %fxanim_mp_hydro_wires_long_02_anim;
}

main()
{
    clientscripts\mp\createfx\mp_hydro_fx::main();
    clientscripts\mp\_fx::reportnumeffects();
    precache_createfx_fx();
    precache_fxanim_props();
    disablefx = getdvarint( _hash_C9B177D6 );

    if ( !isdefined( disablefx ) || disablefx <= 0 )
        precache_scripted_fx();
}
