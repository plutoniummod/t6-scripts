// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\mp_la_fx;
#include maps\mp\_compass;
#include maps\mp\_load;
#include maps\mp\mp_la_amb;
#include maps\mp\killstreaks\_turret_killstreak;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_la_fx::main();
    precachemodel( "collision_clip_wall_64x64x10" );
    precachemodel( "collision_physics_wall_64x64x10" );
    precachemodel( "collision_physics_wall_32x32x10" );
    precachemodel( "collision_physics_256x256x256" );
    precachemodel( "collision_physics_64x64x10" );
    precachemodel( "collision_physics_128x128x10" );
    precachemodel( "collision_clip_64x64x10" );
    precachemodel( "collision_physics_cylinder_32x128" );
    precachemodel( "collision_clip_wall_256x256x10" );
    precachemodel( "collision_physics_128x128x128" );
    precachemodel( "collision_clip_128x128x10" );
    precachemodel( "collision_physics_wall_256x256x10" );
    precachemodel( "collision_physics_wall_128x128x10" );
    precachemodel( "p6_building_granite_tan_brokenb" );

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
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( -698, 2945, 28 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( -698, 2984, 28 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_physics_wall_32x32x10", "collider", ( -1606, 3027, 154 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_physics_wall_32x32x10", "collider", ( -1614, 3010, 204 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_physics_wall_64x64x10", "collider", ( -1610, 1860, 203 ), ( 26, 271, 17 ) );
    spawncollision( "collision_physics_wall_256x256x10", "collider", ( -849, 3145.5, -94.5 ), vectorscale( ( 0, 1, 0 ), 276.1 ) );
    spawncollision( "collision_physics_wall_256x256x10", "collider", ( -835, 3013.5, -119 ), vectorscale( ( 0, 1, 0 ), 276.1 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -795.5, 3208.5, 3.5 ), vectorscale( ( 0, 1, 0 ), 5.99995 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -783, 3080.5, 3.5 ), vectorscale( ( 0, 1, 0 ), 7.2 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -767.5, 2953.5, 15 ), vectorscale( ( 0, 1, 0 ), 7.2 ) );
    spawncollision( "collision_physics_wall_128x128x10", "collider", ( -763, 2894.5, -35 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -2275.5, 5248, -227.5 ), ( 0, 23.4, -90 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -2464.5, 5162, -227 ), ( 0, 33.9, -90 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( -2363.5, 5219, -192.5 ), ( 0, 11.8, -90 ) );
    spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1151.5, 1199.5, -31 ), vectorscale( ( 0, 1, 0 ), 23.4 ) );
    spawncollision( "collision_clip_wall_256x256x10", "collider", ( -621.5, 2114, -176.5 ), ( 0, 270, -180 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 807.5, 855, -217.5 ), vectorscale( ( 0, 1, 0 ), 345.9 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 886, 835.5, -206 ), vectorscale( ( 0, 1, 0 ), 345.9 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 958.277, 946.957, -191.5 ), vectorscale( ( 0, 1, 0 ), 359.9 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 1039.22, 946.543, -173 ), vectorscale( ( 0, 1, 0 ), 359.9 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 853.93, 1147.29, -191.5 ), vectorscale( ( 0, 1, 0 ), 47.4 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 914.57, 1214.71, -173 ), vectorscale( ( 0, 1, 0 ), 47.4 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( -1354, 2215.5, -206 ), vectorscale( ( 0, 0, -1 ), 12.2001 ) );
    spawncollision( "collision_physics_wall_64x64x10", "collider", ( -257.5, 958, -154.5 ), ( 7.66668, 317.653, 2.55286 ) );
    spawncollision( "collision_clip_128x128x10", "collider", ( -684, 1465, 36.5 ), ( 0, 5, 90 ) );
    spawncollision( "collision_physics_wall_128x128x10", "collider", ( -2067, 1390, -102 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    concrete1 = spawn( "script_model", ( -2040.54, 636.504, -215.717 ) );
    concrete1.angles = ( 0.0251585, 359.348, 178.338 );
    concrete1 setmodel( "p6_building_granite_tan_brokenb" );
    level.levelkothdisable = [];
    level.levelkothdisable[level.levelkothdisable.size] = spawn( "trigger_radius", ( -1337, 2016, 8.5 ), 0, 40, 50 );
    level thread maps\mp\killstreaks\_turret_killstreak::addnoturrettrigger( ( -2295, 3843.5, -193 ), 80, 64 );
    level thread maps\mp\killstreaks\_turret_killstreak::addnoturrettrigger( ( -2341, 3917.5, -193 ), 80, 64 );
    level thread maps\mp\killstreaks\_turret_killstreak::addnoturrettrigger( ( -2397.75, 4003.5, -193 ), 80, 64 );
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
