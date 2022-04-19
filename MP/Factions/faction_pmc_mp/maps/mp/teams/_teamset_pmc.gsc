// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\teams\_teamset;
#include mpbody\class_assault_rus_pmc;
#include mpbody\class_lmg_rus_pmc;
#include mpbody\class_shotgun_rus_pmc;
#include mpbody\class_smg_rus_pmc;
#include mpbody\class_sniper_rus_pmc;

main()
{
    init( "axis" );
    maps\mp\teams\_teamset::customteam_init();
    precache();
}

init( team )
{
    maps\mp\teams\_teamset::init();
    game[team] = "pmc";
    game["defenders"] = team;
    precacheshader( "faction_pmc" );
    game["entity_headicon_" + team] = "faction_pmc";
    game["headicon_" + team] = "faction_pmc";
    level.teamprefix[team] = "vox_pm";
    level.teampostfix[team] = "pmc";
    setdvar( "g_TeamName_" + team, &"MPUI_PMC_SHORT" );
    setdvar( "g_TeamColor_" + team, "0.65 0.57 0.41" );
    setdvar( "g_ScoresColor_" + team, "0.65 0.57 0.41" );
    setdvar( "g_FactionName_" + team, "rus_pmc" );
    game["strings"][team + "_win"] = &"MP_PMC_WIN_MATCH";
    game["strings"][team + "_win_round"] = &"MP_PMC_WIN_ROUND";
    game["strings"][team + "_mission_accomplished"] = &"MP_PMC_MISSION_ACCOMPLISHED";
    game["strings"][team + "_eliminated"] = &"MP_PMC_ELIMINATED";
    game["strings"][team + "_forfeited"] = &"MP_PMC_FORFEITED";
    game["strings"][team + "_name"] = &"MP_PMC_NAME";
    game["music"]["spawn_" + team] = "SPAWN_PMC";
    game["music"]["spawn_short" + team] = "SPAWN_SHORT_PMC";
    game["music"]["victory_" + team] = "VICTORY_PMC";
    game["icons"][team] = "faction_pmc";
    game["voice"][team] = "vox_pmc_";
    setdvar( "scr_" + team, "ussr" );
    level.heli_vo[team]["hit"] = "vox_rus_0_kls_attackheli_hit";
    game["flagmodels"][team] = "mp_flag_axis_2";
    game["carry_flagmodels"][team] = "mp_flag_axis_2_carry";
    game["carry_icon"][team] = "hudicon_spetsnaz_ctf_flag_carry";
}

precache()
{
    mpbody\class_assault_rus_pmc::precache();
    mpbody\class_lmg_rus_pmc::precache();
    mpbody\class_shotgun_rus_pmc::precache();
    mpbody\class_smg_rus_pmc::precache();
    mpbody\class_sniper_rus_pmc::precache();
}
