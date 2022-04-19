// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_drone_fx;
#include maps\mp\_compass;
#include maps\mp\_load;
#include maps\mp\mp_drone_amb;
#include maps\mp\mp_drone_doors;

main()
{
    precachemodel( "fxanim_gp_robot_arm_welder_server_side_mod" );
    level.levelspawndvars = ::levelspawndvars;
    welders = [];
    welders[welders.size] = ( -1339.51, 76.04, 136.11 );
    welders[welders.size] = ( -1339.51, -171.9, 136.11 );
    welders[welders.size] = ( -1339.51, 559.04, 136.12 );
    welders[welders.size] = ( -1339.51, 312.01, 136.12 );
    maps\mp\mp_drone_fx::main();
    precachemodel( "collision_physics_wall_512x512x10" );
    precachemodel( "collision_physics_wall_256x256x10" );
    precachemodel( "collision_physics_256x256x10" );
    precachemodel( "collision_clip_32x32x10" );
    precachemodel( "collision_clip_128x128x10" );
    precachemodel( "collision_physics_128x128x128" );
    precachemodel( "collision_physics_32x32x128" );
    maps\mp\_compass::setupminimap( "compass_map_mp_drone" );
    maps\mp\_load::main();
    maps\mp\mp_drone_amb::main();
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
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -3252, -2085, -44 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -3763, -2085, -44 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_256x256x10", "collider", ( -4146, -2085, 88 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -2054, -2098, -56 ), ( 0, 0, 0 ) );
    spawncollision( "collision_clip_32x32x10", "collider", ( -1351, -1076, 202 ), ( 5.82444, 91.4567, 105.986 ) );
    spawncollision( "collision_clip_128x128x10", "collider", ( 33.5, -1386.25, 211.5 ), vectorscale( ( 0, 0, -1 ), 90.0 ) );
    spawncollision( "collision_physics_wall_256x256x10", "collider", ( -923.5, 2180, 366.5 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_physics_wall_256x256x10", "collider", ( -1050.5, 2303, 366.5 ), vectorscale( ( 0, 1, 0 ), 180.0 ) );
    spawncollision( "collision_physics_wall_256x256x10", "collider", ( -1306.5, 2303, 366.5 ), vectorscale( ( 0, 1, 0 ), 180.0 ) );
    spawncollision( "collision_physics_256x256x10", "collider", ( -1046.5, 2180, 489.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_256x256x10", "collider", ( -1302.5, 2180, 489.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( -1024, 2288, 352 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( -1197.5, 2589, 429.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( -1197.5, 2589, 565 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( -1217.5, 2602, 429.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( -1217.5, 2602, 565 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 335, 3507.5, 453 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 496.5, 3280, 478.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 440, 3272, 432 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 1109, 347.5, 305.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -1505, 1898, 754.5 ), ( 360, 180, 90.0003 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -1505, 2406, 754.5 ), ( 360, 180, 90.0003 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -1253.5, 1898, 503.5 ), ( 1.0, 270, 5.96 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -1253.5, 2406, 503.5 ), ( 1.0, 270, 5.96 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -1264.64, 2921.02, 754.5 ), ( 1.0, 133.4, 90 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -1091.83, 2738.29, 503.5 ), ( 1.0, 223.4, 5.96 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -1091.83, 3083.21, 503 ), ( 360, 136.6, -180 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -1504.82, 1671.75, 503 ), ( 1.0, 174.2, -180 ) );

    if ( getgametypesetting( "allowMapScripting" ) )
        level maps\mp\mp_drone_doors::init();

    level.remotemotarviewleft = 35;
    level.remotemotarviewright = 35;
    level.remotemotarviewup = 18;
    setheliheightpatchenabled( "war_mode_heli_height_lock", 0 );
    geo_changes();

    foreach ( welder in welders )
    {
        collision = spawn( "script_model", welder );
        collision setmodel( "fxanim_gp_robot_arm_welder_server_side_mod" );
    }
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
}

geo_changes()
{
    rts_floor = getent( "overwatch_floor", "targetname" );

    if ( isdefined( rts_floor ) )
        rts_floor delete();

    removes = getentarray( "rts_only", "targetname" );

    foreach ( removal in removes )
        removal delete();
}
