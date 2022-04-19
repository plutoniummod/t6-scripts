// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_highrise_sq;
#include maps\mp\zm_highrise_sq_pts;

init()
{
    flag_init( "sq_slb_first_ball_sniped" );
    flag_init( "sq_slb_richtofen_spoke" );
    declare_sidequest_stage( "sq", "slb", ::init_stage, ::stage_logic, ::exit_stage_1 );
}

init_stage()
{
    level._cur_stage_name = "slb";
    clientnotify( "slb" );
    level thread vo_maxis_slb_hint();
}

stage_logic()
{
/#
    iprintlnbold( "SLB Started" );
#/
    snipe_balls_wait();
    stage_completed( "sq", level._cur_stage_name );
}

exit_stage_1( success )
{

}

snipe_balls_wait()
{
    a_balls = getentarray( "sq_dragon_lion_ball", "targetname" );
    array_thread( a_balls, ::snipe_balls_watch_ball );
    is_complete = 0;

    while ( !is_complete )
    {
        level waittill( "zm_ball_shot" );

        wait 1;
        is_complete = 1;

        foreach ( m_ball in a_balls )
        {
            if ( isdefined( m_ball ) )
                is_complete = 0;
        }
    }
/#
    iprintlnbold( "All Balls Shot" );
#/
}

snipe_balls_watch_ball()
{
    self endon( "delete" );
    a_snipers = array( "dsr50_zm", "dsr50_upgraded_zm+vzoom", "barretm82_zm", "barretm82_upgraded_zm+vzoom", "svu_zm", "svu_upgraded_zm+vzoom" );
    self setcandamage( 1 );

    while ( true )
    {
        self waittill( "damage", amount, attacker, direction, point, mod, tagname, modelname, partname, weaponname );

        if ( maps\mp\zm_highrise_sq::sq_is_weapon_sniper( weaponname ) )
        {
            level notify( "zm_ball_shot" );
            playsoundatposition( "zmb_sq_ball_ding", self.origin );
            playfx( level._effect["sidequest_flash"], self.origin );
            str_noteworthy = self.script_noteworthy;
            self delete();
            wait 0.5;
            clientnotify( str_noteworthy );
            m_ball = getent( "sq_sliquify_r", "script_noteworthy" );

            if ( str_noteworthy == "m_drg_tail" )
                m_ball = getent( "sq_sliquify_m", "script_noteworthy" );

            playfx( level._effect["sidequest_flash"], m_ball.origin );
            m_ball show();
            m_ball thread lion_ball_enable_pickup();

            if ( !flag( "sq_slb_first_ball_sniped" ) )
            {
                flag_set( "sq_slb_first_ball_sniped" );
                level thread vo_atd_ball1_sniped();
            }
            else
                level thread vo_maxis_atd_ball2_sniped();
        }
    }
}

lion_ball_enable_pickup()
{
    self endon( "sq_sliquified" );

    while ( true )
    {
        self.can_pickup = 1;
        self.t_pickup = sq_slb_create_use_trigger( self.origin, 32, 70, &"ZM_HIGHRISE_SQ_PICKUP_BALL" );

        while ( self.can_pickup )
        {
            self.t_pickup waittill( "trigger", player );

            if ( !isdefined( player.zm_sq_has_ball ) )
            {
                player.zm_sq_has_ball = 1;
                player.which_ball = self;
                self.can_pickup = 0;
                self.player = player;
                flag_set( "sq_ball_picked_up" );
                level thread maps\mp\zm_highrise_sq_pts::pts_should_player_create_trigs( player );
                level notify( "zm_ball_picked_up", player );
            }
        }

        self.t_pickup delete();
        self hide();
        self setcandamage( 0 );
        wait 1;
        self.t_putdown = sq_slb_create_use_trigger( self.origin, 16, 70, &"ZM_HIGHRISE_SQ_PUTDOWN_BALL" );
        self.player clientclaimtrigger( self.t_putdown );
        self.player.t_putdown_ball = self.t_putdown;
        self ball_pickup_waittill_change();
        play_spark = 0;

        if ( !isdefined( self.t_putdown ) )
        {
            self waittill( "sq_pickup_reset" );

            play_spark = 1;
        }
        else
            self.t_putdown delete();

        self.player notify( "zm_sq_ball_putdown" );

        if ( play_spark )
        {
            self.sq_pickup_reset = undefined;
            playfx( level._effect["sidequest_flash"], self.origin );
        }

        self show();
        self setcandamage( 1 );
        self.player.zm_sq_has_ball = undefined;
        self.player = undefined;
        wait 1;
    }
}

ball_pickup_waittill_change()
{
    self endon( "sq_pickup_reset" );
    self.t_putdown waittill_any_return( "trigger", "delete", "reset" );
}

sq_slb_create_use_trigger( v_origin, radius, height, str_hint_string )
{
    t_pickup = spawn( "trigger_radius_use", v_origin, 0, radius, height );
    t_pickup setcursorhint( "HINT_NOICON" );
    t_pickup sethintstring( str_hint_string );
    t_pickup.targetname = "ball_pickup_trig";
    t_pickup triggerignoreteam();
    t_pickup usetriggerrequirelookat();
    return t_pickup;
}

vo_richtofen_atd_ball_sniped()
{
    if ( !flag( "sq_slb_richtofen_spoke" ) )
    {
        flag_set( "sq_slb_richtofen_spoke" );
        maps\mp\zm_highrise_sq::richtofensay( "vox_zmba_sidequest_sec_symbols_4" );
    }
}

vo_maxis_slb_hint()
{
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_lion_balls_0" );
}

vo_maxis_atd_ball1_sniped()
{
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_lion_balls_1" );
}

vo_maxis_atd_ball2_sniped()
{
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_lion_balls_2" );
}

vo_atd_ball1_sniped()
{
    vo_richtofen_atd_ball_sniped();
    level thread vo_maxis_atd_ball1_sniped();
}
