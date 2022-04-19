// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\teams\_teamset;
#include mpbody\class_assault_isa;
#include mpbody\class_lmg_isa;
#include mpbody\class_shotgun_isa;
#include mpbody\class_smg_isa;
#include mpbody\class_sniper_isa;

main()
{
    init( "allies" );
    maps\mp\teams\_teamset::customteam_init();
    precache();
}

init( team )
{
    maps\mp\teams\_teamset::init();
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
    game["flagmodels"][team] = "mp_flag_allies_3";
    game["carry_flagmodels"][team] = "mp_flag_allies_3_carry";
    game["carry_icon"][team] = "hudicon_marines_ctf_flag_carry";
}

precache()
{
    mpbody\class_assault_isa::precache();
    mpbody\class_lmg_isa::precache();
    mpbody\class_shotgun_isa::precache();
    mpbody\class_smg_isa::precache();
    mpbody\class_sniper_isa::precache();
}
