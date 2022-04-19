// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zm_prison;
#include maps\mp\zombies\_zm_afterlife;

main_start()
{
    level thread spawned_collision_ffotd();
    t_killbrush_1 = spawn( "trigger_box", ( 142, 9292, 1504 ), 0, 700, 160, 128 );
    t_killbrush_1.script_noteworthy = "kill_brush";
    t_killbrush_2 = spawn( "trigger_box", ( 1822, 9316, 1358 ), 0, 120, 100, 30 );
    t_killbrush_2.script_noteworthy = "kill_brush";
    t_killbrush_3 = spawn( "trigger_box", ( -50, 9318, 1392 ), 0, 200, 110, 128 );
    t_killbrush_3.script_noteworthy = "kill_brush";
    t_killbrush_4 = spawn( "trigger_box", ( -212, 7876, 74 ), 0, 220, 280, 30 );
    t_killbrush_4.angles = vectorscale( ( 0, 1, 0 ), 315.0 );
    t_killbrush_4.script_noteworthy = "kill_brush";
    t_killbrush_5 = spawn( "trigger_box", ( 896, 6291, 84 ), 0, 798, 498, 332 );
    t_killbrush_5.angles = vectorscale( ( 0, 1, 0 ), 10.0 );
    t_killbrush_5.script_noteworthy = "kill_brush";
    t_killbrush_6 = spawn( "trigger_box", ( 1268, 6870, 232 ), 0, 1024, 512, 512 );
    t_killbrush_6.angles = vectorscale( ( 0, 1, 0 ), 10.0 );
    t_killbrush_6.script_noteworthy = "kill_brush";
    t_killbrush_7 = spawn( "trigger_box", ( 896, 6009, 304 ), 0, 320, 192, 128 );
    t_killbrush_7.angles = ( 0, 0, 0 );
    t_killbrush_7.script_noteworthy = "kill_brush";
    level.gondola_docks_landing_killbrush = t_killbrush_7;
    t_killbrush_8 = spawn( "trigger_box", ( 934, 9148, 1346 ), 0, 39.7, 55.6, 39.7 );
    t_killbrush_8.angles = vectorscale( ( 1, 0, 0 ), 325.0 );
    t_killbrush_8.script_noteworthy = "kill_brush";
    t_killbrush_9 = spawn( "trigger_box", ( -1338, 5478, 114 ), 0, 200, 50, 100 );
    t_killbrush_9.angles = vectorscale( ( 0, 1, 0 ), 280.0 );
    t_killbrush_9.script_noteworthy = "kill_brush";
}

main_end()
{
    level.equipment_dead_zone_pos = [];
    level.equipment_dead_zone_rad2 = [];
    level.equipment_safe_to_drop = ::equipment_safe_to_drop_ffotd;
    waittillframeend;
    level.afterlife_give_loadout = ::afterlife_give_loadout_override;
}

equipment_safe_to_drop_ffotd( weapon )
{
    for ( i = 0; i < level.equipment_dead_zone_pos.size; i++ )
    {
        if ( distancesquared( level.equipment_dead_zone_pos[i], weapon.origin ) < level.equipment_dead_zone_rad2[i] )
            return 0;
    }

    return self maps\mp\zm_prison::equipment_safe_to_drop( weapon );
}

spawned_collision_ffotd()
{
    precachemodel( "collision_ai_64x64x10" );
    precachemodel( "collision_wall_256x256x10_standard" );
    precachemodel( "collision_wall_128x128x10_standard" );
    precachemodel( "collision_wall_512x512x10_standard" );
    precachemodel( "collision_geo_256x256x256_standard" );
    precachemodel( "collision_geo_64x64x256_standard" );
    precachemodel( "collision_geo_128x128x128_standard" );
    precachemodel( "collision_geo_128x128x10_standard" );
    precachemodel( "collision_geo_64x64x64_standard" );
    precachemodel( "collision_geo_32x32x128_standard" );
    precachemodel( "p6_zm_al_surgery_cart" );
    precachemodel( "p6_zm_al_laundry_bag" );
    precachemodel( "ch_furniture_teachers_chair1" );
    flag_wait( "start_zombie_round_logic" );

    if ( !is_true( level.optimise_for_splitscreen ) )
    {
        collision1 = spawn( "script_model", ( 1999, 9643, 1472 ) );
        collision1 setmodel( "collision_ai_64x64x10" );
        collision1.angles = ( 0, 270, -90 );
        collision1 ghost();
        collision2 = spawn( "script_model", ( -437, 6260, 121 ) );
        collision2 setmodel( "collision_wall_256x256x10_standard" );
        collision2.angles = vectorscale( ( 0, 1, 0 ), 11.8 );
        collision2 ghost();
        collision3 = spawn( "script_model", ( 1887.98, 9323, 1489.14 ) );
        collision3 setmodel( "collision_wall_128x128x10_standard" );
        collision3.angles = ( 0, 270, 38.6 );
        collision3 ghost();
        collision4 = spawn( "script_model", ( -261, 8512.02, 1153.14 ) );
        collision4 setmodel( "collision_geo_256x256x256_standard" );
        collision4.angles = vectorscale( ( 0, 1, 0 ), 180.0 );
        collision4 ghost();
        collision5a = spawn( "script_model", ( 792, 8302, 1620 ) );
        collision5a setmodel( "collision_geo_64x64x256_standard" );
        collision5a.angles = ( 0, 0, 0 );
        collision5a ghost();
        collision5b = spawn( "script_model", ( 1010, 8302, 1620 ) );
        collision5b setmodel( "collision_geo_64x64x256_standard" );
        collision5b.angles = ( 0, 0, 0 );
        collision5b ghost();
        collision6 = spawn( "script_model", ( 554, 8026, 698 ) );
        collision6 setmodel( "collision_wall_128x128x10_standard" );
        collision6.angles = vectorscale( ( 0, 1, 0 ), 22.2 );
        collision6 ghost();
        collision7 = spawn( "script_model", ( 1890, 9911, 1184 ) );
        collision7 setmodel( "collision_geo_64x64x256_standard" );
        collision7.angles = ( 0, 0, 0 );
        collision7 ghost();
        collision8 = spawn( "script_model", ( 258, 9706, 1152 ) );
        collision8 setmodel( "collision_geo_64x64x256_standard" );
        collision8.angles = ( 0, 0, 0 );
        collision8 ghost();
        collision9 = spawn( "script_model", ( 596, 8944, 1160 ) );
        collision9 setmodel( "collision_ai_64x64x10" );
        collision9.angles = ( 270, 180, -180 );
        collision9 ghost();
        collision10 = spawn( "script_model", ( -756.5, 5730, -113.75 ) );
        collision10 setmodel( "collision_geo_128x128x128_standard" );
        collision10.angles = ( 354.9, 11, 0 );
        collision10 ghost();
        collision11 = spawn( "script_model", ( -4, 8314, 808 ) );
        collision11 setmodel( "collision_wall_128x128x10_standard" );
        collision11.angles = vectorscale( ( 0, 1, 0 ), 292.0 );
        collision11 ghost();
        collision12 = spawn( "script_model", ( 1416, 10708, 1440 ) );
        collision12 setmodel( "collision_wall_512x512x10_standard" );
        collision12.angles = ( 0, 0, 0 );
        collision12 ghost();
        collision13 = spawn( "script_model", ( 1788, 9758, 1472 ) );
        collision13 setmodel( "collision_geo_64x64x64_standard" );
        collision13.angles = ( 0, 0, 0 );
        collision13 ghost();
        collision13_prop1 = spawn( "script_model", ( 1801.27, 9753.57, 1440 ) );
        collision13_prop1 setmodel( "p6_zm_al_surgery_cart" );
        collision13_prop1.angles = vectorscale( ( 0, 1, 0 ), 14.8 );
        collision13_prop2 = spawn( "script_model", ( 1802.64, 9754.85, 1476 ) );
        collision13_prop2 setmodel( "p6_zm_al_laundry_bag" );
        collision13_prop2.angles = vectorscale( ( 0, 1, 0 ), 314.351 );
        collision14 = spawn( "script_model", ( -820, 8668, 1400 ) );
        collision14 setmodel( "collision_geo_32x32x128_standard" );
        collision14.angles = ( 0, 0, 0 );
        collision14 ghost();
        collision14_prop1 = spawn( "script_model", ( -820.273, 8668.71, 1336 ) );
        collision14_prop1 setmodel( "ch_furniture_teachers_chair1" );
        collision14_prop1.angles = vectorscale( ( 0, 1, 0 ), 80.0 );
        collision15 = spawn( "script_model", ( 2557, 9723.5, 1520 ) );
        collision15 setmodel( "collision_geo_128x128x10_standard" );
        collision15.angles = vectorscale( ( 0, 0, 1 ), 34.2 );
        collision15 ghost();
        collision16 = spawn( "script_model", ( -1909.5, -3614, -8583 ) );
        collision16 setmodel( "collision_geo_256x256x256_standard" );
        collision16.angles = vectorscale( ( 1, 0, 0 ), 34.9 );
        collision16 ghost();
        collision17 = spawn( "script_model", ( -1909.5, -3554, -8583 ) );
        collision17 setmodel( "collision_geo_256x256x256_standard" );
        collision17.angles = vectorscale( ( 1, 0, 0 ), 34.9 );
        collision17 ghost();
    }
}

afterlife_give_loadout_override()
{
    self thread afterlife_leave_freeze();
    self maps\mp\zombies\_zm_afterlife::afterlife_give_loadout();
}

afterlife_leave_freeze()
{
    self endon( "disconnect" );
    level endon( "end_game" );
    self freezecontrols( 1 );
    wait 0.5;

    if ( !is_true( self.hostmigrationcontrolsfrozen ) )
        self freezecontrols( 0 );
}
