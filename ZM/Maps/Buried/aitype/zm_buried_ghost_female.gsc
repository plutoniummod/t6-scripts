// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include character\c_zom_zombie_buried_ghost_woman;

#using_animtree("zm_buried_ghost");

reference_anims_from_animtree()
{
    dummy_anim_ref = %ai_zombie_ghost_idle;
    dummy_anim_ref = %ai_zombie_ghost_supersprint;
    dummy_anim_ref = %ai_zombie_ghost_walk;
    dummy_anim_ref = %ai_zombie_ghost_melee;
    dummy_anim_ref = %ai_zombie_ghost_pointdrain;
    dummy_anim_ref = %ai_zombie_ghost_float_death;
    dummy_anim_ref = %ai_zombie_ghost_float_death_b;
    dummy_anim_ref = %ai_zombie_ghost_spawn;
    dummy_anim_ref = %ai_zombie_ghost_ground_pain;
    dummy_anim_ref = %ai_zombie_traverse_v1;
    dummy_anim_ref = %ai_zombie_traverse_v5;
    dummy_anim_ref = %ai_zombie_ghost_jump_across_120;
    dummy_anim_ref = %ai_zombie_ghost_jump_down_48;
    dummy_anim_ref = %ai_zombie_ghost_jump_down_72;
    dummy_anim_ref = %ai_zombie_ghost_jump_down_96;
    dummy_anim_ref = %ai_zombie_ghost_jump_down_127;
    dummy_anim_ref = %ai_zombie_ghost_jump_down_154;
    dummy_anim_ref = %ai_zombie_ghost_jump_down_176;
    dummy_anim_ref = %ai_zombie_ghost_jump_down_190;
    dummy_anim_ref = %ai_zombie_ghost_jump_down_222;
    dummy_anim_ref = %ai_zombie_ghost_jump_down_240;
    dummy_anim_ref = %ai_zombie_ghost_jump_up_72;
    dummy_anim_ref = %ai_zombie_ghost_jump_up_96;
    dummy_anim_ref = %ai_zombie_ghost_jump_up_127;
    dummy_anim_ref = %ai_zombie_ghost_jump_up_154;
    dummy_anim_ref = %ai_zombie_ghost_jump_up_176;
    dummy_anim_ref = %ai_zombie_ghost_jump_up_190;
    dummy_anim_ref = %ai_zombie_ghost_jump_up_222;
    dummy_anim_ref = %ai_zombie_ghost_jump_up_240;
    dummy_anim_ref = %ai_zombie_ghost_jump_up_startrailing;
    dummy_anim_ref = %ai_zombie_ghost_jump_down_startrailing;
    dummy_anim_ref = %ai_zombie_ghost_jump_up_48;
    dummy_anim_ref = %ai_zombie_ghost_playing_piano;
}

main()
{
    self.accuracy = 1;
    self.animstatedef = "zm_buried_ghost.asd";
    self.animtree = "zm_buried_ghost.atr";
    self.csvinclude = "";
    self.demolockonhighlightdistance = 100;
    self.demolockonviewheightoffset1 = 70;
    self.demolockonviewheightoffset2 = 8;
    self.demolockonviewpitchmax1 = 60;
    self.demolockonviewpitchmax2 = 60;
    self.demolockonviewpitchmin1 = -15;
    self.demolockonviewpitchmin2 = 0;
    self.footstepfxtable = "";
    self.footstepprepend = "fly_step_ghost";
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
    character\c_zom_zombie_buried_ghost_woman::main();
    self setcharacterindex( 0 );
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache( ai_index )
{
    level thread reference_anims_from_animtree();
    precacheanimstatedef( ai_index, #animtree, "zm_buried_ghost" );
    character\c_zom_zombie_buried_ghost_woman::precache();
}
