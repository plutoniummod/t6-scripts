// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;

init()
{
    level thread levelwatchforfakefire();
}

spawned( localclientnum )
{
    self thread watchforfakefire( localclientnum );
}

watchforfakefire( localclientnum )
{
    self endon( "entityshutdown" );

    while ( true )
    {
        self waittill( "fake_fire" );
        playfxontag( localclientnum, level._effect["decoy_fire"], self, "tag_origin" );
    }
}

levelwatchforfakefire()
{
    while ( true )
    {
        self waittill( "fake_fire", origin );
        playfx( 0, level._effect["decoy_fire"], origin );
    }
}
