// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\teams\_teamset;
#include mpbody\class_assault_usa_seals;
#include mpbody\class_assault_usa_fbi;
#include mpbody\class_assault_rus_pmc;
#include mpbody\class_assault_chn_pla;
#include mpbody\class_assault_isa;
#include mpbody\class_assault_cd;

main()
{
    maps\mp\teams\_teamset::init();
    init_seals( "allies" );
    init_pla( "axis" );
    init_fbi( "team3" );
    init_pmc( "team4" );
    init_isa( "team5" );
    init_cd( "team6" );
    init_seals( "team7" );
    init_seals( "team8" );
    precache();
}

precache()
{
    mpbody\class_assault_usa_seals::precache();
    mpbody\class_assault_usa_fbi::precache();
    mpbody\class_assault_rus_pmc::precache();
    mpbody\class_assault_chn_pla::precache();
    mpbody\class_assault_isa::precache();
    mpbody\class_assault_cd::precache();
}

init_seals( team )
{
    game[team] = "seals";
    game["attackers"] = team;
    precacheshader( "faction_seals" );
    game["entity_headicon_" + team] = "faction_seals";
    game["headicon_" + team] = "faction_seals";
    level.teamprefix[team] = "vox_st";
    level.teampostfix[team] = "st6";
    setdvar( "g_TeamName_" + team, &"MPUI_SEALS_SHORT" );
    setdvar( "g_TeamColor_" + team, "0.6 0.64 0.69" );
    setdvar( "g_ScoresColor_" + team, "0.6 0.64 0.69" );
    setdvar( "g_FactionName_" + team, "usa_seals" );
    game["strings"][team + "_win"] = &"MP_SEALS_WIN_MATCH";
    game["strings"][team + "_win_round"] = &"MP_SEALS_WIN_ROUND";
    game["strings"][team + "_mission_accomplished"] = &"MP_SEALS_MISSION_ACCOMPLISHED";
    game["strings"][team + "_eliminated"] = &"MP_SEALS_ELIMINATED";
    game["strings"][team + "_forfeited"] = &"MP_SEALS_FORFEITED";
    game["strings"][team + "_name"] = &"MP_SEALS_NAME";
    game["music"]["spawn_" + team] = "SPAWN_ST6";
    game["music"]["spawn_short" + team] = "SPAWN_SHORT_ST6";
    game["music"]["victory_" + team] = "VICTORY_ST6";
    game["icons"][team] = "faction_seals";
    game["voice"][team] = "vox_st6_";
    setdvar( "scr_" + team, "marines" );
    level.heli_vo[team]["hit"] = "vox_ops_2_kls_attackheli_hit";
    game["flagmodels"][team] = "mp_flag_allies_1";
    game["carry_flagmodels"][team] = "mp_flag_allies_1_carry";
    game["carry_icon"][team] = "hudicon_marines_ctf_flag_carry";
}

init_pmc( team )
{
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
    game["flagmodels"][team] = "mp_flag_axis_1";
    game["carry_flagmodels"][team] = "mp_flag_axis_1_carry";
    game["carry_icon"][team] = "hudicon_spetsnaz_ctf_flag_carry";
}

init_pla( team )
{
    game[team] = "pla";
    game["defenders"] = team;
    precacheshader( "faction_pla" );
    game["entity_headicon_" + team] = "faction_pla";
    game["headicon_" + team] = "faction_pla";
    level.teamprefix[team] = "vox_ch";
    level.teampostfix[team] = "pla";
    setdvar( "g_TeamName_" + team, &"MPUI_PLA_SHORT" );
    setdvar( "g_TeamColor_" + team, "0.65 0.57 0.41" );
    setdvar( "g_ScoresColor_" + team, "0.65 0.57 0.41" );
    setdvar( "g_FactionName_" + team, "chn_pla" );
    game["strings"][team + "_win"] = &"MP_PLA_WIN_MATCH";
    game["strings"][team + "_win_round"] = &"MP_PLA_WIN_ROUND";
    game["strings"][team + "_mission_accomplished"] = &"MP_PLA_MISSION_ACCOMPLISHED";
    game["strings"][team + "_eliminated"] = &"MP_PLA_ELIMINATED";
    game["strings"][team + "_forfeited"] = &"MP_PLA_FORFEITED";
    game["strings"][team + "_name"] = &"MP_PLA_NAME";
    game["music"]["spawn_" + team] = "SPAWN_PLA";
    game["music"]["spawn_short" + team] = "SPAWN_SHORT_PLA";
    game["music"]["victory_" + team] = "VICTORY_PLA";
    game["icons"][team] = "faction_pla";
    game["voice"][team] = "vox_pla_";
    setdvar( "scr_" + team, "ussr" );
    level.heli_vo[team]["hit"] = "vox_rus_0_kls_attackheli_hit";
    game["flagmodels"][team] = "mp_flag_axis_1";
    game["carry_flagmodels"][team] = "mp_flag_axis_1_carry";
    game["carry_icon"][team] = "hudicon_spetsnaz_ctf_flag_carry";
}

init_fbi( team )
{
    game[team] = "fbi";
    game["attackers"] = team;
    precacheshader( "faction_fbi" );
    game["entity_headicon_" + team] = "faction_fbi";
    game["headicon_" + team] = "faction_fbi";
    level.teamprefix[team] = "vox_fbi";
    level.teampostfix[team] = "fbi";
    setdvar( "g_TeamName_" + team, &"MPUI_FBI_SHORT" );
    setdvar( "g_TeamColor_" + team, "0.6 0.64 0.69" );
    setdvar( "g_ScoresColor_" + team, "0.6 0.64 0.69" );
    setdvar( "g_FactionName_" + team, "usa_fbi" );
    game["strings"][team + "_win"] = &"MP_FBI_WIN_MATCH";
    game["strings"][team + "_win_round"] = &"MP_FBI_WIN_ROUND";
    game["strings"][team + "_mission_accomplished"] = &"MP_FBI_MISSION_ACCOMPLISHED";
    game["strings"][team + "_eliminated"] = &"MP_FBI_ELIMINATED";
    game["strings"][team + "_forfeited"] = &"MP_FBI_FORFEITED";
    game["strings"][team + "_name"] = &"MP_FBI_NAME";
    game["music"]["spawn_" + team] = "SPAWN_FBI";
    game["music"]["spawn_short" + team] = "SPAWN_SHORT_FBI";
    game["music"]["victory_" + team] = "VICTORY_FBI";
    game["icons"][team] = "faction_fbi";
    game["voice"][team] = "vox_fbi_";
    setdvar( "scr_" + team, "marines" );
    level.heli_vo[team]["hit"] = "vox_ops_2_kls_attackheli_hit";
    game["flagmodels"][team] = "mp_flag_allies_1";
    game["carry_flagmodels"][team] = "mp_flag_allies_1_carry";
    game["carry_icon"][team] = "hudicon_marines_ctf_flag_carry";
}

init_isa( team )
{
    game[team] = "isa";
    game["attackers"] = team;
    precacheshader( "faction_isa" );
    game["entity_headicon_" + team] = "faction_isa";
    game["headicon_" + team] = "faction_isa";
    level.teamprefix[team] = "vox_is";
    level.teampostfix[team] = "isa";
    setdvar( "g_TeamName_" + team, &"MPUI_ISA_SHORT" );
    setdvar( "g_TeamColor_" + team, "0.6 0.64 0.69" );
    setdvar( "g_ScoresColor_" + team, "0.6 0.64 0.69" );
    setdvar( "g_FactionName_" + team, "isa" );
    game["strings"][team + "_win"] = &"MP_ISA_WIN_MATCH";
    game["strings"][team + "_win_round"] = &"MP_ISA_WIN_ROUND";
    game["strings"][team + "_mission_accomplished"] = &"MP_ISA_MISSION_ACCOMPLISHED";
    game["strings"][team + "_eliminated"] = &"MP_ISA_ELIMINATED";
    game["strings"][team + "_forfeited"] = &"MP_ISA_FORFEITED";
    game["strings"][team + "_name"] = &"MP_ISA_NAME";
    game["music"]["spawn_" + team] = "SPAWN_CIA";
    game["music"]["spawn_short" + team] = "SPAWN_SHORT_CIA";
    game["music"]["victory_" + team] = "VICTORY_CIA";
    game["icons"][team] = "faction_isa";
    game["voice"][team] = "vox_isa_";
    setdvar( "scr_" + team, "marines" );
    level.heli_vo[team]["hit"] = "vox_ops_2_kls_attackheli_hit";
    game["flagmodels"][team] = "mp_flag_allies_1";
    game["carry_flagmodels"][team] = "mp_flag_allies_1_carry";
    game["carry_icon"][team] = "hudicon_marines_ctf_flag_carry";
}

init_cd( team )
{
    game[team] = "cd";
    game["attackers"] = team;
    precacheshader( "faction_cd" );
    game["entity_headicon_" + team] = "faction_cd";
    game["headicon_" + team] = "faction_cd";
    level.teamprefix[team] = "vox_cd";
    level.teampostfix[team] = "cda";
    setdvar( "g_TeamName_" + team, &"MPUI_CD_SHORT" );
    setdvar( "g_TeamColor_" + team, "0.6 0.64 0.69" );
    setdvar( "g_ScoresColor_" + team, "0.6 0.64 0.69" );
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
    level.heli_vo[team]["hit"] = "vox_cd2_kls_attackheli_hit";
    game["flagmodels"][team] = "mp_flag_axis_1";
    game["carry_flagmodels"][team] = "mp_flag_axis_1_carry";
    game["carry_icon"][team] = "hudicon_spetsnaz_ctf_flag_carry";
}
