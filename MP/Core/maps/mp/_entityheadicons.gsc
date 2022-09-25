// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;

init()
{
    if ( isdefined( level.initedentityheadicons ) )
        return;

    if ( level.createfx_enabled )
        return;

    level.initedentityheadicons = 1;
    assert( isdefined( game["entity_headicon_allies"] ), "Allied head icons are not defined.  Check the team set for the level." );
    assert( isdefined( game["entity_headicon_axis"] ), "Axis head icons are not defined.  Check the team set for the level." );
    precacheshader( game["entity_headicon_allies"] );
    precacheshader( game["entity_headicon_axis"] );

    if ( !level.teambased )
        return;

    level.entitieswithheadicons = [];
}

setentityheadicon( team, owner, offset, icon, constant_size )
{
    if ( !level.teambased && !isdefined( owner ) )
        return;

    if ( !isdefined( constant_size ) )
        constant_size = 0;

    if ( !isdefined( self.entityheadiconteam ) )
    {
        self.entityheadiconteam = "none";
        self.entityheadicons = [];
    }

    if ( level.teambased && !isdefined( owner ) )
    {
        if ( team == self.entityheadiconteam )
            return;

        self.entityheadiconteam = team;
    }

    if ( isdefined( offset ) )
        self.entityheadiconoffset = offset;
    else
        self.entityheadiconoffset = ( 0, 0, 0 );

    if ( isdefined( self.entityheadicons ) )
    {
        for ( i = 0; i < self.entityheadicons.size; i++ )
        {
            if ( isdefined( self.entityheadicons[i] ) )
                self.entityheadicons[i] destroy();
        }
    }

    self.entityheadicons = [];
    self notify( "kill_entity_headicon_thread" );

    if ( !isdefined( icon ) )
        icon = game["entity_headicon_" + team];

    if ( isdefined( owner ) && !level.teambased )
    {
        if ( !isplayer( owner ) )
        {
            assert( isdefined( owner.owner ), "entity has to have an owner if it's not a player" );
            owner = owner.owner;
        }

        owner updateentityheadclienticon( self, icon, constant_size );
    }
    else if ( isdefined( owner ) && team != "none" )
        owner updateentityheadteamicon( self, team, icon, constant_size );

    self thread destroyheadiconsondeath();
}

updateentityheadteamicon( entity, team, icon, constant_size )
{
    headicon = newteamhudelem( team );
    headicon.archived = 1;
    headicon.x = entity.entityheadiconoffset[0];
    headicon.y = entity.entityheadiconoffset[1];
    headicon.z = entity.entityheadiconoffset[2];
    headicon.alpha = 0.8;
    headicon setshader( icon, 6, 6 );
    headicon setwaypoint( constant_size );
    headicon settargetent( entity );
    entity.entityheadicons[entity.entityheadicons.size] = headicon;
}

updateentityheadclienticon( entity, icon, constant_size )
{
    headicon = newclienthudelem( self );
    headicon.archived = 1;
    headicon.x = entity.entityheadiconoffset[0];
    headicon.y = entity.entityheadiconoffset[1];
    headicon.z = entity.entityheadiconoffset[2];
    headicon.alpha = 0.8;
    headicon setshader( icon, 6, 6 );
    headicon setwaypoint( constant_size );
    headicon settargetent( entity );
    entity.entityheadicons[entity.entityheadicons.size] = headicon;
}

destroyheadiconsondeath()
{
    self waittill_any( "death", "hacked" );

    for ( i = 0; i < self.entityheadicons.size; i++ )
    {
        if ( isdefined( self.entityheadicons[i] ) )
            self.entityheadicons[i] destroy();
    }
}

destroyentityheadicons()
{
    if ( isdefined( self.entityheadicons ) )
    {
        for ( i = 0; i < self.entityheadicons.size; i++ )
        {
            if ( isdefined( self.entityheadicons[i] ) )
                self.entityheadicons[i] destroy();
        }
    }
}

updateentityheadiconpos( headicon )
{
    headicon.x = self.origin[0] + self.entityheadiconoffset[0];
    headicon.y = self.origin[1] + self.entityheadiconoffset[1];
    headicon.z = self.origin[2] + self.entityheadiconoffset[2];
}
