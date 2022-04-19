// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include codescripts\character;
#include xmodelalias\c_zom_zombie_buried_male_heads_als;
#include xmodelalias\c_zom_zombie_buried_civilian_hat4_als;

main()
{
    self setmodel( "c_zom_zombie_buried_civilian_body4_nohat" );
    self.headmodel = codescripts\character::randomelement( xmodelalias\c_zom_zombie_buried_male_heads_als::main() );
    self attach( self.headmodel, "", 1 );
    self.hatmodel = codescripts\character::randomelement( xmodelalias\c_zom_zombie_buried_civilian_hat4_als::main() );
    self attach( self.hatmodel, "", 1 );
    self.voice = "american";
    self.skeleton = "base";
    self.torsodmg1 = "c_zom_zombie_buried_civilian_g_upclean4";
    self.torsodmg2 = "c_zom_zombie_buried_civilian_g_rarmoff4";
    self.torsodmg3 = "c_zom_zombie_buried_civilian_g_larmoff4";
    self.torsodmg5 = "c_zom_zombie_buried_civilian_g_behead";
    self.legdmg1 = "c_zom_zombie_buried_civilian_g_lowclean4";
    self.legdmg2 = "c_zom_zombie_buried_civilian_g_rlegoff4";
    self.legdmg3 = "c_zom_zombie_buried_civilian_g_llegoff4";
    self.legdmg4 = "c_zom_zombie_buried_civilian_g_legsoff4";
    self.gibspawn1 = "c_zom_buried_g_rarmspawn";
    self.gibspawntag1 = "J_Elbow_RI";
    self.gibspawn2 = "c_zom_buried_g_larmspawn";
    self.gibspawntag2 = "J_Elbow_LE";
    self.gibspawn3 = "c_zom_buried_g_rlegspawn";
    self.gibspawntag3 = "J_Knee_RI";
    self.gibspawn4 = "c_zom_buried_g_llegspawn";
    self.gibspawntag4 = "J_Knee_LE";
}

precache()
{
    precachemodel( "c_zom_zombie_buried_civilian_body4_nohat" );
    codescripts\character::precachemodelarray( xmodelalias\c_zom_zombie_buried_male_heads_als::main() );
    codescripts\character::precachemodelarray( xmodelalias\c_zom_zombie_buried_civilian_hat4_als::main() );
    precachemodel( "c_zom_zombie_buried_civilian_g_upclean4" );
    precachemodel( "c_zom_zombie_buried_civilian_g_rarmoff4" );
    precachemodel( "c_zom_zombie_buried_civilian_g_larmoff4" );
    precachemodel( "c_zom_zombie_buried_civilian_g_behead" );
    precachemodel( "c_zom_zombie_buried_civilian_g_lowclean4" );
    precachemodel( "c_zom_zombie_buried_civilian_g_rlegoff4" );
    precachemodel( "c_zom_zombie_buried_civilian_g_llegoff4" );
    precachemodel( "c_zom_zombie_buried_civilian_g_legsoff4" );
    precachemodel( "c_zom_buried_g_rarmspawn" );
    precachemodel( "c_zom_buried_g_larmspawn" );
    precachemodel( "c_zom_buried_g_rlegspawn" );
    precachemodel( "c_zom_buried_g_llegspawn" );
}
