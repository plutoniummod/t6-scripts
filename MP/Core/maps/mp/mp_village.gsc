// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_village_fx;
#include maps\mp\_load;
#include maps\mp\mp_village_amb;
#include maps\mp\_compass;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    level thread spawnkilltrigger();
    maps\mp\mp_village_fx::main();
    precachemodel( "collision_physics_32x32x32" );
    precachemodel( "collision_physics_32x32x128" );
    precachemodel( "collision_physics_128x128x10" );
    precachemodel( "collision_physics_256x256x10" );
    precachemodel( "collision_clip_wall_64x64x10" );
    precachemodel( "collision_clip_64x64x10" );
    precachemodel( "afr_corrugated_metal8x8" );
    precachemodel( "p6_pak_old_plywood" );
    destructibles = getentarray( "destructible", "targetname" );

    foreach ( destructible in destructibles )
    {
        if ( destructible.destructibledef == "dest_propanetank_01" )
            destructible thread death_sound_think();
    }

    foreach ( destructible in destructibles )
    {
        if ( destructible getentitynumber() == 553 )
        {
            destructible delete();
            break;
        }
    }

    maps\mp\_load::main();
    maps\mp\mp_village_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_village" );
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
    spawncollision( "collision_physics_32x32x32", "collider", ( 610, -126, 60 ), vectorscale( ( 1, 0, 0 ), 287.2 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 590, -126, 67 ), vectorscale( ( 1, 0, 0 ), 287.2 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 602, -233, 70 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_wall_128x128x10", "collider", ( 707, -812, 32 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_physics_wall_128x128x10", "collider", ( 707, -730, 32 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( -1056, -1294, 32 ), vectorscale( ( 1, 0, 0 ), 270.0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( -960, -1294, 32 ), vectorscale( ( 1, 0, 0 ), 270.0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( -1057, -1294, 111 ), vectorscale( ( 1, 0, 0 ), 270.0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( -964, -1294, 111 ), vectorscale( ( 1, 0, 0 ), 270.0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( -344, 1356, 264 ), ( 270, 276.8, -6.8 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( -344, 1407, 264 ), ( 270, 276.8, -6.8 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -1335.5, -1667, 196 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -1335.5, -1676, 196 ), ( 0, 0, 0 ) );
    metalsheet1 = spawn( "script_model", ( -1487, 1156, 10 ) );
    metalsheet1.angles = vectorscale( ( 0, 0, -1 ), 90.0 );
    metalsheet1 setmodel( "afr_corrugated_metal8x8" );
    metalsheet1 = spawn( "script_model", ( -1487, 1252, 10 ) );
    metalsheet1.angles = vectorscale( ( 0, 0, -1 ), 90.0 );
    metalsheet1 setmodel( "afr_corrugated_metal8x8" );
    metalsheet1 = spawn( "script_model", ( -1487, 1348, 10 ) );
    metalsheet1.angles = vectorscale( ( 0, 0, -1 ), 90.0 );
    metalsheet1 setmodel( "afr_corrugated_metal8x8" );
    metalsheet1 = spawn( "script_model", ( -1487, 1444, 10 ) );
    metalsheet1.angles = vectorscale( ( 0, 0, -1 ), 90.0 );
    metalsheet1 setmodel( "afr_corrugated_metal8x8" );
    spawncollision( "collision_physics_32x32x32", "collider", ( 1095, 1482, 31 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 1095, 1519, 31 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 1054, 1552, 68 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 1054, 1589, 68 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 1054, 1552, 39 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 1054, 1589, 39 ), ( 0, 0, 0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 1023.52, 1577.46, 37.8172 ), ( 353.857, 287.799, 18.4368 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 990.481, 1565.54, 26.1828 ), ( 353.857, 287.799, 18.4368 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 952.701, 1488.68, 29 ), vectorscale( ( 0, 1, 0 ), 24.6 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( 937.299, 1522.32, 29 ), vectorscale( ( 0, 1, 0 ), 24.6 ) );
    spawncollision( "collision_physics_256x256x10", "collider", ( 596, -1545, -8 ), vectorscale( ( 1, 0, 0 ), 2.2 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 628.255, -1724.02, 2 ), ( 270, 307.4, 0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 645.992, -1840.11, 2 ), ( 270, 251.2, 0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 560.513, -1921.33, 2 ), ( 270, 196.2, 0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 443.23, -1896.61, 2 ), ( 270, 140.6, 0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 400.756, -1788.41, 2 ), ( 270, 85.6, 0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 435.565, -1707.94, 2 ), ( 270, 44.4, 0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 523, -1672, 2 ), vectorscale( ( 1, 0, 0 ), 270.0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -1861, -1004, 239 ), vectorscale( ( 0, 1, 0 ), 346.0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -1867, -1023, 239 ), vectorscale( ( 0, 1, 0 ), 346.0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -1861, -1324, 239 ), vectorscale( ( 0, 1, 0 ), 346.0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -1867, -1343, 239 ), vectorscale( ( 0, 1, 0 ), 346.0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -1876, -1400, 239 ), vectorscale( ( 0, 1, 0 ), 61.0 ) );
    spawncollision( "collision_physics_32x32x32", "collider", ( -1859, -1411, 239 ), vectorscale( ( 0, 1, 0 ), 61.0 ) );
    spawncollision( "collision_physics_32x32x128", "collider", ( 1335, 1029, 55 ), vectorscale( ( 1, 0, 0 ), 270.0 ) );
    spawncollision( "collision_physics_256x256x10", "collider", ( 645, -1562, 0 ), vectorscale( ( 0, 0, 1 ), 3.0 ) );
    level.levelkothdisable = [];
    level.levelkothdisable[level.levelkothdisable.size] = spawn( "trigger_radius", ( -176, 1512, 133.5 ), 0, 60, 25 );
    level.levelkothdisable[level.levelkothdisable.size] = spawn( "trigger_radius", ( 243.5, 1010, 145.5 ), 0, 60, 25 );
    spawncollision( "collision_clip_wall_64x64x10", "collider", ( 1180, 1399.5, 34.5 ), ( 357.9, 356.4, -3.28 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( -83.966, 1292.63, 135.543 ), ( 0, 0, 0 ) );
    spawncollision( "collision_clip_64x64x10", "collider", ( -94.7516, 1383.63, 135.54 ), ( 0, 0, 0 ) );
    board1 = spawn( "script_model", ( -633.5, 646.2, 22.45 ) );
    board1.angles = ( 0, 195.6, 90 );
    board1 setmodel( "p6_pak_old_plywood" );
    board2 = spawn( "script_model", ( -627.66, 646.19, 22.45 ) );
    board2.angles = ( 0, 184.4, 90 );
    board2 setmodel( "p6_pak_old_plywood" );
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2300", reset_dvars );
}

death_sound_think()
{
    self waittill( "destructible_base_piece_death" );

    self playsound( "exp_barrel" );
}

spawnkilltrigger()
{
    trigger = spawn( "trigger_radius", ( -108.857, 1221.1, 132.467 ), 0, 200, 5 );
    trigger = spawn( "trigger_radius", ( -213.452, 1405.1, 137 ), 0, 75, 5 );

    while ( true )
    {
        trigger waittill( "trigger", player );

        player dodamage( player.health * 2, trigger.origin, trigger, trigger, "none", "MOD_SUICIDE", 0, "lava_mp" );
    }
}
