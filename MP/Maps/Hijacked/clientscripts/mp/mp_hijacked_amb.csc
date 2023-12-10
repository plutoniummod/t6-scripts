// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "hijacked_outdoor", 1 );
    setambientroomtone( "hijacked_outdoor", "amb_wind_extreior_2d", 0.55, 1 );
    setambientroomreverb( "hijacked_outdoor", "hijacked_outdoor", 1, 1 );
    setambientroomcontext( "hijacked_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "hijacked_tile_room" );
    setambientroomreverb( "hijacked_tile_room", "hijacked_tile_room", 1, 1 );
    setambientroomcontext( "hijacked_tile_room", "ringoff_plr", "indoor" );
    declareambientroom( "hijacked_tile_room_partial" );
    setambientroomreverb( "hijacked_tile_room_partial", "hijacked_tile_room", 1, 1 );
    setambientroomcontext( "hijacked_tile_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "hijacked_carpet_room" );
    setambientroomreverb( "hijacked_carpet_room", "hijacked_smallroom", 1, 1 );
    setambientroomcontext( "hijacked_carpet_room", "ringoff_plr", "indoor" );
    declareambientroom( "hijacked_carpet_room_partial" );
    setambientroomreverb( "hijacked_carpet_room_partial", "hijacked_smallroom", 1, 1 );
    setambientroomcontext( "hijacked_carpet_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "hijacked_wood_room" );
    setambientroomreverb( "hijacked_wood_room", "hijacked_wood_room", 1, 1 );
    setambientroomcontext( "hijacked_wood_room", "ringoff_plr", "indoor" );
    declareambientroom( "hijacked_wood_room_partial" );
    setambientroomreverb( "hijacked_wood_room_partial", "hijacked_wood_room", 1, 1 );
    setambientroomcontext( "hijacked_wood_room_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "hijacked_heli_pad_cover" );
    setambientroomreverb( "hijacked_heli_pad_cover", "hijacked__heli_pad_cover", 1, 1 );
    setambientroomcontext( "hijacked_heli_pad_cover", "ringoff_plr", "outdoor" );
    declareambientroom( "hijacked_cabana" );
    setambientroomreverb( "hijacked_cabana", "hijacked_cabana", 1, 1 );
    setambientroomcontext( "hijacked_cabana", "ringoff_plr", "outdoor" );
    declareambientroom( "hijacked_eng_rm_hallway" );
    setambientroomreverb( "hijacked_eng_rm_hallway", "hijacked_eng_rm_hallway", 1, 1 );
    setambientroomcontext( "hijacked_eng_rm_hallway", "ringoff_plr", "indoor" );
    declareambientroom( "hijacked_laundry_rm" );
    setambientroomreverb( "hijacked_laundry_rm", "hijacked_wood_room", 1, 1 );
    setambientroomcontext( "hijacked_laundry_rm", "ringoff_plr", "indoor" );
    declareambientroom( "hijacked_laundry_rm_partial" );
    setambientroomreverb( "hijacked_laundry_rm_partial", "hijacked_wood_room", 1, 1 );
    setambientroomcontext( "hijacked_laundry_rm_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "hijacked_engine_room" );
    setambientroomreverb( "hijacked_engine_room", "hijacked_engine_room", 1, 1 );
    setambientroomcontext( "hijacked_engine_room", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{
    soundloopemitter( "amb_ribbon_flap", ( -95, 76, -60 ) );
    soundloopemitter( "amb_radar_ping_lp", ( -415, -120, -86 ) );
    soundloopemitter( "amb_radar_ping_lp", ( -330, -16, -111 ) );
}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_mp_water_drip_light_shrt", "amb_engine_rm_drips", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_mp_vent_heat_distort", "amb_vent", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_flour_glow_v_shape_cool", "amb_flourescent_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_flour_glow_v_shape_cool_sm", "amb_flourescent_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_light_recessed_cool_sm", "amb_outside_lights", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_vent_steam_sm", "amb_jacuzzi_steam", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_water_shower_dribble_splsh", "amb_shower_splash", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_water_shower_dribble", "amb_shower_drip", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_raid_hot_tub_sm", "amb_jacuzzi_bubbles", 0, 0, 0, 0 );
}
