// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include codescripts\character;
#include character\character_sp_zombie_dog;

#using_animtree("zm_nuked_dog");

reference_anims_from_animtree()
{
    dummy_anim_ref = %zombie_dog_idle;
    dummy_anim_ref = %zombie_dog_attackidle_growl;
    dummy_anim_ref = %zombie_dog_attackidle;
    dummy_anim_ref = %zombie_dog_attackidle_bark;
    dummy_anim_ref = %zombie_dog_run_stop;
    dummy_anim_ref = %zombie_dog_run;
    dummy_anim_ref = %zombie_dog_trot;
    dummy_anim_ref = %zombie_dog_run_start;
    dummy_anim_ref = %zombie_dog_turn_90_left;
    dummy_anim_ref = %zombie_dog_turn_90_right;
    dummy_anim_ref = %zombie_dog_turn_180_left;
    dummy_anim_ref = %zombie_dog_turn_180_right;
    dummy_anim_ref = %zombie_dog_run_turn_90_left;
    dummy_anim_ref = %zombie_dog_run_turn_90_right;
    dummy_anim_ref = %zombie_dog_run_turn_180_left;
    dummy_anim_ref = %zombie_dog_run_turn_180_right;
    dummy_anim_ref = %zombie_dog_death_front;
    dummy_anim_ref = %zombie_dog_death_hit_back;
    dummy_anim_ref = %zombie_dog_death_hit_left;
    dummy_anim_ref = %zombie_dog_death_hit_right;
    dummy_anim_ref = %zombie_dog_run_attack;
    dummy_anim_ref = %zombie_dog_run_attack_low;
    dummy_anim_ref = %zombie_dog_run_jump_window_40;
    dummy_anim_ref = %zombie_dog_traverse_down_40;
    dummy_anim_ref = %zombie_dog_traverse_down_96;
    dummy_anim_ref = %zombie_dog_traverse_down_126;
    dummy_anim_ref = %zombie_dog_traverse_down_190;
    dummy_anim_ref = %zombie_dog_traverse_up_40;
    dummy_anim_ref = %zombie_dog_traverse_up_80;
    dummy_anim_ref = %ai_zombie_dog_jump_across_120;
}

main()
{
    self.accuracy = 0.2;
    self.animstatedef = "zm_nuked_dog.asd";
    self.animtree = "zm_nuked_dog.atr";
    self.csvinclude = "";
    self.demolockonhighlightdistance = 100;
    self.demolockonviewheightoffset1 = 8;
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
    self.type = "zombie_dog";
    self.weapon = "";
    self setengagementmindist( 256.0, 0.0 );
    self setengagementmaxdist( 768.0, 1024.0 );
    randchar = codescripts\character::get_random_character( 2 );

    switch ( randchar )
    {
        case 0:
            character\character_sp_zombie_dog::main();
            break;
        case 1:
            character\character_sp_zombie_dog::main();
            break;
    }

    self setcharacterindex( randchar );
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache( ai_index )
{
    level thread reference_anims_from_animtree();
    precacheanimstatedef( ai_index, #animtree, "zm_nuked_dog" );
    character\character_sp_zombie_dog::precache();
    character\character_sp_zombie_dog::precache();
}
