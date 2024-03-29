// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_utility;

precache()
{

}

init()
{
    register_sloth_client_fields();
    level._effect["fx_zmb_taser_vomit"] = loadfx( "maps/zombie/fx_zmb_taser_vomit" );
    level._effect["fx_buried_sloth_building"] = loadfx( "maps/zombie_buried/fx_buried_sloth_building" );
    level._effect["fx_buried_sloth_drinking"] = loadfx( "maps/zombie_buried/fx_buried_sloth_drinking" );
    level._effect["fx_buried_sloth_eating"] = loadfx( "maps/zombie_buried/fx_buried_sloth_eating" );
    level._effect["fx_buried_sloth_glass_brk"] = loadfx( "maps/zombie_buried/fx_buried_sloth_glass_brk" );
}

register_sloth_client_fields()
{
    registerclientfield( "actor", "actor_is_sloth", 12000, 1, "int", ::actor_is_sloth_handler_cb, 0, 0 );
    registerclientfield( "actor", "sloth_berserk", 12000, 1, "int", ::sloth_berserk_cb, 1 );
    registerclientfield( "actor", "sloth_ragdoll_zombie", 12000, 1, "int", ::sloth_ragdoll_zombie_cb, 0 );
    registerclientfield( "actor", "sloth_vomit", 12000, 1, "int", ::sloth_vomit_cb, 0 );
    registerclientfield( "actor", "sloth_buildable", 12000, 1, "int", ::sloth_buildable_cb, 0 );
    registerclientfield( "actor", "sloth_drinking", 12000, 1, "int", ::sloth_drinking_cb, 0 );
    registerclientfield( "actor", "sloth_eating", 12000, 1, "int", ::sloth_eating_cb, 0 );
    registerclientfield( "actor", "sloth_glass_brk", 12000, 1, "int", ::sloth_glass_brk_cb, 0 );
}

sloth_berserk_cb( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval )
        level.sloth_berserk_origin = self.origin;
    else
        level.sloth_beserk_origin = undefined;
}

sloth_ragdoll_zombie_cb( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    p = level.sloth_beserk_origin;
    force_mul = 1;

    if ( !isdefined( p ) )
    {
        if ( isdefined( level._sloth_actor[localclientnum] ) )
        {
            p = level._sloth_actor[localclientnum].origin;
            force_mul = 1.5;
        }

        if ( !isdefined( p ) )
            return;
    }

    dir = self.origin - p;
    force = length( dir ) * force_mul;
    dir = vectornormalize( dir );
    launch = ( dir[0], dir[1], 0.15 );
    launch = vectorscale( launch, force );
    self launchragdoll( launch );
}

actor_is_sloth_handler_cb( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    level._sloth_actor[localclientnum] = self;
}

sloth_vomit_cb( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval )
        playfxontag( localclientnum, level._effect["fx_zmb_taser_vomit"], self, "j_neck" );
}

sloth_buildable_cb( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval )
        self thread loop_buildable_fx( localclientnum );
    else
        self notify( "stop_buildable" );
}

loop_buildable_fx( localclientnum )
{
    self endon( "entityshutdown" );
    self notify( "stop_buildable" );
    self endon( "stop_buildable" );
    level.benches = [];
    level.benches[level.benches.size] = "turbine_bench";
    level.benches[level.benches.size] = "subwoofer_bench";
    level.benches[level.benches.size] = "headchopper_bench";
    level.benches[level.benches.size] = "springpad_bench";
    closest_dist = undefined;
    closest = getent( localclientnum, level.benches[0], "targetname" );

    if ( isdefined( closest ) )
        closest_dist = distancesquared( self.origin, closest.origin );

    for ( i = 1; i < level.benches.size; i++ )
    {
        bench = getent( localclientnum, level.benches[i], "targetname" );

        if ( isdefined( bench ) )
        {
            dist = distancesquared( self.origin, bench.origin );

            if ( dist < closest_dist )
            {
                closest = bench;
                closest_dist = dist;
            }
        }
    }

    while ( true )
    {
        playfx( localclientnum, level._effect["fx_buried_sloth_building"], closest, "tag_origin" );
        wait 0.25;
    }
}

sloth_drinking_cb( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval )
        playfxontag( localclientnum, level._effect["fx_buried_sloth_drinking"], self, "j_head" );
}

sloth_eating_cb( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval )
        playfxontag( localclientnum, level._effect["fx_buried_sloth_eating"], self, "j_head" );
}

sloth_glass_brk_cb( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval )
        playfxontag( localclientnum, level._effect["fx_buried_sloth_glass_brk"], self, "tag_weapon_right" );
}
