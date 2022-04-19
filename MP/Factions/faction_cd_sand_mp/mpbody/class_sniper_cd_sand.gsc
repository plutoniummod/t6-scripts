// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;

precache()
{
    precachemodel( "c_mul_mp_cordis_sniper_ca_fb" );
    precachemodel( "c_mul_mp_cordis_sniper_ca_viewhands" );

    if ( level.multiteam )
        game["set_player_model"]["team6"]["rifle"] = ::set_player_model;
    else
        game["set_player_model"]["axis"]["rifle"] = ::set_player_model;
}

set_player_model()
{
    self setmodel( "c_mul_mp_cordis_sniper_ca_fb" );
    self setviewmodel( "c_mul_mp_cordis_sniper_ca_viewhands" );
    heads = [];
}
