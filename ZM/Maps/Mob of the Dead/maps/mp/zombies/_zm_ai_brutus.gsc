// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_zonemgr;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_ai_brutus;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zm_alcatraz_utility;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\animscripts\shared;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_weap_riotshield_prison;
#include maps\mp\animscripts\zm_death;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_craftables;
#include maps\mp\zm_alcatraz_sq;

precache()
{
    level._effect["brutus_flashlight"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_brut_light" );
    level._effect["brutus_spawn"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_brut_spawn" );
    level._effect["brutus_death"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_brut_spawn" );
    level._effect["brutus_teargas"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_brut_gas" );
    level._effect["brutus_lockdown"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_lock" );
    level._effect["brutus_lockdown_sm"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_s_lock" );
    level._effect["brutus_lockdown_lg"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_w_bench_lock" );
    precachemodel( "c_zom_cellbreaker_helmet" );
    precacheshellshock( "mp_radiation_high" );
    precacheshellshock( "mp_radiation_med" );
    precacheshellshock( "mp_radiation_low" );
    precachestring( &"ZOMBIE_LOCKED_COST" );
    precachestring( &"ZOMBIE_LOCKED_COST_2000" );
    precachestring( &"ZOMBIE_LOCKED_COST_4000" );
    precachestring( &"ZOMBIE_LOCKED_COST_6000" );
    flag_init( "brutus_setup_complete" );
    setdvar( "zombie_double_wide_checks", 1 );

    if ( !isdefined( level.vsmgr_prio_zm_brutus_teargas ) )
        level.vsmgr_prio_overlay_zm_ai_screecher_blur = 50;

    if ( !isdefined( level.custom_brutus_barrier_fx ) )
        level.custom_brutus_barrier_fx = ::precache_default_brutus_barrier_fx;

    [[ level.custom_brutus_barrier_fx ]]();
}

init()
{
    level.brutus_spawners = getentarray( "brutus_zombie_spawner", "script_noteworthy" );

    if ( level.brutus_spawners.size == 0 )
        return;

    array_thread( level.brutus_spawners, ::add_spawn_function, ::brutus_prespawn );

    for ( i = 0; i < level.brutus_spawners.size; i++ )
    {
        level.brutus_spawners[i].is_enabled = 1;
        level.brutus_spawners[i].script_forcespawn = 1;
    }

    level.brutus_spawn_positions = getstructarray( "brutus_location", "script_noteworthy" );
    level thread setup_interaction_matrix();
    level.sndbrutusistalking = 0;
    level.brutus_health = 500;
    level.brutus_health_increase = 1000;
    level.brutus_round_count = 0;
    level.brutus_last_spawn_round = 0;
    level.brutus_count = 0;
    level.brutus_max_count = 1;
    level.brutus_damage_percent = 0.1;
    level.brutus_helmet_shots = 5;
    level.brutus_team_points_for_death = 500;
    level.brutus_player_points_for_death = 250;
    level.brutus_points_for_helmet = 250;
    level.brutus_alarm_chance = 100;
    level.brutus_min_alarm_chance = 100;
    level.brutus_alarm_chance_increment = 10;
    level.brutus_max_alarm_chance = 200;
    level.brutus_min_round_fq = 4;
    level.brutus_max_round_fq = 7;
    level.brutus_reset_dist_sq = 262144;
    level.brutus_aggro_dist_sq = 16384;
    level.brutus_aggro_earlyout = 12;
    level.brutus_blocker_pieces_req = 1;
    level.brutus_zombie_per_round = 1;
    level.brutus_players_in_zone_spawn_point_cap = 120;
    level.brutus_teargas_duration = 7;
    level.player_teargas_duration = 2;
    level.brutus_teargas_radius = 64;
    level.num_pulls_since_brutus_spawn = 0;
    level.brutus_min_pulls_between_box_spawns = 4;
    level.brutus_explosive_damage_for_helmet_pop = 1500;
    level.brutus_explosive_damage_increase = 600;
    level.brutus_failed_paths_to_teleport = 4;
    level.brutus_do_prologue = 1;
    level.brutus_min_spawn_delay = 10.0;
    level.brutus_max_spawn_delay = 60.0;
    level.brutus_respawn_after_despawn = 1;
    level.brutus_in_grief = 0;

    if ( getdvar( "ui_gametype" ) == "zgrief" )
        level.brutus_in_grief = 1;

    level.brutus_shotgun_damage_mod = 1.5;
    level.brutus_custom_goalradius = 48;
    registerclientfield( "actor", "helmet_off", 9000, 1, "int" );
    registerclientfield( "actor", "brutus_lock_down", 9000, 1, "int" );
    level thread maps\mp\zombies\_zm_ai_brutus::brutus_spawning_logic();

    if ( !level.brutus_in_grief )
    {
        level thread maps\mp\zombies\_zm_ai_brutus::get_brutus_interest_points();
/#
        setup_devgui();
#/
        level.custom_perk_validation = maps\mp\zombies\_zm_ai_brutus::check_perk_machine_valid;
        level.custom_craftable_validation = maps\mp\zombies\_zm_ai_brutus::check_craftable_table_valid;
        level.custom_plane_validation = maps\mp\zombies\_zm_ai_brutus::check_plane_valid;
    }
}

setup_interaction_matrix()
{
    level.interaction_types = [];
    level.interaction_types["magic_box"] = spawnstruct();
    level.interaction_types["magic_box"].priority = 0;
    level.interaction_types["magic_box"].animstate = "zm_lock_magicbox";
    level.interaction_types["magic_box"].notify_name = "box_lock_anim";
    level.interaction_types["magic_box"].action_notetrack = "locked";
    level.interaction_types["magic_box"].end_notetrack = "lock_done";
    level.interaction_types["magic_box"].validity_func = ::is_magic_box_valid;
    level.interaction_types["magic_box"].get_func = ::get_magic_boxes;
    level.interaction_types["magic_box"].value_func = ::get_dist_score;
    level.interaction_types["magic_box"].interact_func = ::magic_box_lock;
    level.interaction_types["magic_box"].spawn_bias = 1000;
    level.interaction_types["magic_box"].num_times_to_scale = 1;
    level.interaction_types["magic_box"].unlock_cost = 2000;
    level.interaction_types["perk_machine"] = spawnstruct();
    level.interaction_types["perk_machine"].priority = 1;
    level.interaction_types["perk_machine"].animstate = "zm_lock_perk_machine";
    level.interaction_types["perk_machine"].notify_name = "perk_lock_anim";
    level.interaction_types["perk_machine"].action_notetrack = "locked";
    level.interaction_types["perk_machine"].validity_func = ::is_perk_machine_valid;
    level.interaction_types["perk_machine"].get_func = ::get_perk_machines;
    level.interaction_types["perk_machine"].value_func = ::get_dist_score;
    level.interaction_types["perk_machine"].interact_func = ::perk_machine_lock;
    level.interaction_types["perk_machine"].spawn_bias = 800;
    level.interaction_types["perk_machine"].num_times_to_scale = 3;
    level.interaction_types["perk_machine"].unlock_cost = 2000;
    level.interaction_types["craftable_table"] = spawnstruct();
    level.interaction_types["craftable_table"].priority = 2;
    level.interaction_types["craftable_table"].animstate = "zm_smash_craftable_table";
    level.interaction_types["craftable_table"].notify_name = "table_smash_anim";
    level.interaction_types["craftable_table"].action_notetrack = "fire";
    level.interaction_types["craftable_table"].validity_func = ::is_craftable_table_valid;
    level.interaction_types["craftable_table"].get_func = ::get_craftable_tables;
    level.interaction_types["craftable_table"].value_func = ::get_dist_score;
    level.interaction_types["craftable_table"].interact_func = ::craftable_table_lock;
    level.interaction_types["craftable_table"].spawn_bias = 600;
    level.interaction_types["craftable_table"].num_times_to_scale = 1;
    level.interaction_types["craftable_table"].unlock_cost = 2000;
    level.interaction_types["craftable_table"].interaction_z_offset = -15;
    level.interaction_types["craftable_table"].interaction_yaw_offset = 270;
    level.interaction_types["craftable_table"].fx_z_offset = -44;
    level.interaction_types["craftable_table"].fx_yaw_offset = 270;
    level.interaction_types["trap"] = spawnstruct();
    level.interaction_types["trap"].priority = 3;
    level.interaction_types["trap"].animstate = "zm_smash_trap";
    level.interaction_types["trap"].notify_name = "trap_smash_anim";
    level.interaction_types["trap"].action_notetrack = "fire";
    level.interaction_types["trap"].validity_func = ::is_trap_valid;
    level.interaction_types["trap"].get_func = ::get_traps;
    level.interaction_types["trap"].value_func = ::get_dist_score;
    level.interaction_types["trap"].interact_func = ::trap_smash;
    level.interaction_types["trap"].spawn_bias = 400;
    level.interaction_types["trap"].interaction_z_offset = -15;
    level.interaction_types["plane_ramp"] = spawnstruct();
    level.interaction_types["plane_ramp"].priority = 4;
    level.interaction_types["plane_ramp"].animstate = "zm_lock_plane_ramp";
    level.interaction_types["plane_ramp"].notify_name = "plane_lock_anim";
    level.interaction_types["plane_ramp"].action_notetrack = "locked";
    level.interaction_types["plane_ramp"].end_notetrack = "lock_done";
    level.interaction_types["plane_ramp"].validity_func = ::is_plane_ramp_valid;
    level.interaction_types["plane_ramp"].get_func = ::get_plane_ramps;
    level.interaction_types["plane_ramp"].value_func = ::get_dist_score;
    level.interaction_types["plane_ramp"].interact_func = ::plane_ramp_lock;
    level.interaction_types["plane_ramp"].spawn_bias = 500;
    level.interaction_types["plane_ramp"].num_times_to_scale = 3;
    level.interaction_types["plane_ramp"].unlock_cost = 2000;
    level.interaction_types["plane_ramp"].interaction_z_offset = -60;
    level.interaction_types["plane_ramp"].fx_z_offset = -60;
    level.interaction_types["plane_ramp"].fx_x_offset = 70;
    level.interaction_types["plane_ramp"].fx_yaw_offset = 90;
    level.interaction_types["blocker"] = spawnstruct();
    level.interaction_types["blocker"].priority = 5;
    level.interaction_types["blocker"].animstate = "zm_smash_blocker";
    level.interaction_types["blocker"].notify_name = "board_smash_anim";
    level.interaction_types["blocker"].action_notetrack = "fire";
    level.interaction_types["blocker"].validity_func = ::is_blocker_valid;
    level.interaction_types["blocker"].get_func = ::get_blockers;
    level.interaction_types["blocker"].value_func = ::get_dist_score;
    level.interaction_types["blocker"].interact_func = ::blocker_smash;
    level.interaction_types["blocker"].spawn_bias = 50;
    level.interaction_priority = [];
    interaction_types = getarraykeys( level.interaction_types );

    for ( i = 0; i < interaction_types.size; i++ )
    {
        int_type = interaction_types[i];
        interaction = level.interaction_types[int_type];
        assert( !isdefined( level.interaction_priority[interaction.priority] ) );
        level.interaction_priority[interaction.priority] = int_type;
    }
/#
    for ( i = 0; i < interaction_types.size; i++ )
        assert( isdefined( level.interaction_priority[i] ) );
#/
}

brutus_prespawn()
{

}

brutus_spawn_prologue( spawn_pos )
{
    playsoundatposition( "zmb_ai_brutus_prespawn", spawn_pos.origin );
    wait 3;
}

brutus_spawn( starting_health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name )
{
    level.num_pulls_since_brutus_spawn = 0;
    self set_zombie_run_cycle( "run" );

    if ( !isdefined( has_helmet ) )
        self.has_helmet = 1;
    else
        self.has_helmet = has_helmet;

    if ( !isdefined( helmet_hits ) )
        self.helmet_hits = 0;
    else
        self.helmet_hits = helmet_hits;

    if ( !isdefined( explosive_dmg_taken ) )
        self.explosive_dmg_taken = 0;
    else
        self.explosive_dmg_taken = explosive_dmg_taken;

    if ( !isdefined( starting_health ) )
    {
        self brutus_health_increases();
        self.maxhealth = level.brutus_health;
        self.health = level.brutus_health;
    }
    else
    {
        self.maxhealth = starting_health;
        self.health = starting_health;
    }

    self.explosive_dmg_req = level.brutus_expl_dmg_req;
    self.no_damage_points = 1;
    self endon( "death" );
    level endon( "intermission" );
    self.animname = "brutus_zombie";
    self.audio_type = "brutus";
    self.has_legs = 1;
    self.ignore_all_poi = 1;
    self.is_brutus = 1;
    self.ignore_enemy_count = 1;
    self.instakill_func = ::brutus_instakill_override;
    self.nuke_damage_func = ::brutus_nuke_override;
    self.melee_anim_func = ::melee_anim_func;
    self.meleedamage = 99;
    self.custom_item_dmg = 1000;
    self.brutus_lockdown_state = 0;
    recalc_zombie_array();
    self setphysparams( 20, 0, 60 );
    self.zombie_init_done = 1;
    self notify( "zombie_init_done" );
    self.allowpain = 0;
    self animmode( "normal" );
    self orientmode( "face enemy" );
    self maps\mp\zombies\_zm_spawner::zombie_setup_attack_properties();
    self setfreecameralockonallowed( 0 );
    level thread maps\mp\zombies\_zm_spawner::zombie_death_event( self );
    self thread maps\mp\zombies\_zm_spawner::enemy_death_detection();

    if ( isdefined( zone_name ) && zone_name == "zone_golden_gate_bridge" )
    {
        wait( randomfloat( 1.5 ) );
        spawn_pos = get_random_brutus_spawn_pos( zone_name );
    }
    else
        spawn_pos = get_best_brutus_spawn_pos( zone_name );

    if ( !isdefined( spawn_pos ) )
    {
/#
        println( "ERROR: Tried to spawn brutus with no brutus spawn_positions!\\n" );
        iprintln( "ERROR: Tried to spawn brutus with no brutus spawn_positions!" );
#/
        self delete();
        return;
    }

    if ( !isdefined( spawn_pos.angles ) )
        spawn_pos.angles = ( 0, 0, 0 );

    if ( isdefined( level.brutus_do_prologue ) && level.brutus_do_prologue )
        self brutus_spawn_prologue( spawn_pos );

    if ( !self.has_helmet )
        self detach( "c_zom_cellbreaker_helmet" );

    level.brutus_count++;
    self maps\mp\zombies\_zm_spawner::zombie_complete_emerging_into_playable_area();
    self thread snddelayedmusic();
    self thread brutus_death();
    self thread brutus_check_zone();
    self thread brutus_watch_enemy();
    self forceteleport( spawn_pos.origin, spawn_pos.angles );
    self.cant_melee = 1;
    self.not_interruptable = 1;
    self.actor_damage_func = ::brutus_damage_override;
    self.non_attacker_func = ::brutus_non_attacker_damage_override;
    self thread brutus_lockdown_client_effects( 0.5 );
    playfx( level._effect["brutus_spawn"], self.origin );
    playsoundatposition( "zmb_ai_brutus_spawn", self.origin );
    self animscripted( spawn_pos.origin, spawn_pos.angles, "zm_spawn" );
    self thread maps\mp\animscripts\zm_shared::donotetracks( "spawn_anim" );

    self waittillmatch( "spawn_anim", "spawn_complete" );

    self.not_interruptable = 0;
    self.cant_melee = 0;
    self thread brutus_chest_flashlight();
    self thread brutus_find_flesh();
    self thread maps\mp\zombies\_zm_spawner::delayed_zombie_eye_glow();
    level notify( "brutus_spawned", self );
}

brutus_chest_flashlight()
{
    wait 0.1;
    self.chest_flashlight = spawn( "script_model", self.origin );
    self.chest_flashlight setmodel( "tag_origin" );
    self.chest_flashlight linkto( self, "J_spineupper", ( 0, 0, 0 ), ( 0, 0, 0 ) );
    playfxontag( level._effect["brutus_flashlight"], self.chest_flashlight, "tag_origin" );

    self waittill( "death" );

    if ( isdefined( self.chest_flashlight ) )
        self.chest_flashlight delete();
}

brutus_temp_despawn( brutus, endon_notify, respawn_notify )
{
    level endon( endon_notify );
    align_struct = spawn( "script_model", brutus.origin );
    align_struct.angles = brutus.angles;
    align_struct setmodel( "tag_origin" );

    if ( !level.brutus_in_grief && ( brutus istouching( level.e_gondola.t_ride ) || isdefined( brutus.force_gondola_teleport ) && brutus.force_gondola_teleport ) )
    {
        brutus.force_gondola_teleport = 0;
        align_struct linkto( level.e_gondola );
        brutus linkto( align_struct );
    }

    brutus.not_interruptable = 1;
    playfxontag( level._effect["brutus_spawn"], align_struct, "tag_origin" );
    brutus animscripted( brutus.origin, brutus.angles, "zm_taunt" );
    brutus maps\mp\animscripts\zm_shared::donotetracks( "taunt_anim" );
    brutus.not_interruptable = 0;
    brutus ghost();
    brutus notify( "brutus_cleanup" );
    brutus notify( "brutus_teleporting" );

    if ( isdefined( align_struct ) )
        align_struct delete();

    if ( isdefined( brutus.sndbrutusmusicent ) )
    {
        brutus.sndbrutusmusicent delete();
        brutus.sndbrutusmusicent = undefined;
    }

    health = brutus.health;
    has_helmet = brutus.has_helmet;
    helmet_hits = brutus.helmet_hits;
    explosive_dmg_taken = brutus.explosive_dmg_taken;
    zone_name = brutus.force_zone;
    brutus delete();
    level.brutus_count--;

    level waittill( respawn_notify );

    wait( randomfloatrange( 1.0, 2.5 ) );
    level thread respawn_brutus( health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name );
}

brutus_spawn_zone_locked( zone_name )
{
    ai = spawn_zombie( level.brutus_spawners[0] );
    ai thread brutus_spawn( undefined, undefined, undefined, undefined, zone_name );
    ai.force_zone = zone_name;

    if ( isdefined( ai ) )
    {
        ai playsound( "zmb_ai_brutus_spawn_2d" );
        return ai;
    }
}

brutus_spawn_in_zone( zone_name, zone_locked )
{
    if ( isdefined( zone_locked ) && zone_locked )
        return brutus_spawn_zone_locked( zone_name );
    else
    {
        ai = spawn_zombie( level.brutus_spawners[0] );
        ai thread brutus_spawn( undefined, undefined, undefined, undefined, zone_name );

        if ( isdefined( ai ) )
        {
            ai playsound( "zmb_ai_brutus_spawn_2d" );
            return ai;
        }
    }
}

snddelayedmusic()
{
    self endon( "death" );
    wait 5;

    if ( !isdefined( self.sndbrutusmusicent ) )
    {
        sndentorigin = self gettagorigin( "J_spineupper" );
        self.sndbrutusmusicent = spawn( "script_origin", sndentorigin );
        self.sndbrutusmusicent linkto( self, "J_spineupper" );
        self.sndbrutusmusicent playloopsound( "mus_event_brutus_loop" );
    }

    self thread sndbrutusloopwatcher( self.sndbrutusmusicent );
}

sndbrutusloopwatcher( ent )
{
    self endon( "death" );

    level waittill( "sndStopBrutusLoop" );

    ent stoploopsound( 1 );
    wait 1;
    ent delete();
}

brutus_health_increases()
{
    if ( level.round_number > level.brutus_last_spawn_round )
    {
        a_players = getplayers();
        n_player_modifier = 1;

        if ( a_players.size > 1 )
            n_player_modifier = a_players.size * 0.75;

        level.brutus_round_count++;
        level.brutus_health = int( level.brutus_health_increase * n_player_modifier * level.brutus_round_count );
        level.brutus_expl_dmg_req = int( level.brutus_explosive_damage_increase * n_player_modifier * level.brutus_round_count );

        if ( level.brutus_health >= 5000 * n_player_modifier )
            level.brutus_health = int( 5000 * n_player_modifier );

        if ( level.brutus_expl_dmg_req >= 4500 * n_player_modifier )
            level.brutus_expl_dmg_req = int( 4500 * n_player_modifier );

        level.brutus_last_spawn_round = level.round_number;
    }
}

get_brutus_spawn_pos_val( brutus_pos )
{
    score = 0;
    zone_name = brutus_pos.zone_name;

    if ( !maps\mp\zombies\_zm_zonemgr::zone_is_enabled( zone_name ) )
        return 0;

    a_players_in_zone = get_players_in_zone( zone_name, 1 );

    if ( a_players_in_zone.size == 0 )
        return 0;
    else
    {
        n_score_addition = 1;

        for ( i = 0; i < a_players_in_zone.size; i++ )
        {
            if ( findpath( brutus_pos.origin, a_players_in_zone[i].origin, self, 0, 0 ) )
            {
                n_dist = distance2d( brutus_pos.origin, a_players_in_zone[i].origin );
                n_score_addition += linear_map( n_dist, 2000, 0, 0, level.brutus_players_in_zone_spawn_point_cap );
            }
        }

        if ( n_score_addition > level.brutus_players_in_zone_spawn_point_cap )
            n_score_addition = level.brutus_players_in_zone_spawn_point_cap;

        score += n_score_addition;
    }

    if ( !level.brutus_in_grief )
    {
        interaction_types = getarraykeys( level.interaction_types );
        interact_array = level.interaction_types;

        for ( i = 0; i < interaction_types.size; i++ )
        {
            int_type = interaction_types[i];
            interaction = interact_array[int_type];
            interact_points = [[ interaction.get_func ]]( zone_name );

            for ( j = 0; j < interact_points.size; j++ )
            {
                if ( interact_points[j] [[ interaction.validity_func ]]() )
                    score += interaction.spawn_bias;
            }
        }
    }

    return score;
}

get_random_brutus_spawn_pos( zone_name )
{
    zone_spawn_pos = [];

    for ( i = 0; i < level.zombie_brutus_locations.size; i++ )
    {
        if ( isdefined( zone_name ) && level.zombie_brutus_locations[i].zone_name != zone_name )
            continue;

        zone_spawn_pos[zone_spawn_pos.size] = i;
    }

    if ( zone_spawn_pos.size > 0 )
    {
        pos_idx = randomint( zone_spawn_pos.size );
        return level.zombie_brutus_locations[zone_spawn_pos[pos_idx]];
    }

    return undefined;
}

get_best_brutus_spawn_pos( zone_name )
{
    val = 0;

    for ( i = 0; i < level.zombie_brutus_locations.size; i++ )
    {
        if ( isdefined( zone_name ) && level.zombie_brutus_locations[i].zone_name != zone_name )
            continue;

        newval = get_brutus_spawn_pos_val( level.zombie_brutus_locations[i] );

        if ( newval > val )
        {
            val = newval;
            pos_idx = i;
        }
    }

    if ( isdefined( pos_idx ) )
        return level.zombie_brutus_locations[pos_idx];
    else
        return undefined;
}

play_ambient_brutus_vocals()
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
                self playsound( "zmb_vocals_brutus_ambience" );
        }

        wait( randomfloatrange( 1, 1.5 ) );
    }
}

brutus_cleanup()
{
    self waittill( "brutus_cleanup" );

    level.sndbrutusistalking = 0;

    if ( isdefined( self.sndbrutusmusicent ) )
    {
        self.sndbrutusmusicent delete();
        self.sndbrutusmusicent = undefined;
    }
}

brutus_cleanup_at_end_of_grief_round()
{
    self endon( "death" );
    self endon( "brutus_cleanup" );
    level waittill_any( "keep_griefing", "game_module_ended" );
    self delete();
    self notify( "brutus_cleanup" );
}

brutus_death()
{
    self endon( "brutus_cleanup" );
    self thread brutus_cleanup();

    if ( level.brutus_in_grief )
        self thread brutus_cleanup_at_end_of_grief_round();

    self waittill( "death" );

    self thread sndbrutusvox( "vox_brutus_brutus_defeated" );
    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "brutus_death" );
    level.brutus_count--;
    playfx( level._effect["brutus_death"], self.origin );
    playsoundatposition( "zmb_ai_brutus_death", self.origin );

    if ( get_current_zombie_count() == 0 && level.zombie_total == 0 )
    {
        level.last_brutus_origin = self.origin;
        level notify( "last_brutus_down" );

        if ( isdefined( self.brutus_round_spawn_failsafe ) && self.brutus_round_spawn_failsafe )
            level.next_brutus_round = level.round_number + 1;
    }
    else if ( isdefined( self.brutus_round_spawn_failsafe ) && self.brutus_round_spawn_failsafe )
    {
        level.zombie_total++;
        level.zombie_total_subtract++;
        level thread brutus_round_spawn_failsafe_respawn();
    }

    if ( !( isdefined( self.suppress_brutus_powerup_drop ) && self.suppress_brutus_powerup_drop ) )
    {
        if ( !( isdefined( level.global_brutus_powerup_prevention ) && level.global_brutus_powerup_prevention ) )
        {
            if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_golden_gate_bridge" ) )
                level.global_brutus_powerup_prevention = 1;

            if ( level.powerup_drop_count >= level.zombie_vars["zombie_powerup_drop_max_per_round"] )
                level.powerup_drop_count = level.zombie_vars["zombie_powerup_drop_max_per_round"] - 1;

            level.zombie_vars["zombie_drop_item"] = 1;
            level thread maps\mp\zombies\_zm_powerups::powerup_drop( self.origin );
        }
    }

    if ( isplayer( self.attacker ) )
    {
        event = "death";

        if ( issubstr( self.damageweapon, "knife_ballistic_" ) )
            event = "ballistic_knife_death";

        self.attacker thread do_player_general_vox( "general", "brutus_killed", 20, 20 );

        if ( level.brutus_in_grief )
        {
            team_points = level.brutus_team_points_for_death;
            player_points = level.brutus_player_points_for_death;
            a_players = getplayers( self.team );
        }
        else
        {
            multiplier = maps\mp\zombies\_zm_score::get_points_multiplier( self );
            team_points = multiplier * round_up_score( level.brutus_team_points_for_death, 5 );
            player_points = multiplier * round_up_score( level.brutus_player_points_for_death, 5 );
            a_players = getplayers();
        }

        foreach ( player in a_players )
        {
            if ( !is_player_valid( player ) )
                continue;

            player add_to_player_score( team_points );

            if ( player == self.attacker )
            {
                player add_to_player_score( player_points );
                level notify( "brutus_killed", player );
            }

            player.pers["score"] = player.score;
            player maps\mp\zombies\_zm_stats::increment_client_stat( "prison_brutus_killed", 0 );
        }
    }

    self notify( "brutus_cleanup" );
}

brutus_round_spawn_failsafe_respawn()
{
    while ( true )
    {
        wait 2.0;

        if ( attempt_brutus_spawn( 1 ) )
            break;
    }
}

get_interact_offset( item, target_type )
{
    assert( isdefined( level.interaction_types[target_type] ) );
    interaction = level.interaction_types[target_type];
    anim_state = interaction.animstate;
    animationid = self getanimfromasd( anim_state, 0 );
    origin = item.origin;
    angles = item.angles;

    if ( isdefined( interaction.interaction_z_offset ) )
        origin += ( 0, 0, interaction.interaction_z_offset );

    if ( isdefined( interaction.interaction_yaw_offset ) )
        angles += ( 0, interaction.interaction_yaw_offset, 0 );

    return getstartorigin( origin, angles, animationid );
}

enable_brutus_rounds()
{
    level.brutus_rounds_enabled = 1;
    flag_init( "brutus_round" );
    level thread brutus_round_tracker();
}

brutus_round_tracker()
{
    level.next_brutus_round = level.round_number + randomintrange( level.brutus_min_round_fq, level.brutus_max_round_fq );
    old_spawn_func = level.round_spawn_func;
    old_wait_func = level.round_wait_func;

    while ( true )
    {
        level waittill( "between_round_over" );

        players = get_players();

        if ( level.round_number < 9 && ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game ) )
            continue;
        else if ( level.next_brutus_round <= level.round_number )
        {
            if ( maps\mp\zm_alcatraz_utility::is_team_on_golden_gate_bridge() )
            {
                level.next_brutus_round = level.round_number + 1;
                continue;
            }

            wait( randomfloatrange( level.brutus_min_spawn_delay, level.brutus_max_spawn_delay ) );

            if ( attempt_brutus_spawn( level.brutus_zombie_per_round ) )
            {
                level.music_round_override = 1;
                level thread maps\mp\zombies\_zm_audio::change_zombie_music( "brutus_round_start" );
                level thread sndforcewait();
                level.next_brutus_round = level.round_number + randomintrange( level.brutus_min_round_fq, level.brutus_max_round_fq );
            }
        }
    }
}

sndforcewait()
{
    wait 10;
    level.music_round_override = 0;
}

wait_on_box_alarm()
{
    while ( true )
    {
        self.zbarrier waittill( "randomization_done" );

        level.num_pulls_since_brutus_spawn++;

        if ( level.brutus_in_grief )
            level.brutus_min_pulls_between_box_spawns = randomintrange( 7, 10 );

        if ( level.num_pulls_since_brutus_spawn >= level.brutus_min_pulls_between_box_spawns )
        {
            rand = randomint( 1000 );

            if ( level.brutus_in_grief )
                level notify( "spawn_brutus", 1 );
            else if ( rand <= level.brutus_alarm_chance )
            {
                if ( flag( "moving_chest_now" ) )
                    continue;

                if ( attempt_brutus_spawn( 1 ) )
                {
                    if ( level.next_brutus_round == level.round_number + 1 )
                        level.next_brutus_round++;

                    level.brutus_alarm_chance = level.brutus_min_alarm_chance;
                }
            }
            else if ( level.brutus_alarm_chance < level.brutus_max_alarm_chance )
                level.brutus_alarm_chance += level.brutus_alarm_chance_increment;
        }
    }
}

brutus_spawning_logic()
{
    if ( !level.brutus_in_grief )
        level thread enable_brutus_rounds();

    if ( isdefined( level.chests ) )
    {
        for ( i = 0; i < level.chests.size; i++ )
            level.chests[i] thread wait_on_box_alarm();
    }

    while ( true )
    {
        level waittill( "spawn_brutus", num );

        for ( i = 0; i < num; i++ )
        {
            ai = spawn_zombie( level.brutus_spawners[0] );
            ai thread brutus_spawn();
        }

        if ( isdefined( ai ) )
            ai playsound( "zmb_ai_brutus_spawn_2d" );
    }
}

attempt_brutus_spawn( n_spawn_num )
{
    if ( level.brutus_count + n_spawn_num > level.brutus_max_count )
    {
/#
        iprintln( "Brutus max count reached - Preventing Brutus from spawning!" );
#/
        return false;
    }

    level notify( "spawn_brutus", n_spawn_num );
    return true;
}

brutus_start_basic_find_flesh()
{
    self.goalradius = 48;
    self.custom_goalradius_override = level.brutus_custom_goalradius;

    if ( self.ai_state != "find_flesh" )
    {
        self.ai_state = "find_flesh";
        self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
    }
}

brutus_stop_basic_find_flesh()
{
    if ( self.ai_state == "find_flesh" )
    {
        self notify( "stop_find_flesh" );
        self notify( "zombie_acquire_enemy" );
    }
}

setup_devgui()
{
/#
    setdvar( "spawn_Brutus", "off" );
    adddebugcommand( "devgui_cmd \"Zombies:2/Zombie Spawning:2/Spawn Zombie:1/Brutus:1\" \"spawn_Brutus on\"\n" );
    level thread watch_devgui_brutus();
#/
}

watch_devgui_brutus()
{
/#
    while ( true )
    {
        if ( getdvar( _hash_5E6F2932 ) == "on" )
        {
            level notify( "spawn_brutus", 1 );
            setdvar( "spawn_Brutus", "off" );
        }

        wait 0.1;
    }
#/
}

respawn_brutus( starting_health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name, b_no_current_valid_targets )
{
    if ( isdefined( b_no_current_valid_targets ) && b_no_current_valid_targets )
        zone_name = brutus_watch_for_new_valid_targets();
    else
        wait 5;

    ai = spawn_zombie( level.brutus_spawners[0] );
    ai thread brutus_spawn( starting_health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name );
    ai.force_zone = zone_name;
}

respawn_brutus_after_gondola( starting_health, has_helmet, helmet_hits, explosive_dmg_taken )
{
    level waittill( "gondola_arrived", zone_name );

    ai = spawn_zombie( level.brutus_spawners[0] );
    ai thread brutus_spawn( starting_health, has_helmet, helmet_hits, explosive_dmg_taken, zone_name );
}

brutus_watch_for_gondola()
{
    self endon( "death" );

    while ( true )
    {
        level waittill( "gondola_moving" );

        if ( !level.brutus_in_grief && self istouching( level.e_gondola.t_ride ) )
            self.force_gondola_teleport = 1;

        wait 0.05;
    }
}

are_all_targets_invalid()
{
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( !( isdefined( player.is_on_gondola ) && player.is_on_gondola ) && !( isdefined( player.afterlife ) && player.afterlife ) )
            return false;
    }

    return true;
}

brutus_watch_for_new_valid_targets()
{
    level thread brutus_watch_for_gondola_arrive();
    level thread brutus_watch_for_non_afterlife_players();

    level waittill( "brutus_valid_targets_arrived", zone_name );

    return zone_name;
}

brutus_watch_for_gondola_arrive()
{
    level endon( "brutus_valid_targets_arrived" );

    level waittill( "gondola_arrived", zone_name );

    level notify( "brutus_valid_targets_arrived", zone_name );
}

brutus_watch_for_non_afterlife_players()
{
    level endon( "brutus_valid_targets_arrived" );
    b_all_players_in_afterlife = 1;

    while ( b_all_players_in_afterlife )
    {
        a_players = getplayers();

        foreach ( player in a_players )
        {
            if ( !( isdefined( player.afterlife ) && player.afterlife ) && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
                b_all_players_in_afterlife = 0;
        }

        wait 0.5;
    }

    level notify( "brutus_valid_targets_arrived" );
}

brutus_stuck_teleport()
{
    self endon( "death" );
    align_struct = spawn( "script_model", self.origin );
    align_struct.angles = self.angles;
    align_struct setmodel( "tag_origin" );

    if ( !level.brutus_in_grief && ( self istouching( level.e_gondola.t_ride ) || isdefined( self.force_gondola_teleport ) && self.force_gondola_teleport ) )
    {
        self.force_gondola_teleport = 0;
        align_struct linkto( level.e_gondola );
        self linkto( align_struct );
    }

    self.not_interruptable = 1;
    playfxontag( level._effect["brutus_spawn"], align_struct, "tag_origin" );
    self animscripted( self.origin, self.angles, "zm_taunt" );
    self maps\mp\animscripts\zm_shared::donotetracks( "taunt_anim" );
    self.not_interruptable = 0;
    self ghost();
    self notify( "brutus_cleanup" );
    self notify( "brutus_teleporting" );

    if ( isdefined( align_struct ) )
        align_struct delete();

    if ( isdefined( self.sndbrutusmusicent ) )
    {
        self.sndbrutusmusicent delete();
        self.sndbrutusmusicent = undefined;
    }

    if ( isdefined( level.brutus_respawn_after_despawn ) && level.brutus_respawn_after_despawn )
    {
        b_no_current_valid_targets = are_all_targets_invalid();
        level thread respawn_brutus( self.health, self.has_helmet, self.helmet_hits, self.explosive_dmg_taken, self.force_zone, b_no_current_valid_targets );
    }

    level.brutus_count--;
    self delete();
}

watch_for_riot_shield_melee()
{
    self endon( "new_stuck_watcher" );
    self endon( "death" );

    while ( true )
    {
        self waittill( "item_attack" );

        self.fail_count = 0;
    }
}

watch_for_valid_melee()
{
    self endon( "new_stuck_watcher" );
    self endon( "death" );

    while ( true )
    {
        self waittillmatch( "melee_anim", "end" );

        if ( isdefined( self.favorite_enemy ) && distancesquared( self.origin, self.favorite_enemy.origin ) < 16384 && !( isdefined( self.favorite_enemy.is_on_gondola ) && self.favorite_enemy.is_on_gondola ) )
            self.fail_count = 0;
    }
}

brutus_stuck_watcher()
{
    self notify( "new_stuck_watcher" );
    self endon( "death" );
    self endon( "new_stuck_watcher" );
    self.fail_count = 0;
    self thread watch_for_valid_melee();
    self thread watch_for_riot_shield_melee();

    while ( true )
    {
        while ( !isdefined( self.goal_pos ) )
            wait 0.05;

        if ( self.not_interruptable )
        {
            wait 1;
            continue;
        }

        if ( !findpath( self.origin, self.goal_pos, self, 0, 0 ) )
        {
/#
            println( "Brutus could not path to goal_pos " + self.goal_pos );
#/
            self.fail_count++;
        }
        else
            self.fail_count = 0;

        if ( self.fail_count >= level.brutus_failed_paths_to_teleport )
        {
            self brutus_stuck_teleport();
            return;
        }

        wait 1;
    }
}

should_brutus_aggro( player_zone, brutus_zone )
{
    if ( !isdefined( player_zone ) || !isdefined( brutus_zone ) )
        return false;

    if ( player_zone == brutus_zone )
        return true;

    if ( isdefined( level.zones[brutus_zone].adjacent_zones ) && isdefined( level.zones[brutus_zone].adjacent_zones[player_zone] ) )
        return true;

    return false;
}

brutus_find_flesh()
{
    self endon( "death" );
    level endon( "intermission" );

    if ( level.intermission )
        return;

    self.ai_state = "idle";
    self.helitarget = 1;
    self.ignoreme = 0;
    self.nododgemove = 1;
    self.ignore_player = [];
    self thread brutus_watch_for_gondola();
    self thread brutus_stuck_watcher();
    self thread brutus_goal_watcher();
    self thread watch_for_player_dist();

    while ( true )
    {
        if ( self.not_interruptable )
        {
            wait 0.05;
            continue;
        }

        player = brutus_get_closest_valid_player();
        brutus_zone = get_zone_from_position( self.origin );

        if ( !isdefined( brutus_zone ) )
        {
            brutus_zone = self.prev_zone;

            if ( !isdefined( brutus_zone ) )
            {
                wait 1;
                continue;
            }
        }

        player_zone = undefined;
        self.prev_zone = brutus_zone;

        if ( level.brutus_in_grief )
            brutus_start_basic_find_flesh();
        else if ( !isdefined( player ) )
            self.priority_item = self get_priority_item_for_brutus( brutus_zone, 1 );
        else
        {
            player_zone = player get_player_zone();

            if ( isdefined( player_zone ) )
                self.priority_item = self get_priority_item_for_brutus( player_zone );
            else
                self.priority_item = self get_priority_item_for_brutus( brutus_zone, 1 );
        }

        if ( isdefined( player ) && distancesquared( self.origin, player.origin ) < level.brutus_aggro_dist_sq && isdefined( player_zone ) && should_brutus_aggro( player_zone, brutus_zone ) )
        {
            self.favorite_enemy = player;
            self.goal_pos = player.origin;
            brutus_start_basic_find_flesh();
        }
        else if ( isdefined( self.priority_item ) )
        {
            brutus_stop_basic_find_flesh();
            self.goalradius = 12;
            self.custom_goalradius_override = 12;
            self.goal_pos = self get_interact_offset( self.priority_item, self.ai_state );
            self setgoalpos( self.goal_pos );
        }
        else if ( isdefined( player ) )
        {
            self.favorite_enemy = player;
            self.goal_pos = self.favorite_enemy.origin;
            brutus_start_basic_find_flesh();
        }
        else
        {
            self.goal_pos = self.origin;
            self.ai_state = "idle";
            self setanimstatefromasd( "zm_idle" );
            self setgoalpos( self.goal_pos );
        }

        wait 1;
    }
}

trap_damage_callback( trap )
{
    self endon( "death" );

    if ( !( isdefined( self.not_interruptable ) && self.not_interruptable ) )
    {
        self.not_interruptable = 1;
        self animscripted( self.origin, self.angles, "zm_taunt" );
        self maps\mp\animscripts\shared::donotetracks( "taunt_anim" );

        if ( trap.targetname == "fan_trap" )
            trap notify( "trap_finished_" + trap.script_string );
        else if ( trap.targetname == "acid_trap" )
            trap notify( "acid_trap_fx_done" );

        self.not_interruptable = 0;
    }
}

zone_array_contains( zone_array, zone_name )
{
    for ( j = 0; j < zone_array.size; j++ )
    {
        if ( zone_array[j] == zone_name )
            return true;
    }

    return false;
}

get_priority_item_for_brutus( zone_name, do_secondary_zone_checks )
{
    interact_types = level.interaction_types;
    interact_prio = level.interaction_priority;

    for ( i = 0; i < interact_prio.size; i++ )
    {
        best_score = -1;
        best_object = undefined;
        int_type = interact_prio[i];
        int_struct = interact_types[int_type];
        int_objects = self [[ int_struct.get_func ]]( zone_name );

        for ( j = 0; j < int_objects.size; j++ )
        {
            if ( int_objects[j] [[ int_struct.validity_func ]]() )
            {
                score = self [[ int_struct.value_func ]]( int_objects[j] );
                assert( score >= 0 );

                if ( score < best_score || best_score < 0 )
                {
                    best_object = int_objects[j];
                    best_score = score;
                }
            }
        }

        if ( isdefined( best_object ) )
        {
            self.ai_state = int_type;
            return best_object;
        }
    }

    if ( isdefined( do_secondary_zone_checks ) && do_secondary_zone_checks )
    {
        adj_zone_names = getarraykeys( level.zones[zone_name].adjacent_zones );

        for ( i = 0; i < adj_zone_names.size; i++ )
        {
            if ( !maps\mp\zombies\_zm_zonemgr::zone_is_enabled( adj_zone_names[i] ) )
                continue;

            best_object = get_priority_item_for_brutus( adj_zone_names[i] );

            if ( isdefined( best_object ) )
                return best_object;
        }

        global_zone_names = getarraykeys( level.zones );

        for ( i = 0; i < global_zone_names.size; i++ )
        {
            if ( global_zone_names[i] == zone_name )
                continue;

            if ( zone_array_contains( adj_zone_names, global_zone_names[i] ) )
                continue;

            if ( !maps\mp\zombies\_zm_zonemgr::zone_is_enabled( global_zone_names[i] ) )
                continue;

            best_object = get_priority_item_for_brutus( global_zone_names[i] );

            if ( isdefined( best_object ) )
                return best_object;
        }
    }

    return undefined;
}

get_dist_score( object )
{
    return distancesquared( self.origin, object.origin );
}

get_trap_score( object )
{
    if ( sighttracepassed( self.origin + ( 0, 0, 1 ), object.origin, 0, self ) )
        return 0;

    return distancesquared( self.origin, object.origin );
}

get_magic_boxes( zone_name )
{
    assert( isdefined( level.zones[zone_name] ) );
    return level.zones[zone_name].magic_boxes;
}

is_magic_box_valid()
{
    if ( self is_chest_active() && self == level.chests[level.chest_index] )
        return true;

    return false;
}

get_perk_machine_trigger()
{
    if ( self.targetname == "vendingelectric_cherry" )
        perk_machine = getent( "vending_electriccherry", "target" );
    else if ( self.targetname == "vending_deadshot_model" )
        perk_machine = getent( "vending_deadshot", "target" );
    else
        perk_machine = getent( self.targetname, "target" );

    return perk_machine;
}

get_perk_machines( zone_name )
{
    assert( isdefined( level.zones[zone_name] ) );
    return level.zones[zone_name].perk_machines;
}

is_perk_machine_valid()
{
    trigger = self get_perk_machine_trigger();

    if ( isdefined( trigger.is_locked ) && trigger.is_locked )
        return false;

    if ( isdefined( trigger.power_on ) && trigger.power_on )
        return true;

    return false;
}

get_trigger_for_craftable()
{
    for ( i = 0; i < level.a_uts_craftables.size; i++ )
    {
        if ( isdefined( level.a_uts_craftables[i].target ) && level.a_uts_craftables[i].target == self.targetname )
            return level.a_uts_craftables[i];
    }

    trig_ent = getent( self.targetname, "target" );
    return trig_ent;
}

get_craftable_tables( zone_name )
{
    assert( isdefined( level.zones[zone_name] ) );
    return level.zones[zone_name].craftable_tables;
}

is_craftable_table_valid()
{
    table_trig = self get_trigger_for_craftable();

    if ( isdefined( table_trig.is_locked ) && table_trig.is_locked )
        return false;

    if ( isdefined( table_trig.removed ) && table_trig.removed )
        return false;

    return true;
}

get_closest_trap_for_brutus()
{
    best_dist = -1;
    best_trap = undefined;

    for ( i = 0; i < level.trap_triggers.size; i++ )
    {
        if ( !level.trap_triggers[i] [[ level.interaction_types["trap"].validity_func ]]() )
            continue;

        dist = distancesquared( self.origin, level.trap_triggers[i].origin );

        if ( dist < best_dist || best_dist < 0 )
        {
            best_dist = dist;
            best_trap = level.trap_triggers[i];
        }
    }

    return best_trap;
}

get_traps( zone_name )
{
    assert( isdefined( level.zones[zone_name] ) );
    return level.zones[zone_name].traps;
}

is_trap_valid()
{
    if ( isdefined( self.trigger.zombie_dmg_trig ) && ( isdefined( self.trigger.zombie_dmg_trig.active ) && self.trigger.zombie_dmg_trig.active ) )
        return true;
    else if ( isdefined( self.trigger.active ) && self.trigger.active )
        return true;

    return false;
}

get_plane_ramps( zone_name )
{
    assert( isdefined( level.zones[zone_name] ) );
    return level.zones[zone_name].plane_triggers;
}

is_plane_ramp_valid()
{
    if ( isdefined( self.fly_trigger ) && ( isdefined( self.fly_trigger.trigger_off ) && self.fly_trigger.trigger_off ) )
        return false;

    if ( isdefined( self.is_locked ) && self.is_locked )
        return false;

    if ( isdefined( self.equipname ) && ( isdefined( self.crafted ) && self.crafted ) )
        return false;

    return true;
}

get_blockers( zone_name )
{
    return get_zone_zbarriers( zone_name );
}

is_blocker_valid()
{
    closed_pieces = self getzbarrierpieceindicesinstate( "closed" );

    if ( closed_pieces.size >= level.brutus_blocker_pieces_req )
        return true;

    return false;
}

brutus_get_closest_valid_player()
{
    valid_player_found = 0;
    players = get_players();

    if ( isdefined( level._zombie_using_humangun ) && level._zombie_using_humangun )
        players = arraycombine( players, level._zombie_human_array, 0, 0 );

    if ( isdefined( self.ignore_player ) )
    {
        for ( i = 0; i < self.ignore_player.size; i++ )
            arrayremovevalue( players, self.ignore_player[i] );
    }

    while ( !valid_player_found )
    {
        if ( isdefined( level.calc_closest_player_using_paths ) && level.calc_closest_player_using_paths )
            player = get_closest_player_using_paths( self.origin, players );
        else
            player = getclosest( self.origin, players );

        if ( !isdefined( player ) )
            return undefined;

        if ( isdefined( level._zombie_using_humangun ) && level._zombie_using_humangun && isai( player ) )
            return player;

        if ( !is_player_valid( player, 1 ) )
        {
            arrayremovevalue( players, player );
            continue;
        }

        return player;
    }
}

watch_for_player_dist()
{
    self endon( "death" );

    while ( true )
    {
        player = brutus_get_closest_valid_player();

        if ( !isdefined( player ) || distancesquared( player.origin, self.origin ) > level.brutus_reset_dist_sq )
        {
            self.ai_state = "idle";
            self notify( "zombie_acquire_enemy" );
            self notify( "stop_find_flesh" );
        }

        wait 0.5;
    }
}

brutus_goal_watcher()
{
    self endon( "death" );

    while ( true )
    {
        self waittill( "goal" );

        if ( self.ai_state == "find_flesh" || self.ai_state == "idle" )
        {
            wait 0.05;
            continue;
        }

        interaction = level.interaction_types[self.ai_state];
        origin = self.priority_item.origin;
        angles = self.priority_item.angles;

        if ( isdefined( interaction.interaction_z_offset ) )
            origin += ( 0, 0, interaction.interaction_z_offset );

        if ( isdefined( interaction.interaction_yaw_offset ) )
            angles += ( 0, interaction.interaction_yaw_offset, 0 );

        self.not_interruptable = 1;
        self animscripted( origin, angles, interaction.animstate );
        self thread maps\mp\animscripts\zm_shared::donotetracks( interaction.notify_name );
        self thread snddointeractionvox( interaction.notify_name );

        self waittillmatch( interaction.notify_name, interaction.action_notetrack );

        self brutus_lockdown_client_effects();
        self thread [[ interaction.interact_func ]]();
        self.priority_item = undefined;

        if ( isdefined( interaction.end_notetrack ) )
            self waittillmatch( interaction.notify_name, interaction.end_notetrack );
        else
            self waittillmatch( interaction.notify_name, "end" );

        self.not_interruptable = 0;

        while ( !isdefined( self.priority_item ) )
            wait 0.05;
    }
}

snddointeractionvox( type )
{
    alias = "vox_brutus_brutus_lockbox";
    num = undefined;

    switch ( type )
    {
        case "box_lock_anim":
            alias = "vox_brutus_brutus_lockbox";
            break;
        case "perk_lock_anim":
            alias = "vox_brutus_brutus_lockbox";
            num = 5;
            break;
        case "table_smash_anim":
            alias = "vox_brutus_brutus_lockbox";
            num = 5;
            break;
        case "trap_smash_anim":
            alias = "vox_brutus_brutus_lockbox";
            num = 5;
            break;
        case "plane_lock_anim":
            alias = "vox_brutus_brutus_lockbox";
            num = 5;
            break;
        case "board_smash_anim":
            alias = "vox_brutus_brutus_lockbox";
            num = 5;
            break;
    }

    self thread sndbrutusvox( alias, num );
}

brutus_fire_teargas_when_possible()
{
    self endon( "death" );
    wait 0.2;

    while ( isdefined( self.not_interruptable ) && self.not_interruptable )
        wait 0.05;

    self.not_interruptable = 1;
    self playsound( "vox_brutus_enraged" );
    self animscripted( self.origin, self.angles, "zm_teargas_attack" );
    self thread maps\mp\animscripts\zm_shared::donotetracks( "teargas_anim" );

    self waittillmatch( "teargas_anim", "grenade_drop" );

    v_org_left = self gettagorigin( "TAG_WEAPON_LEFT" );
    v_org_right = self gettagorigin( "TAG_WEAPON_RIGHT" );
    self thread sndplaydelayedsmokeaudio( v_org_left, v_org_right );
    self magicgrenadetype( "willy_pete_zm", v_org_left, ( 0, 0, 0 ), 0.4 );
    self magicgrenadetype( "willy_pete_zm", v_org_right, ( 0, 0, 0 ), 0.4 );

    self waittillmatch( "teargas_anim", "end" );

    self.not_interruptable = 0;
}

sndplaydelayedsmokeaudio( org1, org2 )
{
    wait 1.5;
    playsoundatposition( "zmb_ai_brutus_gas_explode", org1 );
    wait 0.25;
    playsoundatposition( "zmb_ai_brutus_gas_explode", org2 );
}

brutus_afterlife_teleport()
{
    playfx( level._effect["afterlife_teleport"], self.origin );
    self hide();
    wait 0.1;
    self notify( "brutus_cleanup" );

    if ( isdefined( self.sndbrutusmusicent ) )
    {
        self.sndbrutusmusicent delete();
        self.sndbrutusmusicent = undefined;
    }

    level thread respawn_brutus( self.health, self.has_helmet, self.helmet_hits, self.explosive_dmg_taken, self.force_zone );
    level.brutus_count--;
    self delete();
}

brutus_remove_helmet( vdir )
{
    self.has_helmet = 0;
    self detach( "c_zom_cellbreaker_helmet" );
    self playsound( "evt_brutus_helmet" );
    launch_pos = self.origin + vectorscale( ( 0, 0, 1 ), 85.0 );
    createdynentandlaunch( "c_zom_cellbreaker_helmet", launch_pos, self.angles, launch_pos, vdir );

    if ( !( isdefined( self.suppress_teargas_behavior ) && self.suppress_teargas_behavior ) )
    {
        self thread brutus_fire_teargas_when_possible();

        if ( isdefined( self.not_interruptable ) && self.not_interruptable )
            return;

        self.not_interruptable = 1;
        self playsound( "vox_brutus_exert" );
        self animscripted( self.origin, self.angles, "zm_pain" );
        self maps\mp\animscripts\zm_shared::donotetracks( "pain_anim" );
        self.not_interruptable = 0;
    }
}

offset_fx_struct( int_struct, fx_struct )
{
    if ( isdefined( int_struct.fx_x_offset ) )
        fx_struct.origin += ( int_struct.fx_x_offset, 0, 0 );

    if ( isdefined( int_struct.fx_y_offset ) )
        fx_struct.origin += ( 0, int_struct.fx_y_offset, 0 );

    if ( isdefined( int_struct.fx_z_offset ) )
        fx_struct.origin += ( 0, 0, int_struct.fx_z_offset );

    if ( isdefined( int_struct.fx_yaw_offset ) )
        fx_struct.angles += ( 0, int_struct.fx_yaw_offset, 0 );

    return fx_struct;
}

get_scaling_lock_cost( int_type, object )
{
    interaction = level.interaction_types[int_type];
    base_cost = interaction.unlock_cost;

    if ( !isdefined( object.num_times_locked ) )
        object.num_times_locked = 0;

    object.num_times_locked++;
    num_times_locked = object.num_times_locked;

    if ( num_times_locked > interaction.num_times_to_scale )
        num_times_locked = interaction.num_times_to_scale;

    return num_times_locked * base_cost;
}

get_lock_hint_string( cost )
{
    switch ( cost )
    {
        case 2000:
            return &"ZOMBIE_LOCKED_COST_2000";
        case 4000:
            return &"ZOMBIE_LOCKED_COST_4000";
        case 6000:
            return &"ZOMBIE_LOCKED_COST_6000";
        default:
            return &"ZOMBIE_LOCKED_COST";
    }
}

magic_box_lock()
{
    self endon( "death" );

    if ( flag( "moving_chest_now" ) )
    {
        self.priority_item = undefined;
        return;
    }

    magic_box = self.priority_item;

    if ( !isdefined( magic_box ) )
        return;

    magic_box.zbarrier set_magic_box_zbarrier_state( "locking" );
    self playsound( "zmb_ai_brutus_clang" );
    magic_box.locked_cost = get_scaling_lock_cost( "magic_box", magic_box );
    level.lockdown_track["magic_box"] = 1;
    level notify( "brutus_locked_object" );
    self.priority_item = undefined;
}

perk_machine_lock()
{
    self endon( "death" );
    perk_machine = self.priority_item get_perk_machine_trigger();

    if ( !isdefined( perk_machine ) )
        return;

    int_struct = level.interaction_types["perk_machine"];

    if ( perk_machine.target == "vending_jugg" || perk_machine.target == "vending_deadshot" )
        lock_fx = level._effect["brutus_lockdown_sm"];
    else
        lock_fx = level._effect["brutus_lockdown"];

    perk_machine.lock_fx = spawn( "script_model", self.priority_item.origin );
    perk_machine.lock_fx.angles = self.priority_item.angles;
    perk_machine.lock_fx = offset_fx_struct( int_struct, perk_machine.lock_fx );
    perk_machine.lock_fx setmodel( "tag_origin" );
    playfxontag( lock_fx, perk_machine.lock_fx, "tag_origin" );
    perk_machine.lock_fx playsound( "zmb_ai_brutus_clang" );
    perk_machine.is_locked = 1;
    perk_machine.locked_cost = get_scaling_lock_cost( "perk_machine", perk_machine );
    perk_machine sethintstring( &"ZOMBIE_LOCKED_COST", perk_machine.locked_cost );
    level.lockdown_track[perk_machine.script_string] = 1;
    level notify( "brutus_locked_object" );
    self.priority_item = undefined;
}

craftable_table_lock()
{
    self endon( "death" );
    table_struct = self.priority_item;

    if ( !isdefined( table_struct ) )
        return;

    craftable_table = table_struct get_trigger_for_craftable();
    int_struct = level.interaction_types["craftable_table"];
    craftable_table.lock_fx = spawn( "script_model", table_struct.origin );
    craftable_table.lock_fx.angles = table_struct.angles;
    craftable_table.lock_fx = offset_fx_struct( int_struct, craftable_table.lock_fx );
    craftable_table.lock_fx setmodel( "tag_origin" );
    playfxontag( level._effect["brutus_lockdown_lg"], craftable_table.lock_fx, "tag_origin" );
    craftable_table.lock_fx playsound( "zmb_ai_brutus_clang" );
    craftable_table.is_locked = 1;
    craftable_table.locked_cost = get_scaling_lock_cost( "craftable_table", craftable_table );
    craftable_table.hint_string = get_lock_hint_string( craftable_table.locked_cost );

    if ( !isdefined( craftable_table.equipname ) )
        craftable_table sethintstring( craftable_table.hint_string );

    if ( isdefined( craftable_table.targetname ) && craftable_table.targetname == "blundergat_upgrade" )
        level.lockdown_track["craft_kit"] = 1;

    if ( isdefined( craftable_table.weaponname ) && craftable_table.weaponname == "alcatraz_shield_zm" )
        level.lockdown_track["craft_shield"] = 1;

    level notify( "brutus_locked_object" );
    self.priority_item = undefined;
}

trap_smash()
{
    self endon( "death" );
    trap = self.priority_item.trigger;

    if ( !isdefined( trap ) )
        return;

    if ( trap.targetname == "fan_trap_use_trigger" )
        trap.zombie_dmg_trig notify( "trap_finished_" + trap.script_string );
    else if ( trap.targetname == "acid_trap_trigger" )
        trap.zombie_dmg_trig notify( "acid_trap_fx_done" );
    else if ( trap.targetname == "tower_trap_activate_trigger" )
        trap notify( "tower_trap_off" );

    trap playsound( "zmb_ai_brutus_clang" );
    self.priority_item = undefined;
}

plane_ramp_lock()
{
    self endon( "death" );
    plane_ramp = self.priority_item;

    if ( !isdefined( plane_ramp ) )
        return;

    int_struct = level.interaction_types["plane_ramp"];
    plane_ramp.lock_fx = spawn( "script_model", plane_ramp.origin );
    plane_ramp.lock_fx.angles = plane_ramp.angles;
    plane_ramp.lock_fx = offset_fx_struct( int_struct, plane_ramp.lock_fx );
    plane_ramp.lock_fx setmodel( "tag_origin" );
    plane_ramp.lock_fx playsound( "zmb_ai_brutus_clang" );
    playfxontag( level._effect["brutus_lockdown"], plane_ramp.lock_fx, "tag_origin" );
    plane_ramp.is_locked = 1;
    plane_ramp.locked_cost = get_scaling_lock_cost( "plane_ramp", plane_ramp );
    plane_ramp.hint_string = get_lock_hint_string( plane_ramp.locked_cost );
    plane_ramp maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
    level.lockdown_track["plane_ramp"] = 1;
    level notify( "brutus_locked_object" );

    if ( !isdefined( plane_ramp.equipname ) )
        plane_ramp.fly_trigger sethintstring( plane_ramp.hint_string );
}

blocker_smash()
{
    self endon( "death" );
    self playsound( "vox_brutus_enraged" );
    self playsound( "zmb_ai_brutus_window_teardown" );
    blocker = self.priority_item;
    self playsound( "zmb_ai_brutus_clang" );

    if ( !isdefined( blocker ) )
        return;

    num_pieces = blocker getnumzbarrierpieces();

    for ( i = 0; i < num_pieces; i++ )
    {
        blocker hidezbarrierpiece( i );
        blocker setzbarrierpiecestate( i, "open" );
    }

    if ( !isdefined( blocker.script_string ) )
        smash_fx_alias = "brutus_smash_default";
    else
        smash_fx_alias = "brutus_smash_" + blocker.script_string;

    forward = anglestoforward( blocker.angles + vectorscale( ( 0, 1, 0 ), 180.0 ) );

    if ( isdefined( level._effect[smash_fx_alias] ) )
        playfx( level._effect[smash_fx_alias], blocker.origin, forward );
    else
        playfx( level._effect["brutus_smash_default"], blocker.origin, forward );

    self.priority_item = undefined;
}

melee_anim_func()
{
    self.next_leap_time = gettime() + 1500;
}

kill_teargas_after_duration( duration )
{
    wait( duration );
    self notify( "kill_teargas" );
    wait_network_frame();
    self delete();
}

teargas_player( player )
{
    player endon( "death_or_disconnect" );
    level endon( "intermission" );
    self endon( "kill_teargas" );
    player.being_teargassed = 1;
    clear_timer = 0;
    teargas_timer = 0;

    while ( true )
    {
        self waittill( "trigger", player );

        while ( true )
        {
            if ( !player istouching( self ) )
                clear_timer += 0.1;
            else
                clear_timer = 0;

            if ( clear_timer >= level.player_teargas_duration )
            {
                player.being_teargassed = 0;
                break;
            }
            else if ( teargas_timer % 5 == 0 )
            {
                if ( distancesquared( player.origin, self.origin ) > level.brutus_teargas_radius * 2 / 3 * level.brutus_teargas_radius * 2 / 3 )
                    player shellshock( "mp_radiation_low", 1.5 );
                else if ( distancesquared( player.origin, self.origin ) > level.brutus_teargas_radius * 1 / 3 * level.brutus_teargas_radius * 1 / 3 )
                    player shellshock( "mp_radiation_med", 1.5 );
                else
                    player shellshock( "mp_radiation_high", 1.5 );
            }

            teargas_timer++;
            wait 0.1;
        }
    }
}

teargas_trigger_think()
{
    self endon( "kill_teargas" );
    self thread kill_teargas_after_duration( level.brutus_teargas_duration );
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( !( isdefined( players[i].being_teargassed ) && players[i].being_teargassed ) )
            self thread teargas_player( players[i] );
    }
}

precache_default_brutus_barrier_fx()
{
    level._effect["brutus_smash_default"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_brut_brk_wood" );
}

scale_helmet_damage( attacker, damage, headshot_mod, damage_mod, vdir )
{
    if ( !self.has_helmet )
        return damage * headshot_mod;
    else
    {
        self.helmet_hits++;

        if ( self.helmet_hits >= level.brutus_helmet_shots )
        {
            self thread brutus_remove_helmet( vdir );

            if ( level.brutus_in_grief )
                player_points = level.brutus_points_for_helmet;
            else
            {
                multiplier = maps\mp\zombies\_zm_score::get_points_multiplier( self );
                player_points = multiplier * round_up_score( level.brutus_points_for_helmet, 5 );
            }

            if ( isdefined( attacker ) && isplayer( attacker ) )
            {
                attacker add_to_player_score( player_points );
                attacker.pers["score"] = attacker.score;
                level notify( "brutus_helmet_removed", attacker );
            }
        }

        return damage * damage_mod;
    }
}

brutus_non_attacker_damage_override( damage, weapon )
{
    scaled_dmg = 0;

    if ( weapon == "tower_trap_zm" )
        scaled_dmg = self scale_helmet_damage( undefined, damage, 0.1, 0.01, vectorscale( ( 0, 1, 0 ), 10.0 ) );

    return int( scaled_dmg );
}

is_weapon_shotgun( sweapon )
{
    if ( weaponclass( sweapon ) == "spread" )
        return true;

    return false;
}

brutus_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, poffsettime, boneindex )
{
    if ( isdefined( attacker ) && isalive( attacker ) && isplayer( attacker ) && ( level.zombie_vars[attacker.team]["zombie_insta_kill"] || isdefined( attacker.personal_instakill ) && attacker.personal_instakill ) )
    {
        n_brutus_damage_percent = 1.0;
        n_brutus_headshot_modifier = 2.0;
    }
    else
    {
        n_brutus_damage_percent = level.brutus_damage_percent;
        n_brutus_headshot_modifier = 1.0;
    }

    if ( isdefined( weapon ) && is_weapon_shotgun( weapon ) )
    {
        n_brutus_damage_percent *= level.brutus_shotgun_damage_mod;
        n_brutus_headshot_modifier *= level.brutus_shotgun_damage_mod;
    }

    if ( isdefined( weapon ) && weapon == "bouncing_tomahawk_zm" && isdefined( inflictor ) )
    {
        self playsound( "wpn_tomahawk_imp_zombie" );

        if ( self.has_helmet )
        {
            if ( damage == 1 )
                return 0;

            if ( isdefined( inflictor.n_cookedtime ) && inflictor.n_cookedtime >= 2000 )
                self.helmet_hits = level.brutus_helmet_shots;
            else if ( isdefined( inflictor.n_grenade_charge_power ) && inflictor.n_grenade_charge_power >= 2 )
                self.helmet_hits = level.brutus_helmet_shots;
            else
                self.helmet_hits++;

            if ( self.helmet_hits >= level.brutus_helmet_shots )
            {
                self thread brutus_remove_helmet( vdir );

                if ( level.brutus_in_grief )
                    player_points = level.brutus_points_for_helmet;
                else
                {
                    multiplier = maps\mp\zombies\_zm_score::get_points_multiplier( self );
                    player_points = multiplier * round_up_score( level.brutus_points_for_helmet, 5 );
                }

                if ( isdefined( attacker ) && isplayer( attacker ) )
                {
                    attacker add_to_player_score( player_points );
                    attacker.pers["score"] = attacker.score;
                    level notify( "brutus_helmet_removed", attacker );
                }
            }

            return damage * n_brutus_damage_percent;
        }
        else
            return damage;
    }

    if ( isdefined( meansofdeath ) && ( meansofdeath == "MOD_MELEE" || meansofdeath == "MOD_IMPACT" ) )
    {
        if ( weapon == "alcatraz_shield_zm" )
        {
            shield_damage = level.zombie_vars["riotshield_fling_damage_shield"];
            inflictor maps\mp\zombies\_zm_weap_riotshield_prison::player_damage_shield( shield_damage, 0 );
            return 0;
        }
    }

    if ( isdefined( level.zombiemode_using_afterlife ) && level.zombiemode_using_afterlife && weapon == "lightning_hands_zm" )
    {
        self thread brutus_afterlife_teleport();
        return 0;
    }

    if ( is_explosive_damage( meansofdeath ) )
    {
        self.explosive_dmg_taken += damage;

        if ( !self.has_helmet )
            scaler = n_brutus_headshot_modifier;
        else
            scaler = level.brutus_damage_percent;

        if ( self.explosive_dmg_taken >= self.explosive_dmg_req && ( isdefined( self.has_helmet ) && self.has_helmet ) )
        {
            self thread brutus_remove_helmet( vectorscale( ( 0, 1, 0 ), 10.0 ) );

            if ( level.brutus_in_grief )
                player_points = level.brutus_points_for_helmet;
            else
            {
                multiplier = maps\mp\zombies\_zm_score::get_points_multiplier( self );
                player_points = multiplier * round_up_score( level.brutus_points_for_helmet, 5 );
            }

            attacker add_to_player_score( player_points );
            attacker.pers["score"] = inflictor.score;
        }

        return damage * scaler;
    }
    else if ( shitloc != "head" && shitloc != "helmet" )
        return damage * n_brutus_damage_percent;
    else
        return int( self scale_helmet_damage( attacker, damage, n_brutus_headshot_modifier, n_brutus_damage_percent, vdir ) );
}

brutus_instakill_override()
{

}

brutus_nuke_override()
{
    self endon( "death" );
    wait( randomfloatrange( 0.1, 0.7 ) );
    self thread maps\mp\animscripts\zm_death::flame_death_fx();
    self playsound( "evt_nuked" );
    self dodamage( level.brutus_health * 0.25, self.origin );
}

custom_brutus_flame_death_fx()
{
    self endon( "death" );

    if ( isdefined( self.is_on_fire ) && self.is_on_fire )
        return;

    self.is_on_fire = 1;
    a_script_origins = [];

    if ( isdefined( level._effect ) && isdefined( level._effect["character_fire_death_torso"] ) )
    {
        if ( !self.isdog )
        {
            v_origin = self gettagorigin( "J_SpineLower" );
            e_origin = spawn( "script_origin", v_origin );
            e_origin setmodel( "tag_origin" );
            e_origin linkto( self, "J_SpineLower" );
            playfxontag( level._effect["character_fire_death_torso"], e_origin, "tag_origin" );
            a_script_origins[a_script_origins.size] = e_origin;
        }
    }
    else
    {
/#
        println( "^3ANIMSCRIPT WARNING: You are missing level._effect[\"character_fire_death_torso\"], please set it in your levelname_fx.gsc. Use \"env/fire/fx_fire_player_torso\"" );
#/
    }

    if ( isdefined( level._effect ) && isdefined( level._effect["character_fire_death_sm"] ) )
    {
        wait 1;
        tagarray = [];
        tagarray[0] = "J_Elbow_LE";
        tagarray[1] = "J_Elbow_RI";
        tagarray[2] = "J_Knee_RI";
        tagarray[3] = "J_Knee_LE";
        tagarray = maps\mp\animscripts\zm_death::randomize_array( tagarray );
        v_origin = self gettagorigin( tagarray[0] );
        e_origin = spawn( "script_origin", v_origin );
        e_origin setmodel( "tag_origin" );
        e_origin linkto( self, tagarray[0] );
        playfxontag( level._effect["character_fire_death_torso"], e_origin, "tag_origin" );
        a_script_origins[a_script_origins.size] = e_origin;
        wait 1;
        tagarray[0] = "J_Wrist_RI";
        tagarray[1] = "J_Wrist_LE";

        if ( !isdefined( self.a ) || !isdefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" )
        {
            tagarray[2] = "J_Ankle_RI";
            tagarray[3] = "J_Ankle_LE";
        }

        tagarray = maps\mp\animscripts\zm_death::randomize_array( tagarray );
        v_origin_0 = self gettagorigin( tagarray[0] );
        v_origin_1 = self gettagorigin( tagarray[1] );
        e_origin_0 = spawn( "script_origin", v_origin_0 );
        e_origin_1 = spawn( "script_origin", v_origin_1 );
        e_origin_0 setmodel( "tag_origin" );
        e_origin_1 setmodel( "tag_origin" );
        e_origin_0 linkto( self, tagarray[0] );
        e_origin_1 linkto( self, tagarray[1] );
        playfxontag( level._effect["character_fire_death_torso"], e_origin_0, "tag_origin" );
        playfxontag( level._effect["character_fire_death_torso"], e_origin_1, "tag_origin" );
        a_script_origins[a_script_origins.size] = e_origin_0;
        a_script_origins[a_script_origins.size] = e_origin_1;
    }
    else
    {
/#
        println( "^3ANIMSCRIPT WARNING: You are missing level._effect[\"character_fire_death_sm\"], please set it in your levelname_fx.gsc. Use \"env/fire/fx_fire_zombie_md\"" );
#/
    }

    self thread custom_brutus_on_fire_timeout( a_script_origins );
}

custom_brutus_on_fire_timeout( a_script_origins )
{
    self endon( "death" );
    wait 3;

    if ( isdefined( self ) && isalive( self ) )
    {
        self.is_on_fire = 0;
        self notify( "stop_flame_damage" );
    }

    foreach ( script_origin in a_script_origins )
        script_origin delete();
}

brutus_debug()
{
/#
    while ( true )
    {
        debug_level = getdvarint( _hash_8DB11170 );

        if ( isdefined( debug_level ) && debug_level )
        {
            if ( debug_level == 1 )
            {
                brutus_array = getentarray( "brutus_zombie_ai" );

                for ( i = 0; i < brutus_array.size; i++ )
                {
                    if ( isdefined( brutus_array[i].goal_pos ) )
                    {
                        debugstar( brutus_array[i].goal_pos, ( 1, 0, 0 ), 1 );
                        line( brutus_array[i].goal_pos, brutus_array[i].origin, ( 1, 0, 0 ), 0, 1 );
                    }
                }
            }
        }
    }
#/
}

brutus_check_zone()
{
    self endon( "death" );
    self.in_player_zone = 0;

    while ( true )
    {
        self.in_player_zone = 0;

        foreach ( zone in level.zones )
        {
            if ( !isdefined( zone.volumes ) || zone.volumes.size == 0 )
                continue;

            zone_name = zone.volumes[0].targetname;

            if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( zone_name ) )
            {
                if ( is_true( zone.is_occupied ) )
                {
                    self.in_player_zone = 1;
                    break;
                }
            }
        }

        wait 0.2;
    }
}

brutus_watch_enemy()
{
    self endon( "death" );

    while ( true )
    {
        if ( !is_player_valid( self.favoriteenemy ) )
            self.favoriteenemy = get_favorite_enemy();

        wait 0.2;
    }
}

get_favorite_enemy()
{
    brutus_targets = getplayers();
    least_hunted = brutus_targets[0];

    for ( i = 0; i < brutus_targets.size; i++ )
    {
        if ( !isdefined( brutus_targets[i].hunted_by ) )
            brutus_targets[i].hunted_by = 0;

        if ( !is_player_valid( brutus_targets[i] ) )
            continue;

        if ( !is_player_valid( least_hunted ) )
            least_hunted = brutus_targets[i];

        if ( brutus_targets[i].hunted_by < least_hunted.hunted_by )
            least_hunted = brutus_targets[i];
    }

    least_hunted.hunted_by += 1;
    return least_hunted;
}

brutus_lockdown_client_effects( delay )
{
    self endon( "death" );

    if ( isdefined( delay ) )
        wait( delay );

    if ( self.brutus_lockdown_state )
    {
        self.brutus_lockdown_state = 0;
        self setclientfield( "brutus_lock_down", 0 );
    }
    else
    {
        self.brutus_lockdown_state = 1;
        self setclientfield( "brutus_lock_down", 1 );
    }
}

get_brutus_interest_points()
{
    zone_names = getarraykeys( level.zones );

    for ( i = 0; i < zone_names.size; i++ )
    {
        self thread get_zone_perk_machines( zone_names[i] );
        self thread get_zone_craftable_tables( zone_names[i] );
        self thread get_zone_traps( zone_names[i] );
        self thread get_zone_plane_ramp( zone_names[i] );
    }

    build_trap_array();
    flag_set( "brutus_setup_complete" );
}

build_trap_array()
{
    fan_array = getentarray( "acid_trap_trigger", "targetname" );
    acid_array = getentarray( "fan_trap_use_trigger", "targetname" );
    level.trap_triggers = arraycombine( fan_array, acid_array, 0, 0 );
}

add_machines_in_zone( zone, zone_name, match_string )
{
    machine_array = getentarray( match_string, "targetname" );

    for ( i = 0; i < machine_array.size; i++ )
    {
        if ( machine_array[i] entity_in_zone( zone_name, 1 ) )
            zone.perk_machines[zone.perk_machines.size] = machine_array[i];
    }
}

get_zone_perk_machines( zone_name )
{
    zone = level.zones[zone_name];
    zone.perk_machines = [];
    machine_array = [];

    if ( isdefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
        add_machines_in_zone( zone, zone_name, "vending_doubletap" );

    if ( isdefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
        add_machines_in_zone( zone, zone_name, "vending_revive" );

    if ( isdefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
        add_machines_in_zone( zone, zone_name, "vending_jugg" );

    if ( isdefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
        add_machines_in_zone( zone, zone_name, "vending_sleight" );

    if ( isdefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
        add_machines_in_zone( zone, zone_name, "vending_deadshot_model" );

    if ( isdefined( level.zombiemode_using_electric_cherry_perk ) && level.zombiemode_using_electric_cherry_perk )
        add_machines_in_zone( zone, zone_name, "vendingelectric_cherry" );

    if ( isdefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
        add_machines_in_zone( zone, zone_name, "vending_additionalprimaryweapon" );

    if ( isdefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
        add_machines_in_zone( zone, zone_name, "vending_marathon" );

    if ( isdefined( level.zombiemode_using_divetonuke_perk ) && level.zombiemode_using_divetonuke_perk )
        add_machines_in_zone( zone, zone_name, "vending_divetonuke" );

    if ( isdefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
        add_machines_in_zone( zone, zone_name, "vending_chugabud" );
}

get_zone_craftable_tables( zone_name )
{
    flag_wait( "initial_players_connected" );
    zone = level.zones[zone_name];
    zone.craftable_tables = [];

    while ( level.a_uts_craftables.size == 0 )
        wait 1;

    scr_org = spawn( "script_origin", ( 0, 0, 0 ) );
    craftable_tables = level.a_uts_craftables;

    for ( i = 0; i < craftable_tables.size; i++ )
    {
        if ( !isdefined( craftable_tables[i].origin ) )
            continue;

        scr_org.origin = craftable_tables[i].origin;
        wait 0.05;

        if ( craftable_tables[i].equipname == "open_table" && scr_org entity_in_zone( zone_name, 1 ) )
            zone.craftable_tables[zone.craftable_tables.size] = getstruct( craftable_tables[i].target, "targetname" );
    }

    scr_org delete();
}

get_zone_traps( zone_name )
{
    zone = level.zones[zone_name];
    zone.traps = [];
    acid_traps = getentarray( "acid_trap_trigger", "targetname" );
    scr_org = spawn( "script_origin", ( 0, 0, 0 ) );

    for ( i = 0; i < acid_traps.size; i++ )
    {
        target_struct = getstruct( acid_traps[i].script_parameters, "targetname" );
        acid_traps[i].target_struct = target_struct;
        scr_org.origin = target_struct.origin;
        wait 0.05;

        if ( scr_org entity_in_zone( zone_name, 1 ) )
        {
            zone.traps[zone.traps.size] = acid_traps[i].target_struct;
            target_struct.trigger = acid_traps[i];
        }
    }

    fan_traps = getentarray( "fan_trap_use_trigger", "targetname" );

    for ( i = 0; i < fan_traps.size; i++ )
    {
        target_struct = getstruct( fan_traps[i].script_parameters, "targetname" );
        fan_traps[i].target_struct = target_struct;
        scr_org.origin = target_struct.origin;
        wait 0.05;

        if ( scr_org entity_in_zone( zone_name, 1 ) )
        {
            zone.traps[zone.traps.size] = fan_traps[i].target_struct;
            target_struct.trigger = fan_traps[i];
        }
    }

    tower_traps = getentarray( "tower_trap_activate_trigger", "targetname" );

    for ( i = 0; i < tower_traps.size; i++ )
    {
        target_struct = getstruct( tower_traps[i].script_parameters, "targetname" );
        tower_traps[i].target_struct = target_struct;
        scr_org.origin = target_struct.origin;
        wait 0.05;

        if ( scr_org entity_in_zone( zone_name, 1 ) )
        {
            zone.traps[zone.traps.size] = tower_traps[i].target_struct;
            target_struct.trigger = tower_traps[i];
        }
    }

    scr_org delete();
}

get_zone_plane_ramp( zone_name )
{
    flag_wait( "initial_players_connected" );
    zone = level.zones[zone_name];
    zone.plane_triggers = [];
    scr_org = spawn( "script_origin", ( 0, 0, 0 ) );
    fly_trigger = getent( "plane_fly_trigger", "targetname" );
    scr_org.origin = fly_trigger.origin;

    if ( scr_org entity_in_zone( zone_name, 1 ) )
    {
        fly_trigger_target = spawn( "script_model", ( 0, 0, 0 ) );
        fly_trigger_target.targetname = "fly_target";
        fly_trigger.fly_trigger_target = fly_trigger_target;
        fly_trigger_target.fly_trigger = fly_trigger;
        zone.plane_triggers[zone.plane_triggers.size] = fly_trigger_target;
    }

    while ( level.a_uts_craftables.size == 0 )
        wait 1;

    for ( i = 0; i < level.a_uts_craftables.size; i++ )
    {
        if ( level.a_uts_craftables[i].equipname == "plane" )
        {
            scr_org.origin = level.a_uts_craftables[i].origin;
            wait 0.05;

            if ( scr_org entity_in_zone( zone_name, 1 ) )
            {
                zone.plane_triggers[zone.plane_triggers.size] = level.a_uts_craftables[i];
                fly_trigger_target.origin = level.a_uts_craftables[i].origin;
                fly_trigger_target.angles = level.a_uts_craftables[i].angles;
            }
        }
    }

    scr_org delete();
}

check_magic_box_valid( player )
{
    if ( isdefined( self.is_locked ) && self.is_locked )
    {
        if ( player.score >= self.locked_cost )
        {
            player minus_to_player_score( self.locked_cost );
            self.is_locked = 0;
            self.locked_cost = undefined;
            self.zbarrier set_magic_box_zbarrier_state( "unlocking" );
        }

        return false;
    }

    return true;
}

check_perk_machine_valid( player )
{
    if ( isdefined( self.is_locked ) && self.is_locked )
    {
        if ( player.score >= self.locked_cost )
        {
            player minus_to_player_score( self.locked_cost );
            self.is_locked = 0;
            self.locked_cost = undefined;
            self.lock_fx delete();
            self maps\mp\zombies\_zm_perks::reset_vending_hint_string();
        }

        return false;
    }

    return true;
}

check_craftable_table_valid( player )
{
    if ( !isdefined( self.stub ) && ( isdefined( self.is_locked ) && self.is_locked ) )
    {
        if ( player.score >= self.locked_cost )
        {
            player minus_to_player_score( self.locked_cost );
            self.is_locked = 0;
            self.locked_cost = undefined;
            self.lock_fx delete();
        }

        return false;
    }
    else if ( isdefined( self.stub ) && ( isdefined( self.stub.is_locked ) && self.stub.is_locked ) )
    {
        if ( player.score >= self.stub.locked_cost )
        {
            player minus_to_player_score( self.stub.locked_cost );
            self.stub.is_locked = 0;
            self.stub.locked_cost = undefined;
            self.stub.lock_fx delete();
            self.stub thread maps\mp\zombies\_zm_craftables::craftablestub_update_prompt( player );
            self sethintstring( self.stub.hint_string );
        }

        return false;
    }

    return true;
}

check_plane_valid( player )
{
    if ( isdefined( self.fly_trigger_target ) )
        plane_struct = self.fly_trigger_target;
    else
        plane_struct = self;

    if ( isdefined( plane_struct.is_locked ) && plane_struct.is_locked )
    {
        if ( player.score >= plane_struct.locked_cost )
        {
            player minus_to_player_score( plane_struct.locked_cost );
            plane_struct.is_locked = 0;
            plane_struct.locked_cost = undefined;
            plane_struct.lock_fx delete();
            plane_struct maps\mp\zm_alcatraz_sq::reset_plane_hint_string( player );
        }

        return false;
    }

    return true;
}

sndbrutusvox( alias, num )
{
    self endon( "brutus_cleanup" );

    if ( !isdefined( alias ) )
        return;

    num_variants = maps\mp\zombies\_zm_spawner::get_number_variants( alias );

    if ( num_variants <= 0 )
        return;

    if ( isdefined( num ) && num <= num_variants )
        num_variants = num;

    if ( !level.sndbrutusistalking )
    {
        level.sndbrutusistalking = 1;
        alias = alias + "_" + randomintrange( 0, num_variants );
        playbacktime = soundgetplaybacktime( alias );

        if ( playbacktime >= 0 )
            playbacktime *= 0.001;
        else
            playbacktime = 1;

        self playsoundontag( alias, "J_head" );
        wait( playbacktime );
        level.sndbrutusistalking = 0;
    }
}

get_fly_trigger()
{
    plane_triggers = level.zones["zone_roof"].plane_triggers;

    for ( i = 0; i < plane_triggers.size; i++ )
    {
        if ( isdefined( plane_triggers[i].fly_trigger ) )
            return plane_triggers[i];
    }
}

get_build_trigger()
{
    plane_triggers = level.zones["zone_roof"].plane_triggers;

    for ( i = 0; i < plane_triggers.size; i++ )
    {
        if ( isdefined( plane_triggers[i].equipname ) && plane_triggers[i].equipname == "plane" )
            return plane_triggers[i];
    }
}

get_fuel_trigger()
{
    plane_triggers = level.zones["zone_roof"].plane_triggers;

    for ( i = 0; i < plane_triggers.size; i++ )
    {
        if ( isdefined( plane_triggers[i].equipname ) && plane_triggers[i].equipname == "refuelable_plane" )
            return plane_triggers[i];
    }
}

transfer_plane_trigger( from, to )
{
    if ( from == "fly" )
        from_trigger = get_fly_trigger();
    else if ( from == "build" )
        from_trigger = get_build_trigger();
    else
        from_trigger = get_fuel_trigger();

    if ( to == "fly" )
        to_trigger = get_fly_trigger();
    else if ( to == "build" )
        to_trigger = get_build_trigger();
    else
        to_trigger = get_fuel_trigger();

    to_trigger.lock_fx = from_trigger.lock_fx;
    to_trigger.is_locked = from_trigger.is_locked;
    to_trigger.num_times_locked = from_trigger.num_times_locked;
    to_trigger.hint_string = from_trigger.hint_string;
    to_trigger.locked_cost = from_trigger.locked_cost;
    from_trigger.lock_fx = undefined;
    from_trigger.is_locked = 0;
    from_trigger.locked_cost = undefined;

    if ( from == "fly" )
    {
        t_plane_fly = getent( "plane_fly_trigger", "targetname" );
        t_plane_fly sethintstring( &"ZM_PRISON_PLANE_BOARD" );
    }
}
