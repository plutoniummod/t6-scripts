// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;

precache()
{
    precachemodel( "c_chn_mp_pla_sniper_w_fb" );
    precachemodel( "c_chn_mp_pla_longsleeve_w_viewhands" );

    if ( level.multiteam )
        game["set_player_model"]["axis"]["rifle"] = ::set_player_model;
    else
        game["set_player_model"]["axis"]["rifle"] = ::set_player_model;
}

set_player_model()
{
    self setmodel( "c_chn_mp_pla_sniper_w_fb" );
    self setviewmodel( "c_chn_mp_pla_longsleeve_w_viewhands" );
    heads = [];
}
