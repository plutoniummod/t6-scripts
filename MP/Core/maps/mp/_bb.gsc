// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
    level thread onplayerconnect();
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connected", player );

        player thread onplayerspawned();
        player thread onplayerdeath();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );
    self._bbdata = [];

    for (;;)
    {
        self waittill( "spawned_player" );

        self._bbdata["score"] = 0;
        self._bbdata["momentum"] = 0;
        self._bbdata["spawntime"] = gettime();
        self._bbdata["shots"] = 0;
        self._bbdata["hits"] = 0;
    }
}

onplayerdisconnect()
{
    for (;;)
    {
        self waittill( "disconnect" );

        self commitspawndata();
        break;
    }
}

onplayerdeath()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "death" );

        self commitspawndata();
    }
}

commitspawndata()
{
/#
    assert( isdefined( self._bbdata ) );
#/
    if ( !isdefined( self._bbdata ) )
        return;

    bbprint( "mpplayerlives", "gametime %d spawnid %d lifescore %d lifemomentum %d lifetime %d name %s", gettime(), getplayerspawnid( self ), self._bbdata["score"], self._bbdata["momentum"], gettime() - self._bbdata["spawntime"], self.name );
}

commitweapondata( spawnid, currentweapon, time0 )
{
/#
    assert( isdefined( self._bbdata ) );
#/
    if ( !isdefined( self._bbdata ) )
        return;

    time1 = gettime();
    bbprint( "mpweapons", "spawnid %d name %s duration %d shots %d hits %d", spawnid, currentweapon, time1 - time0, self._bbdata["shots"], self._bbdata["hits"] );
    self._bbdata["shots"] = 0;
    self._bbdata["hits"] = 0;
}

bbaddtostat( statname, delta )
{
    if ( isdefined( self._bbdata ) && isdefined( self._bbdata[statname] ) )
        self._bbdata[statname] += delta;
}
