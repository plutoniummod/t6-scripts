// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_downhill_fx;
#include maps\mp\_load;
#include maps\mp\mp_downhill_amb;
#include maps\mp\_compass;
#include maps\mp\gametypes\_spawning;
#include maps\mp\mp_downhill_cablecar;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_downhill_fx::main();
    precachemodel( "collision_physics_64x64x64" );
    precachemodel( "collision_clip_32x32x32" );
    precachemodel( "collision_clip_64x64x64" );
    precachemodel( "collision_physics_cylinder_32x128" );
    precachemodel( "collision_missile_32x32x128" );
    precachemodel( "collision_clip_64x64x64" );
    maps\mp\_load::main();
    maps\mp\mp_downhill_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_downhill" );
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
    spawncollision( "collision_physics_64x64x64", "collider", ( 969.01, -2355.43, 1014.87 ), ( 2.23119, 12.5057, -9.9556 ) );
    spawncollision( "collision_physics_64x64x64", "collider", ( 954.068, -2352.16, 1001.08 ), ( 3.17067, 17.931, -9.69974 ) );
    spawncollision( "collision_physics_64x64x64", "collider", ( 942.933, -2359.71, 1031.9 ), ( 3.17067, 17.931, -9.69974 ) );
    spawncollision( "collision_physics_cylinder_32x128", "collider", ( 368, -1378, 1015 ), vectorscale( ( 0, 1, 0 ), 24.9 ) );
    spawncollision( "collision_clip_64x64x64", "collider", ( 1268.5, -2518, 1062 ), vectorscale( ( 0, 1, 0 ), 349.0 ) );
    spawncollision( "collision_clip_64x64x64", "collider", ( 1122.5, 583.5, 959.5 ), vectorscale( ( 0, 1, 0 ), 41.2 ) );
    spawncollision( "collision_clip_32x32x32", "collider", ( 1895, -1428.5, 948 ), ( 0, 0, 0 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( 2431.5, -174, 1209.5 ), ( 0, 318.4, 90 ) );
    spawncollision( "collision_clip_64x64x64", "collider", ( 318, 1509, 1105 ), ( 0, 34.4, 90 ) );
    precachemodel( "fxanim_mp_downhill_cable_car_mod" );
    maps\mp\gametypes\_spawning::level_use_unified_spawning( 1 );
    level.cablecarlightsfx = loadfx( "maps/mp_maps/fx_mp_downhill_cablecar_lights" );
    level thread maps\mp\mp_downhill_cablecar::main();
    level.remotemotarviewleft = 40;
    level.remotemotarviewright = 40;
    level.remotemotarviewup = 15;
    level.remotemotarviewdown = 65;
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
}
