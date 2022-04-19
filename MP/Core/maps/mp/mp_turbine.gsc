// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_turbine_fx;
#include maps\mp\_load;
#include maps\mp\_compass;
#include maps\mp\mp_turbine_amb;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_turbine_fx::main();
    precachemodel( "collision_clip_cylinder_32x128" );
    precachemodel( "collision_physics_128x128x10" );
    precachemodel( "collision_physics_64x64x64" );
    precachemodel( "collision_physics_64x64x10" );
    precachemodel( "collision_physics_wall_64x64x10" );
    precachemodel( "collision_clip_32x32x32" );
    precachemodel( "collision_clip_64x64x64" );
    precachemodel( "collision_clip_wall_64x64x10" );
    precachemodel( "collision_missile_128x128x10" );
    precachemodel( "collision_clip_128x128x10" );
    precachemodel( "collision_missile_32x32x128" );
    precachemodel( "collision_clip_wall_128x128x10" );
    precachemodel( "p6_rocks_medium_01_nospec" );
    precachemodel( "collision_clip_64x64x10" );
    maps\mp\_load::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_turbine" );
    maps\mp\mp_turbine_amb::main();

    if ( !level.console )
    {
        precachemodel( "collision_clip_32x32x32" );
        spawncollision( "collision_clip_32x32x32", "collider", ( -1400, 550, 360 ), ( 0, 0, 0 ) );
    }

    spawncollision( "collision_clip_cylinder_32x128", "collider", ( 334, 1724, -14 ), vectorscale( ( 0, 1, 0 ), 346.8 ) );
    spawncollision( "collision_clip_cylinder_32x128", "collider", ( 1249, 1250, 193 ), ( 270, 241.8, -4 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -713, -737, 310 ), ( 276.402, 353.887, 29.1528 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -707.5, -727, 310 ), ( 276.402, 353.887, 29.1528 ) );
    spawncollision( "collision_physics_64x64x64", "collider", ( -826.5, -866, 350.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( -678, -1044, 396.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -612.5, -1001.5, 348.5 ), ( 355.897, 281.708, -59.5212 ) );
    spawncollision( "collision_clip_32x32x32", "collider", ( 828, 3006.5, -124.5 ), vectorscale( ( 0, 0, -1 ), 15.6 ) );
    spawncollision( "collision_clip_64x64x64", "collider", ( 96.5, 3649, 46.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( 171, -1578.5, 180.5 ), ( 2.65172, 9.74951, -15.074 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -789.5, 2667, 424 ), ( 359.984, 19.5888, -179.329 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -807.5, 2660.5, 424 ), ( 359.984, 19.5888, -179.329 ) );
    spawncollision( "collision_clip_128x128x10", "collider", ( -789.5, 2667, 424 ), ( 359.984, 19.5888, -89.3292 ) );
    spawncollision( "collision_clip_128x128x10", "collider", ( -807.5, 2660.5, 424 ), ( 359.984, 19.5888, -89.3292 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -789.5, 2667, 424 ), ( 359.984, 19.5888, -89.3292 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -807.5, 2660.5, 424 ), ( 359.984, 19.5888, -89.3292 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( -1889.5, 1249.5, 318.5 ), ( 359.691, 90.6276, 26.2986 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( 1970, 2595.5, 75 ), vectorscale( ( 0, 1, 0 ), 45.2 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( 2221, 2396.5, 119.5 ), vectorscale( ( 0, 1, 0 ), 45.0 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( 2130, 2305.5, 116 ), vectorscale( ( 0, 1, 0 ), 45.0 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( 2111.5, 2287.5, 54 ), vectorscale( ( 0, 1, 0 ), 45.0 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( 1692.5, 2321.5, 60.5 ), vectorscale( ( 0, 1, 0 ), 45.0 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( 2195.5, 2702, 132.5 ), vectorscale( ( 0, 1, 0 ), 314.6 ) );
    spawncollision( "collision_clip_wall_32x32x10", "collider", ( 296, -181.5, 282 ), vectorscale( ( 0, 1, 0 ), 341.5 ) );
    spawncollision( "collision_clip_wall_32x32x10", "collider", ( 300, -84, 282 ), ( 0, 0, 0 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( 937, 2270, -59 ), ( 0.562452, 274.866, -38.8762 ) );
    spawncollision( "collision_clip_32x32x32", "collider", ( 223.5, 3528, 132 ), ( 0, 0, 0 ) );
    rock1 = spawn( "script_model", ( 61.6428, 2656.92, 253.46 ) );
    rock1.angles = ( 288.55, 212.152, -86.8076 );
    rock1 setmodel( "p6_rocks_medium_01_nospec" );
    rock2 = spawn( "script_model", ( 30.64, 2652, 277.89 ) );
    rock2.angles = ( 352.368, 229.531, -57.337 );
    rock2 setmodel( "p6_rocks_medium_01_nospec" );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( 42.5, 2573.5, 334 ), vectorscale( ( 0, 1, 0 ), 319.3 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( 91, 2569, 334 ), vectorscale( ( 0, 1, 0 ), 3.59998 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( 60.5, 2610, 368.5 ), ( 3.43509, 325.664, -77.5079 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( 89.5, 2594, 368.5 ), ( 3.43509, 12.164, -77.5079 ) );
    spawncollision( "collision_clip_32x32x32", "collider", ( -239, 1680.5, 318.5 ), vectorscale( ( 0, 1, 0 ), 319.3 ) );
    spawncollision( "collision_clip_wall_128x128x10", "collider", ( 62.5, 2557, 358 ), vectorscale( ( 0, 0, -1 ), 8.50021 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 348.02, 1176.13, 299.595 ), ( 339.37, 328.453, -22.7468 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 388.801, 1219.68, 271.157 ), ( 339.37, 328.453, -22.7468 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( 432.597, 1264.16, 247.717 ), ( 339.37, 328.453, -22.7468 ) );
    level.remotemotarviewleft = 50;
    level.remotemotarviewright = 50;
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
}

turbine_spin_init()
{
    level endon( "game_ended" );
    turbine1 = getent( "turbine_blades", "targetname" );
    turbine1 thread rotate_blades( 4 );
    turbine2 = getent( "turbine_blades2", "targetname" );
    turbine2 thread rotate_blades( 3 );
    turbine3 = getent( "turbine_blades3", "targetname" );
    turbine3 thread rotate_blades( 6 );
    turbine4 = getent( "turbine_blades4", "targetname" );
    turbine4 thread rotate_blades( 3 );
    turbine6 = getent( "turbine_blades6", "targetname" );
    turbine6 thread rotate_blades( 4 );
}

rotate_blades( time )
{
    self endon( "game_ended" );
    revolutions = 1000;

    while ( true )
    {
        self rotateroll( 360 * revolutions, time * revolutions );

        self waittill( "rotatedone" );
    }
}
