// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\teams\_teamset;
#include mpbody\class_assault_cd_sand;
#include mpbody\class_lmg_cd_sand;
#include mpbody\class_shotgun_cd_sand;
#include mpbody\class_smg_cd_sand;
#include mpbody\class_sniper_cd_sand;

main()
{
    init( "axis" );
    maps\mp\teams\_teamset::customteam_init();
    precache();
}

init( team )
{
    maps\mp\teams\_teamset::init();
    game[team] = "cd";
    game["defenders"] = team;
    precacheshader( "faction_cd" );
    game["entity_headicon_" + team] = "faction_cd";
    game["headicon_" + team] = "faction_cd";
    level.teamprefix[team] = "vox_cd";
    level.teampostfix[team] = "cda";
    setdvar( "g_TeamName_" + team, &"MPUI_CD_SHORT" );
    setdvar( "g_TeamColor_" + team, "0.65 0.57 0.41" );
    setdvar( "g_ScoresColor_" + team, "0.65 0.57 0.41" );
    setdvar( "g_FactionName_" + team, "cd" );
    game["strings"][team + "_win"] = &"MP_CD_WIN_MATCH";
    game["strings"][team + "_win_round"] = &"MP_CD_WIN_ROUND";
    game["strings"][team + "_mission_accomplished"] = &"MP_CD_MISSION_ACCOMPLISHED";
    game["strings"][team + "_eliminated"] = &"MP_CD_ELIMINATED";
    game["strings"][team + "_forfeited"] = &"MP_CD_FORFEITED";
    game["strings"][team + "_name"] = &"MP_CD_NAME";
    game["music"]["spawn_" + team] = "SPAWN_TER";
    game["music"]["spawn_short" + team] = "SPAWN_SHORT_TER";
    game["music"]["victory_" + team] = "VICTORY_TER";
    game["icons"][team] = "faction_cd";
    game["voice"][team] = "vox_cda_";
    setdvar( "scr_" + team, "ussr" );
    level.heli_vo[team]["hit"] = "vox_ops_2_kls_attackheli_hit";
    game["flagmodels"][team] = "mp_flag_axis_3";
    game["carry_flagmodels"][team] = "mp_flag_axis_3_carry";
    game["carry_icon"][team] = "hudicon_spetsnaz_ctf_flag_carry";
}

precache()
{
    mpbody\class_assault_cd_sand::precache();
    mpbody\class_lmg_cd_sand::precache();
    mpbody\class_shotgun_cd_sand::precache();
    mpbody\class_smg_cd_sand::precache();
    mpbody\class_sniper_cd_sand::precache();
}
