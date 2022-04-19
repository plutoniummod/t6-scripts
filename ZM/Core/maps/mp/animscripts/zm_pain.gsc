// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\animscripts\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\zm_utility;

main()
{
    self setflashbanged( 0 );

    if ( isdefined( self.longdeathstarting ) )
    {
        self waittill( "killanimscript" );

        return;
    }

    if ( self.a.disablepain )
        return;
}
