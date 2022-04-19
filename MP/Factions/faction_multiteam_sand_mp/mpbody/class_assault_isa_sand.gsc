// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;

precache()
{
    precachemodel( "c_usa_mp_isa_assault_ca_fb" );
    precachemodel( "c_usa_mp_isa_assault_ca_viewhands" );

    if ( level.multiteam )
        game["set_player_model"]["team5"]["default"] = ::set_player_model;
    else
        game["set_player_model"]["allies"]["default"] = ::set_player_model;
}

set_player_model()
{
    self setmodel( "c_usa_mp_isa_assault_ca_fb" );
    self setviewmodel( "c_usa_mp_isa_assault_ca_viewhands" );
    heads = [];
}
