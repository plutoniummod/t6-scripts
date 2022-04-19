// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_nightclub_fx;
#include maps\mp\_load;
#include maps\mp\mp_nightclub_amb;
#include maps\mp\_compass;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_nightclub_fx::main();
    precachemodel( "collision_clip_128x128x128" );
    precachemodel( "collision_physics_wall_32x32x10" );
    precachemodel( "collision_missile_256x256x10" );
    precachemodel( "collision_clip_cylinder_32x128" );
    precachemodel( "collision_clip_wall_64x64x10" );
    precachemodel( "collision_clip_128x128x10" );
    precachemodel( "collision_clip_64x64x10" );
    precachemodel( "collision_clip_wall_128x128x10" );
    precachemodel( "collision_missile_32x32x128" );
    precachemodel( "collision_missile_128x128x10" );
    precachemodel( "collision_tvs_anchor_desk01" );
    precachemodel( "collision_physics_wall_64x64x10" );
    precachemodel( "collision_physics_32x32x32" );
    maps\mp\_load::main();
    maps\mp\mp_nightclub_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_nightclub" );
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
    spawncollision( "collision_clip_128x128x128", "collider", ( -17402.5, 2804, -109 ), vectorscale( ( 0, 1, 0 ), 315.0 ) );
    spawncollision( "collision_clip_128x128x128", "collider", ( -17350.5, 2856, -109 ), vectorscale( ( 0, 1, 0 ), 315.0 ) );
    spawncollision( "collision_clip_cylinder_32x128", "collider", ( -18769, 733, -218 ), ( 0, 0, 0 ) );
    spawncollision( "collision_clip_cylinder_32x128", "collider", ( -18772, 664, -218 ), ( 0, 0, 0 ) );
    spawncollision( "collision_clip_cylinder_32x128", "collider", ( -18772, 605, -218 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_32x32x10", "collider", ( -16759, 3939, -100 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_32x32x10", "collider", ( -16742, 3939, -100 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_32x32x10", "collider", ( -19469, 355, -86 ), vectorscale( ( 0, 1, 0 ), 90.0 ) );
    spawncollision( "collision_physics_wall_32x32x10", "collider", ( -19469, 338, -86 ), vectorscale( ( 0, 1, 0 ), 90.0 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( -18273.5, 1092.5, -2.5 ), vectorscale( ( 0, 1, 0 ), 86.7 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( -16166.5, 1802, -127 ), ( 16, 44.3, 0 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -18016.9, 1674.34, -179 ), ( 270, 225.8, 4.34 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -18025.9, 1683.34, -179 ), ( 270, 225.8, 4.34 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17810.9, 1883.34, -77 ), ( 270, 225.8, 4.34 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17819.9, 1892.34, -77 ), ( 270, 225.8, 4.34 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17872, 1839, -87 ), ( 359.801, 315.726, 110.729 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17860, 1827, -87 ), ( 359.801, 315.726, 110.729 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17946, 1764, -129 ), ( 359.801, 315.726, 110.729 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17970, 1737, -146 ), ( 359.801, 315.726, 110.729 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17936, 1754, -129 ), ( 359.801, 315.726, 110.729 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17961, 1728, -146 ), ( 359.801, 315.726, 110.729 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17370.1, 2304.66, -77 ), ( 270, 45.8, 4.33999 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17379.1, 2313.66, -77 ), ( 270, 45.8, 4.33999 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17164.1, 2513.66, -179 ), ( 270, 45.8, 4.33999 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17173.1, 2522.66, -179 ), ( 270, 45.8, 4.33999 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17229, 2469, -146 ), ( 359.801, 135.726, 110.729 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17220, 2460, -146 ), ( 359.801, 135.726, 110.729 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17254, 2443, -129 ), ( 359.801, 135.726, 110.729 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17244, 2433, -129 ), ( 359.801, 135.726, 110.729 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17330, 2370, -87 ), ( 359.801, 135.726, 110.729 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17318, 2358, -87 ), ( 359.801, 135.726, 110.729 ) );
    spawncollision( "collision_tvs_anchor_desk01", "collider", ( -15441, 3711, -192 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -16938.5, 2314, -226.5 ), vectorscale( ( 0, 1, 0 ), 33.5 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17504.5, 1852.5, -93 ), ( 0, 44.9, 90 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -17413, 1942, -93 ), ( 0, 44.9, 90 ) );
    spawncollision( "collision_clip_256x256x10", "collider", ( -16309.5, 3077, -64.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17336.4, 1959.55, -25.25 ), ( 0, 42.2, 90 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17315.1, 1935.7, -25.25 ), ( 0, 42.2, 90 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17311.6, 1931.95, -25.25 ), ( 0, 42.2, 90 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17462.9, 1832.79, -25.25 ), ( 0, 49.8, 90 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17438.6, 1811.97, -25.25 ), ( 0, 49.8, 90 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17434.6, 1808.72, -25.25 ), ( 0, 49.8, 90 ) );
    spawncollision( "collision_physics_wall_64x64x10", "collider", ( -18712.5, 525, -122.5 ), vectorscale( ( 0, 1, 0 ), 20.9 ) );
    spawncollision( "collision_physics_wall_64x64x10", "collider", ( -18712.5, 525, -159.5 ), vectorscale( ( 0, 1, 0 ), 20.9 ) );
    spawncollision( "collision_physics_wall_64x64x10", "collider", ( -18927.5, 1099, -122.5 ), vectorscale( ( 0, 1, 0 ), 65.6 ) );
    spawncollision( "collision_physics_wall_64x64x10", "collider", ( -18927.5, 1099, -159.5 ), vectorscale( ( 0, 1, 0 ), 65.6 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17335, 1962, -30.5 ), ( 0, 44.6, 90 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -17463.5, 1833, -30.5 ), ( 0, 48.7, 90 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -17251.5, 2908.5, 31 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -17250.5, 2981, 31 ), ( 0, 0, 0 ) );
    destructibles = getentarray( "destructible", "targetname" );

    foreach ( destructible in destructibles )
        destructible thread car_sound_think();
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2200", reset_dvars );
}

car_sound_think()
{
    self waittill( "car_dead" );

    self playsound( "exp_barrel" );
}
