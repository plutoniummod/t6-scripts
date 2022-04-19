// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self setmodel( "c_zom_leaper_body" );
    self.headmodel = "c_zom_leaper_head";
    self attach( self.headmodel, "", 1 );
    self.voice = "american";
    self.skeleton = "base";
    self.torsodmg1 = "c_zom_leaper_body_g_upclean";
    self.torsodmg5 = "c_zom_leaper_body_g_behead";
    self.legdmg1 = "c_zom_leaper_body_g_lowclean";
}

precache()
{
    precachemodel( "c_zom_leaper_body" );
    precachemodel( "c_zom_leaper_head" );
    precachemodel( "c_zom_leaper_body_g_upclean" );
    precachemodel( "c_zom_leaper_body_g_behead" );
    precachemodel( "c_zom_leaper_body_g_lowclean" );
}
