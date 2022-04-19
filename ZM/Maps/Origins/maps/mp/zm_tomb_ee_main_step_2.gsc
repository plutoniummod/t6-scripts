// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_tomb_ee_main;
#include maps\mp\zombies\_zm_powerup_zombie_blood;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zm_tomb_craftables;

init()
{
    declare_sidequest_stage( "little_girl_lost", "step_2", ::init_stage, ::stage_logic, ::exit_stage );
    precachemodel( "p6_zm_tm_staff_holder" );
}

init_stage()
{
    level._cur_stage_name = "step_2";
    a_structs = getstructarray( "robot_head_staff", "targetname" );

    foreach ( unitrigger_stub in a_structs )
    {
        level thread create_robot_head_trigger( unitrigger_stub );
        wait_network_frame();
        wait_network_frame();
        wait_network_frame();
    }
}

stage_logic()
{
/#
    iprintln( level._cur_stage_name + " of little girl lost started" );
#/
    flag_wait( "ee_all_staffs_placed" );
    playsoundatposition( "zmb_squest_robot_alarm_high", ( -14, -1, 871 ) );
    wait 3;
    wait_network_frame();
    stage_completed( "little_girl_lost", level._cur_stage_name );
}

exit_stage( success )
{
    a_structs = getstructarray( "robot_head_staff", "targetname" );

    foreach ( struct in a_structs )
    {
        struct thread remove_plinth();
        wait_network_frame();
        wait_network_frame();
        wait_network_frame();
    }
}

remove_plinth()
{
    playfx( level._effect["teleport_1p"], self.m_plinth.origin );
    playsoundatposition( "zmb_footprintbox_disappear", self.m_plinth.origin );
    wait 3;

    if ( isdefined( self.m_plinth.m_staff ) )
    {
        self.m_plinth.m_staff unlink();
        self.m_plinth.m_staff.origin = self.m_plinth.v_old_origin;
        self.m_plinth.m_staff.angles = self.m_plinth.v_old_angles;
        self.m_plinth.e_staff.ee_in_use = undefined;
    }

    self.m_sign delete();
    self.m_plinth delete();
    self.m_coll delete();
    unregister_unitrigger( self );
}

create_robot_head_trigger( unitrigger_stub )
{
    playfx( level._effect["teleport_1p"], unitrigger_stub.origin );
    playsoundatposition( "zmb_footprintbox_disappear", unitrigger_stub.origin );
    wait 3;
    unitrigger_stub.radius = 50;
    unitrigger_stub.height = 256;
    unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
    unitrigger_stub.cursor_hint = "HINT_NOICON";
    unitrigger_stub.require_look_at = 1;
    m_coll = spawn( "script_model", unitrigger_stub.origin );
    m_coll setmodel( "drone_collision" );
    unitrigger_stub.m_coll = m_coll;
    wait_network_frame();
    m_plinth = spawn( "script_model", unitrigger_stub.origin );
    m_plinth.angles = unitrigger_stub.angles;
    m_plinth setmodel( "p6_zm_tm_staff_holder" );
    unitrigger_stub.m_plinth = m_plinth;
    wait_network_frame();
    m_sign = spawn( "script_model", unitrigger_stub.origin );
    m_sign setmodel( "p6_zm_tm_runes" );
    m_sign linkto( unitrigger_stub.m_plinth, "tag_origin", ( 0, 15, 40 ) );
    m_sign hidepart( "j_fire" );
    m_sign hidepart( "j_ice" );
    m_sign hidepart( "j_lightning" );
    m_sign hidepart( "j_wind" );

    switch ( unitrigger_stub.script_noteworthy )
    {
        case "fire":
            m_sign showpart( "j_fire" );
            break;
        case "water":
            m_sign showpart( "j_ice" );
            break;
        case "lightning":
            m_sign showpart( "j_lightning" );
            break;
        case "air":
            m_sign showpart( "j_wind" );
            break;
    }

    m_sign maps\mp\zombies\_zm_powerup_zombie_blood::make_zombie_blood_entity();
    unitrigger_stub.m_sign = m_sign;
    unitrigger_stub.origin += vectorscale( ( 0, 0, 1 ), 30.0 );
    maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::robot_head_trigger_think );
}

robot_head_trigger_think()
{
    self endon( "kill_trigger" );
    str_weap_staff = "staff_" + self.script_noteworthy + "_upgraded_zm";
    e_upgraded_staff = maps\mp\zm_tomb_craftables::get_staff_info_from_weapon_name( str_weap_staff );

    while ( true )
    {
        self waittill( "trigger", player );

        if ( player hasweapon( str_weap_staff ) )
        {
            e_upgraded_staff.ee_in_use = 1;
            player takeweapon( str_weap_staff );
            maps\mp\zm_tomb_craftables::clear_player_staff( str_weap_staff );
            level.n_ee_robot_staffs_planted++;

            if ( level.n_ee_robot_staffs_planted == 4 )
                flag_set( "ee_all_staffs_placed" );

            e_upgraded_staff thread place_staff( self.stub.m_plinth );
        }
    }
}

place_staff( m_plinth )
{
    m_staff = getent( "craftable_" + self.weapname, "targetname" );
    m_plinth.e_staff = self;
    m_plinth.m_staff = m_staff;
    m_plinth.v_old_angles = m_staff.angles;
    m_plinth.v_old_origin = m_staff.origin;
    m_staff linkto( m_plinth, "tag_origin", ( 0, 10, 30 ), ( 345, 90, 0 ) );
    m_staff show();
    m_plinth playsound( "zmb_squest_robot_place_staff" );
}
