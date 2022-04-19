// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_buried_sq;

init()
{
    declare_sidequest_stage( "sq", "bt", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
    flag_init( "sq_player_underground" );
    level thread stage_vo();
    level thread stage_start_watcher();
    level._cur_stage_name = "bt";
    clientnotify( "bt" );
}

stage_vo()
{
    level waittill( "start_of_round" );

    level thread stage_vo_watch_underground();
    wait 5;
    maxissay( "vox_maxi_sidequest_maxis_start_1_0" );
    maxissay( "vox_maxi_sidequest_maxis_start_2_0" );
    maxissay( "vox_maxi_sidequest_maxis_start_3_0" );
    maxissay( "vox_maxi_sidequest_maxis_start_4_0" );
    maxissay( "vox_maxi_sidequest_maxis_start_5_0" );
    flag_wait( "sq_player_underground" );
    level.m_maxis_vo_spot.origin = ( -728, -344, 280 );

    while ( isdefined( level.vo_player_who_discovered_stables_roof ) && is_true( level.vo_player_who_discovered_stables_roof.isspeaking ) )
        wait 0.05;

    maxissay( "vox_maxi_sidequest_town_0" );
    maxissay( "vox_maxi_sidequest_town_1" );
    wait 1;
    level thread stage_vo_watch_gallows();

    if ( !level.richcompleted )
    {
        if ( isdefined( level.rich_sq_player ) )
        {
            level.rich_sq_player.dontspeak = 1;
            level.rich_sq_player setclientfieldtoplayer( "isspeaking", 1 );
        }

        richtofensay( "vox_zmba_sidequest_zmba_start_1_0", 3 );

        if ( isdefined( level.rich_sq_player ) )
        {
            while ( isdefined( level.rich_sq_player ) && ( is_true( level.rich_sq_player.isspeaking ) || is_true( level.rich_sq_player.dontspeak ) ) )
                wait 1;

            level.rich_sq_player.dontspeak = 1;
            level.rich_sq_player setclientfieldtoplayer( "isspeaking", 1 );
            level.rich_sq_player playsoundwithnotify( "vox_plr_1_respond_richtofen_0", "sound_done_vox_plr_1_respond_richtofen_0" );

            level.rich_sq_player waittill( "sound_done_vox_plr_1_respond_richtofen_0" );

            wait 1;
            level.rich_sq_player setclientfieldtoplayer( "isspeaking", 0 );
        }

        richtofensay( "vox_zmba_sidequest_zmba_start_3_0", 4 );

        if ( isdefined( level.rich_sq_player ) )
        {
            while ( isdefined( level.rich_sq_player ) && ( is_true( level.rich_sq_player.isspeaking ) || is_true( level.rich_sq_player.dontspeak ) ) )
                wait 1;

            level.rich_sq_player.dontspeak = 1;
            level.rich_sq_player setclientfieldtoplayer( "isspeaking", 1 );
            level.rich_sq_player playsoundwithnotify( "vox_plr_1_respond_richtofen_1", "sound_done_vox_plr_1_respond_richtofen_1" );

            level.rich_sq_player waittill( "sound_done_vox_plr_1_respond_richtofen_1" );

            wait 1;
            level.rich_sq_player setclientfieldtoplayer( "isspeaking", 0 );
        }

        richtofensay( "vox_zmba_sidequest_zmba_start_5_0", 12 );
        richtofensay( "vox_zmba_sidequest_zmba_start_6_0", 8 );

        if ( isdefined( level.rich_sq_player ) )
        {
            while ( isdefined( level.rich_sq_player ) && ( is_true( level.rich_sq_player.isspeaking ) || is_true( level.rich_sq_player.dontspeak ) ) )
                wait 1;

            level.rich_sq_player.dontspeak = 1;
            level.rich_sq_player setclientfieldtoplayer( "isspeaking", 1 );
            level.rich_sq_player playsoundwithnotify( "vox_plr_1_respond_richtofen_2", "sound_done_vox_plr_1_respond_richtofen_2" );

            level.rich_sq_player waittill( "sound_done_vox_plr_1_respond_richtofen_2" );

            wait 1;
            level.rich_sq_player setclientfieldtoplayer( "isspeaking", 0 );
        }

        richtofensay( "vox_zmba_sidequest_town_0", 6 );
        richtofensay( "vox_zmba_sidequest_town_1", 6 );
    }

    flag_set( "sq_intro_vo_done" );
    level thread stage_vo_nag();
    level thread stage_vo_watch_guillotine();
}

stage_vo_nag()
{
    level endon( "sq_is_max_tower_built" );
    level endon( "sq_is_ric_tower_built" );
    level endon( "end_game_reward_starts_maxis" );
    level endon( "end_game_reward_starts_richtofen" );
    s_struct = getstruct( "sq_gallows", "targetname" );
    m_maxis_vo_spot = spawn( "script_model", s_struct.origin );
    m_maxis_vo_spot setmodel( "tag_origin" );

    for ( i = 0; i < 5; i++ )
    {
        level waittill( "end_of_round" );

        maxissay( "vox_maxi_sidequest_nag_" + i, m_maxis_vo_spot );
        richtofensay( "vox_zmba_sidequest_nag_" + i, 10 );
    }
}

stage_vo_watch_guillotine()
{
    level endon( "sq_bt_over" );
    level endon( "end_game_reward_starts_maxis" );
    level endon( "end_game_reward_starts_richtofen" );
    s_struct = getstruct( "sq_guillotine", "targetname" );
    trigger = spawn( "trigger_radius", s_struct.origin, 0, 128, 72 );

    trigger waittill( "trigger" );

    trigger delete();
    richtofensay( "vox_zmba_sidequest_gallows_0", 9 );
    richtofensay( "vox_zmba_sidequest_gallows_1", 12 );

    level waittill( "rtower_object_planted" );

    richtofensay( "vox_zmba_sidequest_parts_0", 9 );

    level waittill( "rtower_object_planted" );

    richtofensay( "vox_zmba_sidequest_parts_1", 3 );

    level waittill( "rtower_object_planted" );

    richtofensay( "vox_zmba_sidequest_parts_2", 5 );

    level waittill( "rtower_object_planted" );

    richtofensay( "vox_zmba_sidequest_parts_3", 11 );
}

stage_vo_watch_gallows()
{
    level endon( "sq_bt_over" );
    level endon( "end_game_reward_starts_maxis" );
    level endon( "end_game_reward_starts_richtofen" );
    s_struct = getstruct( "sq_gallows", "targetname" );
    trigger = spawn( "trigger_radius", s_struct.origin, 0, 128, 72 );

    trigger waittill( "trigger" );

    trigger delete();
    m_maxis_vo_spot = spawn( "script_model", s_struct.origin );
    m_maxis_vo_spot setmodel( "tag_origin" );

    if ( flag( "sq_intro_vo_done" ) )
        maxissay( "vox_maxi_sidequest_gallows_0", m_maxis_vo_spot );

    for ( i = 0; i < 4; i++ )
    {
        level waittill( "mtower_object_planted" );

        if ( flag( "sq_intro_vo_done" ) )
            maxissay( "vox_maxi_sidequest_parts_" + i, m_maxis_vo_spot, 1 );

        wait_network_frame();
    }

    m_maxis_vo_spot delete();
}

stage_vo_watch_underground()
{
    trigger_wait( "sq_player_underground", "targetname" );
    flag_set( "sq_player_underground" );
}

stage_start_watcher()
{
    level waittill_either( "mtower_object_planted", "rtower_object_planted" );
    flag_set( "sq_started" );
}

stage_logic()
{
/#
    iprintlnbold( "BT Started" );
#/
    level thread wait_for_maxis_tower();
    level thread wait_for_richtofen_tower();
    flag_wait_any( "sq_is_max_tower_built", "sq_is_ric_tower_built" );
    wait_network_frame();
    stage_completed( "sq", level._cur_stage_name );
}

wait_for_maxis_tower()
{
    level endon( "sq_is_ric_tower_built" );
    wait_for_buildable( "buried_sq_bt_m_tower" );
    flag_set( "sq_is_max_tower_built" );
}

wait_for_richtofen_tower()
{
    level endon( "sq_is_max_tower_built" );
    wait_for_buildable( "buried_sq_bt_r_tower" );
    flag_set( "sq_is_ric_tower_built" );
}

exit_stage( success )
{

}
