// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include character\c_zom_dlc_mech;

#using_animtree("zm_tomb_mechz");

reference_anims_from_animtree()
{
    dummy_anim_ref = %ai_zombie_mech_death;
    dummy_anim_ref = %ai_zombie_mech_death_explode;
    dummy_anim_ref = %ai_zombie_mech_ft_aim_1;
    dummy_anim_ref = %ai_zombie_mech_ft_aim_2;
    dummy_anim_ref = %ai_zombie_mech_ft_aim_3;
    dummy_anim_ref = %ai_zombie_mech_ft_aim_4;
    dummy_anim_ref = %ai_zombie_mech_ft_aim_5;
    dummy_anim_ref = %ai_zombie_mech_ft_aim_6;
    dummy_anim_ref = %ai_zombie_mech_ft_aim_7;
    dummy_anim_ref = %ai_zombie_mech_ft_aim_8;
    dummy_anim_ref = %ai_zombie_mech_ft_aim_9;
    dummy_anim_ref = %ai_zombie_mech_ft_intro_sprint_to_aim_5;
    dummy_anim_ref = %ai_zombie_mech_ft_aim_idle;
    dummy_anim_ref = %ai_zombie_mech_ft_fire_end;
    dummy_anim_ref = %ai_zombie_mech_ft_fire_loop;
    dummy_anim_ref = %ai_zombie_mech_ft_fire_start;
    dummy_anim_ref = %ai_zombie_mech_ft_sweep;
    dummy_anim_ref = %ai_zombie_mech_ft_sweep_up;
    dummy_anim_ref = %ai_zombie_mech_ft_burn_player;
    dummy_anim_ref = %ai_zombie_mech_grapple_aim_1;
    dummy_anim_ref = %ai_zombie_mech_grapple_aim_2;
    dummy_anim_ref = %ai_zombie_mech_grapple_aim_3;
    dummy_anim_ref = %ai_zombie_mech_grapple_aim_4;
    dummy_anim_ref = %ai_zombie_mech_grapple_aim_5;
    dummy_anim_ref = %ai_zombie_mech_grapple_aim_6;
    dummy_anim_ref = %ai_zombie_mech_grapple_aim_7;
    dummy_anim_ref = %ai_zombie_mech_grapple_aim_8;
    dummy_anim_ref = %ai_zombie_mech_grapple_aim_9;
    dummy_anim_ref = %ai_zombie_mech_grapple_intro_sprint_to_aim_5;
    dummy_anim_ref = %ai_zombie_mech_grapple_arm_closed_idle;
    dummy_anim_ref = %ai_zombie_mech_grapple_arm_open_idle;
    dummy_anim_ref = %ai_zombie_mech_idle;
    dummy_anim_ref = %ai_zombie_mech_melee_a;
    dummy_anim_ref = %ai_zombie_mech_melee_b;
    dummy_anim_ref = %ai_zombie_mech_run_melee;
    dummy_anim_ref = %ai_zombie_mech_sprint_melee;
    dummy_anim_ref = %ai_zombie_mech_pain;
    dummy_anim_ref = %ai_zombie_mech_injury_hit_by_tank;
    dummy_anim_ref = %ai_zombie_mech_injury_down_by_tank_loop;
    dummy_anim_ref = %ai_zombie_mech_injury_recover_from_tank;
    dummy_anim_ref = %ai_zombie_mech_injury_hit_by_footstep;
    dummy_anim_ref = %ai_zombie_mech_injury_down_by_footstep_loop;
    dummy_anim_ref = %ai_zombie_mech_injury_recover_from_footstep;
    dummy_anim_ref = %ai_zombie_mech_stunned;
    dummy_anim_ref = %ai_zombie_mech_powercore_pain;
    dummy_anim_ref = %ai_zombie_mech_faceplate_pain;
    dummy_anim_ref = %ai_zombie_mech_head_pain;
    dummy_anim_ref = %ai_zombie_mech_run;
    dummy_anim_ref = %ai_zombie_mech_walk_basic;
    dummy_anim_ref = %ai_zombie_mech_walk_patrol;
    dummy_anim_ref = %ai_zombie_mech_sprint;
    dummy_anim_ref = %ai_zombie_mech_sprint_booster_liftoff;
    dummy_anim_ref = %ai_zombie_mech_sprint_booster_loop;
    dummy_anim_ref = %ai_zombie_mech_sprint_booster_touchdown;
    dummy_anim_ref = %ai_zombie_mech_intro_jump_in;
    dummy_anim_ref = %ai_zombie_mech_exit;
    dummy_anim_ref = %ai_zombie_mech_exit_hover;
    dummy_anim_ref = %ai_zombie_mech_arrive;
    dummy_anim_ref = %ai_zombie_mech_jump_down_48;
    dummy_anim_ref = %ai_zombie_mech_jump_down_72;
    dummy_anim_ref = %ai_zombie_mech_jump_down_96;
    dummy_anim_ref = %ai_zombie_mech_jump_down_127;
    dummy_anim_ref = %ai_zombie_mech_jump_up_48;
    dummy_anim_ref = %ai_zombie_mech_jump_up_96;
    dummy_anim_ref = %ai_zombie_mech_jump_up_127;
    dummy_anim_ref = %ai_zombie_mech_traverse_hurdle_40;
    dummy_anim_ref = %ai_zombie_mech_jump_across_120;
    dummy_anim_ref = %ai_zombie_mech_jump_down_church;
    dummy_anim_ref = %ai_zombie_mech_jump_down_dlc4_trench_wall_96;
    dummy_anim_ref = %ai_zombie_mech_jump_down_dlc4_trench_wall_112;
    dummy_anim_ref = %ai_zombie_mech_jump_down_dlc4_trench_wall_120;
    dummy_anim_ref = %ai_zombie_mech_jump_up_dlc4_trench_wall_140;
}

main()
{
    self.accuracy = 1;
    self.animstatedef = "zm_tomb_mechz.asd";
    self.animtree = "zm_tomb_mechz.atr";
    self.csvinclude = "";
    self.demolockonhighlightdistance = 100;
    self.demolockonviewheightoffset1 = 60;
    self.demolockonviewheightoffset2 = 30;
    self.demolockonviewpitchmax1 = 60;
    self.demolockonviewpitchmax2 = 60;
    self.demolockonviewpitchmin1 = -15;
    self.demolockonviewpitchmin2 = -5;
    self.footstepfxtable = "zm_mechz_footstepfxtable";
    self.footstepprepend = "fly_step_mechz";
    self.footstepscriptcallback = 1;
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
    character\c_zom_dlc_mech::main();
    self setcharacterindex( 0 );
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache( ai_index )
{
    level thread reference_anims_from_animtree();
    precacheanimstatedef( ai_index, #animtree, "zm_tomb_mechz" );
    character\c_zom_dlc_mech::precache();
}
