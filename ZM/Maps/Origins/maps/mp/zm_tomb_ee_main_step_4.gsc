// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_tomb_ee_main;
#include maps\mp\zombies\_zm_ai_mechz;
#include maps\mp\zombies\_zm_ai_mechz_dev;
#include maps\mp\zombies\_zm_ai_mechz_claw;
#include maps\mp\zombies\_zm_ai_mechz_ft;
#include maps\mp\zombies\_zm_ai_mechz_booster;
#include maps\mp\zm_tomb_vo;
#include maps\mp\zombies\_zm_ai_mechz_ffotd;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\animscripts\zm_shared;

init()
{
    declare_sidequest_stage( "little_girl_lost", "step_4", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
    level._cur_stage_name = "step_4";
    level.ee_mech_zombies_killed = 0;
    level.ee_mech_zombies_alive = 0;
    level.ee_mech_zombies_spawned = 0;
    level.quadrotor_custom_behavior = ::mech_zombie_hole_search;
}

stage_logic()
{
/#
    iprintln( level._cur_stage_name + " of little girl lost started" );
#/
    flag_wait( "ee_quadrotor_disabled" );
    level thread sndee4music();

    if ( !flag( "ee_mech_zombie_fight_completed" ) )
    {
        while ( level.ee_mech_zombies_spawned < 8 )
        {
            if ( level.ee_mech_zombies_alive < 4 )
            {
                ai = spawn_zombie( level.mechz_spawners[0] );
                ai thread ee_mechz_spawn( level.ee_mech_zombies_spawned % 4 );
                level.ee_mech_zombies_alive++;
                level.ee_mech_zombies_spawned++;
            }

            wait( randomfloatrange( 0.5, 1 ) );
        }
    }

    flag_wait( "ee_mech_zombie_fight_completed" );
    wait_network_frame();
    stage_completed( "little_girl_lost", level._cur_stage_name );
}

exit_stage( success )
{
    level.quadrotor_custom_behavior = undefined;
}

mech_zombie_hole_search()
{
    s_goal = getstruct( "ee_mech_hole_goal_0", "targetname" );

    if ( distance2dsquared( self.origin, s_goal.origin ) < 250000 )
    {
        self setvehgoalpos( s_goal.origin, 1, 2, 1 );
        self waittill_any( "near_goal", "force_goal", "reached_end_node" );
        s_goal = getstruct( "ee_mech_hole_goal_1", "targetname" );
        self setvehgoalpos( s_goal.origin, 1, 0, 1 );
        self waittill_any( "near_goal", "force_goal", "reached_end_node" );
        wait 2;
        s_goal = getstruct( "ee_mech_hole_goal_2", "targetname" );
        self setvehgoalpos( s_goal.origin, 1, 0, 1 );
        self waittill_any( "near_goal", "force_goal", "reached_end_node" );
        playsoundatposition( "zmb_squest_maxis_folly", s_goal.origin );
        maxissay( "vox_maxi_drone_upgraded_3", self );
        flag_set( "ee_quadrotor_disabled" );
        self dodamage( 200, self.origin );
        self delete();
        level.maxis_quadrotor = undefined;
    }
}

ee_mechz_spawn( n_spawn_pos )
{
    self maps\mp\zombies\_zm_ai_mechz_ffotd::spawn_start();
    self endon( "death" );
    level endon( "intermission" );
    self mechz_attach_objects();
    self mechz_set_starting_health();
    self mechz_setup_fx();
    self mechz_setup_snd();
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
    recalc_zombie_array();
    self setphysparams( 20, 0, 80 );
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
    self thread maps\mp\zombies\_zm_spawner::zombie_eye_glow();
    level thread maps\mp\zombies\_zm_spawner::zombie_death_event( self );
    self thread maps\mp\zombies\_zm_spawner::enemy_death_detection();
    a_spawner_structs = getstructarray( "mech_hole_spawner", "targetname" );
    spawn_pos = a_spawner_structs[n_spawn_pos];

    if ( !isdefined( spawn_pos.angles ) )
        spawn_pos.angles = ( 0, 0, 0 );

    self thread mechz_death();
    self thread mechz_death_ee();
    self forceteleport( spawn_pos.origin, spawn_pos.angles );
    self set_zombie_run_cycle( "walk" );

    if ( isdefined( level.mechz_find_flesh_override_func ) )
        level thread [[ level.mechz_find_flesh_override_func ]]();
    else
        self thread mechz_find_flesh();

    self thread mechz_jump_think( spawn_pos );
    self ee_mechz_do_jump( spawn_pos );
    self maps\mp\zombies\_zm_ai_mechz_ffotd::spawn_end();
}

mechz_death_ee()
{
    self waittill( "death" );

    level.ee_mech_zombies_killed++;
    level.ee_mech_zombies_alive--;

    if ( level.ee_mech_zombies_killed == 4 )
    {
        v_max_ammo_origin = self.origin;
        level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop( "full_ammo", v_max_ammo_origin );
    }

    if ( level.ee_mech_zombies_killed == 8 )
    {
        v_nuke_origin = self.origin;
        level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop( "nuke", v_nuke_origin );
        flag_set( "ee_mech_zombie_fight_completed" );
    }
}

ee_mechz_do_jump( s_spawn_pos )
{
    self endon( "death" );
    self endon( "kill_jump" );
/#
    if ( getdvarint( _hash_E7121222 ) > 0 )
        println( "\\nMZ: Doing Jump-Teleport\\n" );
#/
/#
    if ( getdvarint( _hash_E7121222 ) > 1 )
        println( "\\nMZ: Jump setting not interruptable\\n" );
#/
    self.not_interruptable = 1;
    self setfreecameralockonallowed( 0 );
    self animscripted( self.origin, self.angles, "zm_fly_out" );
    self maps\mp\animscripts\zm_shared::donotetracks( "jump_anim" );
    self ghost();

    if ( isdefined( self.m_claw ) )
        self.m_claw ghost();

    old_fx = self.fx_field;
    self thread maps\mp\zombies\_zm_spawner::zombie_eye_glow_stop();
    self fx_cleanup();
    self animscripted( self.origin, self.angles, "zm_fly_hover" );
    wait( level.mechz_jump_delay );
    s_landing_point = getstruct( s_spawn_pos.target, "targetname" );

    if ( !isdefined( s_landing_point.angles ) )
        s_landing_point.angles = ( 0, 0, 0 );

    self animscripted( s_landing_point.origin, s_landing_point.angles, "zm_fly_in" );
    self show();
    self.fx_field = old_fx;
    self setclientfield( "mechz_fx", self.fx_field );
    self thread maps\mp\zombies\_zm_spawner::zombie_eye_glow();

    if ( isdefined( self.m_claw ) )
        self.m_claw show();

    self maps\mp\animscripts\zm_shared::donotetracks( "jump_anim" );
    self.not_interruptable = 0;
    self setfreecameralockonallowed( 1 );
/#
    if ( getdvarint( _hash_E7121222 ) > 1 )
        println( "\\nMZ: Jump clearing not interruptable\\n" );
#/
    mechz_jump_cleanup();
    self.closest_jump_point = s_landing_point;
}

sndee4music()
{
    shouldplay = sndwait();

    if ( !shouldplay )
        return;

    level.music_override = 1;
    level setclientfield( "mus_zmb_egg_snapshot_loop", 1 );
    ent = spawn( "script_origin", ( 0, 0, 0 ) );
    ent playloopsound( "mus_mechz_fight_loop" );
    flag_wait( "ee_mech_zombie_fight_completed" );
    level setclientfield( "mus_zmb_egg_snapshot_loop", 0 );
    level.music_override = 0;
    wait 0.05;
    ent delete();
}

sndwait()
{
    counter = 0;

    while ( is_true( level.music_override ) )
    {
        wait 1;
        counter++;

        if ( counter >= 60 )
            return false;
    }

    return true;
}
