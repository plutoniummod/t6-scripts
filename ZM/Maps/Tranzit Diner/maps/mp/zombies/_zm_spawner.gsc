// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\animscripts\zm_death;
#include maps\mp\animscripts\zm_run;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_pers_upgrades;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_ai_faller;

init()
{
    level._contextual_grab_lerp_time = 0.3;
    level.zombie_spawners = getentarray( "zombie_spawner", "script_noteworthy" );

    if ( isdefined( level.use_multiple_spawns ) && level.use_multiple_spawns )
    {
        level.zombie_spawn = [];

        for ( i = 0; i < level.zombie_spawners.size; i++ )
        {
            if ( isdefined( level.zombie_spawners[i].script_int ) )
            {
                int = level.zombie_spawners[i].script_int;

                if ( !isdefined( level.zombie_spawn[int] ) )
                    level.zombie_spawn[int] = [];

                level.zombie_spawn[int][level.zombie_spawn[int].size] = level.zombie_spawners[i];
            }
        }
    }

    precachemodel( "p6_anim_zm_barricade_board_01_upgrade" );
    precachemodel( "p6_anim_zm_barricade_board_02_upgrade" );
    precachemodel( "p6_anim_zm_barricade_board_03_upgrade" );
    precachemodel( "p6_anim_zm_barricade_board_04_upgrade" );
    precachemodel( "p6_anim_zm_barricade_board_05_upgrade" );
    precachemodel( "p6_anim_zm_barricade_board_06_upgrade" );

    if ( isdefined( level.ignore_spawner_func ) )
    {
        for ( i = 0; i < level.zombie_spawners.size; i++ )
        {
            ignore = [[ level.ignore_spawner_func ]]( level.zombie_spawners[i] );

            if ( ignore )
                arrayremovevalue( level.zombie_spawners, level.zombie_spawners[i] );
        }
    }

    gametype = getdvar( "ui_gametype" );

    if ( !isdefined( level.attack_player_thru_boards_range ) )
        level.attack_player_thru_boards_range = 109.8;

    if ( isdefined( level._game_module_custom_spawn_init_func ) )
        [[ level._game_module_custom_spawn_init_func ]]();

    registerclientfield( "actor", "zombie_has_eyes", 1, 1, "int" );
    registerclientfield( "actor", "zombie_ragdoll_explode", 1, 1, "int" );
    registerclientfield( "actor", "zombie_gut_explosion", 9000, 1, "int" );
}

add_cusom_zombie_spawn_logic( func )
{
    if ( !isdefined( level._zombie_custom_spawn_logic ) )
        level._zombie_custom_spawn_logic = [];

    level._zombie_custom_spawn_logic[level._zombie_custom_spawn_logic.size] = func;
}

player_attacks_enemy( player, amount, type, point )
{
    team = undefined;

    if ( isdefined( self._race_team ) )
        team = self._race_team;

    if ( !isads( player ) )
    {
        [[ level.global_damage_func ]]( type, self.damagelocation, point, player, amount, team );
        return false;
    }

    if ( !bullet_attack( type ) )
    {
        [[ level.global_damage_func ]]( type, self.damagelocation, point, player, amount, team );
        return false;
    }

    [[ level.global_damage_func_ads ]]( type, self.damagelocation, point, player, amount, team );
    return true;
}

player_attacker( attacker )
{
    if ( isplayer( attacker ) )
        return true;

    return false;
}

enemy_death_detection()
{
    self endon( "death" );

    for (;;)
    {
        self waittill( "damage", amount, attacker, direction_vec, point, type );

        if ( !isdefined( amount ) )
            continue;

        if ( !isalive( self ) || self.delayeddeath )
            return;

        if ( !player_attacker( attacker ) )
            continue;

        self.has_been_damaged_by_player = 1;
        self player_attacks_enemy( attacker, amount, type, point );
    }
}

is_spawner_targeted_by_blocker( ent )
{
    if ( isdefined( ent.targetname ) )
    {
        targeters = getentarray( ent.targetname, "target" );

        for ( i = 0; i < targeters.size; i++ )
        {
            if ( targeters[i].targetname == "zombie_door" || targeters[i].targetname == "zombie_debris" )
                return true;

            result = is_spawner_targeted_by_blocker( targeters[i] );

            if ( result )
                return true;
        }
    }

    return false;
}

add_custom_zombie_spawn_logic( func )
{
    if ( !isdefined( level._zombie_custom_spawn_logic ) )
        level._zombie_custom_spawn_logic = [];

    level._zombie_custom_spawn_logic[level._zombie_custom_spawn_logic.size] = func;
}

zombie_spawn_init( animname_set )
{
    if ( !isdefined( animname_set ) )
        animname_set = 0;

    self.targetname = "zombie";
    self.script_noteworthy = undefined;
    recalc_zombie_array();

    if ( !animname_set )
        self.animname = "zombie";

    if ( isdefined( get_gamemode_var( "pre_init_zombie_spawn_func" ) ) )
        self [[ get_gamemode_var( "pre_init_zombie_spawn_func" ) ]]();

    self thread play_ambient_zombie_vocals();
    self.zmb_vocals_attack = "zmb_vocals_zombie_attack";
    self.ignoreall = 1;
    self.ignoreme = 1;
    self.allowdeath = 1;
    self.force_gib = 1;
    self.is_zombie = 1;
    self.has_legs = 1;
    self allowedstances( "stand" );
    self.zombie_damaged_by_bar_knockdown = 0;
    self.gibbed = 0;
    self.head_gibbed = 0;
    self setphysparams( 15, 0, 72 );
    self.disablearrivals = 1;
    self.disableexits = 1;
    self.grenadeawareness = 0;
    self.badplaceawareness = 0;
    self.ignoresuppression = 1;
    self.suppressionthreshold = 1;
    self.nododgemove = 1;
    self.dontshootwhilemoving = 1;
    self.pathenemylookahead = 0;
    self.badplaceawareness = 0;
    self.chatinitialized = 0;
    self.a.disablepain = 1;
    self disable_react();

    if ( isdefined( level.zombie_health ) )
    {
        self.maxhealth = level.zombie_health;

        if ( isdefined( level.zombie_respawned_health ) && level.zombie_respawned_health.size > 0 )
        {
            self.health = level.zombie_respawned_health[0];
            arrayremovevalue( level.zombie_respawned_health, level.zombie_respawned_health[0] );
        }
        else
            self.health = level.zombie_health;
    }
    else
    {
        self.maxhealth = level.zombie_vars["zombie_health_start"];
        self.health = self.maxhealth;
    }

    self.freezegun_damage = 0;
    self.dropweapon = 0;
    level thread zombie_death_event( self );
    self init_zombie_run_cycle();
    self thread zombie_think();
    self thread zombie_gib_on_damage();
    self thread zombie_damage_failsafe();
    self thread enemy_death_detection();

    if ( isdefined( level._zombie_custom_spawn_logic ) )
    {
        if ( isarray( level._zombie_custom_spawn_logic ) )
        {
            for ( i = 0; i < level._zombie_custom_spawn_logic.size; i++ )
                self thread [[ level._zombie_custom_spawn_logic[i] ]]();
        }
        else
            self thread [[ level._zombie_custom_spawn_logic ]]();
    }

    if ( !isdefined( self.no_eye_glow ) || !self.no_eye_glow )
    {
        if ( !( isdefined( self.is_inert ) && self.is_inert ) )
            self thread delayed_zombie_eye_glow();
    }

    self.deathfunction = ::zombie_death_animscript;
    self.flame_damage_time = 0;
    self.meleedamage = 60;
    self.no_powerups = 1;
    self zombie_history( "zombie_spawn_init -> Spawned = " + self.origin );
    self.thundergun_knockdown_func = level.basic_zombie_thundergun_knockdown;
    self.tesla_head_gib_func = ::zombie_tesla_head_gib;
    self.team = level.zombie_team;

    if ( isdefined( level.achievement_monitor_func ) )
        self [[ level.achievement_monitor_func ]]();

    if ( isdefined( get_gamemode_var( "post_init_zombie_spawn_func" ) ) )
        self [[ get_gamemode_var( "post_init_zombie_spawn_func" ) ]]();

    if ( isdefined( level.zombie_init_done ) )
        self [[ level.zombie_init_done ]]();

    self.zombie_init_done = 1;
    self notify( "zombie_init_done" );
}

delayed_zombie_eye_glow()
{
    self endon( "zombie_delete" );

    if ( isdefined( self.in_the_ground ) && self.in_the_ground || isdefined( self.in_the_ceiling ) && self.in_the_ceiling )
    {
        while ( !isdefined( self.create_eyes ) )
            wait 0.1;
    }
    else
        wait 0.5;

    self zombie_eye_glow();
}

zombie_damage_failsafe()
{
    self endon( "death" );
    continue_failsafe_damage = 0;

    while ( true )
    {
        wait 0.5;

        if ( !isdefined( self.enemy ) || !isplayer( self.enemy ) )
            continue;

        if ( self istouching( self.enemy ) )
        {
            old_org = self.origin;

            if ( !continue_failsafe_damage )
                wait 5;

            if ( !isdefined( self.enemy ) || !isplayer( self.enemy ) || self.enemy hasperk( "specialty_armorvest" ) )
                continue;

            if ( self istouching( self.enemy ) && !self.enemy maps\mp\zombies\_zm_laststand::player_is_in_laststand() && isalive( self.enemy ) )
            {
                if ( distancesquared( old_org, self.origin ) < 3600 )
                {
                    self.enemy dodamage( self.enemy.health + 1000, self.enemy.origin, self, self, "none", "MOD_RIFLE_BULLET" );
                    continue_failsafe_damage = 1;
                }
            }
        }
        else
            continue_failsafe_damage = 0;
    }
}

should_skip_teardown( find_flesh_struct_string )
{
    if ( isdefined( find_flesh_struct_string ) && find_flesh_struct_string == "find_flesh" )
        return true;

    if ( isdefined( self.script_string ) && self.script_string == "zombie_chaser" )
        return true;

    return false;
}

zombie_think()
{
    self endon( "death" );
/#
    assert( !self.isdog );
#/
    self.ai_state = "zombie_think";
    find_flesh_struct_string = undefined;

    if ( isdefined( level.zombie_custom_think_logic ) )
    {
        shouldwait = self [[ level.zombie_custom_think_logic ]]();

        if ( shouldwait )
            self waittill( "zombie_custom_think_done", find_flesh_struct_string );
    }
    else if ( isdefined( self.start_inert ) && self.start_inert )
        find_flesh_struct_string = "find_flesh";
    else
    {
        if ( isdefined( self.custom_location ) )
            self thread [[ self.custom_location ]]();
        else
            self thread do_zombie_spawn();

        self waittill( "risen", find_flesh_struct_string );
    }

    node = undefined;
    desired_nodes = [];
    self.entrance_nodes = [];

    if ( isdefined( level.max_barrier_search_dist_override ) )
        max_dist = level.max_barrier_search_dist_override;
    else
        max_dist = 500;

    if ( !isdefined( find_flesh_struct_string ) && isdefined( self.target ) && self.target != "" )
    {
        desired_origin = get_desired_origin();
/#
        assert( isdefined( desired_origin ), "Spawner @ " + self.origin + " has a .target but did not find a target" );
#/
        origin = desired_origin;
        node = getclosest( origin, level.exterior_goals );
        self.entrance_nodes[self.entrance_nodes.size] = node;
        self zombie_history( "zombie_think -> #1 entrance (script_forcegoal) origin = " + self.entrance_nodes[0].origin );
    }
    else if ( self should_skip_teardown( find_flesh_struct_string ) )
    {
        self zombie_setup_attack_properties();

        if ( isdefined( self.target ) )
        {
            end_at_node = getnode( self.target, "targetname" );

            if ( isdefined( end_at_node ) )
            {
                self setgoalnode( end_at_node );

                self waittill( "goal" );
            }
        }

        if ( isdefined( self.start_inert ) && self.start_inert )
        {
            self thread maps\mp\zombies\_zm_ai_basic::start_inert( 1 );
            self zombie_complete_emerging_into_playable_area();
        }
        else
        {
            self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
            self thread zombie_entered_playable();
        }

        return;
    }
    else if ( isdefined( find_flesh_struct_string ) )
    {
/#
        assert( isdefined( find_flesh_struct_string ) );
#/
        for ( i = 0; i < level.exterior_goals.size; i++ )
        {
            if ( isdefined( level.exterior_goals[i].script_string ) && level.exterior_goals[i].script_string == find_flesh_struct_string )
            {
                node = level.exterior_goals[i];
                break;
            }
        }

        self.entrance_nodes[self.entrance_nodes.size] = node;
        self zombie_history( "zombie_think -> #1 entrance origin = " + node.origin );
        self thread zombie_assure_node();
    }
    else
    {
        origin = self.origin;
        desired_origin = get_desired_origin();

        if ( isdefined( desired_origin ) )
            origin = desired_origin;

        nodes = get_array_of_closest( origin, level.exterior_goals, undefined, 3 );
        desired_nodes[0] = nodes[0];
        prev_dist = distance( self.origin, nodes[0].origin );

        for ( i = 1; i < nodes.size; i++ )
        {
            dist = distance( self.origin, nodes[i].origin );

            if ( dist - prev_dist > max_dist )
                break;

            prev_dist = dist;
            desired_nodes[i] = nodes[i];
        }

        node = desired_nodes[0];

        if ( desired_nodes.size > 1 )
            node = desired_nodes[randomint( desired_nodes.size )];

        self.entrance_nodes = desired_nodes;
        self zombie_history( "zombie_think -> #1 entrance origin = " + node.origin );
        self thread zombie_assure_node();
    }
/#
    assert( isdefined( node ), "Did not find a node!!! [Should not see this!]" );
#/
    level thread draw_line_ent_to_pos( self, node.origin, "goal" );
    self.first_node = node;
    self thread zombie_goto_entrance( node );
}

zombie_entered_playable()
{
    self endon( "death" );

    if ( !isdefined( level.playable_areas ) )
        level.playable_areas = getentarray( "player_volume", "script_noteworthy" );

    while ( true )
    {
        foreach ( area in level.playable_areas )
        {
            if ( self istouching( area ) )
            {
                self zombie_complete_emerging_into_playable_area();
                return;
            }
        }

        wait 1;
    }
}

get_desired_origin()
{
    if ( isdefined( self.target ) )
    {
        ent = getent( self.target, "targetname" );

        if ( !isdefined( ent ) )
            ent = getstruct( self.target, "targetname" );

        if ( !isdefined( ent ) )
            ent = getnode( self.target, "targetname" );
/#
        assert( isdefined( ent ), "Cannot find the targeted ent/node/struct, \"" + self.target + "\" at " + self.origin );
#/
        return ent.origin;
    }

    return undefined;
}

zombie_goto_entrance( node, endon_bad_path )
{
/#
    assert( !self.isdog );
#/
    self endon( "death" );
    self endon( "stop_zombie_goto_entrance" );
    level endon( "intermission" );
    self.ai_state = "zombie_goto_entrance";

    if ( isdefined( endon_bad_path ) && endon_bad_path )
        self endon( "bad_path" );

    self zombie_history( "zombie_goto_entrance -> start goto entrance " + node.origin );
    self.got_to_entrance = 0;
    self.goalradius = 128;
    self setgoalpos( node.origin );

    self waittill( "goal" );

    self.got_to_entrance = 1;
    self zombie_history( "zombie_goto_entrance -> reached goto entrance " + node.origin );
    self tear_into_building();

    if ( isdefined( level.pre_aggro_pathfinding_func ) )
        self [[ level.pre_aggro_pathfinding_func ]]();

    barrier_pos = [];
    barrier_pos[0] = "m";
    barrier_pos[1] = "r";
    barrier_pos[2] = "l";
    self.barricade_enter = 1;
    animstate = maps\mp\animscripts\zm_utility::append_missing_legs_suffix( "zm_barricade_enter" );
    substate = "barrier_" + self.zombie_move_speed + "_" + barrier_pos[self.attacking_spot_index];
    self animscripted( self.first_node.zbarrier.origin, self.first_node.zbarrier.angles, animstate, substate );
    maps\mp\animscripts\zm_shared::donotetracks( "barricade_enter_anim" );
    self zombie_setup_attack_properties();
    self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
    self.pathenemyfightdist = 4;
    self zombie_complete_emerging_into_playable_area();
    self.pathenemyfightdist = 64;
    self.barricade_enter = 0;
}

zombie_assure_node()
{
    self endon( "death" );
    self endon( "goal" );
    level endon( "intermission" );
    start_pos = self.origin;

    if ( isdefined( self.entrance_nodes ) )
    {
        for ( i = 0; i < self.entrance_nodes.size; i++ )
        {
            if ( self zombie_bad_path() )
            {
                self zombie_history( "zombie_assure_node -> assigned assured node = " + self.entrance_nodes[i].origin );
/#
                println( "^1Zombie @ " + self.origin + " did not move for 1 second. Going to next closest node @ " + self.entrance_nodes[i].origin );
#/
                level thread draw_line_ent_to_pos( self, self.entrance_nodes[i].origin, "goal" );
                self.first_node = self.entrance_nodes[i];
                self setgoalpos( self.entrance_nodes[i].origin );
                continue;
            }

            return;
        }
    }

    wait 2;
    nodes = get_array_of_closest( self.origin, level.exterior_goals, undefined, 20 );

    if ( isdefined( nodes ) )
    {
        self.entrance_nodes = nodes;

        for ( i = 0; i < self.entrance_nodes.size; i++ )
        {
            if ( self zombie_bad_path() )
            {
                self zombie_history( "zombie_assure_node -> assigned assured node = " + self.entrance_nodes[i].origin );
/#
                println( "^1Zombie @ " + self.origin + " did not move for 1 second. Going to next closest node @ " + self.entrance_nodes[i].origin );
#/
                level thread draw_line_ent_to_pos( self, self.entrance_nodes[i].origin, "goal" );
                self.first_node = self.entrance_nodes[i];
                self setgoalpos( self.entrance_nodes[i].origin );
                continue;
            }

            return;
        }
    }

    self zombie_history( "zombie_assure_node -> failed to find a good entrance point" );
    wait 20;
    self dodamage( self.health + 10, self.origin );
    level.zombies_timeout_spawn++;
}

zombie_bad_path()
{
    self endon( "death" );
    self endon( "goal" );
    self thread zombie_bad_path_notify();
    self thread zombie_bad_path_timeout();
    self.zombie_bad_path = undefined;

    while ( !isdefined( self.zombie_bad_path ) )
        wait 0.05;

    self notify( "stop_zombie_bad_path" );
    return self.zombie_bad_path;
}

zombie_bad_path_notify()
{
    self endon( "death" );
    self endon( "stop_zombie_bad_path" );

    self waittill( "bad_path" );

    self.zombie_bad_path = 1;
}

zombie_bad_path_timeout()
{
    self endon( "death" );
    self endon( "stop_zombie_bad_path" );
    wait 2;
    self.zombie_bad_path = 0;
}

tear_into_building()
{
    self endon( "death" );
    self endon( "teleporting" );
    self zombie_history( "tear_into_building -> start" );

    while ( true )
    {
        if ( isdefined( self.first_node.script_noteworthy ) )
        {
            if ( self.first_node.script_noteworthy == "no_blocker" )
                return;
        }

        if ( !isdefined( self.first_node.target ) )
            return;

        if ( all_chunks_destroyed( self.first_node, self.first_node.barrier_chunks ) )
            self zombie_history( "tear_into_building -> all chunks destroyed" );

        if ( !get_attack_spot( self.first_node ) )
        {
            self zombie_history( "tear_into_building -> Could not find an attack spot" );
            self thread do_a_taunt();
            wait 0.5;
            continue;
        }

        self.goalradius = 2;

        if ( isdefined( level.tear_into_position ) )
            self [[ level.tear_into_position ]]();
        else
        {
            angles = self.first_node.zbarrier.angles;
            self setgoalpos( self.attacking_spot, angles );
        }

        self waittill( "goal" );

        if ( isdefined( level.tear_into_wait ) )
            self [[ level.tear_into_wait ]]();
        else
            self waittill_notify_or_timeout( "orientdone", 1 );

        self zombie_history( "tear_into_building -> Reach position and orientated" );

        if ( all_chunks_destroyed( self.first_node, self.first_node.barrier_chunks ) )
        {
            self zombie_history( "tear_into_building -> all chunks destroyed" );

            for ( i = 0; i < self.first_node.attack_spots_taken.size; i++ )
                self.first_node.attack_spots_taken[i] = 0;

            return;
        }

        while ( true )
        {
            if ( isdefined( self.zombie_board_tear_down_callback ) )
                self [[ self.zombie_board_tear_down_callback ]]();

            chunk = get_closest_non_destroyed_chunk( self.origin, self.first_node, self.first_node.barrier_chunks );

            if ( !isdefined( chunk ) )
            {
                if ( !all_chunks_destroyed( self.first_node, self.first_node.barrier_chunks ) )
                {
                    attack = self should_attack_player_thru_boards();

                    if ( isdefined( attack ) && !attack && self.has_legs )
                        self do_a_taunt();
                    else
                        wait 0.1;

                    continue;
                }

                for ( i = 0; i < self.first_node.attack_spots_taken.size; i++ )
                    self.first_node.attack_spots_taken[i] = 0;

                return;
            }

            self zombie_history( "tear_into_building -> animating" );
            self.first_node.zbarrier setzbarrierpiecestate( chunk, "targetted_by_zombie" );
            self.first_node thread check_zbarrier_piece_for_zombie_inert( chunk, self.first_node.zbarrier, self );
            self.first_node thread check_zbarrier_piece_for_zombie_death( chunk, self.first_node.zbarrier, self );
            self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "teardown", self.animname );

            if ( isdefined( level.zbarrier_override_tear_in ) )
                animstatebase = self [[ level.zbarrier_override_tear_in ]]( chunk );
            else
                animstatebase = self.first_node.zbarrier getzbarrierpieceanimstate( chunk );

            animsubstate = "spot_" + self.attacking_spot_index + "_piece_" + self.first_node.zbarrier getzbarrierpieceanimsubstate( chunk );
            anim_sub_index = self getanimsubstatefromasd( animstatebase + "_in", animsubstate );
            self animscripted( self.first_node.zbarrier.origin, self.first_node.zbarrier.angles, maps\mp\animscripts\zm_utility::append_missing_legs_suffix( animstatebase + "_in" ), anim_sub_index );
            self zombie_tear_notetracks( "tear_anim", chunk, self.first_node );

            while ( 0 < self.first_node.zbarrier.chunk_health[chunk] )
            {
                self animscripted( self.first_node.zbarrier.origin, self.first_node.zbarrier.angles, maps\mp\animscripts\zm_utility::append_missing_legs_suffix( animstatebase + "_loop" ), anim_sub_index );
                self zombie_tear_notetracks( "tear_anim", chunk, self.first_node );
                self.first_node.zbarrier.chunk_health[chunk]--;
            }

            self animscripted( self.first_node.zbarrier.origin, self.first_node.zbarrier.angles, maps\mp\animscripts\zm_utility::append_missing_legs_suffix( animstatebase + "_out" ), anim_sub_index );
            self zombie_tear_notetracks( "tear_anim", chunk, self.first_node );
            self.lastchunk_destroy_time = gettime();
            attack = self should_attack_player_thru_boards();

            if ( isdefined( attack ) && !attack && self.has_legs )
                self do_a_taunt();

            if ( all_chunks_destroyed( self.first_node, self.first_node.barrier_chunks ) )
            {
                for ( i = 0; i < self.first_node.attack_spots_taken.size; i++ )
                    self.first_node.attack_spots_taken[i] = 0;

                level notify( "last_board_torn", self.first_node.zbarrier.origin );
                return;
            }
        }

        self reset_attack_spot();
    }
}

do_a_taunt()
{
    self endon( "death" );

    if ( !self.has_legs )
        return 0;

    if ( !self.first_node.zbarrier zbarriersupportszombietaunts() )
        return;

    self.old_origin = self.origin;

    if ( getdvar( _hash_6896A7C3 ) == "" )
        setdvar( "zombie_taunt_freq", "5" );

    freq = getdvarint( _hash_6896A7C3 );

    if ( freq >= randomint( 100 ) )
    {
        self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "taunt", self.animname );
        tauntstate = "zm_taunt";

        if ( isdefined( self.first_node.zbarrier ) && self.first_node.zbarrier getzbarriertauntanimstate() != "" )
            tauntstate = self.first_node.zbarrier getzbarriertauntanimstate();

        self animscripted( self.origin, self.angles, tauntstate );
        self taunt_notetracks( "taunt_anim" );
    }
}

taunt_notetracks( msg )
{
    self endon( "death" );

    while ( true )
    {
        self waittill( msg, notetrack );

        if ( notetrack == "end" )
        {
            self forceteleport( self.old_origin );
            return;
        }
    }
}

should_attack_player_thru_boards()
{
    if ( !self.has_legs )
        return false;

    if ( isdefined( self.first_node.zbarrier ) )
    {
        if ( !self.first_node.zbarrier zbarriersupportszombiereachthroughattacks() )
            return false;
    }

    if ( getdvar( _hash_4A4203B1 ) == "" )
        setdvar( "zombie_reachin_freq", "50" );

    freq = getdvarint( _hash_4A4203B1 );
    players = get_players();
    attack = 0;
    self.player_targets = [];

    for ( i = 0; i < players.size; i++ )
    {
        if ( isalive( players[i] ) && !isdefined( players[i].revivetrigger ) && distance2d( self.origin, players[i].origin ) <= level.attack_player_thru_boards_range && !( isdefined( players[i].zombie_vars["zombie_powerup_zombie_blood_on"] ) && players[i].zombie_vars["zombie_powerup_zombie_blood_on"] ) )
        {
            self.player_targets[self.player_targets.size] = players[i];
            attack = 1;
        }
    }

    if ( !attack || freq < randomint( 100 ) )
        return false;

    self.old_origin = self.origin;
    attackanimstate = "zm_window_melee";

    if ( isdefined( self.first_node.zbarrier ) && self.first_node.zbarrier getzbarrierreachthroughattackanimstate() != "" )
        attackanimstate = self.first_node.zbarrier getzbarrierreachthroughattackanimstate();

    self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "attack", self.animname );
    self animscripted( self.origin, self.angles, attackanimstate, self.attacking_spot_index - 1 );
    self window_notetracks( "window_melee_anim" );
    return true;
}

window_notetracks( msg )
{
    self endon( "death" );

    while ( true )
    {
        self waittill( msg, notetrack );

        if ( notetrack == "end" )
        {
            self teleport( self.old_origin );
            return;
        }

        if ( notetrack == "fire" )
        {
            if ( self.ignoreall )
                self.ignoreall = 0;

            if ( isdefined( self.first_node ) )
            {
                _melee_dist_sq = 8100;

                if ( isdefined( level.attack_player_thru_boards_range ) )
                    _melee_dist_sq = level.attack_player_thru_boards_range * level.attack_player_thru_boards_range;

                _trigger_dist_sq = 2601;

                for ( i = 0; i < self.player_targets.size; i++ )
                {
                    playerdistsq = distance2dsquared( self.player_targets[i].origin, self.origin );
                    heightdiff = abs( self.player_targets[i].origin[2] - self.origin[2] );

                    if ( playerdistsq < _melee_dist_sq && heightdiff * heightdiff < _melee_dist_sq )
                    {
                        triggerdistsq = distance2dsquared( self.player_targets[i].origin, self.first_node.trigger_location.origin );
                        heightdiff = abs( self.player_targets[i].origin[2] - self.first_node.trigger_location.origin[2] );

                        if ( triggerdistsq < _trigger_dist_sq && heightdiff * heightdiff < _trigger_dist_sq )
                        {
                            self.player_targets[i] dodamage( self.meleedamage, self.origin, self, self, "none", "MOD_MELEE" );
                            break;
                        }
                    }
                }
            }
            else
                self melee();
        }
    }
}

reset_attack_spot()
{
    if ( isdefined( self.attacking_node ) )
    {
        node = self.attacking_node;
        index = self.attacking_spot_index;
        node.attack_spots_taken[index] = 0;
        self.attacking_node = undefined;
        self.attacking_spot_index = undefined;
    }
}

get_attack_spot( node )
{
    index = get_attack_spot_index( node );

    if ( !isdefined( index ) )
        return false;

    self.attacking_node = node;
    self.attacking_spot_index = index;
    node.attack_spots_taken[index] = 1;
    self.attacking_spot = node.attack_spots[index];
    return true;
}

get_attack_spot_index( node )
{
    indexes = [];

    for ( i = 0; i < node.attack_spots.size; i++ )
    {
        if ( !node.attack_spots_taken[i] )
            indexes[indexes.size] = i;
    }

    if ( indexes.size == 0 )
        return undefined;

    return indexes[randomint( indexes.size )];
}

zombie_tear_notetracks( msg, chunk, node )
{
    self endon( "death" );

    while ( true )
    {
        self waittill( msg, notetrack );

        if ( notetrack == "end" )
            return;

        if ( notetrack == "board" || notetrack == "destroy_piece" || notetrack == "bar" )
        {
            if ( isdefined( level.zbarrier_zombie_tear_notetrack_override ) )
                self thread [[ level.zbarrier_zombie_tear_notetrack_override ]]( node, chunk );

            node.zbarrier setzbarrierpiecestate( chunk, "opening" );
        }
    }
}

zombie_boardtear_offset_fx_horizontle( chunk, node )
{
    if ( isdefined( chunk.script_parameters ) && ( chunk.script_parameters == "repair_board" || chunk.script_parameters == "board" ) )
    {
        if ( isdefined( chunk.unbroken ) && chunk.unbroken == 1 )
        {
            if ( isdefined( chunk.material ) && chunk.material == "glass" )
            {
                playfx( level._effect["glass_break"], chunk.origin, node.angles );
                chunk.unbroken = 0;
            }
            else if ( isdefined( chunk.material ) && chunk.material == "metal" )
            {
                playfx( level._effect["fx_zombie_bar_break"], chunk.origin );
                chunk.unbroken = 0;
            }
            else if ( isdefined( chunk.material ) && chunk.material == "rock" )
            {
                if ( isdefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
                    chunk setclientflag( level._zombie_scriptmover_flag_rock_fx );
                else
                    playfx( level._effect["wall_break"], chunk.origin );

                chunk.unbroken = 0;
            }
        }
    }

    if ( isdefined( chunk.script_parameters ) && chunk.script_parameters == "barricade_vents" )
    {
        if ( isdefined( level.use_clientside_board_fx ) && level.use_clientside_board_fx )
            chunk setclientflag( level._zombie_scriptmover_flag_board_horizontal_fx );
        else
            playfx( level._effect["fx_zombie_bar_break"], chunk.origin );
    }
    else if ( isdefined( chunk.material ) && chunk.material == "rock" )
    {
        if ( isdefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
            chunk setclientflag( level._zombie_scriptmover_flag_rock_fx );
    }
    else if ( isdefined( level.use_clientside_board_fx ) )
        chunk setclientflag( level._zombie_scriptmover_flag_board_horizontal_fx );
    else
    {
        playfx( level._effect["wood_chunk_destory"], chunk.origin + vectorscale( ( 0, 0, 1 ), 30.0 ) );
        wait( randomfloatrange( 0.2, 0.4 ) );
        playfx( level._effect["wood_chunk_destory"], chunk.origin + vectorscale( ( 0, 0, -1 ), 30.0 ) );
    }
}

zombie_boardtear_offset_fx_verticle( chunk, node )
{
    if ( isdefined( chunk.script_parameters ) && ( chunk.script_parameters == "repair_board" || chunk.script_parameters == "board" ) )
    {
        if ( isdefined( chunk.unbroken ) && chunk.unbroken == 1 )
        {
            if ( isdefined( chunk.material ) && chunk.material == "glass" )
            {
                playfx( level._effect["glass_break"], chunk.origin, node.angles );
                chunk.unbroken = 0;
            }
            else if ( isdefined( chunk.material ) && chunk.material == "metal" )
            {
                playfx( level._effect["fx_zombie_bar_break"], chunk.origin );
                chunk.unbroken = 0;
            }
            else if ( isdefined( chunk.material ) && chunk.material == "rock" )
            {
                if ( isdefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
                    chunk setclientflag( level._zombie_scriptmover_flag_rock_fx );
                else
                    playfx( level._effect["wall_break"], chunk.origin );

                chunk.unbroken = 0;
            }
        }
    }

    if ( isdefined( chunk.script_parameters ) && chunk.script_parameters == "barricade_vents" )
    {
        if ( isdefined( level.use_clientside_board_fx ) )
            chunk setclientflag( level._zombie_scriptmover_flag_board_vertical_fx );
        else
            playfx( level._effect["fx_zombie_bar_break"], chunk.origin );
    }
    else if ( isdefined( chunk.material ) && chunk.material == "rock" )
    {
        if ( isdefined( level.use_clientside_rock_tearin_fx ) && level.use_clientside_rock_tearin_fx )
            chunk setclientflag( level._zombie_scriptmover_flag_rock_fx );
    }
    else if ( isdefined( level.use_clientside_board_fx ) )
        chunk setclientflag( level._zombie_scriptmover_flag_board_vertical_fx );
    else
    {
        playfx( level._effect["wood_chunk_destory"], chunk.origin + vectorscale( ( 1, 0, 0 ), 30.0 ) );
        wait( randomfloatrange( 0.2, 0.4 ) );
        playfx( level._effect["wood_chunk_destory"], chunk.origin + vectorscale( ( -1, 0, 0 ), 30.0 ) );
    }
}

zombie_bartear_offset_fx_verticle( chunk )
{
    if ( isdefined( chunk.script_parameters ) && chunk.script_parameters == "bar" || chunk.script_noteworthy == "board" )
    {
        possible_tag_array_1 = [];
        possible_tag_array_1[0] = "Tag_fx_top";
        possible_tag_array_1[1] = "";
        possible_tag_array_1[2] = "Tag_fx_top";
        possible_tag_array_1[3] = "";
        possible_tag_array_2 = [];
        possible_tag_array_2[0] = "";
        possible_tag_array_2[1] = "Tag_fx_bottom";
        possible_tag_array_2[2] = "";
        possible_tag_array_2[3] = "Tag_fx_bottom";
        possible_tag_array_2 = array_randomize( possible_tag_array_2 );
        random_fx = [];
        random_fx[0] = level._effect["fx_zombie_bar_break"];
        random_fx[1] = level._effect["fx_zombie_bar_break_lite"];
        random_fx[2] = level._effect["fx_zombie_bar_break"];
        random_fx[3] = level._effect["fx_zombie_bar_break_lite"];
        random_fx = array_randomize( random_fx );

        switch ( randomint( 9 ) )
        {
            case "0":
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_top" );
                wait( randomfloatrange( 0.0, 0.3 ) );
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_bottom" );
                break;
            case "1":
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_top" );
                wait( randomfloatrange( 0.0, 0.3 ) );
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_bottom" );
                break;
            case "2":
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_top" );
                wait( randomfloatrange( 0.0, 0.3 ) );
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_bottom" );
                break;
            case "3":
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_top" );
                wait( randomfloatrange( 0.0, 0.3 ) );
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_bottom" );
                break;
            case "4":
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_top" );
                wait( randomfloatrange( 0.0, 0.3 ) );
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_bottom" );
                break;
            case "5":
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_top" );
                break;
            case "6":
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_bottom" );
                break;
            case "7":
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_top" );
                break;
            case "8":
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_bottom" );
                break;
        }
    }
}

zombie_bartear_offset_fx_horizontle( chunk )
{
    if ( isdefined( chunk.script_parameters ) && chunk.script_parameters == "bar" || chunk.script_noteworthy == "board" )
    {
        switch ( randomint( 10 ) )
        {
            case "0":
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_left" );
                wait( randomfloatrange( 0.0, 0.3 ) );
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_right" );
                break;
            case "1":
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_left" );
                wait( randomfloatrange( 0.0, 0.3 ) );
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_right" );
                break;
            case "2":
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_left" );
                wait( randomfloatrange( 0.0, 0.3 ) );
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_right" );
                break;
            case "3":
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_left" );
                wait( randomfloatrange( 0.0, 0.3 ) );
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_right" );
                break;
            case "4":
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_left" );
                wait( randomfloatrange( 0.0, 0.3 ) );
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_right" );
                break;
            case "5":
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_left" );
                break;
            case "6":
                playfxontag( level._effect["fx_zombie_bar_break_lite"], chunk, "Tag_fx_right" );
                break;
            case "7":
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_right" );
                break;
            case "8":
                playfxontag( level._effect["fx_zombie_bar_break"], chunk, "Tag_fx_right" );
                break;
        }
    }
}

check_zbarrier_piece_for_zombie_inert( chunk_index, zbarrier, zombie )
{
    zombie endon( "completed_emerging_into_playable_area" );

    zombie waittill( "stop_zombie_goto_entrance" );

    if ( zbarrier getzbarrierpiecestate( chunk_index ) == "targetted_by_zombie" )
        zbarrier setzbarrierpiecestate( chunk_index, "closed" );
}

check_zbarrier_piece_for_zombie_death( chunk_index, zbarrier, zombie )
{
    while ( true )
    {
        if ( zbarrier getzbarrierpiecestate( chunk_index ) != "targetted_by_zombie" )
            return;

        if ( !isdefined( zombie ) || !isalive( zombie ) )
        {
            zbarrier setzbarrierpiecestate( chunk_index, "closed" );
            return;
        }

        wait 0.05;
    }
}

check_for_zombie_death( zombie )
{
    self endon( "destroyed" );
    wait 2.5;
    self maps\mp\zombies\_zm_blockers::update_states( "repaired" );
}

zombie_hat_gib( attacker, means_of_death )
{
    self endon( "death" );

    if ( !is_mature() )
        return 0;

    if ( isdefined( self.hat_gibbed ) && self.hat_gibbed )
        return;

    if ( !isdefined( self.gibspawn5 ) || !isdefined( self.gibspawntag5 ) )
        return;

    self.hat_gibbed = 1;

    if ( isdefined( self.hatmodel ) )
        self detach( self.hatmodel, "" );

    temp_array = [];
    temp_array[0] = level._zombie_gib_piece_index_hat;
    self gib( "normal", temp_array );

    if ( isdefined( level.track_gibs ) )
        level [[ level.track_gibs ]]( self, temp_array );
}

zombie_head_gib( attacker, means_of_death )
{
    self endon( "death" );

    if ( !is_mature() )
        return 0;

    if ( isdefined( self.head_gibbed ) && self.head_gibbed )
        return;

    self.head_gibbed = 1;
    self zombie_eye_glow_stop();
    size = self getattachsize();

    for ( i = 0; i < size; i++ )
    {
        model = self getattachmodelname( i );

        if ( issubstr( model, "head" ) )
        {
            if ( isdefined( self.hatmodel ) )
                self detach( self.hatmodel, "" );

            self detach( model, "" );

            if ( isdefined( self.torsodmg5 ) )
                self attach( self.torsodmg5, "", 1 );

            break;
        }
    }

    temp_array = [];
    temp_array[0] = level._zombie_gib_piece_index_head;

    if ( !( isdefined( self.hat_gibbed ) && self.hat_gibbed ) && isdefined( self.gibspawn5 ) && isdefined( self.gibspawntag5 ) )
        temp_array[1] = level._zombie_gib_piece_index_hat;

    self.hat_gibbed = 1;
    self gib( "normal", temp_array );

    if ( isdefined( level.track_gibs ) )
        level [[ level.track_gibs ]]( self, temp_array );

    self thread damage_over_time( ceil( self.health * 0.2 ), 1, attacker, means_of_death );
}

damage_over_time( dmg, delay, attacker, means_of_death )
{
    self endon( "death" );
    self endon( "exploding" );

    if ( !isalive( self ) )
        return;

    if ( !isplayer( attacker ) )
        attacker = self;

    if ( !isdefined( means_of_death ) )
        means_of_death = "MOD_UNKNOWN";

    while ( true )
    {
        if ( isdefined( delay ) )
            wait( delay );

        if ( isdefined( self ) )
            self dodamage( dmg, self gettagorigin( "j_neck" ), attacker, self, self.damagelocation, means_of_death, 0, self.damageweapon );
    }
}

head_should_gib( attacker, type, point )
{
    if ( !is_mature() )
        return false;

    if ( self.head_gibbed )
        return false;

    if ( !isdefined( attacker ) || !isplayer( attacker ) )
        return false;

    weapon = attacker getcurrentweapon();

    if ( type != "MOD_RIFLE_BULLET" && type != "MOD_PISTOL_BULLET" )
    {
        if ( type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" )
        {
            if ( distance( point, self gettagorigin( "j_head" ) ) > 55 )
                return false;
            else
                return true;
        }
        else if ( type == "MOD_PROJECTILE" )
        {
            if ( distance( point, self gettagorigin( "j_head" ) ) > 10 )
                return false;
            else
                return true;
        }
        else if ( weaponclass( weapon ) != "spread" )
            return false;
    }

    if ( !self maps\mp\animscripts\zm_utility::damagelocationisany( "head", "helmet", "neck" ) )
        return false;

    if ( weapon == "none" || weapon == level.start_weapon || weaponisgasweapon( self.weapon ) )
        return false;

    low_health_percent = self.health / self.maxhealth * 100;

    if ( low_health_percent > 10 )
    {
        self zombie_hat_gib( attacker, type );
        return false;
    }

    return true;
}

headshot_blood_fx()
{
    if ( !isdefined( self ) )
        return;

    if ( !is_mature() )
        return;

    fxtag = "j_neck";
    fxorigin = self gettagorigin( fxtag );
    upvec = anglestoup( self gettagangles( fxtag ) );
    forwardvec = anglestoforward( self gettagangles( fxtag ) );
    playfx( level._effect["headshot"], fxorigin, forwardvec, upvec );
    playfx( level._effect["headshot_nochunks"], fxorigin, forwardvec, upvec );
    wait 0.3;

    if ( isdefined( self ) )
        playfxontag( level._effect["bloodspurt"], self, fxtag );
}

zombie_gib_on_damage()
{
    while ( true )
    {
        self waittill( "damage", amount, attacker, direction_vec, point, type, tagname, modelname, partname, weaponname );

        if ( !isdefined( self ) )
            return;

        if ( !self zombie_should_gib( amount, attacker, type ) )
            continue;

        if ( self head_should_gib( attacker, type, point ) && type != "MOD_BURNED" )
        {
            self zombie_head_gib( attacker, type );
            continue;
        }

        if ( !self.gibbed )
        {
            if ( self maps\mp\animscripts\zm_utility::damagelocationisany( "head", "helmet", "neck" ) )
                continue;

            refs = [];

            switch ( self.damagelocation )
            {
                case "torso_upper":
                case "torso_lower":
                    refs[refs.size] = "guts";
                    refs[refs.size] = "right_arm";
                    break;
                case "right_hand":
                case "right_arm_upper":
                case "right_arm_lower":
                    refs[refs.size] = "right_arm";
                    break;
                case "left_hand":
                case "left_arm_upper":
                case "left_arm_lower":
                    refs[refs.size] = "left_arm";
                    break;
                case "right_leg_upper":
                case "right_leg_lower":
                case "right_foot":
                    if ( self.health <= 0 )
                    {
                        refs[refs.size] = "right_leg";
                        refs[refs.size] = "right_leg";
                        refs[refs.size] = "right_leg";
                        refs[refs.size] = "no_legs";
                    }

                    break;
                case "left_leg_upper":
                case "left_leg_lower":
                case "left_foot":
                    if ( self.health <= 0 )
                    {
                        refs[refs.size] = "left_leg";
                        refs[refs.size] = "left_leg";
                        refs[refs.size] = "left_leg";
                        refs[refs.size] = "no_legs";
                    }

                    break;
                default:
                    if ( self.damagelocation == "none" )
                    {
                        if ( type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" || type == "MOD_PROJECTILE" || type == "MOD_PROJECTILE_SPLASH" )
                        {
                            refs = self derive_damage_refs( point );
                            break;
                        }
                    }
                    else
                    {
                        refs[refs.size] = "guts";
                        refs[refs.size] = "right_arm";
                        refs[refs.size] = "left_arm";
                        refs[refs.size] = "right_leg";
                        refs[refs.size] = "left_leg";
                        refs[refs.size] = "no_legs";
                        break;
                    }
            }

            if ( isdefined( level.custom_derive_damage_refs ) )
                refs = self [[ level.custom_derive_damage_refs ]]( refs, point, weaponname );

            if ( refs.size )
            {
                self.a.gib_ref = maps\mp\animscripts\zm_death::get_random( refs );

                if ( ( self.a.gib_ref == "no_legs" || self.a.gib_ref == "right_leg" || self.a.gib_ref == "left_leg" ) && self.health > 0 )
                {
                    self.has_legs = 0;
                    self allowedstances( "crouch" );
                    self setphysparams( 15, 0, 24 );
                    self allowpitchangle( 1 );
                    self setpitchorient();
                    health = self.health;
                    health *= 0.1;
                    self thread maps\mp\animscripts\zm_run::needsdelayedupdate();

                    if ( isdefined( self.crawl_anim_override ) )
                        self [[ self.crawl_anim_override ]]();
                }
            }

            if ( self.health > 0 )
            {
                self thread maps\mp\animscripts\zm_death::do_gib();

                if ( isdefined( level.gib_on_damage ) )
                    self thread [[ level.gib_on_damage ]]();
            }
        }
    }
}

zombie_should_gib( amount, attacker, type )
{
    if ( !is_mature() )
        return false;

    if ( !isdefined( type ) )
        return false;

    if ( isdefined( self.is_on_fire ) && self.is_on_fire )
        return false;

    if ( isdefined( self.no_gib ) && self.no_gib == 1 )
        return false;

    switch ( type )
    {
        case "MOD_UNKNOWN":
        case "MOD_TRIGGER_HURT":
        case "MOD_TELEFRAG":
        case "MOD_SUICIDE":
        case "MOD_FALLING":
        case "MOD_CRUSH":
        case "MOD_BURNED":
            return false;
        case "MOD_MELEE":
            return false;
    }

    if ( type == "MOD_PISTOL_BULLET" || type == "MOD_RIFLE_BULLET" )
    {
        if ( !isdefined( attacker ) || !isplayer( attacker ) )
            return false;

        weapon = attacker getcurrentweapon();

        if ( weapon == "none" || weapon == level.start_weapon )
            return false;

        if ( weaponisgasweapon( self.weapon ) )
            return false;
    }
    else if ( type == "MOD_PROJECTILE" )
    {
        if ( isdefined( attacker ) && isplayer( attacker ) )
        {
            weapon = attacker getcurrentweapon();

            if ( weapon == "slipgun_zm" || weapon == "slipgun_upgraded_zm" )
                return false;
        }
    }

    prev_health = amount + self.health;

    if ( prev_health <= 0 )
        prev_health = 1;

    damage_percent = amount / prev_health * 100;

    if ( damage_percent < 10 )
        return false;

    return true;
}

derive_damage_refs( point )
{
    if ( !isdefined( level.gib_tags ) )
        init_gib_tags();

    closesttag = undefined;

    for ( i = 0; i < level.gib_tags.size; i++ )
    {
        if ( !isdefined( closesttag ) )
        {
            closesttag = level.gib_tags[i];
            continue;
        }

        if ( distancesquared( point, self gettagorigin( level.gib_tags[i] ) ) < distancesquared( point, self gettagorigin( closesttag ) ) )
            closesttag = level.gib_tags[i];
    }

    refs = [];

    if ( closesttag == "J_SpineLower" || closesttag == "J_SpineUpper" || closesttag == "J_Spine4" )
    {
        refs[refs.size] = "guts";
        refs[refs.size] = "right_arm";
    }
    else if ( closesttag == "J_Shoulder_LE" || closesttag == "J_Elbow_LE" || closesttag == "J_Wrist_LE" )
        refs[refs.size] = "left_arm";
    else if ( closesttag == "J_Shoulder_RI" || closesttag == "J_Elbow_RI" || closesttag == "J_Wrist_RI" )
        refs[refs.size] = "right_arm";
    else if ( closesttag == "J_Hip_LE" || closesttag == "J_Knee_LE" || closesttag == "J_Ankle_LE" )
    {
        refs[refs.size] = "left_leg";
        refs[refs.size] = "no_legs";
    }
    else if ( closesttag == "J_Hip_RI" || closesttag == "J_Knee_RI" || closesttag == "J_Ankle_RI" )
    {
        refs[refs.size] = "right_leg";
        refs[refs.size] = "no_legs";
    }
/#
    assert( array_validate( refs ), "get_closest_damage_refs(): couldn't derive refs from closestTag " + closesttag );
#/
    return refs;
}

init_gib_tags()
{
    tags = [];
    tags[tags.size] = "J_SpineLower";
    tags[tags.size] = "J_SpineUpper";
    tags[tags.size] = "J_Spine4";
    tags[tags.size] = "J_Shoulder_LE";
    tags[tags.size] = "J_Elbow_LE";
    tags[tags.size] = "J_Wrist_LE";
    tags[tags.size] = "J_Shoulder_RI";
    tags[tags.size] = "J_Elbow_RI";
    tags[tags.size] = "J_Wrist_RI";
    tags[tags.size] = "J_Hip_LE";
    tags[tags.size] = "J_Knee_LE";
    tags[tags.size] = "J_Ankle_LE";
    tags[tags.size] = "J_Hip_RI";
    tags[tags.size] = "J_Knee_RI";
    tags[tags.size] = "J_Ankle_RI";
    level.gib_tags = tags;
}

zombie_can_drop_powerups( zombie )
{
    if ( is_tactical_grenade( zombie.damageweapon ) || !flag( "zombie_drop_powerups" ) )
        return false;

    if ( isdefined( zombie.no_powerups ) && zombie.no_powerups )
        return false;

    return true;
}

zombie_delay_powerup_drop( origin )
{
    wait_network_frame();
    level thread maps\mp\zombies\_zm_powerups::powerup_drop( origin );
}

zombie_death_points( origin, mod, hit_location, attacker, zombie, team )
{
    if ( !isdefined( attacker ) || !isplayer( attacker ) )
        return;

    if ( zombie_can_drop_powerups( zombie ) )
    {
        if ( isdefined( zombie.in_the_ground ) && zombie.in_the_ground == 1 )
        {
            trace = bullettrace( zombie.origin + vectorscale( ( 0, 0, 1 ), 100.0 ), zombie.origin + vectorscale( ( 0, 0, -1 ), 100.0 ), 0, undefined );
            origin = trace["position"];
            level thread zombie_delay_powerup_drop( origin );
        }
        else
        {
            trace = groundtrace( zombie.origin + vectorscale( ( 0, 0, 1 ), 5.0 ), zombie.origin + vectorscale( ( 0, 0, -1 ), 300.0 ), 0, undefined );
            origin = trace["position"];
            level thread zombie_delay_powerup_drop( origin );
        }
    }

    level thread maps\mp\zombies\_zm_audio::player_zombie_kill_vox( hit_location, attacker, mod, zombie );
    event = "death";

    if ( isdefined( zombie.damageweapon ) && issubstr( zombie.damageweapon, "knife_ballistic_" ) && ( mod == "MOD_MELEE" || mod == "MOD_IMPACT" ) )
        event = "ballistic_knife_death";

    if ( isdefined( zombie.deathpoints_already_given ) && zombie.deathpoints_already_given )
        return;

    zombie.deathpoints_already_given = 1;

    if ( isdefined( zombie.damageweapon ) && is_equipment( zombie.damageweapon ) )
        return;

    attacker maps\mp\zombies\_zm_score::player_add_points( event, mod, hit_location, undefined, team, attacker.currentweapon );
}

get_number_variants( aliasprefix )
{
    for ( i = 0; i < 100; i++ )
    {
        if ( !soundexists( aliasprefix + "_" + i ) )
            return i;
    }
}

dragons_breath_flame_death_fx()
{
    if ( self.isdog )
        return;

    if ( !isdefined( level._effect ) || !isdefined( level._effect["character_fire_death_sm"] ) )
    {
/#
        println( "^3ANIMSCRIPT WARNING: You are missing level._effect[\"character_fire_death_sm\"], please set it in your levelname_fx.gsc. Use \"env/fire/fx_fire_zombie_md\"" );
#/
        return;
    }

    playfxontag( level._effect["character_fire_death_sm"], self, "J_SpineLower" );
    tagarray = [];

    if ( !isdefined( self.a.gib_ref ) || self.a.gib_ref != "left_arm" )
    {
        tagarray[tagarray.size] = "J_Elbow_LE";
        tagarray[tagarray.size] = "J_Wrist_LE";
    }

    if ( !isdefined( self.a.gib_ref ) || self.a.gib_ref != "right_arm" )
    {
        tagarray[tagarray.size] = "J_Elbow_RI";
        tagarray[tagarray.size] = "J_Wrist_RI";
    }

    if ( !isdefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" && self.a.gib_ref != "left_leg" )
    {
        tagarray[tagarray.size] = "J_Knee_LE";
        tagarray[tagarray.size] = "J_Ankle_LE";
    }

    if ( !isdefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" && self.a.gib_ref != "right_leg" )
    {
        tagarray[tagarray.size] = "J_Knee_RI";
        tagarray[tagarray.size] = "J_Ankle_RI";
    }

    tagarray = array_randomize( tagarray );
    playfxontag( level._effect["character_fire_death_sm"], self, tagarray[0] );
}

zombie_ragdoll_then_explode( launchvector, attacker )
{
    if ( !isdefined( self ) )
        return;

    self zombie_eye_glow_stop();
    self setclientfield( "zombie_ragdoll_explode", 1 );
    self notify( "exploding" );
    self notify( "end_melee" );
    self notify( "death", attacker );
    self.dont_die_on_me = 1;
    self.exploding = 1;
    self.a.nodeath = 1;
    self.dont_throw_gib = 1;
    self startragdoll();
    self setplayercollision( 0 );
    self reset_attack_spot();

    if ( isdefined( launchvector ) )
        self launchragdoll( launchvector );

    wait 2.1;

    if ( isdefined( self ) )
    {
        self ghost();
        self delay_thread( 0.25, ::self_delete );
    }
}

zombie_death_animscript()
{
    team = undefined;
    recalc_zombie_array();

    if ( isdefined( self._race_team ) )
        team = self._race_team;

    self reset_attack_spot();

    if ( self check_zombie_death_animscript_callbacks() )
        return false;

    if ( isdefined( level.zombie_death_animscript_override ) )
        self [[ level.zombie_death_animscript_override ]]();

    if ( self.has_legs && isdefined( self.a.gib_ref ) && self.a.gib_ref == "no_legs" )
        self.deathanim = "zm_death";

    self.grenadeammo = 0;

    if ( isdefined( self.nuked ) )
    {
        if ( zombie_can_drop_powerups( self ) )
        {
            if ( isdefined( self.in_the_ground ) && self.in_the_ground == 1 )
            {
                trace = bullettrace( self.origin + vectorscale( ( 0, 0, 1 ), 100.0 ), self.origin + vectorscale( ( 0, 0, -1 ), 100.0 ), 0, undefined );
                origin = trace["position"];
                level thread zombie_delay_powerup_drop( origin );
            }
            else
            {
                trace = groundtrace( self.origin + vectorscale( ( 0, 0, 1 ), 5.0 ), self.origin + vectorscale( ( 0, 0, -1 ), 300.0 ), 0, undefined );
                origin = trace["position"];
                level thread zombie_delay_powerup_drop( self.origin );
            }
        }
    }
    else
        level zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker, self, team );

    if ( isdefined( self.attacker ) && isai( self.attacker ) )
        self.attacker notify( "killed", self );

    if ( "rottweil72_upgraded_zm" == self.damageweapon && "MOD_RIFLE_BULLET" == self.damagemod )
        self thread dragons_breath_flame_death_fx();

    if ( "tazer_knuckles_zm" == self.damageweapon && "MOD_MELEE" == self.damagemod )
    {
        self.is_on_fire = 0;
        self notify( "stop_flame_damage" );
    }

    if ( self.damagemod == "MOD_BURNED" )
        self thread maps\mp\animscripts\zm_death::flame_death_fx();

    if ( self.damagemod == "MOD_GRENADE" || self.damagemod == "MOD_GRENADE_SPLASH" )
        level notify( "zombie_grenade_death", self.origin );

    return false;
}

check_zombie_death_animscript_callbacks()
{
    if ( !isdefined( level.zombie_death_animscript_callbacks ) )
        return false;

    for ( i = 0; i < level.zombie_death_animscript_callbacks.size; i++ )
    {
        if ( self [[ level.zombie_death_animscript_callbacks[i] ]]() )
            return true;
    }

    return false;
}

register_zombie_death_animscript_callback( func )
{
    if ( !isdefined( level.zombie_death_animscript_callbacks ) )
        level.zombie_death_animscript_callbacks = [];

    level.zombie_death_animscript_callbacks[level.zombie_death_animscript_callbacks.size] = func;
}

damage_on_fire( player )
{
    self endon( "death" );
    self endon( "stop_flame_damage" );
    wait 2;

    while ( isdefined( self.is_on_fire ) && self.is_on_fire )
    {
        if ( level.round_number < 6 )
            dmg = level.zombie_health * randomfloatrange( 0.2, 0.3 );
        else if ( level.round_number < 9 )
            dmg = level.zombie_health * randomfloatrange( 0.15, 0.25 );
        else if ( level.round_number < 11 )
            dmg = level.zombie_health * randomfloatrange( 0.1, 0.2 );
        else
            dmg = level.zombie_health * randomfloatrange( 0.1, 0.15 );

        if ( isdefined( player ) && isalive( player ) )
            self dodamage( dmg, self.origin, player );
        else
            self dodamage( dmg, self.origin, level );

        wait( randomfloatrange( 1.0, 3.0 ) );
    }
}

player_using_hi_score_weapon( player )
{
    weapon = player getcurrentweapon();

    if ( weapon == "none" || weaponissemiauto( weapon ) )
        return true;

    return false;
}

zombie_damage( mod, hit_location, hit_origin, player, amount, team )
{
    if ( is_magic_bullet_shield_enabled( self ) )
        return;

    player.use_weapon_type = mod;

    if ( isdefined( self.marked_for_death ) )
        return;

    if ( !isdefined( player ) )
        return;

    if ( isdefined( hit_origin ) )
        self.damagehit_origin = hit_origin;
    else
        self.damagehit_origin = player getweaponmuzzlepoint();

    if ( self check_zombie_damage_callbacks( mod, hit_location, hit_origin, player, amount ) )
        return;
    else if ( self zombie_flame_damage( mod, player ) )
    {
        if ( self zombie_give_flame_damage_points() )
            player maps\mp\zombies\_zm_score::player_add_points( "damage", mod, hit_location, self.isdog, team );
    }
    else
    {
        if ( player_using_hi_score_weapon( player ) )
            damage_type = "damage";
        else
            damage_type = "damage_light";

        if ( !( isdefined( self.no_damage_points ) && self.no_damage_points ) )
            player maps\mp\zombies\_zm_score::player_add_points( damage_type, mod, hit_location, self.isdog, team, self.damageweapon );
    }

    if ( isdefined( self.zombie_damage_fx_func ) )
        self [[ self.zombie_damage_fx_func ]]( mod, hit_location, hit_origin, player );

    modname = remove_mod_from_methodofdeath( mod );

    if ( is_placeable_mine( self.damageweapon ) )
    {
        if ( isdefined( self.zombie_damage_claymore_func ) )
            self [[ self.zombie_damage_claymore_func ]]( mod, hit_location, hit_origin, player );
        else if ( isdefined( player ) && isalive( player ) )
            self dodamage( level.round_number * randomintrange( 100, 200 ), self.origin, player, self, hit_location, mod );
        else
            self dodamage( level.round_number * randomintrange( 100, 200 ), self.origin, undefined, self, hit_location, mod );
    }
    else if ( mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH" )
    {
        if ( isdefined( player ) && isalive( player ) )
        {
            player.grenade_multiattack_count++;
            player.grenade_multiattack_ent = self;
            self dodamage( level.round_number + randomintrange( 100, 200 ), self.origin, player, self, hit_location, modname );
        }
        else
            self dodamage( level.round_number + randomintrange( 100, 200 ), self.origin, undefined, self, hit_location, modname );
    }
    else if ( mod == "MOD_PROJECTILE" || mod == "MOD_EXPLOSIVE" || mod == "MOD_PROJECTILE_SPLASH" )
    {
        if ( isdefined( player ) && isalive( player ) )
            self dodamage( level.round_number * randomintrange( 0, 100 ), self.origin, player, self, hit_location, modname );
        else
            self dodamage( level.round_number * randomintrange( 0, 100 ), self.origin, undefined, self, hit_location, modname );
    }

    if ( isdefined( self.a.gib_ref ) && self.a.gib_ref == "no_legs" && isalive( self ) )
    {
        if ( isdefined( player ) )
        {
            rand = randomintrange( 0, 100 );

            if ( rand < 10 )
                player create_and_play_dialog( "general", "crawl_spawn" );
        }
    }
    else if ( isdefined( self.a.gib_ref ) && ( self.a.gib_ref == "right_arm" || self.a.gib_ref == "left_arm" ) )
    {
        if ( self.has_legs && isalive( self ) )
        {
            if ( isdefined( player ) )
            {
                rand = randomintrange( 0, 100 );

                if ( rand < 7 )
                    player create_and_play_dialog( "general", "shoot_arm" );
            }
        }
    }

    self thread maps\mp\zombies\_zm_powerups::check_for_instakill( player, mod, hit_location );
}

zombie_damage_ads( mod, hit_location, hit_origin, player, amount, team )
{
    if ( is_magic_bullet_shield_enabled( self ) )
        return;

    player.use_weapon_type = mod;

    if ( !isdefined( player ) )
        return;

    if ( isdefined( hit_origin ) )
        self.damagehit_origin = hit_origin;
    else
        self.damagehit_origin = player getweaponmuzzlepoint();

    if ( self check_zombie_damage_callbacks( mod, hit_location, hit_origin, player, amount ) )
        return;
    else if ( self zombie_flame_damage( mod, player ) )
    {
        if ( self zombie_give_flame_damage_points() )
            player maps\mp\zombies\_zm_score::player_add_points( "damage_ads", mod, hit_location, undefined, team );
    }
    else
    {
        if ( player_using_hi_score_weapon( player ) )
            damage_type = "damage";
        else
            damage_type = "damage_light";

        if ( !( isdefined( self.no_damage_points ) && self.no_damage_points ) )
            player maps\mp\zombies\_zm_score::player_add_points( damage_type, mod, hit_location, undefined, team, self.damageweapon );
    }

    self thread maps\mp\zombies\_zm_powerups::check_for_instakill( player, mod, hit_location );
}

check_zombie_damage_callbacks( mod, hit_location, hit_origin, player, amount )
{
    if ( !isdefined( level.zombie_damage_callbacks ) )
        return false;

    for ( i = 0; i < level.zombie_damage_callbacks.size; i++ )
    {
        if ( self [[ level.zombie_damage_callbacks[i] ]]( mod, hit_location, hit_origin, player, amount ) )
            return true;
    }

    return false;
}

register_zombie_damage_callback( func )
{
    if ( !isdefined( level.zombie_damage_callbacks ) )
        level.zombie_damage_callbacks = [];

    level.zombie_damage_callbacks[level.zombie_damage_callbacks.size] = func;
}

zombie_give_flame_damage_points()
{
    if ( gettime() > self.flame_damage_time )
    {
        self.flame_damage_time = gettime() + level.zombie_vars["zombie_flame_dmg_point_delay"];
        return true;
    }

    return false;
}

zombie_flame_damage( mod, player )
{
    if ( mod == "MOD_BURNED" )
    {
        if ( !isdefined( self.is_on_fire ) || isdefined( self.is_on_fire ) && !self.is_on_fire )
            self thread damage_on_fire( player );

        do_flame_death = 1;
        dist = 10000;
        ai = getaiarray( level.zombie_team );

        for ( i = 0; i < ai.size; i++ )
        {
            if ( isdefined( ai[i].is_on_fire ) && ai[i].is_on_fire )
            {
                if ( distancesquared( ai[i].origin, self.origin ) < dist )
                {
                    do_flame_death = 0;
                    break;
                }
            }
        }

        if ( do_flame_death )
            self thread maps\mp\animscripts\zm_death::flame_death_fx();

        return true;
    }

    return false;
}

is_weapon_shotgun( sweapon )
{
    if ( isdefined( sweapon ) && weaponclass( sweapon ) == "spread" )
        return true;

    return false;
}

zombie_death_event( zombie )
{
    zombie.marked_for_recycle = 0;
    force_explode = 0;
    force_head_gib = 0;

    zombie waittill( "death", attacker );

    time_of_death = gettime();

    if ( isdefined( zombie ) )
        zombie stopsounds();

    if ( isdefined( zombie ) && isdefined( zombie.marked_for_insta_upgraded_death ) )
        force_head_gib = 1;

    if ( !isdefined( zombie.damagehit_origin ) && isdefined( attacker ) )
        zombie.damagehit_origin = attacker getweaponmuzzlepoint();

    if ( isdefined( attacker ) && isplayer( attacker ) )
    {
        if ( isdefined( level.pers_upgrade_carpenter ) && level.pers_upgrade_carpenter )
            maps\mp\zombies\_zm_pers_upgrades::pers_zombie_death_location_check( attacker, zombie.origin );

        if ( isdefined( level.pers_upgrade_sniper ) && level.pers_upgrade_sniper )
            attacker pers_upgrade_sniper_kill_check( zombie, attacker );

        if ( isdefined( zombie ) && isdefined( zombie.damagelocation ) )
        {
            if ( is_headshot( zombie.damageweapon, zombie.damagelocation, zombie.damagemod ) )
            {
                attacker.headshots++;
                attacker maps\mp\zombies\_zm_stats::increment_client_stat( "headshots" );
                attacker addweaponstat( zombie.damageweapon, "headshots", 1 );
                attacker maps\mp\zombies\_zm_stats::increment_player_stat( "headshots" );

                if ( is_classic() )
                    attacker maps\mp\zombies\_zm_pers_upgrades_functions::pers_check_for_pers_headshot( time_of_death, zombie );
            }
            else
                attacker notify( "zombie_death_no_headshot" );
        }

        if ( isdefined( zombie ) && isdefined( zombie.damagemod ) && zombie.damagemod == "MOD_MELEE" )
        {
            attacker maps\mp\zombies\_zm_stats::increment_client_stat( "melee_kills" );
            attacker maps\mp\zombies\_zm_stats::increment_player_stat( "melee_kills" );
            attacker notify( "melee_kill" );

            if ( attacker maps\mp\zombies\_zm_pers_upgrades::is_insta_kill_upgraded_and_active() )
                force_explode = 1;
        }

        attacker maps\mp\zombies\_zm::add_rampage_bookmark_kill_time();
        attacker.kills++;
        attacker maps\mp\zombies\_zm_stats::increment_client_stat( "kills" );
        attacker maps\mp\zombies\_zm_stats::increment_player_stat( "kills" );

        if ( isdefined( level.pers_upgrade_pistol_points ) && level.pers_upgrade_pistol_points )
            attacker maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_pistol_points_kill();

        dmgweapon = zombie.damageweapon;

        if ( is_alt_weapon( dmgweapon ) )
            dmgweapon = weaponaltweaponname( dmgweapon );

        attacker addweaponstat( dmgweapon, "kills", 1 );

        if ( attacker maps\mp\zombies\_zm_pers_upgrades_functions::pers_mulit_kill_headshot_active() || force_head_gib )
            zombie maps\mp\zombies\_zm_spawner::zombie_head_gib();

        if ( isdefined( level.pers_upgrade_nube ) && level.pers_upgrade_nube )
            attacker notify( "pers_player_zombie_kill" );
    }

    zombie_death_achievement_sliquifier_check( attacker, zombie );
    recalc_zombie_array();

    if ( !isdefined( zombie ) )
        return;

    level.global_zombies_killed++;

    if ( isdefined( zombie.marked_for_death ) && !isdefined( zombie.nuked ) )
        level.zombie_trap_killed_count++;

    zombie check_zombie_death_event_callbacks();
    name = zombie.animname;

    if ( isdefined( zombie.sndname ) )
        name = zombie.sndname;

    zombie thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "death", name );
    zombie thread zombie_eye_glow_stop();

    if ( isdefined( zombie.damageweapon ) && is_weapon_shotgun( zombie.damageweapon ) && maps\mp\zombies\_zm_weapons::is_weapon_upgraded( zombie.damageweapon ) || isdefined( zombie.damageweapon ) && is_placeable_mine( zombie.damageweapon ) || zombie.damagemod == "MOD_GRENADE" || zombie.damagemod == "MOD_GRENADE_SPLASH" || zombie.damagemod == "MOD_EXPLOSIVE" || force_explode == 1 )
    {
        splode_dist = 180;

        if ( isdefined( zombie.damagehit_origin ) && distancesquared( zombie.origin, zombie.damagehit_origin ) < splode_dist * splode_dist )
        {
            tag = "J_SpineLower";

            if ( isdefined( zombie.isdog ) && zombie.isdog )
                tag = "tag_origin";

            if ( !( isdefined( zombie.is_on_fire ) && zombie.is_on_fire ) && !( isdefined( zombie.guts_explosion ) && zombie.guts_explosion ) )
                zombie thread zombie_gut_explosion();
        }
    }

    if ( zombie.damagemod == "MOD_GRENADE" || zombie.damagemod == "MOD_GRENADE_SPLASH" )
    {
        if ( isdefined( attacker ) && isalive( attacker ) )
        {
            attacker.grenade_multiattack_count++;
            attacker.grenade_multiattack_ent = zombie;
        }
    }

    if ( !( isdefined( zombie.has_been_damaged_by_player ) && zombie.has_been_damaged_by_player ) && ( isdefined( zombie.marked_for_recycle ) && zombie.marked_for_recycle ) )
    {
        level.zombie_total++;
        level.zombie_total_subtract++;
    }
    else if ( isdefined( zombie.attacker ) && isplayer( zombie.attacker ) )
    {
        level.zombie_player_killed_count++;

        if ( isdefined( zombie.sound_damage_player ) && zombie.sound_damage_player == zombie.attacker )
        {
            chance = get_response_chance( "damage" );

            if ( chance != 0 )
            {
                if ( chance > randomintrange( 1, 100 ) )
                    zombie.attacker maps\mp\zombies\_zm_audio::create_and_play_dialog( "kill", "damage" );
            }
            else
                zombie.attacker maps\mp\zombies\_zm_audio::create_and_play_dialog( "kill", "damage" );
        }

        zombie.attacker notify( "zom_kill", zombie );
        damageloc = zombie.damagelocation;
        damagemod = zombie.damagemod;
        attacker = zombie.attacker;
        weapon = zombie.damageweapon;
        bbprint( "zombie_kills", "round %d zombietype %s damagetype %s damagelocation %s playername %s playerweapon %s playerx %f playery %f playerz %f zombiex %f zombiey %f zombiez %f", level.round_number, zombie.animname, damagemod, damageloc, attacker.name, weapon, attacker.origin, zombie.origin );
    }
    else if ( zombie.ignoreall && !( isdefined( zombie.marked_for_death ) && zombie.marked_for_death ) )
        level.zombies_timeout_spawn++;

    level notify( "zom_kill" );
    level.total_zombies_killed++;
}

zombie_gut_explosion()
{
    self.guts_explosion = 1;

    if ( is_mature() )
        self setclientfield( "zombie_gut_explosion", 1 );

    if ( !( isdefined( self.isdog ) && self.isdog ) )
        wait 0.1;

    if ( isdefined( self ) )
        self ghost();
}

zombie_death_achievement_sliquifier_check( e_player, e_zombie )
{
    if ( !isplayer( e_player ) )
        return;

    if ( isdefined( e_zombie ) )
    {
        if ( isdefined( e_zombie.damageweapon ) && e_zombie.damageweapon == "slipgun_zm" )
        {
            if ( !isdefined( e_player.num_sliquifier_kills ) )
                e_player.num_sliquifier_kills = 0;

            e_player.num_sliquifier_kills++;
            e_player notify( "sliquifier_kill" );
        }
    }
}

check_zombie_death_event_callbacks()
{
    if ( !isdefined( level.zombie_death_event_callbacks ) )
        return;

    for ( i = 0; i < level.zombie_death_event_callbacks.size; i++ )
        self [[ level.zombie_death_event_callbacks[i] ]]();
}

register_zombie_death_event_callback( func )
{
    if ( !isdefined( level.zombie_death_event_callbacks ) )
        level.zombie_death_event_callbacks = [];

    level.zombie_death_event_callbacks[level.zombie_death_event_callbacks.size] = func;
}

deregister_zombie_death_event_callback( func )
{
    if ( isdefined( level.zombie_death_event_callbacks ) )
        arrayremovevalue( level.zombie_death_event_callbacks, func );
}

zombie_setup_attack_properties()
{
    self zombie_history( "zombie_setup_attack_properties()" );
    self.ignoreall = 0;
    self.pathenemyfightdist = 64;
    self.meleeattackdist = 64;
    self.maxsightdistsqrd = 16384;
    self.disablearrivals = 1;
    self.disableexits = 1;
}

attractors_generated_listener()
{
    self endon( "death" );
    level endon( "intermission" );
    self endon( "stop_find_flesh" );
    self endon( "path_timer_done" );

    level waittill( "attractor_positions_generated" );

    self.zombie_path_timer = 0;
}

zombie_pathing()
{
    self endon( "death" );
    self endon( "zombie_acquire_enemy" );
    level endon( "intermission" );
/#
    assert( isdefined( self.favoriteenemy ) || isdefined( self.enemyoverride ) );
#/
    self._skip_pathing_first_delay = 1;
    self thread zombie_follow_enemy();

    self waittill( "bad_path" );

    level.zombie_pathing_failed++;

    if ( isdefined( self.enemyoverride ) )
    {
        debug_print( "Zombie couldn't path to point of interest at origin: " + self.enemyoverride[0] + " Falling back to breadcrumb system" );

        if ( isdefined( self.enemyoverride[1] ) )
        {
            self.enemyoverride = self.enemyoverride[1] invalidate_attractor_pos( self.enemyoverride, self );
            self.zombie_path_timer = 0;
            return;
        }
    }
    else if ( isdefined( self.favoriteenemy ) )
        debug_print( "Zombie couldn't path to player at origin: " + self.favoriteenemy.origin + " Falling back to breadcrumb system" );
    else
        debug_print( "Zombie couldn't path to a player ( the other 'prefered' player might be ignored for encounters mode ). Falling back to breadcrumb system" );

    if ( !isdefined( self.favoriteenemy ) )
    {
        self.zombie_path_timer = 0;
        return;
    }
    else
        self.favoriteenemy endon( "disconnect" );

    players = get_players();
    valid_player_num = 0;

    for ( i = 0; i < players.size; i++ )
    {
        if ( is_player_valid( players[i], 1 ) )
            valid_player_num += 1;
    }

    if ( players.size > 1 )
    {
        if ( isdefined( level._should_skip_ignore_player_logic ) && [[ level._should_skip_ignore_player_logic ]]() )
        {
            self.zombie_path_timer = 0;
            return;
        }

        if ( array_check_for_dupes( self.ignore_player, self.favoriteenemy ) )
            self.ignore_player[self.ignore_player.size] = self.favoriteenemy;

        if ( self.ignore_player.size < valid_player_num )
        {
            self.zombie_path_timer = 0;
            return;
        }
    }

    crumb_list = self.favoriteenemy.zombie_breadcrumbs;
    bad_crumbs = [];

    while ( true )
    {
        if ( !is_player_valid( self.favoriteenemy, 1 ) )
        {
            self.zombie_path_timer = 0;
            return;
        }

        goal = zombie_pathing_get_breadcrumb( self.favoriteenemy.origin, crumb_list, bad_crumbs, randomint( 100 ) < 20 );

        if ( !isdefined( goal ) )
        {
            debug_print( "Zombie exhausted breadcrumb search" );
            level.zombie_breadcrumb_failed++;
            goal = self.favoriteenemy.spectator_respawn.origin;
        }

        debug_print( "Setting current breadcrumb to " + goal );
        self.zombie_path_timer += 100;
        self setgoalpos( goal );

        self waittill( "bad_path" );

        debug_print( "Zombie couldn't path to breadcrumb at " + goal + " Finding next breadcrumb" );

        for ( i = 0; i < crumb_list.size; i++ )
        {
            if ( goal == crumb_list[i] )
            {
                bad_crumbs[bad_crumbs.size] = i;
                break;
            }
        }
    }
}

zombie_pathing_get_breadcrumb( origin, breadcrumbs, bad_crumbs, pick_random )
{
/#
    assert( isdefined( origin ) );
#/
/#
    assert( isdefined( breadcrumbs ) );
#/
/#
    assert( isarray( breadcrumbs ) );
#/
/#
    if ( pick_random )
        debug_print( "Finding random breadcrumb" );
#/
    for ( i = 0; i < breadcrumbs.size; i++ )
    {
        if ( pick_random )
            crumb_index = randomint( breadcrumbs.size );
        else
            crumb_index = i;

        if ( crumb_is_bad( crumb_index, bad_crumbs ) )
            continue;

        return breadcrumbs[crumb_index];
    }

    return undefined;
}

crumb_is_bad( crumb, bad_crumbs )
{
    for ( i = 0; i < bad_crumbs.size; i++ )
    {
        if ( bad_crumbs[i] == crumb )
            return true;
    }

    return false;
}

jitter_enemies_bad_breadcrumbs( start_crumb )
{
    trace_distance = 35;
    jitter_distance = 2;
    index = start_crumb;

    while ( isdefined( self.favoriteenemy.zombie_breadcrumbs[index + 1] ) )
    {
        current_crumb = self.favoriteenemy.zombie_breadcrumbs[index];
        next_crumb = self.favoriteenemy.zombie_breadcrumbs[index + 1];
        angles = vectortoangles( current_crumb - next_crumb );
        right = anglestoright( angles );
        left = anglestoright( angles + vectorscale( ( 0, 1, 0 ), 180.0 ) );
        dist_pos = current_crumb + vectorscale( right, trace_distance );
        trace = bullettrace( current_crumb, dist_pos, 1, undefined );
        vector = trace["position"];

        if ( distance( vector, current_crumb ) < 17 )
        {
            self.favoriteenemy.zombie_breadcrumbs[index] = current_crumb + vectorscale( left, jitter_distance );
            continue;
        }

        dist_pos = current_crumb + vectorscale( left, trace_distance );
        trace = bullettrace( current_crumb, dist_pos, 1, undefined );
        vector = trace["position"];

        if ( distance( vector, current_crumb ) < 17 )
        {
            self.favoriteenemy.zombie_breadcrumbs[index] = current_crumb + vectorscale( right, jitter_distance );
            continue;
        }

        index++;
    }
}

zombie_repath_notifier()
{
    note = 0;
    notes = [];

    for ( i = 0; i < 4; i++ )
        notes[notes.size] = "zombie_repath_notify_" + i;

    while ( true )
    {
        level notify( notes[note] );
        note = ( note + 1 ) % 4;
        wait 0.05;
    }
}

zombie_follow_enemy()
{
    self endon( "death" );
    self endon( "zombie_acquire_enemy" );
    self endon( "bad_path" );
    level endon( "intermission" );

    if ( !isdefined( level.repathnotifierstarted ) )
    {
        level.repathnotifierstarted = 1;
        level thread zombie_repath_notifier();
    }

    if ( !isdefined( self.zombie_repath_notify ) )
        self.zombie_repath_notify = "zombie_repath_notify_" + self getentitynumber() % 4;

    while ( true )
    {
        if ( !isdefined( self._skip_pathing_first_delay ) )
            level waittill( self.zombie_repath_notify );
        else
            self._skip_pathing_first_delay = undefined;

        if ( !( isdefined( self.ignore_enemyoverride ) && self.ignore_enemyoverride ) && isdefined( self.enemyoverride ) && isdefined( self.enemyoverride[1] ) )
        {
            if ( distancesquared( self.origin, self.enemyoverride[0] ) > 1 )
                self orientmode( "face motion" );
            else
                self orientmode( "face point", self.enemyoverride[1].origin );

            self.ignoreall = 1;
            goalpos = self.enemyoverride[0];

            if ( isdefined( level.adjust_enemyoverride_func ) )
                goalpos = self [[ level.adjust_enemyoverride_func ]]();

            self setgoalpos( goalpos );
        }
        else if ( isdefined( self.favoriteenemy ) )
        {
            self.ignoreall = 0;
            self orientmode( "face default" );
            goalpos = self.favoriteenemy.origin;

            if ( isdefined( level.enemy_location_override_func ) )
                goalpos = [[ level.enemy_location_override_func ]]( self, self.favoriteenemy );

            self setgoalpos( goalpos );

            if ( !isdefined( level.ignore_path_delays ) )
            {
                distsq = distancesquared( self.origin, self.favoriteenemy.origin );

                if ( distsq > 10240000 )
                    wait( 2.0 + randomfloat( 1.0 ) );
                else if ( distsq > 4840000 )
                    wait( 1.0 + randomfloat( 0.5 ) );
                else if ( distsq > 1440000 )
                    wait( 0.5 + randomfloat( 0.5 ) );
            }
        }

        if ( isdefined( level.inaccesible_player_func ) )
            self [[ level.inaccessible_player_func ]]();
    }
}

zombie_eye_glow()
{
    if ( !isdefined( self ) )
        return;

    if ( !isdefined( self.no_eye_glow ) || !self.no_eye_glow )
        self setclientfield( "zombie_has_eyes", 1 );
}

zombie_eye_glow_stop()
{
    if ( !isdefined( self ) )
        return;

    if ( !isdefined( self.no_eye_glow ) || !self.no_eye_glow )
        self setclientfield( "zombie_has_eyes", 0 );
}

zombie_history( msg )
{
/#
    if ( !isdefined( self.zombie_history ) || 32 <= self.zombie_history.size )
        self.zombie_history = [];

    self.zombie_history[self.zombie_history.size] = msg;
#/
}

do_zombie_spawn()
{
    self endon( "death" );
    spots = [];

    if ( isdefined( self._rise_spot ) )
    {
        spot = self._rise_spot;
        self thread do_zombie_rise( spot );
        return;
    }

    if ( isdefined( level.zombie_spawn_locations ) )
    {
        for ( i = 0; i < level.zombie_spawn_locations.size; i++ )
        {
            if ( isdefined( level.use_multiple_spawns ) && level.use_multiple_spawns && isdefined( self.script_int ) )
            {
                if ( !( isdefined( level.spawner_int ) && level.spawner_int == self.script_int ) && !( isdefined( level.zombie_spawn_locations[i].script_int ) || isdefined( level.zones[level.zombie_spawn_locations[i].zone_name].script_int ) ) )
                    continue;

                if ( isdefined( level.zombie_spawn_locations[i].script_int ) && level.zombie_spawn_locations[i].script_int != self.script_int )
                    continue;
                else if ( isdefined( level.zones[level.zombie_spawn_locations[i].zone_name].script_int ) && level.zones[level.zombie_spawn_locations[i].zone_name].script_int != self.script_int )
                    continue;
            }

            spots[spots.size] = level.zombie_spawn_locations[i];
        }
    }
/#
    if ( getdvarint( _hash_A8C231AA ) )
    {
        if ( isdefined( level.zombie_spawn_locations ) )
        {
            player = get_players()[0];
            spots = [];

            for ( i = 0; i < level.zombie_spawn_locations.size; i++ )
            {
                player_vec = vectornormalize( anglestoforward( player.angles ) );
                player_spawn = vectornormalize( level.zombie_spawn_locations[i].origin - player.origin );
                dot = vectordot( player_vec, player_spawn );

                if ( dot > 0.707 )
                {
                    spots[spots.size] = level.zombie_spawn_locations[i];
                    debugstar( level.zombie_spawn_locations[i].origin, 1000, ( 1, 1, 1 ) );
                }
            }

            if ( spots.size <= 0 )
            {
                spots[spots.size] = level.zombie_spawn_locations[0];
                iprintln( "no spawner in view" );
            }
        }
    }
#/
/#
    assert( spots.size > 0, "No spawn locations found" );
#/
    spot = random( spots );
    self.spawn_point = spot;
/#
    if ( isdefined( level.toggle_show_spawn_locations ) && level.toggle_show_spawn_locations )
    {
        debugstar( spot.origin, getdvarint( _hash_BB9101B2 ), ( 0, 1, 0 ) );
        host_player = gethostplayer();
        distance = distance( spot.origin, host_player.origin );
        iprintln( "Distance to player: " + distance / 12 + "feet" );
    }
#/
    if ( isdefined( spot.target ) )
        self.target = spot.target;

    if ( isdefined( spot.zone_name ) )
        self.zone_name = spot.zone_name;

    if ( isdefined( spot.script_parameters ) )
        self.script_parameters = spot.script_parameters;

    tokens = strtok( spot.script_noteworthy, " " );

    foreach ( index, token in tokens )
    {
        if ( isdefined( self.spawn_point_override ) )
        {
            spot = self.spawn_point_override;
            token = spot.script_noteworthy;
        }

        if ( token == "custom_spawner_entry" )
        {
            next_token = index + 1;

            if ( isdefined( tokens[next_token] ) )
            {
                str_spawn_entry = tokens[next_token];

                if ( isdefined( level.custom_spawner_entry ) && isdefined( level.custom_spawner_entry[str_spawn_entry] ) )
                {
                    self thread [[ level.custom_spawner_entry[str_spawn_entry] ]]( spot );
                    continue;
                }
            }
        }

        if ( token == "riser_location" )
        {
            self thread do_zombie_rise( spot );
            continue;
        }

        if ( token == "faller_location" )
        {
            self thread maps\mp\zombies\_zm_ai_faller::do_zombie_fall( spot );
            continue;
        }

        if ( token == "dog_location" )
            continue;
        else if ( token == "screecher_location" )
            continue;
        else if ( token == "leaper_location" )
            continue;
        else
        {
            if ( isdefined( self.anchor ) )
                return;

            self.anchor = spawn( "script_origin", self.origin );
            self.anchor.angles = self.angles;
            self linkto( self.anchor );

            if ( !isdefined( spot.angles ) )
                spot.angles = ( 0, 0, 0 );

            self ghost();
            self.anchor moveto( spot.origin, 0.05 );

            self.anchor waittill( "movedone" );

            target_org = get_desired_origin();

            if ( isdefined( target_org ) )
            {
                anim_ang = vectortoangles( target_org - self.origin );
                self.anchor rotateto( ( 0, anim_ang[1], 0 ), 0.05 );

                self.anchor waittill( "rotatedone" );
            }

            if ( isdefined( level.zombie_spawn_fx ) )
                playfx( level.zombie_spawn_fx, spot.origin );

            self unlink();

            if ( isdefined( self.anchor ) )
                self.anchor delete();

            self show();
            self notify( "risen", spot.script_string );
        }
    }
}

do_zombie_rise( spot )
{
    self endon( "death" );
    self.in_the_ground = 1;

    if ( isdefined( self.anchor ) )
        self.anchor delete();

    self.anchor = spawn( "script_origin", self.origin );
    self.anchor.angles = self.angles;
    self linkto( self.anchor );

    if ( !isdefined( spot.angles ) )
        spot.angles = ( 0, 0, 0 );

    anim_org = spot.origin;
    anim_ang = spot.angles;
    anim_org += ( 0, 0, 0 );
    self ghost();
    self.anchor moveto( anim_org, 0.05 );

    self.anchor waittill( "movedone" );

    target_org = get_desired_origin();

    if ( isdefined( target_org ) )
    {
        anim_ang = vectortoangles( target_org - self.origin );
        self.anchor rotateto( ( 0, anim_ang[1], 0 ), 0.05 );

        self.anchor waittill( "rotatedone" );
    }

    self unlink();

    if ( isdefined( self.anchor ) )
        self.anchor delete();

    self thread hide_pop();
    level thread zombie_rise_death( self, spot );
    spot thread zombie_rise_fx( self );
    substate = 0;

    if ( self.zombie_move_speed == "walk" )
        substate = randomint( 2 );
    else if ( self.zombie_move_speed == "run" )
        substate = 2;
    else if ( self.zombie_move_speed == "sprint" )
        substate = 3;

    self orientmode( "face default" );
    self animscripted( self.origin, spot.angles, "zm_rise", substate );
    self maps\mp\animscripts\zm_shared::donotetracks( "rise_anim", ::handle_rise_notetracks, spot );
    self notify( "rise_anim_finished" );
    spot notify( "stop_zombie_rise_fx" );
    self.in_the_ground = 0;
    self notify( "risen", spot.script_string );
}

hide_pop()
{
    self endon( "death" );
    wait 0.5;

    if ( isdefined( self ) )
    {
        self show();
        wait_network_frame();

        if ( isdefined( self ) )
            self.create_eyes = 1;
    }
}

handle_rise_notetracks( note, spot )
{
    if ( note == "deathout" || note == "deathhigh" )
    {
        self.zombie_rise_death_out = 1;
        self notify( "zombie_rise_death_out" );
        wait 2;
        spot notify( "stop_zombie_rise_fx" );
    }
}

zombie_rise_death( zombie, spot )
{
    zombie.zombie_rise_death_out = 0;
    zombie endon( "rise_anim_finished" );

    while ( isdefined( zombie ) && isdefined( zombie.health ) && zombie.health > 1 )
        zombie waittill( "damage", amount );

    spot notify( "stop_zombie_rise_fx" );

    if ( isdefined( zombie ) )
    {
        zombie.deathanim = zombie get_rise_death_anim();
        zombie stopanimscripted();
    }
}

zombie_rise_fx( zombie )
{
    if ( !( isdefined( level.riser_fx_on_client ) && level.riser_fx_on_client ) )
    {
        self thread zombie_rise_dust_fx( zombie );
        self thread zombie_rise_burst_fx( zombie );
    }
    else
        self thread zombie_rise_burst_fx( zombie );

    zombie endon( "death" );
    self endon( "stop_zombie_rise_fx" );
    wait 1;

    if ( zombie.zombie_move_speed != "sprint" )
        wait 1;
}

zombie_rise_burst_fx( zombie )
{
    self endon( "stop_zombie_rise_fx" );
    self endon( "rise_anim_finished" );

    if ( isdefined( self.script_parameters ) && self.script_parameters == "in_water" && !( isdefined( level._no_water_risers ) && level._no_water_risers ) )
        zombie setclientfield( "zombie_riser_fx_water", 1 );
    else if ( isdefined( self.script_parameters ) && self.script_parameters == "in_foliage" && ( isdefined( level._foliage_risers ) && level._foliage_risers ) )
        zombie setclientfield( "zombie_riser_fx_foliage", 1 );
    else if ( isdefined( self.script_parameters ) && self.script_parameters == "in_snow" )
        zombie setclientfield( "zombie_riser_fx", 1 );
    else if ( isdefined( zombie.zone_name ) && isdefined( level.zones[zombie.zone_name] ) )
    {
        low_g_zones = getentarray( zombie.zone_name, "targetname" );

        if ( isdefined( low_g_zones[0].script_string ) && low_g_zones[0].script_string == "lowgravity" )
            zombie setclientfield( "zombie_riser_fx_lowg", 1 );
        else
            zombie setclientfield( "zombie_riser_fx", 1 );
    }
    else
        zombie setclientfield( "zombie_riser_fx", 1 );
}

zombie_rise_dust_fx( zombie )
{
    dust_tag = "J_SpineUpper";
    self endon( "stop_zombie_rise_dust_fx" );
    self thread stop_zombie_rise_dust_fx( zombie );
    wait 2;
    dust_time = 5.5;
    dust_interval = 0.3;

    if ( isdefined( self.script_string ) && self.script_string == "in_water" )
    {
        for ( t = 0; t < dust_time; t += dust_interval )
        {
            playfxontag( level._effect["rise_dust_water"], zombie, dust_tag );
            wait( dust_interval );
        }
    }
    else if ( isdefined( self.script_string ) && self.script_string == "in_snow" )
    {
        for ( t = 0; t < dust_time; t += dust_interval )
        {
            playfxontag( level._effect["rise_dust_snow"], zombie, dust_tag );
            wait( dust_interval );
        }
    }
    else if ( isdefined( self.script_string ) && self.script_string == "in_foliage" )
    {
        for ( t = 0; t < dust_time; t += dust_interval )
        {
            playfxontag( level._effect["rise_dust_foliage"], zombie, dust_tag );
            wait( dust_interval );
        }
    }
    else
    {
        for ( t = 0; t < dust_time; t += dust_interval )
        {
            playfxontag( level._effect["rise_dust"], zombie, dust_tag );
            wait( dust_interval );
        }
    }
}

stop_zombie_rise_dust_fx( zombie )
{
    zombie waittill( "death" );

    self notify( "stop_zombie_rise_dust_fx" );
}

get_rise_death_anim()
{
    if ( self.zombie_rise_death_out )
        return "zm_rise_death_out";

    self.noragdoll = 1;
    self.nodeathragdoll = 1;
    return "zm_rise_death_in";
}

zombie_tesla_head_gib()
{
    self endon( "death" );

    if ( self.animname == "quad_zombie" )
        return;

    if ( randomint( 100 ) < level.zombie_vars["tesla_head_gib_chance"] )
    {
        wait( randomfloatrange( 0.53, 1.0 ) );
        self zombie_head_gib();
    }
    else
        network_safe_play_fx_on_tag( "tesla_death_fx", 2, level._effect["tesla_shock_eyes"], self, "J_Eyeball_LE" );
}

play_ambient_zombie_vocals()
{
    self endon( "death" );

    if ( self.animname == "monkey_zombie" || isdefined( self.is_avogadro ) && self.is_avogadro )
        return;

    while ( true )
    {
        type = "ambient";
        float = 2;

        if ( !isdefined( self.zombie_move_speed ) )
        {
            wait 0.5;
            continue;
        }

        switch ( self.zombie_move_speed )
        {
            case "walk":
                type = "ambient";
                float = 4;
                break;
            case "run":
                type = "sprint";
                float = 4;
                break;
            case "sprint":
                type = "sprint";
                float = 4;
                break;
        }

        if ( self.animname == "zombie" && !self.has_legs )
            type = "crawler";
        else if ( self.animname == "thief_zombie" || self.animname == "leaper_zombie" )
            float = 1.2;

        name = self.animname;

        if ( isdefined( self.sndname ) )
            name = self.sndname;

        self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( type, name );
        wait( randomfloatrange( 1, float ) );
    }
}

zombie_complete_emerging_into_playable_area()
{
    self.completed_emerging_into_playable_area = 1;
    self notify( "completed_emerging_into_playable_area" );
    self.no_powerups = 0;
    self thread zombie_free_cam_allowed();
}

zombie_free_cam_allowed()
{
    self endon( "death" );
    wait 1.5;
    self setfreecameralockonallowed( 1 );
}
