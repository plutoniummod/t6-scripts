// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\_visionset_mgr;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm;
#include maps\mp\zm_buried_sq;
#include maps\mp\zombies\_zm_weap_time_bomb;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zm_buried_buildables;

init()
{
    declare_sidequest_stage( "sq", "tpo", ::init_stage, ::stage_logic, ::exit_stage );
    flag_init( "sq_tpo_time_bomb_in_valid_location" );
    flag_init( "sq_tpo_players_in_position_for_time_warp" );
    flag_init( "sq_tpo_special_round_active" );
    flag_init( "sq_tpo_found_item" );
    flag_init( "sq_tpo_generator_powered" );
    flag_init( "sq_wisp_saved_with_time_bomb" );
    flag_init( "sq_tpo_stage_started" );
    maps\mp\zombies\_zm_weap_time_bomb::time_bomb_add_custom_func_global_save( ::time_bomb_saves_wisp_state );
    maps\mp\zombies\_zm_weap_time_bomb::time_bomb_add_custom_func_global_restore( ::time_bomb_restores_wisp_state );
/#
    level thread debug_give_piece();
#/
    level._effect["sq_tpo_time_bomb_fx"] = loadfx( "maps/zombie_buried/fx_buried_ghost_drain" );
    level.sq_tpo = spawnstruct();
    level thread setup_buildable_switch();
}

init_stage()
{
    if ( flag( "sq_is_max_tower_built" ) )
        level thread stage_vo_max();
    else
        level thread stage_vo_ric();

    level._cur_stage_name = "tpo";
    clientnotify( "tpo" );
}

stage_vo_max()
{
    s_struct = getstruct( "sq_gallows", "targetname" );
    m_maxis_vo_spot = spawn( "script_model", s_struct.origin );
    m_maxis_vo_spot setmodel( "tag_origin" );
    maxissay( "vox_maxi_sidequest_ctw_5", m_maxis_vo_spot );
    maxissay( "vox_maxi_sidequest_ctw_6", m_maxis_vo_spot );
    maxissay( "vox_maxi_sidequest_ctw_7", m_maxis_vo_spot );
    m_maxis_vo_spot delete();
}

stage_vo_ric()
{
    richtofensay( "vox_zmba_sidequest_ctw_4", 10 );
    richtofensay( "vox_zmba_sidequest_step8_0", 11 );
    richtofensay( "vox_zmba_sidequest_step8_1", 6 );
    richtofensay( "vox_zmba_sidequest_step8_2", 6 );

    level waittill( "sq_tpo_special_round_started" );

    wait 2;
    richtofensay( "vox_zmba_sidequest_step8_3", 6 );

    level waittill( "sq_tpo_special_round_ended" );

    richtofensay( "vox_zmba_sidequest_step8_6", 4 );
}

stage_logic()
{
/#
    iprintlnbold( "TPO Started" );
#/
    flag_set( "sq_tpo_stage_started" );

    if ( flag( "sq_is_ric_tower_built" ) )
        stage_logic_richtofen();
    else if ( flag( "sq_is_max_tower_built" ) )
        stage_logic_maxis();
    else
    {
/#
        assertmsg( "SQ TPO: no sidequest side picked!" );
#/
    }
/#
    iprintlnbold( "TPO done" );
#/
    stage_completed( "sq", level._cur_stage_name );
}

stage_logic_richtofen()
{
    level endon( "sq_tpo_generator_powered" );
/#
    iprintlnbold( "TPO: Richtofen started" );
#/
    e_time_bomb_volume = getent( "sq_tpo_timebomb_volume", "targetname" );

    do
    {
        flag_clear( "sq_tpo_time_bomb_in_valid_location" );

        do
        {
            if ( !( isdefined( level.time_bomb_save_data ) && isdefined( level.time_bomb_save_data.time_bomb_model ) && !isdefined( level.time_bomb_save_data.time_bomb_model.sq_location_valid ) ) )
                level waittill( "new_time_bomb_set" );

            b_time_bomb_in_valid_location = level.time_bomb_save_data.time_bomb_model istouching( e_time_bomb_volume );
            level.time_bomb_save_data.time_bomb_model.sq_location_valid = b_time_bomb_in_valid_location;
        }
        while ( !b_time_bomb_in_valid_location );

        playfxontag( level._effect["sq_tpo_time_bomb_fx"], level.time_bomb_save_data.time_bomb_model, "tag_origin" );
        flag_set( "sq_tpo_time_bomb_in_valid_location" );
        level thread sq_tpo_check_players_in_time_bomb_volume( e_time_bomb_volume );
        wait_for_time_bomb_to_be_detonated_or_thrown_again();
        level notify( "sq_tpo_stop_checking_time_bomb_volume" );

        if ( flag( "time_bomb_restore_active" ) )
        {
            if ( flag( "sq_tpo_players_in_position_for_time_warp" ) )
            {
                special_round_start();
                level notify( "sq_tpo_special_round_started" );
                start_item_hunt_with_timeout( 60 );
                special_round_end();
                level notify( "sq_tpo_special_round_ended" );
            }
        }

        wait_network_frame();
    }
    while ( !flag( "sq_tpo_generator_powered" ) );
}

stage_logic_maxis()
{
/#
    iprintlnbold( "TPO: Maxis started" );
#/
    flag_wait( "sq_wisp_saved_with_time_bomb" );

    while ( !flag( "sq_wisp_success" ) )
    {
        stage_start( "sq", "ts" );

        level waittill( "sq_ts_over" );

        stage_start( "sq", "ctw" );

        level waittill( "sq_ctw_over" );
    }

    level._cur_stage_name = "tpo";
}

sq_tpo_check_players_in_time_bomb_volume( e_volume )
{
    level endon( "sq_tpo_stop_checking_time_bomb_volume" );

    while ( true )
    {
        b_players_ready = _are_all_players_in_time_bomb_volume( e_volume );
        level._time_bomb.functionality_override = b_players_ready;

        if ( b_players_ready )
            flag_set( "sq_tpo_players_in_position_for_time_warp" );
        else
            flag_clear( "sq_tpo_players_in_position_for_time_warp" );

        wait 0.25;
    }
}

_are_all_players_in_time_bomb_volume( e_volume )
{
    n_required_players = 4;
    a_players = get_players();
/#
    if ( getdvarint( _hash_5256118F ) > 0 )
        n_required_players = a_players.size;
#/
    n_players_in_position = 0;

    foreach ( player in a_players )
    {
        if ( player istouching( e_volume ) )
            n_players_in_position++;
    }

    b_all_in_valid_position = n_players_in_position == n_required_players;
    return b_all_in_valid_position;
}

wait_for_time_bomb_to_be_detonated_or_thrown_again()
{
    level endon( "new_time_bomb_set" );
    flag_wait( "time_bomb_restore_active" );
}

special_round_start()
{
/#
    iprintlnbold( "SPECIAL ROUND START" );
#/
    flag_set( "sq_tpo_special_round_active" );
    level.sq_tpo.times_searched = 0;
    maps\mp\zombies\_zm_weap_time_bomb::time_bomb_saves_data( 0 );
    flag_clear( "time_bomb_detonation_enabled" );
    fake_time_warp();
    level thread sndsidequestnoirmusic();
    make_super_zombies( 1 );
    level thread spawn_zombies_after_time_bomb_round_killed();
    a_players = get_players();

    foreach ( player in a_players )
        vsmgr_activate( "visionset", "cheat_bw", player );

    level setclientfield( "sq_tpo_special_round_active", 1 );
}

make_super_zombies( b_toggle )
{
    if ( b_toggle )
    {
        n_round = 115;
        level thread watch_for_time_bombs( n_round );
    }
    else
    {
        n_round = level.round_number;
        level notify( "super_zombies_end" );
    }

    level.zombie_total = n_round;
    ai_calculate_health( n_round );
    level.zombie_move_speed = n_round * level.zombie_vars["zombie_move_speed_multiplier"];
}

watch_for_time_bombs( n_round )
{
    level notify( "super_zombies_end" );
    level endon( "super_zombies_end" );

    while ( true )
    {
        level waittill_any( "time_bomb_detonation_complete", "start_of_round" );
        level.zombie_total = n_round;
        ai_calculate_health( n_round );
        level.zombie_move_speed = n_round * level.zombie_vars["zombie_move_speed_multiplier"];
    }
}

spawn_zombies_after_time_bomb_round_killed()
{
    flag_wait( "time_bomb_round_killed" );
    flag_set( "spawn_zombies" );
}

fake_time_warp()
{
    maps\mp\zombies\_zm_weap_time_bomb::time_bomb_destroy_hud_elem();
    maps\mp\zombies\_zm_weap_time_bomb::_time_bomb_show_overlay();
    maps\mp\zombies\_zm_weap_time_bomb::_time_bomb_kill_all_active_enemies();
    playsoundatposition( "zmb_timebomb_timechange_2d_sq", ( 0, 0, 0 ) );
    maps\mp\zombies\_zm_weap_time_bomb::_time_bomb_hide_overlay();
}

special_round_end()
{
/#
    iprintlnbold( "SPECIAL ROUND END" );
#/
    level setclientfield( "sq_tpo_special_round_active", 0 );
    level notify( "sndEndNoirMusic" );
    make_super_zombies( 0 );
    level._time_bomb.functionality_override = 0;
    flag_set( "time_bomb_detonation_enabled" );
    maps\mp\zombies\_zm_weap_time_bomb::time_bomb_restores_saved_data();
    a_players = get_players();

    foreach ( player in a_players )
    {
        vsmgr_deactivate( "visionset", "cheat_bw", player );
        player notify( "search_done" );
    }

    clean_up_special_round();
    flag_clear( "sq_tpo_special_round_active" );
}

clean_up_special_round()
{
    a_models = getentarray( "sq_tpo_corpse_model", "targetname" );

    foreach ( model in a_models )
    {
        model _delete_unitrigger();
        model delete();
    }
}

_delete_unitrigger()
{
    if ( isdefined( self.unitrigger ) )
        self.unitrigger.registered = 0;

    if ( isdefined( self.unitrigger.trigger ) )
    {
        if ( isdefined( self.unitrigger.trigger.stub ) )
            self.unitrigger.trigger maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.unitrigger.trigger.stub );
        else
        {
            self.trigger notify( "kill_trigger" );
            self.trigger delete();
        }
    }
}

start_item_hunt_with_timeout( n_timeout )
{
    setup_random_corpse_positions();
    level delay_notify( "sq_tpo_item_hunt_done", n_timeout );
/#
    iprintlnbold( "ITEM HUNT STARTED" );
#/
    level waittill( "sq_tpo_item_hunt_done" );
}

exit_stage( success )
{

}

debug_give_piece()
{
    while ( true )
    {
        level waittill( "sq_tpo_give_item" );

        get_players()[0] give_player_sq_tpo_switch();
    }
}

get_randomized_corpse_list()
{
    a_corpses = array( "c_zom_player_farmgirl_fb", "c_zom_player_oldman_fb", "c_zom_player_reporter_dam_fb", "c_zom_player_engineer_fb" );
    a_corpses = array_randomize( a_corpses );
    return a_corpses;
}

setup_random_corpse_positions()
{
    a_corpse_models = get_randomized_corpse_list();
    a_corpse_structs = array_randomize( getstructarray( "sq_tpo_corpse_spawn_location", "targetname" ) );

    for ( i = 0; i < a_corpse_models.size; i++ )
    {
        a_corpse_structs[i] promote_to_corpse_model( a_corpse_models[i] );
        a_corpse_structs[i] thread _debug_show_location();
    }
}

_debug_show_location()
{
/#
    level endon( "sq_tpo_item_hunt_done" );

    while ( true )
    {
        if ( getdvarint( _hash_5256118F ) > 0 )
            debugstar( self.origin, 20, ( 0, 1, 0 ) );

        wait 1;
    }
#/
}

promote_to_corpse_model( str_model )
{
    v_spawn_point = groundtrace( self.origin + vectorscale( ( 0, 0, 1 ), 10.0 ), self.origin + vectorscale( ( 0, 0, -1 ), 300.0 ), 0, undefined )["position"];
    self.corpse_model = spawn( "script_model", v_spawn_point );
    self.corpse_model.angles = self.angles;
    self.corpse_model setmodel( str_model );
    self.corpse_model.targetname = "sq_tpo_corpse_model";
    self _pose_corpse();
    self.corpse_model.unitrigger = setup_unitrigger( &"ZM_BURIED_SQ_SCH", ::unitrigger_think );
}

#using_animtree("zm_buried_props");

_pose_corpse()
{
    assert( isdefined( self.script_noteworthy ), "sq_tpo_corpse_spawn_location at " + self.origin + " is missing script_noteworthy! This is required to set deadpose" );

    switch ( self.script_noteworthy )
    {
        case "deadpose_1":
            anim_pose = %pb_gen_m_floor_armdown_onback_deathpose;
            break;
        case "deadpose_2":
            anim_pose = %pb_gen_m_floor_armdown_onfront_deathpose;
            break;
        case "deadpose_3":
            anim_pose = %pb_gen_m_floor_armover_onrightside_deathpose;
            break;
        case "deadpose_4":
            anim_pose = %pb_gen_m_floor_armrelaxed_onleftside_deathpose;
            break;
        case "deadpose_5":
            anim_pose = %pb_gen_m_floor_armspread_legaskew_onback_deathpose;
            break;
        case "deadpose_6":
            anim_pose = %pb_gen_m_floor_armspreadwide_legspread_onback_deathpose;
            break;
        case "deadpose_7":
            anim_pose = %pb_gen_m_floor_armstomach_onrightside_deathpose;
            break;
        case "deadpose_8":
            anim_pose = %pb_gen_m_floor_armstretched_onleftside_deathpose;
            break;
        case "deadpose_9":
            anim_pose = %pb_gen_m_wall_armcraddle_leanleft_deathpose;
            break;
        case "deadpose_10":
            anim_pose = %pb_gen_m_wall_legin_armcraddle_hunchright_deathpose;
            break;
        case "deadpose_11":
            anim_pose = %pb_gen_m_wall_legspread_armdown_leanleft_deathpose;
            break;
        case "deadpose_12":
            anim_pose = %pb_gen_m_floor_armsopen_onback_deathpose;
            break;
        case "deadpose_13":
            anim_pose = %pb_gen_m_floor_armstomach_onback_deathpose;
            break;
        default:
/#
            assertmsg( "sq_tpo_corpse_struct with script_noteworthy '" + self.script_noteworthy + "' is not supported by existing anim list!" );
#/
            break;
    }

    self.corpse_model useanimtree( #animtree );
    self.corpse_model setanim( anim_pose, 1, 0.05, 1 );
}

setup_unitrigger( str_hint, func_update )
{
    radius = 32;
    script_height = 32;
    script_width = 0;
    script_length = undefined;
    unitrigger_stub = spawnstruct();
    unitrigger_stub.origin = self.origin + vectorscale( ( 0, 0, 1 ), 10.0 );
    unitrigger_stub.script_length = 13.5;
    unitrigger_stub.script_width = script_width;
    unitrigger_stub.script_height = script_height;
    unitrigger_stub.radius = radius;
    unitrigger_stub.cursor_hint = "HINT_NOICON";
    unitrigger_stub.hint_string = str_hint;
    unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
    unitrigger_stub.require_look_at = 1;
    unitrigger_stub.prompt_and_visibility_func = ::piecetrigger_update_prompt;
    maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, func_update );
    return unitrigger_stub;
}

piecetrigger_update_prompt( player )
{
    can_use = self.stub piecestub_update_prompt( player );
    self setinvisibletoplayer( player, !can_use );
    self sethintstring( self.stub.hint_string );
    return can_use;
}

piecestub_update_prompt( player )
{
    return 1;
}

unitrigger_killed()
{
    self waittill( "kill_trigger" );

    self _delete_progress_bar();
}

unitrigger_think()
{
    self endon( "kill_trigger" );
    self thread unitrigger_killed();
    b_trigger_used = 0;

    while ( !b_trigger_used )
    {
        self waittill( "trigger", player );

        b_progress_bar_done = 0;
        n_frame_count = 0;

        while ( player usebuttonpressed() && !b_progress_bar_done )
        {
            if ( !isdefined( self.progress_bar ) )
            {
                self.progress_bar = player createprimaryprogressbar();
                self.progress_bar_text = player createprimaryprogressbartext();
                self.progress_bar_text settext( &"ZM_BURIED_SQ_SEARCHING" );
                self thread _kill_progress_bar();
            }

            n_progress_amount = n_frame_count / 30.0;
            self.progress_bar updatebar( n_progress_amount );
            n_frame_count++;

            if ( n_progress_amount == 1 )
                b_progress_bar_done = 1;

            wait 0.05;
        }

        self _delete_progress_bar();

        if ( b_progress_bar_done )
            b_trigger_used = 1;
    }

    if ( b_progress_bar_done )
    {
        self.stub.hint_string = "";
        self sethintstring( self.stub.hint_string );

        if ( item_is_on_corpse() )
        {
            iprintlnbold( &"ZM_BURIED_SQ_FND" );
            player give_player_sq_tpo_switch();
        }
        else
            iprintlnbold( &"ZM_BURIED_SQ_NFND" );

        self thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.stub );
    }
}

give_player_sq_tpo_switch()
{
    self player_take_piece( level.zombie_buildables["buried_sq_tpo_switch"].buildablepieces[0] );
    flag_set( "sq_tpo_found_item" );
    level.sq_tpo_unitrig.origin = level.sq_tpo_unitrig.realorigin;
}

item_is_on_corpse()
{
    if ( !isdefined( level.sq_tpo.times_searched ) )
        level.sq_tpo.times_searched = 0;

    switch ( level.sq_tpo.times_searched )
    {
        case 0:
            n_chance = 1;
            break;
        case 1:
            n_chance = 15;
            break;
        case 2:
            n_chance = 33;
            break;
        case 3:
            n_chance = 100;
            break;
    }

    b_found_item = randomint( 100 ) > 100 - n_chance && !flag( "sq_tpo_found_item" );
    level.sq_tpo.times_searched++;
    return b_found_item;
}

_delete_progress_bar()
{
    if ( isdefined( self.progress_bar ) )
    {
        self.progress_bar destroyelem();
        self.progress_bar_text destroyelem();
        self.progress_bar = undefined;
    }
}

_kill_progress_bar()
{
    self endon( "death" );
    self endon( "disconnect" );

    self waittill( "search_done" );

    self _delete_progress_bar();
}

setup_buildable_switch()
{
    s_switch_piece = generate_zombie_buildable_piece( "buried_sq_tpo_switch", "p6_zm_buildable_pswitch_lever_handed", 32, 64, 2.4, "zom_icon_trap_switch_handle", ::onpickup_switch, ::ondrop_switch, undefined, undefined, 0, 5, 2 );
    s_switch_piece.hint_grab = level.str_buildables_grab_part;
    s_switch_piece.hint_swap = level.str_buildables_swap_part;
    s_switch_piece manage_multiple_pieces( 1 );
    s_switch_piece.onspawn = ::onspawn_switch;
    s_switch = spawnstruct();
    s_switch.name = "buried_sq_tpo_switch";
    s_switch add_buildable_piece( s_switch_piece );
    s_switch.triggerthink = ::triggerthink_switch;
    s_switch.onuseplantobject = ::onuseplantobject_switch;
    include_buildable( s_switch );

    while ( !isdefined( level.sq_tpo_unitrig ) )
        wait 1;

    level.sq_tpo_unitrig.realorigin = level.sq_tpo_unitrig.origin;
    level.sq_tpo_unitrig.origin += vectorscale( ( 0, 0, -1 ), 10000.0 );
}

onuseplantobject_switch( player )
{
    flag_set( "sq_tpo_generator_powered" );
}

onpickup_switch( player )
{
    maps\mp\zm_buried_buildables::onpickup_common( player );
}

ondrop_switch( player )
{
    maps\mp\zm_buried_buildables::ondrop_common( player );
}

onspawn_switch( player )
{

}

triggerthink_switch()
{
    if ( isdefined( getent( "guillotine_trigger", "targetname" ) ) )
    {
        str_trigger_generator_name = "guillotine_trigger";
        level.sq_tpo_unitrig = maps\mp\zombies\_zm_buildables::buildable_trigger_think( str_trigger_generator_name, "buried_sq_tpo_switch", "none", "", 1, 0 );
        level.sq_tpo_unitrig.ignore_open_sesame = 1;
        level.sq_tpo_unitrig.buildablestub_reject_func = ::guillotine_trigger_reject_func;
    }
}

guillotine_trigger_reject_func( player )
{
    b_should_reject = 0;

    if ( flag( "sq_tpo_special_round_active" ) )
        b_should_reject = 1;

    return b_should_reject;
}

time_bomb_saves_wisp_state()
{
    if ( !isdefined( self.sq_data ) )
        self.sq_data = spawnstruct();

    self.sq_data.wisp_stage_complete = flag( "sq_wisp_success" );
}

time_bomb_restores_wisp_state()
{
    if ( isdefined( self.sq_data ) && isdefined( self.sq_data.wisp_stage_complete ) && !self.sq_data.wisp_stage_complete && flag( "sq_tpo_stage_started" ) )
    {
        flag_clear( "sq_wisp_success" );
        flag_clear( "sq_wisp_failed" );
        flag_set( "sq_wisp_saved_with_time_bomb" );
    }
}

sndsidequestnoirmusic()
{
    if ( is_true( level.music_override ) )
        return;

    level.music_override = 1;
    level setclientfield( "mus_noir_snapshot_loop", 1 );
    ent = spawn( "script_origin", ( 0, 0, 0 ) );
    ent playloopsound( "mus_sidequest_noir" );

    level waittill( "sndEndNoirMusic" );

    level setclientfield( "mus_noir_snapshot_loop", 0 );
    level.music_override = 0;
    ent stoploopsound( 2 );
    wait 2;
    ent delete();
}
