// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_utility;

init()
{
    if ( level.createfx_enabled )
        return;

    level._effect["lght_marker"] = loadfx( "maps/zombie_tomb/fx_tomb_marker" );
    level._effect["lght_marker_flare"] = loadfx( "maps/zombie/fx_zmb_tranzit_marker_fl" );
    level._effect["box_powered"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_on" );
    level._effect["box_unpowered"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_off" );
    level._effect["box_gone_ambient"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_amb_base" );
    level._effect["box_here_ambient"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_amb_slab" );
    level._effect["box_is_open"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_open" );
    level._effect["box_portal"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_portal" );
    level._effect["box_is_leaving"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_leave" );
    registerclientfield( "zbarrier", "magicbox_initial_fx", 2000, 1, "int", ::magicbox_initial_closed_fx );
    registerclientfield( "zbarrier", "magicbox_amb_fx", 2000, 2, "int", ::magicbox_ambient_fx );
    registerclientfield( "zbarrier", "magicbox_open_fx", 2000, 1, "int", ::magicbox_open_fx );
    registerclientfield( "zbarrier", "magicbox_leaving_fx", 2000, 1, "int", ::magicbox_leaving_fx );
}

magicbox_leaving_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( !isdefined( self.fx_obj ) )
    {
        self.fx_obj = spawn( localclientnum, self.origin, "script_model" );
        self.fx_obj.angles = self.angles;
        self.fx_obj setmodel( "tag_origin" );
    }

    if ( newval == 1 )
        self.fx_obj.curr_leaving_fx = playfxontag( localclientnum, level._effect["box_is_leaving"], self.fx_obj, "tag_origin" );
}

magicbox_open_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( !isdefined( self.fx_obj ) )
    {
        self.fx_obj = spawn( localclientnum, self.origin, "script_model" );
        self.fx_obj.angles = self.angles;
        self.fx_obj setmodel( "tag_origin" );
    }

    if ( !isdefined( self.fx_obj_2 ) )
    {
        self.fx_obj_2 = spawn( localclientnum, self.origin, "script_model" );
        self.fx_obj_2.angles = self.angles;
        self.fx_obj_2 setmodel( "tag_origin" );
    }

    if ( newval == 0 )
    {
        stopfx( localclientnum, self.fx_obj.curr_open_fx );
        self.fx_obj_2 stoploopsound( 1 );
        self notify( "magicbox_portal_finished" );
    }
    else if ( newval == 1 )
    {
        self.fx_obj.curr_open_fx = playfxontag( localclientnum, level._effect["box_is_open"], self.fx_obj, "tag_origin" );
        self.fx_obj_2 playloopsound( "zmb_hellbox_open_effect" );
        self thread fx_magicbox_portal( localclientnum );
    }
}

fx_magicbox_portal( localclientnum )
{
    self endon( "magicbox_portal_finished" );
    wait 0.5;

    while ( true )
    {
        self.fx_obj_2.curr_portal_fx = playfxontag( localclientnum, level._effect["box_portal"], self.fx_obj_2, "tag_origin" );
        wait 0.1;
    }
}

magicbox_initial_closed_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( !isdefined( self.fx_obj ) )
    {
        self.fx_obj = spawn( localclientnum, self.origin, "script_model" );
        self.fx_obj.angles = self.angles;
        self.fx_obj setmodel( "tag_origin" );
    }
    else
        return;

    if ( newval == 1 )
        self.fx_obj playloopsound( "zmb_hellbox_amb_low" );
}

magicbox_ambient_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( !isdefined( self.fx_obj ) )
    {
        self.fx_obj = spawn( localclientnum, self.origin, "script_model" );
        self.fx_obj.angles = self.angles;
        self.fx_obj setmodel( "tag_origin" );
    }

    if ( isdefined( self.fx_obj.curr_amb_fx ) )
        stopfx( localclientnum, self.fx_obj.curr_amb_fx );

    if ( isdefined( self.fx_obj.curr_amb_fx_power ) )
        stopfx( localclientnum, self.fx_obj.curr_amb_fx_power );

    if ( newval == 0 )
    {
        self.fx_obj playloopsound( "zmb_hellbox_amb_low" );
        playsound( 0, "zmb_hellbox_leave", self.fx_obj.origin );
        stopfx( localclientnum, self.fx_obj.curr_amb_fx );
    }
    else if ( newval == 1 )
    {
        self.fx_obj.curr_amb_fx_power = playfxontag( localclientnum, level._effect["box_unpowered"], self.fx_obj, "tag_origin" );
        self.fx_obj.curr_amb_fx = playfxontag( localclientnum, level._effect["box_here_ambient"], self.fx_obj, "tag_origin" );
        self.fx_obj playloopsound( "zmb_hellbox_amb_low" );
        playsound( 0, "zmb_hellbox_arrive", self.fx_obj.origin );
    }
    else if ( newval == 2 )
    {
        self.fx_obj.curr_amb_fx_power = playfxontag( localclientnum, level._effect["box_powered"], self.fx_obj, "tag_origin" );
        self.fx_obj.curr_amb_fx = playfxontag( localclientnum, level._effect["box_here_ambient"], self.fx_obj, "tag_origin" );
        self.fx_obj playloopsound( "zmb_hellbox_amb_high" );
        playsound( 0, "zmb_hellbox_arrive", self.fx_obj.origin );
    }
    else if ( newval == 3 )
    {
        self.fx_obj.curr_amb_fx_power = playfxontag( localclientnum, level._effect["box_unpowered"], self.fx_obj, "tag_origin" );
        self.fx_obj.curr_amb_fx = playfxontag( localclientnum, level._effect["box_gone_ambient"], self.fx_obj, "tag_origin" );
        self.fx_obj playloopsound( "zmb_hellbox_amb_high" );
        playsound( 0, "zmb_hellbox_leave", self.fx_obj.origin );
    }
}
