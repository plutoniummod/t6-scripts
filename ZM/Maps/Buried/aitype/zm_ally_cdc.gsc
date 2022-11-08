// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include character\c_zom_ally_cdc;

#using_animtree("zm_ally");

reference_anims_from_animtree()
{
    dummy_anim_ref = %pb_laststand_idle;
    dummy_anim_ref = %pb_stand_alert;
    dummy_anim_ref = %pb_crouch_alert;
    dummy_anim_ref = %pb_afterlife_laststand_idle;
    dummy_anim_ref = %ai_actor_elec_chair_idle;
}

main()
{
    self.accuracy = 1;
    self.animstatedef = "zm_ally_basic.asd";
    self.animtree = "zm_ally.atr";
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
    self.team = "allies";
    self.type = "zombie";
    self.weapon = "";
    self setengagementmindist( 0.0, 0.0 );
    self setengagementmaxdist( 100.0, 300.0 );
    character\c_zom_ally_cdc::main();
    self setcharacterindex( 0 );
}

spawner()
{
    self setspawnerteam( "allies" );
}

precache( ai_index )
{
    level thread reference_anims_from_animtree();
    precacheanimstatedef( ai_index, #animtree, "zm_ally_basic" );
    character\c_zom_ally_cdc::precache();
}
