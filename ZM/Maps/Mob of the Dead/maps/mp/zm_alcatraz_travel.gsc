// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\_zombiemode_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_audio;

#using_animtree("fxanim_props");

init_alcatraz_zipline()
{
    level thread gondola_hostmigration();
    level.player_intersection_tracker_override = ::zombie_alcatraz_player_intersection_tracker_override;
    level.gondola_kill_brush_override = 0;
    flag_init( "gondola_at_roof" );
    flag_init( "gondola_at_docks" );
    flag_init( "gondola_in_motion" );
    flag_init( "gondola_initialized" );
    e_gondola = getent( "zipline_gondola", "targetname" );
    level.e_gondola = e_gondola;
    e_gondola.location = "roof";
    e_gondola.destination = undefined;
    e_gondola setmovingplatformenabled( 1 );
    playfxontag( level._effect["light_gondola"], e_gondola, "tag_origin" );
    flag_set( "gondola_at_roof" );
    level.e_gondola.t_ride = getent( "gondola_ride_trigger", "targetname" );
    level.e_gondola.t_ride enablelinkto();
    level.e_gondola.t_ride linkto( e_gondola );
    t_move_triggers = getentarray( "gondola_move_trigger", "targetname" );
    t_call_triggers = getentarray( "gondola_call_trigger", "targetname" );
    a_t_gondola_triggers = arraycombine( t_move_triggers, t_call_triggers, 1, 0 );

    foreach ( trigger in a_t_gondola_triggers )
        trigger hint_string( &"ZM_PRISON_GONDOLA_REQUIRES_POWER" );

    a_gondola_doors = getentarray( "gondola_doors", "targetname" );

    foreach ( m_door in a_gondola_doors )
    {
        m_door linkto( e_gondola );
        e_gondola establish_gondola_door_definition( m_door );
        m_door setmovingplatformenabled( 1 );
    }

    a_gondola_gates = getentarray( "gondola_gates", "targetname" );

    foreach ( m_gate in a_gondola_gates )
    {
        m_gate linkto( e_gondola );
        e_gondola establish_gondola_gate_definition( m_gate );
        m_gate setmovingplatformenabled( 1 );
    }

    a_gondola_landing_doors = getentarray( "gondola_landing_doors", "targetname" );

    foreach ( m_door in a_gondola_landing_doors )
        e_gondola establish_gondola_landing_door_definition( m_door );

    a_gondola_landing_gates = getentarray( "gondola_landing_gates", "targetname" );

    foreach ( m_gate in a_gondola_landing_gates )
        e_gondola establish_gondola_landing_gate_definition( m_gate );

    m_chains = spawn( "script_model", level.e_gondola.origin );
    m_chains.origin = level.e_gondola.origin;
    m_chains.angles = level.e_gondola.angles;
    m_chains setmodel( "fxanim_zom_al_gondola_chains_mod" );
    m_chains linkto( level.e_gondola );
    level.e_gondola.fxanim_chains = m_chains;
    level.gondola_chains_fxanims = [];
    level.gondola_chains_fxanims["gondola_chains_start"] = %fxanim_zom_al_gondola_chains_start_anim;
    level.gondola_chains_fxanims["gondola_chains_idle"] = %fxanim_zom_al_gondola_chains_idle_anim;
    level.gondola_chains_fxanims["gondola_chains_end"] = %fxanim_zom_al_gondola_chains_end_anim;
    gondola_lights_red();
/#
    level thread debug_power_gondola_on();
#/
    str_notify = level waittill_any_array_return( array( "gondola_powered_on_roof", "gondola_powered_on_docks" ) );

    if ( str_notify == "gondola_powered_on_roof" )
    {
        level thread turn_off_opposite_side_gondola_shockbox( "gondola_powered_on_docks" );
        e_gondola gondola_doors_move( "roof", 1 );
    }
    else if ( str_notify == "gondola_powered_on_docks" )
    {
        level thread turn_off_opposite_side_gondola_shockbox( "gondola_powered_on_roof" );
        move_gondola( 1 );
    }

    flag_set( "gondola_initialized" );
    gondola_lights_green();
    array_thread( t_move_triggers, ::zipline_move_trigger_think );
    array_thread( t_call_triggers, ::zipline_call_trigger_think );
}

turn_off_opposite_side_gondola_shockbox( str_notify_opposite )
{
    a_e_afterlife_interacts = getentarray( "afterlife_interact", "targetname" );

    foreach ( shockbox in a_e_afterlife_interacts )
    {
        if ( isdefined( shockbox.script_string ) )
        {
            if ( shockbox.script_string == str_notify_opposite )
                shockbox notify( "damage", 1, level );
        }
    }
}

debug_power_gondola_on()
{
/#
    level waittill( "open_sesame" );

    level notify( "gondola_powered_on_roof" );
#/
}

establish_gondola_door_definition( m_door )
{
    str_identifier = m_door.script_noteworthy;

    switch ( str_identifier )
    {
        case "roof left":
            self.door_roof_left = m_door;
            break;
        case "roof right":
            self.door_roof_right = m_door;
            break;
        case "docks left":
            self.door_docks_left = m_door;
            break;
        case "docks right":
            self.door_docks_right = m_door;
            break;
    }
}

establish_gondola_gate_definition( m_gate )
{
    str_identifier = m_gate.script_noteworthy;

    switch ( str_identifier )
    {
        case "roof left":
            self.gate_roof_left = m_gate;
            break;
        case "roof right":
            self.gate_roof_right = m_gate;
            break;
        case "docks left":
            self.gate_docks_left = m_gate;
            break;
        case "docks right":
            self.gate_docks_right = m_gate;
            break;
    }
}

establish_gondola_landing_door_definition( m_door )
{
    str_identifier = m_door.script_noteworthy;

    switch ( str_identifier )
    {
        case "roof left":
            self.landing_door_roof_left = m_door;
            break;
        case "roof right":
            self.landing_door_roof_right = m_door;
            break;
        case "docks left":
            self.landing_door_docks_left = m_door;
            break;
        case "docks right":
            self.landing_door_docks_right = m_door;
            break;
    }
}

establish_gondola_landing_gate_definition( m_gate )
{
    str_identifier = m_gate.script_noteworthy;

    switch ( str_identifier )
    {
        case "roof left":
            self.landing_gate_roof_left = m_gate;
            break;
        case "roof right":
            self.landing_gate_roof_right = m_gate;
            break;
        case "docks left":
            self.landing_gate_docks_left = m_gate;
            break;
        case "docks right":
            self.landing_gate_docks_right = m_gate;
            break;
    }
}

zipline_move_trigger_think()
{
    level endon( "interrupt_gondola_move_trigger_" + self.script_string );
    self.cost = 750;
    self.in_use = 0;
    self.is_available = 1;
    self hint_string( "" );

    while ( true )
    {
        flag_wait( "gondola_at_" + self.script_string );
        self hint_string( &"ZM_PRISON_MOVE_GONDOLA", self.cost );

        self waittill( "trigger", who );

        if ( who in_revive_trigger() )
            continue;

        if ( !isdefined( self.is_available ) )
            continue;

        if ( is_player_valid( who ) )
        {
            if ( who.score >= self.cost )
            {
                if ( !self.in_use )
                {
                    self.in_use = 1;
                    self.is_available = undefined;
                    play_sound_at_pos( "purchase", who.origin );
                    who minus_to_player_score( self.cost );

                    if ( self.script_string == "roof" )
                    {
                        level notify( "interrupt_gondola_call_trigger_docks" );
                        str_loc = "docks";
                    }
                    else if ( self.script_string == "docks" )
                    {
                        level notify( "interrupt_gondola_call_trigger_roof" );
                        str_loc = "roof";
                    }

                    a_t_trig = getentarray( "gondola_call_trigger", "targetname" );

                    foreach ( trigger in a_t_trig )
                    {
                        if ( trigger.script_string == str_loc )
                        {
                            t_opposite_call_trigger = trigger;
                            break;
                        }
                    }

                    move_gondola();
                    t_opposite_call_trigger thread zipline_call_trigger_think();
                    t_opposite_call_trigger playsound( "zmb_trap_available" );
                    self.in_use = 0;
                    self.is_available = 1;
                }
            }
        }
    }
}

zipline_call_trigger_think()
{
    level endon( "interrupt_gondola_call_trigger_" + self.script_string );
    self.cost = 0;
    self.in_use = 0;
    self.is_available = 1;
    e_gondola = level.e_gondola;

    if ( self.script_string == "roof" )
        str_gondola_loc = "docks";
    else if ( self.script_string == "docks" )
        str_gondola_loc = "roof";

    while ( true )
    {
        self sethintstring( "" );
        flag_wait( "gondola_at_" + str_gondola_loc );
        self notify( "available" );
        self hint_string( &"ZM_PRISON_CALL_GONDOLA" );

        self waittill( "trigger", who );

        if ( who in_revive_trigger() )
            continue;

        if ( !isdefined( self.is_available ) )
            continue;

        if ( is_player_valid( who ) )
        {
            if ( !self.in_use )
            {
                self.in_use = 1;

                if ( self.script_string == "roof" )
                {
                    level notify( "interrupt_gondola_move_trigger_docks" );
                    str_loc = "docks";
                }
                else if ( self.script_string == "docks" )
                {
                    level notify( "interrupt_gondola_move_trigger_roof" );
                    str_loc = "roof";
                }

                a_t_trig = getentarray( "gondola_move_trigger", "targetname" );

                foreach ( trigger in a_t_trig )
                {
                    if ( trigger.script_string == str_loc )
                    {
                        t_opposite_move_trigger = trigger;
                        break;
                    }
                }

                self playsound( "zmb_trap_activate" );
                move_gondola();
                t_opposite_move_trigger thread zipline_move_trigger_think();
                self.in_use = 0;
                self playsound( "zmb_trap_available" );
                self.is_available = 1;
            }
        }
    }
}

move_gondola( b_suppress_doors_close = 0 )
{
    level clientnotify( "sndGS" );
    gondola_lights_red();
    e_gondola = level.e_gondola;
    t_ride = level.e_gondola.t_ride;
    e_gondola.is_moving = 1;

    if ( e_gondola.location == "roof" )
    {
        s_moveloc = getstruct( "gondola_struct_docks", "targetname" );
        e_gondola.destination = "docks";
        level thread gondola_outofbounds_trigger_stop();
    }
    else if ( e_gondola.location == "docks" )
    {
        s_moveloc = getstruct( "gondola_struct_roof", "targetname" );
        e_gondola.destination = "roof";
        level thread gondola_outofbounds_trigger_enabled();
    }

    if ( flag( "gondola_initialized" ) )
    {
        flag_set( "gondola_roof_to_dock" );
        flag_set( "gondola_dock_to_roof" );
        flag_set( "gondola_ride_zone_enabled" );
    }

    flag_clear( "gondola_at_" + e_gondola.location );

    if ( !( isdefined( b_suppress_doors_close ) && b_suppress_doors_close ) )
        e_gondola gondola_doors_move( e_gondola.location, -1 );

    level notify( "gondola_moving" );
    a_t_move = getentarray( "gondola_move_trigger", "targetname" );

    foreach ( trigger in a_t_move )
        trigger sethintstring( "" );

    a_t_call = getentarray( "gondola_call_trigger", "targetname" );

    foreach ( trigger in a_t_call )
        trigger sethintstring( &"ZM_PRISON_GONDOLA_ACTIVE" );

    check_when_gondola_moves_if_groundent_is_undefined( e_gondola );
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( player is_player_on_gondola() )
        {
            player setclientfieldtoplayer( "rumble_gondola", 1 );
            player thread check_for_death_on_gondola( e_gondola );
            player.is_on_gondola = 1;
            level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "gondola", player );
        }

        if ( isdefined( player.e_afterlife_corpse ) && player.e_afterlife_corpse istouching( t_ride ) )
            player.e_afterlife_corpse thread link_corpses_to_gondola( e_gondola );
    }

    e_gondola thread create_gondola_poi();
    level thread gondola_moving_vo();
    e_gondola thread gondola_physics_explosion( 10 );
    e_gondola moveto( s_moveloc.origin, 10, 1, 1 );
    flag_set( "gondola_in_motion" );
    e_gondola thread gondola_chain_fx_anim();
    e_gondola playsound( "zmb_gondola_start" );
    e_gondola playloopsound( "zmb_gondola_loop", 1 );

    e_gondola waittill( "movedone" );

    flag_clear( "gondola_in_motion" );
    e_gondola stoploopsound( 0.5 );
    e_gondola thread sndcooldown();
    e_gondola playsound( "zmb_gondola_stop" );
    player_escaped_gondola_failsafe();
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( isdefined( player.is_on_gondola ) && player.is_on_gondola )
        {
            player setclientfieldtoplayer( "rumble_gondola", 0 );
            player.is_on_gondola = 0;
        }
    }

    e_gondola gondola_doors_move( e_gondola.destination, 1 );
    e_gondola.is_moving = 0;
    e_gondola thread tear_down_gondola_poi();
    wait 1.0;
    level clientnotify( "sndGE" );

    if ( e_gondola.location == "roof" )
    {
        e_gondola.location = "docks";
        str_zone = "zone_dock_gondola";
    }
    else if ( e_gondola.location == "docks" )
    {
        e_gondola.location = "roof";
        str_zone = "zone_cellblock_west_gondola_dock";
    }

    level notify( "gondola_arrived", str_zone );
    gondola_cooldown();
    flag_set( "gondola_at_" + e_gondola.location );
}

sndcooldown()
{
    self playsound( "zmb_gond_pwr_dn" );
    self playloopsound( "zmb_gondola_cooldown_lp", 1 );
    wait 10;
    wait 3.5;
    self stoploopsound( 0.5 );
    self playsound( "zmb_gond_pwr_on" );
}

gondola_doors_move( str_side, n_state )
{
    if ( str_side == "roof" )
    {
        m_door_left = self.door_roof_left;
        m_gate_left = self.gate_roof_left;
        m_door_right = self.door_roof_right;
        m_gate_right = self.gate_roof_right;
        m_landing_door_left = self.landing_door_roof_left;
        m_landing_gate_left = self.landing_gate_roof_left;
        m_landing_door_right = self.landing_door_roof_right;
        m_landing_gate_right = self.landing_gate_roof_right;
        n_side_modifier = 1;
    }
    else if ( str_side == "docks" )
    {
        m_door_left = self.door_docks_left;
        m_gate_left = self.gate_docks_left;
        m_door_right = self.door_docks_right;
        m_gate_right = self.gate_docks_right;
        m_landing_door_left = self.landing_door_docks_left;
        m_landing_gate_left = self.landing_gate_docks_left;
        m_landing_door_right = self.landing_door_docks_right;
        m_landing_gate_right = self.landing_gate_docks_right;
        n_side_modifier = -1;
    }

    a_doors_and_gates = [];
    a_doors_and_gates[0] = m_door_left;
    a_doors_and_gates[1] = m_gate_left;
    a_doors_and_gates[2] = m_door_right;
    a_doors_and_gates[3] = m_gate_right;

    foreach ( m_model in a_doors_and_gates )
        m_model unlink();

    m_door_left playsound( "zmb_gondola_door" );

    if ( n_state == 1 )
    {
        gondola_gate_moves( n_state, n_side_modifier, m_gate_left, m_gate_right, m_landing_gate_left, m_landing_gate_right );
        gondola_gate_and_door_moves( n_state, n_side_modifier, m_gate_left, m_door_left, m_gate_right, m_door_right, m_landing_gate_left, m_landing_door_left, m_landing_gate_right, m_landing_door_right );

        if ( n_side_modifier == 1 )
        {
            top_node_r = getnode( "nd_gond_top_r", "targetname" );
            top_node_r node_add_connection( getnode( "nd_on_top_r", "targetname" ) );
        }
        else
        {
            bottom_node_r = getnode( "nd_gond_bottom_r", "targetname" );
            bottom_node_r node_add_connection( getnode( "nd_on_bottom_r", "targetname" ) );
        }
    }
    else
    {
        if ( n_side_modifier == 1 )
        {
            top_node_r = getnode( "nd_gond_top_r", "targetname" );
            top_node_r node_disconnect_from_path();
        }
        else
        {
            bottom_node_r = getnode( "nd_gond_bottom_r", "targetname" );
            bottom_node_r node_disconnect_from_path();
        }

        gondola_gate_and_door_moves( n_state, n_side_modifier, m_gate_left, m_door_left, m_gate_right, m_door_right, m_landing_gate_left, m_landing_door_left, m_landing_gate_right, m_landing_door_right );
        gondola_gate_moves( n_state, n_side_modifier, m_gate_left, m_gate_right, m_landing_gate_left, m_landing_gate_right );
    }

    foreach ( m_model in a_doors_and_gates )
        m_model linkto( self );
}

gondola_gate_moves( n_state, n_side_modifier, m_gate_left, m_gate_right, m_landing_gate_left, m_landing_gate_right )
{
    m_gate_left moveto( m_gate_left.origin + ( 22.5 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
    m_gate_right moveto( m_gate_right.origin + ( 22.5 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );
    m_landing_gate_left moveto( m_landing_gate_left.origin + ( 22.5 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
    m_landing_gate_right moveto( m_landing_gate_right.origin + ( 22.5 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );

    m_gate_right waittill( "movedone" );
}

gondola_gate_and_door_moves( n_state, n_side_modifier, m_gate_left, m_door_left, m_gate_right, m_door_right, m_landing_gate_left, m_landing_door_left, m_landing_gate_right, m_landing_door_right )
{
    m_door_left moveto( m_door_left.origin + ( 24 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
    m_gate_left moveto( m_gate_left.origin + ( 24 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
    m_door_right moveto( m_door_right.origin + ( 24 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );
    m_gate_right moveto( m_gate_right.origin + ( 24 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );
    m_landing_door_left moveto( m_landing_door_left.origin + ( 24 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
    m_landing_gate_left moveto( m_landing_gate_left.origin + ( 24 * n_side_modifier * n_state, 0, 0 ), 0.5, 0.05, 0.05 );
    m_landing_door_right moveto( m_landing_door_right.origin + ( 24 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );
    m_landing_gate_right moveto( m_landing_gate_right.origin + ( 24 * n_side_modifier * n_state * -1, 0, 0 ), 0.5, 0.05, 0.05 );

    m_gate_right waittill( "movedone" );
}

check_for_death_on_gondola( e_gondola )
{
    self endon( "disconnect" );
    self endon( "afterlife_bleedout" );
    e_gondola endon( "movedone" );

    self waittill( "player_fake_corpse_created" );

    self.e_afterlife_corpse endon( "player_revived" );
    self.e_afterlife_corpse linkto( e_gondola );
}

link_corpses_to_gondola( e_gondola )
{
    e_gondola endon( "movedone" );

    if ( isdefined( self ) )
        self linkto( e_gondola );
}

create_gondola_poi()
{
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( !( isdefined( player.is_on_gondola ) && player.is_on_gondola ) )
            return;
    }

    s_poi = getstruct( "gondola_poi_" + self.destination, "targetname" );
    e_poi = spawn( "script_origin", s_poi.origin );
    e_poi create_zombie_point_of_interest( 10000, 30, 5000, 1 );
    e_poi thread create_zombie_point_of_interest_attractor_positions();
    self.poi = e_poi;
}

tear_down_gondola_poi()
{
    if ( isdefined( self.poi ) )
    {
        remove_poi_attractor( self.poi );
        self.poi delete();
    }
}

gondola_chain_fx_anim()
{
    m_chains = self.fxanim_chains;
    m_chains useanimtree( #animtree );
    n_start_time = getanimlength( level.gondola_chains_fxanims["gondola_chains_start"] );
    n_idle_time = getanimlength( level.gondola_chains_fxanims["gondola_chains_idle"] );
    m_chains setanim( level.gondola_chains_fxanims["gondola_chains_start"], 1, 0.1, 1 );
    wait( n_start_time );
    m_chains setanim( level.gondola_chains_fxanims["gondola_chains_idle"], 1, 0.1, 1 );

    while ( flag( "gondola_in_motion" ) )
        wait( n_idle_time );

    m_chains setanim( level.gondola_chains_fxanims["gondola_chains_end"], 1, 0.1, 1 );
}

gondola_physics_explosion( n_move_time )
{
    self endon( "movedone" );

    for ( i = 0; i < 2; i++ )
    {
        physicsexplosionsphere( self.origin, 1000, 0.1, 0.1 );
        wait( n_move_time / 2 );
    }
}

gondola_cooldown()
{
    a_t_call = getentarray( "gondola_call_trigger", "targetname" );

    foreach ( trigger in a_t_call )
        trigger sethintstring( &"ZM_PRISON_GONDOLA_COOLDOWN" );

    a_t_move = getentarray( "gondola_move_trigger", "targetname" );

    foreach ( trigger in a_t_move )
        trigger sethintstring( &"ZM_PRISON_GONDOLA_COOLDOWN" );

    wait 10;
    gondola_lights_green();
}

gondola_moving_vo()
{
    if ( isdefined( level.custom_gondola_moving_vo_func ) )
    {
        self thread [[ level.custom_gondola_moving_vo_func ]]();
        return;
    }

    a_players = array_players_on_gondola();

    if ( a_players.size > 0 )
    {
        a_players = array_randomize( a_players );
        a_players[0] thread do_player_general_vox( "general", "use_gondola" );
    }
}

hint_string( string, cost )
{
    if ( isdefined( cost ) )
        self sethintstring( string, cost );
    else
        self sethintstring( string );

    self setcursorhint( "HINT_NOICON" );
}

gondola_lights_red()
{
    a_m_gondola_lights = getentarray( "gondola_state_light", "targetname" );

    foreach ( model in a_m_gondola_lights )
    {
        model setmodel( "p6_zm_al_gondola_frame_light_red" );
        wait_network_frame();
    }
}

gondola_lights_green()
{
    a_m_gondola_lights = getentarray( "gondola_state_light", "targetname" );

    foreach ( model in a_m_gondola_lights )
    {
        model setmodel( "p6_zm_al_gondola_frame_light_green" );
        wait_network_frame();
    }
}

is_player_on_gondola()
{
    if ( isplayer( self ) )
    {
        if ( self istouching( level.e_gondola.t_ride ) )
            return true;
        else
            return false;
    }
}

array_players_on_gondola()
{
    a_players_on_gondola = [];
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( player is_player_on_gondola() )
            a_players_on_gondola[a_players_on_gondola.size] = player;
    }

    return a_players_on_gondola;
}

init_gondola_chains_animtree()
{
    scriptmodelsuseanimtree( #animtree );
}

gondola_hostmigration()
{
    level endon( "end_game" );
    level notify( "gondola_hostmigration" );
    level endon( "gondola_hostmigration" );

    while ( true )
    {
        level waittill( "host_migration_begin" );

        level.hm_link_origins = [];
        a_players = getplayers();

        foreach ( player in a_players )
            player thread link_player_to_gondola();

        level waittill( "host_migration_end" );

        a_players = getplayers();

        foreach ( player in a_players )
            player unlink();

        foreach ( e_origin in level.hm_link_origins )
            e_origin delete();

        if ( !( isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving ) )
        {
            if ( level.e_gondola.location == "roof" )
            {
                top_node_r = getnode( "nd_gond_top_r", "targetname" );
                top_node_r node_add_connection( getnode( "nd_on_top_r", "targetname" ) );
            }
            else
            {
                bottom_node_r = getnode( "nd_gond_bottom_r", "targetname" );
                bottom_node_r node_add_connection( getnode( "nd_on_bottom_r", "targetname" ) );
            }
        }
    }
}

link_player_to_gondola()
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( !isdefined( self ) )
        return;

    if ( self is_player_on_gondola() )
    {
        e_origin = spawn( "script_origin", self.origin );
        e_origin.angles = self.angles;
        level.hm_link_origins[level.hm_link_origins.size] = e_origin;
        e_origin linkto( level.e_gondola );
        self playerlinkto( e_origin );
    }
}

node_add_connection( nd_node )
{
    if ( !nodesarelinked( self, nd_node ) )
    {
        if ( !isdefined( self.a_node_path_connections ) )
            self.a_node_path_connections = [];

        link_nodes( self, nd_node );
        link_nodes( nd_node, self );
        self.a_node_path_connections[self.a_node_path_connections.size] = nd_node;
    }
}

node_disconnect_from_path()
{
    if ( isdefined( self.a_node_path_connections ) )
    {
        for ( i = 0; i < self.a_node_path_connections.size; i++ )
        {
            nd_node = self.a_node_path_connections[i];
            unlink_nodes( self, nd_node );
            unlink_nodes( nd_node, self );
        }
    }

    self.a_node_path_connections = undefined;
}

check_when_gondola_moves_if_groundent_is_undefined( e_gondola )
{
    wait 1.0;
    a_zombies = getaiarray( level.zombie_team );
    a_zombies = get_array_of_closest( e_gondola.origin, a_zombies );

    for ( i = 0; i < a_zombies.size; i++ )
    {
        if ( distancesquared( e_gondola.origin, a_zombies[i].origin ) < 90000 )
        {
            ground_ent = a_zombies[i] getgroundent();

            if ( !isdefined( ground_ent ) )
                a_zombies[i] dodamage( a_zombies[i].health + 1000, a_zombies[i].origin );
        }
    }
}

get_gondola_doors_and_gates()
{
    if ( isdefined( level.e_gondola ) )
    {
        a_doors_gates = [];
        a_doors_gates[0] = level.e_gondola.door_roof_left;
        a_doors_gates[1] = level.e_gondola.door_roof_right;
        a_doors_gates[2] = level.e_gondola.door_docks_left;
        a_doors_gates[3] = level.e_gondola.door_docks_right;
        a_doors_gates[4] = level.e_gondola.gate_roof_left;
        a_doors_gates[5] = level.e_gondola.gate_roof_right;
        a_doors_gates[6] = level.e_gondola.gate_docks_left;
        a_doors_gates[7] = level.e_gondola.gate_docks_right;
        a_doors_gates[8] = level.e_gondola.landing_door_roof_left;
        a_doors_gates[9] = level.e_gondola.landing_door_roof_right;
        a_doors_gates[10] = level.e_gondola.landing_door_docks_left;
        a_doors_gates[11] = level.e_gondola.landing_door_docks_right;
        a_doors_gates[12] = level.e_gondola.landing_gate_roof_left;
        a_doors_gates[13] = level.e_gondola.landing_gate_roof_right;
        a_doors_gates[14] = level.e_gondola.landing_gate_docks_left;
        a_doors_gates[15] = level.e_gondola.landing_gate_docks_right;
        return a_doors_gates;
    }
}

zombie_alcatraz_player_intersection_tracker_override( other_player )
{
    if ( isdefined( self.afterlife_revived ) && self.afterlife_revived || isdefined( other_player.afterlife_revived ) && other_player.afterlife_revived )
        return true;

    if ( isdefined( self.is_on_gondola ) && self.is_on_gondola && ( isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving ) )
        return true;

    if ( isdefined( other_player.is_on_gondola ) && other_player.is_on_gondola && ( isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving ) )
        return true;

    return false;
}

player_escaped_gondola_failsafe()
{
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( isdefined( player.is_on_gondola ) && player.is_on_gondola )
        {
            if ( !player is_player_on_gondola() )
            {
                if ( !( isdefined( player.afterlife ) && player.afterlife ) && isalive( player ) )
                {
                    a_s_orgs = getstructarray( "gondola_dropped_parts_" + level.e_gondola.destination, "targetname" );

                    foreach ( struct in a_s_orgs )
                    {
                        if ( !positionwouldtelefrag( struct.origin ) )
                        {
                            player setorigin( struct.origin );
                            break;
                        }
                    }
                }
            }
        }
    }
}

gondola_outofbounds_trigger_stop()
{
    wait 5.0;
    level.gondola_kill_brush_override = 1;
}

gondola_outofbounds_trigger_enabled()
{
    wait 5.0;
    level.gondola_kill_brush_override = 0;
}
