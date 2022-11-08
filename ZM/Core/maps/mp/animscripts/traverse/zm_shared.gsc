// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\utility;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\animscripts\zm_run;

init_traverse()
{
    point = getent( self.target, "targetname" );

    if ( isdefined( point ) )
    {
        self.traverse_height = point.origin[2];
        point delete();
    }
    else
    {
        point = getstruct( self.target, "targetname" );

        if ( isdefined( point ) )
            self.traverse_height = point.origin[2];
    }
}

teleportthread( verticaloffset )
{
    self endon( "killanimscript" );
    self notify( "endTeleportThread" );
    self endon( "endTeleportThread" );
    reps = 5;
    offset = ( 0, 0, verticaloffset / reps );

    for ( i = 0; i < reps; i++ )
    {
        self teleport( self.origin + offset );
        wait 0.05;
    }
}

teleportthreadex( verticaloffset, delay, frames )
{
    self endon( "killanimscript" );
    self notify( "endTeleportThread" );
    self endon( "endTeleportThread" );

    if ( verticaloffset == 0 )
        return;

    wait( delay );
    amount = verticaloffset / frames;

    if ( amount > 10.0 )
        amount = 10.0;
    else if ( amount < -10.0 )
        amount = -10.0;

    offset = ( 0, 0, amount );

    for ( i = 0; i < frames; i++ )
    {
        self teleport( self.origin + offset );
        wait 0.05;
    }
}

handletraversealignment()
{
    self traversemode( "nogravity" );
    self traversemode( "noclip" );

    if ( isdefined( self.traverseheight ) && isdefined( self.traversestartnode.traverse_height ) )
    {
        currentheight = self.traversestartnode.traverse_height - self.traversestartz;
        self thread teleportthread( currentheight - self.traverseheight );
    }
}

dosimpletraverse( traversealias, no_powerups, traversestate = "zm_traverse" )
{
    if ( isdefined( level.ignore_traverse ) )
    {
        if ( self [[ level.ignore_traverse ]]() )
            return;
    }

    if ( isdefined( level.zm_traversal_override ) )
        traversealias = self [[ level.zm_traversal_override ]]( traversealias );

    if ( !self.has_legs )
    {
        traversestate += "_crawl";
        traversealias += "_crawl";
    }

    self dotraverse( traversestate, traversealias, no_powerups );
}

dotraverse( traversestate, traversealias, no_powerups )
{
    self endon( "killanimscript" );
    self traversemode( "nogravity" );
    self traversemode( "noclip" );
    old_powerups = 0;

    if ( isdefined( no_powerups ) && no_powerups )
    {
        old_powerups = self.no_powerups;
        self.no_powerups = 1;
    }

    self.is_traversing = 1;
    self notify( "zombie_start_traverse" );
    self.traversestartnode = self getnegotiationstartnode();
    assert( isdefined( self.traversestartnode ) );
    self orientmode( "face angle", self.traversestartnode.angles[1] );
    self.traversestartz = self.origin[2];

    if ( isdefined( self.pre_traverse ) )
        self [[ self.pre_traverse ]]();

    self setanimstatefromasd( traversestate, traversealias );
    self maps\mp\animscripts\zm_shared::donotetracks( "traverse_anim" );
    self traversemode( "gravity" );
    self.a.nodeath = 0;

    if ( isdefined( self.post_traverse ) )
        self [[ self.post_traverse ]]();

    self maps\mp\animscripts\zm_run::needsupdate();

    if ( !self.isdog )
        self maps\mp\animscripts\zm_run::moverun();

    self.is_traversing = 0;
    self notify( "zombie_end_traverse" );

    if ( isdefined( no_powerups ) && no_powerups )
        self.no_powerups = old_powerups;
}
