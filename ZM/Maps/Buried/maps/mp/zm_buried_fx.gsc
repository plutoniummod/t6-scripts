// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\createfx\zm_buried_fx;

main()
{
    precache_createfx_fx();
    precache_scripted_fx();
    precache_fxanim_props();
    maps\mp\createfx\zm_buried_fx::main();
}

precache_scripted_fx()
{
    level._effect["switch_sparks"] = loadfx( "maps/zombie/fx_zmb_pswitch_spark" );
    level._effect["lght_marker"] = loadfx( "maps/zombie/fx_zmb_tranzit_marker" );
    level._effect["lght_marker_flare"] = loadfx( "maps/zombie/fx_zmb_tranzit_marker_fl" );
    level._effect["poltergeist"] = loadfx( "misc/fx_zombie_couch_effect" );
    level._effect["zomb_gib"] = loadfx( "maps/zombie/fx_zmb_tranzit_lava_torso_explo" );
    level._effect["blue_eyes"] = loadfx( "maps/zombie/fx_zombie_eye_single_blue" );
    level._effect["orange_eyes"] = loadfx( "misc/fx_zombie_eye_single" );
    level._effect["player_possessed_eyes"] = loadfx( "maps/zombie_buried/fx_buried_eye_stulhinger" );
    gametype = getdvar( "ui_gametype" );

    if ( gametype == "zcleansed" )
    {
        level._effect["blue_eyes_player"] = loadfx( "maps/zombie/fx_zombie_eye_returned_blue" );
        level._effect["lava_burning"] = loadfx( "env/fire/fx_fire_lava_player_torso" );
    }

    if ( isdefined( 0 ) && 0 )
    {
        level._effect["player_3rd_spotlight_lite"] = loadfx( "maps/zombie_buried/fx_buried_spot_flkr_lite" );
        level._effect["player_3rd_spotlight_med"] = loadfx( "maps/zombie_buried/fx_buried_spot_flkr_med" );
        level._effect["player_3rd_spotlight_high"] = loadfx( "maps/zombie_buried/fx_buried_spot_flkr_hvy" );
        level._effect["oillamp"] = loadfx( "maps/zombie_buried/fx_buried_glow_lantern" );
    }

    level._effect["booze_candy_spawn"] = loadfx( "maps/zombie_buried/fx_buried_booze_candy_spawn" );
    level._effect["crusher_sparks"] = loadfx( "maps/zombie_buried/fx_buried_crusher_sparks" );
    level._effect["rise_burst_foliage"] = loadfx( "maps/zombie/fx_zm_buried_hedge_billow_body" );
    level._effect["rise_billow_foliage"] = loadfx( "maps/zombie/fx_zm_buried_hedge_burst_hand" );
    level._effect["rise_dust_foliage"] = loadfx( "maps/zombie/fx_zm_buried_hedge_dustfall_body" );
    level._effect["fx_buried_key_glint"] = loadfx( "maps/zombie_buried/fx_buried_key_glint" );
    level._effect["sq_glow"] = loadfx( "maps/zombie_buried/fx_buried_glow_lantern_ghost" );
    level._effect["vulture_fx_wisp"] = loadfx( "maps/zombie_buried/fx_buried_richt_whisp_center" );
    level._effect["vulture_fx_wisp_orb"] = loadfx( "maps/zombie_buried/fx_buried_richt_whisp_orbit" );
    level._effect["fx_wisp_m"] = loadfx( "maps/zombie_buried/fx_buried_maxis_whisp_os" );
    level._effect["fx_wisp_lg_m"] = loadfx( "maps/zombie_buried/fx_buried_maxis_whisp_lg_os" );
    level._effect["sq_bulb_blue"] = loadfx( "maps/zombie_buried/fx_buried_eg_blu" );
    level._effect["sq_bulb_orange"] = loadfx( "maps/zombie_buried/fx_buried_eg_orng" );
    level._effect["sq_bulb_green"] = loadfx( "maps/zombie_buried/fx_buried_sq_bulb_green" );
    level._effect["sq_bulb_yellow"] = loadfx( "maps/zombie_buried/fx_buried_sq_bulb_yellow" );
    level._effect["sq_ether_amp_trail"] = loadfx( "maps/zombie_buried/fx_buried_ether_amp_trail" );
    level._effect["sq_tower_r"] = loadfx( "maps/zombie_buried/fx_buried_tower_power_blue" );
    level._effect["sq_tower_m"] = loadfx( "maps/zombie_buried/fx_buried_tower_power_orange" );
    level._effect["sq_tower_bolts"] = loadfx( "maps/zombie_buried/fx_buried_tower_power_bolts" );
    level._effect["sq_spark"] = loadfx( "maps/zombie_buried/fx_buried_spark_gen" );
    level._effect["sq_spawn"] = loadfx( "maps/zombie_buried/fx_buried_time_bomb_spawn" );
    level._effect["sq_vulture_orange_eye_glow"] = loadfx( "misc/fx_zombie_eye_side_quest" );
}

precache_createfx_fx()
{
    level._effect["fx_buried_ash_blowing"] = loadfx( "maps/zombie_buried/fx_buried_ash_blowing" );
    level._effect["fx_buried_bats_group"] = loadfx( "maps/zombie_buried/fx_buried_bats_group" );
    level._effect["fx_buried_cloud_low"] = loadfx( "maps/zombie_buried/fx_buried_cloud_low" );
    level._effect["fx_buried_conveyor_belt_edge"] = loadfx( "maps/zombie_buried/fx_buried_conveyor_belt_edge" );
    level._effect["fx_buried_dust_ceiling_hole"] = loadfx( "maps/zombie_buried/fx_buried_dust_ceiling_hole" );
    level._effect["fx_buried_dust_edge_100"] = loadfx( "maps/zombie_buried/fx_buried_dust_edge_100" );
    level._effect["fx_buried_dust_edge_xlg"] = loadfx( "maps/zombie_buried/fx_buried_dust_edge_xlg" );
    level._effect["fx_buried_dust_edge_blown"] = loadfx( "maps/zombie_buried/fx_buried_dust_edge_blown" );
    level._effect["fx_buried_dust_flurry"] = loadfx( "maps/zombie_buried/fx_buried_dust_flurry" );
    level._effect["fx_buried_dust_int_25x50"] = loadfx( "maps/zombie_buried/fx_buried_dust_int_25x50" );
    level._effect["fx_buried_dust_motes_xlg"] = loadfx( "maps/zombie_buried/fx_buried_dust_motes_xlg" );
    level._effect["fx_buried_dust_motes_ext_xlg"] = loadfx( "maps/zombie_buried/fx_buried_dust_motes_ext_xlg" );
    level._effect["fx_buried_dust_motes_ext_sm"] = loadfx( "maps/zombie_buried/fx_buried_dust_motes_ext_sm" );
    level._effect["fx_buried_dust_rising_sm"] = loadfx( "maps/zombie_buried/fx_buried_dust_rising_sm" );
    level._effect["fx_buried_dust_rising_md"] = loadfx( "maps/zombie_buried/fx_buried_dust_rising_md" );
    level._effect["fx_buried_dust_tunnel_ceiling"] = loadfx( "maps/zombie_buried/fx_buried_dust_tunnel_ceiling" );
    level._effect["fx_buried_fireplace"] = loadfx( "maps/zombie_buried/fx_buried_fireplace" );
    level._effect["fx_buried_fog_sm"] = loadfx( "maps/zombie_buried/fx_buried_fog_sm" );
    level._effect["fx_buried_fog_md"] = loadfx( "maps/zombie_buried/fx_buried_fog_md" );
    level._effect["fx_buried_glow_kerosene_lamp"] = loadfx( "maps/zombie_buried/fx_buried_glow_kerosene_lamp" );
    level._effect["fx_buried_glow_sconce"] = loadfx( "maps/zombie_buried/fx_buried_glow_sconce" );
    level._effect["fx_buried_god_ray_sm"] = loadfx( "maps/zombie_buried/fx_buried_god_ray_sm" );
    level._effect["fx_buried_godray_church"] = loadfx( "maps/zombie_buried/fx_buried_godray_church" );
    level._effect["fx_buried_godray_ext_sm"] = loadfx( "maps/zombie_buried/fx_buried_godray_ext_sm" );
    level._effect["fx_buried_godray_ext_md"] = loadfx( "maps/zombie_buried/fx_buried_godray_ext_md" );
    level._effect["fx_buried_godray_ext_lg"] = loadfx( "maps/zombie_buried/fx_buried_godray_ext_lg" );
    level._effect["fx_buried_godray_ext_thin"] = loadfx( "maps/zombie_buried/fx_buried_godray_ext_thin" );
    level._effect["fx_buried_insects"] = loadfx( "maps/zombie_buried/fx_buried_insects" );
    level._effect["fx_buried_sand_windy_sm"] = loadfx( "maps/zombie_buried/fx_buried_sand_windy_sm" );
    level._effect["fx_buried_sand_windy_md"] = loadfx( "maps/zombie_buried/fx_buried_sand_windy_md" );
    level._effect["fx_buried_sandstorm_edge"] = loadfx( "maps/zombie_buried/fx_buried_sandstorm_edge" );
    level._effect["fx_buried_sandstorm_distant"] = loadfx( "maps/zombie_buried/fx_buried_sandstorm_distant" );
    level._effect["fx_buried_smk_plume_lg"] = loadfx( "maps/zombie_buried/fx_buried_smk_plume_lg" );
    level._effect["fx_buried_steam_md"] = loadfx( "maps/zombie_buried/fx_buried_steam_md" );
    level._effect["fx_buried_water_dripping"] = loadfx( "maps/zombie_buried/fx_buried_water_dripping" );
    level._effect["fx_buried_water_spilling"] = loadfx( "maps/zombie_buried/fx_buried_water_spilling" );
    level._effect["fx_buried_water_spilling_lg"] = loadfx( "maps/zombie_buried/fx_buried_water_spilling_lg" );
    level._effect["fx_buried_barrier_break"] = loadfx( "maps/zombie_buried/fx_buried_barrier_break" );
    level._effect["fx_buried_barrier_break_sm"] = loadfx( "maps/zombie_buried/fx_buried_barrier_break_sm" );
    level._effect["fx_buried_dest_floor_lg"] = loadfx( "maps/zombie_buried/fx_buried_dest_floor_lg" );
    level._effect["fx_buried_dest_floor_sm"] = loadfx( "maps/zombie_buried/fx_buried_dest_floor_sm" );
    level._effect["fx_buried_dest_platform_lsat"] = loadfx( "maps/zombie_buried/fx_buried_dest_platform_lsat" );
    level._effect["fx_buried_fountain_spray"] = loadfx( "maps/zombie_buried/fx_buried_fountain_spray" );
    level._effect["fx_buried_fountain_swirl"] = loadfx( "maps/zombie_buried/fx_buried_fountain_swirl" );
    level._effect["fx_buried_meteor_sm_runner"] = loadfx( "maps/zombie_buried/fx_buried_meteor_sm_runner" );
    level._effect["fx_buried_meteor_lg_runner"] = loadfx( "maps/zombie_buried/fx_buried_meteor_lg_runner" );
}

#using_animtree("fxanim_props_dlc3");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["sheriff_sign"] = %fxanim_zom_buried_sign_sheriff_anim;
    level.scr_anim["fxanim_props"]["balcony_rope"] = %fxanim_zom_buried_rope_balcony_anim;
    level.scr_anim["fxanim_props"]["livingstone_sign"] = %fxanim_zom_buried_sign_livingstone_anim;
    level.scr_anim["fxanim_props"]["livingstone_sign_fast"] = %fxanim_zom_buried_sign_livingstone_fast_anim;
    level.scr_anim["fxanim_props"]["noose_lrg"] = %fxanim_zom_buried_noose_lrg_anim;
    level.scr_anim["fxanim_props"]["noose_med"] = %fxanim_zom_buried_noose_med_anim;
    level.scr_anim["fxanim_props"]["noose_sml"] = %fxanim_zom_buried_noose_sml_anim;
    level.scr_anim["fxanim_props"]["rope_barn"] = %fxanim_zom_buried_rope_barn_anim;
    level.scr_anim["fxanim_props"]["lsat_catwalk"] = %fxanim_zom_buried_catwalk_anim;
    level.scr_anim["fxanim_props"]["sq_orbs"] = %fxanim_zom_buried_orbs_anim;
    level.scr_anim["fxanim_props"]["endgame_machine_open"] = %o_zombie_end_game_open;
    level.scr_anim["fxanim_props"]["endgame_machine_close"] = %o_zombie_end_game_close;
    level.scr_anim["fxanim_props"]["gunsmith_sign"] = %fxanim_zom_buried_sign_gunsmith_anim;
    level.scr_anim["fxanim_props"]["corrugated_panels"] = %fxanim_zom_buried_corrugated_panels_anim;
    level.scr_anim["fxanim_props"]["clock_old"] = %fxanim_gp_clock_old_anim;
    level.scr_anim["fxanim_props"]["chandelier"] = %fxanim_gp_chandelier_anim;
    level.scr_anim["fxanim_props"]["track_board"] = %fxanim_zom_buried_track_board_anim;
    level.scr_anim["fxanim_props"]["wood_plank_hole"] = %fxanim_zom_buried_wood_plank_hole_anim;
    level.scr_anim["fxanim_props"]["wood_plank_bridge"] = %fxanim_zom_buried_wood_plank_bridge_anim;
    level.scr_anim["fxanim_props"]["drop_start"] = %fxanim_zom_buried_board_drop_start_anim;
    level.scr_anim["fxanim_props"]["rock_crusher"] = %fxanim_zom_buried_rock_crusher_anim;
    level.scr_anim["fxanim_props"]["rock_crusher_btm"] = %fxanim_zom_buried_rock_crusher_btm_anim;
    level.scr_anim["fxanim_props"]["piano_old"] = %fxanim_gp_piano_old_anim;
    level.scr_anim["fxanim_props"]["general_store_sign"] = %fxanim_zom_buried_sign_general_store_anim;
    level.scr_anim["fxanim_props"]["tree_vines"] = %fxanim_zom_buried_tree_vines_anim;
    level.scr_anim["fxanim_props"]["ice_cream_sign"] = %fxanim_zom_buried_sign_ice_cream_anim;
    level.scr_anim["fxanim_props"]["conveyor"] = %fxanim_zom_buried_conveyor_anim;
    level.scr_anim["fxanim_props"]["conveyor_lrg"] = %fxanim_zom_buried_conveyor_lrg_anim;
    level.scr_anim["fxanim_props"]["fountain_grave"] = %fxanim_zom_buried_fountain_grave_anim;
    level.scr_anim["fxanim_props"]["fountain_maze"] = %fxanim_zom_buried_fountain_maze_anim;
    level.scr_anim["fxanim_props"]["rocks_church"] = %fxanim_zom_buried_falling_rocks_church_anim;
    level.scr_anim["fxanim_props"]["rocks_graveyard"] = %fxanim_zom_buried_falling_rocks_graveyard_anim;
    level.scr_anim["fxanim_props"]["rocks_mansion"] = %fxanim_zom_buried_falling_rocks_mansion_anim;
    level.maze_switch_anim["switch_up"] = %o_zombie_maze_switch_up;
    level.maze_switch_anim["switch_down"] = %o_zombie_maze_switch_down;
    level.maze_switch_anim["switch_neutral"] = %o_zombie_maze_switch_neutral;
    level.scr_anim["fxanim_props"]["bank_sign"] = %fxanim_zom_buried_sign_bank_anim;
    scriptmodelsuseanimtree( -1 );
}
