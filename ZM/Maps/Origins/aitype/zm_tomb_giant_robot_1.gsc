// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include character\c_zom_giant_robot_1;

#using_animtree("zm_tomb_giant_robot");

reference_anims_from_animtree()
{
    dummy_anim_ref = %ai_zombie_giant_robot_walk_a;
    dummy_anim_ref = %ai_zombie_giant_robot_walk_b;
    dummy_anim_ref = %ai_zombie_giant_robot_walk_nml_intro;
    dummy_anim_ref = %ai_zombie_giant_robot_walk_nml;
    dummy_anim_ref = %ai_zombie_giant_robot_walk_nml_outtro;
    dummy_anim_ref = %ai_zombie_giant_robot_walk_trenches_intro;
    dummy_anim_ref = %ai_zombie_giant_robot_walk_trenches;
    dummy_anim_ref = %ai_zombie_giant_robot_walk_trenches_outtro;
    dummy_anim_ref = %ai_zombie_giant_robot_walk_village_intro;
    dummy_anim_ref = %ai_zombie_giant_robot_walk_village;
    dummy_anim_ref = %ai_zombie_giant_robot_walk_village_outtro;
    dummy_anim_ref = %ai_zombie_giant_robot_bunker_intro;
}

main()
{
    self.accuracy = 1;
    self.animstatedef = "zm_tomb_giant_robot.asd";
    self.animtree = "zm_tomb_giant_robot.atr";
    self.csvinclude = "";
    self.demolockonhighlightdistance = 100;
    self.demolockonviewheightoffset1 = 60;
    self.demolockonviewheightoffset2 = 30;
    self.demolockonviewpitchmax1 = 60;
    self.demolockonviewpitchmax2 = 60;
    self.demolockonviewpitchmin1 = -15;
    self.demolockonviewpitchmin2 = -5;
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
    self.team = "neutral";
    self.type = "zombie";
    self.weapon = "";
    self setengagementmindist( 0.0, 0.0 );
    self setengagementmaxdist( 100.0, 300.0 );
    character\c_zom_giant_robot_1::main();
    self setcharacterindex( 0 );
}

spawner()
{
    self setspawnerteam( "neutral" );
}

precache( ai_index )
{
    level thread reference_anims_from_animtree();
    precacheanimstatedef( ai_index, -1, "zm_tomb_giant_robot" );
    character\c_zom_giant_robot_1::precache();
}
