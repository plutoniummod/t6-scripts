// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\animscripts\utility;
#include maps\mp\_utility;

handledogsoundnotetracks( note )
{
    if ( note == "sound_dogstep_run_default" )
        return true;

    prefix = getsubstr( note, 0, 5 );

    if ( prefix != "sound" )
        return false;

    return true;
}

growling()
{
    return isdefined( self.script_growl );
}

handlenotetrack( note, flagname, customfunction, var1 )
{
/#
    if ( getdvarint( _hash_6EBEB982 ) )
        println( "dog notetrack: " + flagname + " " + note + " " + gettime() );
#/
    if ( isai( self ) && self.type == "dog" )
    {
        if ( handledogsoundnotetracks( note ) )
            return;
    }

    switch ( note )
    {
        case "undefined":
        case "finish":
        case "end":
            return note;
        default:
            if ( isdefined( customfunction ) )
            {
                if ( !isdefined( var1 ) )
                    return [[ customfunction ]]( note );
                else
                    return [[ customfunction ]]( note, var1 );
            }

            break;
    }
}

donotetracks( flagname, customfunction, var1 )
{
    for (;;)
    {
        self waittill( flagname, note );

        if ( !isdefined( note ) )
            note = "undefined";

        val = self handlenotetrack( note, flagname, customfunction, var1 );

        if ( isdefined( val ) )
            return val;
    }
}

donotetracksforeverproc( notetracksfunc, flagname, killstring, customfunction, var1 )
{
    if ( isdefined( killstring ) )
        self endon( killstring );

    self endon( "killanimscript" );

    for (;;)
    {
        time = gettime();
        returnednote = [[ notetracksfunc ]]( flagname, customfunction, var1 );
        timetaken = gettime() - time;

        if ( timetaken < 0.05 )
        {
            time = gettime();
            returnednote = [[ notetracksfunc ]]( flagname, customfunction, var1 );
            timetaken = gettime() - time;

            if ( timetaken < 0.05 )
            {
/#
                println( gettime() + " mapsmpanimscriptsshared::DoNoteTracksForever is trying to cause an infinite loop on anim " + flagname + ", returned " + returnednote + "." );
#/
                wait( 0.05 - timetaken );
            }
        }
    }
}

donotetracksforever( flagname, killstring, customfunction, var1 )
{
    donotetracksforeverproc( ::donotetracks, flagname, killstring, customfunction, var1 );
}

donotetracksfortimeproc( donotetracksforeverfunc, time, flagname, customfunction, ent, var1 )
{
    ent endon( "stop_notetracks" );
    [[ donotetracksforeverfunc ]]( flagname, undefined, customfunction, var1 );
}

donotetracksfortime( time, flagname, customfunction, var1 )
{
    ent = spawnstruct();
    ent thread donotetracksfortimeendnotify( time );
    donotetracksfortimeproc( ::donotetracksforever, time, flagname, customfunction, ent, var1 );
}

donotetracksfortimeendnotify( time )
{
    wait( time );
    self notify( "stop_notetracks" );
}

trackloop()
{
    players = get_players();
    deltachangeperframe = 5;
    aimblendtime = 0.05;
    prevyawdelta = 0;
    prevpitchdelta = 0;
    maxyawdeltachange = 5;
    maxpitchdeltachange = 5;
    pitchadd = 0;
    yawadd = 0;

    if ( self.type == "dog" || self.type == "zombie" || self.type == "zombie_dog" )
    {
        domaxanglecheck = 0;
        self.shootent = self.enemy;
    }
    else
    {
        domaxanglecheck = 1;

        if ( self.a.script == "cover_crouch" && isdefined( self.a.covermode ) && self.a.covermode == "lean" )
            pitchadd = -1 * anim.covercrouchleanpitch;

        if ( ( self.a.script == "cover_left" || self.a.script == "cover_right" ) && isdefined( self.a.cornermode ) && self.a.cornermode == "lean" )
            yawadd = self.covernode.angles[1] - self.angles[1];
    }

    yawdelta = 0;
    pitchdelta = 0;
    firstframe = 1;

    for (;;)
    {
        incranimaimweight();
        selfshootatpos = ( self.origin[0], self.origin[1], self geteye()[2] );
        shootpos = undefined;

        if ( isdefined( self.enemy ) )
            shootpos = self.enemy getshootatpos();

        if ( !isdefined( shootpos ) )
        {
            yawdelta = 0;
            pitchdelta = 0;
        }
        else
        {
            vectortoshootpos = shootpos - selfshootatpos;
            anglestoshootpos = vectortoangles( vectortoshootpos );
            pitchdelta = 360 - anglestoshootpos[0];
            pitchdelta = angleclamp180( pitchdelta + pitchadd );
            yawdelta = self.angles[1] - anglestoshootpos[1];
            yawdelta = angleclamp180( yawdelta + yawadd );
        }

        if ( domaxanglecheck && ( abs( yawdelta ) > 60 || abs( pitchdelta ) > 60 ) )
        {
            yawdelta = 0;
            pitchdelta = 0;
        }
        else
        {
            if ( yawdelta > self.rightaimlimit )
                yawdelta = self.rightaimlimit;
            else if ( yawdelta < self.leftaimlimit )
                yawdelta = self.leftaimlimit;

            if ( pitchdelta > self.upaimlimit )
                pitchdelta = self.upaimlimit;
            else if ( pitchdelta < self.downaimlimit )
                pitchdelta = self.downaimlimit;
        }

        if ( firstframe )
            firstframe = 0;
        else
        {
            yawdeltachange = yawdelta - prevyawdelta;

            if ( abs( yawdeltachange ) > maxyawdeltachange )
                yawdelta = prevyawdelta + maxyawdeltachange * sign( yawdeltachange );

            pitchdeltachange = pitchdelta - prevpitchdelta;

            if ( abs( pitchdeltachange ) > maxpitchdeltachange )
                pitchdelta = prevpitchdelta + maxpitchdeltachange * sign( pitchdeltachange );
        }

        prevyawdelta = yawdelta;
        prevpitchdelta = pitchdelta;
        updown = 0;
        leftright = 0;

        if ( yawdelta > 0 )
        {
/#
            assert( yawdelta <= self.rightaimlimit );
#/
            weight = yawdelta / self.rightaimlimit * self.a.aimweight;
            leftright = weight;
        }
        else if ( yawdelta < 0 )
        {
/#
            assert( yawdelta >= self.leftaimlimit );
#/
            weight = yawdelta / self.leftaimlimit * self.a.aimweight;
            leftright = -1 * weight;
        }

        if ( pitchdelta > 0 )
        {
/#
            assert( pitchdelta <= self.upaimlimit );
#/
            weight = pitchdelta / self.upaimlimit * self.a.aimweight;
            updown = weight;
        }
        else if ( pitchdelta < 0 )
        {
/#
            assert( pitchdelta >= self.downaimlimit );
#/
            weight = pitchdelta / self.downaimlimit * self.a.aimweight;
            updown = -1 * weight;
        }

        self setaimanimweights( updown, leftright );
        wait 0.05;
    }
}

setanimaimweight( goalweight, goaltime )
{
    if ( !isdefined( goaltime ) || goaltime <= 0 )
    {
        self.a.aimweight = goalweight;
        self.a.aimweight_start = goalweight;
        self.a.aimweight_end = goalweight;
        self.a.aimweight_transframes = 0;
    }
    else
    {
        self.a.aimweight = goalweight;
        self.a.aimweight_start = self.a.aimweight;
        self.a.aimweight_end = goalweight;
        self.a.aimweight_transframes = int( goaltime * 20 );
    }

    self.a.aimweight_t = 0;
}

incranimaimweight()
{
    if ( self.a.aimweight_t < self.a.aimweight_transframes )
    {
        self.a.aimweight_t++;
        t = 1.0 * self.a.aimweight_t / self.a.aimweight_transframes;
        self.a.aimweight = self.a.aimweight_start * ( 1 - t ) + self.a.aimweight_end * t;
    }
}
