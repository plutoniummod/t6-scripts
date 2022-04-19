// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_meltdown_fx;
#include maps\mp\_load;
#include maps\mp\mp_meltdown_amb;
#include maps\mp\_compass;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_meltdown_fx::main();
    maps\mp\_load::main();
    maps\mp\mp_meltdown_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_meltdown" );
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2100", reset_dvars );
}
