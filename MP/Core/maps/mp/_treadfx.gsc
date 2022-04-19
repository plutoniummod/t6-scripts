// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

loadtreadfx( vehicle )
{
    treadfx = vehicle.treadfxnamearray;

    if ( isdefined( treadfx ) )
    {
        vehicle.treadfx = [];

        if ( isdefined( treadfx["asphalt"] ) && treadfx["asphalt"] != "" )
            vehicle.treadfx["asphalt"] = loadfx( treadfx["asphalt"] );

        if ( isdefined( treadfx["bark"] ) && treadfx["bark"] != "" )
            vehicle.treadfx["bark"] = loadfx( treadfx["bark"] );

        if ( isdefined( treadfx["brick"] ) && treadfx["brick"] != "" )
            vehicle.treadfx["brick"] = loadfx( treadfx["brick"] );

        if ( isdefined( treadfx["carpet"] ) && treadfx["carpet"] != "" )
            vehicle.treadfx["carpet"] = loadfx( treadfx["carpet"] );

        if ( isdefined( treadfx["ceramic"] ) && treadfx["ceramic"] != "" )
            vehicle.treadfx["ceramic"] = loadfx( treadfx["ceramic"] );

        if ( isdefined( treadfx["cloth"] ) && treadfx["cloth"] != "" )
            vehicle.treadfx["cloth"] = loadfx( treadfx["cloth"] );

        if ( isdefined( treadfx["concrete"] ) && treadfx["concrete"] != "" )
            vehicle.treadfx["concrete"] = loadfx( treadfx["concrete"] );

        if ( isdefined( treadfx["cushion"] ) && treadfx["cushion"] != "" )
            vehicle.treadfx["cushion"] = loadfx( treadfx["cushion"] );

        if ( isdefined( treadfx["none"] ) && treadfx["none"] != "" )
            vehicle.treadfx["none"] = loadfx( treadfx["none"] );

        if ( isdefined( treadfx["dirt"] ) && treadfx["dirt"] != "" )
            vehicle.treadfx["dirt"] = loadfx( treadfx["dirt"] );

        if ( isdefined( treadfx["flesh"] ) && treadfx["flesh"] != "" )
            vehicle.treadfx["flesh"] = loadfx( treadfx["flesh"] );

        if ( isdefined( treadfx["foliage"] ) && treadfx["foliage"] != "" )
            vehicle.treadfx["foliage"] = loadfx( treadfx["foliage"] );

        if ( isdefined( treadfx["fruit"] ) && treadfx["fruit"] != "" )
            vehicle.treadfx["fruit"] = loadfx( treadfx["fruit"] );

        if ( isdefined( treadfx["glass"] ) && treadfx["glass"] != "" )
            vehicle.treadfx["glass"] = loadfx( treadfx["glass"] );

        if ( isdefined( treadfx["grass"] ) && treadfx["grass"] != "" )
            vehicle.treadfx["grass"] = loadfx( treadfx["grass"] );

        if ( isdefined( treadfx["gravel"] ) && treadfx["gravel"] != "" )
            vehicle.treadfx["gravel"] = loadfx( treadfx["gravel"] );

        if ( isdefined( treadfx["metal"] ) && treadfx["metal"] != "" )
            vehicle.treadfx["metal"] = loadfx( treadfx["metal"] );

        if ( isdefined( treadfx["mud"] ) && treadfx["mud"] != "" )
            vehicle.treadfx["mud"] = loadfx( treadfx["mud"] );

        if ( isdefined( treadfx["paintedmetal"] ) && treadfx["paintedmetal"] != "" )
            vehicle.treadfx["paintedmetal"] = loadfx( treadfx["paintedmetal"] );

        if ( isdefined( treadfx["paper"] ) && treadfx["paper"] != "" )
            vehicle.treadfx["paper"] = loadfx( treadfx["paper"] );

        if ( isdefined( treadfx["plaster"] ) && treadfx["plaster"] != "" )
            vehicle.treadfx["plaster"] = loadfx( treadfx["plaster"] );

        if ( isdefined( treadfx["plastic"] ) && treadfx["plastic"] != "" )
            vehicle.treadfx["plastic"] = loadfx( treadfx["plastic"] );

        if ( isdefined( treadfx["rock"] ) && treadfx["rock"] != "" )
            vehicle.treadfx["rock"] = loadfx( treadfx["rock"] );

        if ( isdefined( treadfx["rubber"] ) && treadfx["rubber"] != "" )
            vehicle.treadfx["rubber"] = loadfx( treadfx["rubber"] );

        if ( isdefined( treadfx["sand"] ) && treadfx["sand"] != "" )
            vehicle.treadfx["sand"] = loadfx( treadfx["sand"] );

        if ( isdefined( treadfx["water"] ) && treadfx["water"] != "" )
            vehicle.treadfx["water"] = loadfx( treadfx["water"] );

        if ( isdefined( treadfx["wood"] ) && treadfx["wood"] != "" )
            vehicle.treadfx["wood"] = loadfx( treadfx["wood"] );
    }
}

preloadtreadfx( vehicle )
{
    treadfx = getvehicletreadfxarray( vehicle );

    for ( i = 0; i < treadfx.size; i++ )
        loadfx( treadfx[i] );
}
