// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_audio;

main()
{
    declareambientroom( "slums_outside", 1 );
    setambientroomreverb( "slums_outside", "slums_outdoor", 1, 1 );
    setambientroomcontext( "slums_outside", "ringoff_plr", "outdoor" );
    declareambientroom( "slums_garage" );
    setambientroomreverb( "slums_garage", "slums_garage", 1, 1 );
    setambientroomcontext( "slums_garage", "ringoff_plr", "indoor" );
    declareambientroom( "slums_garage_partial" );
    setambientroomreverb( "slums_garage_partial", "slums_garage", 1, 1 );
    setambientroomcontext( "slums_garage_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "slums_broken_bldg" );
    setambientroomreverb( "slums_broken_bldg", "slums_broken_bldg", 1, 1 );
    setambientroomcontext( "slums_broken_bldg", "ringoff_plr", "indoor" );
    declareambientroom( "slums_broken_bldg_partial" );
    setambientroomreverb( "slums_broken_bldg_partial", "slums_broken_bldg", 1, 1 );
    setambientroomcontext( "slums_broken_bldg_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "slums_broken_bldg_md" );
    setambientroomreverb( "slums_broken_bldg_md", "slums_broken_bldg_md", 1, 1 );
    setambientroomcontext( "slums_broken_bldg_md", "ringoff_plr", "indoor" );
    declareambientroom( "slums_broken_bldg_md_partial" );
    setambientroomreverb( "slums_broken_bldg_md_partial", "slums_broken_bldg_md", 1, 1 );
    setambientroomcontext( "slums_broken_bldg_md_partial", "ringoff_plr", "outdoor" );
    declareambientroom( "slums_over_hang" );
    setambientroomreverb( "slums_over_hang", "slums_over_hang", 1, 1 );
    setambientroomcontext( "slums_over_hang", "ringoff_plr", "outdoor" );
    declareambientroom( "slums_mtl_shed_open" );
    setambientroomreverb( "slums_mtl_shed_open", "slums_alley", 1, 1 );
    setambientroomcontext( "slums_mtl_shed_open", "ringoff_plr", "outdoor" );
    declareambientroom( "slums_alley" );
    setambientroomreverb( "slums_alley", "slums_alley", 1, 1 );
    setambientroomcontext( "slums_alley", "ringoff_plr", "indoor" );
    thread snd_start_autofx_audio();
    thread snd_play_loopers();
}

snd_play_loopers()
{

}

snd_start_autofx_audio()
{
    snd_play_auto_fx( "fx_insects_swarm_lg_light", "amb_flies_sml", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_insects_swarm_dark_lg", "amb_flies_lrg", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_slums_fire_lg", "amb_fire_lrg", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_slums_fire_sm", "amb_fire_sm", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_mp_slums_sprinkle_water", "amb_water_sprinkler", 0, 0, 0, 0 );
    snd_play_auto_fx( "fx_pipe_water_ground", "amb_pipe_water", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_water_splash_detail", "amb_water_splash", 0, 0, 0, 1 );
    snd_play_auto_fx( "fx_village_tube_light", "amb_flour_light", 0, 0, 0, 0 );
}
