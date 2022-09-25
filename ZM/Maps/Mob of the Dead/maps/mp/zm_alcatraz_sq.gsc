// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\mp\zombies\_zm_afterlife;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_craftables;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_alcatraz_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud;
#include maps\mp\zm_prison_sq_final;
#include maps\mp\zm_alcatraz_sq_vo;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zm_alcatraz_sq_nixie;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_ai_brutus;
#include maps\mp\animscripts\shared;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_clone;

init()
{
    precachemodel( "accessories_gas_canister_1" );
    precachemodel( "p6_zm_al_power_station_panels_03" );
    precacheitem( "falling_hands_zm" );
    precacheitem( "electrocuted_hands_zm" );
    precachestring( &"ZM_PRISON_ELECTRIC_CHAIR_ACTIVATE" );
    precachestring( &"ZM_PRISON_LAUNDRY_MACHINE_ACTIVATE" );
    precachestring( &"ZM_PRISON_PLANE_BEGIN_TAKEOFF" );
    precachestring( &"ZM_PRISON_PLANE_BOARD" );
    precachestring( &"ZM_PRISON_KEY_DOOR_LOCKED" );
    precacherumble( "damage_heavy" );
    precacherumble( "explosion_generic" );
    registerclientfield( "world", "fake_master_key", 9000, 2, "int" );
    flag_init( "map_revealed" );
    flag_init( "key_found" );
    flag_init( "cloth_found" );
    flag_init( "fueltanks_found" );
    flag_init( "engine_found" );
    flag_init( "steering_found" );
    flag_init( "rigging_found" );
    flag_init( "plane_ready" );
    flag_init( "plane_built" );
    flag_init( "plane_boarded" );
    flag_init( "plane_departed" );
    flag_init( "plane_approach_bridge" );
    flag_init( "plane_zapped" );
    flag_init( "plane_crashed" );
    flag_init( "portal_open" );
    flag_init( "spawn_fuel_tanks" );
    flag_init( "plane_is_away" );
    flag_init( "plane_trip_to_nml_successful" );
    flag_init( "story_vo_playing" );
    flag_init( "docks_inner_gate_unlocked" );
    flag_init( "docks_inner_gate_open" );
    flag_init( "docks_outer_gate_open" );
    flag_init( "docks_gates_remain_open" );
    flag_init( "nixie_puzzle_solved" );
    flag_init( "nixie_countdown_started" );
    flag_init( "nixie_countdown_expired" );
    flag_init( "nixie_puzzle_completed" );
    flag_init( "generator_challenge_completed" );
    flag_init( "dryer_cycle_active" );
    flag_init( "quest_completed_thrice" );
    flag_init( "final_quest_ready" );
    flag_init( "final_quest_audio_tour_started" );
    flag_init( "final_quest_audio_tour_finished" );
    flag_init( "final_quest_plane_built" );
    flag_init( "final_quest_plane_boarded" );
    flag_init( "final_quest_plane_departed" );
    flag_init( "final_quest_plane_zapped" );
    flag_init( "final_quest_plane_crashed" );
    flag_init( "final_quest_final_battle_started" );
    flag_init( "final_quest_good_wins" );
    flag_init( "final_quest_evil_wins" );
    flag_init( "nixie_ee_flashing" );
}

start_alcatraz_sidequest()
{
    init();
    onplayerconnect_callback( ::player_disconnect_watcher );
    onplayerconnect_callback( ::player_death_watcher );
    flag_wait( "start_zombie_round_logic" );
/#
    setup_devgui();
#/
    level.n_quest_iteration_count = 1;
    level.n_plane_fuel_count = 5;
    level.n_plane_pieces_found = 0;
    level.final_flight_players = [];
    level.final_flight_activated = 0;
    level.characters_in_nml = [];
    level.someone_has_visited_nml = 0;
    level.custom_game_over_hud_elem = maps\mp\zm_prison_sq_final::custom_game_over_hud_elem;
    prevent_theater_mode_spoilers();
    setup_key_doors();
    setup_puzzle_piece_glint();
    setup_puzzles();
    setup_quest_triggers();

    if ( isdefined( level.gamedifficulty ) && level.gamedifficulty != 0 )
        maps\mp\zm_prison_sq_final::final_flight_setup();

    level thread warden_fence_hotjoin_handler();

    if ( isdefined( level.host_migration_listener_custom_func ) )
        level thread [[ level.host_migration_listener_custom_func ]]();
    else
        level thread host_migration_listener();

    if ( isdefined( level.manage_electric_chairs_custom_func ) )
        level thread [[ level.manage_electric_chairs_custom_func ]]();
    else
        level thread manage_electric_chairs();

    if ( isdefined( level.plane_flight_thread_custom_func ) )
        level thread [[ level.plane_flight_thread_custom_func ]]();
    else
        level thread plane_flight_thread();

    if ( isdefined( level.track_quest_status_thread_custom_func ) )
        level thread [[ level.track_quest_status_thread_custom_func ]]();
    else
        level thread track_quest_status_thread();

    maps\mp\zm_alcatraz_sq_vo::opening_vo();
}

host_migration_listener()
{
    level endon( "end_game" );
    level notify( "afterlife_hostmigration" );
    level endon( "afterlife_hostmigration" );

    while ( true )
    {
        level waittill( "host_migration_end" );

        m_plane_craftable = getent( "plane_craftable", "targetname" );
        m_plane_about_to_crash = getent( "plane_about_to_crash", "targetname" );
        veh_plane_flyable = getent( "plane_flyable", "targetname" );
        a_players = getplayers();

        if ( flag( "plane_boarded" ) && !flag( "plane_departed" ) )
        {
            foreach ( player in a_players )
            {
                if ( isdefined( player ) && isdefined( player.character_name ) && isinarray( level.characters_in_nml, player.character_name ) )
                    player playerlinktodelta( m_plane_craftable, "tag_player_crouched_" + ( player.n_passenger_index + 1 ) );
            }
        }
        else if ( flag( "plane_departed" ) && !flag( "plane_approach_bridge" ) )
        {
            foreach ( player in a_players )
            {
                if ( isdefined( player ) && isdefined( player.character_name ) && isinarray( level.characters_in_nml, player.character_name ) )
                    player playerlinktodelta( veh_plane_flyable, "tag_player_crouched_" + ( player.n_passenger_index + 1 ) );
            }
        }
        else if ( flag( "plane_approach_bridge" ) && !flag( "plane_zapped" ) )
        {
            foreach ( player in a_players )
            {
                if ( isdefined( player ) && isdefined( player.character_name ) && isinarray( level.characters_in_nml, player.character_name ) )
                    player playerlinktoabsolute( veh_plane_flyable, "tag_player_crouched_" + ( player.n_passenger_index + 1 ) );
            }
        }
        else if ( flag( "plane_zapped" ) && !flag( "plane_crashed" ) )
        {
            foreach ( player in a_players )
            {
                if ( isdefined( player ) && isdefined( player.character_name ) && isinarray( level.characters_in_nml, player.character_name ) )
                    player playerlinktodelta( m_plane_about_to_crash, "tag_player_crouched_" + ( player.n_passenger_index + 1 ), 1, 0, 0, 0, 0, 1 );
            }
        }

        setup_puzzle_piece_glint();
        setclientfield( "fake_master_key", level.is_master_key_west + 1 );

        if ( !flag( "key_found" ) )
        {
            if ( level.is_master_key_west )
                exploder( 101 );
            else
                exploder( 100 );
        }
    }
}

prevent_theater_mode_spoilers()
{
    flag_wait( "initial_blackscreen_passed" );
    m_plane_flyable = getent( "plane_flyable", "targetname" );
    m_plane_flyable setinvisibletoall();
    m_plane_hideable_engine = getent( "plane_hideable_engine", "targetname" );
    m_plane_hideable_engine ghost();
    m_plane_hideable_clothes_pile = getent( "plane_hideable_clothes_pile", "targetname" );
    m_plane_hideable_clothes_pile ghost();
    a_str_partnames = [];
    a_str_partnames[0] = "cloth";
    a_str_partnames[1] = "steering";

    for ( i = 0; i < a_str_partnames.size; i++ )
    {
        m_plane_piece = get_craftable_piece_model( "plane", a_str_partnames[i] );

        if ( isdefined( m_plane_piece ) )
            m_plane_piece setinvisibletoall();
    }

    m_master_key = get_craftable_piece_model( "quest_key1", "p6_zm_al_key" );

    if ( isdefined( m_master_key ) )
        m_master_key setinvisibletoall();
}

setup_puzzle_piece_glint()
{
    wait 1;
    a_str_partnames = [];
    a_str_partnames[0] = "cloth";
    a_str_partnames[1] = "fueltanks";
    a_str_partnames[2] = "engine";
    a_str_partnames[3] = "steering";
    a_str_partnames[4] = "rigging";

    for ( i = 0; i < a_str_partnames.size; i++ )
    {
        m_plane_piece = get_craftable_piece_model( "plane", a_str_partnames[i] );

        if ( isdefined( m_plane_piece ) )
            playfxontag( level._effect["quest_item_glow"], m_plane_piece, "tag_origin" );

        m_fuel_can = get_craftable_piece_model( "refuelable_plane", "fuel" + ( i + 1 ) );

        if ( isdefined( m_fuel_can ) )
            playfxontag( level._effect["quest_item_glow"], m_fuel_can, "tag_origin" );
    }

    m_master_key = get_craftable_piece_model( "quest_key1", "p6_zm_al_key" );

    if ( isdefined( m_master_key ) )
        playfxontag( level._effect["key_glint"], m_master_key, "tag_origin" );

    m_fake_plane_steering = getent( "fake_veh_t6_dlc_zombie_part_control", "targetname" );

    if ( isdefined( m_fake_plane_steering ) )
        playfxontag( level._effect["quest_item_glow"], m_fake_plane_steering, "tag_origin" );
}

setup_devgui()
{
    setdvar( "add_afterlife", "off" );
    setdvar( "build_plane", "off" );
    setdvar( "get_master_key", "off" );
    setdvar( "alcatraz_final_battle", "off" );
    setdvar( "alcatraz_give_shield", "off" );
/#
    adddebugcommand( "devgui_cmd \"Zombies/Alcatraz:1/Add Afterlife\" \"add_afterlife on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Alcatraz:1/Get Master Key\" \"get_master_key on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Alcatraz:1/Alcatraz Final Battle\" \"alcatraz_final_battle on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Alcatraz:1/Build Plane:1\" \"build_plane on\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies/Alcatraz:1/Give Shield:1\" \"alcatraz_give_shield on\"\n" );
#/
    level thread watch_devgui_alcatraz_final_battle();
    level thread watch_devgui_afterlife();
    level thread watch_devgui_plane();
    level thread watch_devgui_get_key();
    level thread watch_devgui_give_shield();
}

watch_devgui_alcatraz_final_battle()
{
    while ( true )
    {
        if ( getdvar( _hash_9624FC9B ) == "on" )
        {
            players = getplayers();

            foreach ( player in players )
            {
/#
                iprintlnbold( "LINK PLAYER TO PLANE, START COUNTDOWN IF NOT YET STARTED" );
#/
                level.final_flight_activated = 1;
                player thread final_flight_player_thread();
            }

            setdvar( "alcatraz_final_battle", "off" );
        }

        wait 0.1;
    }
}

watch_devgui_get_key()
{
    while ( true )
    {
        if ( getdvar( _hash_B1E41F18 ) == "on" )
        {
            a_players = [];
            a_players = getplayers();
            m_master_key = get_craftable_piece_model( "quest_key1", "p6_zm_al_key" );

            if ( isdefined( m_master_key ) )
            {
                m_master_key.origin = a_players[0].origin + vectorscale( ( 0, 0, 1 ), 60.0 );
                m_master_key setvisibletoall();
            }

            setdvar( "get_master_key", "off" );
        }

        wait 0.1;
    }
}

watch_devgui_afterlife()
{
    while ( true )
    {
        if ( getdvar( _hash_51DB321F ) == "on" )
        {
            a_players = [];
            a_players = getplayers();

            for ( i = 0; i < a_players.size; i++ )
                a_players[i] afterlife_add();

            setdvar( "add_afterlife", "off" );
        }

        wait 0.1;
    }
}

watch_devgui_give_shield()
{
    while ( true )
    {
        if ( getdvar( _hash_DF65AA39 ) == "on" )
        {
            foreach ( player in getplayers() )
            {
                if ( is_equipment_included( "alcatraz_shield_zm" ) )
                    player maps\mp\zombies\_zm_equipment::equipment_buy( "alcatraz_shield_zm" );
            }

            setdvar( "alcatraz_give_shield", "off" );
        }

        wait 0.05;
    }
}

watch_devgui_plane()
{
    is_shortcut_plane_built = 0;

    while ( !is_shortcut_plane_built )
    {
        if ( getdvar( _hash_3C0D12E4 ) == "on" )
        {
/#
            iprintlnbold( "plane built!" );
#/
            is_shortcut_plane_built = 1;
        }

        wait 0.1;
    }

    for ( i = 0; i < level.a_uts_craftables.size; i++ )
    {
        if ( level.a_uts_craftables[i].equipname == "plane" )
            level.a_uts_craftables[i].crafted = 1;
    }

    level thread maps\mp\zm_alcatraz_sq_vo::escape_flight_vo();
    plane_craftable = getent( "plane_craftable", "targetname" );
    plane_craftable showpart( "tag_support_upper" );
    plane_craftable showpart( "tag_wing_skins_up" );
    plane_craftable showpart( "tag_engines_up" );
    plane_craftable showpart( "tag_feul_tanks" );
    plane_craftable showpart( "tag_control_mechanism" );
    plane_craftable showpart( "tag_fuel_hose" );
    t_plane_fly = getent( "plane_fly_trigger", "targetname" );
    t_plane_fly trigger_on();
    t_plane_fly.require_look_at = 0;

    while ( isdefined( t_plane_fly ) )
    {
        t_plane_fly waittill( "trigger", e_triggerer );

        if ( isplayer( e_triggerer ) )
        {
/#
            iprintlnbold( e_triggerer );
#/
            if ( isdefined( level.custom_plane_validation ) )
            {
                valid = t_plane_fly [[ level.custom_plane_validation ]]( e_triggerer );

                if ( !valid )
                    continue;
            }

            if ( level.n_plane_fuel_count == 5 )
            {
                if ( isdefined( level.plane_boarding_thread_custom_func ) )
                    e_triggerer thread [[ level.plane_boarding_thread_custom_func ]]();
                else
                {
/#
                    iprintlnbold( "LINK PLAYER TO PLANE, START COUNTDOWN IF NOT YET STARTED" );
#/
                    e_triggerer thread plane_boarding_thread();
                }
            }
        }
    }
}

setup_key_doors()
{
    width = 0;
    height = 0;
    length = 0;

    for ( piece_number = 1; piece_number < 6; piece_number++ )
    {
        switch ( piece_number )
        {
            case 1:
                width = 120;
                height = 112;
                length = 120;
                break;
            case 2:
                width = 120;
                height = 112;
                length = 124;
                break;
            case 3:
                width = 108;
                height = 112;
                length = 90;
                break;
            case 4:
                width = 98;
                height = 112;
                length = 108;
                break;
            case 5:
                width = 60;
                height = 112;
                length = 90;
                break;
        }

        create_key_door_unitrigger( piece_number, width, height, length );
    }
}

create_key_door_unitrigger( piece_num, width, height, length )
{
    t_key_door = getstruct( "key_door_" + piece_num + "_trigger", "targetname" );
    t_key_door.unitrigger_stub = spawnstruct();
    t_key_door.unitrigger_stub.origin = t_key_door.origin;
    t_key_door.unitrigger_stub.angles = t_key_door.angles;
    t_key_door.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
    t_key_door.unitrigger_stub.hint_string = &"ZM_PRISON_KEY_DOOR_LOCKED";
    t_key_door.unitrigger_stub.cursor_hint = "HINT_NOICON";
    t_key_door.unitrigger_stub.script_width = width;
    t_key_door.unitrigger_stub.script_height = height;
    t_key_door.unitrigger_stub.script_length = length;
    t_key_door.unitrigger_stub.n_door_index = piece_num;
    t_key_door.unitrigger_stub.require_look_at = 0;
    t_key_door.unitrigger_stub.prompt_and_visibility_func = ::key_door_trigger_visibility;
    maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( t_key_door.unitrigger_stub, ::master_key_door_trigger_thread );
}

key_door_trigger_visibility( player )
{
    b_is_invis = player.afterlife || isdefined( self.stub.master_key_door_opened ) && self.stub.master_key_door_opened || self.stub.n_door_index == 2 && !flag( "generator_challenge_completed" );
    self setinvisibletoplayer( player, b_is_invis );

    if ( flag( "key_found" ) )
        self sethintstring( &"ZM_PRISON_KEY_DOOR" );
    else
        self sethintstring( self.stub.hint_string );

    return !b_is_invis;
}

master_key_door_trigger_thread()
{
    self endon( "death" );
    self endon( "kill_trigger" );
    n_door_index = self.stub.n_door_index;
    b_door_open = 0;

    while ( !b_door_open )
    {
        self waittill( "trigger", e_triggerer );

        if ( e_triggerer is_holding_part( "quest_key1", "p6_zm_al_key" ) )
        {
            self.stub.master_key_door_opened = 1;
            self.stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
            level thread open_custom_door_master_key( n_door_index, e_triggerer );
            self playsound( "evt_quest_door_open" );
            b_door_open = 1;
        }
        else
        {
            e_triggerer thread do_player_general_vox( "quest", "sidequest_key", undefined, 100 );
/#
            iprintlnbold( "missing key!" );
#/
        }
    }

    level thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.stub );
}

open_custom_door_master_key( n_door_index, e_triggerer )
{
    m_lock = getent( "masterkey_lock_" + n_door_index, "targetname" );
    m_lock playsound( "zmb_quest_key_unlock" );
    playfxontag( level._effect["fx_alcatraz_unlock_door"], m_lock, "tag_origin" );
    wait 0.5;
    m_lock delete();

    switch ( n_door_index )
    {
        case 1:
            shower_key_door = getent( "shower_key_door", "targetname" );
            shower_key_door moveto( shower_key_door.origin + vectorscale( ( 1, 0, 0 ), 80.0 ), 0.25 );
            shower_key_door connectpaths();

            if ( isdefined( e_triggerer ) )
                e_triggerer door_rumble_on_open();

            shower_key_door playsound( "zmb_chainlink_open" );
            break;
        case 2:
            admin_powerhouse_puzzle_door_clip = getent( "admin_powerhouse_puzzle_door_clip", "targetname" );
            admin_powerhouse_puzzle_door_clip delete();
            admin_powerhouse_puzzle_door = getent( "admin_powerhouse_puzzle_door", "targetname" );
            admin_powerhouse_puzzle_door rotateyaw( 90, 0.5 );
            admin_powerhouse_puzzle_door playsound( "zmb_chainlink_open" );
            break;
        case 3:
            m_nixie_door_left = getent( "nixie_door_left", "targetname" );
            m_nixie_door_right = getent( "nixie_door_right", "targetname" );
            m_nixie_door_left rotateyaw( -165, 0.5 );
            m_nixie_door_right rotateyaw( 165, 0.5 );
            m_nixie_tube_weaponclip = getent( "nixie_tube_weaponclip", "targetname" );
            m_nixie_tube_weaponclip delete();

            if ( isdefined( e_triggerer ) )
                e_triggerer door_rumble_on_open();

            break;
        case 4:
            m_gate_01 = getent( "cable_puzzle_gate_01", "targetname" );
            m_gate_01 moveto( m_gate_01.origin + ( -16, 80, 0 ), 0.5 );
            m_gate_01 connectpaths();
            gate_1_monsterclip = getent( "docks_gate_1_monsterclip", "targetname" );
            gate_1_monsterclip.origin += vectorscale( ( 0, 0, 1 ), 256.0 );
            gate_1_monsterclip disconnectpaths();
            gate_1_monsterclip.origin -= vectorscale( ( 0, 0, 1 ), 256.0 );

            if ( isdefined( e_triggerer ) )
                e_triggerer door_rumble_on_open();

            m_gate_01 playsound( "zmb_chainlink_open" );
            flag_set( "docks_inner_gate_unlocked" );
            flag_set( "docks_inner_gate_open" );
            break;
        case 5:
            m_infirmary_case_door_left = getent( "infirmary_case_door_left", "targetname" );
            m_infirmary_case_door_right = getent( "infirmary_case_door_right", "targetname" );
            m_infirmary_case_door_left rotateyaw( -165, 0.5 );
            m_infirmary_case_door_right rotateyaw( 165, 0.5 );
            m_fake_plane_steering = getent( "fake_veh_t6_dlc_zombie_part_control", "targetname" );
            m_plane_steering = get_craftable_piece_model( "plane", "steering" );
            m_plane_steering moveto( m_plane_steering.origin + vectorscale( ( 0, 0, 1 ), 512.0 ), 0.05 );
            m_plane_steering setvisibletoall();
            m_fake_plane_steering hide();

            if ( isdefined( e_triggerer ) )
                e_triggerer door_rumble_on_open();

            m_infirmary_case_door_right playsound( "zmb_cabinet_door" );
            break;
    }
}

door_rumble_on_open()
{
    self endon( "disconnect" );
    level endon( "end_game" );
    self setclientfieldtoplayer( "rumble_door_open", 1 );
    wait_network_frame();
    self setclientfieldtoplayer( "rumble_door_open", 0 );
}

setup_puzzles()
{
    level thread setup_master_key();
    level thread setup_dryer_challenge();
    level thread setup_generator_challenge();
    level thread maps\mp\zm_alcatraz_sq_nixie::setup_nixie_tubes_puzzle();
    level thread setup_gate_puzzle();
}

setup_quest_triggers()
{
    t_plane_fuelable = getent( "plane_fuelable_trigger", "targetname" );
    t_plane_fuelable trigger_off();
    t_plane_fly = getent( "plane_fly_trigger", "targetname" );
    t_plane_fly setcursorhint( "HINT_NOICON" );
    t_plane_fly sethintstring( &"ZM_PRISON_PLANE_BOARD" );
    t_plane_fly.require_look_at = 0;
    t_plane_fly thread plane_fly_trigger_thread();
}

setup_master_key()
{
    level.is_master_key_west = randomintrange( 0, 2 );
    setclientfield( "fake_master_key", level.is_master_key_west + 1 );

    if ( level.is_master_key_west )
    {
        level thread key_pulley( "west" );
        exploder( 101 );
        array_delete( getentarray( "wires_pulley_east", "script_noteworthy" ) );
    }
    else
    {
        level thread key_pulley( "east" );
        exploder( 100 );
        array_delete( getentarray( "wires_pulley_west", "script_noteworthy" ) );
    }
}

key_pulley( str_master_key_location )
{
    if ( level.is_master_key_west )
    {
        t_other_hurt_trigger = getent( "pulley_hurt_trigger_east", "targetname" );
        t_other_panel = getent( "master_key_pulley_east", "targetname" );
    }
    else
    {
        t_other_hurt_trigger = getent( "pulley_hurt_trigger_west", "targetname" );
        t_other_panel = getent( "master_key_pulley_west", "targetname" );
    }

    t_other_hurt_trigger delete();
    t_other_panel setmodel( "p6_zm_al_power_station_panels_03" );
    t_pulley_hurt_trigger = getent( "pulley_hurt_trigger_" + str_master_key_location, "targetname" );
    t_pulley_hurt_trigger thread maps\mp\zm_alcatraz_sq_vo::sndhitelectrifiedpulley( str_master_key_location );
    m_master_key_pulley = getent( "master_key_pulley_" + str_master_key_location, "targetname" );
    m_master_key_pulley play_fx( "fx_alcatraz_panel_on_2", m_master_key_pulley.origin, m_master_key_pulley.angles, "power_down", 1, undefined, undefined );
    m_master_key_pulley thread afterlife_interact_object_think();

    level waittill( "master_key_pulley_" + str_master_key_location );

    m_master_key_pulley playsound( "zmb_quest_generator_panel_spark" );
    m_master_key_pulley notify( "power_down" );
    m_master_key_pulley setmodel( "p6_zm_al_power_station_panels_03" );
    playfxontag( level._effect["fx_alcatraz_panel_ol"], m_master_key_pulley, "tag_origin" );
    m_master_key_pulley play_fx( "fx_alcatraz_panel_off_2", m_master_key_pulley.origin, m_master_key_pulley.angles, "power_down", 1, undefined, undefined );

    if ( level.is_master_key_west )
    {
        stop_exploder( 101 );
        array_delete( getentarray( "wires_pulley_west", "script_noteworthy" ) );
    }
    else
    {
        stop_exploder( 100 );
        array_delete( getentarray( "wires_pulley_east", "script_noteworthy" ) );
    }

    t_hurt_trigger = getent( "pulley_hurt_trigger_" + str_master_key_location, "targetname" );
    t_hurt_trigger delete();

    if ( str_master_key_location == "west" )
        level setclientfield( "fxanim_pulley_down_start", 1 );
    else if ( str_master_key_location == "east" )
        level setclientfield( "fxanim_pulley_down_start", 2 );

    wait 3;
    level setclientfield( "master_key_is_lowered", 1 );
    m_master_key = get_craftable_piece_model( "quest_key1", "p6_zm_al_key" );

    if ( isdefined( m_master_key ) )
    {
        e_master_key_target = getstruct( "master_key_" + str_master_key_location + "_origin", "targetname" );
        m_master_key.origin = e_master_key_target.origin;
        m_master_key setvisibletoall();
    }
}

setup_dryer_challenge()
{
    t_dryer = getent( "dryer_trigger", "targetname" );
    t_dryer setcursorhint( "HINT_NOICON" );
    t_dryer sethintstring( &"ZM_PRISON_LAUNDRY_MACHINE_ACTIVATE" );
    t_dryer thread dryer_trigger_thread();
    t_dryer thread dryer_zombies_thread();
    t_dryer trigger_off();

    level waittill( "laundry_power_switch_afterlife" );

    level setclientfield( "dryer_stage", 1 );
/#
    iprintlnbold( "dryer can now be activated" );
#/
    t_dryer trigger_on();
    t_dryer playsound( "evt_dryer_rdy_bell" );
    wait 1;
    players = getplayers();

    foreach ( player in players )
    {
        if ( !player.afterlife && distance( player.origin, t_dryer.origin ) < 1500 )
        {
            player thread do_player_general_vox( "general", "power_on", undefined, 100 );
            return;
        }
    }
}

dryer_trigger_thread()
{
    self endon( "death" );
    n_dryer_cycle_duration = 30;
    a_dryer_spawns = [];
    sndent = spawn( "script_origin", ( 1613, 10599, 1203 ) );

    self waittill( "trigger" );

    self trigger_off();
    level setclientfield( "dryer_stage", 2 );
    dryer_playerclip = getent( "dryer_playerclip", "targetname" );
    dryer_playerclip moveto( dryer_playerclip.origin + vectorscale( ( 0, 0, 1 ), 104.0 ), 0.05 );
    level clientnotify( "sndFF" );

    if ( !( isdefined( level.music_override ) && level.music_override ) )
    {
        level notify( "sndStopBrutusLoop" );
        level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "laundry_defend" );
    }

    exploder( 1000 );
    sndent thread snddryercountdown( n_dryer_cycle_duration );
    sndent playsound( "evt_dryer_start" );
    sndent playloopsound( "evt_dryer_lp" );
    level clientnotify( "fxanim_dryer_start" );
    flag_set( "dryer_cycle_active" );
    wait 1;
    sndset = sndmusicvariable();
    level clientnotify( "fxanim_dryer_idle_start" );

    for ( i = 3; i > 0; i-- )
    {
/#
        iprintlnbold( i / 3 * n_dryer_cycle_duration + " seconds left!" );
#/
        wait( n_dryer_cycle_duration / 3 );
    }

    level clientnotify( "fxanim_dryer_end_start" );
    wait 2;
    flag_clear( "dryer_cycle_active" );
    dryer_playerclip = getent( "dryer_playerclip", "targetname" );
    dryer_playerclip delete();
    sndent stoploopsound();
    sndent playsound( "evt_dryer_stop" );

    if ( isdefined( sndset ) && sndset )
        level.music_override = 0;

    level clientnotify( "sndFF" );
    level setclientfield( "dryer_stage", 3 );
    stop_exploder( 900 );
    stop_exploder( 1000 );
    m_sheets = get_craftable_piece_model( "plane", "cloth" );
    m_sheets.origin = ( 1586.16, 10598.3, 1192 );
    m_sheets setvisibletoall();
    m_sheets ghost();
    self delete();
    sndent thread delaysndenddelete();
}

sndmusicvariable()
{
    if ( !( isdefined( level.music_override ) && level.music_override ) )
    {
        level.music_override = 1;
        return true;
    }

    return false;
}

dryer_zombies_thread()
{
    n_zombie_count_min = 20;
    e_shower_zone = getent( "cellblock_shower", "targetname" );
    flag_wait( "dryer_cycle_active" );

    if ( level.round_number > 4 || isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
    {
        if ( level.zombie_total < n_zombie_count_min )
            level.zombie_total = n_zombie_count_min;

        while ( flag( "dryer_cycle_active" ) )
        {
            a_zombies_in_shower = [];
            a_zombies_in_shower = get_zombies_touching_volume( "axis", "cellblock_shower", undefined );

            if ( a_zombies_in_shower.size < n_zombie_count_min )
            {
                e_zombie = get_farthest_available_zombie( e_shower_zone );

                if ( isdefined( e_zombie ) && !isinarray( a_zombies_in_shower, e_zombie ) )
                {
                    e_zombie notify( "zapped" );
                    e_zombie thread dryer_teleports_zombie();
                }
            }

            wait 1;
        }
    }
    else
        maps\mp\zombies\_zm_ai_brutus::brutus_spawn_in_zone( "cellblock_shower" );
}

get_farthest_available_zombie( e_landmark )
{
    if ( !isdefined( e_landmark ) )
        return undefined;

    while ( true )
    {
        a_zombies = getaiarray( level.zombie_team );

        if ( isdefined( a_zombies ) )
        {
            zombies = get_array_of_closest( e_landmark.origin, a_zombies );

            for ( x = 0; x < zombies.size; x++ )
            {
                zombie = zombies[x];

                if ( isdefined( zombie ) && isalive( zombie ) && !( isdefined( zombie.in_the_ground ) && zombie.in_the_ground ) && !( isdefined( zombie.gibbed ) && zombie.gibbed ) && !( isdefined( zombie.head_gibbed ) && zombie.head_gibbed ) && !( isdefined( zombie.is_being_used_as_spawnpoint ) && zombie.is_being_used_as_spawnpoint ) && zombie in_playable_area() )
                {
                    zombie.is_being_used_as_spawnpoint = 1;
                    return zombie;
                }
            }
        }
        else
            return undefined;

        wait 0.05;
    }
}

get_zombies_touching_volume( team, volume_name, volume )
{
    if ( !isdefined( volume ) )
    {
        volume = getent( volume_name, "targetname" );
        assert( isdefined( volume ), volume_name + " does not exist" );
    }

    guys = getaiarray( team );
    guys_touching_volume = [];

    for ( i = 0; i < guys.size; i++ )
    {
        if ( guys[i] istouching( volume ) )
            guys_touching_volume[guys_touching_volume.size] = guys[i];
    }

    return guys_touching_volume;
}

dryer_teleports_zombie()
{
    self endon( "death" );
    self endon( "zapped" );

    if ( self.ai_state == "find_flesh" )
    {
        self.zapped = 1;
        a_nodes = getstructarray( "dryer_zombie_teleports", "targetname" );
        nd_target = random( a_nodes );
        playfx( level._effect["afterlife_teleport"], self.origin );
        self hide();
        linker = spawn( "script_origin", ( 0, 0, 0 ) );
        linker thread linker_delete_watch( self );
        linker.origin = self.origin;
        linker.angles = self.angles;
        self linkto( linker );
        linker moveto( nd_target.origin, 0.05 );

        linker waittill( "movedone" );

        playfx( level._effect["afterlife_teleport"], self.origin );
        linker delete();
        self show();
        self.zapped = undefined;
        self.ignoreall = 1;
        self notify( "stop_find_flesh" );
        self thread afterlife_zapped_fx();
        self animscripted( self.origin, self.angles, "zm_afterlife_stun" );
        self maps\mp\animscripts\shared::donotetracks( "stunned" );
        self.ignoreall = 0;
        self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
    }
}

delaysndenddelete()
{
    wait 5;
    self delete();
}

snddryercountdown( num )
{
    ent = spawn( "script_origin", self.origin );

    for ( i = num; i > 0; i-- )
    {
        if ( i <= 10 )
            ent playsound( "zmb_quest_nixie_count_final" );
        else
            ent playsound( "zmb_quest_nixie_count" );

        wait 1;
    }

    ent delete();
}

setup_generator_challenge()
{
    level.n_generator_panels_active = 0;
    generator_soundent = spawn( "script_origin", ( -467, 6388, 132 ) );

    for ( i = 1; i < 4; i++ )
        level thread generator_panel_trigger_thread( i, generator_soundent );

    level thread generator_challenge_main_thread();
}

generator_challenge_main_thread()
{
    exploder( 2000 );

    while ( !flag( "generator_challenge_completed" ) )
    {
        if ( level.n_generator_panels_active == 3 )
        {
/#
            iprintlnbold( "generator overloaded!" );
#/
            flag_set( "generator_challenge_completed" );
        }

        wait 0.1;
    }

    level clientnotify( "sndWard" );
    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "piece_mid" );
    t_warden_fence_damage = getent( "warden_fence_damage", "targetname" );
    t_warden_fence_damage delete();
    level setclientfield( "warden_fence_down", 1 );
    array_delete( getentarray( "generator_wires", "script_noteworthy" ) );
    wait 3;
    stop_exploder( 2000 );
    wait 1;
    players = getplayers();
    player = players[randomintrange( 0, players.size )];
    player do_player_general_vox( "general", "power_off", undefined, 100 );
}

generator_panel_trigger_thread( n_panel_index, generator_soundent )
{
    self endon( "death" );
    m_generator_panel = getent( "generator_panel_" + n_panel_index, "targetname" );
    m_generator_panel thread afterlife_interact_object_think();
    m_generator_panel play_fx( "fx_alcatraz_panel_on_2", m_generator_panel.origin, m_generator_panel.angles, "generator_panel_" + n_panel_index + "_afterlife", 1, undefined, undefined );

    level waittill( "generator_panel_" + n_panel_index + "_afterlife" );

    m_generator_panel notify( "generator_panel_" + n_panel_index + "_afterlife" );
/#
    iprintlnbold( "generator panel " + n_panel_index + " overloaded!" );
#/
    level.n_generator_panels_active += 1;
    m_generator_panel setmodel( "p6_zm_al_power_station_panels_03" );
    playfxontag( level._effect["fx_alcatraz_panel_ol"], m_generator_panel, "tag_origin" );
    m_generator_panel play_fx( "fx_alcatraz_panel_off_2", m_generator_panel.origin, m_generator_panel.angles, undefined, 1, undefined, undefined );
    set_generator_vfx_amount( level.n_generator_panels_active, generator_soundent );
    playsoundatposition( "zmb_quest_generator_panel_spark", m_generator_panel.origin );
}

set_generator_vfx_amount( n_vfx_amount, generator_soundent )
{
    if ( n_vfx_amount == 1 )
        generator_soundent playloopsound( "zmb_quest_generator_loop1" );

    if ( n_vfx_amount == 2 )
    {
        generator_soundent stoploopsound();
        wait 0.05;
        generator_soundent playloopsound( "zmb_quest_generator_loop2" );
    }

    if ( n_vfx_amount == 3 )
    {
        exploder( 3100 );
        exploder( 3200 );
        exploder( 3300 );
        generator_soundent stoploopsound();
        wait 0.05;
        generator_soundent playloopsound( "zmb_quest_generator_loop3" );
    }
}

setup_gate_puzzle()
{
    self endon( "death" );
    is_gate_toggled = 0;
    is_inner_gate_toggleable = 0;
    m_gate_02 = getent( "cable_puzzle_gate_02", "targetname" );
    n_gate_move_duration = 0.5;
    m_docks_shockbox = getent( "docks_panel", "targetname" );
    array_set_visible_to_all( getentarray( "wires_docks_gate_toggle", "script_noteworthy" ), 0 );
    a_players = [];
    a_players = getplayers();

    if ( a_players.size > 1 )
        is_inner_gate_toggleable = 1;

    while ( true )
    {
        m_docks_shockbox thread afterlife_interact_object_think();

        level waittill( "cable_puzzle_gate_afterlife" );

        array_set_visible_to_all( getentarray( "wires_docks_gate_toggle", "script_noteworthy" ), 1 );

        if ( is_inner_gate_toggleable && flag( "docks_inner_gate_unlocked" ) )
            level thread toggle_inner_gate( n_gate_move_duration );

        if ( !flag( "docks_outer_gate_open" ) )
        {
            m_gate_02 moveto( m_gate_02.origin + ( -16, 80, 0 ), n_gate_move_duration );
            wait( n_gate_move_duration + 0.25 );
            m_gate_02 connectpaths();
            gate_2_monsterclip = getent( "docks_gate_2_monsterclip", "targetname" );
            gate_2_monsterclip.origin += vectorscale( ( 0, 0, 1 ), 256.0 );
            gate_2_monsterclip disconnectpaths();
            gate_2_monsterclip.origin -= vectorscale( ( 0, 0, 1 ), 256.0 );
            m_gate_02 playsound( "zmb_chainlink_close" );
        }
        else if ( !flag( "docks_gates_remain_open" ) )
        {
            m_gate_02 moveto( m_gate_02.origin - ( -16, 80, 0 ), n_gate_move_duration );
            wait( n_gate_move_duration + 0.25 );
            m_gate_02 disconnectpaths();
            gate_2_monsterclip = getent( "docks_gate_2_monsterclip", "targetname" );
            gate_2_monsterclip connectpaths();
            m_gate_02 playsound( "zmb_chainlink_open" );
        }

        flag_toggle( "docks_outer_gate_open" );
/#
        iprintlnbold( "gate toggled!" );
#/
        wait( n_gate_move_duration );
/#
        iprintlnbold( "gate ready to be re-toggled" );
#/
        m_docks_shockbox notify( "afterlife_interact_reset" );
        array_set_visible_to_all( getentarray( "wires_docks_gate_toggle", "script_noteworthy" ), 0 );
    }
}

toggle_inner_gate( n_gate_move_duration )
{
    a_m_gate_01 = getentarray( "cable_puzzle_gate_01", "targetname" );

    if ( flag( "docks_inner_gate_open" ) && !flag( "docks_gates_remain_open" ) )
    {
        for ( i = 0; i < a_m_gate_01.size; i++ )
            a_m_gate_01[i] moveto( a_m_gate_01[i].origin - ( -16, 80, 0 ), n_gate_move_duration );

        wait( n_gate_move_duration + 0.25 );

        for ( i = 0; i < a_m_gate_01.size; i++ )
            a_m_gate_01[i] disconnectpaths();

        gate_1_monsterclip = getent( "docks_gate_1_monsterclip", "targetname" );
        gate_1_monsterclip connectpaths();
        a_m_gate_01[0] playsound( "zmb_chainlink_close" );
    }
    else
    {
        for ( i = 0; i < a_m_gate_01.size; i++ )
            a_m_gate_01[i] moveto( a_m_gate_01[i].origin + ( -16, 80, 0 ), n_gate_move_duration );

        wait( n_gate_move_duration + 0.25 );

        for ( i = 0; i < a_m_gate_01.size; i++ )
            a_m_gate_01[i] connectpaths();

        gate_1_monsterclip = getent( "docks_gate_1_monsterclip", "targetname" );
        gate_1_monsterclip.origin += vectorscale( ( 0, 0, 1 ), 256.0 );
        gate_1_monsterclip disconnectpaths();
        gate_1_monsterclip.origin -= vectorscale( ( 0, 0, 1 ), 256.0 );
        a_m_gate_01[0] playsound( "zmb_chainlink_open" );
    }

    flag_toggle( "docks_inner_gate_open" );
}

plane_fly_trigger_thread()
{
    self setcursorhint( "HINT_NOICON" );
    self sethintstring( &"ZM_PRISON_PLANE_BEGIN_TAKEOFF" );
    flag_wait( "initial_players_connected" );
    flag_wait( "brutus_setup_complete" );
    self trigger_off();
    wait 1;
    m_plane_craftable = getent( "plane_craftable", "targetname" );
    m_plane_craftable show();
    m_plane_craftable hidepart( "tag_support_upper" );
    m_plane_craftable hidepart( "tag_wing_skins_up" );
    m_plane_craftable hidepart( "tag_engines_up" );
    m_plane_craftable hidepart( "tag_feul_tanks" );
    m_plane_craftable hidepart( "tag_control_mechanism" );
    m_plane_craftable hidepart( "tag_engine_ground" );
    m_plane_craftable hidepart( "tag_clothes_ground" );
    m_plane_craftable hidepart( "tag_fuel_hose" );
    waittill_crafted( "plane" );
    maps\mp\zombies\_zm_ai_brutus::transfer_plane_trigger( "build", "fly" );
    self trigger_on();

    while ( isdefined( self ) )
    {
        self waittill( "trigger", e_triggerer );

        if ( isplayer( e_triggerer ) )
        {
            if ( level.n_plane_fuel_count == 5 )
            {
                if ( isdefined( level.custom_plane_validation ) )
                {
                    valid = self [[ level.custom_plane_validation ]]( e_triggerer );

                    if ( !valid )
                        continue;
                }

                self setinvisibletoplayer( e_triggerer );

                if ( isdefined( level.plane_boarding_thread_custom_func ) )
                    e_triggerer thread [[ level.plane_boarding_thread_custom_func ]]();
                else
                    e_triggerer thread plane_boarding_thread();
            }
        }
    }
}

plane_boarding_thread()
{
    self endon( "death_or_disconnect" );
    flag_set( "plane_is_away" );
    self thread player_disconnect_watcher();
    self thread player_death_watcher();
/#
    iprintlnbold( "plane boarding thread started" );
#/
    flag_set( "plane_boarded" );
    self setclientfieldtoplayer( "effects_escape_flight", 1 );
    level.brutus_respawn_after_despawn = 0;
    a_nml_teleport_targets = [];

    for ( i = 1; i < 6; i++ )
        a_nml_teleport_targets[i - 1] = getstruct( "nml_telepoint_" + i, "targetname" );

    level.characters_in_nml[level.characters_in_nml.size] = self.character_name;
    self.on_a_plane = 1;
    level.someone_has_visited_nml = 1;
    self.n_passenger_index = level.characters_in_nml.size;
    m_plane_craftable = getent( "plane_craftable", "targetname" );
    m_plane_about_to_crash = getent( "plane_about_to_crash", "targetname" );
    veh_plane_flyable = getent( "plane_flyable", "targetname" );
    t_plane_fly = getent( "plane_fly_trigger", "targetname" );
    t_plane_fly sethintstring( &"ZM_PRISON_PLANE_BOARD" );
    self enableinvulnerability();
    self playerlinktodelta( m_plane_craftable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
    self allowstand( 0 );
    flag_wait( "plane_departed" );
    level notify( "sndStopBrutusLoop" );
    self clientnotify( "sndPS" );
    self playsoundtoplayer( "zmb_plane_takeoff", self );
    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "plane_takeoff", self );
    self playerlinktodelta( veh_plane_flyable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
    self setclientfieldtoplayer( "effects_escape_flight", 2 );
    flag_wait( "plane_approach_bridge" );
    self thread snddelayedimp();
    self setclientfieldtoplayer( "effects_escape_flight", 3 );
    self unlink();
    self playerlinktoabsolute( veh_plane_flyable, "tag_player_crouched_" + ( self.n_passenger_index + 1 ) );
    flag_wait( "plane_zapped" );
    flag_set( "activate_player_zone_bridge" );
    self playsoundtoplayer( "zmb_plane_fall", self );
    self setclientfieldtoplayer( "effects_escape_flight", 4 );
    self.dontspeak = 1;
    self setclientfieldtoplayer( "isspeaking", 1 );
    self playerlinktodelta( m_plane_about_to_crash, "tag_player_crouched_" + ( self.n_passenger_index + 1 ), 1, 0, 0, 0, 0, 1 );
    self forcegrenadethrow();
    str_current_weapon = self getcurrentweapon();
    self giveweapon( "falling_hands_zm" );
    self switchtoweaponimmediate( "falling_hands_zm" );
    self setweaponammoclip( "falling_hands_zm", 0 );
    players = getplayers();

    foreach ( player in players )
    {
        if ( player != self )
            player setinvisibletoplayer( self );
    }

    flag_wait( "plane_crashed" );
    self setclientfieldtoplayer( "effects_escape_flight", 5 );
    self takeweapon( "falling_hands_zm" );

    if ( isdefined( str_current_weapon ) && str_current_weapon != "none" )
        self switchtoweaponimmediate( str_current_weapon );

    self thread fadetoblackforxsec( 0, 2, 0, 0.5, "black" );
    self thread snddelayedmusic();
    self unlink();
    self allowstand( 1 );
    self setstance( "stand" );
    players = getplayers();

    foreach ( player in players )
    {
        if ( player != self )
            player setvisibletoplayer( self );
    }

    flag_clear( "spawn_zombies" );
    self setorigin( a_nml_teleport_targets[self.n_passenger_index].origin );
    e_poi = getstruct( "plane_crash_poi", "targetname" );
    vec_to_target = e_poi.origin - self.origin;
    vec_to_target = vectortoangles( vec_to_target );
    vec_to_target = ( 0, vec_to_target[1], 0 );
    self setplayerangles( vec_to_target );
    n_shellshock_duration = 5;
    self shellshock( "explosion", n_shellshock_duration );
    self.dontspeak = 0;
    self setclientfieldtoplayer( "isspeaking", 0 );
    self notify( "player_at_bridge" );
    wait( n_shellshock_duration );
    self disableinvulnerability();
    self.on_a_plane = 0;

    if ( level.characters_in_nml.size == 1 )
        self vo_bridge_soliloquy();
    else if ( level.characters_in_nml.size == 4 )
        vo_bridge_four_part_convo();

    wait 10;
    self playsoundtoplayer( "zmb_ggb_swarm_start", self );
    flag_set( "spawn_zombies" );
    level.brutus_respawn_after_despawn = 1;
    wait 5;
    character_name = level.characters_in_nml[randomintrange( 0, level.characters_in_nml.size )];
    players = getplayers();

    foreach ( player in players )
    {
        if ( isdefined( player ) && player.character_name == character_name )
            player thread do_player_general_vox( "quest", "zombie_arrive_gg", undefined, 100 );
    }
}

snddelayedimp()
{
    self endon( "disconnect" );
    wait 6;
    self playsoundtoplayer( "zmb_plane_explode", self );
}

snddelayedmusic()
{
    self endon( "disconnect" );
    wait 1;
    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "at_golden_gate", self );
    self clientnotify( "sndPE" );
}

track_quest_status_thread()
{
    while ( true )
    {
        while ( level.characters_in_nml.size == 0 )
            wait 1;

        while ( level.characters_in_nml.size > 0 )
            wait 1;

        if ( flag( "plane_trip_to_nml_successful" ) )
        {
            bestow_quest_rewards();
            flag_clear( "plane_trip_to_nml_successful" );
        }

        level notify( "bridge_empty" );

        level waittill( "start_of_round" );

        if ( level.n_quest_iteration_count == 2 )
            vo_play_four_part_conversation( level.four_part_convos["alcatraz_return_alt" + randomintrange( 0, 2 )] );

        prep_for_new_quest();
        waittill_crafted( "refuelable_plane" );
        maps\mp\zombies\_zm_ai_brutus::transfer_plane_trigger( "fuel", "fly" );
        t_plane_fly = getent( "plane_fly_trigger", "targetname" );
        t_plane_fly trigger_on();
    }
}

bestow_quest_rewards()
{
    level.n_quest_iteration_count += 1;

    if ( level.n_quest_iteration_count == 2 )
    {
        level notify( "unlock_all_perk_machines" );
        level notify( "intro_powerup_restored" );
    }
    else if ( level.n_quest_iteration_count == 4 )
        flag_set( "quest_completed_thrice" );
}

prep_for_new_quest()
{
    for ( i = 1; i < 4; i++ )
    {
        str_trigger_targetname = "trigger_electric_chair_" + i;
        t_electric_chair = getent( str_trigger_targetname, "targetname" );
        t_electric_chair sethintstring( &"ZM_PRISON_ELECTRIC_CHAIR_ACTIVATE" );
        t_electric_chair trigger_on();
    }

    flag_set( "spawn_fuel_tanks" );
    wait 0.05;
    flag_clear( "spawn_fuel_tanks" );

    for ( i = 0; i < level.a_uts_craftables.size; i++ )
    {
        if ( level.a_uts_craftables[i].equipname == "refuelable_plane" )
        {
            t_plane_fuelable = level.a_uts_craftables[i];
            level.zones["zone_roof"].plane_triggers[level.zones["zone_roof"].plane_triggers.size] = t_plane_fuelable;
            break;
        }
    }

    t_plane_fly = getent( "plane_fly_trigger", "targetname" );
    t_plane_fly trigger_off();
    players = get_players();
    t_plane_fly setvisibletoall();
    maps\mp\zombies\_zm_ai_brutus::transfer_plane_trigger( "fly", "fuel" );

    for ( i = 1; i < 5; i++ )
    {
        m_electric_chair = getent( "electric_chair_" + i, "targetname" );
        m_electric_chair notify( "bridge_empty" );
    }

    setup_puzzle_piece_glint();
/#
    iprintlnbold( "plane location reset" );
#/
    m_plane_craftable = getent( "plane_craftable", "targetname" );
    m_plane_craftable show();
    playfxontag( level._effect["fx_alcatraz_plane_apear"], m_plane_craftable, "tag_origin" );
    veh_plane_flyable = getent( "plane_flyable", "targetname" );
    veh_plane_flyable attachpath( getvehiclenode( "zombie_plane_underground", "targetname" ) );
    vo_play_four_part_conversation( level.four_part_convos["alcatraz_return_quest_reset"] );
    flag_clear( "plane_is_away" );
}

plane_flight_thread()
{
    while ( true )
    {
        m_plane_about_to_crash = getent( "plane_about_to_crash", "targetname" );
        m_plane_craftable = getent( "plane_craftable", "targetname" );
        t_plane_fly = getent( "plane_fly_trigger", "targetname" );
        veh_plane_flyable = getent( "plane_flyable", "targetname" );
        m_plane_about_to_crash ghost();
        flag_wait( "plane_boarded" );
        level clientnotify( "sndPB" );

        if ( !( isdefined( level.music_override ) && level.music_override ) )
            t_plane_fly playloopsound( "mus_event_plane_countdown_loop", 0.25 );

        for ( i = 10; i > 0; i-- )
        {
/#
            iprintlnbold( "TAKE-OFF IN " + i + "..." );
#/
            veh_plane_flyable playsound( "zmb_plane_countdown_tick" );
            wait 1;
        }

        t_plane_fly stoploopsound( 2 );
        exploder( 10000 );
        veh_plane_flyable attachpath( getvehiclenode( "zombie_plane_flight_path", "targetname" ) );
        veh_plane_flyable startpath();
        flag_set( "plane_departed" );
        t_plane_fly trigger_off();
        m_plane_craftable ghost();
        veh_plane_flyable setvisibletoall();
        level setclientfield( "fog_stage", 1 );
        playfxontag( level._effect["fx_alcatraz_plane_trail"], veh_plane_flyable, "tag_origin" );
        wait 2;
        playfxontag( level._effect["fx_alcatraz_plane_trail_fast"], veh_plane_flyable, "tag_origin" );
        wait 3;
        exploder( 10001 );
        wait 4;
        playfxontag( level._effect["fx_alcatraz_flight_lightning"], veh_plane_flyable, "tag_origin" );
        level setclientfield( "scripted_lightning_flash", 1 );
        wait 1;
        flag_set( "plane_approach_bridge" );
        stop_exploder( 10001 );
        level setclientfield( "fog_stage", 2 );
        veh_plane_flyable attachpath( getvehiclenode( "zombie_plane_bridge_approach", "targetname" ) );
        veh_plane_flyable startpath();
        wait 6;
        playfxontag( level._effect["fx_alcatraz_flight_lightning"], veh_plane_flyable, "tag_origin" );
        level setclientfield( "scripted_lightning_flash", 1 );

        veh_plane_flyable waittill( "reached_end_node" );

        flag_set( "plane_zapped" );
        level setclientfield( "fog_stage", 3 );
        veh_plane_flyable setinvisibletoall();
        n_crash_duration = 2.25;
        nd_plane_about_to_crash_1 = getstruct( "plane_about_to_crash_point_1", "targetname" );
        m_plane_about_to_crash.origin = nd_plane_about_to_crash_1.origin;
        nd_plane_about_to_crash_2 = getstruct( "plane_about_to_crash_point_2", "targetname" );
        m_plane_about_to_crash moveto( nd_plane_about_to_crash_2.origin, n_crash_duration );
        m_plane_about_to_crash thread spin_while_falling();
        stop_exploder( 10000 );

        m_plane_about_to_crash waittill( "movedone" );

        flag_set( "plane_crashed" );
        wait 2;
        level setclientfield( "scripted_lightning_flash", 1 );
        m_plane_about_to_crash.origin += vectorscale( ( 0, 0, -1 ), 2048.0 );
        wait 4;
        veh_plane_flyable setvisibletoall();
        veh_plane_flyable play_fx( "fx_alcatraz_plane_fire_trail", veh_plane_flyable.origin, veh_plane_flyable.angles, "reached_end_node", 1, "tag_origin", undefined );
        veh_plane_flyable attachpath( getvehiclenode( "zombie_plane_bridge_flyby", "targetname" ) );
        veh_plane_flyable startpath();
        veh_plane_flyable thread sndpc();

        veh_plane_flyable waittill( "reached_end_node" );

        veh_plane_flyable setinvisibletoall();
        wait 20;

        if ( !level.final_flight_activated )
        {
            if ( isdefined( level.brutus_on_the_bridge_custom_func ) )
                level thread [[ level.brutus_on_the_bridge_custom_func ]]();
            else
                level thread brutus_on_the_bridge();
        }

        flag_clear( "plane_built" );
        flag_clear( "plane_boarded" );
        flag_clear( "plane_departed" );
        flag_clear( "plane_approach_bridge" );
        flag_clear( "plane_zapped" );
        flag_clear( "plane_crashed" );
        level.n_plane_fuel_count = 0;
    }
}

sndpc()
{
    self playloopsound( "zmb_plane_fire", 4 );
    wait 6;
    self playsound( "zmb_plane_fire_whoosh" );
    wait 1;
    self stoploopsound( 3 );
}

brutus_on_the_bridge()
{
    level endon( "bridge_empty" );
    n_round_on_bridge = 1;
    n_desired_spawn_count = 0;
    n_spawn_cap = 4;
    level.n_bridge_brutuses_killed = 0;

    if ( isdefined( level.last_brutus_on_bridge_custom_func ) )
        level thread [[ level.last_brutus_on_bridge_custom_func ]]();
    else
        level thread last_brutus_on_bridge();

    if ( isdefined( level.brutus_despawn_manager_custom_func ) )
        level thread [[ level.brutus_despawn_manager_custom_func ]]();
    else
        level thread brutus_despawn_manager();

    while ( true )
    {
        level.brutus_last_spawn_round = 0;
        n_desired_spawn_count = int( min( n_round_on_bridge, n_spawn_cap ) );
        n_brutuses_on_bridge_count = get_bridge_brutus_count();
        n_spawns_needed = n_desired_spawn_count - n_brutuses_on_bridge_count;

        for ( i = n_spawns_needed; i > 0; i-- )
        {
            ai = maps\mp\zombies\_zm_ai_brutus::brutus_spawn_in_zone( "zone_golden_gate_bridge", 1 );

            if ( isdefined( ai ) )
            {
                ai.is_bridge_brutus = 1;

                if ( level.n_bridge_brutuses_killed == 0 )
                    ai thread suppress_brutus_bridge_powerups();
            }

            wait( randomfloatrange( 1.0, 4.0 ) );
        }

        level waittill( "start_of_round" );

        n_round_on_bridge++;
    }
}

last_brutus_on_bridge()
{
    level endon( "bridge_empty" );
    e_gg_zone = getent( "zone_golden_gate_bridge", "targetname" );
    a_bridge_brutuses = [];

    while ( true )
    {
        a_bridge_brutuses = get_bridge_brutuses();

        if ( a_bridge_brutuses.size > 1 )
        {
            foreach ( brutus in a_bridge_brutuses )
            {
                if ( isdefined( brutus ) )
                    brutus.suppress_teargas_behavior = 1;
            }
        }
        else if ( a_bridge_brutuses.size == 1 )
            a_bridge_brutuses[0].suppress_teargas_behavior = 0;

        wait 0.05;
    }
}

suppress_brutus_bridge_powerups()
{
    self endon( "brutus_teleporting" );
    level endon( "bridge_empty" );
    level endon( "first_bridge_brutus_killed" );

    self waittill( "death" );

    level.n_bridge_brutuses_killed++;

    if ( level.n_bridge_brutuses_killed >= 1 )
    {
        level.global_brutus_powerup_prevention = 1;
        level thread allow_brutus_powerup_spawning();
        level notify( "first_bridge_brutus_killed" );
    }
}

allow_brutus_powerup_spawning()
{
    level notify( "only_one_powerup_thread" );
    level endon( "only_one_powerup_thread" );

    level waittill( "bridge_empty" );

    level.global_brutus_powerup_prevention = 0;
}

get_bridge_brutuses()
{
    e_gg_zone = getent( "zone_golden_gate_bridge", "targetname" );
    a_bridge_brutuses = [];
    zombies = getaispeciesarray( "axis", "all" );

    for ( i = 0; i < zombies.size; i++ )
    {
        if ( isdefined( zombies[i].is_brutus ) && zombies[i].is_brutus )
        {
            brutus = zombies[i];

            if ( brutus istouching( e_gg_zone ) )
            {
                brutus.is_bridge_brutus = 1;
                a_bridge_brutuses[a_bridge_brutuses.size] = brutus;
            }
        }
    }

    return a_bridge_brutuses;
}

brutus_despawn_manager()
{
    level notify( "brutus_despawn_manager" );
    level endon( "brutus_despawn_manager" );
    level endon( "bridge_empty" );
    e_gg_zone = getent( "zone_golden_gate_bridge", "targetname" );

    while ( true )
    {
        b_is_time_to_despawn = 0;

        while ( !b_is_time_to_despawn )
        {
            b_is_time_to_despawn = 1;
            players = getplayers();

            foreach ( player in players )
            {
                if ( isdefined( player ) && player istouching( e_gg_zone ) && !player.afterlife && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
                    b_is_time_to_despawn = 0;
            }

            wait 0.1;
        }

        zombies = getaispeciesarray( "axis", "all" );

        for ( i = 0; i < zombies.size; i++ )
        {
            if ( isdefined( zombies[i].is_brutus ) && zombies[i].is_brutus && ( isdefined( zombies[i].is_bridge_brutus ) && zombies[i].is_bridge_brutus ) )
                level thread brutus_temp_despawn( zombies[i], "bridge_empty", "bring_bridge_brutuses_back" );
        }

        b_is_time_to_bring_back = 0;

        while ( !b_is_time_to_bring_back )
        {
            b_is_time_to_bring_back = 0;
            players = getplayers();

            foreach ( player in players )
            {
                if ( isdefined( player ) && player istouching( e_gg_zone ) && !player.afterlife && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
                    b_is_time_to_bring_back = 1;
            }

            wait 0.1;
        }

        level notify( "bring_bridge_brutuses_back" );
    }
}

get_bridge_brutus_count()
{
    n_touching_count = 0;
    e_gg_zone = getent( "zone_golden_gate_bridge", "targetname" );
    zombies = getaispeciesarray( "axis", "all" );

    for ( i = 0; i < zombies.size; i++ )
    {
        if ( isdefined( zombies[i].is_brutus ) && zombies[i].is_brutus )
        {
            brutus = zombies[i];

            if ( brutus istouching( e_gg_zone ) )
                n_touching_count++;
        }
    }

    return n_touching_count;
}

clean_up_bridge_brutuses()
{
    zombies = getaispeciesarray( "axis", "all" );

    for ( i = 0; i < zombies.size; i++ )
    {
        if ( isdefined( zombies[i].is_brutus ) && zombies[i].is_brutus && ( isdefined( zombies[i].is_bridge_brutus ) && zombies[i].is_bridge_brutus ) )
        {
            brutus = zombies[i];
            brutus dodamage( 10000, brutus.origin );
        }
    }
}

spin_while_falling()
{
    self endon( "movedone" );

    while ( true )
    {
        self.angles += vectorscale( ( 0, 1, 0 ), 4.0 );
        wait 0.05;
    }
}

manage_electric_chairs()
{
    level notify( "manage_electric_chairs" );
    level endon( "manage_electric_chairs" );
    n_chairs_wait = 60;

    while ( true )
    {
        flag_wait( "plane_approach_bridge" );

        for ( i = 1; i < 5; i++ )
        {
            str_trigger_targetname = "trigger_electric_chair_" + i;
            t_electric_chair = getent( str_trigger_targetname, "targetname" );

            if ( isdefined( level.electric_chair_trigger_thread_custom_func ) )
                t_electric_chair thread [[ level.electric_chair_trigger_thread_custom_func ]]( i );
            else
                t_electric_chair thread electric_chair_trigger_thread( i );

            t_electric_chair setcursorhint( "HINT_NOICON" );
            t_electric_chair sethintstring( &"ZM_PRISON_ELECTRIC_CHAIR_ACTIVATE" );
            t_electric_chair usetriggerrequirelookat();
        }

        if ( level.final_flight_activated )
        {
            level.revive_trigger_should_ignore_sight_checks = maps\mp\zm_prison_sq_final::revive_trigger_should_ignore_sight_checks;

            for ( j = 0; j < level.final_flight_players.size; j++ )
            {
                m_electric_chair = getent( "electric_chair_" + ( j + 1 ), "targetname" );
                corpse = level.final_flight_players[j].e_afterlife_corpse;
                corpse linkto( m_electric_chair, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
                corpse maps\mp\zombies\_zm_clone::clone_animate( "chair" );
                wait 1;
                corpse.revivetrigger unlink();
                corpse.revivetrigger.origin = m_electric_chair.origin + ( 64, 0, 32 );
/#
                corpse.revivetrigger thread print3d_ent( "revivetrigger" );
#/
            }

            for ( j = 1; j < 5; j++ )
            {
                str_trigger_targetname = "trigger_electric_chair_" + j;
                t_electric_chair = getent( str_trigger_targetname, "targetname" );
                t_electric_chair trigger_off();
            }

            while ( flag( "plane_approach_bridge" ) )
                wait 1;
        }
        else
        {
            for ( i = 1; i < 5; i++ )
            {
                m_electric_chair = getent( "electric_chair_" + i, "targetname" );
                m_electric_chair hide();
                str_trigger_targetname = "trigger_electric_chair_" + i;
                t_electric_chair = getent( str_trigger_targetname, "targetname" );
                t_electric_chair trigger_off();
            }

            flag_wait( "plane_crashed" );
            wait( n_chairs_wait );
            exploder( 666 );

            for ( i = 1; i < 5; i++ )
            {
                m_electric_chair = getent( "electric_chair_" + i, "targetname" );
                m_electric_chair show();
                m_electric_chair thread snddelayedchairaudio( i );
                str_trigger_targetname = "trigger_electric_chair_" + i;
                t_electric_chair = getent( str_trigger_targetname, "targetname" );
                t_electric_chair trigger_on();
            }

            wait 3;
            electric_chair_vo();
            wait 6;
        }
    }
}

snddelayedchairaudio( i )
{
    wait( i / 10 );
    self playsound( "zmb_quest_electricchair_spawn" );
}

electric_chair_trigger_thread( chair_number )
{
    level notify( "electric_chair_trigger_thread_" + chair_number );
    level endon( "electric_chair_trigger_thread_" + chair_number );
    m_electric_chair = getent( "electric_chair_" + chair_number, "targetname" );
    n_effects_wait_1 = 4;
    n_effects_wait_2 = 0.15;
    n_effects_wait_3 = 2;
    n_effects_wait_4 = 2;
    n_effects_duration = n_effects_wait_1 + n_effects_wait_2 + n_effects_wait_3 + n_effects_wait_4;

    while ( true )
    {
        self waittill( "trigger", e_triggerer );

        character_name = e_triggerer.character_name;

        if ( isplayer( e_triggerer ) && is_player_valid( e_triggerer ) )
        {
            e_triggerer enableinvulnerability();
            self sethintstring( "" );
            self trigger_off();
            flag_set( "plane_trip_to_nml_successful" );

            if ( level.characters_in_nml.size == 1 )
                clean_up_bridge_brutuses();

            v_origin = m_electric_chair gettagorigin( "seated" ) + ( 10, 0, -40 );
            v_seated_angles = m_electric_chair gettagangles( "seated" );
            m_linkpoint = spawn_model( "tag_origin", v_origin, v_seated_angles );

            if ( isdefined( level.electric_chair_player_thread_custom_func ) )
                e_triggerer thread [[ level.electric_chair_player_thread_custom_func ]]( m_linkpoint, chair_number, n_effects_duration );
            else
                e_triggerer thread electric_chair_player_thread( m_linkpoint, chair_number, n_effects_duration );

            chair_corpse = e_triggerer maps\mp\zombies\_zm_clone::spawn_player_clone( e_triggerer, e_triggerer.origin, undefined );
            chair_corpse linkto( m_electric_chair, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
            chair_corpse.ignoreme = 1;
            chair_corpse show();
            chair_corpse detachall();
            chair_corpse setvisibletoall();
            chair_corpse setinvisibletoplayer( e_triggerer );
            chair_corpse maps\mp\zombies\_zm_clone::clone_animate( "chair" );

            if ( isdefined( e_triggerer ) )
                e_triggerer setclientfieldtoplayer( "rumble_electric_chair", 1 );

            wait( n_effects_wait_1 );
            m_fx_1 = spawn_model( "tag_origin", ( -516.883, -3912.04, -7494.9 ), vectorscale( ( 0, 1, 0 ), 180.0 ) );
            m_fx_2 = spawn_model( "tag_origin", ( -517.024, -3252.66, -7496.2 ), ( 0, 0, 0 ) );
            level setclientfield( "scripted_lightning_flash", 1 );
            wait( n_effects_wait_2 );
            playfxontag( level._effect["fx_alcatraz_lightning_finale"], m_fx_1, "tag_origin" );
            playfxontag( level._effect["fx_alcatraz_lightning_finale"], m_fx_2, "tag_origin" );
            m_fx_3 = spawn_model( "tag_origin", ( -753.495, -3092.62, -8416.6 ), vectorscale( ( 1, 0, 0 ), 270.0 ) );
            playfxontag( level._effect["fx_alcatraz_lightning_wire"], m_fx_3, "tag_origin" );
            wait( n_effects_wait_3 );
            m_electric_chair play_fx( "fx_alcatraz_elec_chair", m_electric_chair.origin, m_electric_chair.angles, "bridge_empty" );

            if ( isdefined( e_triggerer ) )
                e_triggerer setclientfieldtoplayer( "rumble_electric_chair", 2 );

            wait( n_effects_wait_4 );
            playfxontag( level._effect["fx_alcatraz_afterlife_zmb_tport"], m_electric_chair, "tag_origin" );

            if ( isdefined( e_triggerer ) )
                e_triggerer playsoundtoplayer( "zmb_afterlife_death", e_triggerer );

            chair_corpse delete();

            if ( level.characters_in_nml.size == 1 )
                clean_up_bridge_brutuses();

            if ( isinarray( level.characters_in_nml, character_name ) )
                arrayremovevalue( level.characters_in_nml, character_name );

            m_fx_1 delete();
            m_fx_2 delete();
            self sethintstring( &"ZM_PRISON_ELECTRIC_CHAIR_ACTIVATE" );
            self trigger_on();
        }
    }
}

electric_chair_player_thread( m_linkpoint, chair_number, n_effects_duration )
{
    self endon( "death_or_disconnect" );
    e_home_telepoint = getstruct( "home_telepoint_" + chair_number, "targetname" );
    e_corpse_location = getstruct( "corpse_starting_point_" + chair_number, "targetname" );
    self disableweapons();
    self enableinvulnerability();
    self setstance( "stand" );
    self allowstand( 1 );
    self allowcrouch( 0 );
    self allowprone( 0 );
    self playerlinktodelta( m_linkpoint, "tag_origin", 1, 20, 20, 20, 20 );
    self setplayerangles( m_linkpoint.angles );
    self playsoundtoplayer( "zmb_electric_chair_2d", self );
    self do_player_general_vox( "quest", "chair_electrocution", undefined, 100 );
    self ghost();
    self.ignoreme = 1;
    self.dontspeak = 1;
    self setclientfieldtoplayer( "isspeaking", 1 );
    wait( n_effects_duration - 2 );

    switch ( self.character_name )
    {
        case "Arlington":
            self playsoundontag( "vox_plr_3_arlington_electrocution_0", "J_Head" );
            break;
        case "Sal":
            self playsoundontag( "vox_plr_1_sal_electrocution_0", "J_Head" );
            break;
        case "Billy":
            self playsoundontag( "vox_plr_2_billy_electrocution_0", "J_Head" );
            break;
        case "Finn":
            self playsoundontag( "vox_plr_0_finn_electrocution_0", "J_Head" );
            break;
    }

    wait 2;
    level.zones["zone_golden_gate_bridge"].is_enabled = 1;
    level.zones["zone_golden_gate_bridge"].is_spawning_allowed = 1;
    self.keep_perks = 1;
    self disableinvulnerability();
    self.afterlife = 1;
    self thread afterlife_laststand( 1 );
    self unlink();
    self setstance( "stand" );

    self waittill( "player_fake_corpse_created" );

    self thread track_player_completed_cycle();
    trace_start = e_corpse_location.origin + vectorscale( ( 0, 0, 1 ), 100.0 );
    trace_end = e_corpse_location.origin + vectorscale( ( 0, 0, -1 ), 100.0 );
    corpse_trace = bullettrace( trace_start, trace_end, 0, self.e_afterlife_corpse );
    self.e_afterlife_corpse.origin = corpse_trace["position"];
    self setorigin( e_home_telepoint.origin );
    self enableweapons();
    self setclientfieldtoplayer( "rumble_electric_chair", 0 );

    if ( level.n_quest_iteration_count == 2 )
    {
        self waittill( "player_revived" );

        wait 1;
        self do_player_general_vox( "quest", "start_2", undefined, 100 );
    }
}

track_player_completed_cycle()
{
    self endon( "disconnect" );

    self.e_afterlife_corpse waittill( "death" );

    self notify( "player_completed_cycle" );
    level notify( "someone_completed_quest_cycle" );
}

reset_plane_hint_string( player )
{
    if ( isdefined( self.stub ) )
    {
/#
        println( "Error: This should have been handled by the craftables callback" );
#/
    }
    else
        self.fly_trigger sethintstring( &"ZM_PRISON_PLANE_BEGIN_TAKEOFF" );
}

play_fx( str_fx, v_origin, v_angles, time_to_delete_or_notify, b_link_to_self, str_tag, b_no_cull )
{
    if ( ( !isdefined( time_to_delete_or_notify ) || !isstring( time_to_delete_or_notify ) && time_to_delete_or_notify == -1 ) && ( isdefined( b_link_to_self ) && b_link_to_self ) && isdefined( str_tag ) )
    {
        playfxontag( getfx( str_fx ), self, str_tag );
        return self;
    }
    else
    {
        m_fx = spawn_model( "tag_origin", v_origin, v_angles );

        if ( isdefined( b_link_to_self ) && b_link_to_self )
        {
            if ( isdefined( str_tag ) )
                m_fx linkto( self, str_tag, ( 0, 0, 0 ), ( 0, 0, 0 ) );
            else
                m_fx linkto( self );
        }

        if ( isdefined( b_no_cull ) && b_no_cull )
            m_fx setforcenocull();

        playfxontag( getfx( str_fx ), m_fx, "tag_origin" );
        m_fx thread _play_fx_delete( self, time_to_delete_or_notify );
        return m_fx;
    }
}

spawn_model( model_name, origin, angles, n_spawnflags )
{
    if ( !isdefined( n_spawnflags ) )
        n_spawnflags = 0;

    if ( !isdefined( origin ) )
        origin = ( 0, 0, 0 );

    model = spawn( "script_model", origin, n_spawnflags );
    model setmodel( model_name );

    if ( isdefined( angles ) )
        model.angles = angles;

    return model;
}

getfx( fx )
{
    assert( isdefined( level._effect[fx] ), "Fx " + fx + " is not defined in level._effect." );
    return level._effect[fx];
}

_play_fx_delete( ent, time_to_delete_or_notify )
{
    if ( !isdefined( time_to_delete_or_notify ) )
        time_to_delete_or_notify = -1;

    if ( isstring( time_to_delete_or_notify ) )
        ent waittill_either( "death", time_to_delete_or_notify );
    else if ( time_to_delete_or_notify > 0 )
        ent waittill_notify_or_timeout( "death", time_to_delete_or_notify );
    else
        ent waittill( "death" );

    if ( isdefined( self ) )
        self delete();
}

player_disconnect_watcher()
{
    if ( isdefined( level.player_disconnect_watcher_custom_func ) )
    {
        self thread [[ level.player_disconnect_watcher_custom_func ]]();
        return;
    }

    self notify( "disconnect_watcher" );
    self endon( "disconnect_watcher" );
    level endon( "bridge_empty" );
/#
    iprintlnbold( "player_disconnect_watcher" );
#/
    if ( !isdefined( self.character_name ) )
        wait 0.1;

    character_name = self.character_name;

    self waittill( "disconnect" );
/#
    iprintlnbold( character_name + " disconnected!" );
#/
    if ( isinarray( level.characters_in_nml, character_name ) )
    {
        arrayremovevalue( level.characters_in_nml, character_name );
        flag_set( "spawn_zombies" );
        level.brutus_respawn_after_despawn = 1;
    }
}

player_death_watcher()
{
    if ( isdefined( level.player_death_watcher_custom_func ) )
    {
        self thread [[ level.player_death_watcher_custom_func ]]();
        return;
    }

    self notify( "player_death_watcher" );
    self endon( "player_death_watcher" );
    level endon( "bridge_empty" );
/#
    iprintlnbold( "player_death_watcher" );
#/
    e_gg_zone = getent( "zone_golden_gate_bridge", "targetname" );
    nml_trip_is_over = 0;

    while ( !nml_trip_is_over )
    {
        level waittill( "start_of_round" );

        nml_trip_is_over = 1;
        players = getplayers();

        foreach ( player in players )
        {
            if ( player istouching( e_gg_zone ) || isdefined( player.on_a_plane ) && player.on_a_plane )
            {
                nml_trip_is_over = 0;

                if ( !isinarray( level.characters_in_nml, player.character_name ) )
                    level.characters_in_nml[level.characters_in_nml.size] = player.character_name;
            }
        }
    }

    if ( isdefined( level.characters_in_nml ) )
    {
        for ( i = 0; i < level.characters_in_nml.size; i++ )
        {
            character_name = level.characters_in_nml[i];

            if ( isinarray( level.characters_in_nml, character_name ) )
                arrayremovevalue( level.characters_in_nml, character_name );
        }
    }

    flag_set( "spawn_zombies" );
    level.brutus_respawn_after_despawn = 1;
}

array_set_visible_to_all( a_ents, is_visible )
{
    if ( is_visible )
    {
        foreach ( ent in a_ents )
            ent setvisibletoall();
    }
    else
    {
        foreach ( ent in a_ents )
            ent setinvisibletoall();
    }
}

warden_fence_hotjoin_handler()
{
    while ( true )
    {
        level waittill( "warden_fence_up" );

        stop_exploder( 2000 );
        exploder( 2000 );
        wait 0.05;
    }
}
