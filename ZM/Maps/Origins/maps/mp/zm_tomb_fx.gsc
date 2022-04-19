// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\createfx\zm_tomb_fx;

main()
{
    precache_createfx_fx();
    precache_scripted_fx();
    precache_fxanim_props();
    precache_fxanim_props_dlc4();
    maps\mp\createfx\zm_tomb_fx::main();
}

precache_scripted_fx()
{
    level._effect["eye_glow_blue"] = loadfx( "maps/zombie/fx_zombie_eye_single_blue" );
    level._effect["switch_sparks"] = loadfx( "env/electrical/fx_elec_wire_spark_burst" );
    level._effect["zapper_light_ready"] = loadfx( "maps/zombie_tomb/fx_tomb_capture_light_green" );
    level._effect["zapper_light_notready"] = loadfx( "maps/zombie_tomb/fx_tomb_capture_light_red" );
    level._effect["m14_zm_fx"] = loadfx( "maps/zombie/fx_zmb_wall_buy_rifle" );
    level._effect["fx_tomb_ee_vortex"] = loadfx( "maps/zombie_tomb/fx_tomb_ee_vortex" );
    level._effect["poltergeist"] = loadfx( "misc/fx_zombie_couch_effect" );
    level._effect["door_steam"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_doors_steam" );
    level._effect["zomb_gib"] = loadfx( "maps/zombie/fx_zmb_tranzit_lava_torso_explo" );
    level._effect["spawn_cloud"] = loadfx( "maps/zombie/fx_zmb_race_zombie_spawn_cloud" );
    level._effect["robot_foot_stomp"] = loadfx( "maps/zombie_tomb/fx_tomb_robot_dust" );
    level._effect["eject_warning"] = loadfx( "maps/zombie_tomb/fx_tomb_robot_eject_warning" );
    level._effect["eject_steam"] = loadfx( "maps/zombie_tomb/fx_tomb_robot_eject_steam" );
    level._effect["giant_robot_footstep_warning_light"] = loadfx( "maps/zombie_tomb/fx_tomb_foot_warning_light_red" );
    level._effect["air_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_elem_reveal_air_glow" );
    level._effect["elec_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_elem_reveal_elec_glow" );
    level._effect["fire_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_elem_reveal_fire_glow" );
    level._effect["ice_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_elem_reveal_ice_glow" );
    level._effect["digging"] = loadfx( "maps/zombie_tomb/fx_tomb_shovel_dig" );
    level._effect["mechz_death"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_death" );
    level._effect["mechz_sparks"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_dmg_sparks" );
    level._effect["mechz_steam"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_dmg_steam" );
    level._effect["mechz_claw"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_wpn_claw" );
    level._effect["mechz_claw_arm"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_wpn_source" );
    level._effect["staff_charge"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_charge" );
    level._effect["staff_soul"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_charge_souls" );
    level._effect["fire_muzzle"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_fire_muz_flash_1p" );
    level._effect["crypt_gem_beam"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_charge_souls" );
    level._effect["crypt_wall_drop"] = loadfx( "maps/zombie_tomb/fx_tomb_chamber_walls_impact" );
    level._effect["air_puzzle_smoke"] = loadfx( "maps/zombie_tomb/fx_tomb_puzzle_air_smoke" );
    level._effect["elec_piano_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_puzzle_elec_sparks" );
    level._effect["fire_ash_explosion"] = loadfx( "maps/zombie_tomb/fx_tomb_puzzle_fire_exp_ash" );
    level._effect["fire_sacrifice_flame"] = loadfx( "maps/zombie_tomb/fx_tomb_puzzle_fire_sacrifice" );
    level._effect["fire_torch"] = loadfx( "maps/zombie_tomb/fx_tomb_puzzle_fire_torch" );
    level._effect["ice_explode"] = loadfx( "maps/zombie_tomb/fx_tomb_puzzle_ice_pipe_burst" );
    level._effect["puzzle_orb_trail"] = loadfx( "maps/zombie_tomb/fx_tomb_puzzle_plinth_trail" );
    level._effect["teleport_1p"] = loadfx( "maps/zombie_tomb/fx_tomb_teleport_1p" );
    level._effect["teleport_3p"] = loadfx( "maps/zombie_tomb/fx_tomb_teleport_3p" );
    level._effect["teleport_air"] = loadfx( "maps/zombie_tomb/fx_tomb_portal_air" );
    level._effect["teleport_elec"] = loadfx( "maps/zombie_tomb/fx_tomb_portal_elec" );
    level._effect["teleport_fire"] = loadfx( "maps/zombie_tomb/fx_tomb_portal_fire" );
    level._effect["teleport_ice"] = loadfx( "maps/zombie_tomb/fx_tomb_portal_ice" );
    level._effect["tesla_elec_kill"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_zmb_tport" );
    level._effect["capture_progression"] = loadfx( "maps/zombie_tomb/fx_tomb_capture_progression" );
    level._effect["capture_complete"] = loadfx( "maps/zombie_tomb/fx_tomb_capture_complete" );
    level._effect["capture_exhaust"] = loadfx( "maps/zombie_tomb/fx_tomb_capture_exhaust_back" );
    level._effect["screecher_hole"] = loadfx( "maps/zombie_tomb/fx_tomb_screecher_vortex" );
    level._effect["zone_capture_zombie_spawn"] = loadfx( "maps/zombie_tomb/fx_tomb_emergence_spawn" );
    level._effect["crusader_zombie_eyes"] = loadfx( "maps/zombie/fx_zombie_crusader_eyes" );
    level._effect["zone_capture_zombie_torso_fx"] = loadfx( "maps/zombie_tomb/fx_tomb_crusader_torso_loop" );
    level._effect["player_rain"] = loadfx( "maps/zombie_tomb/fx_tomb_player_weather_rain" );
    level._effect["player_snow"] = loadfx( "maps/zombie_tomb/fx_tomb_player_weather_snow" );
    level._effect["lightning_flash"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_lightning_lg" );
    level._effect["tank_treads"] = loadfx( "maps/zombie_tomb/fx_tomb_veh_tank_treadfx_mud" );
    level._effect["tank_light_grn"] = loadfx( "maps/zombie_tomb/fx_tomb_capture_light_green" );
    level._effect["tank_light_red"] = loadfx( "maps/zombie_tomb/fx_tomb_capture_light_red" );
    level._effect["tank_overheat"] = loadfx( "maps/zombie_tomb/fx_tomb_veh_tank_exhaust_overheat" );
    level._effect["tank_exhaust"] = loadfx( "maps/zombie_tomb/fx_tomb_veh_tank_exhaust" );
    level._effect["bottle_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_portal" );
    level._effect["perk_pipe_smoke"] = loadfx( "maps/zombie_tomb/fx_tomb_perk_machine_exhaust" );
    level._effect["wagon_fire"] = loadfx( "maps/zombie_tomb/fx_tomb_ee_fire_wagon" );
    level._effect["zombie_fist_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_ee_fists" );
    level._effect["ee_vortex"] = loadfx( "maps/zombie_tomb/fx_tomb_ee_vortex" );
    level._effect["ee_beam"] = loadfx( "maps/zombie_tomb/fx_tomb_ee_beam" );
    level._effect["foot_box_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_challenge_fire" );
    level._effect["couch_fx"] = loadfx( "maps/zombie_tomb/fx_tomb_debris_blocker" );
    level._effect["sky_plane_tracers"] = loadfx( "maps/zombie_tomb/fx_tomb_sky_plane_tracers" );
    level._effect["sky_plane_trail"] = loadfx( "maps/zombie_tomb/fx_tomb_sky_plane_trail" );
    level._effect["biplane_explode"] = loadfx( "maps/zombie_tomb/fx_tomb_explo_airplane" );
    level._effect["special_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_elem_reveal_glow" );
}

precache_createfx_fx()
{
    level._effect["fx_sky_dist_aa_tracers"] = loadfx( "maps/zombie_tomb/fx_tomb_sky_dist_aa_tracers" );
    level._effect["fx_tomb_vortex_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_vortex_glow" );
    level._effect["fx_pack_a_punch"] = loadfx( "maps/zombie_tomb/fx_tomb_pack_a_punch_light_beams" );
    level._effect["fx_tomb_dust_fall"] = loadfx( "maps/zombie_tomb/fx_tomb_dust_fall" );
    level._effect["fx_tomb_dust_fall_lg"] = loadfx( "maps/zombie_tomb/fx_tomb_dust_fall_lg" );
    level._effect["fx_tomb_embers_flat"] = loadfx( "maps/zombie_tomb/fx_tomb_embers_flat" );
    level._effect["fx_tomb_fire_lg"] = loadfx( "maps/zombie_tomb/fx_tomb_fire_lg" );
    level._effect["fx_tomb_fire_sm"] = loadfx( "maps/zombie_tomb/fx_tomb_fire_sm" );
    level._effect["fx_tomb_fire_line_sm"] = loadfx( "maps/zombie_tomb/fx_tomb_fire_line_sm" );
    level._effect["fx_tomb_fire_sm_smolder"] = loadfx( "maps/zombie_tomb/fx_tomb_fire_sm_smolder" );
    level._effect["fx_tomb_ground_fog"] = loadfx( "maps/zombie_tomb/fx_tomb_ground_fog" );
    level._effect["fx_tomb_sparks"] = loadfx( "maps/zombie_tomb/fx_tomb_sparks" );
    level._effect["fx_tomb_water_drips"] = loadfx( "maps/zombie_tomb/fx_tomb_water_drips" );
    level._effect["fx_tomb_water_drips_sm"] = loadfx( "maps/zombie_tomb/fx_tomb_water_drips_sm" );
    level._effect["fx_tomb_smoke_pillar_xlg"] = loadfx( "maps/zombie_tomb/fx_tomb_smoke_pillar_xlg" );
    level._effect["fx_tomb_godray_md"] = loadfx( "maps/zombie_tomb/fx_tomb_godray_md" );
    level._effect["fx_tomb_godray_mist_md"] = loadfx( "maps/zombie_tomb/fx_tomb_godray_mist_md" );
    level._effect["fx_tomb_dust_motes_md"] = loadfx( "maps/zombie_tomb/fx_tomb_dust_motes_md" );
    level._effect["fx_tomb_dust_motes_lg"] = loadfx( "maps/zombie_tomb/fx_tomb_dust_motes_lg" );
    level._effect["fx_tomb_light_md"] = loadfx( "maps/zombie_tomb/fx_tomb_light_md" );
    level._effect["fx_tomb_light_lg"] = loadfx( "maps/zombie_tomb/fx_tomb_light_lg" );
    level._effect["fx_tomb_light_expensive"] = loadfx( "maps/zombie_tomb/fx_tomb_light_expensive" );
    level._effect["fx_tomb_steam_md"] = loadfx( "maps/zombie_tomb/fx_tomb_steam_md" );
    level._effect["fx_tomb_steam_lg"] = loadfx( "maps/zombie_tomb/fx_tomb_steam_lg" );
    level._effect["fx_tomb_church_fire_vista"] = loadfx( "maps/zombie_tomb/fx_tomb_church_fire_vista" );
    level._effect["fx_tomb_church_custom"] = loadfx( "maps/zombie_tomb/fx_tomb_church_custom" );
    level._effect["fx_tomb_chamber_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_chamber_glow" );
    level._effect["fx_tomb_chamber_glow_blue"] = loadfx( "maps/zombie_tomb/fx_tomb_chamber_glow_blue" );
    level._effect["fx_tomb_chamber_glow_purple"] = loadfx( "maps/zombie_tomb/fx_tomb_chamber_glow_purple" );
    level._effect["fx_tomb_chamber_glow_yellow"] = loadfx( "maps/zombie_tomb/fx_tomb_chamber_glow_yellow" );
    level._effect["fx_tomb_chamber_glow_red"] = loadfx( "maps/zombie_tomb/fx_tomb_chamber_glow_red" );
    level._effect["fx_tomb_chamber_walls_impact"] = loadfx( "maps/zombie_tomb/fx_tomb_chamber_walls_impact" );
    level._effect["fx_tomb_crafting_chamber_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_crafting_chamber_glow" );
    level._effect["fx_tomb_probe_elec_on"] = loadfx( "maps/zombie_tomb/fx_tomb_probe_elec_on" );
    level._effect["fx_tomb_robot_ambient"] = loadfx( "maps/zombie_tomb/fx_tomb_robot_ambient" );
    level._effect["fx_tomb_skybox_vortex"] = loadfx( "maps/zombie_tomb/fx_tomb_skybox_vortex" );
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["dogfights"] = %fxanim_zom_tomb_dogfights_anim;
}

#using_animtree("fxanim_props_dlc4");

precache_fxanim_props_dlc4()
{
    level.scr_anim["fxanim_props_dlc4"]["church_wires"] = %fxanim_zom_tomb_church_wires_anim;
    level.scr_anim["fxanim_props_dlc4"]["no_mans_wire"] = %fxanim_zom_tomb_no_mans_wire_anim;
    level.scr_anim["fxanim_props_dlc4"]["float_bunker"] = %fxanim_zom_tomb_debris_float_bunker_anim;
    level.scr_anim["fxanim_props_dlc4"]["chamber_rocks01"] = %fxanim_zom_tomb_chamber_rocks01_anim;
    level.scr_anim["fxanim_props_dlc4"]["chamber_rocks02"] = %fxanim_zom_tomb_chamber_rocks02_anim;
    level.scr_anim["fxanim_props_dlc4"]["head_fans"] = %fxanim_zom_tomb_robot_head_fans_anim;
    level.scr_anim["fxanim_props_dlc4"]["church_drain"] = %fxanim_zom_tomb_church_drain_anim;
    level.scr_anim["fxanim_props_dlc4"]["wires_ruins"] = %fxanim_zom_tomb_wires_ruins_anim;
    level.scr_anim["fxanim_props_dlc4"]["pap_ropes"] = %fxanim_zom_tomb_pap_ropes_anim;
    level.scr_anim["fxanim_props_dlc4"]["church_ceiling"] = %fxanim_zom_tomb_church_ceiling_anim;
    level.scr_anim["fxanim_props_dlc4"]["crane_hook"] = %fxanim_zom_tomb_crane_hook_anim;
}
