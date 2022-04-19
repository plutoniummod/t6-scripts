// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_socotra_fx;
#include maps\mp\_load;
#include maps\mp\_compass;
#include maps\mp\mp_socotra_amb;
#include maps\mp\gametypes\_spawning;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_socotra_fx::main();
    maps\mp\_load::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_socotra" );
    maps\mp\mp_socotra_amb::main();
    setheliheightpatchenabled( "war_mode_heli_height_lock", 0 );
    maps\mp\gametypes\_spawning::level_use_unified_spawning( 1 );
    rts_remove();
    level.remotemotarviewleft = 30;
    level.remotemotarviewright = 30;
    level.remotemotarviewup = 18;
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2000", reset_dvars );
}

rts_remove()
{
    rtsfloors = getentarray( "overwatch_floor", "targetname" );

    foreach ( rtsfloor in rtsfloors )
    {
        if ( isdefined( rtsfloor ) )
            rtsfloor delete();
    }
}
