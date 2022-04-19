// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include character\c_zom_avogadro;

#using_animtree("zm_transit_avogadro");

reference_anims_from_animtree()
{
    dummy_anim_ref = %ai_zombie_avogadro_arrival;
    dummy_anim_ref = %ai_zombie_avogadro_exit;
    dummy_anim_ref = %ai_zombie_avogadro_bus_attack_back;
    dummy_anim_ref = %ai_zombie_avogadro_bus_attack_front;
    dummy_anim_ref = %ai_zombie_avogadro_bus_attack_left;
    dummy_anim_ref = %ai_zombie_avogadro_bus_attack_right;
    dummy_anim_ref = %ai_zombie_avogadro_bus_attack_knocked_off;
    dummy_anim_ref = %ai_zombie_avogadro_bus_pain_long;
    dummy_anim_ref = %ai_zombie_avogadro_bus_pain_med;
    dummy_anim_ref = %ai_zombie_avogadro_bus_pain_short;
    dummy_anim_ref = %ai_zombie_avogadro_bus_back_pain_long;
    dummy_anim_ref = %ai_zombie_avogadro_bus_back_pain_med;
    dummy_anim_ref = %ai_zombie_avogadro_bus_back_pain_short;
    dummy_anim_ref = %ai_zombie_avogadro_chamber_idle;
    dummy_anim_ref = %ai_zombie_avogadro_chamber_trans_out;
    dummy_anim_ref = %ai_zombie_avogadro_idle_v1;
    dummy_anim_ref = %ai_zombie_avogadro_melee_attack_v1;
    dummy_anim_ref = %ai_zombie_avogadro_pain_long;
    dummy_anim_ref = %ai_zombie_avogadro_pain_med;
    dummy_anim_ref = %ai_zombie_avogadro_pain_short;
    dummy_anim_ref = %ai_zombie_avogadro_ranged_attack_v1;
    dummy_anim_ref = %ai_zombie_avogadro_ranged_attack_v1_loop;
    dummy_anim_ref = %ai_zombie_avogadro_ranged_attack_v1_end;
    dummy_anim_ref = %ai_zombie_avogadro_run_v1;
    dummy_anim_ref = %ai_zombie_avogadro_run_v1_twitch;
    dummy_anim_ref = %ai_zombie_avogadro_sprint_v1;
    dummy_anim_ref = %ai_zombie_avogadro_sprint_v1_twitch;
    dummy_anim_ref = %ai_zombie_avogadro_walk_v1;
    dummy_anim_ref = %ai_zombie_avogadro_walk_v1_twitch;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_forward_long;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_forward_med;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_forward_short;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_left_long;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_left_med;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_left_short;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_right_long;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_right_med;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_right_short;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_back_long;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_back_med;
    dummy_anim_ref = %ai_zombie_avogadro_teleport_back_short;
    dummy_anim_ref = %ai_zombie_traverse_v1;
    dummy_anim_ref = %ai_zombie_traverse_v2;
    dummy_anim_ref = %ai_zombie_traverse_v5;
    dummy_anim_ref = %ai_zombie_traverse_v6;
    dummy_anim_ref = %ai_zombie_traverse_v7;
    dummy_anim_ref = %ai_zombie_traverse_crawl_v1;
    dummy_anim_ref = %ai_zombie_traverse_v4;
    dummy_anim_ref = %ai_zombie_climb_down_pothole;
    dummy_anim_ref = %ai_zombie_climb_up_pothole;
    dummy_anim_ref = %ai_zombie_jump_down_48;
    dummy_anim_ref = %ai_zombie_jump_down_96;
    dummy_anim_ref = %ai_zombie_jump_down_127;
    dummy_anim_ref = %ai_zombie_jump_down_190;
    dummy_anim_ref = %ai_zombie_jump_down_222;
    dummy_anim_ref = %ai_zombie_jump_up_127;
    dummy_anim_ref = %ai_zombie_jump_up_222;
    dummy_anim_ref = %ai_zombie_avogadro_jump_across_120;
    dummy_anim_ref = %ai_zombie_diner_roof_hatch_jump_up;
    dummy_anim_ref = %ai_zombie_traverse_diner_roof;
    dummy_anim_ref = %ai_zombie_jump_up_diner_roof;
    dummy_anim_ref = %ai_zombie_traverse_garage_roll;
    dummy_anim_ref = %ai_zombie_traverse_diner_counter_from_stools;
    dummy_anim_ref = %ai_zombie_traverse_diner_counter_to_stools;
    dummy_anim_ref = %ai_zombie_traverse_car;
    dummy_anim_ref = %ai_zombie_traverse_car_sprint;
    dummy_anim_ref = %ai_zombie_traverse_car_run;
    dummy_anim_ref = %ai_zombie_traverse_car_pass_to_driver_side;
}

main()
{
    self.accuracy = 1;
    self.animstatedef = "zm_transit_avogadro.asd";
    self.animtree = "zm_transit_avogadro.atr";
    self.csvinclude = "";
    self.demolockonhighlightdistance = 100;
    self.demolockonviewheightoffset1 = 70;
    self.demolockonviewheightoffset2 = 8;
    self.demolockonviewpitchmax1 = 60;
    self.demolockonviewpitchmax2 = 60;
    self.demolockonviewpitchmin1 = -15;
    self.demolockonviewpitchmin2 = 0;
    self.footstepfxtable = "";
    self.footstepprepend = "";
    self.footstepscriptcallback = 0;
    self.grenadeammo = 0;
    self.grenadeweapon = "";
    self.health = 200;
    self.precachescript = "";
    self.secondaryweapon = "";
    self.sidearm = "";
    self.subclass = "regular";
    self.team = "axis";
    self.type = "zombie";
    self.weapon = "";
    self setengagementmindist( 0.0, 0.0 );
    self setengagementmaxdist( 100.0, 300.0 );
    character\c_zom_avogadro::main();
    self setcharacterindex( 0 );
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache( ai_index )
{
    level thread reference_anims_from_animtree();
    precacheanimstatedef( ai_index, -1, "zm_transit_avogadro" );
    character\c_zom_avogadro::precache();
}
