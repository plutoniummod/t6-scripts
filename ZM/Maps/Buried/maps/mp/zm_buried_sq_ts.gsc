// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;

init()
{
    flag_init( "sq_ts_quicktest" );
    declare_sidequest_stage( "sq", "ts", ::init_stage, ::stage_logic, ::exit_stage );
}

init_stage()
{
    a_signs = getentarray( "sq_tunnel_sign", "targetname" );

    foreach ( m_sign in a_signs )
    {
        m_sign setcandamage( 1 );
        m_sign thread ts_sign_damage_watch();
    }

    level._cur_stage_name = "ts";
    clientnotify( "ts" );
}

stage_logic()
{
/#
    iprintlnbold( "TS Started" );
#/
    level waittill( "sq_sign_damaged" );

    wait_network_frame();
    stage_completed( "sq", level._cur_stage_name );
}

exit_stage( success )
{

}

ts_sign_damage_watch()
{
    level endon( "sq_sign_damaged" );
    self ts_sign_deactivate();

    while ( true )
    {
        self waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_type, str_tag, str_model, str_part, str_weapon );

        if ( flag( "sq_ts_quicktest" ) )
        {
            level.m_sq_start_sign = self;
            level.e_sq_sign_attacker = e_attacker;
            level notify( "sq_sign_damaged" );
        }

        if ( ts_is_bowie_knife( str_weapon ) || ts_is_galvaknuckles( str_weapon ) )
        {
            if ( self.ts_sign_activated )
                self thread ts_sign_deactivate();
            else
                self thread ts_sign_activate();

            ts_sign_check_all_activated( e_attacker, self );
        }
    }
}

ts_sign_activate()
{
    self.ts_sign_activated = 1;

    if ( !isdefined( self.fx_ent ) )
    {
        v_forward = anglestoforward( self.angles );
        v_offset = vectornormalize( v_forward ) * 2;
        self.fx_ent = spawn( "script_model", self.origin - vectorscale( ( 0, 0, 1 ), 20.0 ) + v_offset );
        self.fx_ent.angles = anglestoforward( self.angles );
        self.fx_ent setmodel( "tag_origin" );
        self.fx_ent playsound( "zmb_sq_wisp_spawn" );
        self.fx_ent playloopsound( "zmb_sq_wisp_wall_loop" );

        while ( isdefined( self.fx_ent ) )
        {
            playfxontag( level._effect["sq_ether_amp_trail"], self.fx_ent, "tag_origin" );
            wait 0.3;
        }
    }
}

ts_sign_deactivate()
{
    self.ts_sign_activated = 0;

    if ( isdefined( self.fx_ent ) )
    {
        self.fx_ent stoploopsound( 2 );
        self.fx_ent delete();
    }
}

ts_sign_check_all_activated( e_attacker, m_last_touched )
{
    a_signs = getentarray( "sq_tunnel_sign", "targetname" );
    a_signs_active = [];
    is_max_complete = 1;
    is_ric_complete = 1;

    foreach ( m_sign in a_signs )
    {
        if ( m_sign.ts_sign_activated )
        {
            a_signs_active[a_signs_active.size] = m_sign;

            if ( !is_true( m_sign.is_max_sign ) )
                is_max_complete = 0;

            if ( !is_true( m_sign.is_ric_sign ) )
                is_ric_complete = 0;
        }
    }

    if ( a_signs_active.size == 3 )
    {
        if ( is_max_complete || is_ric_complete )
        {
            level.m_sq_start_sign = m_last_touched;
            level.e_sq_sign_attacker = e_attacker;
            level notify( "sq_sign_damaged" );
        }
    }
}

ts_is_bowie_knife( str_weapon )
{
    if ( str_weapon == "knife_ballistic_bowie_zm" || str_weapon == "knife_ballistic_bowie_upgraded_zm" || str_weapon == "bowie_knife_zm" )
        return true;

    return false;
}

ts_is_galvaknuckles( str_weapon )
{
    if ( str_weapon == "tazer_knuckles_zm" )
        return true;

    return false;
}
