// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include character\c_zom_cellbreaker;

#using_animtree("zm_alcatraz_brutus");

reference_anims_from_animtree()
{
    dummy_anim_ref = %ai_zombie_cellbreaker_attack_swingleft;
    dummy_anim_ref = %ai_zombie_cellbreaker_attack_swingright_a;
    dummy_anim_ref = %ai_zombie_cellbreaker_attack_swingright_b;
    dummy_anim_ref = %ai_zombie_cellbreaker_death;
    dummy_anim_ref = %ai_zombie_cellbreaker_death_a;
    dummy_anim_ref = %ai_zombie_cellbreaker_death_explode;
    dummy_anim_ref = %ai_zombie_cellbreaker_death_mg;
    dummy_anim_ref = %ai_zombie_cellbreaker_tesla_death_a;
    dummy_anim_ref = %ai_zombie_cellbreaker_enrage_start;
    dummy_anim_ref = %ai_zombie_cellbreaker_idle_a;
    dummy_anim_ref = %ai_zombie_cellbreaker_idle_b;
    dummy_anim_ref = %ai_zombie_cellbreaker_run_a;
    dummy_anim_ref = %ai_zombie_cellbreaker_run_b;
    dummy_anim_ref = %ai_zombie_cellbreaker_run_c;
    dummy_anim_ref = %ai_zombie_cellbreaker_run_d;
    dummy_anim_ref = %ai_zombie_cellbreaker_sprint_a;
    dummy_anim_ref = %ai_zombie_cellbreaker_sprint_b;
    dummy_anim_ref = %ai_zombie_cellbreaker_walk_a;
    dummy_anim_ref = %ai_zombie_cellbreaker_boardsmash_a;
    dummy_anim_ref = %ai_zombie_cellbreaker_boardsmash_b;
    dummy_anim_ref = %ai_zombie_cellbreaker_boardsmash_c;
    dummy_anim_ref = %ai_zombie_cellbreaker_lock_magicbox;
    dummy_anim_ref = %ai_zombie_cellbreaker_lock_perkmachine;
    dummy_anim_ref = %ai_zombie_cellbreaker_lock_planeramp;
    dummy_anim_ref = %ai_zombie_cellbreaker_bullcharge_tell;
    dummy_anim_ref = %ai_zombie_cellbreaker_gasattack;
    dummy_anim_ref = %ai_zombie_cellbreaker_headpain;
    dummy_anim_ref = %ai_zombie_cellbreaker_spawn;
    dummy_anim_ref = %ai_zombie_cellbreaker_stumble_running;
    dummy_anim_ref = %ai_zombie_cellbreaker_summondogs;
}

main()
{
    self.accuracy = 1;
    self.animstatedef = "zm_alcatraz_brutus.asd";
    self.animtree = "zm_alcatraz_brutus.atr";
    self.csvinclude = "";
    self.demolockonhighlightdistance = 100;
    self.demolockonviewheightoffset1 = 60;
    self.demolockonviewheightoffset2 = 30;
    self.demolockonviewpitchmax1 = 60;
    self.demolockonviewpitchmax2 = 60;
    self.demolockonviewpitchmin1 = -15;
    self.demolockonviewpitchmin2 = -5;
    self.footstepfxtable = "zm_brutus_footstepfxtable";
    self.footstepprepend = "fly_step_brutus";
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
    character\c_zom_cellbreaker::main();
    self setcharacterindex( 0 );
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache( ai_index )
{
    level thread reference_anims_from_animtree();
    precacheanimstatedef( ai_index, #animtree, "zm_alcatraz_brutus" );
    character\c_zom_cellbreaker::precache();
}
