// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_ai_ghost_ffotd;
#include maps\mp\zombies\_zm_ai_ghost;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_weap_slowgun;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weap_time_bomb;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_ai_basic;

precache()
{

}

#using_animtree("zm_buried_ghost");

init_animtree()
{
    scriptmodelsuseanimtree( #animtree );
}

precache_fx()
{
    if ( !isdefined( level.ghost_effects ) )
    {
        level.ghost_effects = [];
        level.ghost_effects[1] = loadfx( "maps/zombie_buried/fx_buried_ghost_death" );
        level.ghost_effects[2] = loadfx( "maps/zombie_buried/fx_buried_ghost_drain" );
        level.ghost_effects[3] = loadfx( "maps/zombie_buried/fx_buried_ghost_spawn" );
        level.ghost_effects[4] = loadfx( "maps/zombie_buried/fx_buried_ghost_trail" );
        level.ghost_effects[5] = loadfx( "maps/zombie_buried/fx_buried_ghost_evaporation" );
        level.ghost_impact_effects[1] = loadfx( "maps/zombie_buried/fx_buried_ghost_impact" );
    }
}

init()
{
    maps\mp\zombies\_zm_ai_ghost_ffotd::ghost_init_start();
    register_client_fields();
    flag_init( "spawn_ghosts" );

    if ( !init_ghost_spawners() )
        return;

    init_ghost_zone();
    init_ghost_sounds();
    init_ghost_script_move_path_data();
    level.zombie_ai_limit_ghost = 4;
    level.zombie_ai_limit_ghost_per_player = 1;
    level.zombie_ghost_count = 0;
    level.ghost_health = 100;
    level.zombie_ghost_round_states = spawnstruct();
    level.zombie_ghost_round_states.any_player_in_ghost_zone = 0;
    level.zombie_ghost_round_states.active_zombie_locations = [];
    level.is_ghost_round_started = ::is_ghost_round_started;
    level.zombie_ghost_round_states.is_started = 0;
    level.zombie_ghost_round_states.is_first_ghost_round_finished = 0;
    level.zombie_ghost_round_states.current_ghost_round_number = 0;
    level.zombie_ghost_round_states.next_ghost_round_number = 0;
    level.zombie_ghost_round_states.presentation_stage_1_started = 0;
    level.zombie_ghost_round_states.presentation_stage_2_started = 0;
    level.zombie_ghost_round_states.presentation_stage_3_started = 0;
    level.zombie_ghost_round_states.is_teleporting = 0;
    level.zombie_ghost_round_states.round_count = 0;
    level thread ghost_round_presentation_think();

    if ( isdefined( level.ghost_round_think_override_func ) )
        level thread [[ level.ghost_round_think_override_func ]]();
    else
        level thread ghost_round_think();

    level thread player_in_ghost_zone_monitor();

    if ( isdefined( level.ghost_zone_spawning_think_override_func ) )
        level thread [[ level.ghost_zone_spawning_think_override_func ]]();
    else
        level thread ghost_zone_spawning_think();

    level thread ghost_vox_think();
    init_time_bomb_ghost_rounds();
/#
    level.force_no_ghost = 0;
    level.ghost_devgui_toggle_no_ghost = ::devgui_toggle_no_ghost;
    level.ghost_devgui_warp_to_mansion = ::devgui_warp_to_mansion;
#/
    maps\mp\zombies\_zm_ai_ghost_ffotd::ghost_init_end();
}

init_ghost_spawners()
{
    level.ghost_spawners = getentarray( "ghost_zombie_spawner", "script_noteworthy" );

    if ( level.ghost_spawners.size == 0 )
        return false;

    array_thread( level.ghost_spawners, ::add_spawn_function, maps\mp\zombies\_zm_ai_ghost::prespawn );

    foreach ( spawner in level.ghost_spawners )
    {
        if ( spawner.targetname == "female_ghost" )
            level.female_ghost_spawner = spawner;
    }

    return true;
}

init_ghost_script_move_path_data()
{
    level.ghost_script_move_sin = [];

    for ( degree = 0; degree < 360; degree += 15 )
        level.ghost_script_move_sin[level.ghost_script_move_sin.size] = sin( degree );
}

init_ghost_sounds()
{
    level.ghost_vox = [];
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_0";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_1";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_2";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_3";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_4";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_5";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_6";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_7";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_8";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_9";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_10";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_11";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_12";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_13";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_14";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_15";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_16";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_17";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_18";
    level.ghost_vox[level.ghost_vox.size] = "vox_fg_ghost_haunt_19";
}

init_ghost_zone()
{
    level.ghost_start_area = getent( "ghost_start_area", "targetname" );
    level.ghost_zone_door_clips = getentarray( "ghost_zone_door_clip", "targetname" );
    enable_ghost_zone_door_ai_clips();
    level.ghost_zone_start_lower_locations = getstructarray( "ghost_zone_start_lower_location", "targetname" );
    level.ghost_drop_down_locations = getstructarray( "ghost_start_zone_spawners", "targetname" );
    level.ghost_front_standing_locations = getstructarray( "ghost_front_standing_location", "targetname" );
    level.ghost_back_standing_locations = getstructarray( "ghost_back_standing_location", "targetname" );
    level.ghost_front_flying_out_path_starts = getstructarray( "ghost_front_flying_out_path_start", "targetname" );
    level.ghost_back_flying_out_path_starts = getstructarray( "ghost_back_flying_out_path_start", "targetname" );
    level.ghost_gazebo_pit_volume = getent( "sloth_pack_volume", "targetname" );
    level.ghost_gazebo_pit_perk_pos = getstruct( "ghost_gazebo_pit_perk_pos", "targetname" );
    level.ghost_entry_room_to_mansion = "ghost_to_maze_zone_1";
    level.ghost_entry_room_to_maze = "ghost_to_maze_zone_5";
    level.ghost_rooms = [];
    a_rooms = getentarray( "ghost_zone", "script_noteworthy" );

    foreach ( room in a_rooms )
    {
        str_targetname = room.targetname;

        if ( !isdefined( level.ghost_rooms[str_targetname] ) )
        {
            level.ghost_rooms[str_targetname] = spawnstruct();
            level.ghost_rooms[str_targetname].ghost_spawn_locations = [];
            level.ghost_rooms[str_targetname].volumes = [];
            level.ghost_rooms[str_targetname].name = str_targetname;

            if ( issubstr( str_targetname, "from_maze" ) )
                level.ghost_rooms[str_targetname].from_maze = 1;
            else if ( issubstr( str_targetname, "to_maze" ) )
                level.ghost_rooms[str_targetname].to_maze = 1;
        }

        assert( isdefined( room.target ), "ghost zone with targetname '" + str_targetname + "' is missing spawner target! This is used to pair zones with spawners." );
        a_ghost_spawn_locations = getstructarray( room.target, "targetname" );
        level.ghost_rooms[str_targetname].ghost_spawn_locations = arraycombine( a_ghost_spawn_locations, level.ghost_rooms[str_targetname].ghost_spawn_locations, 0, 0 );
        level.ghost_rooms[str_targetname].volumes[level.ghost_rooms[str_targetname].volumes.size] = room;

        if ( isdefined( room.script_string ) )
            level.ghost_rooms[str_targetname].next_room_names = strtok( room.script_string, " " );

        if ( isdefined( room.script_parameters ) )
            level.ghost_rooms[str_targetname].previous_room_names = strtok( room.script_parameters, " " );

        if ( isdefined( room.script_flag ) )
            level.ghost_rooms[str_targetname].flag = room.script_flag;
    }
}

register_client_fields()
{
    registerclientfield( "actor", "ghost_impact_fx", 12000, 1, "int" );
    registerclientfield( "actor", "ghost_fx", 12000, 3, "int" );
    registerclientfield( "actor", "sndGhostAudio", 12000, 3, "int" );
    registerclientfield( "scriptmover", "ghost_fx", 12000, 3, "int" );
    registerclientfield( "scriptmover", "sndGhostAudio", 12000, 3, "int" );
    registerclientfield( "world", "ghost_round_light_state", 12000, 1, "int" );
}

is_player_fully_claimed( player )
{
    result = 0;

    if ( isdefined( player.ghost_count ) && player.ghost_count >= level.zombie_ai_limit_ghost_per_player )
        result = 1;

    return result;
}

ghost_zone_spawning_think()
{
    level endon( "intermission" );

    if ( isdefined( level.intermission ) && level.intermission )
        return;

    if ( !isdefined( level.female_ghost_spawner ) )
    {
/#
        assertmsg( "No female ghost spawner in the map.  Check to see if the zone is active and if it's pointing to spawners." );
#/
        return;
    }

    while ( true )
    {
        if ( level.zombie_ghost_count >= level.zombie_ai_limit_ghost )
        {
            wait 0.1;
            continue;
        }

        valid_player_count = 0;
        valid_players = [];

        while ( valid_player_count < 1 )
        {
            players = getplayers();
            valid_player_count = 0;

            foreach ( player in players )
            {
                if ( is_player_valid( player ) && !is_player_fully_claimed( player ) )
                {
                    if ( isdefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone || is_ghost_round_started() && ( isdefined( level.zombie_ghost_round_states.any_player_in_ghost_zone ) && level.zombie_ghost_round_states.any_player_in_ghost_zone ) )
                    {
                        valid_player_count++;
                        valid_players[valid_players.size] = player;
                    }
                }
            }

            wait 0.1;
        }

        valid_players = array_randomize( valid_players );
        spawn_point = get_best_spawn_point( valid_players[0] );

        if ( !isdefined( spawn_point ) )
        {
            wait 0.1;
            continue;
        }
/#
        if ( isdefined( level.force_no_ghost ) && level.force_no_ghost )
        {
            wait 0.1;
            continue;
        }
#/
        ghost_ai = undefined;

        if ( isdefined( level.female_ghost_spawner ) )
            ghost_ai = spawn_zombie( level.female_ghost_spawner, level.female_ghost_spawner.targetname, spawn_point );
        else
        {
/#
            assertmsg( "No female ghost spawner in the map." );
#/
            return;
        }

        if ( isdefined( ghost_ai ) )
        {
            ghost_ai setclientfield( "ghost_fx", 3 );
            ghost_ai.spawn_point = spawn_point;
            ghost_ai.is_ghost = 1;
            ghost_ai.is_spawned_in_ghost_zone = 1;
            ghost_ai.find_target = 1;
            level.zombie_ghost_count++;
/#
            ghost_print( "ghost total " + level.zombie_ghost_count );
#/
        }
        else
        {
/#
            assertmsg( "Female ghost: failed spawn" );
#/
            return;
        }

        wait 0.1;
    }
}

is_player_in_ghost_room( player, room )
{
    foreach ( volume in room.volumes )
    {
        if ( player istouching( volume ) )
            return true;
    }

    return false;
}

is_player_in_ghost_rooms( player, room_names )
{
    result = 0;

    if ( isdefined( room_names ) )
    {
        foreach ( room_name in room_names )
        {
            next_room = level.ghost_rooms[room_name];

            if ( is_player_in_ghost_room( player, next_room ) )
            {
                player.current_ghost_room_name = next_room.name;
                result = 1;
                break;
            }
        }
    }

    return result;
}

player_in_ghost_zone_monitor()
{
    level endon( "intermission" );

    if ( level.intermission )
        return;

    while ( true )
    {
        if ( isdefined( level.zombie_ghost_round_states.any_player_in_ghost_zone ) && level.zombie_ghost_round_states.any_player_in_ghost_zone )
        {
            players = getplayers();

            foreach ( player in players )
            {
                if ( is_player_valid( player ) && ( isdefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone ) )
                {
                    if ( isdefined( player.current_ghost_room_name ) )
                    {
                        current_room = level.ghost_rooms[player.current_ghost_room_name];
/#
                        foreach ( ghost_location in current_room.ghost_spawn_locations )
                            draw_debug_star( ghost_location.origin, ( 0, 0, 1 ), 2 );

                        foreach ( volume in current_room.volumes )
                            draw_debug_box( volume.origin, vectorscale( ( -1, -1, -1 ), 5.0 ), vectorscale( ( 1, 1, 1 ), 5.0 ), volume.angles[1], vectorscale( ( 0, 1, 0 ), 0.5 ), 2 );
#/
                        if ( is_player_in_ghost_room( player, current_room ) )
                        {
                            player.current_ghost_room_name = current_room.name;
                            continue;
                        }

                        if ( is_player_in_ghost_rooms( player, current_room.next_room_names ) )
                            continue;

                        if ( is_player_in_ghost_rooms( player, current_room.previous_room_names ) )
                            continue;
                    }
                    else
                        player.current_ghost_room_name = level.ghost_entry_room_to_mansion;
                }
            }
        }

        wait 0.1;
    }
}

is_any_player_near_point( target, spawn_pos )
{
    players = getplayers();

    foreach ( player in players )
    {
        if ( target != player && is_player_valid( player ) )
        {
            dist_squared = distancesquared( player.origin, spawn_pos );

            if ( dist_squared < 84 * 84 )
                return true;
        }
    }

    return false;
}

is_in_start_area()
{
    if ( isdefined( level.ghost_start_area ) && self istouching( level.ghost_start_area ) )
        return true;

    return false;
}

get_best_spawn_point( player )
{
    spawn_point = undefined;

    if ( isdefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone )
    {
        if ( isdefined( player.current_ghost_room_name ) )
        {
            min_distance_squared = 9600 * 9600;
            selected_locations = [];
            current_ghost_room_name = player.current_ghost_room_name;

            foreach ( ghost_location in level.ghost_rooms[current_ghost_room_name].ghost_spawn_locations )
            {
                player_eye_pos = player geteyeapprox();
                line_of_sight = sighttracepassed( player_eye_pos, ghost_location.origin, 0, self );

                if ( !( isdefined( line_of_sight ) && line_of_sight ) )
                {
                    if ( !self is_any_player_near_point( player, ghost_location.origin ) )
                        selected_locations[selected_locations.size] = ghost_location;
                }
            }

            if ( selected_locations.size > 0 )
            {
                selected_location = selected_locations[randomint( selected_locations.size )];
/#
                draw_debug_line( player.origin, selected_location.origin, ( 0, 1, 0 ), 10, 0 );
#/
                return selected_location;
            }
        }
    }
    else if ( is_ghost_round_started() && ( isdefined( level.zombie_ghost_round_states.any_player_in_ghost_zone ) && level.zombie_ghost_round_states.any_player_in_ghost_zone ) )
    {
        if ( isdefined( player.current_ghost_room_name ) && player.current_ghost_room_name == level.ghost_entry_room_to_maze )
        {
            random_index = randomint( level.ghost_back_standing_locations.size );
            return level.ghost_back_standing_locations[random_index];
        }
        else if ( player is_in_start_area() )
        {
            random_index = randomint( level.ghost_zone_start_lower_locations.size );
            return level.ghost_zone_start_lower_locations[random_index];
        }
        else
        {
            random_index = randomint( level.ghost_front_standing_locations.size );
            return level.ghost_front_standing_locations[random_index];
        }
    }

    return undefined;
}

check_players_in_ghost_zone()
{
    result = 0;
    players = getplayers();

    foreach ( player in players )
    {
        if ( is_player_valid( player, 0, 1 ) && player_in_ghost_zone( player ) )
            result = 1;
    }

    return result;
}

player_in_ghost_zone( player )
{
    result = 0;

    if ( isdefined( level.is_player_in_ghost_zone ) )
        result = [[ level.is_player_in_ghost_zone ]]( player );

    player.is_in_ghost_zone = result;
    return result;
}

ghost_vox_think()
{
    level endon( "end_game" );
    level endon( "intermission" );

    if ( isdefined( level.intermission ) && level.intermission )
        return;

    while ( true )
    {
        ghosts = get_current_ghosts();

        if ( ghosts.size > 0 )
        {
            foreach ( ghost in ghosts )
            {
                if ( isdefined( ghost.favoriteenemy ) && !( isdefined( ghost.favoriteenemy.ghost_talking ) && ghost.favoriteenemy.ghost_talking ) )
                    ghost thread ghost_talk_to_target( ghost.favoriteenemy );
            }
        }

        wait( randomintrange( 2, 6 ) );
    }
}

ghost_talk_to_target( player )
{
    self endon( "death" );
    level endon( "intermission" );
    vox_index = randomint( level.ghost_vox.size );
    vox_line = level.ghost_vox[vox_index];
    self playsoundtoplayer( vox_line, player );
    player.ghost_talking = 1;
    wait 6;
    player.ghost_talking = 0;
}

prespawn()
{
    self endon( "death" );
    level endon( "intermission" );
    self maps\mp\zombies\_zm_ai_ghost_ffotd::prespawn_start();
    self.startinglocation = self.origin;
    self.animname = "ghost_zombie";
    self.audio_type = "ghost";
    self.has_legs = 1;
    self.no_gib = 1;
    self.ignore_enemy_count = 1;
    self.ignore_equipment = 1;
    self.ignore_claymore = 0;
    self.force_killable_timer = 0;
    self.noplayermeleeblood = 1;
    self.paralyzer_hit_callback = ::paralyzer_callback;
    self.paralyzer_slowtime = 0;
    self.paralyzer_score_time_ms = gettime();
    self.ignore_slowgun_anim_rates = undefined;
    self.reset_anim = ::ghost_reset_anim;
    self.custom_springpad_fling = ::ghost_springpad_fling;
    self.bookcase_entering_callback = ::bookcase_entering_callback;
    self.ignore_subwoofer = 1;
    self.ignore_headchopper = 1;
    self.ignore_spring_pad = 1;
    recalc_zombie_array();
    self setphysparams( 15, 0, 72 );
    self.cant_melee = 1;

    if ( isdefined( self.spawn_point ) )
    {
        spot = self.spawn_point;

        if ( !isdefined( spot.angles ) )
            spot.angles = ( 0, 0, 0 );

        self forceteleport( spot.origin, spot.angles );
    }

    self set_zombie_run_cycle( "run" );
    self setanimstatefromasd( "zm_move_run" );
    self.actor_damage_func = ::ghost_damage_func;
    self.deathfunction = ::ghost_death_func;
    self.maxhealth = level.ghost_health;
    self.health = level.ghost_health;
    self.zombie_init_done = 1;
    self notify( "zombie_init_done" );
    self.allowpain = 0;
    self.ignore_nuke = 1;
    self animmode( "normal" );
    self orientmode( "face enemy" );
    self bloodimpact( "none" );
    self disableaimassist();
    self.forcemovementscriptstate = 0;
    self maps\mp\zombies\_zm_spawner::zombie_setup_attack_properties();

    if ( isdefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
        self.pathenemyfightdist = 0;

    self maps\mp\zombies\_zm_spawner::zombie_complete_emerging_into_playable_area();
    self setfreecameralockonallowed( 0 );
    self.startinglocation = self.origin;

    if ( isdefined( level.ghost_custom_think_logic ) )
        self [[ level.ghost_custom_think_logic ]]();

    self.bad_path_failsafe = maps\mp\zombies\_zm_ai_ghost_ffotd::ghost_bad_path_failsafe;
    self thread ghost_think();
    self.attack_time = 0;
    self.ignore_inert = 1;
    self.subwoofer_burst_func = ::subwoofer_burst_func;
    self.subwoofer_fling_func = ::subwoofer_fling_func;
    self.subwoofer_knockdown_func = ::subwoofer_knockdown_func;
    self maps\mp\zombies\_zm_ai_ghost_ffotd::prespawn_end();
}

bookcase_entering_callback( bookcase_door )
{
    self endon( "death" );

    while ( true )
    {
        if ( isdefined( bookcase_door._door_open ) && bookcase_door._door_open )
        {
            if ( isdefined( bookcase_door.door_moving ) && bookcase_door.door_moving )
            {
                self.need_wait = 1;
                wait 2.1;
                self.need_wait = 0;
            }
            else
                self.need_wait = 0;

            break;
        }
        else
            self.need_wait = 1;

        wait 0.1;
    }
}

ghost_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    if ( sweapon == "equip_headchopper_zm" )
    {
        self.damageweapon_name = sweapon;
        self check_zombie_damage_callbacks( smeansofdeath, shitloc, vpoint, eattacker, idamage );
        self.damageweapon_name = undefined;
    }

    if ( idamage >= self.health )
    {
        self.killed_by = eattacker;
        self thread prepare_to_die();
    }

    self thread set_impact_effect();
    return idamage;
}

set_impact_effect()
{
    self endon( "death" );
    self setclientfield( "ghost_impact_fx", 1 );
    wait_network_frame();
    self setclientfield( "ghost_impact_fx", 0 );
}

prepare_to_die()
{
    qrate = self getclientfield( "anim_rate" );

    if ( qrate < 0.8 )
    {
        self.ignore_slowgun_anim_rates = 1;
        self setclientfield( "anim_rate", 1 );
        qrate = self getclientfield( "anim_rate" );
        self setentityanimrate( qrate );
        self.slowgun_anim_rate = qrate;
        wait_network_frame();
        self setclientfield( "anim_rate", 0.8 );
        qrate = self getclientfield( "anim_rate" );
        self setentityanimrate( qrate );
        wait_network_frame();
        ghost_reset_anim();
    }
}

ghost_reset_anim()
{
    if ( !isdefined( self ) )
        return;

    animstate = self getanimstatefromasd();
    substate = self getanimsubstatefromasd();

    if ( animstate == "zm_death" )
        self setanimstatefromasd( "zm_death_no_restart", substate );
    else
        self maps\mp\zombies\_zm_weap_slowgun::reset_anim();
}

wait_ghost_ghost( time )
{
    wait( time );

    if ( isdefined( self ) )
        self ghost();
}

ghost_death_func()
{
    if ( get_current_ghost_count() == 0 )
        level.ghost_round_last_ghost_origin = self.origin;

    self stoploopsound( 1 );
    self playsound( "zmb_ai_ghost_death" );
    self setclientfield( "ghost_impact_fx", 1 );
    self setclientfield( "ghost_fx", 1 );
    self thread prepare_to_die();

    if ( isdefined( self.extra_custom_death_logic ) )
        self thread [[ self.extra_custom_death_logic ]]();

    qrate = self getclientfield( "anim_rate" );
    self setanimstatefromasd( "zm_death" );
    self thread wait_ghost_ghost( self getanimlengthfromasd( "zm_death", 0 ) );
    maps\mp\animscripts\zm_shared::donotetracks( "death_anim" );

    if ( isdefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
    {
        level.zombie_ghost_count--;

        if ( isdefined( self.favoriteenemy ) )
        {
            if ( isdefined( self.favoriteenemy.ghost_count ) && self.favoriteenemy.ghost_count > 0 )
                self.favoriteenemy.ghost_count--;
        }
    }

    player = undefined;

    if ( is_player_valid( self.attacker ) )
    {
        give_player_rewards( self.attacker );
        player = self.attacker;
    }
    else if ( isdefined( self.attacker ) && is_player_valid( self.attacker.owner ) )
    {
        give_player_rewards( self.attacker.owner );
        player = self.attacker.owner;
    }

    if ( isdefined( player ) )
    {
        player maps\mp\zombies\_zm_stats::increment_client_stat( "buried_ghost_killed", 0 );
        player maps\mp\zombies\_zm_stats::increment_player_stat( "buried_ghost_killed" );
    }

    self delete();
    return 1;
}

subwoofer_burst_func( weapon )
{
    self dodamage( self.health + 666, weapon.origin );
}

subwoofer_fling_func( weapon, fling_vec )
{
    self dodamage( self.health + 666, weapon.origin );
}

subwoofer_knockdown_func( weapon, gib )
{

}

ghost_think()
{
    self endon( "death" );
    level endon( "intermission" );

    if ( isdefined( level.ghost_round_presentation_ghost ) && level.ghost_round_presentation_ghost == self )
        return;

    if ( isdefined( level.ghost_custom_think_func_logic ) )
    {
        shouldwait = self [[ level.ghost_custom_think_func_logic ]]();

        if ( shouldwait )
            self waittill( "ghost_custom_think_done", find_flesh_struct_string );
    }

    self.ignore_slowgun_anim_rates = undefined;
    self maps\mp\zombies\_zm_weap_slowgun::set_anim_rate( 1.0 );
    self setclientfield( "slowgun_fx", 0 );
    self setclientfield( "sndGhostAudio", 1 );
    self init_thinking();

    if ( isdefined( self.need_script_move ) && self.need_script_move )
        self start_script_move();
    else if ( !( isdefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone ) && !( isdefined( self.respawned_by_time_bomb ) && self.respawned_by_time_bomb ) )
        self start_spawn();
    else
        self start_chase();

    if ( isdefined( self.bad_path_failsafe ) )
        self thread [[ self.bad_path_failsafe ]]();

    while ( true )
    {
        switch ( self.state )
        {
            case "script_move_update":
                self script_move_update();
                break;
            case "chase_update":
                self chase_update();
                break;
            case "drain_update":
                self drain_update();
                break;
            case "runaway_update":
                self runaway_update();
                break;
            case "evaporate_update":
                self evaporate_update();
                break;
            case "wait_update":
                self wait_update();
                break;
        }

        wait 0.1;
    }
}

start_spawn()
{
    self animscripted( self.origin, self.angles, "zm_spawn" );
    self maps\mp\animscripts\zm_shared::donotetracks( "spawn_anim" );
    self start_chase();
}

init_thinking()
{
    self thread find_flesh();
}

find_flesh()
{
    self endon( "death" );
    level endon( "intermission" );
    self endon( "stop_find_flesh" );

    if ( isdefined( level.intermission ) && level.intermission )
        return;

    self.nododgemove = 1;
    self.ignore_player = [];
    self zombie_history( "ghost find flesh -> start" );
    self.goalradius = 32;

    while ( true )
    {
        if ( isdefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
        {
            if ( isdefined( self.find_target ) && self.find_target )
            {
                self.favoriteenemy = get_closest_valid_player( self.origin );
                self.find_target = 0;
            }
        }
        else
            self.favoriteenemy = get_closest_valid_player( self.origin );

        if ( isdefined( self.favoriteenemy ) )
            self thread zombie_pathing();
        else if ( isdefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
            self.find_target = 1;

        self.zombie_path_timer = gettime() + randomfloatrange( 1, 3 ) * 1000;

        while ( gettime() < self.zombie_path_timer )
            wait 0.1;

        self notify( "path_timer_done" );
        self zombie_history( "ghost find flesh -> path timer done" );
        debug_print( "Zombie is re-acquiring enemy, ending breadcrumb search" );
        self notify( "zombie_acquire_enemy" );
    }
}

get_closest_valid_player( origin )
{
    valid_player_found = 0;
    players = get_players();

    while ( !valid_player_found )
    {
        player = get_closest_player( origin, players );

        if ( !isdefined( player ) )
            return undefined;

        if ( isdefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
        {
            player_claimed_fully = is_player_fully_claimed( player );

            if ( players.size == 1 && player_claimed_fully )
                return undefined;

            if ( !is_player_valid( player, 1 ) || !is_ghost_round_started() && !( isdefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone ) || player_claimed_fully )
            {
                arrayremovevalue( players, player );
                continue;
            }

            if ( !( isdefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone ) && !player is_in_start_area() )
                self.need_script_move = 1;

            if ( !isdefined( player.ghost_count ) )
                player.ghost_count = 1;
            else
                player.ghost_count += 1;
        }
        else if ( !is_player_valid( player, 1 ) )
        {
            arrayremovevalue( players, player );
            continue;
        }

        return player;
    }
}

get_closest_player( origin, players )
{
    min_length_to_player = 9999999;
    player_to_return = undefined;

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];
        length_to_player = get_path_length_to_enemy( player );

        if ( length_to_player == 0 )
            continue;

        if ( length_to_player < min_length_to_player )
        {
            min_length_to_player = length_to_player;
            player_to_return = player;
        }
    }

    if ( !isdefined( player_to_return ) )
        player_to_return = getclosest( origin, players );

    return player_to_return;
}

does_fall_into_pap_hole()
{
    if ( self istouching( level.ghost_gazebo_pit_volume ) )
    {
        self forceteleport( level.ghost_gazebo_pit_perk_pos.origin, ( 0, 0, 0 ) );
        wait 0.1;
        return true;
    }

    return false;
}

start_script_move()
{
    self.script_mover = spawn( "script_origin", self.origin );
    self.script_mover.angles = self.angles;
    self linkto( self.script_mover );
    self.state = "script_move_update";
    self setclientfield( "ghost_fx", 4 );
    player = self.favoriteenemy;

    if ( is_player_valid( player ) )
    {
        start_location = undefined;

        if ( isdefined( player.current_ghost_room_name ) && player.current_ghost_room_name == level.ghost_entry_room_to_maze )
            start_location = level.ghost_back_flying_out_path_starts[0];
        else
            start_location = level.ghost_front_flying_out_path_starts[0];

        self.script_move_target_node = self get_best_flying_target_node( player, start_location.origin );
    }

    self.script_move_sin_index = 0;
}

get_best_flying_target_node( player, start_loc )
{
    nearest_node = getnearestnode( player.origin );
    nodes = getnodesinradiussorted( player.origin, 540, 180, 60, "Path" );

    if ( !isdefined( nearest_node ) && nodes.size > 0 )
        nearest_node = nodes[0];

    selected_node = nearest_node;
    max_distance_squared = 0;
    start_pos = ( player.origin[0], player.origin[1], player.origin[2] + 60 );

    for ( i = nodes.size - 1; i >= 0; i-- )
    {
        node = nodes[i];
        end_pos = ( node.origin[0], node.origin[1], node.origin[2] + 60 );
        line_of_sight = sighttracepassed( start_pos, end_pos, 0, player );

        if ( isdefined( line_of_sight ) && line_of_sight )
        {
            draw_debug_star( node.origin, ( 0, 0, 1 ), 100 );

            if ( is_within_view_2d( node.origin, player.origin, player.angles, 0.86 ) )
            {
                selected_node = node;
                break;
            }

            selected_node = node;
        }
    }

    return selected_node;
}

script_move_update()
{
    if ( isdefined( self.is_traversing ) && self.is_traversing )
        return;

    player = self.favoriteenemy;

    if ( is_player_valid( player ) && isdefined( self.script_move_target_node ) )
    {
        desired_angles = vectortoangles( vectornormalize( player.origin - self.origin ) );
        distance_squared = distancesquared( self.origin, self.script_move_target_node.origin );

        if ( distance_squared < 24 )
        {
            self.script_mover.angles = desired_angles;
            self remove_script_mover();
            wait_network_frame();
            self setclientfield( "ghost_fx", 3 );
            self setclientfield( "sndGhostAudio", 1 );
            wait_network_frame();
            self start_chase();
            return;
        }

        draw_debug_star( self.script_move_target_node.origin, ( 0, 0, 1 ), 1 );
        target_node_pos = self.script_move_target_node.origin + vectorscale( ( 0, 0, 1 ), 36.0 );
        distance_squared_to_target_node_pos = distancesquared( self.origin, target_node_pos );
        moved_distance_during_interval = 80.0;

        if ( distance_squared_to_target_node_pos <= moved_distance_during_interval * moved_distance_during_interval )
        {
            target_point = self.script_move_target_node.origin;
            self.script_mover moveto( target_point, 0.1, 0, 0.1 );

            self.script_mover waittill( "movedone" );

            self.script_mover.angles = desired_angles;
        }
        else
        {
            distance_squared_to_player = distancesquared( self.origin, player.origin );

            if ( distance_squared_to_player < 540 && !( isdefined( self.script_mover.search_target_node_again ) && self.script_mover.search_target_node_again ) )
            {
                self get_best_flying_target_node( player, self.script_move_target_node.origin );
                self.script_mover.search_target_node_again = 1;
            }

            if ( self.script_move_sin_index >= level.ghost_script_move_sin.size )
                self.script_move_sin_index = 0;

            move_dir = target_node_pos - self.origin;
            move_dir = vectornormalize( move_dir );
            target_point = self.origin + move_dir * 800 * 0.1;
            x_offset = level.ghost_script_move_sin[self.script_move_sin_index] * 6;
            z_offset = level.ghost_script_move_sin[self.script_move_sin_index] * 12;
            target_point += ( x_offset, 0, z_offset );
            self.script_move_sin_index++;
            self.script_mover moveto( target_point, 0.1 );
            self.script_mover.angles = desired_angles;
            draw_debug_star( target_point, ( 0, 1, 0 ), 1 );
        }
    }
    else
    {
        self remove_script_mover();
        self start_evaporate( 1 );
    }
}

remove_script_mover()
{
    if ( isdefined( self.script_mover ) )
    {
        self dontinterpolate();
        self unlink();
        self.script_mover delete();
    }
}

start_chase()
{
    self set_zombie_run_cycle( "run" );
    self setanimstatefromasd( "zm_move_run" );
    self.state = "chase_update";
    self setclientfield( "ghost_fx", 4 );
}

chase_update()
{
    if ( isdefined( self.is_traversing ) && self.is_traversing )
        return;

    player = self.favoriteenemy;

    if ( is_player_valid( player ) )
    {
        if ( self should_runaway( player ) )
        {
            self start_runaway();
            return;
        }

        if ( self does_fall_into_pap_hole() )
        {
            self dodamage( self.health + 666, self.origin );
            return;
        }

        if ( self need_wait() )
        {
            self start_wait();
            return;
        }

        ghost_check_point = self.origin + ( 0, 0, 60 );
        player_eye_pos = player geteyeapprox();
        line_of_sight = sighttracepassed( ghost_check_point, player_eye_pos, 0, self );

        if ( isdefined( line_of_sight ) && line_of_sight && can_drain_points( self.origin, player.origin ) )
        {
            self start_drain();
            return;
        }

        distsquared = distancesquared( self.origin, player.origin );

        if ( distsquared > 300 * 300 )
        {
            if ( isdefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone && ( isdefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone ) && isdefined( player.current_ghost_room_name ) )
            {
                current_room = level.ghost_rooms[player.current_ghost_room_name];

                if ( isdefined( current_room.flag ) && current_room.flag == "no_cleanup" || self is_in_close_rooms( current_room ) || self is_in_room( current_room ) && !self is_following_room_path( player, current_room ) )
                    set_chase_status( "run" );
                else
                    self start_evaporate( 1 );
            }
            else
            {
                set_chase_status( "run" );

                if ( distsquared > 9600 * 9600 )
                {
                    teleport_location = level.ghost_front_flying_out_path_starts[0];
                    self forceteleport( teleport_location.origin, ( 0, 0, 0 ) );
                }
            }
        }
        else if ( distsquared > 144 * 144 )
            set_chase_status( "run" );
        else
            set_chase_status( "walk" );
    }
    else
    {
        self set_zombie_run_cycle( "run" );

        if ( self getanimstatefromasd() != "zm_move_run" )
            self setanimstatefromasd( "zm_move_run" );

        self start_runaway();
    }
}

need_wait()
{
    return isdefined( self.need_wait ) && self.need_wait;
}

start_wait()
{
    self setanimstatefromasd( "zm_idle" );
    self setclientfield( "ghost_fx", 4 );
    self.state = "wait_update";
}

wait_update()
{
    if ( isdefined( self.is_traversing ) && self.is_traversing )
        return;

    player = self.favoriteenemy;

    if ( is_player_valid( player ) )
    {
        ghost_check_point = self.origin + ( 0, 0, 60 );
        player_eye_pos = player geteyeapprox();
        line_of_sight = sighttracepassed( ghost_check_point, player_eye_pos, 0, self );

        if ( isdefined( line_of_sight ) && line_of_sight && can_drain_points( self.origin, player.origin ) )
        {
            self start_drain();
            return;
        }

        if ( !self need_wait() )
            self start_chase();
    }
    else
    {
        self set_zombie_run_cycle( "run" );

        if ( self getanimstatefromasd() != "zm_move_run" )
            self setanimstatefromasd( "zm_move_run" );

        self setclientfield( "ghost_fx", 4 );
        self start_runaway();
    }
}

start_evaporate( need_deletion )
{
    self setclientfield( "ghost_fx", 5 );
    wait 0.1;

    if ( isdefined( need_deletion ) && need_deletion )
    {
        level.zombie_ghost_count--;

        if ( isdefined( self.favoriteenemy ) )
        {
            if ( isdefined( self.favoriteenemy.ghost_count ) && self.favoriteenemy.ghost_count > 0 )
                self.favoriteenemy.ghost_count--;
        }

        self delete();
    }
    else
    {
        self.state = "evaporate_update";
        self ghost();
        self notsolid();
    }
}

should_be_deleted_during_evaporate_update( player )
{
    if ( !( isdefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone ) )
        return false;

    if ( !isdefined( player ) )
        return true;

    if ( isdefined( player.sessionstate ) && ( player.sessionstate == "spectator" || player.sessionstate == "intermission" ) )
        return true;

    return false;
}

evaporate_update()
{
    player = self.favoriteenemy;

    if ( should_be_deleted_during_evaporate_update( player ) )
    {
        if ( level.zombie_ghost_count > 0 )
            level.zombie_ghost_count--;

        self delete();
    }
    else if ( is_player_valid( player ) )
    {
        self solid();
        self show();
        self start_chase();
    }
}

is_within_capsule( point, origin, angles, radius, range )
{
    forward_dir = vectornormalize( anglestoforward( angles ) );
    start = origin + forward_dir * radius;
    end = start + forward_dir * range;
    point_intersect = pointonsegmentnearesttopoint( start, end, point );
    distance_squared = distancesquared( point_intersect, point );

    if ( distance_squared <= radius * radius )
        return true;

    return false;
}

is_within_view_2d( point, origin, angles, fov_cos )
{
    dot = get_dot_production_2d( point, origin, angles );

    if ( dot > fov_cos )
        return true;

    return false;
}

get_dot_production_2d( point, origin, angles )
{
    forward_dir = anglestoforward( angles );
    forward_dir = ( forward_dir[0], forward_dir[1], 0 );
    forward_dir = vectornormalize( forward_dir );
    to_point_dir = point - origin;
    to_point_dir = ( to_point_dir[0], to_point_dir[1], 0 );
    to_point_dir = vectornormalize( to_point_dir );
    return vectordot( forward_dir, to_point_dir );
}

is_in_room( room )
{
    foreach ( volume in room.volumes )
    {
        if ( self istouching( volume ) )
            return true;
    }

    return false;
}

is_in_rooms( room_names )
{
    foreach ( room_name in room_names )
    {
        room = level.ghost_rooms[room_name];

        if ( self is_in_room( room ) )
            return true;
    }

    return false;
}

is_in_next_rooms( room )
{
    if ( self is_in_rooms( room.next_room_names ) )
        return true;

    return false;
}

is_in_close_rooms( room )
{
    foreach ( next_room_name in room.next_room_names )
    {
        next_room = level.ghost_rooms[next_room_name];

        if ( self is_in_rooms( next_room.next_room_names ) )
            return true;
    }

    if ( self is_in_rooms( room.next_room_names ) )
        return true;

    return false;
}

is_following_room_path( player, room )
{
    if ( isdefined( room.volumes[0].script_angles ) )
    {
        dot = get_dot_production_2d( player.origin, self.origin, room.volumes[0].script_angles );

        if ( dot > 0 )
            return true;
    }

    return false;
}

can_drain_points( self_pos, target_pos )
{
    if ( isdefined( self.force_killable ) && self.force_killable )
        return false;

    dist = distancesquared( self_pos, target_pos );

    if ( dist < 60 * 60 )
        return true;

    return false;
}

set_chase_status( move_speed )
{
    self setclientfield( "ghost_fx", 4 );

    if ( self.zombie_move_speed != move_speed )
    {
        self set_zombie_run_cycle( move_speed );
        self setanimstatefromasd( "zm_move_" + move_speed );
    }
}

start_drain()
{
    self setanimstatefromasd( "zm_drain" );
    self setclientfield( "ghost_fx", 2 );
    self.state = "drain_update";
}

drain_update()
{
    if ( isdefined( self.is_traversing ) && self.is_traversing )
        return;

    player = self.favoriteenemy;

    if ( is_player_valid( player ) )
    {
        if ( can_drain_points( self.origin, player.origin ) )
        {
            if ( self getanimstatefromasd() != "zm_drain" )
                self setanimstatefromasd( "zm_drain" );

            self orientmode( "face enemy" );

            if ( !( isdefined( self.is_draining ) && self.is_draining ) )
                self thread drain_player( player );
        }
        else
            self start_chase();
    }
    else
    {
        self set_zombie_run_cycle( "run" );

        if ( self getanimstatefromasd() != "zm_move_run" )
            self setanimstatefromasd( "zm_move_run" );

        self setclientfield( "ghost_fx", 4 );
        self start_runaway();
    }
}

drain_player( player )
{
    self endon( "death" );
    self.is_draining = 1;
    player_drained = 0;
    points_to_drain = 2000;

    if ( player.score < points_to_drain )
    {
        if ( player.score > 0 )
            points_to_drain = player.score;
        else
            points_to_drain = 0;
    }

    if ( points_to_drain > 0 )
    {
        player maps\mp\zombies\_zm_score::minus_to_player_score( points_to_drain );
        player_drained = 1;
        player playsoundtoplayer( "zmb_ai_ghost_money_drain", player );
        level notify( "ghost_drained_player", player );
    }
    else if ( player.health > 0 && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
    {
        player dodamage( 25, self.origin, self );
        player_drained = 1;
        level notify( "ghost_damaged_player", player );
    }

    if ( player_drained )
    {
        give_player_rewards( player );
        player maps\mp\zombies\_zm_stats::increment_client_stat( "buried_ghost_drained_player", 0 );
        player maps\mp\zombies\_zm_stats::increment_player_stat( "buried_ghost_drained_player" );
        wait 2;
    }

    self.is_draining = 0;
}

should_runaway( player )
{
    result = 0;

    if ( !is_ghost_round_started() && ( isdefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone ) && !( isdefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone ) )
    {
        path_lenth = self getpathlength();

        if ( path_lenth == 0 )
            result = 1;
    }

    return result;
}

start_runaway()
{
    wait 2;
    self.state = "runaway_update";
    self setgoalpos( self.startinglocation );
    self set_chase_status( "run" );
}

does_reach_runaway_goal()
{
    result = 0;
    dist_squared = distancesquared( self.origin, self.startinglocation );

    if ( dist_squared < 60 * 60 )
        result = 1;

    return result;
}

runaway_update()
{
    if ( isdefined( self.is_traversing ) && self.is_traversing )
        return;

    player = self.favoriteenemy;

    if ( is_player_valid( player ) && ( is_ghost_round_started() || isdefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone ) )
    {
        self.state = "chase_update";
        return;
    }

    if ( self does_fall_into_pap_hole() )
    {
        self dodamage( self.health + 666, self.origin );
        return;
    }

    if ( self does_reach_runaway_goal() )
    {
        should_delete = 1;

        if ( is_ghost_round_started() || !( isdefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone ) )
            should_delete = 0;

        self start_evaporate( should_delete );
    }
    else
    {
        self setgoalpos( self.startinglocation );
/#
        draw_debug_star( self.startinglocation, ( 0, 0, 1 ), 1 );
        draw_debug_line( self.origin, self.startinglocation, ( 0, 1, 0 ), 1, 0 );
#/
    }
}

paralyzer_callback( player, upgraded )
{
    if ( isdefined( self.ignore_slowgun_anim_rates ) && self.ignore_slowgun_anim_rates )
        return;

    if ( upgraded )
        self setclientfield( "slowgun_fx", 5 );
    else
        self setclientfield( "slowgun_fx", 1 );

    self maps\mp\zombies\_zm_weap_slowgun::zombie_slow_for_time( 0.3, 0 );
}

ghost_springpad_fling( weapon, attacker )
{
    self dodamage( self.health + 666, self.origin );
    weapon.springpad_kills++;
}

ghost_print( str )
{
/#
    if ( getdvarint( _hash_151B6F17 ) )
    {
        iprintln( "ghost: " + str + "\\n" );

        if ( isdefined( self ) )
        {
            if ( isdefined( self.debug_msg ) )
                self.debug_msg[self.debug_msg.size] = str;
            else
            {
                self.debug_msg = [];
                self.debug_msg[self.debug_msg.size] = str;
            }
        }
    }
#/
}

ghost_round_think()
{
    level endon( "intermission" );

    if ( isdefined( level.intermission ) && level.intermission )
        return;

    while ( true )
    {
        level.zombie_ghost_round_states.any_player_in_ghost_zone = check_players_in_ghost_zone();

        if ( can_start_ghost_round() )
        {
            if ( ghost_round_start_conditions_met() )
                start_ghost_round();
            else
            {
                wait 0.1;
                continue;
            }

            while ( true )
            {
                if ( can_end_ghost_round() )
                {
                    wait 0.5;
                    end_ghost_round();
                    break;
                }

                level.zombie_ghost_round_states.any_player_in_ghost_zone = check_players_in_ghost_zone();

                if ( isdefined( level.ghost_zone_teleport_logic ) )
                    [[ level.ghost_zone_teleport_logic ]]();

                if ( isdefined( level.ghost_zone_fountain_teleport_logic ) )
                    [[ level.ghost_zone_fountain_teleport_logic ]]();

                wait 0.1;
            }
        }
        else
            check_sending_away_zombie_followers();

        wait 0.1;
    }
}

ghost_round_start_conditions_met()
{
    b_conditions_met = isdefined( level.zombie_ghost_round_states.any_player_in_ghost_zone ) && level.zombie_ghost_round_states.any_player_in_ghost_zone && !is_ghost_round_started();

    if ( isdefined( level.force_ghost_round_start ) && level.force_ghost_round_start || is_ghost_round_started() )
        b_conditions_met = 1;

    return b_conditions_met;
}

can_start_ghost_round()
{
/#
    if ( isdefined( level.force_no_ghost ) && level.force_no_ghost )
        return 0;
#/
    result = 0;

    if ( isdefined( level.zombie_ghost_round_states ) )
    {
        if ( !( isdefined( level.zombie_ghost_round_states.is_first_ghost_round_finished ) && level.zombie_ghost_round_states.is_first_ghost_round_finished ) || level.round_number >= level.zombie_ghost_round_states.next_ghost_round_number )
            result = 1;
    }

    if ( isdefined( level.force_ghost_round_start ) && level.force_ghost_round_start )
        result = 1;

    return result;
}

set_ghost_round_number()
{
    if ( isdefined( level.zombie_ghost_round_states ) )
    {
        level.zombie_ghost_round_states.current_ghost_round_number = level.round_number;
        level.zombie_ghost_round_states.next_ghost_round_number = level.round_number + randomintrange( 4, 6 );
    }
}

is_ghost_round_started()
{
    if ( isdefined( level.zombie_ghost_round_states ) )
        return level.zombie_ghost_round_states.is_started;

    return 0;
}

start_ghost_round()
{
    level.zombie_ghost_round_states.is_started = 1;
    level.zombie_ghost_round_states.round_count++;
    flag_clear( "spawn_zombies" );
    flag_set( "spawn_ghosts" );
    disable_ghost_zone_door_ai_clips();
    clear_all_active_zombies();
    set_ghost_round_number();
    increase_ghost_health();
    ghost_round_presentation_reset();
    wait 0.5;
    level thread sndghostroundmus();
    level thread outside_ghost_zone_spawning_think();
    level thread player_moving_speed_scale_think();

    if ( !flag( "time_bomb_restore_active" ) )
        level.force_ghost_round_start = undefined;

    maps\mp\zombies\_zm_ai_ghost_ffotd::ghost_round_start();
}

increase_ghost_health()
{
    if ( level.zombie_ghost_round_states.round_count == 1 )
    {
        new_health = level.ghost_health + 300;

        if ( level.round_number > 5 )
            new_health = int( 1600 * level.round_number / 20 );

        level.ghost_health = new_health;
    }
    else if ( level.zombie_ghost_round_states.round_count == 2 )
        level.ghost_health += 500;
    else if ( level.zombie_ghost_round_states.round_count == 3 )
        level.ghost_health += 400;
    else if ( level.zombie_ghost_round_states.round_count == 4 )
        level.ghost_health = 1600;

    if ( level.ghost_health > 1600 )
        level.ghost_health = 1600;
}

enable_ghost_zone_door_ai_clips()
{
    if ( isdefined( level.ghost_zone_door_clips ) && level.ghost_zone_door_clips.size > 0 )
    {
        foreach ( door_clip in level.ghost_zone_door_clips )
        {
            door_clip solid();
            door_clip disconnectpaths();
        }
    }
}

disable_ghost_zone_door_ai_clips()
{
    if ( isdefined( level.ghost_zone_door_clips ) && level.ghost_zone_door_clips.size > 0 )
    {
        foreach ( door_clip in level.ghost_zone_door_clips )
        {
            door_clip notsolid();
            door_clip connectpaths();
        }
    }
}

clear_all_active_zombies()
{
    zombies = get_round_enemy_array();

    if ( isdefined( zombies ) )
    {
        level.zombie_ghost_round_states.round_zombie_total = level.zombie_total + zombies.size;

        foreach ( zombie in zombies )
        {
            if ( !( isdefined( zombie.is_ghost ) && zombie.is_ghost ) )
            {
                spawn_point = spawnstruct();
                spawn_point.origin = zombie.origin;
                spawn_point.angles = zombie.angles;

                if ( !( isdefined( zombie.completed_emerging_into_playable_area ) && zombie.completed_emerging_into_playable_area ) )
                {
                    no_barrier_target = isdefined( zombie.spawn_point ) && isdefined( zombie.spawn_point.script_string ) && zombie.spawn_point.script_string == "find_flesh";

                    if ( no_barrier_target )
                    {
                        if ( isdefined( zombie.spawn_point.script_noteworthy ) && zombie.spawn_point.script_noteworthy == "faller_location" )
                        {
                            ground_pos = groundpos_ignore_water_new( zombie.spawn_point.origin );
                            spawn_point.origin = ground_pos;
                        }
                    }
                    else
                    {
                        origin = zombie.origin;
                        desired_origin = zombie get_desired_origin();

                        if ( isdefined( desired_origin ) )
                            origin = desired_origin;

                        nodes = get_array_of_closest( origin, level.exterior_goals, undefined, 1 );

                        if ( nodes.size > 0 )
                        {
                            spawn_point.origin = nodes[0].neg_end.origin;
                            spawn_point.angles = nodes[0].neg_end.angles;
                        }
                    }
                }
                else if ( isdefined( level.sloth ) && isdefined( level.sloth.crawler ) && zombie == level.sloth.crawler )
                {
                    spawn_point.origin = level.sloth.origin;
                    spawn_point.angles = level.sloth.angles;
                }

                level.zombie_ghost_round_states.active_zombie_locations[level.zombie_ghost_round_states.active_zombie_locations.size] = spawn_point;
                zombie.nodeathragdoll = 1;
                zombie.turning_into_ghost = 1;

                if ( isalive( zombie ) )
                    zombie dodamage( zombie.health + 666, zombie.origin );
            }
        }
    }
}

reset_ghost_round_states()
{
    if ( !isdefined( level.zombie_ghost_round_states.round_zombie_total ) )
        level.zombie_ghost_round_states.round_zombie_total = 0;

    level.zombie_ghost_round_states.is_started = 0;

    if ( should_restore_zombie_total() )
    {
        if ( level.zombie_ghost_round_states.round_zombie_total > 0 )
            level.zombie_total = level.zombie_ghost_round_states.round_zombie_total;
    }

    level.zombie_ghost_round_states.round_zombie_total = 0;
    level.zombie_ghost_round_states.active_zombie_locations = [];

    if ( is_false( level.zombie_ghost_round_states.is_first_ghost_round_finished ) )
        level.zombie_ghost_round_states.is_first_ghost_round_finished = 1;
}

should_restore_zombie_total()
{
    return !flag( "time_bomb_restore_active" ) || flag( "time_bomb_restore_active" ) && maps\mp\zombies\_zm_weap_time_bomb::get_time_bomb_saved_round_type() == "ghost";
}

can_end_ghost_round()
{
    if ( isdefined( level.force_ghost_round_end ) && level.force_ghost_round_end )
        return true;

    if ( !( isdefined( level.zombie_ghost_round_states.any_player_in_ghost_zone ) && level.zombie_ghost_round_states.any_player_in_ghost_zone ) && get_current_ghost_count() <= 0 )
        return true;

    return false;
}

end_ghost_round()
{
    reset_ghost_round_states();

    if ( should_last_ghost_drop_powerup() )
    {
        trace = groundtrace( level.ghost_round_last_ghost_origin + vectorscale( ( 0, 0, 1 ), 10.0 ), level.ghost_round_last_ghost_origin + vectorscale( ( 0, 0, -1 ), 150.0 ), 0, undefined, 1 );
        power_up_origin = trace["position"];
        powerup = level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop( "free_perk", power_up_origin );

        if ( isdefined( powerup ) )
            powerup.ghost_powerup = 1;

        level.ghost_round_last_ghost_origin_last = level.ghost_round_last_ghost_origin;
        level.ghost_round_last_ghost_origin = undefined;
    }

    level setclientfield( "ghost_round_light_state", 0 );
    enable_ghost_zone_door_ai_clips();
    level notify( "ghost_round_end" );

    if ( isdefined( level.force_ghost_round_end ) && level.force_ghost_round_end )
    {
        level.force_ghost_round_end = undefined;
        return;
    }

    flag_set( "spawn_zombies" );
    flag_clear( "spawn_ghosts" );
    maps\mp\zombies\_zm_ai_ghost_ffotd::ghost_round_end();
}

should_last_ghost_drop_powerup()
{
    if ( flag( "time_bomb_restore_active" ) )
        return false;

    if ( !isdefined( level.ghost_round_last_ghost_origin ) )
        return false;

    return true;
}

sndghostroundmus()
{
    level endon( "ghost_round_end" );
    ent = spawn( "script_origin", ( 0, 0, 0 ) );
    level.sndroundwait = 1;
    ent thread sndghostroundmus_end();
    ent endon( "sndGhostRoundEnd" );
    ent playsound( "mus_ghost_round_start" );
    wait 11;
    ent playloopsound( "mus_ghost_round_loop", 3 );
}

sndghostroundmus_end()
{
    level waittill( "ghost_round_end" );

    self notify( "sndGhostRoundEnd" );
    self stoploopsound( 1 );
    self playsoundwithnotify( "mus_ghost_round_over", "stingerDone" );

    self waittill( "stingerDone" );

    self delete();
    level.sndroundwait = 0;
}

sndghostroundready()
{
    level notify( "sndGhostRoundReady" );
    level endon( "sndGhostRoundReady" );
    mansion = ( 2830, 555, 436 );

    while ( true )
    {
        level waittill( "between_round_over" );

        if ( level.zombie_ghost_round_states.next_ghost_round_number == level.round_number )
        {
            playsoundatposition( "zmb_ghost_round_srt", mansion );
            ent = spawn( "script_origin", mansion );
            ent playloopsound( "zmb_ghost_round_lp", 3 );
            ent thread sndghostroundready_stoplp();
            break;
        }
    }

    wait 15;
    level notify( "sndStopRoundReadyLp" );
}

sndghostroundready_stoplp()
{
    level waittill_either( "sndStopRoundReadyLp", "sndGhostRoundReady" );
    self stoploopsound( 3 );
    wait 3;
    self delete();
}

check_sending_away_zombie_followers()
{
    if ( flag_exists( "time_bomb_restore_active" ) && flag( "time_bomb_restore_active" ) )
        return;

    players = getplayers();
    valid_player_in_ghost_zone_count = 0;
    valid_player_count = 0;

    foreach ( player in players )
    {
        if ( is_player_valid( player ) )
        {
            valid_player_count++;

            if ( isdefined( player.is_in_ghost_zone ) && player.is_in_ghost_zone )
            {
                valid_player_in_ghost_zone_count++;
                continue;
            }

            player.zombie_followers_sent_away = 0;
        }
    }

    if ( valid_player_count > 0 && valid_player_in_ghost_zone_count == valid_player_count )
    {
        if ( flag( "spawn_zombies" ) )
            flag_clear( "spawn_zombies" );

        zombies = get_round_enemy_array();

        foreach ( zombie in zombies )
        {
            if ( is_true( zombie.completed_emerging_into_playable_area ) && !is_true( zombie.zombie_path_bad ) )
                zombie notify( "bad_path" );
        }
    }
    else if ( !flag( "spawn_zombies" ) )
        flag_set( "spawn_zombies" );
}

send_away_zombie_follower( player )
{
    self endon( "death" );
    dist_zombie = 0;
    dist_player = 0;
    dest = 0;
    awaydir = self.origin - player.origin;
    awaydir = ( awaydir[0], awaydir[1], 0 );
    awaydir = vectornormalize( awaydir );
    endpos = self.origin + vectorscale( awaydir, 600 );
    locs = array_randomize( level.enemy_dog_locations );

    for ( i = 0; i < locs.size; i++ )
    {
        dist_zombie = distancesquared( locs[i].origin, endpos );
        dist_player = distancesquared( locs[i].origin, player.origin );

        if ( dist_zombie < dist_player )
        {
            dest = i;
            break;
        }
    }

    self notify( "stop_find_flesh" );
    self notify( "zombie_acquire_enemy" );

    if ( isdefined( locs[dest] ) )
        self setgoalpos( locs[dest].origin );

    wait 5;
    self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
}

outside_ghost_zone_spawning_think()
{
    level endon( "intermission" );

    if ( level.intermission )
        return;

    level endon( "ghost_round_end" );

    if ( !isdefined( level.female_ghost_spawner ) )
    {
/#
        assertmsg( "No female ghost spawner in the map." );
#/
        return;
    }

    if ( isdefined( level.zombie_ghost_round_states.active_zombie_locations ) )
    {
        for ( i = 0; i < level.zombie_ghost_round_states.active_zombie_locations.size; i++ )
        {
            if ( i >= 20 )
                return;

            spawn_point = level.zombie_ghost_round_states.active_zombie_locations[i];
            ghost_ai = spawn_zombie( level.female_ghost_spawner, level.female_ghost_spawner.targetname, spawn_point );

            if ( isdefined( ghost_ai ) )
            {
                ghost_ai setclientfield( "ghost_fx", 3 );
                ghost_ai.spawn_point = spawn_point;
                ghost_ai.is_ghost = 1;
            }
            else
            {
/#
                assertmsg( "female ghost outside ghost zone: failed spawn" );
#/
                return;
            }

            wait( randomfloat( 0.3 ) );
            wait_network_frame();
        }
    }
}

get_current_ghost_count()
{
    ghost_count = 0;
    ais = getaiarray( level.zombie_team );

    foreach ( ai in ais )
    {
        if ( isdefined( ai.is_ghost ) && ai.is_ghost )
            ghost_count++;
    }

    return ghost_count;
}

get_current_ghosts()
{
    ghosts = [];
    ais = getaiarray( level.zombie_team );

    foreach ( ai in ais )
    {
        if ( isdefined( ai.is_ghost ) && ai.is_ghost )
            ghosts[ghosts.size] = ai;
    }

    return ghosts;
}

set_player_moving_speed_scale( player, move_speed_scale )
{
    if ( isdefined( player ) )
        player setmovespeedscale( move_speed_scale );
}

player_moving_speed_scale_think()
{
    level endon( "intermission" );

    if ( isdefined( level.intermission ) && level.intermission )
        return;

    level endon( "ghost_round_end" );

    while ( true )
    {
        players = get_players();

        foreach ( player in players )
        {
            if ( !is_player_valid( player, undefined, 1 ) )
                continue;

            if ( player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
            {
                set_player_moving_speed_scale( player, 1 );
                continue;
            }

            if ( isdefined( player.ghost_next_drain_time_left ) )
                player.ghost_next_drain_time_left -= 0.1;

            player_slow_down = 0;
            ais = getaiarray( level.zombie_team );

            foreach ( ai in ais )
            {
                if ( isdefined( ai.is_ghost ) && ai.is_ghost && can_drain_points( ai.origin, player.origin ) )
                {
                    player_slow_down = 1;
                    set_player_moving_speed_scale( player, 0.5 );

                    if ( ( !isdefined( player.ghost_next_drain_time_left ) || player.ghost_next_drain_time_left < 0 ) && isdefined( ai.favoriteenemy ) && player != ai.favoriteenemy )
                    {
                        give_player_rewards( player );
                        points_to_drain = 2000;

                        if ( player.score < points_to_drain )
                        {
                            if ( player.score > 0 )
                                points_to_drain = player.score;
                            else
                                points_to_drain = 0;
                        }

                        if ( points_to_drain > 0 )
                        {
                            player maps\mp\zombies\_zm_score::minus_to_player_score( points_to_drain );
                            player playsoundtoplayer( "zmb_ai_ghost_money_drain", player );
                        }
                        else if ( player.health > 0 && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
                            player dodamage( 25, ai.origin, ai );

                        player.ghost_next_drain_time_left = 2;
                    }

                    break;
                }
            }

            if ( player_slow_down == 0 )
                set_player_moving_speed_scale( player, 1 );
        }

        wait 0.1;
    }
}

give_player_rewards( player )
{
    if ( player is_player_placeable_mine( "claymore_zm" ) )
    {
        claymore_count = player getweaponammostock( "claymore_zm" ) + 1;

        if ( claymore_count >= 2 )
        {
            claymore_count = 2;
            player notify( "zmb_disable_claymore_prompt" );
        }

        player setweaponammostock( "claymore_zm", claymore_count );
    }
    else
    {
        lethal_grenade_name = player get_player_lethal_grenade();

        if ( player hasweapon( lethal_grenade_name ) )
        {
            lethal_grenade_count = player getweaponammoclip( lethal_grenade_name ) + 1;

            if ( lethal_grenade_count > 4 )
                lethal_grenade_count = 4;

            player setweaponammoclip( lethal_grenade_name, lethal_grenade_count );
        }
    }
}

set_player_current_ghost_zone( player, ghost_zone_name )
{
    if ( isdefined( player ) )
        player.current_ghost_room_name = ghost_zone_name;
}

can_start_ghost_round_presentation()
{
/#
    if ( isdefined( level.force_no_ghost ) && level.force_no_ghost )
        return false;
#/
    if ( isdefined( level.zombie_ghost_round_states.is_first_ghost_round_finished ) && level.zombie_ghost_round_states.is_first_ghost_round_finished )
    {
        if ( level.round_number < level.zombie_ghost_round_states.current_ghost_round_number + 4 )
            return false;
    }

    if ( is_ghost_round_started() )
        return false;

    if ( flag( "time_bomb_round_killed" ) && !flag( "time_bomb_enemies_restored" ) )
        return false;

    return true;
}

can_start_ghost_round_presentation_stage_1()
{
    if ( isdefined( level.zombie_ghost_round_states.presentation_stage_1_started ) && level.zombie_ghost_round_states.presentation_stage_1_started )
        return false;

    return true;
}

can_start_ghost_round_presentation_stage_2()
{
    if ( isdefined( level.zombie_ghost_round_states.presentation_stage_2_started ) && level.zombie_ghost_round_states.presentation_stage_2_started )
        return false;

    if ( isdefined( level.zombie_ghost_round_states.is_first_ghost_round_finished ) && level.zombie_ghost_round_states.is_first_ghost_round_finished )
    {
        if ( level.round_number < level.zombie_ghost_round_states.current_ghost_round_number + 4 + 1 )
            return false;
    }

    return true;
}

can_start_ghost_round_presentation_stage_3()
{
    if ( isdefined( level.zombie_ghost_round_states.presentation_stage_3_started ) && level.zombie_ghost_round_states.presentation_stage_3_started )
        return false;

    if ( isdefined( level.zombie_ghost_round_states.is_first_ghost_round_finished ) && level.zombie_ghost_round_states.is_first_ghost_round_finished )
    {
        if ( level.round_number < level.zombie_ghost_round_states.current_ghost_round_number + 4 + 2 )
            return false;
    }

    return true;
}

get_next_spot_during_ghost_round_presentation()
{
    if ( isdefined( level.current_ghost_window_index ) )
    {
        for ( standing_location_index = randomint( level.ghost_front_standing_locations.size ); standing_location_index == level.current_ghost_window_index; standing_location_index = randomint( level.ghost_front_standing_locations.size ) )
        {

        }

        level.current_ghost_window_index = standing_location_index;
    }
    else
        level.current_ghost_window_index = 1;

    return level.ghost_front_standing_locations[level.current_ghost_window_index];
}

spawn_ghost_round_presentation_ghost()
{
    spawn_point = get_next_spot_during_ghost_round_presentation();
    ghost = spawn( "script_model", spawn_point.origin );
    ghost.angles = spawn_point.angles;
    ghost setmodel( "c_zom_zombie_buried_ghost_woman_fb" );

    if ( isdefined( ghost ) )
    {
        ghost.spawn_point = spawn_point;
        ghost.for_ghost_round_presentation = 1;
        level.ghost_round_presentation_ghost = ghost;
    }
    else
    {
/#
        assertmsg( "ghost round presentation ghost: failed spawn" );
#/
        return;
    }

    wait 0.5;
    ghost useanimtree( #animtree );
    ghost setanim( %ai_zombie_ghost_idle );
    ghost.script_mover = spawn( "script_origin", ghost.origin );
    ghost.script_mover.angles = ghost.angles;
    ghost linkto( ghost.script_mover );
    ghost setclientfield( "sndGhostAudio", 1 );
}

ghost_round_presentation_think()
{
    level endon( "intermission" );

    if ( isdefined( level.intermission ) && level.intermission )
        return;

    if ( !isdefined( level.sndmansionent ) )
        level.sndmansionent = spawn( "script_origin", ( 2830, 555, 436 ) );

    flag_wait( "start_zombie_round_logic" );

    while ( true )
    {
        if ( can_start_ghost_round_presentation() )
        {
            if ( can_start_ghost_round_presentation_stage_1() )
            {
                level.zombie_ghost_round_states.presentation_stage_1_started = 1;
                spawn_ghost_round_presentation_ghost();

                if ( isdefined( level.ghost_round_presentation_ghost ) )
                    level.ghost_round_presentation_ghost thread ghost_switch_windows();
            }

            if ( can_start_ghost_round_presentation_stage_2() )
            {
                level.zombie_ghost_round_states.presentation_stage_2_started = 1;
                level.sndmansionent playloopsound( "zmb_ghost_round_lp_quiet", 3 );
                level setclientfield( "ghost_round_light_state", 1 );
            }

            if ( can_start_ghost_round_presentation_stage_3() )
            {
                level.zombie_ghost_round_states.presentation_stage_3_started = 1;
                level.sndmansionent playloopsound( "zmb_ghost_round_lp_loud", 3 );

                if ( isdefined( level.ghost_round_presentation_ghost ) )
                    level.ghost_round_presentation_ghost thread ghost_round_presentation_sound();
            }
        }

        wait 0.1;
    }
}

ghost_switch_windows()
{
    level endon( "intermission" );
    self endon( "death" );

    while ( true )
    {
        next_spot = get_next_spot_during_ghost_round_presentation();
        self setclientfield( "ghost_fx", 5 );
        self setclientfield( "sndGhostAudio", 0 );
        self ghost();
        self.script_mover moveto( next_spot.origin, 1 );

        self.script_mover waittill( "movedone" );

        self.script_mover.origin = next_spot.origin;
        self.script_mover.angles = next_spot.angles;
        self setclientfield( "ghost_fx", 3 );
        self setclientfield( "sndGhostAudio", 1 );
        self show();
        wait 6;
    }
}

ghost_round_presentation_sound()
{
    level endon( "intermission" );
    self endon( "death" );

    while ( true )
    {
        players = getplayers();

        foreach ( player in players )
        {
            if ( is_player_valid( player ) )
            {
                vox_index = randomint( level.ghost_vox.size );
                vox_line = level.ghost_vox[vox_index];
                self playsoundtoplayer( vox_line, player );
            }
        }

        wait( randomintrange( 2, 6 ) );
    }
}

ghost_round_presentation_reset()
{
    if ( isdefined( level.sndmansionent ) )
        level.sndmansionent stoploopsound( 3 );

    if ( isdefined( level.ghost_round_presentation_ghost ) )
    {
        level.ghost_round_presentation_ghost.skip_death_notetracks = 1;
        level.ghost_round_presentation_ghost.nodeathragdoll = 1;
        level.ghost_round_presentation_ghost setclientfield( "ghost_fx", 5 );
        wait_network_frame();
        level.ghost_round_presentation_ghost delete();
        level.ghost_round_presentation_ghost = undefined;
    }

    level.zombie_ghost_round_states.presentation_stage_1_started = 0;
    level.zombie_ghost_round_states.presentation_stage_2_started = 0;
    level.zombie_ghost_round_states.presentation_stage_3_started = 0;
}

behave_after_fountain_transport( player )
{
    wait 1;

    if ( isdefined( player ) )
    {
        set_player_current_ghost_zone( player, undefined );
        level.zombie_ghost_round_states.is_teleporting = 1;
        ais = getaiarray( level.zombie_team );
        ghost_teleport_point_index = 0;
        ais_need_teleported = [];

        foreach ( ai in ais )
        {
            if ( isdefined( ai.is_ghost ) && ai.is_ghost && isdefined( ai.favoriteenemy ) && ai.favoriteenemy == player )
                ais_need_teleported[ais_need_teleported.size] = ai;
        }

        foreach ( ai_need_teleported in ais_need_teleported )
        {
            if ( ghost_teleport_point_index == level.ghost_zone_start_lower_locations.size )
                ghost_teleport_point_index = 0;

            teleport_point_origin = level.ghost_zone_start_lower_locations[ghost_teleport_point_index].origin;
            teleport_point_angles = level.ghost_zone_start_lower_locations[ghost_teleport_point_index].angles;
            ai_need_teleported forceteleport( teleport_point_origin, teleport_point_angles );
            ghost_teleport_point_index++;
            wait_network_frame();
        }

        wait 1;
        level.zombie_ghost_round_states.is_teleporting = 0;
    }
}

init_time_bomb_ghost_rounds()
{
    register_time_bomb_enemy( "ghost", ::is_ghost_round, ::save_ghost_data, ::time_bomb_respawns_ghosts );
    level.ghost_custom_think_logic = ::time_bomb_ghost_respawn_think;
    maps\mp\zombies\_zm_weap_time_bomb::time_bomb_add_custom_func_global_save( ::time_bomb_global_data_save_ghosts );
    maps\mp\zombies\_zm_weap_time_bomb::time_bomb_add_custom_func_global_restore( ::time_bomb_global_data_restore_ghosts );
    level._time_bomb.custom_funcs_get_enemies = ::time_bomb_custom_get_enemy_func;
    maps\mp\zombies\_zm_weap_time_bomb::register_time_bomb_enemy_save_filter( "zombie", ::is_ghost );
}

is_ghost()
{
    return !( isdefined( self.is_ghost ) && self.is_ghost );
}

is_ghost_round()
{
    return flag( "spawn_ghosts" );
}

save_ghost_data( s_data )
{
    s_data.origin = self.origin;
    s_data.angles = self.angles;
    s_data.is_ghost = self.is_ghost;
    s_data.spawn_point = self.spawn_point;

    if ( level.zombie_ghost_round_states.any_player_in_ghost_zone )
        s_data.is_spawned_in_ghost_zone = self.is_spawned_in_ghost_zone;
    else
        s_data.is_spawned_in_ghost_zone = 0;

    s_data.is_spawned_in_ghost_zone_actual = self.is_spawned_in_ghost_zone;
    s_data.find_target = self.find_target;
    s_data.favoriteenemy = self.favoriteenemy;
    s_data.ignore_timebomb_slowdown = self.ignore_timebomb_slowdown;
}

time_bomb_respawns_ghosts( save_struct )
{
    flag_clear( "spawn_ghosts" );
    ghost_round_presentation_reset();
    level.force_ghost_round_end = 1;
    level.force_ghost_round_start = 1;

    level waittill( "ghost_round_end" );

    level thread respawn_ghosts_outside_mansion( save_struct );
    level thread _respawn_ghost_failsafe();

    if ( !save_struct.custom_data.ghost_data.round_first_done )
        level.zombie_ghost_round_states.is_first_ghost_round_finished = 0;

    flag_wait( "time_bomb_enemies_restored" );
    level.force_ghost_round_end = undefined;
    level.force_ghost_round_start = undefined;
    level.zombie_ghost_round_states.is_started = save_struct.custom_data.ghost_data.round_started;
}

respawn_ghosts_outside_mansion( save_struct )
{
    a_spawns_outside_mansion = [];

    for ( i = 0; i < save_struct.enemies.size; i++ )
    {
        if ( !( isdefined( save_struct.enemies[i].is_spawned_in_ghost_zone ) && save_struct.enemies[i].is_spawned_in_ghost_zone ) )
            a_spawns_outside_mansion[a_spawns_outside_mansion.size] = save_struct.enemies[i];
    }

    level.zombie_ghost_round_states.active_zombie_locations = a_spawns_outside_mansion;
    save_struct.total_respawns = a_spawns_outside_mansion.size;
}

time_bomb_custom_get_enemy_func()
{
    a_enemies = [];
    a_valid_enemies = [];
    a_enemies = getaispeciesarray( level.zombie_team, "all" );

    for ( i = 0; i < a_enemies.size; i++ )
    {
        if ( isdefined( a_enemies[i].ignore_enemy_count ) && a_enemies[i].ignore_enemy_count && !( isdefined( a_enemies[i].is_ghost ) && a_enemies[i].is_ghost ) || isdefined( level.ghost_round_presentation_ghost ) && level.ghost_round_presentation_ghost == a_enemies[i] )
            continue;

        a_valid_enemies[a_valid_enemies.size] = a_enemies[i];
    }

    return a_valid_enemies;
}

time_bomb_global_data_save_ghosts()
{
    s_temp = spawnstruct();
    s_temp.ghost_count = level.zombie_ghost_count;
    s_temp.round_started = level.zombie_ghost_round_states.is_started;
    s_temp.round_first_done = level.zombie_ghost_round_states.is_first_ghost_round_finished;
    s_temp.round_next = level.zombie_ghost_round_states.next_ghost_round_number;
    s_temp.zombie_total = level.zombie_ghost_round_states.round_zombie_total;
    self.ghost_data = s_temp;
}

time_bomb_global_data_restore_ghosts()
{
    level.zombie_ghost_count = 0;
    level.zombie_ghost_round_states.is_started = self.ghost_data.round_started;
    level.zombie_ghost_round_states.is_first_ghost_round_finished = self.ghost_data.round_first_done;
    level.zombie_ghost_round_states.next_ghost_round_number = self.ghost_data.round_next;
    level.zombie_ghost_round_states.round_zombie_total = self.ghost_data.zombie_total;

    foreach ( player in get_players() )
        player.ghost_count = 0;
}

time_bomb_ghost_respawn_think()
{
    if ( flag( "time_bomb_round_killed" ) && !flag( "time_bomb_enemies_restored" ) )
    {
        if ( isdefined( level.timebomb_override_struct ) )
            save_struct = level.timebomb_override_struct;
        else
            save_struct = level.time_bomb_save_data;

        if ( !isdefined( save_struct.respawn_counter ) )
            save_struct.respawn_counter = 0;

        n_index = save_struct.respawn_counter;
        save_struct.respawn_counter++;

        if ( save_struct.enemies.size > 0 && isdefined( save_struct.enemies ) && n_index < save_struct.enemies.size )
        {
            while ( isdefined( save_struct.enemies[n_index] ) && ( isdefined( save_struct.enemies[n_index].is_spawned_in_ghost_zone ) && save_struct.enemies[n_index].is_spawned_in_ghost_zone ) )
            {
                save_struct.respawn_counter++;
                n_index = save_struct.respawn_counter;
            }

            if ( isdefined( save_struct.enemies[n_index] ) )
                self _restore_ghost_data( save_struct, n_index );
        }

        if ( save_struct.respawn_counter >= save_struct.enemies.size || save_struct.enemies.size == 0 )
        {
            flag_set( "time_bomb_enemies_restored" );
            level.zombie_ghost_round_states.active_zombie_locations = [];
        }

        flag_wait( "time_bomb_enemies_restored" );
        self thread restore_ghost_failsafe();
    }
}

restore_ghost_failsafe()
{
    self endon( "death" );
    wait( randomfloatrange( 2.0, 3.0 ) );

    if ( !isdefined( self.state ) )
    {
        self.respawned_by_time_bomb = 1;
        self thread ghost_think();
    }
    else if ( isdefined( level.ghost_round_presentation_ghost ) && level.ghost_round_presentation_ghost == self )
    {
        ghost_round_presentation_reset();
        wait_network_frame();
        self thread ghost_think();
    }

    self.passed_failsafe = 1;
}

_restore_ghost_data( save_struct, n_index )
{
    s_data = save_struct.enemies[n_index];
    playfxontag( level._effect["time_bomb_respawns_enemy"], self, "J_SpineLower" );
    self.origin = s_data.origin;
    self.angles = s_data.angles;
    self.is_ghost = s_data.is_ghost;
    self.spawn_point = s_data.spawn_point;
    self.is_spawned_in_ghost_zone = s_data.is_spawned_in_ghost_zone;
    self.find_target = s_data.find_target;

    if ( isdefined( s_data.favoriteenemy ) )
        self.favoriteenemy = s_data.favoriteenemy;

    self.ignore_timebomb_slowdown = 1;
    self setgoalpos( self.origin );
}

_respawn_ghost_failsafe()
{
    n_counter = 0;

    while ( !flag( "time_bomb_enemies_restored" ) && n_counter < 20 )
    {
        if ( get_current_actor_count() >= level.zombie_ai_limit || isdefined( level.time_bomb_save_data.total_respawns ) && level.time_bomb_save_data.total_respawns == 0 )
            flag_set( "time_bomb_enemies_restored" );

        n_counter++;
        wait 0.5;
    }

    flag_set( "time_bomb_enemies_restored" );
}

devgui_warp_to_mansion()
{
/#
    player = gethostplayer();
    player setorigin( ( 2324, 560, 148 ) );
    player setplayerangles( ( 0, 0, 0 ) );
#/
}

devgui_toggle_no_ghost()
{
/#
    level.force_no_ghost = !level.force_no_ghost;
#/
}

draw_debug_line( from, to, color, time, depth_test )
{
/#
    if ( isdefined( level.ghost_debug ) && level.ghost_debug )
    {
        if ( !isdefined( time ) )
            time = 1000;

        line( from, to, color, 1, depth_test, time );
    }
#/
}

draw_debug_star( origin, color, time )
{
/#
    if ( isdefined( level.ghost_debug ) && level.ghost_debug )
    {
        if ( !isdefined( time ) )
            time = 1000;

        if ( !isdefined( color ) )
            color = ( 1, 1, 1 );

        debugstar( origin, time, color );
    }
#/
}

draw_debug_box( origin, mins, maxs, yaw, color, time )
{
/#
    if ( isdefined( level.ghost_debug ) && level.ghost_debug )
    {
        if ( !isdefined( time ) )
            time = 1000;

        if ( !isdefined( color ) )
            color = ( 1, 1, 1 );

        box( origin, mins, maxs, yaw, color, 1, 0, 1 );
    }
#/
}
