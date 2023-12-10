// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "village_outdoor", 1 );
    setambientroomtone( "village_outdoor", "amb_wind_extreior_2d", 0.55, 1 );
    setambientroomreverb( "village_outdoor", "village_outdoor", 1, 1 );
    setambientroomcontext( "village_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "village_gas_station" );
    setambientroomreverb( "village_gas_station", "village_gas_station", 1, 1 );
    setambientroomcontext( "village_gas_station", "ringoff_plr", "indoor" );
    declareambientroom( "village_gas_station_partial" );
    setambientroomreverb( "village_gas_station_partial", "gen_smallroom", 1, 1 );
    setambientroomcontext( "village_gas_station_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "village_wood_house" );
    setambientroomreverb( "village_wood_house", "village_house_room", 1, 1 );
    setambientroomcontext( "village_wood_house", "ringoff_plr", "indoor" );
    declareambientroom( "village_wood_house_partial" );
    setambientroomreverb( "village_wood_house_partial", "village_house_room", 1, 1 );
    setambientroomcontext( "village_wood_house_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "village_garage" );
    setambientroomreverb( "village_garage", "village_garage", 1, 1 );
    setambientroomcontext( "village_garage", "ringoff_plr", "indoor" );
    declareambientroom( "village_garage_partial" );
    setambientroomreverb( "village_garage_partial", "village_garage", 1, 1 );
    setambientroomcontext( "village_garage_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "village_garage_stairs" );
    setambientroomreverb( "village_garage_stairs", "village_garage_stairs", 1, 1 );
    setambientroomcontext( "village_garage_stairs", "ringoff_plr", "indoor" );
    declareambientroom( "village_garage_office" );
    setambientroomreverb( "village_garage_office", "village_house_room", 1, 1 );
    setambientroomcontext( "village_garage_office", "ringoff_plr", "indoor" );
    declareambientroom( "village_garage_office_partial" );
    setambientroomreverb( "village_garage_office_partial", "village_house_room", 1, 1 );
    setambientroomcontext( "village_garage_office_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "village_stables" );
    setambientroomreverb( "village_stables", "gen_smallroom", 1, 1 );
    setambientroomcontext( "village_stables", "ringoff_plr", "outdoor" );
    declareambientroom( "village_store" );
    setambientroomreverb( "village_store", "village_store", 1, 1 );
    setambientroomcontext( "village_store", "ringoff_plr", "indoor" );
    declareambientroom( "village_store_partial" );
    setambientroomreverb( "village_store_partial", "village_store", 1, 1 );
    setambientroomcontext( "village_store_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "village_store_storage" );
    setambientroomreverb( "village_store_storage", "village_store_storage", 1, 1 );
    setambientroomcontext( "village_store_storage", "ringoff_plr", "indoor" );
    declareambientroom( "village_store_hallway" );
    setambientroomreverb( "village_store_hallway", "village_store_hallway", 1, 1 );
    setambientroomcontext( "village_store_hallway", "ringoff_plr", "indoor" );
    declareambientroom( "village_store_hallway_partial" );
    setambientroomreverb( "village_store_hallway_partial", "village_store_hallway", 1, 1 );
    setambientroomcontext( "village_store_hallway_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "village_diner" );
    setambientroomreverb( "village_diner", "village_diner", 1, 1 );
    setambientroomcontext( "village_diner", "ringoff_plr", "indoor" );
    declareambientroom( "village_diner_partial" );
    setambientroomreverb( "village_diner_partial", "village_diner", 1, 1 );
    setambientroomcontext( "village_diner_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "village_house_kitchen" );
    setambientroomreverb( "village_house_kitchen", "village_house_kitchen", 1, 1 );
    setambientroomcontext( "village_house_kitchen", "ringoff_plr", "indoor" );
    declareambientroom( "village_house_kitchen_partial" );
    setambientroomreverb( "village_house_kitchen_partial", "village_house_kitchen", 1, 1 );
    setambientroomcontext( "village_house_kitchen_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "village_house_room" );
    setambientroomreverb( "village_house_room", "village_house_room", 1, 1 );
    setambientroomcontext( "village_house_room", "ringoff_plr", "indoor" );
    declareambientroom( "village_house_room_partial" );
    setambientroomreverb( "village_house_room_partial", "village_house_room", 1, 1 );
    setambientroomcontext( "village_house_room_partial", "ringoff_plr", "outdoor" );
    thread snd_start_autofx_audio();
}

snd_play_loopers()
{

}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_village_tube_light", "amb_tube_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_insects_swarm_lg_light", "amb_flies", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_village_tube_light_sq", "amb_tube_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_drone_rectangle_light_03", "amb_light_03", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_village_rectangle_light_01", "amb_light_03", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_village_barrel_fire", "amb_fire_sml", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_village_single_glare", "amb_cone_light", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_village_statue_water", "amb_water_fountain", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_slums_fire_sm", "amb_fire_sml", 0, 0, 0, 0 );
}
