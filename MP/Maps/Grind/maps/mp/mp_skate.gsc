// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_skate_fx;
#include maps\mp\_load;
#include maps\mp\mp_skate_amb;
#include maps\mp\_compass;
#include maps\mp\gametypes\_spawning;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_skate_fx::main();
    maps\mp\_load::main();
    maps\mp\mp_skate_amb::main();
    precachemodel( "collision_physics_cylinder_32x128" );
    precachemodel( "collision_clip_wall_128x128x10" );
    precachemodel( "collision_physics_clip_64x64x10" );
    precachemodel( "paris_construction_scaffold_piece_01" );
    maps\mp\_compass::setupminimap( "compass_map_mp_skate" );
    visionsetnaked( "mp_skate", 1 );
    setdvar( "compassmaxrange", "2100" );
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
    spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1045, -418.5, 292 ), vectorscale( ( 0, 1, 0 ), 359.8 ) );
    spawncollision( "collision_physics_cylinder_32x128", "collider", ( -720, -628, 292 ), vectorscale( ( 0, 1, 0 ), 355.6 ) );
    spawncollision( "collision_clip_wall_128x128x10", "collider", ( -2250.5, -837.5, 422.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_clip_wall_128x128x10", "collider", ( -2333, -837.5, 422.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( -663.5, -1975.5, 314 ), ( 0, 0, 0 ) );
    pipe1 = spawn( "script_model", ( -1368, -1541, 257 ) );
    pipe1.angles = vectorscale( ( 0, 1, 0 ), 90.0 );
    pipe1 setmodel( "paris_construction_scaffold_piece_01" );
    maps\mp\gametypes\_spawning::level_use_unified_spawning( 1 );
    level.remotemotarviewleft = 40;
    level.remotemotarviewright = 40;
    level.remotemotarviewup = 20;
    level.remotemotarviewdown = 65;
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2300", reset_dvars );
}
