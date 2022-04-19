// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\teams\_teamset;
#include mpbody\class_assault_chn_pla;
#include mpbody\class_lmg_chn_pla;
#include mpbody\class_shotgun_chn_pla;
#include mpbody\class_smg_chn_pla;
#include mpbody\class_sniper_chn_pla;

main()
{
    init( "axis" );
    maps\mp\teams\_teamset::customteam_init();
    precache();
}

init( team )
{
    maps\mp\teams\_teamset::init();
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

precache()
{
    mpbody\class_assault_chn_pla::precache();
    mpbody\class_lmg_chn_pla::precache();
    mpbody\class_shotgun_chn_pla::precache();
    mpbody\class_smg_chn_pla::precache();
    mpbody\class_sniper_chn_pla::precache();
}
