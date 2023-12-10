// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_rewindobjects;

init( localclientnum )
{
    level._effect["fx_claymore_laser"] = loadfx( "weapon/claymore/fx_claymore_laser" );
}

spawned( localclientnum )
{
    self endon( "entityshutdown" );
    self waittill_dobj( localclientnum );

    while ( true )
    {
        if ( isdefined( self.stunned ) && self.stunned )
        {
            wait 0.1;
            continue;
        }

        self.claymorelaserfxid = playfxontag( localclientnum, level._effect["fx_claymore_laser"], self, "tag_fx" );
        self waittill( "stunned" );
        stopfx( localclientnum, self.claymorelaserfxid );
    }
}