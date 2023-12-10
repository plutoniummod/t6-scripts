// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "mirage_outdoor", 1 );
    setambientroomtone( "mirage_outdoor", "amb_wind_exterior_2d", 0.5, 1 );
    setambientroomreverb( "mirage_outdoor", "mirage_outdoor", 1, 1 );
    setambientroomcontext( "mirage_outdoor", "ringoff_plr", "outdoor" );
    declareambientroom( "bus_interior" );
    setambientroomtone( "bus_interior", "amb_wind_exterior_2d_qt", 0.5, 1 );
    setambientroomreverb( "bus_interior", "mirage_bus", 1, 1 );
    setambientroomcontext( "bus_interior", "ringoff_plr", "indoor" );
    declareambientroom( "guardhouse_room" );
    setambientroomtone( "guardhouse_room", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "guardhouse_room", "mirage_gaurdroom", 1, 1 );
    setambientroomcontext( "guardhouse_room", "ringoff_plr", "indoor" );
    declareambientroom( "kitchen_room" );
    setambientroomtone( "kitchen_room", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "kitchen_room", "mirage_medium_room", 1, 1 );
    setambientroomcontext( "kitchen_room", "ringoff_plr", "indoor" );
    declareambientroom( "veranda_room" );
    setambientroomtone( "veranda_room", "amb_wind_exterior_2d_qt", 0.5, 1 );
    setambientroomreverb( "veranda_room", "mirage_partial_room", 1, 1 );
    setambientroomcontext( "veranda_room", "ringoff_plr", "outdoor" );
    declareambientroom( "open_room" );
    setambientroomtone( "open_room", "amb_wind_exterior_2d_qt", 0.5, 1 );
    setambientroomreverb( "open_room", "mirage_open_room", 1, 1 );
    setambientroomcontext( "open_room", "ringoff_plr", "outdoor" );
    declareambientroom( "med_living_room" );
    setambientroomtone( "med_living_room", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "med_living_room", "mirage_medium_room", 1, 1 );
    setambientroomcontext( "med_living_room", "ringoff_plr", "indoor" );
    declareambientroom( "cave_tile_room" );
    setambientroomtone( "cave_tile_room", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "cave_tile_room", "mirage_tile_room", 1, 1 );
    setambientroomcontext( "cave_tile_room", "ringoff_plr", "indoor" );
    declareambientroom( "center_atrium_room" );
    setambientroomtone( "center_atrium_room", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "center_atrium_room", "mirage_large_room", 1, 1 );
    setambientroomcontext( "center_atrium_room", "ringoff_plr", "indoor" );
    declareambientroom( "elevator_room" );
    setambientroomtone( "elevator_room", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "elevator_room", "mirage_elevator_area", 1, 1 );
    setambientroomcontext( "elevator_room", "ringoff_plr", "indoor" );
    declareambientroom( "central_anteroom" );
    setambientroomtone( "central_anteroom", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "central_anteroom", "mirage_smallroom", 1, 1 );
    setambientroomcontext( "central_anteroom", "ringoff_plr", "indoor" );
    declareambientroom( "vault_room" );
    setambientroomtone( "vault_room", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "vault_room", "mirage_vault", 1, 1 );
    setambientroomcontext( "vault_room", "ringoff_plr", "indoor" );
    declareambientroom( "stairwell_room" );
    setambientroomtone( "stairwell_room", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "stairwell_room", "mirage_stairs", 1, 1 );
    setambientroomcontext( "stairwell_room", "ringoff_plr", "indoor" );
    declareambientroom( "sand_house_room" );
    setambientroomtone( "sand_house_room", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "sand_house_room", "mirage_medium_room", 1, 1 );
    setambientroomcontext( "sand_house_room", "ringoff_plr", "indoor" );
    declareambientroom( "archway_room" );
    setambientroomtone( "archway_room", "amb_wind_exterior_2d", 0.5, 1 );
    setambientroomreverb( "archway_room", "mirage_outdoor", 1, 1 );
    setambientroomcontext( "archway_room", "ringoff_plr", "outdoor" );
    declareambientroom( "small_sitting_room" );
    setambientroomtone( "small_sitting_room", "amb_wind_interior_2d", 0.5, 1 );
    setambientroomreverb( "small_sitting_room", "mirage_smallroom", 1, 1 );
    setambientroomcontext( "small_sitting_room", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{

}

snd_start_autofx_audio()
{

}
