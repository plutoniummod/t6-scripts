// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

register()
{
    game["teamset"] = [];
    game["teamset"]["cdc"] = ::cdc;
}

level_init()
{
    game["allies"] = "cdc";
    game["axis"] = "cia";
    setdvar( "g_TeamName_Allies", &"ZMUI_CDC_SHORT" );
    setdvar( "g_TeamName_Axis", &"ZMUI_CIA_SHORT" );
    game["strings"]["allies_win"] = &"ZM_CDC_WIN_MATCH";
    game["strings"]["allies_win_round"] = &"ZM_CDC_WIN_ROUND";
    game["strings"]["allies_mission_accomplished"] = &"ZM_CDC_MISSION_ACCOMPLISHED";
    game["strings"]["allies_eliminated"] = &"ZM_CDC_ELIMINATED";
    game["strings"]["allies_forfeited"] = &"ZM_CDC_FORFEITED";
    game["strings"]["allies_name"] = &"ZM_CDC_NAME";
    game["music"]["spawn_allies"] = "SPAWN_OPS";
    game["music"]["victory_allies"] = "mus_victory_usa";
    game["icons"]["allies"] = "faction_cdc";
    game["colors"]["allies"] = ( 0, 0, 0 );
    game["voice"]["allies"] = "vox_st6_";
    setdvar( "scr_allies", "marines" );
    game["strings"]["axis_win"] = &"ZM_CIA_WIN_MATCH";
    game["strings"]["axis_win_round"] = &"ZM_CIA_WIN_ROUND";
    game["strings"]["axis_mission_accomplished"] = &"ZM_CIA_MISSION_ACCOMPLISHED";
    game["strings"]["axis_eliminated"] = &"ZM_CIA_ELIMINATED";
    game["strings"]["axis_forfeited"] = &"ZM_CIA_FORFEITED";
    game["strings"]["axis_name"] = &"ZM_CIA_NAME";
    game["music"]["spawn_axis"] = "SPAWN_RUS";
    game["music"]["victory_axis"] = "mus_victory_soviet";
    game["icons"]["axis"] = "faction_cia";
    game["colors"]["axis"] = ( 0.65, 0.57, 0.41 );
    game["voice"]["axis"] = "vox_pmc_";
}

cdc()
{
    allies();
    axis();
}

allies()
{

}

axis()
{

}
