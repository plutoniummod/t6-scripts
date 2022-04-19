// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_highrise_sq;

init()
{
    flag_init( "sq_atd_elevator0" );
    flag_init( "sq_atd_elevator1" );
    flag_init( "sq_atd_elevator2" );
    flag_init( "sq_atd_elevator3" );
    flag_init( "sq_atd_elevator_activated" );
    flag_init( "sq_atd_drg_puzzle_1st_error" );
    flag_init( "sq_atd_drg_puzzle_complete" );
    declare_sidequest_stage( "sq", "atd", ::init_stage, ::stage_logic, ::exit_stage_1 );
    sq_atd_dragon_icon_setup();
}

init_stage()
{
    level._cur_stage_name = "atd";
    clientnotify( "atd" );
}

stage_logic()
{
/#
    iprintlnbold( "ATD Started" );
#/
    sq_atd_elevators();
    sq_atd_drg_puzzle();
    stage_completed( "sq", level._cur_stage_name );
}

exit_stage_1( success )
{

}

sq_atd_dragon_icon_setup()
{
    a_dragon_icons = getentarray( "elevator_dragon_icon", "targetname" );

    foreach ( m_icon in a_dragon_icons )
    {
        m_icon notsolid();
        m_icon.m_elevator = getent( "elevator_" + m_icon.script_noteworthy + "_body", "targetname" );
        m_icon.origin = m_icon.m_elevator.origin + vectorscale( ( 0, 0, 1 ), 134.0 );
        m_icon.angles = m_icon.m_elevator.angles;
        m_icon linkto( m_icon.m_elevator );
        m_icon.m_lit_icon = getent( m_icon.script_noteworthy + "_elevator_lit", "script_noteworthy" );

        if ( isdefined( m_icon.m_lit_icon ) )
        {
            m_icon.m_lit_icon notsolid();
            m_icon.m_lit_icon.origin = m_icon.origin - vectorscale( ( 0, 0, 1 ), 2.0 );
            m_icon.m_lit_icon.angles = m_icon.angles;
            m_icon.m_lit_icon linkto( m_icon.m_elevator );
        }
    }

    a_atd2_icons = getentarray( "atd2_marker_unlit", "script_noteworthy" );
    a_atd2_lit_icons = getentarray( "atd2_marker_lit", "targetname" );

    for ( i = 0; i < a_atd2_icons.size; i++ )
    {
        a_atd2_lit_icons[i].origin = a_atd2_icons[i].origin - vectorscale( ( 0, 0, 1 ), 5.0 );
        a_atd2_lit_icons[i].angles = a_atd2_icons[i].angles;
        a_atd2_icons[i].lit_icon = a_atd2_lit_icons[i];
    }
}

sq_atd_elevators()
{
    a_elevators = array( "elevator_bldg1b_trigger", "elevator_bldg1d_trigger", "elevator_bldg3b_trigger", "elevator_bldg3c_trigger" );
    a_elevator_flags = array( "sq_atd_elevator0", "sq_atd_elevator1", "sq_atd_elevator2", "sq_atd_elevator3" );

    for ( i = 0; i < a_elevators.size; i++ )
    {
        trig_elevator = getent( a_elevators[i], "targetname" );
        trig_elevator thread sq_atd_watch_elevator( a_elevator_flags[i] );
    }

    while ( !flag( "sq_atd_elevator0" ) || !flag( "sq_atd_elevator1" ) || !flag( "sq_atd_elevator2" ) || !flag( "sq_atd_elevator3" ) )
    {
        flag_wait_any_array( a_elevator_flags );
        wait 0.5;
    }
/#
    iprintlnbold( "Standing on Elevators Complete" );
#/
    a_dragon_icons = getentarray( "elevator_dragon_icon", "targetname" );

    foreach ( m_icon in a_dragon_icons )
    {
        v_off_pos = m_icon.m_lit_icon.origin;
        m_icon.m_lit_icon unlink();
        m_icon unlink();
        m_icon.m_lit_icon.origin = m_icon.origin;
        m_icon.origin = v_off_pos;
        m_icon.m_lit_icon linkto( m_icon.m_elevator );
        m_icon linkto( m_icon.m_elevator );
        m_icon playsound( "zmb_sq_symbol_light" );
    }

    flag_set( "sq_atd_elevator_activated" );
    vo_richtofen_atd_elevators();
    level thread vo_maxis_atd_elevators();
}

sq_atd_watch_elevator( str_flag )
{
    level endon( "sq_atd_elevator_activated" );

    while ( true )
    {
        self waittill( "trigger", e_who );

        if ( !isplayer( e_who ) )
        {
            wait 0.05;
            continue;
        }

        flag_set( str_flag );

        while ( isalive( e_who ) && e_who istouching( self ) )
            wait 0.05;

        flag_clear( str_flag );
    }
}

sq_atd_drg_puzzle()
{
    level.sq_atd_cur_drg = 0;
    a_puzzle_trigs = getentarray( "trig_atd_drg_puzzle", "targetname" );
    a_puzzle_trigs = array_randomize( a_puzzle_trigs );

    for ( i = 0; i < a_puzzle_trigs.size; i++ )
        a_puzzle_trigs[i] thread drg_puzzle_trig_think( i );

    while ( level.sq_atd_cur_drg < 4 )
        wait 1;

    flag_set( "sq_atd_drg_puzzle_complete" );
    level thread vo_maxis_atd_order_complete();
/#
    iprintlnbold( "Dragon Puzzle COMPLETE" );
#/
}

drg_puzzle_trig_think( n_order_id )
{
    self.drg_active = 0;
    m_unlit = getent( self.target, "targetname" );
    m_lit = m_unlit.lit_icon;
    v_top = m_unlit.origin;
    v_hidden = m_lit.origin;

    while ( !flag( "sq_atd_drg_puzzle_complete" ) )
    {
        if ( self.drg_active )
        {
            level waittill_either( "sq_atd_drg_puzzle_complete", "drg_puzzle_reset" );

            if ( flag( "sq_atd_drg_puzzle_complete" ) )
                continue;
        }

        self waittill( "trigger", e_who );

        if ( level.sq_atd_cur_drg == n_order_id )
        {
            m_lit.origin = v_top;
            m_unlit.origin = v_hidden;
            m_lit playsound( "zmb_sq_symbol_light" );
            self.drg_active = 1;
            level thread vo_richtofen_atd_order( level.sq_atd_cur_drg );
            level.sq_atd_cur_drg++;
/#
            iprintlnbold( "Dragon " + n_order_id + " Correct" );
#/
            self thread drg_puzzle_trig_watch_fade( m_lit, m_unlit, v_top, v_hidden );
        }
        else
        {
            if ( !flag( "sq_atd_drg_puzzle_1st_error" ) )
                level thread vo_maxis_atd_order_error();

            level.sq_atd_cur_drg = 0;
            level notify( "drg_puzzle_reset" );
/#
            iprintlnbold( "INCORRECT DRAGON" );
#/
            wait 0.5;
        }

        while ( e_who istouching( self ) )
            wait 0.5;
    }
}

drg_puzzle_trig_watch_fade( m_lit, m_unlit, v_top, v_hidden )
{
    level endon( "sq_atd_drg_puzzle_complete" );

    level waittill( "drg_puzzle_reset" );

    m_unlit.origin = v_top;
    m_lit.origin = v_hidden;
    m_unlit playsound( "zmb_sq_symbol_fade" );
    self.drg_active = 0;
}

vo_richtofen_atd_elevators()
{
    maps\mp\zm_highrise_sq::richtofensay( "vox_zmba_sidequest_activ_dragons_0" );
}

vo_maxis_atd_elevators()
{
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_activ_dragons_0" );
}

vo_richtofen_atd_order( n_which )
{
    str_vox = "vox_zmba_sidequest_sec_symbols_" + n_which;
    maps\mp\zm_highrise_sq::richtofensay( str_vox );
}

vo_richtofen_atd_order_error()
{
    maps\mp\zm_highrise_sq::richtofensay( "vox_zmba_sidequest_sec_symbols_5" );
}

vo_maxis_atd_order_error()
{
    flag_set( "sq_atd_drg_puzzle_1st_error" );
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_sec_symbols_0" );
}

vo_maxis_atd_order_complete()
{
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_sec_symbols_1" );
}
