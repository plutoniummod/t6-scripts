// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include codescripts\character;
#include xmodelalias\c_zom_zombie_head_als;

main()
{
    self setmodel( "c_zom_zombie5_body02" );
    self.headmodel = codescripts\character::randomelement( xmodelalias\c_zom_zombie_head_als::main() );
    self attach( self.headmodel, "", 1 );
    self.voice = "american";
    self.skeleton = "base";
    self.torsodmg1 = "c_zom_zombie5_body02_g_upclean";
    self.torsodmg2 = "c_zom_zombie5_body02_g_rarmoff";
    self.torsodmg3 = "c_zom_zombie5_body02_g_larmoff";
    self.torsodmg5 = "c_zom_zombie2_body01_g_behead";
    self.legdmg1 = "c_zom_zombie5_body02_g_lowclean";
    self.legdmg2 = "c_zom_zombie5_body02_g_rlegoff";
    self.legdmg3 = "c_zom_zombie5_body02_g_llegoff";
    self.legdmg4 = "c_zom_zombie5_body02_g_legsoff";
    self.gibspawn1 = "c_zom_zombie_g_rarmspawn";
    self.gibspawntag1 = "J_Elbow_RI";
    self.gibspawn2 = "c_zom_zombie_g_larmspawn";
    self.gibspawntag2 = "J_Elbow_LE";
    self.gibspawn3 = "c_zom_zombie_g_rlegspawn";
    self.gibspawntag3 = "J_Knee_RI";
    self.gibspawn4 = "c_zom_zombie_g_llegspawn";
    self.gibspawntag4 = "J_Knee_LE";
}

precache()
{
    precachemodel( "c_zom_zombie5_body02" );
    codescripts\character::precachemodelarray( xmodelalias\c_zom_zombie_head_als::main() );
    precachemodel( "c_zom_zombie5_body02_g_upclean" );
    precachemodel( "c_zom_zombie5_body02_g_rarmoff" );
    precachemodel( "c_zom_zombie5_body02_g_larmoff" );
    precachemodel( "c_zom_zombie2_body01_g_behead" );
    precachemodel( "c_zom_zombie5_body02_g_lowclean" );
    precachemodel( "c_zom_zombie5_body02_g_rlegoff" );
    precachemodel( "c_zom_zombie5_body02_g_llegoff" );
    precachemodel( "c_zom_zombie5_body02_g_legsoff" );
    precachemodel( "c_zom_zombie_g_rarmspawn" );
    precachemodel( "c_zom_zombie_g_larmspawn" );
    precachemodel( "c_zom_zombie_g_rlegspawn" );
    precachemodel( "c_zom_zombie_g_llegspawn" );
}
