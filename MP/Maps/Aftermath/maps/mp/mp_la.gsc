// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\mp_la_fx;
#include maps\mp\_compass;
#include maps\mp\_load;
#include maps\mp\mp_la_amb;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_la_fx::main();

    if ( gamemodeismode( level.gamemode_wager_match ) )
        maps\mp\_compass::setupminimap( "compass_map_mp_la_wager" );
    else
        maps\mp\_compass::setupminimap( "compass_map_mp_la" );

    maps\mp\_load::main();
    maps\mp\mp_la_amb::main();
    game["strings"]["war_callsign_a"] = &"MPUI_CALLSIGN_MAPNAME_A";
    game["strings"]["war_callsign_b"] = &"MPUI_CALLSIGN_MAPNAME_B";
    game["strings"]["war_callsign_c"] = &"MPUI_CALLSIGN_MAPNAME_C";
    game["strings"]["war_callsign_d"] = &"MPUI_CALLSIGN_MAPNAME_D";
    game["strings"]["war_callsign_e"] = &"MPUI_CALLSIGN_MAPNAME_E";
    game["strings_menu"]["war_callsign_a"] = "@MPUI_CALLSIGN_MAPNAME_A";
    game["strings_menu"]["war_callsign_b"] = "@MPUI_CALLSIGN_MAPNAME_B";
    game["strings_menu"]["war_callsign_c"] = "@MPUI_CALLSIGN_MAPNAME_C";
    game["strings_menu"]["war_callsign_d"] = "@MPUI_CALLSIGN_MAPNAME_D";
    game["strings_menu"]["war_callsign_e"] = "@MPUI_CALLSIGN_MAPNAME_E";
    registerclientfield( "scriptmover", "police_car_lights", 1, 1, "int" );
    registerclientfield( "scriptmover", "ambulance_lights", 1, 1, "int" );
    level thread destructible_lights();
    level.remotemotarviewleft = 45;
    level.remotemotarviewright = 45;
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
}

destructible_lights()
{
    wait 0.05;
    destructibles = getentarray( "destructible", "targetname" );

    foreach ( destructible in destructibles )
    {
        if ( destructible.destructibledef == "veh_t6_police_car_destructible_mp" )
        {
            destructible thread destructible_think( "police_car_lights" );
            destructible setclientfield( "police_car_lights", 1 );
            continue;
        }

        if ( destructible.destructibledef == "veh_iw_civ_ambulance_destructible" )
        {
            destructible thread destructible_think( "ambulance_lights" );
            destructible setclientfield( "ambulance_lights", 1 );
        }
    }
}

destructible_think( clientfield )
{
    self waittill_any( "death", "destructible_base_piece_death" );
    self setclientfield( clientfield, 0 );
}
