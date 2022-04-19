// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\gametypes\_globallogic_utils;
#include maps\mp\gametypes\_deathicons;

init()
{
    if ( !isdefined( level.ragdoll_override ) )
        level.ragdoll_override = ::ragdoll_override;

    if ( !level.teambased )
        return;

    precacheshader( "headicon_dead" );
    level thread onplayerconnect();
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player.selfdeathicons = [];
    }
}

updatedeathiconsenabled()
{

}

adddeathicon( entity, dyingplayer, team, timeout )
{
    if ( !level.teambased )
        return;

    iconorg = entity.origin;
    dyingplayer endon( "spawned_player" );
    dyingplayer endon( "disconnect" );
    wait 0.05;
    maps\mp\gametypes\_globallogic_utils::waittillslowprocessallowed();
/#
    assert( isdefined( level.teams[team] ) );
#/
    if ( getdvar( _hash_F83E8105 ) == "0" )
        return;

    if ( level.hardcoremode )
        return;

    if ( isdefined( self.lastdeathicon ) )
        self.lastdeathicon destroy();

    newdeathicon = newteamhudelem( team );
    newdeathicon.x = iconorg[0];
    newdeathicon.y = iconorg[1];
    newdeathicon.z = iconorg[2] + 54;
    newdeathicon.alpha = 0.61;
    newdeathicon.archived = 1;

    if ( level.splitscreen )
        newdeathicon setshader( "headicon_dead", 14, 14 );
    else
        newdeathicon setshader( "headicon_dead", 7, 7 );

    newdeathicon setwaypoint( 1 );
    self.lastdeathicon = newdeathicon;
    newdeathicon thread destroyslowly( timeout );
}

destroyslowly( timeout )
{
    self endon( "death" );
    wait( timeout );
    self fadeovertime( 1.0 );
    self.alpha = 0;
    wait 1.0;
    self destroy();
}

ragdoll_override( idamage, smeansofdeath, sweapon, shitloc, vdir, vattackerorigin, deathanimduration, einflictor, ragdoll_jib, body )
{
    if ( smeansofdeath == "MOD_FALLING" && self isonground() == 1 )
    {
        body startragdoll();

        if ( !isdefined( self.switching_teams ) )
            thread maps\mp\gametypes\_deathicons::adddeathicon( body, self, self.team, 5.0 );

        return true;
    }

    return false;
}
