// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    if ( !isdefined( game["flagmodels"] ) )
        game["flagmodels"] = [];

    if ( !isdefined( game["carry_flagmodels"] ) )
        game["carry_flagmodels"] = [];

    if ( !isdefined( game["carry_icon"] ) )
        game["carry_icon"] = [];

    game["flagmodels"]["neutral"] = "mp_flag_neutral";
}

customteam_init()
{
    if ( getdvar( "g_customTeamName_Allies" ) != "" )
        setdvar( "g_TeamName_Allies", getdvar( "g_customTeamName_Allies" ) );

    if ( getdvar( "g_customTeamName_Axis" ) != "" )
        setdvar( "g_TeamName_Axis", getdvar( "g_customTeamName_Axis" ) );
}
