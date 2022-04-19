// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_castaway_fx;
#include maps\mp\_load;
#include maps\mp\mp_castaway_amb;
#include maps\mp\_compass;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_castaway_fx::main();
    precachemodel( "collision_physics_64x64x10" );
    precachemodel( "collision_clip_64x64x10" );
    precachemodel( "collision_physics_128x128x10" );
    precachemodel( "p6_cas_rock_medium_02_trimmed" );
    maps\mp\_load::main();
    maps\mp\mp_castaway_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_castaway" );
    setdvar( "compassmaxrange", "2100" );
    setdvar( "bg_dog_swim_enabled", 1 );
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
    spawncollision( "collision_physics_64x64x10", "collider", ( -1181, 1602, 242 ), ( 9.8, 270, 106 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( -1181, 1635, 242 ), ( 9.81, 270, 106 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( -1174, 1602, 197 ), ( 360, 270, 90 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( -1174, 1635, 197 ), ( 360, 270, 90 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( -329, 656, 123 ), ( 359.424, 286.385, 127.196 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( -342, 699, 124 ), ( 354.888, 295.033, 125.723 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( -707, 2358, 145 ), vectorscale( ( 1, 0, 0 ), 90.0 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 407.5, 518, 103 ), vectorscale( ( 1, 0, 0 ), 270.0 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 381, 552, 103 ), ( 270, 65.4, 6.57 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 343, 559, 103 ), ( 270, 112.8, 0 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 370.5, 526, 128.5 ), vectorscale( ( 0, 1, 0 ), 66.2 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 357, 525, 129.5 ), vectorscale( ( 0, 1, 0 ), 23.0 ) );
    rock1 = spawn( "script_model", ( 373.607, 484.974, 42.6 ) );
    rock1.angles = ( 350.899, 243.975, 4.02471 );
    rock1 setmodel( "p6_cas_rock_medium_02_trimmed" );
    spawncollision( "collision_physics_64x64x10", "collider", ( 479.5, 270, 75 ), ( 346.453, 344.758, 4.31137 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( 477.5, 270, 76 ), ( 349.833, 342.352, 15.9726 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( 1503, 186, 121 ), ( 16.2357, 331.376, -70.4431 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( 1571, 147, 97 ), ( 16.2357, 331.376, -70.4431 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 1411, 118.5, 161.5 ), ( 4.9243, 334.331, 80.0809 ) );
    level.levelkothdisable = [];
    level.levelkothdisable[level.levelkothdisable.size] = spawn( "trigger_radius", ( 281.5, 443.5, 161 ), 0, 50, 50 );
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2200", reset_dvars );
    ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "1000", reset_dvars );
    ss.hq_objective_influencer_radius = 3000;
}
