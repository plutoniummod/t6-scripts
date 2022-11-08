// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include character\c_zom_screecher;

#using_animtree("zm_transit_screecher");

reference_anims_from_animtree()
{
    dummy_anim_ref = %ai_zombie_screecher_burrow_into_ground;
    dummy_anim_ref = %ai_zombie_screecher_climb_down_pothole;
    dummy_anim_ref = %ai_zombie_screecher_climb_up_pothole;
    dummy_anim_ref = %ai_zombie_screecher_cower_v1;
    dummy_anim_ref = %ai_zombie_screecher_death_v1;
    dummy_anim_ref = %ai_zombie_screecher_headpull;
    dummy_anim_ref = %ai_zombie_screecher_headpull_fail;
    dummy_anim_ref = %ai_zombie_screecher_headpull_success;
    dummy_anim_ref = %ai_zombie_screecher_jump_land_fail;
    dummy_anim_ref = %ai_zombie_screecher_jump_land_success_fromback;
    dummy_anim_ref = %ai_zombie_screecher_jump_land_success_fromfront;
    dummy_anim_ref = %ai_zombie_screecher_jump_loop;
    dummy_anim_ref = %ai_zombie_screecher_jump_up;
    dummy_anim_ref = %ai_zombie_screecher_run;
    dummy_anim_ref = %ai_zombie_screecher_run_bounce;
    dummy_anim_ref = %ai_zombie_screecher_run_hop;
    dummy_anim_ref = %ai_zombie_screecher_run_zigzag;
    dummy_anim_ref = %ai_zombie_screecher_tunnel_traversal;
    dummy_anim_ref = %ai_zombie_screecher_diner_roof_hatch_jump_up;
    dummy_anim_ref = %ai_zombie_screecher_traverse_car;
    dummy_anim_ref = %ai_zombie_screecher_traverse_car_pass_to_driver_side;
    dummy_anim_ref = %ai_zombie_screecher_traverse_ground_v1;
    dummy_anim_ref = %ai_zombie_screecher_jump_down_96;
    dummy_anim_ref = %ai_zombie_screecher_jump_down_127;
    dummy_anim_ref = %ai_zombie_screecher_jump_up_127;
}

main()
{
    self.accuracy = 1;
    self.animstatedef = "zm_transit_screecher.asd";
    self.animtree = "zm_transit_screecher.atr";
    self.csvinclude = "";
    self.demolockonhighlightdistance = 100;
    self.demolockonviewheightoffset1 = 18;
    self.demolockonviewheightoffset2 = 8;
    self.demolockonviewpitchmax1 = 60;
    self.demolockonviewpitchmax2 = 60;
    self.demolockonviewpitchmin1 = 0;
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
    character\c_zom_screecher::main();
    self setcharacterindex( 0 );
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache( ai_index )
{
    level thread reference_anims_from_animtree();
    precacheanimstatedef( ai_index, #animtree, "zm_transit_screecher" );
    character\c_zom_screecher::precache();
}
