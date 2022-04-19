// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_tomb_ee_main;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_powerup_zombie_blood;
#include maps\mp\zombies\_zm_unitrigger;

init()
{
    declare_sidequest_stage( "little_girl_lost", "step_5", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
    level._cur_stage_name = "step_5";
    level.callbackvehicledamage = ::ee_plane_vehicledamage;
    level.zombie_ai_limit--;
}

stage_logic()
{
/#
    iprintln( level._cur_stage_name + " of little girl lost started" );
#/
    level thread spawn_zombie_blood_plane();
    flag_wait( "ee_maxis_drone_retrieved" );
    wait_network_frame();
    stage_completed( "little_girl_lost", level._cur_stage_name );
}

exit_stage( success )
{
    level.zombie_ai_limit++;
}

spawn_zombie_blood_plane()
{
    s_biplane_pos = getstruct( "air_crystal_biplane_pos", "targetname" );
    vh_biplane = spawnvehicle( "veh_t6_dlc_zm_biplane", "zombie_blood_biplane", "biplane_zm", ( 0, 0, 0 ), ( 0, 0, 0 ) );
    vh_biplane ent_flag_init( "biplane_down", 0 );
    vh_biplane maps\mp\zombies\_zm_powerup_zombie_blood::make_zombie_blood_entity();
    vh_biplane playloopsound( "zmb_zombieblood_3rd_plane_loop", 1 );
    vh_biplane.health = 10000;
    vh_biplane setcandamage( 1 );
    vh_biplane setforcenocull();
    vh_biplane attachpath( getvehiclenode( "biplane_start", "targetname" ) );
    vh_biplane startpath();
    vh_biplane setclientfield( "ee_plane_fx", 1 );
    vh_biplane ent_flag_wait( "biplane_down" );
    vh_biplane playsound( "zmb_zombieblood_3rd_plane_explode" );
    e_special_zombie = getentarray( "zombie_spawner_dig", "script_noteworthy" )[0];
    ai_pilot = spawn_zombie( e_special_zombie, "zombie_blood_pilot" );
    ai_pilot magic_bullet_shield();
    ai_pilot.ignore_enemy_count = 1;
    ai_pilot maps\mp\zombies\_zm_powerup_zombie_blood::make_zombie_blood_entity();
    ai_pilot forceteleport( vh_biplane.origin, vh_biplane.angles );
    ai_pilot.sndname = "capzomb";
    ai_pilot.ignore_nuke = 1;
    ai_pilot.b_zombie_blood_damage_only = 1;
    playfx( level._effect["biplane_explode"], vh_biplane.origin );
    vh_biplane delete();
    a_start_pos = getstructarray( "pilot_goal", "script_noteworthy" );
    a_start_pos = get_array_of_closest( ai_pilot.origin, a_start_pos );
    linker = spawn( "script_model", ai_pilot.origin );
    linker setmodel( "tag_origin" );
    ai_pilot linkto( linker );
    linker moveto( a_start_pos[0].origin, 3 );

    linker waittill( "movedone" );

    linker delete();
    ai_pilot stop_magic_bullet_shield();
    level thread zombie_pilot_sound( ai_pilot );
    ai_pilot.ignoreall = 1;
    ai_pilot.zombie_move_speed = "sprint";
    ai_pilot set_zombie_run_cycle( "sprint" );
    ai_pilot thread pilot_loop_logic( a_start_pos[0] );

    ai_pilot waittill( "death" );

    level thread spawn_quadrotor_pickup( ai_pilot.origin, ai_pilot.angles );
}

zombie_pilot_sound( ai_pilot )
{
    sndent = spawn( "script_origin", ai_pilot.origin );
    sndent playloopsound( "zmb_zombieblood_3rd_loop_other" );

    while ( isdefined( ai_pilot ) && isalive( ai_pilot ) )
    {
        sndent.origin = ai_pilot.origin;
        wait 0.3;
    }

    sndent delete();
}

pilot_loop_logic( s_start )
{
    self endon( "death" );

    for ( s_goal = s_start; isalive( self ); s_goal = getstruct( s_goal.target, "targetname" ) )
    {
        self setgoalpos( s_goal.origin );

        self waittill( "goal" );
    }
}

ee_plane_vehicledamage( e_inflictor, e_attacker, n_damage, n_dflags, str_means_of_death, str_weapon, v_point, v_dir, str_hit_loc, psoffsettime, b_damage_from_underneath, n_model_index, str_part_name )
{
    if ( self.vehicletype == "biplane_zm" && !self ent_flag( "biplane_down" ) )
    {
        if ( isplayer( e_attacker ) && e_attacker.zombie_vars["zombie_powerup_zombie_blood_on"] )
            self ent_flag_set( "biplane_down" );

        return 0;
    }

    return n_damage;
}

spawn_quadrotor_pickup( v_origin, v_angles )
{
    m_quadrotor = spawn( "script_model", v_origin + vectorscale( ( 0, 0, 1 ), 30.0 ) );
    m_quadrotor.angles = v_angles;
    m_quadrotor setmodel( "veh_t6_dlc_zm_quadrotor" );
    m_quadrotor.targetname = "quadrotor_pickup";
    unitrigger_stub = spawnstruct();
    unitrigger_stub.origin = v_origin;
    unitrigger_stub.radius = 36;
    unitrigger_stub.height = 256;
    unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
    unitrigger_stub.hint_string = &"ZM_TOMB_DIHS";
    unitrigger_stub.cursor_hint = "HINT_NOICON";
    unitrigger_stub.require_look_at = 1;
    maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::quadrotor_pickup_think );
    flag_wait( "ee_maxis_drone_retrieved" );
    unregister_unitrigger( unitrigger_stub );
}

quadrotor_pickup_think()
{
    self endon( "kill_trigger" );
    m_quadrotor = getent( "quadrotor_pickup", "targetname" );

    while ( true )
    {
        self waittill( "trigger", player );

        player playsound( "vox_maxi_drone_upgraded_0" );
        flag_clear( "ee_quadrotor_disabled" );
        flag_set( "ee_maxis_drone_retrieved" );
        m_quadrotor delete();
    }
}
