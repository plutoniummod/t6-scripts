// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "default", 1 );
    setambientroomtone( "default", "amb_battel_2d", 0.2, 0.5 );
    setambientroomreverb( "default", "socotra_outdoor", 1, 1 );
    setambientroomcontext( "default", "ringoff_plr", "outdoor" );
    declareambientroom( "under_bridge" );
    setambientroomreverb( "under_bridge", "socotra_stoneroom", 1, 1 );
    setambientroomcontext( "under_bridge", "ringoff_plr", "outdoor" );
    declareambientroom( "small_room" );
    setambientroomreverb( "small_room", "socotra_smallroom", 1, 1 );
    setambientroomcontext( "small_room", "ringoff_plr", "indoor" );
    declareambientroom( "small_room_partial" );
    setambientroomreverb( "small_room_partial", "socotra_smallroom", 1, 1 );
    setambientroomcontext( "small_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "medium_room" );
    setambientroomreverb( "medium_room", "socotra_mediumroom", 1, 1 );
    setambientroomcontext( "medium_room", "ringoff_plr", "indoor" );
    declareambientroom( "medium_room_partial" );
    setambientroomreverb( "medium_room_partial", "socotra_mediumroom", 1, 1 );
    setambientroomcontext( "medium_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "largeroom_room" );
    setambientroomreverb( "largeroom_room", "socotra_largeroom", 1, 1 );
    setambientroomcontext( "largeroom_room", "ringoff_plr", "indoor" );
    declareambientroom( "hallroom" );
    setambientroomreverb( "hallroom", "socotra_hallroom", 1, 1 );
    setambientroomcontext( "hallroom", "ringoff_plr", "indoor" );
    declareambientroom( "hallroom_partial" );
    setambientroomreverb( "hallroom_partial", "socotra_hallroom", 1, 1 );
    setambientroomcontext( "hallroom_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "partialroom" );
    setambientroomreverb( "partialroom", "socotra_partialroom", 1, 1 );
    setambientroomcontext( "partialroom", "ringoff_plr", "outdoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{
    playloopat( "amb_battle_dist", ( -1404, 166, 1299 ) );
    playloopat( "amb_rope_creak", ( 2187, -231, 386 ) );
    playloopat( "amb_rope_creak", ( 2119, -503, 391 ) );
    playloopat( "amb_rope_creak", ( -37, -2296, 244 ) );
    playloopat( "amb_rope_creak", ( -277, 993, 475 ) );
    playloopat( "amb_rope_creak", ( 227, 425, 267 ) );
    playloopat( "amb_rope_creak", ( 431, 255, 267 ) );
    playloopat( "amb_rope_creak", ( 595, 257, 252 ) );
    playloopat( "amb_rope_creak", ( -614, -317, 355 ) );
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_insects_swarm_md_light", "amb_insects_flys_md", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_insects_fly_swarm_lng", "amb_insects_flys_lg", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_insects_fly_swarm", "amb_insects_flys_swarm", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_water_drip_light_shrt", "amb_water_drip", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_water_drip_light_long", "amb_water_drip_2", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_fire_fuel_sm", "amb_fire_large", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_water_faucet_on", "amb_water_faucet", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_water_faucet_splash", "amb_water_faucet_splash", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_fire_fireplace_md", "amb_fireplace", 0, 0, 0, 0 );
}
