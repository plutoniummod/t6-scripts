// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "default_outdoor", 1 );
    setambientroomtone( "default_outdoor", "amb_wind_extreior_2d", 0.2, 0.5 );
    setambientroomreverb( "default_outdoor", "meltdown_outdoor", 1, 1 );
    setambientroomcontext( "default_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "meltdown_partial_room" );
    setambientroomreverb( "meltdown_partial_room", "meltdown_partial_room", 1, 1 );
    setambientroomcontext( "meltdown_partial_room", "ringoff_plr", "outdoor" );
    declareambientroom( "meltdown_small_room" );
    setambientroomreverb( "meltdown_small_room", "meltdown_small_room", 1, 1 );
    setambientroomcontext( "meltdown_small_room", "ringoff_plr", "indoor" );
    declareambientroom( "meltdown_small_room_partial" );
    setambientroomreverb( "meltdown_small_room_partial", "meltdown_small_room", 1, 1 );
    setambientroomcontext( "meltdown_small_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "meltdown_medium_room" );
    setambientroomreverb( "meltdown_medium_room", "meltdown_medium_room", 1, 1 );
    setambientroomcontext( "meltdown_medium_room", "ringoff_plr", "indoor" );
    declareambientroom( "meltdown_medium_room_partial" );
    setambientroomreverb( "meltdown_medium_room_partial", "meltdown_medium_room", 1, 1 );
    setambientroomcontext( "meltdown_medium_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "meltdown_large_room" );
    setambientroomreverb( "meltdown_large_room", "meltdown_large_room", 1, 1 );
    setambientroomcontext( "meltdown_large_room", "ringoff_plr", "indoor" );
    declareambientroom( "meltdown_open_room" );
    setambientroomreverb( "meltdown_open_room", "meltdown_open_room", 1, 1 );
    setambientroomcontext( "meltdown_open_room", "ringoff_plr", "outdoor" );
    declareambientroom( "meltdown_dense_hallway" );
    setambientroomreverb( "meltdown_dense_hallway", "meltdown_dense_hallway", 1, 1 );
    setambientroomcontext( "meltdown_dense_hallway", "ringoff_plr", "indoor" );
    declareambientroom( "meltdown_stone_room" );
    setambientroomreverb( "meltdown_stone_room", "meltdown_stone_room", 1, 1 );
    setambientroomcontext( "meltdown_stone_room", "ringoff_plr", "indoor" );
    declareambientroom( "meltdown_container" );
    setambientroomreverb( "meltdown_container", "meltdown_container", 1, 1 );
    setambientroomcontext( "meltdown_container", "ringoff_plr", "indoor" );
    declareambientroom( "meltdown_tower" );
    setambientroomreverb( "meltdown_tower", "meltdown_tower", 1, 1 );
    setambientroomcontext( "meltdown_tower", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{
    playloopat( "amb_ribbon_flap", ( 258, -617, -2 ) );
    playloopat( "amb_ribbon_flap", ( 1364, 839, 30 ) );
    playloopat( "amb_ribbon_flap", ( 1364, 714, -2 ) );
    playloopat( "amb_ceiling_fan", ( 678, 3206, 102 ) );
    playloopat( "amb_ceiling_fan", ( 399, 3205, 105 ) );
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_mp_water_rain_cooling_tower", "amb_water_in_silo", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_insects_swarm_lg_light", "amb_insects", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_water_drip_light_long", "amb_water_drips", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_vent_heat_distort", "amb_heat_distort", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_vent_steam_windy", "amb_exhaust", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_vent_steam_line", "amb_exhaust", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_outdoor_wall03_white", "amb_wall_lights", 0, 0, 0, 0 );
}
