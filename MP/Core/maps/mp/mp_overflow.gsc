// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_overflow_fx;
#include maps\mp\_load;
#include maps\mp\mp_overflow_amb;
#include maps\mp\_compass;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_overflow_fx::main();
    precachemodel( "collision_physics_128x128x10" );
    precachemodel( "collision_physics_256x256x10" );
    precachemodel( "collision_physics_512x512x10" );
    precachemodel( "collision_physics_128x128x128" );
    precachemodel( "collision_physics_64x64x64" );
    precachemodel( "collision_physics_32x32x32" );
    precachemodel( "collision_physics_cylinder_32x128" );
    precachemodel( "collision_physics_wall_64x64x10" );
    precachemodel( "collision_clip_wall_128x128x10" );
    precachemodel( "intro_construction_scaffold_woodplanks_03" );
    precachemodel( "intro_construction_scaffold_woodplanks_05" );
    precachemodel( "afr_corrugated_metal4x4_holes" );
    precachemodel( "p_rus_rollup_door_40" );
    precachemodel( "p_rus_rollup_door_136" );
    precachemodel( "com_wallchunk_boardmedium01" );
    maps\mp\_load::main();
    maps\mp\mp_overflow_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_overflow" );
    level.overrideplayerdeathwatchtimer = ::leveloverridetime;
    level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
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
    spawncollision( "collision_physics_128x128x10", "collider", ( -1248, -32, 285 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -1248, 96, 285 ), ( 0, 0, 0 ) );
    plank1 = spawn( "script_model", ( -1229.09, 9.85, 289.2 ) );
    plank1.angles = ( 271, 331.6, 180 );
    plank2 = spawn( "script_model", ( -1244.92, 36.81, 288.2 ) );
    plank2.angles = ( 270, 138.6, -104 );
    plank3 = spawn( "script_model", ( -1249.94, 93.83, 288.2 ) );
    plank3.angles = ( 270, 138.6, -128 );
    plank1 setmodel( "intro_construction_scaffold_woodplanks_03" );
    plank2 setmodel( "intro_construction_scaffold_woodplanks_05" );
    plank3 setmodel( "intro_construction_scaffold_woodplanks_05" );
    spawncollision( "collision_physics_128x128x10", "collider", ( -1252, -199, 283 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -1252, 376, 283 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x128", "collider", ( -158, -592, 675 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -2838, -1502, 49 ), ( 1.98509, 344.156, -96.0042 ) );
    spawncollision( "collision_physics_128x128x10", "collider", ( -2917, -1480, 52 ), ( 1.98509, 344.156, -96.0042 ) );
    spawncollision( "collision_physics_cylinder_32x128", "collider", ( 431, -1160, 124 ), vectorscale( ( 0, 0, 1 ), 51.0 ) );
    spawncollision( "collision_physics_cylinder_32x128", "collider", ( 431, -1287, 124 ), ( 0, 180, 51 ) );
    spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1603, 1133, 135 ), ( 0, 180, 51 ) );
    spawncollision( "collision_physics_cylinder_32x128", "collider", ( -1603, 1260, 135 ), vectorscale( ( 0, 0, 1 ), 51.0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -1602, 1115, 161 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -1602, 1276, 161 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_64x64x64", "collider", ( -119, -752, 436 ), ( 0, 0, 0 ) );
    metalpiece = spawn( "script_model", ( -121, -757, 467 ) );
    metalpiece.angles = vectorscale( ( 0, 0, -1 ), 90.0 );
    metalpiece setmodel( "afr_corrugated_metal4x4_holes" );
    metalpiece2 = spawn( "script_model", ( -144, -856, 408 ) );
    metalpiece2 setmodel( "p_rus_rollup_door_136" );
    metalpiece3 = spawn( "script_model", ( -144, -997, 408 ) );
    metalpiece3 setmodel( "p_rus_rollup_door_136" );
    metalpiece4 = spawn( "script_model", ( -144, -1077, 408 ) );
    metalpiece4 setmodel( "p_rus_rollup_door_40" );
    board1 = spawn( "script_model", ( -119, -783, 408 ) );
    board1.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
    board1 setmodel( "com_wallchunk_boardmedium01" );
    board2 = spawn( "script_model", ( -89, -749, 408 ) );
    board2 setmodel( "com_wallchunk_boardmedium01" );
    spawncollision( "collision_physics_64x64x64", "collider", ( -699, -1267, -19 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -683, -1219, -19 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -683, -1162, -24 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_512x512x10", "collider", ( -1746, 1555, -213 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_physics_wall_256x256x10", "collider", ( -1658, 1899, -93 ), vectorscale( ( 0, 1, 0 ), 225.6 ) );
    spawncollision( "collision_physics_wall_256x256x10", "collider", ( -1570, 1989, -93 ), vectorscale( ( 0, 1, 0 ), 225.6 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 1375, -737, 81.5 ), vectorscale( ( 0, 1, 0 ), 327.3 ) );
    level.levelkillbrushes = [];
    level.levelkillbrushes[level.levelkillbrushes.size] = spawn( "trigger_radius", ( -2817, 2226.5, -271 ), 0, 1722, 128 );
    level.levelkillbrushes[level.levelkillbrushes.size] = spawn( "trigger_radius", ( -3620, 270.5, -266.5 ), 0, 1176, 128 );
    level.levelkillbrushes[level.levelkillbrushes.size] = spawn( "trigger_radius", ( -3335, -1775.5, -266.5 ), 0, 1293, 128 );
    level.levelkillbrushes[level.levelkillbrushes.size] = spawn( "trigger_radius", ( -2351, -3384.5, -255.5 ), 0, 1293, 128 );
    spawncollision( "collision_physics_128x128x10", "collider", ( -1171.5, 512, 67 ), vectorscale( ( 0, 0, -1 ), 22.1 ) );
    spawncollision( "collision_physics_wall_64x64x10", "collider", ( 918, -728, 312 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_64x64x10", "collider", ( 1962, -1303, 10.5 ), vectorscale( ( 0, 1, 0 ), 45.2 ) );
    setheliheightpatchenabled( "war_mode_heli_height_lock", 0 );
    level thread water_trigger_init();
    level.remotemotarviewup = 13;
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2300", reset_dvars );
}

water_trigger_init()
{
    wait 3;
    triggers = getentarray( "trigger_hurt", "classname" );

    foreach ( trigger in triggers )
    {
        if ( trigger.origin[2] > level.mapcenter[2] )
            continue;

        trigger thread water_trigger_think();
    }
}

water_trigger_think()
{
    for (;;)
    {
        self waittill( "trigger", entity );

        if ( isplayer( entity ) )
        {
            entity playsound( "mpl_splash_death" );
            playfx( level._effect["water_splash"], entity.origin + vectorscale( ( 0, 0, 1 ), 10.0 ) );
        }
    }
}

leveloverridetime( defaulttime )
{
    if ( self isinwater() )
        return 0.4;

    return defaulttime;
}

useintermissionpointsonwavespawn()
{
    return self isinwater();
}

isinwater()
{
    triggers = getentarray( "trigger_hurt", "classname" );

    foreach ( trigger in triggers )
    {
        if ( trigger.origin[2] > level.mapcenter[2] )
            continue;

        if ( self istouching( trigger ) )
            return true;
    }

    return false;
}
