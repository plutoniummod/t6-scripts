// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_ffotd;

main_start()
{
    level thread spawned_collision_fix();
    level thread kill_trigger_spawn();
}

main_end()
{
    connect_zones_for_ffotd( "zone_orange_level3a", "zone_orange_level3b", 0 );
    connect_zones_for_ffotd( "zone_orange_elevator_shaft_middle_1", "zone_orange_elevator_shaft_top", 1 );
    level thread pathfinding_override_fix();
}

spawned_collision_fix()
{
    precachemodel( "collision_geo_512x512x512_standard" );
    precachemodel( "collision_geo_32x32x128_standard" );
    precachemodel( "collision_geo_64x64x256_standard" );
    precachemodel( "collision_wall_128x128x10_standard" );
    precachemodel( "collision_wall_256x256x10_standard" );
    flag_wait( "start_zombie_round_logic" );

    if ( !is_true( level.optimise_for_splitscreen ) )
    {
        collision1 = spawn( "script_model", ( 2992, 536, 497 ) );
        collision1 setmodel( "collision_geo_512x512x512_standard" );
        collision1.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision1 ghost();
        collision2 = spawn( "script_model", ( 2824, 632, 497 ) );
        collision2 setmodel( "collision_geo_512x512x512_standard" );
        collision2.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision2 ghost();
        collision3 = spawn( "script_model", ( 2992, 536, -15 ) );
        collision3 setmodel( "collision_geo_512x512x512_standard" );
        collision3.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision3 ghost();
        collision4 = spawn( "script_model", ( 2824, 632, -15 ) );
        collision4 setmodel( "collision_geo_512x512x512_standard" );
        collision4.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision4 ghost();
        collision5 = spawn( "script_model", ( 2992, 536, -527 ) );
        collision5 setmodel( "collision_geo_512x512x512_standard" );
        collision5.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision5 ghost();
        collision6 = spawn( "script_model", ( 2824, 632, -527 ) );
        collision6 setmodel( "collision_geo_512x512x512_standard" );
        collision6.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision6 ghost();
        collision7 = spawn( "script_model", ( 2992, 536, -1039 ) );
        collision7 setmodel( "collision_geo_512x512x512_standard" );
        collision7.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision7 ghost();
        collision8 = spawn( "script_model", ( 2824, 632, -1039 ) );
        collision8 setmodel( "collision_geo_512x512x512_standard" );
        collision8.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision8 ghost();
        collision9 = spawn( "script_model", ( 2992, 536, -1551 ) );
        collision9 setmodel( "collision_geo_512x512x512_standard" );
        collision9.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision9 ghost();
        collision10 = spawn( "script_model", ( 2824, 632, -1551 ) );
        collision10 setmodel( "collision_geo_512x512x512_standard" );
        collision10.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision10 ghost();
        collision11 = spawn( "script_model", ( 2992, 536, -2063 ) );
        collision11 setmodel( "collision_geo_512x512x512_standard" );
        collision11.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision11 ghost();
        collision12 = spawn( "script_model", ( 2824, 632, -2063 ) );
        collision12 setmodel( "collision_geo_512x512x512_standard" );
        collision12.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision12 ghost();
        collisione1 = spawn( "script_model", ( 1649, 2164, 2843 ) );
        collisione1 setmodel( "collision_wall_256x256x10_standard" );
        collisione1.angles = ( 0, 0, 0 );
        collisione1 ghost();
        collisione2 = spawn( "script_model", ( 1649, 2164, 2587 ) );
        collisione2 setmodel( "collision_wall_256x256x10_standard" );
        collisione2.angles = ( 0, 0, 0 );
        collisione2 ghost();
        collisione3 = spawn( "script_model", ( 1478, 1216, 2843 ) );
        collisione3 setmodel( "collision_wall_256x256x10_standard" );
        collisione3.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
        collisione3 ghost();
        collisione4 = spawn( "script_model", ( 1478, 1216, 2587 ) );
        collisione4 setmodel( "collision_wall_256x256x10_standard" );
        collisione4.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
        collisione4 ghost();
        collisione5 = spawn( "script_model", ( 1478, 1216, 2331 ) );
        collisione5 setmodel( "collision_wall_256x256x10_standard" );
        collisione5.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
        collisione5 ghost();
        collisione6 = spawn( "script_model", ( 1478, 1216, 2242 ) );
        collisione6 setmodel( "collision_wall_256x256x10_standard" );
        collisione6.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
        collisione6 ghost();
        collision13 = spawn( "script_model", ( 2251, 2687, 3095 ) );
        collision13 setmodel( "collision_wall_128x128x10_standard" );
        collision13.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
        collision13 ghost();
        collision14 = spawn( "script_model", ( 2046, 1270, 2758 ) );
        collision14 setmodel( "collision_geo_512x512x512_standard" );
        collision14.angles = vectorscale( ( 0, 0, -1 ), 6.20013 );
        collision14 ghost();
        collision15 = spawn( "script_model", ( 2518, 597, 3191 ) );
        collision15 setmodel( "collision_wall_128x128x10_standard" );
        collision15.angles = ( 0, 240.4, -3.00014 );
        collision15 ghost();
        collision16 = spawn( "script_model", ( 2613, -721, 1184 ) );
        collision16 setmodel( "collision_wall_128x128x10_standard" );
        collision16.angles = ( 0, 60, -2.60003 );
        collision16 ghost();
        collision17 = spawn( "script_model", ( 2721, -533, 1184 ) );
        collision17 setmodel( "collision_wall_128x128x10_standard" );
        collision17.angles = ( 0, 60, -2.60003 );
        collision17 ghost();
        collision18 = spawn( "script_model", ( 2940, 1512, 3004 ) );
        collision18 setmodel( "collision_geo_64x64x256_standard" );
        collision18.angles = vectorscale( ( 1, 0, 0 ), 350.0 );
        collision18 ghost();
        collision19 = spawn( "script_model", ( 1631, -235, 2943 ) );
        collision19 setmodel( "collision_geo_32x32x128_standard" );
        collision19.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision19 ghost();
        collision20 = spawn( "script_model", ( 2232, -579, 1354 ) );
        collision20 setmodel( "collision_wall_128x128x10_standard" );
        collision20.angles = vectorscale( ( 0, 1, 0 ), 330.0 );
        collision20 ghost();
        collision21 = spawn( "script_model", ( 2349, 805, 1346 ) );
        collision21 setmodel( "collision_geo_32x32x128_standard" );
        collision21.angles = vectorscale( ( 0, 1, 0 ), 8.6 );
        collision21 ghost();
        collision22 = spawn( "script_model", ( 2791, 1093, 1272 ) );
        collision22 setmodel( "collision_geo_32x32x128_standard" );
        collision22.angles = vectorscale( ( 1, 0, 0 ), 3.2 );
        collision22 ghost();
        collision23 = spawn( "script_model", ( 2222, 1488, 3280 ) );
        collision23 setmodel( "collision_geo_32x32x128_standard" );
        collision23.angles = ( 0, 0, 0 );
        collision23 ghost();
        collision24 = spawn( "script_model", ( 2222, 1488, 3312 ) );
        collision24 setmodel( "collision_geo_32x32x128_standard" );
        collision24.angles = ( 0, 0, 0 );
        collision24 ghost();
    }
}

connect_zones_for_ffotd( zone_name_a, zone_name_b, one_way )
{
    if ( !isdefined( one_way ) )
        one_way = 0;

    zone_init( zone_name_a );
    zone_init( zone_name_b );
    enable_zone( zone_name_a );
    enable_zone( zone_name_b );

    if ( !isdefined( level.zones[zone_name_a].adjacent_zones[zone_name_b] ) )
        level.zones[zone_name_a].adjacent_zones[zone_name_b] = spawnstruct();

    level.zones[zone_name_a].adjacent_zones[zone_name_b].is_connected = 1;

    if ( !one_way )
    {
        if ( !isdefined( level.zones[zone_name_b].adjacent_zones[zone_name_a] ) )
            level.zones[zone_name_b].adjacent_zones[zone_name_a] = spawnstruct();

        level.zones[zone_name_b].adjacent_zones[zone_name_a].is_connected = 1;
    }
}

kill_trigger_spawn()
{
    trig = spawn( "trigger_box", ( 3328, 160, 1480 ), 0, 96, 200, 128 );
    trig.angles = vectorscale( ( 0, 1, 0 ), 150.0 );
    trig.targetname = "instant_death";
    trig2 = spawn( "trigger_box", ( 2512, 1824, 1488 ), 0, 140, 140, 128 );
    trig2.angles = ( 0, 0, 0 );
    trig2.targetname = "instant_death";
}

pathfinding_override_fix()
{
    zombie_trigger_origin = ( 2303, 746, 1296 );
    zombie_trigger_radius = 30;
    zombie_trigger_height = 128;
    player_trigger_origin = ( 2357, 778, 1304 );
    player_trigger_radius = 40;
    zombie_goto_point = ( 2361, 738, 1304 );
    level thread maps\mp\zombies\_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
    zombie_trigger_origin = ( 3767, 1867, 2790 );
    zombie_trigger_radius = 64;
    zombie_trigger_height = 128;
    player_trigger_origin = ( 3684, 1772, 2758 );
    player_trigger_radius = 70;
    zombie_goto_point = ( 3659, 1872, 2790 );
    level thread maps\mp\zombies\_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
    zombie_trigger_origin = ( 3245, 1251, 1347.79 );
    zombie_trigger_radius = 64;
    zombie_trigger_height = 128;
    player_trigger_origin = ( 3246, 1126, 1347.79 );
    player_trigger_radius = 64;
    zombie_goto_point = ( 3031, 1234, 1278.12 );
    level thread maps\mp\zombies\_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
    zombie_trigger_origin = ( 3246, 1113, 1347.79 );
    zombie_trigger_radius = 64;
    zombie_trigger_height = 128;
    player_trigger_origin = ( 3245, 1230, 1347.79 );
    player_trigger_radius = 44;
    zombie_goto_point = ( 3023, 1154, 1278.12 );
    level thread maps\mp\zombies\_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
    zombie_trigger_origin = ( 3389, 1182, 1364.79 );
    zombie_trigger_radius = 64;
    zombie_trigger_height = 128;
    player_trigger_origin = ( 3246, 1126, 1347.79 );
    player_trigger_radius = 64;
    zombie_goto_point = ( 3381, 1093, 1364.79 );
    level thread maps\mp\zombies\_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
    zombie_trigger_origin = ( 3148, 1712, 1299.07 );
    zombie_trigger_radius = 64;
    zombie_trigger_height = 128;
    player_trigger_origin = ( 3149, 1604, 1302.2 );
    player_trigger_radius = 44;
    zombie_goto_point = ( 3259, 1644, 1321.5 );
    level thread maps\mp\zombies\_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
    zombie_trigger_origin = ( 3149, 1584, 1302.2 );
    zombie_trigger_radius = 64;
    zombie_trigger_height = 128;
    player_trigger_origin = ( 3148, 1692, 1299.07 );
    player_trigger_radius = 44;
    zombie_goto_point = ( 3291, 1684, 1321.5 );
    level thread maps\mp\zombies\_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
    zombie_trigger_origin = ( 3818, 1860, 2789.23 );
    zombie_trigger_radius = 100;
    zombie_trigger_height = 128;
    player_trigger_origin = ( 3601, 1961, 2744.95 );
    player_trigger_radius = 50;
    zombie_goto_point = ( 3626, 1918, 2750.26 );
    level thread maps\mp\zombies\_zm_ffotd::path_exploit_fix( zombie_trigger_origin, zombie_trigger_radius, zombie_trigger_height, player_trigger_origin, player_trigger_radius, zombie_goto_point );
    all_nodes = getallnodes();

    foreach ( node in all_nodes )
    {
        if ( node.origin[0] == 3598.2 )
        {
            deletepathnode( node );
            break;
        }
    }
}

highrise_link_nodes( a, b )
{
    if ( nodesarelinked( a, b ) )
        return;

    link_nodes( a, b );
}

highrise_unlink_nodes( a, b )
{
    if ( !nodesarelinked( a, b ) )
        return;

    unlink_nodes( a, b );
}
