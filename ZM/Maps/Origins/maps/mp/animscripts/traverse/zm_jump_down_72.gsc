// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\traverse\shared;
#include maps\mp\animscripts\traverse\zm_shared;

main()
{
    if ( isdefined( self.isdog ) && self.isdog )
        dog_jump_down( 72, 7 );
    else
        dosimpletraverse( "jump_down_72" );
}
