// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_fx;
#include clientscripts\mp\_music;

init()
{
    if ( getdvar( #"createfx" ) == "on" )
        return;

    level._effect["lightning_miss"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_elec_ug_impact_miss" );
    level._effect["lightning_arc"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_elec_trail_bolt_cheap" );
    level._effect["lightning_impact"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_elec_ug_impact_hit_torso" );
    level._effect["tesla_shock_eyes"] = loadfx( "maps/zombie/fx_zombie_tesla_shock_eyes" );
    registerclientfield( "actor", "lightning_impact_fx", 14000, 1, "int", ::lightning_impact_play_fx );
    registerclientfield( "scriptmover", "lightning_miss_fx", 14000, 1, "int", ::lightning_miss_play_fx );
    registerclientfield( "actor", "lightning_arc_fx", 14000, 1, "int", ::lightning_arc_play_fx );
    level.lightning_ball_fx = [];
}

lightning_impact_play_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval )
    {
        playfxontag( localclientnum, level._effect["lightning_impact"], self, "J_SpineUpper" );
        self playsound( 0, "wpn_imp_lightningstaff" );
    }
}

lightning_miss_play_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval )
    {
        playfxontag( localclientnum, level._effect["lightning_miss"], self, "tag_origin" );
        level.lightning_ball_fx[localclientnum] = self;
        ent = spawn( 0, self.origin, "script_origin" );
        ent linkto( self );
        ent playloopsound( "wpn_lightningstaff_ball", 1 );
        self thread watch_ball_fx_killed( localclientnum, ent );
        level notify( "lightning_ball_created" );
    }
}

watch_ball_fx_killed( localclientnum, ent )
{
    self waittill( "entityshutdown" );
    ent stoploopsound( 1 );
    playsound( 0, "wpn_lightningstaff_ball_explo", ent.origin );
    ent delete();
    level.lightning_ball_fx[localclientnum] = undefined;
}

lightning_arc_play_fx_thread( localclientnum )
{
    self endon( "entityshutdown" );
    self endon( "stop_arc_fx" );

    if ( !isdefined( level.lightning_ball_fx[localclientnum] ) )
        level waittill( "lightning_ball_created" );

    e_ball = level.lightning_ball_fx[localclientnum];
    e_ball endon( "entityshutdown" );
    serverwait( localclientnum, randomfloatrange( 0.1, 0.5 ) );
    self.e_fx = spawn( localclientnum, e_ball.origin, "script_model" );
    self.e_fx setmodel( "tag_origin" );
    self.fx_arc = playfxontag( localclientnum, level._effect["lightning_arc"], self.e_fx, "tag_origin" );

    while ( true )
    {
        v_spine = self gettagorigin( "J_SpineUpper" );
        self.e_fx moveto( v_spine, 0.1 );
        serverwait( localclientnum, 0.5 );
        self.e_fx moveto( e_ball.origin, 0.1 );
        serverwait( localclientnum, 0.5 );
    }
}

lightning_arc_play_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval )
        self thread lightning_arc_play_fx_thread( localclientnum );
    else
    {
        self notify( "stop_arc_fx" );

        if ( isdefined( self.fx_arc ) )
        {
            stopfx( localclientnum, self.fx_arc );
            self.fx_arc = undefined;
        }

        if ( isdefined( self.e_fx ) )
        {
            self.e_fx delete();
            self.e_fx = undefined;
        }
    }
}
