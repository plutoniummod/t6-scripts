// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\zm_shared;

main()
{
    debug_anim_print( "dog_stop::main()" );
    self endon( "killanimscript" );
    self setaimanimweights( 0, 0 );
    self thread lookattarget( "attackIdle" );

    while ( true )
    {
        if ( shouldattackidle() )
        {
            self randomattackidle();
            maps\mp\animscripts\zm_shared::donotetracks( "attack_idle", ::dogidlenotetracks );
        }
        else
        {
            self set_orient_mode( "face current" );
            debug_anim_print( "dog_stop::main() - Setting stop_idle" );
            self notify( "stop tracking" );
            self setaimanimweights( 0, 0 );
            self setanimstatefromasd( "zm_stop_idle" );
            maps\mp\animscripts\zm_shared::donotetracksfortime( 0.2, "stop_idle", ::dogidlenotetracks );
            self thread lookattarget( "attackIdle" );
        }

        debug_anim_print( "dog_stop::main() - stop idle loop notify done." );
    }
}

dogidlenotetracks( note )
{
    if ( note == "breathe_fire" )
    {
        if ( isdefined( level._effect["dog_breath"] ) )
        {
            self.breath_fx = spawn( "script_model", self gettagorigin( "TAG_MOUTH_FX" ) );
            self.breath_fx.angles = self gettagangles( "TAG_MOUTH_FX" );
            self.breath_fx setmodel( "tag_origin" );
            self.breath_fx linkto( self, "TAG_MOUTH_FX" );
            playfxontag( level._effect["dog_breath"], self.breath_fx, "tag_origin" );
        }
    }
}

isfacingenemy( tolerancecosangle )
{
    assert( isdefined( self.enemy ) );
    vectoenemy = self.enemy.origin - self.origin;
    disttoenemy = length( vectoenemy );

    if ( disttoenemy < 1 )
        return 1;

    forward = anglestoforward( self.angles );
    val1 = forward[0] * vectoenemy[0] + forward[1] * vectoenemy[1];
    val2 = ( forward[0] * vectoenemy[0] + forward[1] * vectoenemy[1] ) / disttoenemy;
    return ( forward[0] * vectoenemy[0] + forward[1] * vectoenemy[1] ) / disttoenemy > tolerancecosangle;
}

randomattackidle()
{
    if ( isfacingenemy( -0.5 ) )
        self set_orient_mode( "face current" );
    else
        self set_orient_mode( "face enemy" );

    if ( should_growl() )
    {
        debug_anim_print( "dog_stop::main() - Setting stop_attackidle_growl" );
        self setanimstatefromasd( "zm_stop_attackidle_growl" );
        return;
    }

    idlechance = 33;
    barkchance = 66;

    if ( isdefined( self.mode ) )
    {
        if ( self.mode == "growl" )
        {
            idlechance = 15;
            barkchance = 30;
        }
        else if ( self.mode == "bark" )
        {
            idlechance = 15;
            barkchance = 85;
        }
    }

    rand = randomint( 100 );

    if ( rand < idlechance )
    {
        debug_anim_print( "dog_stop::main() - Setting stop_attackidle" );
        self setanimstatefromasd( "zm_stop_attackidle" );
    }
    else if ( rand < barkchance )
    {
        debug_anim_print( "dog_stop::main() - Setting stop_attackidle_bark " );
        self setanimstatefromasd( "zm_stop_attackidle_bark" );
    }
    else
    {
        debug_anim_print( "dog_stop::main() - Setting stop_attackidle_growl " );
        self setanimstatefromasd( "zm_stop_attackidle_growl" );
    }
}

shouldattackidle()
{
    return isdefined( self.enemy ) && isalive( self.enemy ) && distancesquared( self.origin, self.enemy.origin ) < 1000000;
}

should_growl()
{
    if ( isdefined( self.script_growl ) )
        return 1;

    if ( !isalive( self.enemy ) )
        return 1;

    return !self cansee( self.enemy );
}

lookattarget( lookposeset )
{
    self endon( "killanimscript" );
    self endon( "stop tracking" );
    debug_anim_print( "dog_stop::lookAtTarget() - Starting look at " + lookposeset );
    self.rightaimlimit = 90;
    self.leftaimlimit = -90;
    self.upaimlimit = 45;
    self.downaimlimit = -45;
    self maps\mp\animscripts\shared::setanimaimweight( 1, 0.2 );
    self maps\mp\animscripts\shared::trackloop();
}
