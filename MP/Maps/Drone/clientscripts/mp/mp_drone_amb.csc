// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "drone_outdoor", 1 );
    setambientroomtone( "drone_outdoor", "amb_wind_extreior_2d", 0.55, 1 );
    setambientroomreverb( "drone_outdoor", "drone_outdoor", 1, 1 );
    setambientroomcontext( "drone_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_partial_room" );
    setambientroomreverb( "drone_partial_room", "drone_partial_room", 1, 1 );
    setambientroomcontext( "drone_partial_room", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_small_partial" );
    setambientroomreverb( "drone_small_partial", "drone_small_partial", 1, 1 );
    setambientroomcontext( "drone_small_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_small_room" );
    setambientroomreverb( "drone_small_room", "drone_small_room", 1, 1 );
    setambientroomcontext( "drone_small_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_entry_room" );
    setambientroomreverb( "drone_entry_room", "drone_entry_room", 1, 1 );
    setambientroomcontext( "drone_entry_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_medium_room" );
    setambientroomreverb( "drone_medium_room", "drone_medium_room", 1, 1 );
    setambientroomcontext( "drone_medium_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_large_room" );
    setambientroomreverb( "drone_large_room", "drone_large_room", 1, 1 );
    setambientroomcontext( "drone_large_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_open_room" );
    setambientroomreverb( "drone_open_room", "drone_open_room", 1, 1 );
    setambientroomcontext( "drone_open_room", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_dense_hallway" );
    setambientroomreverb( "drone_dense_hallway", "drone_dense_hallway", 1, 1 );
    setambientroomcontext( "drone_dense_hallway", "ringoff_plr", "indoor" );
    declareambientroom( "drone_indoor_hallway" );
    setambientroomreverb( "drone_indoor_hallway", "drone_indoor_hallway", 1, 1 );
    setambientroomcontext( "drone_indoor_hallway", "ringoff_plr", "indoor" );
    declareambientroom( "drone_indoor_hallway_partial" );
    setambientroomreverb( "drone_indoor_hallway_partial", "drone_indoor_hallway", 1, 1 );
    setambientroomcontext( "drone_indoor_hallway_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_outdoor_hallway" );
    setambientroomreverb( "drone_outdoor_hallway", "drone_outdoor_hallway", 1, 1 );
    setambientroomcontext( "drone_outdoor_hallway", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_stone_room" );
    setambientroomreverb( "drone_stone_room", "drone_stone_room", 1, 1 );
    setambientroomcontext( "drone_stone_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_container" );
    setambientroomreverb( "drone_container", "drone_container", 1, 1 );
    setambientroomcontext( "drone_container", "ringoff_plr", "indoor" );
    declareambientroom( "drone_small_helipad_room" );
    setambientroomreverb( "drone_small_helipad_room", "drone_small_room", 1, 1 );
    setambientroomcontext( "drone_small_helipad_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_small_helipad_room_partial" );
    setambientroomreverb( "drone_small_helipad_room_partial", "drone_small_room", 1, 1 );
    setambientroomcontext( "drone_small_helipad_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_small_under_helipad_room" );
    setambientroomreverb( "drone_small_under_helipad_room", "drone_cave", 1, 1 );
    setambientroomcontext( "drone_small_under_helipad_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_small_carpet_room" );
    setambientroomreverb( "drone_small_carpet_room", "drone_carpet", 1, 1 );
    setambientroomcontext( "drone_small_carpet_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_small_carpet_partial_room" );
    setambientroomreverb( "drone_small_carpet_partial_room", "drone_carpet", 1, 1 );
    setambientroomcontext( "drone_small_carpet_partial_room", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_large_hanger_room" );
    setambientroomreverb( "drone_large_hanger_room", "drone_hangar", 1, 1 );
    setambientroomcontext( "drone_large_hanger_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_small_comp_room" );
    setambientroomreverb( "drone_small_comp_room", "drone_small_comp", 1, 1 );
    setambientroomcontext( "drone_small_comp_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_small_comp_room_partial" );
    setambientroomreverb( "drone_small_comp_room_partial", "drone_small_comp", 1, 1 );
    setambientroomcontext( "drone_small_comp_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_factory" );
    setambientroomreverb( "drone_factory", "drone_factory", 1, 1 );
    setambientroomcontext( "drone_factory", "ringoff_plr", "indoor" );
    declareambientroom( "drone_factory_partial" );
    setambientroomreverb( "drone_factory_partial", "drone_factory", 1, 1 );
    setambientroomcontext( "drone_factory_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_large_machine_room" );
    setambientroomreverb( "drone_large_machine_room", "drone_factory", 1, 1 );
    setambientroomcontext( "drone_large_machine_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_small_brick_room" );
    setambientroomreverb( "drone_small_brick_room", "drone_stone_room", 1, 1 );
    setambientroomcontext( "drone_small_brick_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_small_tile_room" );
    setambientroomreverb( "drone_small_tile_room", "drone_tile_room", 1, 1 );
    setambientroomcontext( "drone_small_tile_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_small_marble_room" );
    setambientroomreverb( "drone_small_marble_room", "drone_marble_room", 1, 1 );
    setambientroomcontext( "drone_small_marble_room", "ringoff_plr", "indoor" );
    declareambientroom( "drone_small_marble_room_partial" );
    setambientroomreverb( "drone_small_marble_room_partial", "drone_marble_room", 1, 1 );
    setambientroomcontext( "drone_small_marble_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_hangar_hall" );
    setambientroomreverb( "drone_hangar_hall", "drone_hangar_hall", 1, 1 );
    setambientroomcontext( "drone_hangar_hall", "ringoff_plr", "indoor" );
    declareambientroom( "drone_hangar_hall_partial" );
    setambientroomreverb( "drone_hangar_hall_partial", "drone_hangar_hall", 1, 1 );
    setambientroomcontext( "drone_hangar_hall_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "drone_stairwell" );
    setambientroomreverb( "drone_stairwell", "drone_stairwell", 1, 1 );
    setambientroomcontext( "drone_stairwell", "ringoff_plr", "indoor" );
    thread snd_start_autofdrone_audio();
    thread snd_play_loopers();
    thread scanner_alert();
}

snd_play_loopers()
{
    playloopat( "amb_factory_fans", ( -1872, -1079, 355 ) );
    playloopat( "amb_floor_grate", ( -130, 268, 105 ) );
    playloopat( "amb_cave_drip", ( -72, -1215, -21 ) );
    playloopat( "amb_cave_drip", ( -93, -1148, -28 ) );
    playloopat( "amb_cave_drip", ( -59, -1005, -33 ) );
    playloopat( "amb_cave_drip", ( 179, -831, -31 ) );
    playloopat( "amb_exahust", ( -181, 1236, 239 ) );
    playloopat( "amb_exahust", ( -181, 1394, 239 ) );
    playloopat( "amb_scanner_idle", ( -551, -718, 62 ) );
    playloopat( "amb_scanner_idle", ( -770, -712, 68 ) );
    playloopat( "amb_tarp_flap", ( -65, -1258, 295 ) );
    playloopat( "amb_tarp_flap", ( -324, -686, 291 ) );
    playloopat( "amb_tarp_flap", ( 106, -718, 339 ) );
}

snd_start_autofdrone_audio()
{
    snd_play_auto_fx( "fx_mp_drone_interior_steam", "amb_ceilng_fog", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_ceiling_circle_light_glare", "amb_hall_ceiling_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_drone_red_ring_console_runner", "amb_screens_a", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_drone_rectangle_light_blue", "amb_blue_underground_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_wall_water_ground", "amb_gutter_flow", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_steam_pipe_md", "amb_steam_hiss", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_water_drip_light_long", "amb_water_drip", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_water_drip_light_shrt", "amb_water_drip", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_insects_swarm_dark_lg", "amb_flies", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_hvac_steam_md", "amb_fan_steam", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_drone_rectangle_light_skinny", "amb_hall_ceiling_lights", 0, 0, 0, 0 );
}

scanner_alert()
{
    scannertrig = getent( 0, "scanner_alert", "targetname" );

    if ( isdefined( scannertrig ) )
    {
        for (;;)
        {
            scannertrig waittill( "trigger", trigplayer );

            scannertrig thread trigger_thread( trigplayer, ::trig_enter_alarm, ::trig_leave_alarm );
            wait 0.25;
        }
    }
}

trig_enter_alarm( trigplayer )
{
    self playsound( 0, "amb_scanner_detect" );
    wait 0.25;
    playsound( 0, "amb_scanner_alarm", ( -460, -809, -438 ) );
}

trig_leave_alarm( trigplayer )
{

}
