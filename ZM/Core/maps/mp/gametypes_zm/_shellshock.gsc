// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
    precacheshellshock( "frag_grenade_mp" );
    precacheshellshock( "damage_mp" );
    precacherumble( "artillery_rumble" );
    precacherumble( "grenade_rumble" );
}

shellshockondamage( cause, damage )
{
    if ( cause == "MOD_EXPLOSIVE" || cause == "MOD_GRENADE" || cause == "MOD_GRENADE_SPLASH" || cause == "MOD_PROJECTILE" || cause == "MOD_PROJECTILE_SPLASH" )
    {
        time = 0;

        if ( damage >= 90 )
            time = 4;
        else if ( damage >= 50 )
            time = 3;
        else if ( damage >= 25 )
            time = 2;
        else if ( damage > 10 )
            time = 2;

        if ( time )
        {
            if ( self mayapplyscreeneffect() )
                self shellshock( "frag_grenade_mp", 0.5 );
        }
    }
}

endondeath()
{
    self waittill( "death" );

    waittillframeend;
    self notify( "end_explode" );
}

endontimer( timer )
{
    self endon( "disconnect" );
    wait( timer );
    self notify( "end_on_timer" );
}

rcbomb_earthquake( position )
{
    playrumbleonposition( "grenade_rumble", position );
    earthquake( 0.5, 0.5, self.origin, 512 );
}
