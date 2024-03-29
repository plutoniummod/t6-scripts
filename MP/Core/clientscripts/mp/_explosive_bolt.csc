// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;

main()
{
    level._effect["crossbow_enemy_light"] = loadfx( "weapon/crossbow/fx_trail_crossbow_blink_red_os" );
    level._effect["crossbow_friendly_light"] = loadfx( "weapon/crossbow/fx_trail_crossbow_blink_grn_os" );
}

spawned( localclientnum )
{
    if ( self isgrenadedud() )
        return;

    self thread fx_think( localclientnum );
}

fx_think( localclientnum )
{
    self notify( "light_disable" );
    self endon( "entityshutdown" );
    self endon( "light_disable" );
    self waittill_dobj( localclientnum );
    interval = 0.3;

    for (;;)
    {
        self stop_light_fx( localclientnum );
        self start_light_fx( localclientnum );
        self fullscreen_fx( localclientnum );
        self playsound( localclientnum, "wpn_semtex_alert" );
        serverwait( localclientnum, interval, 0.01, "player_switch" );
        interval = clamp( interval / 1.2, 0.08, 0.3 );
    }
}

start_light_fx( localclientnum )
{
    friend = self friendnotfoe( localclientnum );
    player = getlocalplayer( localclientnum );

    if ( friend )
        self.fx = playfxontag( localclientnum, level._effect["crossbow_friendly_light"], self, "tag_origin" );
    else
        self.fx = playfxontag( localclientnum, level._effect["crossbow_enemy_light"], self, "tag_origin" );
}

stop_light_fx( localclientnum )
{
    if ( isdefined( self.fx ) && self.fx != 0 )
    {
        stopfx( localclientnum, self.fx );
        self.fx = undefined;
    }
}

fullscreen_fx( localclientnum )
{
    player = getlocalplayer( localclientnum );

    if ( isdefined( player ) )
    {
        if ( player getinkillcam( localclientnum ) )
            return;
        else if ( player isplayerviewlinkedtoentity( localclientnum ) )
            return;
    }

    if ( self friendnotfoe( localclientnum ) )
        return;

    parent = self getparententity();

    if ( isdefined( parent ) && parent == player )
    {
        parent playrumbleonentity( localclientnum, "buzz_high" );

        if ( issplitscreen() )
        {
            animateui( localclientnum, "sticky_grenade_overlay_ss" + localclientnum, "overlay", "pulse", 0 );

            if ( getdvarint( #"ui_hud_hardcore" ) == 0 )
                animateui( localclientnum, "stuck_ss" + localclientnum, "explosive_bolt", "pulse", 0 );
        }
        else
        {
            animateui( localclientnum, "sticky_grenade_overlay" + localclientnum, "overlay", "pulse", 0 );

            if ( getdvarint( #"ui_hud_hardcore" ) == 0 )
                animateui( localclientnum, "stuck" + localclientnum, "explosive_bolt", "pulse", 0 );
        }
    }
}
