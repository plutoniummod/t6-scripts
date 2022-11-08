// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\zombies\_zm_zonemgr;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zm_tomb_tank;
#include maps\mp\zombies\_zm_ai_mechz_dev;
#include maps\mp\zombies\_zm_ai_mechz_claw;
#include maps\mp\zombies\_zm_ai_mechz_ft;
#include maps\mp\zombies\_zm_ai_mechz_booster;
#include maps\mp\zombies\_zm_ai_mechz_ffotd;
#include maps\mp\zombies\_zm_ai_mechz;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zm_tomb_chamber;
#include maps\mp\zombies\_zm_ai_basic;

precache()
{
    level thread mechz_setup_armor_pieces();
    precachemodel( "c_zom_mech_claw" );
    precachemodel( "c_zom_mech_faceplate" );
    precachemodel( "c_zom_mech_powersupply_cap" );
    level._effect["mech_dmg_sparks"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_dmg_sparks" );
    level._effect["mech_dmg_steam"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_dmg_steam" );
    level._effect["mech_booster"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_jump_booster" );
    level._effect["mech_wpn_source"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_wpn_source" );
    level._effect["mech_wpn_flamethrower"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_wpn_flamethrower" );
    level._effect["mech_booster_landing"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_jump_landing" );
    level._effect["mech_faceplate_dmg"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_dmg_armor_face" );
    level._effect["mech_armor_dmg"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_dmg_armor" );
    level._effect["mech_exhaust"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_exhaust_smoke" );
    level._effect["mech_booster_feet"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_jump_booster_sm" );
    level._effect["mech_headlamp"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_head_light" );
    level._effect["mech_footstep_steam"] = loadfx( "maps/zombie_tomb/fx_tomb_mech_foot_step_steam" );
    setdvar( "zombie_double_wide_checks", 1 );
    precacherumble( "mechz_footsteps" );
    precacheshellshock( "lava_small" );
}

#using_animtree("mechz_claw");

init()
{
    maps\mp\zombies\_zm_ai_mechz_ffotd::mechz_init_start();
    level.mechz_spawners = getentarray( "mechz_spawner", "script_noteworthy" );

    if ( level.mechz_spawners.size == 0 )
        return;

    for ( i = 0; i < level.mechz_spawners.size; i++ )
    {
        level.mechz_spawners[i].is_enabled = 1;
        level.mechz_spawners[i].script_forcespawn = 1;
    }

    level.mechz_base_health = 5000;
    level.mechz_health = level.mechz_base_health;
    level.mechz_health_increase = 1000;
    level.mechz_round_count = 0;
    level.mechz_damage_percent = 0.1;
    level.mechz_remove_helmet_head_dmg_base = 500;
    level.mechz_remove_helmet_head_dmg = level.mechz_remove_helmet_head_dmg_base;
    level.mechz_remove_helmet_head_dmg_increase = 250;
    level.mechz_explosive_dmg_head_scaler = 0.25;
    level.mechz_helmet_health_percentage = 0.1;
    level.mechz_powerplant_expose_dmg_base = 300;
    level.mechz_powerplant_expose_dmg = level.mechz_powerplant_expose_base_dmg;
    level.mechz_powerplant_expose_dmg_increase = 100;
    level.mechz_powerplant_destroy_dmg_base = 500;
    level.mechz_powerplant_destroy_dmg = level.mechz_powerplant_destroy_dmg_base;
    level.mechz_powerplant_destroy_dmg_increase = 150;
    level.mechz_powerplant_expose_health_percentage = 0.05;
    level.mechz_powerplant_destroyed_health_percentage = 0.025;
    level.mechz_explosive_dmg_to_cancel_claw_percentage = 0.1;
    level.mechz_min_round_fq = 3;
    level.mechz_max_round_fq = 4;
    level.mechz_min_round_fq_solo = 4;
    level.mechz_max_round_fq_solo = 6;
    level.mechz_reset_dist_sq = 65536;
    level.mechz_sticky_dist_sq = 1048576;
    level.mechz_aggro_dist_sq = 16384;
    level.mechz_zombie_per_round = 1;
    level.mechz_left_to_spawn = 0;
    level.mechz_players_in_zone_spawn_point_cap = 120;
    level.mechz_shotgun_damage_mod = 1.5;
    level.mechz_failed_paths_to_jump = 3;
    level.mechz_jump_dist_threshold = 4410000;
    level.mechz_jump_delay = 3;
    level.mechz_player_flame_dmg = 10;
    level.mechz_half_front_arc = cos( 45 );
    level.mechz_ft_sweep_chance = 10;
    level.mechz_aim_max_pitch = 60;
    level.mechz_aim_max_yaw = 45;
    level.mechz_custom_goalradius = 48;
    level.mechz_custom_goalradius_sq = level.mechz_custom_goalradius * level.mechz_custom_goalradius;
    level.mechz_tank_knockdown_time = 5;
    level.mechz_robot_knockdown_time = 10;
    level.mechz_dist_for_sprint = 129600;
    level.mechz_dist_for_stop_sprint = 57600;
    level.mechz_claw_cooldown_time = 7000;
    level.mechz_flamethrower_cooldown_time = 5000;
    level.mechz_min_extra_spawn = 8;
    level.mechz_max_extra_spawn = 11;
    level.mechz_points_for_killer = 250;
    level.mechz_points_for_team = 500;
    level.mechz_points_for_helmet = 100;
    level.mechz_points_for_powerplant = 100;
    level.mechz_flogger_stun_time = 3;
    level.mechz_powerplant_stun_time = 4;
    flag_init( "mechz_launching_claw" );
    flag_init( "mechz_claw_move_complete" );
    registerclientfield( "actor", "mechz_fx", 14000, 12, "int" );
    registerclientfield( "toplayer", "mechz_grab", 14000, 1, "int" );
    level thread init_flamethrower_triggers();

    if ( isdefined( level.mechz_spawning_logic_override_func ) )
        level thread [[ level.mechz_spawning_logic_override_func ]]();
    else
        level thread mechz_spawning_logic();

    scriptmodelsuseanimtree( #animtree );
/#
    setup_devgui();
#/
    maps\mp\zombies\_zm_ai_mechz_ffotd::mechz_init_end();
}

mechz_setup_armor_pieces()
{
    level.mechz_armor_info = [];
    level.mechz_armor_info[0] = spawnstruct();
    level.mechz_armor_info[0].model = "c_zom_mech_armor_knee_left";
    level.mechz_armor_info[0].tag = "J_Knee_Attach_LE";
    level.mechz_armor_info[1] = spawnstruct();
    level.mechz_armor_info[1].model = "c_zom_mech_armor_knee_right";
    level.mechz_armor_info[1].tag = "J_Knee_attach_RI";
    level.mechz_armor_info[2] = spawnstruct();
    level.mechz_armor_info[2].model = "c_zom_mech_armor_shoulder_left";
    level.mechz_armor_info[2].tag = "J_ShoulderArmor_LE";
    level.mechz_armor_info[3] = spawnstruct();
    level.mechz_armor_info[3].model = "c_zom_mech_armor_shoulder_right";
    level.mechz_armor_info[3].tag = "J_ShoulderArmor_RI";
    level.mechz_armor_info[4] = spawnstruct();
    level.mechz_armor_info[4].tag = "J_Root_Attach_LE";
    level.mechz_armor_info[5] = spawnstruct();
    level.mechz_armor_info[5].tag = "J_Root_Attach_RI";

    for ( i = 0; i < level.mechz_armor_info.size; i++ )
    {
        if ( isdefined( level.mechz_armor_info[i].model ) )
            precachemodel( level.mechz_armor_info[i].model );
    }
}

mechz_setup_fx()
{
    self.fx_field = 0;
    self thread booster_fx_watcher();
    self thread flamethrower_fx_watcher();
}

clear_one_off_fx( fx_id )
{
    self endon( "death" );
    wait 10;
    self.fx_field &= ~fx_id;
    self setclientfield( "mechz_fx", self.fx_field );
}

traversal_booster_fx_watcher()
{
    self endon( "death" );

    while ( true )
    {
        self waittill( "traverse_anim", notetrack );

        if ( notetrack == "booster_on" )
        {
            self.fx_field |= 128;
            self.sndloopent playsound( "zmb_ai_mechz_rocket_start" );
            self.sndloopent playloopsound( "zmb_ai_mechz_rocket_loop", 0.75 );
        }
        else if ( notetrack == "booster_off" )
        {
            self.fx_field &= ~128;
            self.sndloopent playsound( "zmb_ai_mechz_rocket_stop" );
            self.sndloopent stoploopsound( 1 );
        }

        self setclientfield( "mechz_fx", self.fx_field );
    }
}

booster_fx_watcher()
{
    self endon( "death" );
    self thread traversal_booster_fx_watcher();

    while ( true )
    {
        self waittill( "jump_anim", notetrack );

        if ( isdefined( self.mechz_hidden ) && self.mechz_hidden )
            continue;

        if ( notetrack == "booster_on" )
        {
            self.fx_field |= 128;
            self.sndloopent playsound( "zmb_ai_mechz_rocket_start" );
            self.sndloopent playloopsound( "zmb_ai_mechz_rocket_loop", 0.75 );
        }
        else if ( notetrack == "booster_off" )
        {
            self.fx_field &= ~128;
            self.sndloopent playsound( "zmb_ai_mechz_rocket_stop" );
            self.sndloopent stoploopsound( 1 );
        }
        else if ( notetrack == "impact" )
        {
            self.fx_field |= 512;

            if ( isdefined( self.has_helmet ) && self.has_helmet )
                self.fx_field |= 2048;

            self thread clear_one_off_fx( 512 );
        }

        self setclientfield( "mechz_fx", self.fx_field );
    }
}

flamethrower_fx_watcher()
{
    self endon( "death" );

    while ( true )
    {
        self waittill( "flamethrower_anim", notetrack );

        if ( notetrack == "start_ft" )
            self.fx_field |= 64;
        else if ( notetrack == "stop_ft" )
            self.fx_field &= ~64;

        self setclientfield( "mechz_fx", self.fx_field );
    }
}

fx_cleanup()
{
    self.fx_field = 0;
    self setclientfield( "mechz_fx", self.fx_field );
    wait_network_frame();
}

mechz_setup_snd()
{
    self.audio_type = "mechz";

    if ( !isdefined( self.sndloopent ) )
    {
        self.sndloopent = spawn( "script_origin", self.origin );
        self.sndloopent linkto( self, "tag_origin" );
        self thread snddeleteentondeath( self.sndloopent );
    }

    self thread play_ambient_mechz_vocals();
}

snddeleteentondeath( ent )
{
    self waittill( "death" );

    ent delete();
}

play_ambient_mechz_vocals()
{
    self endon( "death" );
    wait( randomintrange( 2, 4 ) );

    while ( true )
    {
        if ( isdefined( self ) )
        {
            if ( isdefined( self.favoriteenemy ) && distance( self.origin, self.favoriteenemy.origin ) <= 150 )
            {

            }
            else
                self playsound( "zmb_ai_mechz_vox_ambient" );
        }

        wait( randomfloatrange( 3, 6 ) );
    }
}

enable_mechz_rounds()
{
/#
    if ( getdvarint( _hash_FA81816F ) >= 2 )
        return;
#/
    level.mechz_rounds_enabled = 1;
    flag_init( "mechz_round" );
    level thread mechz_round_tracker();
}

mechz_round_tracker()
{
    maps\mp\zombies\_zm_ai_mechz_ffotd::mechz_round_tracker_start();
    level.num_mechz_spawned = 0;
    old_spawn_func = level.round_spawn_func;
    old_wait_func = level.round_wait_func;

    while ( !isdefined( level.zombie_mechz_locations ) )
        wait 0.05;

    flag_wait( "activate_zone_nml" );
    mech_start_round_num = 8;

    if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
        mech_start_round_num = 8;

    while ( level.round_number < mech_start_round_num )
        level waittill( "between_round_over" );

    level.next_mechz_round = level.round_number;
    level thread debug_print_mechz_round();

    while ( true )
    {
        maps\mp\zombies\_zm_ai_mechz_ffotd::mechz_round_tracker_loop_start();

        if ( level.num_mechz_spawned > 0 )
            level.mechz_should_drop_powerup = 1;

        if ( level.next_mechz_round <= level.round_number )
        {
            a_zombies = getaispeciesarray( level.zombie_team, "all" );

            foreach ( zombie in a_zombies )
            {
                if ( isdefined( zombie.is_mechz ) && zombie.is_mechz && isalive( zombie ) )
                {
                    level.next_mechz_round++;
                    break;
                }
            }
        }

        if ( level.mechz_left_to_spawn == 0 && level.next_mechz_round <= level.round_number )
        {
            mechz_health_increases();

            if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
                level.mechz_zombie_per_round = 1;
            else if ( level.mechz_round_count < 2 )
                level.mechz_zombie_per_round = 1;
            else if ( level.mechz_round_count < 5 )
                level.mechz_zombie_per_round = 2;
            else
                level.mechz_zombie_per_round = 3;

            level.mechz_left_to_spawn = level.mechz_zombie_per_round;
            mechz_spawning = level.mechz_left_to_spawn;
            wait( randomfloatrange( 10.0, 15.0 ) );
            level notify( "spawn_mechz" );

            if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
                n_round_gap = randomintrange( level.mechz_min_round_fq_solo, level.mechz_max_round_fq_solo );
            else
                n_round_gap = randomintrange( level.mechz_min_round_fq, level.mechz_max_round_fq );

            level.next_mechz_round = level.round_number + n_round_gap;
            level.mechz_round_count++;
            level thread debug_print_mechz_round();
            level.num_mechz_spawned += mechz_spawning;
        }

        maps\mp\zombies\_zm_ai_mechz_ffotd::mechz_round_tracker_loop_end();

        level waittill( "between_round_over" );

        mechz_clear_spawns();
    }
}

debug_print_mechz_round()
{
    flag_wait( "start_zombie_round_logic" );
/#
    iprintln( "Next mechz Round = " + level.next_mechz_round );
#/
}

mechz_spawning_logic()
{
    level thread enable_mechz_rounds();

    while ( true )
    {
        level waittill( "spawn_mechz" );

        while ( level.mechz_left_to_spawn )
        {
            while ( level.zombie_mechz_locations.size < 1 )
                wait( randomfloatrange( 5.0, 10.0 ) );

            ai = spawn_zombie( level.mechz_spawners[0] );
            ai thread mechz_spawn();
            level.mechz_left_to_spawn--;

            if ( level.mechz_left_to_spawn == 0 )
                level thread response_to_air_raid_siren_vo();

            ai thread mechz_hint_vo();
            wait( randomfloatrange( 3.0, 6.0 ) );
        }
    }
}

mechz_prespawn()
{

}

mechz_attach_objects()
{
    self detachall();
    self.armor_state = [];

    for ( i = 0; i < level.mechz_armor_info.size; i++ )
    {
        self.armor_state[i] = spawnstruct();
        self.armor_state[i].index = i;
        self.armor_state[i].tag = level.mechz_armor_info[i].tag;

        if ( isdefined( level.mechz_armor_info[i].model ) )
        {
            self attach( level.mechz_armor_info[i].model, level.mechz_armor_info[i].tag, 1 );
            self.armor_state[i].model = level.mechz_armor_info[i].model;
        }
    }

    if ( isdefined( self.m_claw ) )
    {
        self.m_claw delete();
        self.m_claw = undefined;
    }

    org = self gettagorigin( "tag_claw" );
    ang = self gettagangles( "tag_claw" );
    self.m_claw = spawn( "script_model", org );
    self.m_claw setmodel( "c_zom_mech_claw" );
    self.m_claw.angles = ang;
    self.m_claw linkto( self, "tag_claw" );
    self.m_claw useanimtree( #animtree );

    if ( isdefined( self.m_claw_damage_trigger ) )
    {
        self.m_claw_damage_trigger unlink();
        self.m_claw_damage_trigger delete();
        self.m_claw_damage_trigger = undefined;
    }

    trigger_spawnflags = 0;
    trigger_radius = 3;
    trigger_height = 15;
    self.m_claw_damage_trigger = spawn( "trigger_damage", org, trigger_spawnflags, trigger_radius, trigger_height );
    self.m_claw_damage_trigger.angles = ang;
    self.m_claw_damage_trigger enablelinkto();
    self.m_claw_damage_trigger linkto( self, "tag_claw" );
    self thread mechz_claw_damage_trigger_thread();
    self attach( "c_zom_mech_faceplate", "J_Helmet", 0 );
    self.has_helmet = 1;
    self attach( "c_zom_mech_powersupply_cap", "tag_powersupply", 0 );
    self.has_powerplant = 1;
    self.powerplant_covered = 1;
    self.armor_state = array_randomize( self.armor_state );
}

mechz_set_starting_health()
{
    self.maxhealth = level.mechz_health;
    self.helmet_dmg = 0;
    self.helmet_dmg_for_removal = self.maxhealth * level.mechz_helmet_health_percentage;
    self.powerplant_cover_dmg = 0;
    self.powerplant_cover_dmg_for_removal = self.maxhealth * level.mechz_powerplant_expose_health_percentage;
    self.powerplant_dmg = 0;
    self.powerplant_dmg_for_destroy = self.maxhealth * level.mechz_powerplant_destroyed_health_percentage;
    level.mechz_explosive_dmg_to_cancel_claw = self.maxhealth * level.mechz_explosive_dmg_to_cancel_claw_percentage;
/#
    if ( getdvarint( _hash_E7121222 ) > 0 )
    {
        println( "\\nMZ: MechZ Starting Health: " + self.maxhealth );
        println( "\\nMZ: MechZ Required Helmet Dmg: " + self.helmet_dmg_for_removal );
        println( "\\nMZ: MechZ Required Powerplant Cover Dmg: " + self.powerplant_cover_dmg_for_removal );
        println( "\\nMZ: MechZ Required Powerplant Dmg: " + self.powerplant_dmg_for_destroy );
    }
#/
    self.health = level.mechz_health;
    self.non_attacker_func = ::mechz_non_attacker_damage_override;
    self.non_attack_func_takes_attacker = 1;
    self.actor_damage_func = ::mechz_damage_override;
    self.instakill_func = ::mechz_instakill_override;
    self.nuke_damage_func = ::mechz_nuke_override;
}

mechz_spawn()
{
    self maps\mp\zombies\_zm_ai_mechz_ffotd::spawn_start();
    self endon( "death" );
    level endon( "intermission" );
    self mechz_attach_objects();
    self mechz_set_starting_health();
    self mechz_setup_fx();
    self mechz_setup_snd();
    level notify( "sam_clue_mechz", self );
    self.closest_player_override = maps\mp\zombies\_zm_ai_mechz::get_favorite_enemy;
    self.animname = "mechz_zombie";
    self.has_legs = 1;
    self.no_gib = 1;
    self.ignore_all_poi = 1;
    self.is_mechz = 1;
    self.ignore_enemy_count = 1;
    self.no_damage_points = 1;
    self.melee_anim_func = ::melee_anim_func;
    self.meleedamage = 75;
    self.custom_item_dmg = 2000;
    recalc_zombie_array();
    self setphysparams( 20, 0, 80 );
    self setcandamage( 0 );
    self.zombie_init_done = 1;
    self notify( "zombie_init_done" );
    self.allowpain = 0;
    self animmode( "normal" );
    self orientmode( "face enemy" );
    self maps\mp\zombies\_zm_spawner::zombie_setup_attack_properties();
    self.completed_emerging_into_playable_area = 1;
    self notify( "completed_emerging_into_playable_area" );
    self.no_powerups = 0;
    self setfreecameralockonallowed( 0 );
    self notsolid();
    self thread maps\mp\zombies\_zm_spawner::zombie_eye_glow();
    level thread maps\mp\zombies\_zm_spawner::zombie_death_event( self );
    self thread maps\mp\zombies\_zm_spawner::enemy_death_detection();

    if ( level.zombie_mechz_locations.size )
        spawn_pos = self get_best_mechz_spawn_pos();

    if ( !isdefined( spawn_pos ) )
    {
/#
        println( "ERROR: Tried to spawn mechz with no mechz spawn_positions!\\n" );
        iprintln( "ERROR: Tried to spawn mechz with no mechz spawn_positions!" );
#/
        self delete();
        return;
    }

    if ( isdefined( level.mechz_force_spawn_pos ) )
    {
        spawn_pos = level.mechz_force_spawn_pos;
        level.mechz_force_spawn_pos = undefined;
    }

    if ( !isdefined( spawn_pos.angles ) )
        spawn_pos.angles = ( 0, 0, 0 );

    self thread mechz_death();
    self forceteleport( spawn_pos.origin, spawn_pos.angles );
    self playsound( "zmb_ai_mechz_incoming_alarm" );

    if ( !isdefined( spawn_pos.angles ) )
        spawn_pos.angles = ( 0, 0, 0 );

    self animscripted( spawn_pos.origin, spawn_pos.angles, "zm_spawn" );
    self maps\mp\animscripts\zm_shared::donotetracks( "jump_anim" );
    self setfreecameralockonallowed( 1 );
    self solid();
    self set_zombie_run_cycle( "walk" );

    if ( isdefined( level.mechz_find_flesh_override_func ) )
        level thread [[ level.mechz_find_flesh_override_func ]]();
    else
        self thread mechz_find_flesh();

    self thread mechz_jump_think( spawn_pos );
    self setcandamage( 1 );
    self init_anim_rate();
    self maps\mp\zombies\_zm_ai_mechz_ffotd::spawn_end();
}

get_closest_mechz_spawn_pos( org )
{
    best_dist = -1;
    best_pos = undefined;
    players = get_players();

    for ( i = 0; i < level.zombie_mechz_locations.size; i++ )
    {
        dist = distancesquared( org, level.zombie_mechz_locations[i].origin );

        if ( dist < best_dist || best_dist < 0 )
        {
            best_dist = dist;
            best_pos = level.zombie_mechz_locations[i];
        }
    }
/#
    if ( !isdefined( best_pos ) )
        println( "Error: Mechz could not find a valid jump pos from position ( " + self.origin[0] + ", " + self.origin[1] + ", " + self.origin[2] + " )" );
#/
    return best_pos;
}

get_best_mechz_spawn_pos( ignore_used_positions = 0 )
{
    best_dist = -1;
    best_pos = undefined;
    players = get_players();

    for ( i = 0; i < level.zombie_mechz_locations.size; i++ )
    {
        if ( !ignore_used_positions && ( isdefined( level.zombie_mechz_locations[i].has_been_used ) && level.zombie_mechz_locations[i].has_been_used ) )
            continue;

        if ( ignore_used_positions == 1 && ( isdefined( level.zombie_mechz_locations[i].used_cooldown ) && level.zombie_mechz_locations[i].used_cooldown ) )
            continue;

        for ( j = 0; j < players.size; j++ )
        {
            if ( is_player_valid( players[j], 1, 1 ) )
            {
                dist = distancesquared( level.zombie_mechz_locations[i].origin, players[j].origin );

                if ( dist < best_dist || best_dist < 0 )
                {
                    best_dist = dist;
                    best_pos = level.zombie_mechz_locations[i];
                }
            }
        }
    }

    if ( ignore_used_positions && isdefined( best_pos ) )
        best_pos thread jump_pos_used_cooldown();

    if ( isdefined( best_pos ) )
        best_pos.has_been_used = 1;
    else if ( level.zombie_mechz_locations.size > 0 )
        return level.zombie_mechz_locations[randomint( level.zombie_mechz_locations.size )];

    return best_pos;
}

mechz_clear_spawns()
{
    for ( i = 0; i < level.zombie_mechz_locations.size; i++ )
        level.zombie_mechz_locations[i].has_been_used = 0;
}

jump_pos_used_cooldown()
{
    self.used_cooldown = 1;
    wait 5.0;
    self.used_cooldown = 0;
}

mechz_health_increases()
{
    if ( !isdefined( level.mechz_last_spawn_round ) || level.round_number > level.mechz_last_spawn_round )
    {
        a_players = getplayers();
        n_player_modifier = 1;

        if ( a_players.size > 1 )
            n_player_modifier = a_players.size * 0.75;

        level.mechz_health = int( n_player_modifier * ( level.mechz_base_health + level.mechz_health_increase * level.mechz_round_count ) );

        if ( level.mechz_health >= 22500 * n_player_modifier )
            level.mechz_health = int( 22500 * n_player_modifier );

        level.mechz_last_spawn_round = level.round_number;
    }
}

mechz_death()
{
    self endon( "mechz_cleanup" );
    thread mechz_cleanup();

    self waittill( "death" );

    death_origin = self.origin;

    if ( isdefined( self.robot_stomped ) && self.robot_stomped )
        death_origin += vectorscale( ( 0, 0, 1 ), 90.0 );

    self mechz_claw_detach();
    self release_flamethrower_trigger();
    self.fx_field = 0;
    self setclientfield( "mechz_fx", self.fx_field );
    self thread maps\mp\zombies\_zm_spawner::zombie_eye_glow_stop();
    self mechz_interrupt();

    if ( isdefined( self.favoriteenemy ) )
    {
        if ( isdefined( self.favoriteenemy.hunted_by ) )
            self.favoriteenemy.hunted_by--;
    }

    self thread mechz_explode( "tag_powersupply", death_origin );

    if ( get_current_zombie_count() == 0 && level.zombie_total == 0 )
    {
        level.last_mechz_origin = self.origin;
        level notify( "last_mechz_down" );
    }

    if ( isplayer( self.attacker ) )
    {
        event = "death";

        if ( issubstr( self.damageweapon, "knife_ballistic_" ) )
            event = "ballistic_knife_death";

        self.attacker delay_thread( 4.0, maps\mp\zombies\_zm_audio::create_and_play_dialog, "general", "mech_defeated" );
        self.attacker maps\mp\zombies\_zm_score::player_add_points( event, self.damagemod, self.damagelocation, 1 );
        self.attacker maps\mp\zombies\_zm_stats::increment_client_stat( "tomb_mechz_killed", 0 );
        self.attacker maps\mp\zombies\_zm_stats::increment_player_stat( "tomb_mechz_killed" );

        if ( isdefined( level.mechz_should_drop_powerup ) && level.mechz_should_drop_powerup )
        {
            wait_network_frame();
            wait_network_frame();
            level.mechz_should_drop_powerup = 0;

            if ( level.powerup_drop_count >= level.zombie_vars["zombie_powerup_drop_max_per_round"] )
                level.powerup_drop_count = level.zombie_vars["zombie_powerup_drop_max_per_round"] - 1;

            level.zombie_vars["zombie_drop_item"] = 1;
            level thread maps\mp\zombies\_zm_powerups::powerup_drop( self.origin );
        }
    }
}

mechz_explode( str_tag, death_origin )
{
    wait 2.0;
    v_origin = self gettagorigin( str_tag );
    level notify( "mechz_exploded", v_origin );
    playsoundatposition( "zmb_ai_mechz_death_explode", v_origin );
    playfx( level._effect["mechz_death"], v_origin );
    radiusdamage( v_origin, 128, 100, 25, undefined, "MOD_GRENADE_SPLASH" );
    earthquake( 0.5, 1.0, v_origin, 256 );
    playrumbleonposition( "grenade_rumble", v_origin );
    level notify( "mechz_killed", death_origin );
}

mechz_cleanup()
{
    self waittill( "mechz_cleanup" );

    self mechz_interrupt();
    level.sndmechzistalking = 0;

    if ( isdefined( self.sndmechzmusicent ) )
    {
        self.sndmechzmusicent delete();
        self.sndmechzmusicent = undefined;
    }

    if ( isdefined( self.favoriteenemy ) )
    {
        if ( isdefined( self.favoriteenemy.hunted_by ) )
            self.favoriteenemy.hunted_by--;
    }
}

mechz_interrupt()
{
    self notify( "kill_claw" );
    self notify( "kill_ft" );
    self notify( "kill_jump" );
}

mechz_stun( time )
{
    self endon( "death" );

    if ( !isalive( self ) || isdefined( self.not_interruptable ) && self.not_interruptable || isdefined( self.is_traversing ) && self.is_traversing )
        return;

    curr_time = 0;
    anim_time = self getanimlengthfromasd( "zm_stun", 0 );
    self mechz_interrupt();
    self mechz_claw_detach();
    wait 0.05;
    self.not_interruptable = 1;
/#
    if ( getdvarint( _hash_E7121222 ) > 1 )
        println( "\\nMZ: Stun setting not interruptable\\n" );
#/
    while ( curr_time < time )
    {
        self animscripted( self.origin, self.angles, "zm_stun" );
        self maps\mp\animscripts\zm_shared::donotetracks( "stun_anim" );
        self clearanim( %root, 0 );
        curr_time += anim_time;
    }

    self.not_interruptable = 0;
/#
    if ( getdvarint( _hash_E7121222 ) > 1 )
        println( "\\nMZ: Stun clearing not interruptable\\n" );
#/
}

mechz_tank_hit_callback()
{
    self endon( "death" );

    if ( isdefined( self.mechz_hit_by_tank ) && self.mechz_hit_by_tank )
        return;
/#
    if ( getdvarint( _hash_E7121222 ) > 1 )
        println( "\\nMZ: Tank damage setting not interruptable\\n" );
#/
    self.not_interruptable = 1;
    self.mechz_hit_by_tank = 1;
    self mechz_interrupt();
    v_trace_start = self.origin + vectorscale( ( 0, 0, 1 ), 100.0 );
    v_trace_end = self.origin - vectorscale( ( 0, 0, 1 ), 500.0 );
    v_trace = physicstrace( self.origin, v_trace_end, ( -15, -15, -5 ), ( 15, 15, 5 ), self );
    self.origin = v_trace["position"];
    timer = 0;
    self animscripted( self.origin, self.angles, "zm_tank_hit_in" );
    self maps\mp\animscripts\zm_shared::donotetracks( "pain_anim" );
    anim_length = self getanimlengthfromasd( "zm_tank_hit_loop", 0 );

    while ( timer < level.mechz_tank_knockdown_time )
    {
        timer += anim_length;
        self animscripted( self.origin, self.angles, "zm_tank_hit_loop" );
        self maps\mp\animscripts\zm_shared::donotetracks( "pain_anim" );
    }

    self animscripted( self.origin, self.angles, "zm_tank_hit_out" );
    self maps\mp\animscripts\zm_shared::donotetracks( "pain_anim" );
/#
    if ( getdvarint( _hash_E7121222 ) > 1 )
        println( "\\nMZ: Tank damage clearing not interruptable\\n" );
#/
    self.not_interruptable = 0;
    self.mechz_hit_by_tank = 0;

    if ( !level.vh_tank ent_flag( "tank_moving" ) && self istouching( level.vh_tank ) )
    {
        self notsolid();
        self ghost();
        self.mechz_hidden = 1;

        if ( isdefined( self.m_claw ) )
            self.m_claw ghost();

        self.fx_field_old = self.fx_field;
        self thread maps\mp\zombies\_zm_spawner::zombie_eye_glow_stop();
        self fx_cleanup();
        self mechz_do_jump();
        self solid();
        self.mechz_hidden = 0;
    }
}

mechz_robot_stomp_callback()
{
    self endon( "death" );

    if ( isdefined( self.robot_stomped ) && self.robot_stomped )
        return;

    self.not_interruptable = 1;
    self.robot_stomped = 1;
    self mechz_interrupt();
/#
    if ( getdvarint( _hash_E7121222 ) > 1 )
        println( "\\nMZ: Robot stomp setting not interruptable\\n" );
#/
    self thread mechz_stomped_by_giant_robot_vo();
    v_trace_start = self.origin + vectorscale( ( 0, 0, 1 ), 100.0 );
    v_trace_end = self.origin - vectorscale( ( 0, 0, 1 ), 500.0 );
    v_trace = physicstrace( self.origin, v_trace_end, ( -15, -15, -5 ), ( 15, 15, 5 ), self );
    self.origin = v_trace["position"];
    timer = 0;
    self animscripted( self.origin, self.angles, "zm_robot_hit_in" );
    self maps\mp\animscripts\zm_shared::donotetracks( "pain_anim" );
    anim_length = self getanimlengthfromasd( "zm_robot_hit_loop", 0 );

    while ( timer < level.mechz_robot_knockdown_time )
    {
        timer += anim_length;
        self animscripted( self.origin, self.angles, "zm_robot_hit_loop" );
        self maps\mp\animscripts\zm_shared::donotetracks( "pain_anim" );
    }

    self animscripted( self.origin, self.angles, "zm_robot_hit_out" );
    self maps\mp\animscripts\zm_shared::donotetracks( "jump_anim" );
/#
    if ( getdvarint( _hash_E7121222 ) > 1 )
        println( "\\nMZ: Robot stomp clearing not interruptable\\n" );
#/
    self.not_interruptable = 0;
    self.robot_stomped = 0;
}

mechz_delayed_item_delete()
{
    wait 30;
    self delete();
}

mechz_get_closest_valid_player()
{
    players = get_players();

    if ( isdefined( self.ignore_player ) )
    {
        for ( i = 0; i < self.ignore_player.size; i++ )
            arrayremovevalue( players, self.ignore_player[i] );
    }

    for ( i = 0; i < players.size; i++ )
    {
        if ( isdefined( level._zombie_using_humangun ) && level._zombie_using_humangun && isai( players[i] ) )
            return players[i];

        if ( !is_player_valid( players[i], 1, 1 ) )
        {
            arrayremovevalue( players, players[i] );
            i--;
        }
    }

    switch ( players.size )
    {
        case 0:
            return undefined;
        case 1:
            return players[0];
        default:
            if ( isdefined( level.closest_player_override ) )
                player = [[ level.closest_player_override ]]( self.origin, players );
            else if ( isdefined( level.calc_closest_player_using_paths ) && level.calc_closest_player_using_paths )
                player = get_closest_player_using_paths( self.origin, players );
            else
                player = getclosest( self.origin, players );

            return player;
    }
}

get_favorite_enemy( origin, players )
{
    mechz_targets = getplayers();
    least_hunted = undefined;
    best_hunted_val = -1;
    best_dist = -1;
    distances = [];

    if ( isdefined( self.favoriteenemy ) && is_player_valid( self.favoriteenemy, 1, 1 ) && !isdefined( self.favoriteenemy.in_giant_robot_head ) && !self.favoriteenemy maps\mp\zm_tomb_chamber::is_player_in_chamber() )
    {
        assert( isdefined( self.favoriteenemy.hunted_by ) );
        self.favoriteenemy.hunted_by--;
        least_hunted = self.favoriteenemy;
    }

    for ( i = 0; i < mechz_targets.size; i++ )
    {
        if ( !isdefined( mechz_targets[i].hunted_by ) || mechz_targets[i].hunted_by < 0 )
            mechz_targets[i].hunted_by = 0;

        if ( !is_player_valid( mechz_targets[i], 1, 1 ) )
        {
            distances[i] = undefined;
            continue;
        }

        distances[i] = distancesquared( self.origin, mechz_targets[i].origin );
    }

    found_weapon_target = 0;

    for ( i = 0; i < mechz_targets.size; i++ )
    {
        if ( abs( mechz_targets[i].origin[2] - self.origin[2] ) > 60 )
            continue;

        dist = distances[i];

        if ( !isdefined( dist ) )
            continue;

        if ( dist < 50000 && ( dist < best_dist || best_dist < 0 ) )
        {
            found_weapon_target = 1;
            least_hunted = mechz_targets[i];
            best_dist = dist;
        }
    }

    if ( found_weapon_target )
    {
        least_hunted.hunted_by++;
        return least_hunted;
    }

    if ( isdefined( self.favoriteenemy ) && is_player_valid( self.favoriteenemy, 1, 1 ) )
    {
        if ( distancesquared( self.origin, self.favoriteenemy.origin ) <= level.mechz_sticky_dist_sq )
        {
            self.favoriteenemy.hunted_by++;
            return self.favoriteenemy;
        }
    }

    for ( i = 0; i < mechz_targets.size; i++ )
    {
        if ( isdefined( mechz_targets[i].in_giant_robot_head ) )
            continue;

        if ( mechz_targets[i] maps\mp\zm_tomb_chamber::is_player_in_chamber() )
            continue;

        if ( isdefined( distances[i] ) )
            dist = distances[i];
        else
            continue;

        hunted = mechz_targets[i].hunted_by;

        if ( !isdefined( least_hunted ) || hunted <= least_hunted.hunted_by )
        {
            if ( dist < best_dist || best_dist < 0 )
            {
                least_hunted = mechz_targets[i];
                best_dist = dist;
            }
        }
    }

    if ( isdefined( least_hunted ) )
        least_hunted.hunted_by++;

    return least_hunted;
}

mechz_check_in_arc( right_offset )
{
    origin = self.origin;

    if ( isdefined( right_offset ) )
    {
        right_angle = anglestoright( self.angles );
        origin += right_angle * right_offset;
    }

    facing_vec = anglestoforward( self.angles );
    enemy_vec = self.favoriteenemy.origin - origin;
    enemy_yaw_vec = ( enemy_vec[0], enemy_vec[1], 0 );
    facing_yaw_vec = ( facing_vec[0], facing_vec[1], 0 );
    enemy_yaw_vec = vectornormalize( enemy_yaw_vec );
    facing_yaw_vec = vectornormalize( facing_yaw_vec );
    enemy_dot = vectordot( facing_yaw_vec, enemy_yaw_vec );

    if ( enemy_dot < cos( level.mechz_aim_max_yaw ) )
        return false;

    enemy_angles = vectortoangles( enemy_vec );

    if ( abs( angleclamp180( enemy_angles[0] ) ) > level.mechz_aim_max_pitch )
        return false;

    return true;
}

mechz_get_aim_anim( anim_prefix, target_pos, right_offset )
{
    in_arc = self mechz_check_in_arc( right_offset );

    if ( !in_arc )
        return undefined;

    origin = self.origin;

    if ( isdefined( right_offset ) )
    {
        right_angle = anglestoright( self.angles );
        origin += right_angle * right_offset;
    }

    aiming_vec = vectortoangles( target_pos - origin );
    pitch = angleclamp180( aiming_vec[0] );
    yaw = angleclamp180( self.angles[1] - aiming_vec[1] );
    centered_ud = abs( pitch ) < level.mechz_aim_max_pitch / 2;
    centered_lr = abs( yaw ) < level.mechz_aim_max_yaw / 2;
    right_anim = angleclamp180( self.angles[1] - aiming_vec[1] ) > 0;
    up_anim = pitch < 0;

    if ( centered_ud && centered_lr )
        return anim_prefix + "_aim_5";
    else if ( centered_ud && right_anim )
        return anim_prefix + "_aim_6";
    else if ( centered_ud )
        return anim_prefix + "_aim_4";
    else if ( centered_lr && up_anim )
        return anim_prefix + "_aim_8";
    else if ( centered_lr )
        return anim_prefix + "_aim_2";
    else if ( right_anim && up_anim )
        return anim_prefix + "_aim_9";
    else if ( right_anim )
        return anim_prefix + "_aim_3";
    else if ( up_anim )
        return anim_prefix + "_aim_7";
    else
        return anim_prefix + "_aim_1";
}

mechz_start_basic_find_flesh()
{
    self.goalradius = level.mechz_custom_goalradius;
    self.custom_goalradius_override = level.mechz_custom_goalradius;

    if ( !isdefined( self.ai_state ) || self.ai_state != "find_flesh" )
    {
        self.ai_state = "find_flesh";
        self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
    }
}

mechz_stop_basic_find_flesh()
{
    if ( isdefined( self.ai_state ) && self.ai_state == "find_flesh" )
    {
        self.ai_state = undefined;
        self notify( "stop_find_flesh" );
        self notify( "zombie_acquire_enemy" );
    }
}

watch_for_player_dist()
{
    self endon( "death" );

    while ( true )
    {
        player = mechz_get_closest_valid_player();

        if ( isdefined( player ) && ( isdefined( player.is_player_slowed ) && player.is_player_slowed ) )
            reset_dist = level.mechz_reset_dist_sq / 2;
        else
            reset_dist = level.mechz_reset_dist_sq;

        if ( !isdefined( player ) || distancesquared( player.origin, self.origin ) > reset_dist )
            self.disable_complex_behaviors = 0;

        wait 0.5;
    }
}

mechz_find_flesh()
{
    self endon( "death" );
    level endon( "intermission" );

    if ( level.intermission )
        return;

    self.helitarget = 1;
    self.ignoreme = 0;
    self.nododgemove = 1;
    self.ignore_player = [];
    self.goalradius = 32;
    self.ai_state = "spawning";
    self thread watch_for_player_dist();

    while ( true )
    {
/#
        if ( isdefined( self.force_behavior ) && self.force_behavior )
        {
            wait 0.05;
            continue;
        }
#/
        if ( isdefined( self.not_interruptable ) && self.not_interruptable )
        {
/#
            if ( getdvarint( _hash_E7121222 ) > 1 )
                println( "\\nMZ: Not thinking since a behavior has set not_interruptable\\n" );
#/
            wait 0.05;
            continue;
        }

        if ( isdefined( self.is_traversing ) && self.is_traversing )
        {
/#
            if ( getdvarint( _hash_E7121222 ) > 1 )
                println( "\\nMZ: Not thinking since mech is traversing\\n" );
#/
            wait 0.05;
            continue;
        }

        player = [[ self.closest_player_override ]]();
        self mechz_set_locomotion_speed();
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\nMZ: Doing think\\n" );
#/
        self.favoriteenemy = player;

        if ( !isdefined( player ) )
        {
/#
            if ( getdvarint( _hash_E7121222 ) > 1 )
                println( "\\n\\tMZ: No Enemy, idling\\n" );
#/
            self.goal_pos = self.origin;
            self setgoalpos( self.goal_pos );
            self.ai_state = "idle";
            self setanimstatefromasd( "zm_idle" );
            wait 0.5;
            continue;
        }

        if ( player entity_on_tank() )
        {
            if ( level.vh_tank ent_flag( "tank_moving" ) )
            {
                if ( isdefined( self.jump_pos ) && self mechz_in_range_for_jump() )
                {
/#
                    if ( getdvarint( _hash_E7121222 ) > 1 )
                        println( "\\n\\tMZ: Enemy on moving tank, do jump out and jump in when tank is stationary\\n" );
#/
                    self mechz_do_jump( 1 );
                }
                else
                {
/#
                    if ( getdvarint( _hash_E7121222 ) > 1 )
                        println( "\\n\\tMZ: Enemy on moving tank, Jump Requested, going to jump pos\\n" );
#/
                    if ( !isdefined( self.jump_pos ) )
                        self.jump_pos = get_closest_mechz_spawn_pos( self.origin );

                    if ( isdefined( self.jump_pos ) )
                    {
                        self.goal_pos = self.jump_pos.origin;
                        self setgoalpos( self.goal_pos );
                    }

                    wait 0.5;
                    continue;
                }
            }
            else
            {
/#
                if ( getdvarint( _hash_E7121222 ) > 1 )
                    println( "\\n\\tMZ: Enemy on tank, targetting a tank pos\\n" );
#/
                self.disable_complex_behaviors = 0;
                self mechz_stop_basic_find_flesh();
                self.ai_state = "tracking_tank";
                self.goalradius = level.mechz_custom_goalradius;
                self.custom_goalradius_override = level.mechz_custom_goalradius;
                closest_tank_tag = level.vh_tank get_closest_mechz_tag_on_tank( self, self.origin );

                if ( !isdefined( closest_tank_tag ) )
                {
/#
                    if ( getdvarint( _hash_E7121222 ) > 1 )
                        println( "\\n\\tMZ: Enemy on tank, no closest tank pos found, continuing\\n" );
#/
                    wait 0.5;
                    continue;
                }

                closest_tank_tag_pos = level.vh_tank gettagorigin( closest_tank_tag );

                if ( abs( self.origin[2] - closest_tank_tag_pos[2] ) >= level.mechz_custom_goalradius || distance2dsquared( self.origin, closest_tank_tag_pos ) >= level.mechz_custom_goalradius_sq )
                {
/#
                    if ( getdvarint( _hash_E7121222 ) > 1 )
                        println( "\\n\\tMZ: Enemy on tank, setting tank pos as goal\\n" );
#/
                    self.goal_pos = closest_tank_tag_pos;
                    self setgoalpos( self.goal_pos );
                    self waittill_any_or_timeout( 0.5, "goal", "bad_path" );

                    if ( !player entity_on_tank() )
                    {
/#
                        if ( getdvarint( _hash_E7121222 ) > 1 )
                            println( "\\n\\tMZ: Enemy got off tank by the time we reached our goal, continuing\\n" );
#/
                        continue;
                    }
                }

                if ( abs( self.origin[2] - closest_tank_tag_pos[2] ) < level.mechz_custom_goalradius && distance2dsquared( self.origin, closest_tank_tag_pos ) < level.mechz_custom_goalradius_sq )
                {
/#
                    if ( getdvarint( _hash_E7121222 ) > 1 )
                        println( "\\n\\tMZ: Enemy on tank, reached tank pos, doing flamethrower sweep\\n" );
#/
                    self.angles = vectortoangles( level.vh_tank.origin - self.origin );
                    self mechz_do_flamethrower_attack( 1 );
                    self notify( "tank_flamethrower_attack_complete" );
                }
            }

            continue;
        }
        else if ( isdefined( self.jump_requested ) && self.jump_requested || isdefined( self.force_jump ) && self.force_jump )
        {
            if ( self mechz_in_range_for_jump() )
                self mechz_do_jump();
            else
            {
/#
                if ( getdvarint( _hash_E7121222 ) > 1 )
                    println( "\\n\\tMZ: Jump Requested, going to jump pos\\n" );
#/
                self.goal_pos = self.jump_pos.origin;
                self setgoalpos( self.goal_pos );
                wait 0.5;
                continue;
            }
        }
        else if ( self.zombie_move_speed == "sprint" && isdefined( player ) )
        {
/#
            if ( getdvarint( _hash_E7121222 ) > 1 )
                println( "\\n\\tMZ: Sprinting\\n" );
#/
            self.goal_pos = player.origin;
            self setgoalpos( self.goal_pos );
            wait 0.5;
            continue;
        }
        else if ( distancesquared( self.origin, player.origin ) < level.mechz_aggro_dist_sq )
        {
/#
            if ( getdvarint( _hash_E7121222 ) > 1 )
                println( "\\n\\tMZ: Player very close, switching to melee only\\n" );
#/
            self.disable_complex_behaviors = 1;
        }
        else if ( self should_do_claw_attack() )
        {
            self mechz_do_claw_grab();
            continue;
        }
        else if ( self should_do_flamethrower_attack() )
        {
            self mechz_do_flamethrower_attack();
            continue;
        }
/#
        if ( getdvarint( _hash_E7121222 ) > 1 )
            println( "\\n\\tMZ: No special behavior valid, heading after player\\n" );
#/
        self.goal_pos = player.origin;

        if ( isdefined( level.damage_prone_players_override_func ) )
            level thread [[ level.damage_prone_players_override_func ]]();
        else
            self thread damage_prone_players();

        mechz_start_basic_find_flesh();
        wait 0.5;
    }
}

damage_prone_players()
{
    self endon( "death" );
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( isdefined( self.favoriteenemy ) && self.favoriteenemy == player )
        {
            n_dist = distance2dsquared( player.origin, self.origin );

            if ( n_dist < 2025 )
            {
                player_z = player.origin[2];
                mechz_z = self.origin[2];

                if ( player_z < mechz_z && mechz_z - player_z <= 75 )
                {
                    if ( isdefined( self.meleedamage ) )
                        idamage = self.meleedamage;
                    else
                        idamage = 50;

                    player dodamage( idamage, self.origin, self, self, "none", "MOD_MELEE" );
                }
            }
        }
    }
}

melee_anim_func()
{
    self.next_leap_time = gettime() + 1500;
}

mechz_launch_armor_piece()
{
    if ( !isdefined( self.next_armor_piece ) )
        self.next_armor_piece = 0;

    if ( !isdefined( self.armor_state ) || self.next_armor_piece >= self.armor_state.size )
    {
/#
        println( "Trying to launch armor piece after all pieces have already been launched!" );
#/
        return;
    }

    if ( isdefined( self.armor_state[self.next_armor_piece].model ) )
        self detach( self.armor_state[self.next_armor_piece].model, self.armor_state[self.next_armor_piece].tag );

    self.fx_field |= 1 << self.armor_state[self.next_armor_piece].index;
    self setclientfield( "mechz_fx", self.fx_field );

    if ( sndmechzisnetworksafe( "destruction" ) )
        self playsound( "zmb_ai_mechz_destruction" );

    self.next_armor_piece++;
}

mechz_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, poffsettime, boneindex )
{
    num_tiers = level.mechz_armor_info.size + 1;
    old_health_tier = int( num_tiers * self.health / self.maxhealth );
    bonename = getpartname( "c_zom_mech_body", boneindex );

    if ( isdefined( attacker ) && isalive( attacker ) && isplayer( attacker ) && ( level.zombie_vars[attacker.team]["zombie_insta_kill"] || isdefined( attacker.personal_instakill ) && attacker.personal_instakill ) )
    {
        n_mechz_damage_percent = 1.0;
        n_mechz_headshot_modifier = 2.0;
    }
    else
    {
        n_mechz_damage_percent = level.mechz_damage_percent;
        n_mechz_headshot_modifier = 1.0;
    }

    if ( isdefined( weapon ) && is_weapon_shotgun( weapon ) )
    {
        n_mechz_damage_percent *= level.mechz_shotgun_damage_mod;
        n_mechz_headshot_modifier *= level.mechz_shotgun_damage_mod;
    }

    if ( damage <= 10 )
        n_mechz_damage_percent = 1.0;

    if ( is_explosive_damage( meansofdeath ) || issubstr( weapon, "staff" ) )
    {
        if ( n_mechz_damage_percent < 0.5 )
            n_mechz_damage_percent = 0.5;

        if ( !( isdefined( self.has_helmet ) && self.has_helmet ) && issubstr( weapon, "staff" ) && n_mechz_damage_percent < 1.0 )
            n_mechz_damage_percent = 1.0;

        final_damage = damage * n_mechz_damage_percent;

        if ( !isdefined( self.explosive_dmg_taken ) )
            self.explosive_dmg_taken = 0;

        self.explosive_dmg_taken += final_damage;
        self.helmet_dmg += final_damage;

        if ( isdefined( self.explosive_dmg_taken_on_grab_start ) )
        {
            if ( isdefined( self.e_grabbed ) && self.explosive_dmg_taken - self.explosive_dmg_taken_on_grab_start > level.mechz_explosive_dmg_to_cancel_claw )
            {
                if ( isdefined( self.has_helmet ) && self.has_helmet && self.helmet_dmg < self.helmet_dmg_for_removal || !( isdefined( self.has_helmet ) && self.has_helmet ) )
                    self thread mechz_claw_shot_pain_reaction();

                self thread ent_released_from_claw_grab_achievement( attacker, self.e_grabbed );
                self thread mechz_claw_release();
            }
        }
    }
    else if ( shitloc != "head" && shitloc != "helmet" )
    {
        if ( bonename == "tag_powersupply" )
        {
            final_damage = damage * n_mechz_damage_percent;

            if ( !( isdefined( self.powerplant_covered ) && self.powerplant_covered ) )
                self.powerplant_dmg += final_damage;
            else
                self.powerplant_cover_dmg += final_damage;
        }

        if ( isdefined( self.e_grabbed ) && ( shitloc == "left_hand" || shitloc == "left_arm_lower" || shitloc == "left_arm_upper" ) )
        {
            if ( isdefined( self.e_grabbed ) )
                self thread mechz_claw_shot_pain_reaction();

            self thread ent_released_from_claw_grab_achievement( attacker, self.e_grabbed );
            self thread mechz_claw_release( 1 );
        }

        final_damage = damage * n_mechz_damage_percent;
    }
    else if ( !( isdefined( self.has_helmet ) && self.has_helmet ) )
        final_damage = damage * n_mechz_headshot_modifier;
    else
    {
        final_damage = damage * n_mechz_damage_percent;
        self.helmet_dmg += final_damage;
    }

    if ( !isdefined( weapon ) || weapon == "none" )
    {
        if ( !isplayer( attacker ) )
            final_damage = 0;
    }

    new_health_tier = int( num_tiers * ( self.health - final_damage ) / self.maxhealth );

    if ( old_health_tier > new_health_tier )
    {
        while ( old_health_tier > new_health_tier )
        {
/#
            if ( getdvarint( _hash_E7121222 ) > 0 )
                println( "\\nMZ: Old tier: " + old_health_tier + "   New Health Tier: " + new_health_tier + "   Launching armor piece" );
#/
            if ( old_health_tier < num_tiers )
                self mechz_launch_armor_piece();

            old_health_tier--;
        }
    }

    if ( isdefined( self.has_helmet ) && self.has_helmet && self.helmet_dmg >= self.helmet_dmg_for_removal )
    {
        self.has_helmet = 0;
        self detach( "c_zom_mech_faceplate", "J_Helmet" );

        if ( sndmechzisnetworksafe( "destruction" ) )
            self playsound( "zmb_ai_mechz_destruction" );

        if ( sndmechzisnetworksafe( "angry" ) )
            self playsound( "zmb_ai_mechz_vox_angry" );

        self.fx_field |= 1024;
        self.fx_field &= ~2048;
        self setclientfield( "mechz_fx", self.fx_field );

        if ( !( isdefined( self.not_interruptable ) && self.not_interruptable ) && !( isdefined( self.is_traversing ) && self.is_traversing ) )
        {
            self mechz_interrupt();
            self animscripted( self.origin, self.angles, "zm_pain_faceplate" );
            self maps\mp\animscripts\zm_shared::donotetracks( "pain_anim_faceplate" );
        }

        self thread shoot_mechz_head_vo();
    }

    if ( isdefined( self.powerplant_covered ) && self.powerplant_covered && self.powerplant_cover_dmg >= self.powerplant_cover_dmg_for_removal )
    {
        self.powerplant_covered = 0;
        self detach( "c_zom_mech_powersupply_cap", "tag_powersupply" );
        cap_model = spawn( "script_model", self gettagorigin( "tag_powersupply" ) );
        cap_model.angles = self gettagangles( "tag_powersupply" );
        cap_model setmodel( "c_zom_mech_powersupply_cap" );
        cap_model physicslaunch( cap_model.origin, anglestoforward( cap_model.angles ) );
        cap_model thread mechz_delayed_item_delete();

        if ( sndmechzisnetworksafe( "destruction" ) )
            self playsound( "zmb_ai_mechz_destruction" );

        if ( !( isdefined( self.not_interruptable ) && self.not_interruptable ) && !( isdefined( self.is_traversing ) && self.is_traversing ) )
        {
            self mechz_interrupt();
            self animscripted( self.origin, self.angles, "zm_pain_powercore" );
            self maps\mp\animscripts\zm_shared::donotetracks( "pain_anim_powercore" );
        }
    }
    else if ( !( isdefined( self.powerplant_covered ) && self.powerplant_covered ) && ( isdefined( self.has_powerplant ) && self.has_powerplant ) && self.powerplant_dmg >= self.powerplant_dmg_for_destroy )
    {
        self.has_powerplant = 0;
        self thread mechz_stun( level.mechz_powerplant_stun_time );

        if ( sndmechzisnetworksafe( "destruction" ) )
            self playsound( "zmb_ai_mechz_destruction" );
    }
/#
    if ( getdvarint( _hash_E7121222 ) > 0 )
    {
        println( "\\nMZ: Doing " + final_damage + " damage to mechz,   Health Remaining: " + self.health );

        if ( self.helmet_dmg < self.helmet_dmg_for_removal )
            println( "\\nMZ: Current helmet dmg: " + self.helmet_dmg + "    Required helmet dmg: " + self.helmet_dmg_for_removal );
    }
#/
    return final_damage;
}

mechz_non_attacker_damage_override( damage, weapon, attacker )
{
    if ( attacker == level.vh_tank )
        self thread mechz_tank_hit_callback();

    return 0;
}

mechz_instakill_override()
{

}

mechz_nuke_override()
{
    self endon( "death" );
    wait( randomfloatrange( 0.1, 0.7 ) );
    self playsound( "evt_nuked" );
    self dodamage( self.health * 0.25, self.origin );
}

mechz_set_locomotion_speed()
{
    self endon( "death" );
    self.prev_move_speed = self.zombie_move_speed;

    if ( !isdefined( self.favoriteenemy ) )
        self.zombie_move_speed = "walk";
    else if ( isdefined( self.force_run ) && self.force_run )
        self.zombie_move_speed = "run";
    else if ( isdefined( self.force_sprint ) && self.force_sprint )
        self.zombie_move_speed = "sprint";
    else if ( isdefined( self.favoriteenemy ) && self.favoriteenemy entity_on_tank() && isdefined( level.vh_tank ) && level.vh_tank ent_flag( "tank_activated" ) )
        self.zombie_move_speed = "run";
    else if ( isdefined( self.favoriteenemy ) && distancesquared( self.origin, self.favoriteenemy.origin ) > level.mechz_dist_for_sprint )
        self.zombie_move_speed = "run";
    else if ( !( isdefined( self.has_powerplant ) && self.has_powerplant ) )
        self.zombie_move_speed = "walk";
    else
        self.zombie_move_speed = "walk";

    if ( self.zombie_move_speed == "sprint" && self.prev_move_speed != "sprint" )
    {
        self mechz_interrupt();
        self animscripted( self.origin, self.angles, "zm_sprint_intro" );
        self maps\mp\animscripts\zm_shared::donotetracks( "jump_anim" );
    }
    else if ( self.zombie_move_speed != "sprint" && self.prev_move_speed == "sprint" )
    {
        self animscripted( self.origin, self.angles, "zm_sprint_outro" );
        self maps\mp\animscripts\zm_shared::donotetracks( "jump_anim" );
    }

    self set_zombie_run_cycle( self.zombie_move_speed );
}

response_to_air_raid_siren_vo()
{
    wait 3.0;
    a_players = getplayers();

    if ( a_players.size == 0 )
        return;

    a_players = array_randomize( a_players );

    foreach ( player in a_players )
    {
        if ( is_player_valid( player ) )
        {
            if ( !( isdefined( player.dontspeak ) && player.dontspeak ) )
            {
                if ( !isdefined( level.air_raid_siren_count ) )
                {
                    player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "siren_1st_time" );
                    level.air_raid_siren_count = 1;

                    while ( isdefined( player ) && ( isdefined( player.isspeaking ) && player.isspeaking ) )
                        wait 0.1;

                    level thread start_see_mech_zombie_vo();
                    break;
                }
                else if ( level.mechz_zombie_per_round == 1 )
                {
                    player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "siren_generic" );
                    break;
                }
                else
                {
                    player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "multiple_mechs" );
                    break;
                }
            }
        }
    }
}

start_see_mech_zombie_vo()
{
    wait 1.0;
    a_zombies = getaispeciesarray( level.zombie_team, "all" );

    foreach ( zombie in a_zombies )
    {
        if ( isdefined( zombie.is_mechz ) && zombie.is_mechz )
            ai_mechz = zombie;
    }

    a_players = getplayers();

    if ( a_players.size == 0 )
        return;

    if ( isalive( ai_mechz ) )
    {
        foreach ( player in a_players )
            player thread player_looking_at_mechz_watcher( ai_mechz );
    }
}

player_looking_at_mechz_watcher( ai_mechz )
{
    self endon( "disconnect" );
    ai_mechz endon( "death" );
    level endon( "first_mech_zombie_seen" );

    while ( true )
    {
        if ( distancesquared( self.origin, ai_mechz.origin ) < 1000000 )
        {
            if ( self is_player_looking_at( ai_mechz.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), 0.75 ) )
            {
                if ( !( isdefined( self.dontspeak ) && self.dontspeak ) )
                {
                    self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "discover_mech" );
                    level notify( "first_mech_zombie_seen" );
                    break;
                }
            }
        }

        wait 0.1;
    }
}

mechz_grabbed_played_vo( ai_mechz )
{
    self endon( "disconnect" );
    self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "mech_grab" );

    while ( isdefined( self ) && ( isdefined( self.isspeaking ) && self.isspeaking ) )
        wait 0.1;

    wait 1.0;

    if ( isalive( ai_mechz ) && isdefined( ai_mechz.e_grabbed ) )
        ai_mechz thread play_shoot_arm_hint_vo();
}

play_shoot_arm_hint_vo()
{
    self endon( "death" );

    while ( true )
    {
        if ( !isdefined( self.e_grabbed ) )
            return;

        a_players = getplayers();

        foreach ( player in a_players )
        {
            if ( player == self.e_grabbed )
                continue;

            if ( distancesquared( self.origin, player.origin ) < 1000000 )
            {
                if ( player is_player_looking_at( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), 0.75 ) )
                {
                    if ( !( isdefined( player.dontspeak ) && player.dontspeak ) )
                    {
                        player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "shoot_mech_arm" );
                        return;
                    }
                }
            }
        }

        wait 0.1;
    }
}

mechz_hint_vo()
{
    self endon( "death" );
    wait 30.0;

    while ( true )
    {
        if ( self.health > self.maxhealth * 0.5 )
        {
            wait 1.0;
            continue;
        }

        if ( !( isdefined( self.powerplant_covered ) && self.powerplant_covered ) )
        {
            wait 1.0;
            continue;
        }

        a_players = getplayers();

        foreach ( player in a_players )
        {
            if ( isdefined( self.e_grabbed ) && self.e_grabbed == player )
                continue;

            if ( distancesquared( self.origin, player.origin ) < 1000000 )
            {
                if ( player is_player_looking_at( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), 0.75 ) )
                {
                    if ( !( isdefined( player.dontspeak ) && player.dontspeak ) )
                    {
                        player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "shoot_mech_power" );
                        return;
                    }
                }
            }
        }

        wait 0.1;
    }
}

shoot_mechz_head_vo()
{
    self endon( "death" );
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( isdefined( self.e_grabbed ) && self.e_grabbed == player )
            continue;

        if ( distancesquared( self.origin, player.origin ) < 1000000 )
        {
            if ( player is_player_looking_at( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), 0.75 ) )
            {
                if ( !( isdefined( player.dontspeak ) && player.dontspeak ) )
                {
                    player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "shoot_mech_head" );
                    return;
                }
            }
        }
    }
}

mechz_jump_vo()
{
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( distancesquared( self.origin, player.origin ) < 1000000 )
        {
            if ( player is_player_looking_at( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), 0.5 ) )
            {
                if ( !( isdefined( player.dontspeak ) && player.dontspeak ) )
                {
                    player delay_thread( 3.0, maps\mp\zombies\_zm_audio::create_and_play_dialog, "general", "rspnd_mech_jump" );
                    return;
                }
            }
        }
    }
}

mechz_stomped_by_giant_robot_vo()
{
    self endon( "death" );
    wait 5.0;
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( distancesquared( self.origin, player.origin ) < 1000000 )
        {
            if ( player is_player_looking_at( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), 0.75 ) )
            {
                if ( !( isdefined( player.dontspeak ) && player.dontspeak ) )
                {
                    player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "robot_crush_mech" );
                    return;
                }
            }
        }
    }
}

init_anim_rate()
{
    self setclientfield( "anim_rate", 1 );
    n_rate = self getclientfield( "anim_rate" );
    self setentityanimrate( n_rate );
}

sndmechzisnetworksafe( type )
{
    if ( !isdefined( level.sndmechz ) )
        level.sndmechz = [];

    if ( !isdefined( level.sndmechz[type] ) )
        level thread sndmechznetworkchoke( type );

    if ( level.sndmechz[type] > 1 )
        return false;

    level.sndmechz[type]++;
    return true;
}

sndmechznetworkchoke( type )
{
    while ( true )
    {
        level.sndmechz[type] = 0;
        wait_network_frame();
    }
}
