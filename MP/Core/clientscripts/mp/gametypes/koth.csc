// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;

main()
{
    level.hardpoints = [];
    level.visuals = [];
    level.hardpointfx = [];
    registerclientfield( "world", "hardpoint", 1, 5, "int", ::hardpoint, 0 );
    level._effect["zoneEdgeMarker"] = loadfx( "maps/mp_maps/fx_mp_koth_marker_neutral_1" );
    level._effect["zoneEdgeMarkerWndw"] = loadfx( "maps/mp_maps/fx_mp_koth_marker_neutral_wndw" );
}

onprecachegametype()
{

}

hardpoint( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( level.hardpoints.size == 0 )
    {
        hardpoints = getstructarray( "koth_zone_center", "targetname" );

        foreach ( point in hardpoints )
            level.hardpoints[point.script_index] = point;

        foreach ( point in level.hardpoints )
            level.visuals[point.script_index] = getstructarray( point.target, "targetname" );

        if ( isdefined( level.overridemapdefinedhardpointsfunc ) )
            level [[ level.overridemapdefinedhardpointsfunc ]]();
    }

    if ( isdefined( level.hardpointfx[localclientnum] ) )
    {
        foreach ( fx in level.hardpointfx[localclientnum] )
            stopfx( localclientnum, fx );
    }

    level.hardpointfx[localclientnum] = [];

    if ( newval )
    {
        if ( isdefined( level.visuals[newval] ) )
        {
            foreach ( visual in level.visuals[newval] )
            {
                if ( !isdefined( visual.script_fxid ) )
                    continue;

                if ( isdefined( visual.angles ) )
                    forward = anglestoforward( visual.angles );
                else
                    forward = ( 0, 0, 0 );

                level.hardpointfx[localclientnum][level.hardpointfx[localclientnum].size] = playfx( localclientnum, level._effect[visual.script_fxid], visual.origin, forward );
            }
        }
    }
}
