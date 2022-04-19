// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.coptermodel = "vehicle_cobra_helicopter_fly";
    precachemodel( level.coptermodel );
    level.copter_maxaccel = 200;
    level.copter_maxvel = 700;
    level.copter_rotspeed = 90;
    level.copter_accellookahead = 2;
    level.coptercenteroffset = vectorscale( ( 0, 0, 1 ), 72.0 );
    level.coptertargetoffset = vectorscale( ( 0, 0, 1 ), 45.0 );
    level.copterexplosion = loadfx( "explosions/fx_default_explosion" );
    level.copterfinalexplosion = loadfx( "explosions/fx_large_vehicle_explosion" );
}

getabovebuildingslocation( location )
{
    trace = bullettrace( location + vectorscale( ( 0, 0, 1 ), 10000.0 ), location, 0, undefined );
    startorigin = trace["position"] + vectorscale( ( 0, 0, -1 ), 514.0 );
    zpos = 0;
    maxxpos = 13;
    maxypos = 13;

    for ( xpos = 0; xpos < maxxpos; xpos++ )
    {
        for ( ypos = 0; ypos < maxypos; ypos++ )
        {
            thisstartorigin = startorigin + ( ( xpos / ( maxxpos - 1 ) - 0.5 ) * 1024, ( ypos / ( maxypos - 1 ) - 0.5 ) * 1024, 0 );
            thisorigin = bullettrace( thisstartorigin, thisstartorigin + vectorscale( ( 0, 0, -1 ), 10000.0 ), 0, undefined );
            zpos += thisorigin["position"][2];
        }
    }

    zpos /= maxxpos * maxypos;
    zpos += 850;
    return ( location[0], location[1], zpos );
}

vectorangle( v1, v2 )
{
    dot = vectordot( v1, v2 );

    if ( dot >= 1 )
        return 0;
    else if ( dot <= -1 )
        return 180;

    return acos( dot );
}

vectortowardsothervector( v1, v2, angle )
{
    dot = vectordot( v1, v2 );

    if ( dot <= -1 )
        return v1;

    v3 = vectornormalize( v2 - vectorscale( v1, dot ) );
    return vectorscale( v1, cos( angle ) ) + vectorscale( v3, sin( angle ) );
}

veclength( v )
{
    return distance( ( 0, 0, 0 ), v );
}

createcopter( location, team, damagetrig )
{
    location = getabovebuildingslocation( location );
    scriptorigin = spawn( "script_origin", location );
    scriptorigin.angles = vectortoangles( ( 1, 0, 0 ) );
    copter = spawn( "script_model", location );
    copter.angles = vectortoangles( ( 0, 1, 0 ) );
    copter linkto( scriptorigin );
    scriptorigin.copter = copter;
    copter setmodel( level.coptermodel );
    copter playloopsound( "mp_copter_ambience" );
    damagetrig.origin = scriptorigin.origin;
    damagetrig thread mylinkto( scriptorigin );
    scriptorigin.damagetrig = damagetrig;
    scriptorigin.finaldest = location;
    scriptorigin.finalzdest = location[2];
    scriptorigin.desireddir = ( 1, 0, 0 );
    scriptorigin.desireddirentity = undefined;
    scriptorigin.desireddirentityoffset = ( 0, 0, 0 );
    scriptorigin.vel = ( 0, 0, 0 );
    scriptorigin.dontascend = 0;
    scriptorigin.health = 2000;

    if ( getdvar( _hash_A8262D2E ) != "" )
        scriptorigin.health = getdvarfloat( _hash_A8262D2E );

    scriptorigin.team = team;
    scriptorigin thread copterai();
    scriptorigin thread copterdamage( damagetrig );
    return scriptorigin;
}

makecopterpassive()
{
    self.damagetrig notify( "unlink" );
    self.damagetrig = undefined;
    self notify( "passive" );
    self.desireddirentity = undefined;
    self.desireddir = undefined;
}

makecopteractive( damagetrig )
{
    damagetrig.origin = self.origin;
    damagetrig thread mylinkto( self );
    self.damagetrig = damagetrig;
    self thread copterai();
    self thread copterdamage( damagetrig );
}

mylinkto( obj )
{
    self endon( "unlink" );

    while ( true )
    {
        self.angles = obj.angles;
        self.origin = obj.origin;
        wait 0.1;
    }
}

setcopterdefensearea( areaent )
{
    self.areaent = areaent;
    self.areadescentpoints = [];

    if ( isdefined( areaent.target ) )
        self.areadescentpoints = getentarray( areaent.target, "targetname" );

    for ( i = 0; i < self.areadescentpoints.size; i++ )
        self.areadescentpoints[i].targetent = getent( self.areadescentpoints[i].target, "targetname" );
}

copterai()
{
    self thread coptermove();
    self thread coptershoot();
    self endon( "death" );
    self endon( "passive" );
    flying = 1;
    descendingent = undefined;
    reacheddescendingent = 0;
    returningtoarea = 0;

    while ( true )
    {
        if ( !isdefined( self.areaent ) )
        {
            wait 1;
            continue;
        }

        players = level.players;
        enemytargets = [];

        if ( self.team != "neutral" )
        {
            for ( i = 0; i < players.size; i++ )
            {
                if ( isalive( players[i] ) && isdefined( players[i].pers["team"] ) && players[i].pers["team"] != self.team && !isdefined( players[i].usingobj ) )
                {
                    playerorigin = players[i].origin;
                    playerorigin = ( playerorigin[0], playerorigin[1], self.areaent.origin[2] );

                    if ( distance( playerorigin, self.areaent.origin ) < self.areaent.radius )
                        enemytargets[enemytargets.size] = players[i];
                }
            }
        }

        insidetargets = [];
        outsidetargets = [];
        skyheight = bullettrace( self.origin, self.origin + vectorscale( ( 0, 0, 1 ), 10000.0 ), 0, undefined )["position"][2] - 10;
        besttarget = undefined;
        bestweight = 0;

        for ( i = 0; i < enemytargets.size; i++ )
        {
            inside = 0;
            trace = bullettrace( enemytargets[i].origin + vectorscale( ( 0, 0, 1 ), 10.0 ), enemytargets[i].origin + vectorscale( ( 0, 0, 1 ), 10000.0 ), 0, undefined );

            if ( trace["position"][2] >= skyheight )
            {
                outsidetargets[outsidetargets.size] = enemytargets[i];
                continue;
            }

            insidetargets[insidetargets.size] = enemytargets[i];
        }

        gotopos = undefined;
        calcedgotopos = 0;
        olddescendingent = undefined;

        if ( flying )
        {
            if ( outsidetargets.size == 0 && insidetargets.size > 0 && self.areadescentpoints.size > 0 )
            {
                flying = 0;
                result = determinebestent( insidetargets, self.areadescentpoints, self.origin );
                descendingent = result["descendEnt"];

                if ( isdefined( descendingent ) )
                    gotopos = result["position"];
                else
                    flying = 1;
            }
        }
        else
        {
            olddescendingent = descendingent;

            if ( insidetargets.size == 0 )
                flying = 1;
            else
            {
                if ( outsidetargets.size > 0 )
                {
                    if ( !isdefined( descendingent ) )
                        flying = 1;
                    else
                    {
                        calcedgotopos = 1;
                        gotopos = determinebestpos( insidetargets, descendingent, self.origin );

                        if ( !isdefined( gotopos ) )
                            flying = 1;
                    }
                }

                if ( isdefined( descendingent ) )
                {
                    if ( !calcedgotopos )
                        gotopos = determinebestpos( insidetargets, descendingent, self.origin );
                }

                if ( !isdefined( gotopos ) )
                {
                    result = determinebestent( insidetargets, self.areadescentpoints, self.origin );

                    if ( isdefined( result["descendEnt"] ) )
                    {
                        descendingent = result["descendEnt"];
                        gotopos = result["position"];
                        reacheddescendingent = 0;
                    }
                    else if ( isdefined( descendingent ) )
                    {
                        if ( isdefined( self.finaldest ) )
                            gotopos = self.finaldest;
                        else
                            gotopos = descendingent.origin;
                    }
                    else
                        gotopos = undefined;
                }

                if ( !isdefined( gotopos ) )
                    flying = 1;
            }
        }

        if ( flying )
        {
            desireddist = 2560.0;
            disttoarea = distance( ( self.origin[0], self.origin[1], self.areaent.origin[2] ), self.areaent.origin );

            if ( outsidetargets.size == 0 && disttoarea > self.areaent.radius + desireddist * 0.25 )
                returningtoarea = 1;
            else if ( disttoarea < self.areaent.radius * 0.5 )
                returningtoarea = 0;

            if ( outsidetargets.size == 0 && !returningtoarea )
            {
                if ( self.team != "neutral" )
                {
                    for ( i = 0; i < players.size; i++ )
                    {
                        if ( isalive( players[i] ) && isdefined( players[i].pers["team"] ) && players[i].pers["team"] != self.team && !isdefined( players[i].usingobj ) )
                        {
                            playerorigin = players[i].origin;
                            playerorigin = ( playerorigin[0], playerorigin[1], self.areaent.origin[2] );

                            if ( distance( players[i].origin, self.areaent.origin ) > self.areaent.radius )
                                outsidetargets[outsidetargets.size] = players[i];
                        }
                    }
                }
            }

            best = undefined;
            bestdist = 0;

            for ( i = 0; i < outsidetargets.size; i++ )
            {
                dist = abs( distance( outsidetargets[i].origin, self.origin ) - desireddist );

                if ( !isdefined( best ) || dist < bestdist )
                {
                    best = outsidetargets[i];
                    bestdist = dist;
                }
            }

            if ( isdefined( best ) )
            {
                attackpos = best.origin + level.coptertargetoffset;
                gotopos = determinebestattackpos( attackpos, self.origin, desireddist );
                self setcopterdest( gotopos, 0 );
                self.desireddir = vectornormalize( attackpos - gotopos );
                self.desireddirentity = best;
                self.desireddirentityoffset = level.coptertargetoffset;
                wait 1;
            }
            else
            {
                gotopos = getrandompos( self.areaent.origin, self.areaent.radius );
                self setcopterdest( gotopos, 0 );
                self.desireddir = undefined;
                self.desireddirentity = undefined;
                wait 1;
            }
        }
        else
        {
            if ( distance( self.origin, descendingent.origin ) < descendingent.radius )
                reacheddescendingent = 1;

            godirectly = isdefined( olddescendingent ) && olddescendingent == descendingent;
            godirectly = godirectly && reacheddescendingent;
            self.desireddir = vectornormalize( descendingent.targetent.origin - ( gotopos - level.coptercenteroffset ) );
            self.desireddirentity = descendingent.targetent;
            self.desireddirentityoffset = ( 0, 0, 0 );

            if ( gotopos != self.origin )
            {
                self setcopterdest( gotopos - level.coptercenteroffset, 1, godirectly );
                wait 0.3;
            }
            else
                wait 0.3;
        }
    }
}

determinebestpos( targets, descendent, startorigin )
{
    targetpos = descendent.targetent.origin;
    circleradius = distance( targetpos, descendent.origin );
    bestpoint = undefined;
    bestdist = 0;

    for ( i = 0; i < targets.size; i++ )
    {
        enemypos = targets[i].origin + level.coptertargetoffset;
        passed = bullettracepassed( enemypos, targetpos, 0, undefined );

        if ( passed )
        {
            dir = targetpos - enemypos;
            dir = ( dir[0], dir[1], 0 );
            isect = vectorscale( vectornormalize( dir ), circleradius ) + targetpos;
            isect = ( isect[0], isect[1], descendent.origin[2] );
            dist = distance( isect, descendent.origin );

            if ( dist <= descendent.radius )
            {
                dist = distance( isect, startorigin );

                if ( !isdefined( bestpoint ) || dist < bestdist )
                {
                    bestdist = dist;
                    bestpoint = isect;
                }
            }
        }
    }

    return bestpoint;
}

determinebestent( targets, descendents, startorigin )
{
    result = [];
    bestpos = undefined;
    bestent = 0;
    bestdist = 0;

    for ( i = 0; i < descendents.size; i++ )
    {
        thispos = determinebestpos( targets, descendents[i], startorigin );

        if ( isdefined( thispos ) )
        {
            thisdist = distance( thispos, startorigin );

            if ( !isdefined( bestpos ) || thisdist < bestdist )
            {
                bestpos = thispos;
                bestent = i;
                bestdist = thisdist;
            }
        }
    }

    if ( isdefined( bestpos ) )
    {
        result["descendEnt"] = descendents[bestent];
        result["position"] = bestpos;
        return result;
    }

    result["descendEnt"] = undefined;
    return result;
}

determinebestattackpos( targetpos, curpos, desireddist )
{
    targetposcopterheight = ( targetpos[0], targetpos[1], curpos[2] );
    attackdirx = curpos - targetposcopterheight;
    attackdirx = vectornormalize( attackdirx );
    attackdiry = ( 0 - attackdirx[1], attackdirx[0], 0 );
    bestpos = undefined;
    bestdist = 0;

    for ( i = 0; i < 8; i++ )
    {
        theta = i / 8.0 * 360;
        thisdir = vectorscale( attackdirx, cos( theta ) ) + vectorscale( attackdiry, sin( theta ) );
        traceend = targetposcopterheight + vectorscale( thisdir, desireddist );
        losexists = bullettracepassed( targetpos, traceend, 0, undefined );

        if ( losexists )
        {
            thisdist = distance( traceend, curpos );

            if ( !isdefined( bestpos ) || thisdist < bestdist )
            {
                bestpos = traceend;
                bestdist = thisdist;
            }
        }
    }

    gotopos = undefined;

    if ( isdefined( bestpos ) )
        gotopos = bestpos;
    else
    {
        dist = distance( targetposcopterheight, curpos );

        if ( dist > desireddist )
            gotopos = self.origin + vectorscale( vectornormalize( attackdirx ), 0 - ( dist - desireddist ) );
        else
            gotopos = self.origin;
    }

    return gotopos;
}

getrandompos( origin, radius )
{
    for ( pos = origin + ( ( randomfloat( 2 ) - 1 ) * radius, ( randomfloat( 2 ) - 1 ) * radius, 0 ); distancesquared( pos, origin ) > radius * radius; pos = origin + ( ( randomfloat( 2 ) - 1 ) * radius, ( randomfloat( 2 ) - 1 ) * radius, 0 ) )
    {

    }

    return pos;
}

coptershoot()
{
    self endon( "death" );
    self endon( "passive" );
    costhreshold = cos( 10 );

    while ( true )
    {
        if ( isdefined( self.desireddirentity ) && isdefined( self.desireddirentity.origin ) )
        {
            mypos = self.origin + level.coptercenteroffset;
            enemypos = self.desireddirentity.origin + self.desireddirentityoffset;
            curdir = anglestoforward( self.angles );
            enemydirraw = enemypos - mypos;
            enemydir = vectornormalize( enemydirraw );

            if ( vectordot( curdir, enemydir ) > costhreshold )
            {
                canseetarget = bullettracepassed( mypos, enemypos, 0, undefined );

                if ( !canseetarget && isplayer( self.desireddirentity ) && isalive( self.desireddirentity ) )
                    canseetarget = bullettracepassed( mypos, self.desireddirentity geteye(), 0, undefined );

                if ( canseetarget )
                {
                    self playsound( "mp_copter_shoot" );
                    numshots = 20;

                    for ( i = 0; i < numshots; i++ )
                    {
                        mypos = self.origin + level.coptercenteroffset;
                        dir = anglestoforward( self.angles );
                        dir += ( ( randomfloat( 2 ) - 1 ) * 0.015, ( randomfloat( 2 ) - 1 ) * 0.015, ( randomfloat( 2 ) - 1 ) * 0.015 );
                        dir = vectornormalize( dir );
                        self mymagicbullet( mypos, dir );
                        wait 0.075;
                    }

                    wait 0.25;
                }
            }
        }

        wait 0.25;
    }
}

mymagicbullet( pos, dir )
{
    damage = 20;

    if ( getdvar( _hash_9E8F8CB7 ) != "" )
        damage = getdvarint( _hash_9E8F8CB7 );

    trace = bullettrace( pos, pos + vectorscale( dir, 10000 ), 1, undefined );

    if ( isdefined( trace["entity"] ) && isplayer( trace["entity"] ) && isalive( trace["entity"] ) )
        trace["entity"] thread [[ level.callbackplayerdamage ]]( self, self, damage, 0, "MOD_RIFLE_BULLET", "copter", self.origin, dir, "none", 0, 0 );
}

setcopterdest( newlocation, descend, dontascend )
{
    self.finaldest = getabovebuildingslocation( newlocation );

    if ( isdefined( descend ) && descend )
        self.finalzdest = newlocation[2];
    else
        self.finalzdest = self.finaldest[2];

    self.intransit = 1;
    self.dontascend = 0;

    if ( isdefined( dontascend ) )
        self.dontascend = dontascend;
}

notifyarrived()
{
    wait 0.05;
    self notify( "arrived" );
}

coptermove()
{
    self endon( "death" );

    if ( isdefined( self.coptermoverunning ) )
        return;

    self.coptermoverunning = 1;
    self.intransit = 0;
    interval = 0.15;
    zinterp = 0.1;
    tiltamnt = 0;

    while ( true )
    {
        horizdistsquared = distancesquared( ( self.origin[0], self.origin[1], 0 ), ( self.finaldest[0], self.finaldest[1], 0 ) );
        donemoving = horizdistsquared < 100;
        neardest = horizdistsquared < 65536;
        self.intransit = 1;
        desiredz = 0;
        movinghorizontally = 1;
        movingvertically = 0;

        if ( self.dontascend )
            movingvertically = 1;
        else if ( !neardest )
        {
            desiredz = getabovebuildingslocation( self.origin )[2];
            movinghorizontally = abs( self.origin[2] - desiredz ) <= 256;
            movingvertically = !movinghorizontally;
        }
        else
            movingvertically = 1;

        if ( movinghorizontally )
        {
            if ( movingvertically )
                thisdest = ( self.finaldest[0], self.finaldest[1], self.finalzdest );
            else
                thisdest = self.finaldest;
        }
        else
        {
/#
            assert( movingvertically );
#/
            thisdest = ( self.origin[0], self.origin[1], desiredz );
        }

        movevec = thisdest - self.origin;
        idealaccel = vectorscale( thisdest - self.origin + vectorscale( self.vel, level.copter_accellookahead ), interval );
        vlen = veclength( idealaccel );

        if ( vlen > level.copter_maxaccel )
            idealaccel = vectorscale( idealaccel, level.copter_maxaccel / vlen );

        self.vel += idealaccel;
        vlen = veclength( self.vel );

        if ( vlen > level.copter_maxvel )
            self.vel = vectorscale( self.vel, level.copter_maxvel / vlen );

        thisdest = self.origin + vectorscale( self.vel, interval );
        self moveto( thisdest, interval * 0.999 );
        speed = veclength( self.vel );

        if ( isdefined( self.desireddirentity ) && isdefined( self.desireddirentity.origin ) )
            self.destdir = vectornormalize( self.desireddirentity.origin + self.desireddirentityoffset - self.origin + level.coptercenteroffset );
        else if ( isdefined( self.desireddir ) )
            self.destdir = self.desireddir;
        else if ( movingvertically )
        {
            self.destdir = anglestoforward( self.angles );
            self.destdir = vectornormalize( ( self.destdir[0], self.destdir[1], 0 ) );
        }
        else
        {
            tiltamnt = speed / level.copter_maxvel;
            tiltamnt = ( tiltamnt - 0.1 ) / 0.9;

            if ( tiltamnt < 0 )
                tiltamnt = 0;

            self.destdir = movevec;
            self.destdir = vectornormalize( ( self.destdir[0], self.destdir[1], 0 ) );
            tiltamnt *= ( 1 - vectorangle( anglestoforward( self.angles ), self.destdir ) / 180 );
            self.destdir = vectornormalize( ( self.destdir[0], self.destdir[1], tiltamnt * -0.4 ) );
        }

        newdir = self.destdir;

        if ( newdir[2] < -0.4 )
            newdir = vectornormalize( ( newdir[0], newdir[1], -0.4 ) );

        copterangles = self.angles;
        copterangles = combineangles( copterangles, vectorscale( ( 0, 1, 0 ), 90.0 ) );
        olddir = anglestoforward( copterangles );
        thisrotspeed = level.copter_rotspeed;
        olddir2d = vectornormalize( ( olddir[0], olddir[1], 0 ) );
        newdir2d = vectornormalize( ( newdir[0], newdir[1], 0 ) );
        angle = vectorangle( olddir2d, newdir2d );
        angle3d = vectorangle( olddir, newdir );

        if ( angle > 0.001 && thisrotspeed > 0.001 )
        {
            thisangle = thisrotspeed * interval;

            if ( thisangle > angle )
                thisangle = angle;

            newdir2d = vectortowardsothervector( olddir2d, newdir2d, thisangle );
            oldz = olddir[2] / veclength( ( olddir[0], olddir[1], 0 ) );
            newz = newdir[2] / veclength( ( newdir[0], newdir[1], 0 ) );
            interpz = oldz + ( newz - oldz ) * thisangle / angle;
            newdir = vectornormalize( ( newdir2d[0], newdir2d[1], interpz ) );
            copterangles = vectortoangles( newdir );
            copterangles = combineangles( copterangles, vectorscale( ( 0, -1, 0 ), 90.0 ) );
            self rotateto( copterangles, interval * 0.999 );
        }
        else if ( angle3d > 0.001 && thisrotspeed > 0.001 )
        {
            thisangle = thisrotspeed * interval;

            if ( thisangle > angle3d )
                thisangle = angle3d;

            newdir = vectortowardsothervector( olddir, newdir, thisangle );
            newdir = vectornormalize( newdir );
            copterangles = vectortoangles( newdir );
            copterangles = combineangles( copterangles, vectorscale( ( 0, -1, 0 ), 90.0 ) );
            self rotateto( copterangles, interval * 0.999 );
        }

        wait( interval );
    }
}

copterdamage( damagetrig )
{
    self endon( "passive" );

    while ( true )
    {
        damagetrig waittill( "damage", amount, attacker );

        if ( isdefined( attacker ) && isplayer( attacker ) && isdefined( attacker.pers["team"] ) && attacker.pers["team"] == self.team )
            continue;

        self.health -= amount;

        if ( self.health <= 0 )
        {
            self thread copterdie();
            return;
        }
    }
}

copterdie()
{
    self endon( "passive" );
    self death_notify_wrapper();
    self.dead = 1;
    self thread copterexplodefx();
    interval = 0.2;
    rottime = 15;
    self rotateyaw( 360 + randomfloat( 360 ), rottime );
    self rotatepitch( 360 + randomfloat( 360 ), rottime );
    self rotateroll( 360 + randomfloat( 360 ), rottime );

    while ( true )
    {
        self.vel += vectorscale( vectorscale( ( 0, 0, -1 ), 200.0 ), interval );
        newpos = self.origin + vectorscale( self.vel, interval );
        pathclear = bullettracepassed( self.origin, newpos, 0, undefined );

        if ( !pathclear )
            break;

        self moveto( newpos, interval * 0.999 );
        wait( interval );
    }

    playfx( level.copterfinalexplosion, self.origin );
    fakeself = spawn( "script_origin", self.origin );
    fakeself playsound( "mp_copter_explosion" );
    self notify( "finaldeath" );
    deletecopter();
    wait 2;
    fakeself delete();
}

deletecopter()
{
    if ( isdefined( self.damagetrig ) )
    {
        self.damagetrig notify( "unlink" );
        self.damagetrig = undefined;
    }

    self.copter delete();
    self delete();
}

copterexplodefx()
{
    self endon( "finaldeath" );

    while ( true )
    {
        playfx( level.copterexplosion, self.origin );
        self playsound( "mp_copter_explosion" );
        wait( 0.5 + randomfloat( 1 ) );
    }
}
