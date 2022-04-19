// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_raid_fx;
#include maps\mp\_load;
#include maps\mp\mp_raid_amb;
#include maps\mp\_compass;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_raid_fx::main();
    precachemodel( "collision_physics_64x64x64" );
    precachemodel( "collision_physics_128x128x128" );
    precachemodel( "collision_clip_wall_64x64x10" );
    precachemodel( "collision_nosight_wall_64x64x10" );
    precachemodel( "collision_missile_32x32x128" );
    precachemodel( "collision_physics_32x32x32" );
    precachemodel( "collision_clip_wall_256x256x10" );
    maps\mp\_load::main();
    maps\mp\mp_raid_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_raid" );
    spawncollision( "collision_physics_64x64x64", "collider", ( 2664, 3832, 24 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_64x64x64", "collider", ( 4127, 3741, 130 ), vectorscale( ( 0, 1, 0 ), 25.4 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 3136, 3590.89, 283.276 ), vectorscale( ( 0, 0, -1 ), 33.6 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 2841, 3590.89, 283.28 ), vectorscale( ( 0, 0, -1 ), 33.6 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 2841, 3696.89, 212.28 ), vectorscale( ( 0, 0, -1 ), 33.6 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( 2841, 3804.89, 140.28 ), vectorscale( ( 0, 0, -1 ), 33.6 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3591, 3274, 187.5 ), ( 0, 16.4, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3600.5, 3242, 187.5 ), ( 0, 16.4, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3645, 3318, 187.5 ), ( 0, 16.4, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3656, 3263, 187.5 ), ( 0, 26.3, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3702.5, 3348.5, 187.5 ), ( 0, 16.4, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3705.5, 3292, 187.5 ), ( 0, 39.1, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3716.5, 3389.5, 187.5 ), ( 0, 56.6, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3750.5, 3333, 187.5 ), ( 0, 46.7, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3748.5, 3434.5, 187.5 ), ( 0, 78.5, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3782.5, 3376, 187.5 ), ( 0, 58.9, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3809, 3428.5, 187.5 ), ( 0, 69.1, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3762.5, 3497, 187.5 ), ( 0, 78.3, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3825.5, 3484.5, 187.5 ), ( 0, 78.7, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3766.5, 3542, 187.5 ), ( 0, 88.6, 90 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 3830, 3540.5, 187.5 ), ( 0, 88.6, 90 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( 3562, 3271.5, 186.5 ), vectorscale( ( 0, 1, 0 ), 11.2 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( 3259.5, 2294.5, 230 ), ( 0, 22.8, 90 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 1583.5, 2900, 137.5 ), ( 0, 0, 0 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 2751, 4130.5, 214.5 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_nosight_wall_64x64x10", "collider", ( 2751, 4099, 214.5 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( 3819, 3475, 113 ), vectorscale( ( 0, -1, 0 ), 15.0 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( 3819, 3598, 113 ), vectorscale( ( 0, 1, 0 ), 15.0 ) );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( 3570, 3834, 113 ), vectorscale( ( 0, 1, 0 ), 260.0 ) );
    spawncollision( "collision_clip_wall_256x256x10", "collider", ( 3352, 4688, 136 ), ( 0, 0, 0 ) );
    level thread water_trigger_init();
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "1870", reset_dvars );
}

water_trigger_init()
{
    triggers = getentarray( "water_killbrush", "targetname" );

    foreach ( trigger in triggers )
        trigger thread player_splash_think();
}

player_splash_think()
{
    for (;;)
    {
        self waittill( "trigger", entity );

        if ( isplayer( entity ) && isalive( entity ) )
            self thread trigger_thread( entity, ::player_water_fx );
    }
}

player_water_fx( player, endon_condition )
{
    maxs = self.origin + self getmaxs();

    if ( maxs[2] < 0 )
        maxs += vectorscale( ( 0, 0, 1 ), 5.0 );

    origin = ( player.origin[0], player.origin[1], maxs[2] );
    playfx( level._effect["water_splash_sm"], origin );
}
