// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_rewindobjects;
#include clientscripts\mp\_fx;

init( localclientnum )
{
    level._effect["acousticsensor_enemy_light"] = loadfx( "misc/fx_equip_light_red" );
    level._effect["acousticsensor_friendly_light"] = loadfx( "misc/fx_equip_light_green" );

    if ( !isdefined( level.acousticsensors ) )
        level.acousticsensors = [];

    if ( !isdefined( level.acousticsensorhandle ) )
        level.acousticsensorhandle = 0;

    setlocalradarenabled( localclientnum, 0 );

    if ( localclientnum == 0 )
        level thread updateacousticsensors();
}

addacousticsensor( handle, sensorent, owner )
{
    acousticsensor = spawnstruct();
    acousticsensor.handle = handle;
    acousticsensor.sensorent = sensorent;
    acousticsensor.owner = owner;
    size = level.acousticsensors.size;
    level.acousticsensors[size] = acousticsensor;
}

removeacousticsensor( acousticsensorhandle )
{
    for ( i = 0; i < level.acousticsensors.size; i++ )
    {
        last = level.acousticsensors.size - 1;

        if ( level.acousticsensors[i].handle == acousticsensorhandle )
        {
            level.acousticsensors[i].handle = level.acousticsensors[last].handle;
            level.acousticsensors[i].sensorent = level.acousticsensors[last].sensorent;
            level.acousticsensors[i].owner = level.acousticsensors[last].owner;
            level.acousticsensors[last] = undefined;
            return;
        }
    }
}

spawned( localclientnum )
{
    handle = level.acousticsensorhandle;
    level.acousticsensorhandle++;
    self thread watchshutdown( handle );
    owner = self getowner( localclientnum );
    addacousticsensor( handle, self, owner );
    local_players_entity_thread( self, ::spawnedperclient );
}

spawnedperclient( localclientnum )
{
    self endon( "entityshutdown" );
    self thread clientscripts\mp\_fx::blinky_light( localclientnum, "tag_light", level._effect["acousticsensor_friendly_light"], level._effect["acousticsensor_enemy_light"] );
}

watchshutdown( handle )
{
    self waittill( "entityshutdown" );
    removeacousticsensor( handle );
}

updateacousticsensors()
{
    self endon( "entityshutdown" );
    localradarenabled = [];
    previousacousticsensorcount = -1;
    waitforclient( 0 );

    while ( true )
    {
        localplayers = level.localplayers;

        if ( previousacousticsensorcount != 0 || level.acousticsensors.size != 0 )
        {
            for ( i = 0; i < localplayers.size; i++ )
                localradarenabled[i] = 0;

            for ( i = 0; i < level.acousticsensors.size; i++ )
            {
                if ( isdefined( level.acousticsensors[i].sensorent.stunned ) && level.acousticsensors[i].sensorent.stunned )
                    continue;

                for ( j = 0; j < localplayers.size; j++ )
                {
                    if ( localplayers[j] == level.acousticsensors[i].sensorent getowner( j ) )
                    {
                        localradarenabled[j] = 1;
                        setlocalradarposition( j, level.acousticsensors[i].sensorent.origin );
                    }
                }
            }

            for ( i = 0; i < localplayers.size; i++ )
                setlocalradarenabled( i, localradarenabled[i] );
        }

        previousacousticsensorcount = level.acousticsensors.size;
        wait 0.1;
    }
}
