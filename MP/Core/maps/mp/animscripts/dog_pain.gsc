// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\shared;

main()
{
    debug_anim_print( "dog_pain::main() " );
    self endon( "killanimscript" );
    self setaimanimweights( 0, 0 );

    if ( isdefined( self.enemy ) && isdefined( self.enemy.syncedmeleetarget ) && self.enemy.syncedmeleetarget == self )
    {
        self unlink();
        self.enemy.syncedmeleetarget = undefined;
    }

    speed = length( self getvelocity() );
    pain_anim = getanimdirection( self.damageyaw );

    if ( speed > level.dogrunpainspeed )
        pain_anim = "pain_run_" + pain_anim;
    else
        pain_anim = "pain_" + pain_anim;

    self setanimstate( pain_anim );
    self maps\mp\animscripts\shared::donotetracksfortime( 0.2, "done" );
}
