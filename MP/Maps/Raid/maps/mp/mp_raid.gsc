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
    maps\mp\_load::main();
    maps\mp\mp_raid_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_raid" );
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
