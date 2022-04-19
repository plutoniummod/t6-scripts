// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;

precache()
{
    precachemodel( "c_mul_mp_cordis_lmg_ca_fb" );
    precachemodel( "c_mul_mp_cordis_lmg_viewhands" );

    if ( level.multiteam )
        game["set_player_model"]["team6"]["mg"] = ::set_player_model;
    else
        game["set_player_model"]["axis"]["mg"] = ::set_player_model;
}

set_player_model()
{
    self setmodel( "c_mul_mp_cordis_lmg_ca_fb" );
    self setviewmodel( "c_mul_mp_cordis_lmg_viewhands" );
    heads = [];
}
