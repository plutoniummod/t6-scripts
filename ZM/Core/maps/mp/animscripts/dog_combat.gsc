// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\animscripts\shared;
#include maps\mp\animscripts\utility;

main()
{
    debug_anim_print( "dog_combat::main() " );
    self endon( "killanimscript" );
    self setaimanimweights( 0, 0 );
/#
    if ( !debug_allow_combat() )
    {
        combatidle();
        return;
    }
#/
    if ( isdefined( level.hostmigrationtimer ) )
    {
        combatidle();
        return;
    }

    assert( isdefined( self.enemy ) );

    if ( !isalive( self.enemy ) )
    {
        combatidle();
        return;
    }

    if ( isplayer( self.enemy ) )
        self meleebiteattackplayer( self.enemy );
}

combatidle()
{
    self set_orient_mode( "face enemy" );
    self animmode( "zonly_physics", 0 );
    idleanims = [];
    idleanims[0] = "combat_attackidle";
    idleanims[1] = "combat_attackidle_bark";
    idleanims[2] = "combat_attackidle_growl";
    idleanim = random( idleanims );
    debug_anim_print( "dog_combat::combatIdle() - Setting " + idleanim );
    self setanimstate( idleanim );
    self maps\mp\animscripts\shared::donotetracks( "done" );
    debug_anim_print( "dog_combat::combatIdle() - " + idleanim + " notify done." );
}

meleebiteattackplayer( player )
{
    self set_orient_mode( "face enemy" );
    self animmode( "gravity", 0 );
    self.safetochangescript = 0;

    if ( use_low_attack() )
    {
        self animmode( "angle deltas", 0 );
        self setanimstate( "combat_attack_player_close_range" );
        wait 0.35;

        if ( isplayer( self.enemy ) && self.enemy getstance() == "prone" )
            self meleewithoffset( vectorscale( ( 0, 0, -1 ), 9.0 ) );
        else
            self melee();

        self maps\mp\animscripts\shared::donotetracksfortime( 1.2, "done" );
        self animmode( "gravity", 0 );
    }
    else
    {
        attack_time = 1.2 + randomfloat( 0.4 );
        debug_anim_print( "dog_combat::meleeBiteAttackPlayer() - Setting  combat_run_attack" );
        self setanimstate( "combat_attack_run" );
        self maps\mp\animscripts\shared::donotetracksfortime( attack_time, "done", ::handlemeleebiteattacknotetracks, player );
        debug_anim_print( "dog_combat::meleeBiteAttackPlayer() - combat_attack_run notify done." );
    }

    self.safetochangescript = 1;
    self animmode( "none", 0 );
}

handlemeleebiteattacknotetracks( note, player )
{
    if ( note == "dog_melee" )
        self melee( anglestoforward( self.angles ) );
}

use_low_attack()
{
    if ( isplayer( self.enemy ) )
    {
        if ( self.enemy getstance() == "prone" )
        {
            attack_height = self.origin[2] + 16;

            if ( self.enemy.origin[2] < attack_height )
                return true;
        }
    }

    return false;
}
