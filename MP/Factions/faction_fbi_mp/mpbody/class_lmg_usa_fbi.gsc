// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;

precache()
{
    precachemodel( "c_usa_mp_fbi_lmg_fb" );
    precachemodel( "c_usa_mp_fbi_longsleeve_viewhands" );

    if ( level.multiteam )
        game["set_player_model"]["team3"]["mg"] = ::set_player_model;
    else
        game["set_player_model"]["allies"]["mg"] = ::set_player_model;
}

set_player_model()
{
    self setmodel( "c_usa_mp_fbi_lmg_fb" );
    self setviewmodel( "c_usa_mp_fbi_longsleeve_viewhands" );
    heads = [];
}
