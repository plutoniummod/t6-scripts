// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\animscripts\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\animscripts\zm_melee;

main()
{
    self endon( "killanimscript" );
    self endon( "melee" );
    maps\mp\animscripts\zm_utility::initialize( "zombie_combat" );
    self animmode( "zonly_physics", 0 );

    if ( isdefined( self.combat_animmode ) )
        self [[ self.combat_animmode ]]();

    self orientmode( "face angle", self.angles[1] );

    for (;;)
    {
        if ( trymelee() )
            return;

        exposedwait();
    }
}

exposedwait()
{
    if ( !isdefined( self.can_always_see ) && ( !isdefined( self.enemy ) || !self cansee( self.enemy ) ) )
    {
        self endon( "enemy" );
        wait( 0.2 + randomfloat( 0.1 ) );
    }
    else if ( !isdefined( self.enemy ) )
    {
        self endon( "enemy" );
        wait( 0.2 + randomfloat( 0.1 ) );
    }
    else
        wait 0.05;
}

trymelee()
{
    if ( isdefined( self.cant_melee ) && self.cant_melee )
        return false;

    if ( !isdefined( self.enemy ) )
        return false;

    if ( distancesquared( self.origin, self.enemy.origin ) > 262144 )
        return false;

    canmelee = maps\mp\animscripts\zm_melee::canmeleedesperate();

    if ( !canmelee )
        return false;

    self thread maps\mp\animscripts\zm_melee::meleecombat();
    return true;
}
