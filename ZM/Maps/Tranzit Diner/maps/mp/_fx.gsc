// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\_createfx;

print_org( fxcommand, fxid, fxpos, waittime )
{
/#
    if ( getdvar( _hash_F49A52C ) == "1" )
    {
        println( "{" );
        println( "\"origin\" \"" + fxpos[0] + " " + fxpos[1] + " " + fxpos[2] + "\"" );
        println( "\"classname\" \"script_model\"" );
        println( "\"model\" \"fx\"" );
        println( "\"script_fxcommand\" \"" + fxcommand + "\"" );
        println( "\"script_fxid\" \"" + fxid + "\"" );
        println( "\"script_delay\" \"" + waittime + "\"" );
        println( "}" );
    }
#/
}

oneshotfx( fxid, fxpos, waittime, fxpos2 )
{

}

oneshotfxthread()
{
    wait 0.05;

    if ( self.v["delay"] > 0 )
        wait( self.v["delay"] );

    create_triggerfx();
}

create_triggerfx()
{
    self.looper = spawnfx_wrapper( self.v["fxid"], self.v["origin"], self.v["forward"], self.v["up"] );
    triggerfx( self.looper, self.v["delay"] );
    create_loopsound();
}

exploderfx( num, fxid, fxpos, waittime, fxpos2, firefx, firefxdelay, firefxsound, fxsound, fxquake, fxdamage, soundalias, repeat, delay_min, delay_max, damage_radius, firefxtimeout, exploder_group )
{
    if ( 1 )
    {
        ent = createexploder( fxid );
        ent.v["origin"] = fxpos;
        ent.v["angles"] = ( 0, 0, 0 );

        if ( isdefined( fxpos2 ) )
            ent.v["angles"] = vectortoangles( fxpos2 - fxpos );

        ent.v["delay"] = waittime;
        ent.v["exploder"] = num;
        return;
    }

    fx = spawn( "script_origin", ( 0, 0, 0 ) );
    fx.origin = fxpos;
    fx.angles = vectortoangles( fxpos2 - fxpos );
    fx.script_exploder = num;
    fx.script_fxid = fxid;
    fx.script_delay = waittime;
    fx.script_firefx = firefx;
    fx.script_firefxdelay = firefxdelay;
    fx.script_firefxsound = firefxsound;
    fx.script_sound = fxsound;
    fx.script_earthquake = fxquake;
    fx.script_damage = fxdamage;
    fx.script_radius = damage_radius;
    fx.script_soundalias = soundalias;
    fx.script_firefxtimeout = firefxtimeout;
    fx.script_repeat = repeat;
    fx.script_delay_min = delay_min;
    fx.script_delay_max = delay_max;
    fx.script_exploder_group = exploder_group;
    forward = anglestoforward( fx.angles );
    forward = vectorscale( forward, 150 );
    fx.targetpos = fxpos + forward;

    if ( !isdefined( level._script_exploders ) )
        level._script_exploders = [];

    level._script_exploders[level._script_exploders.size] = fx;
    maps\mp\_createfx::createfx_showorigin( fxid, fxpos, waittime, fxpos2, "exploderfx", fx, undefined, firefx, firefxdelay, firefxsound, fxsound, fxquake, fxdamage, soundalias, repeat, delay_min, delay_max, damage_radius, firefxtimeout );
}

loopfx( fxid, fxpos, waittime, fxpos2, fxstart, fxstop, timeout )
{
/#
    println( "Loopfx is deprecated!" );
#/
    ent = createloopeffect( fxid );
    ent.v["origin"] = fxpos;
    ent.v["angles"] = ( 0, 0, 0 );

    if ( isdefined( fxpos2 ) )
        ent.v["angles"] = vectortoangles( fxpos2 - fxpos );

    ent.v["delay"] = waittime;
}

create_looper()
{
    self.looper = playloopedfx( level._effect[self.v["fxid"]], self.v["delay"], self.v["origin"], 0, self.v["forward"], self.v["up"] );
    create_loopsound();
}

create_loopsound()
{
    self notify( "stop_loop" );

    if ( isdefined( self.v["soundalias"] ) && self.v["soundalias"] != "nil" )
    {
        if ( isdefined( self.looper ) )
            self.looper thread maps\mp\_utility::loop_fx_sound( self.v["soundalias"], self.v["origin"], "death" );
        else
            thread maps\mp\_utility::loop_fx_sound( self.v["soundalias"], self.v["origin"], "stop_loop" );
    }
}

stop_loopsound()
{
    self notify( "stop_loop" );
}

loopfxthread()
{
    wait 0.05;

    if ( isdefined( self.fxstart ) )
        level waittill( "start fx" + self.fxstart );

    while ( true )
    {
        create_looper();

        if ( isdefined( self.timeout ) )
            thread loopfxstop( self.timeout );

        if ( isdefined( self.fxstop ) )
            level waittill( "stop fx" + self.fxstop );
        else
            return;

        if ( isdefined( self.looper ) )
            self.looper delete();

        if ( isdefined( self.fxstart ) )
            level waittill( "start fx" + self.fxstart );
        else
            return;
    }
}

loopfxchangeid( ent )
{
    self endon( "death" );

    ent waittill( "effect id changed", change );
}

loopfxchangeorg( ent )
{
    self endon( "death" );

    for (;;)
    {
        ent waittill( "effect org changed", change );

        self.origin = change;
    }
}

loopfxchangedelay( ent )
{
    self endon( "death" );

    ent waittill( "effect delay changed", change );
}

loopfxdeletion( ent )
{
    self endon( "death" );

    ent waittill( "effect deleted" );

    self delete();
}

loopfxstop( timeout )
{
    self endon( "death" );
    wait( timeout );
    self.looper delete();
}

loopsound( sound, pos, waittime )
{
    level thread loopsoundthread( sound, pos, waittime );
}

loopsoundthread( sound, pos, waittime )
{
    org = spawn( "script_origin", pos );
    org.origin = pos;
    org playloopsound( sound );
}

gunfireloopfx( fxid, fxpos, shotsmin, shotsmax, shotdelaymin, shotdelaymax, betweensetsmin, betweensetsmax )
{
    thread gunfireloopfxthread( fxid, fxpos, shotsmin, shotsmax, shotdelaymin, shotdelaymax, betweensetsmin, betweensetsmax );
}

gunfireloopfxthread( fxid, fxpos, shotsmin, shotsmax, shotdelaymin, shotdelaymax, betweensetsmin, betweensetsmax )
{
    level endon( "stop all gunfireloopfx" );
    wait 0.05;

    if ( betweensetsmax < betweensetsmin )
    {
        temp = betweensetsmax;
        betweensetsmax = betweensetsmin;
        betweensetsmin = temp;
    }

    betweensetsbase = betweensetsmin;
    betweensetsrange = betweensetsmax - betweensetsmin;

    if ( shotdelaymax < shotdelaymin )
    {
        temp = shotdelaymax;
        shotdelaymax = shotdelaymin;
        shotdelaymin = temp;
    }

    shotdelaybase = shotdelaymin;
    shotdelayrange = shotdelaymax - shotdelaymin;

    if ( shotsmax < shotsmin )
    {
        temp = shotsmax;
        shotsmax = shotsmin;
        shotsmin = temp;
    }

    shotsbase = shotsmin;
    shotsrange = shotsmax - shotsmin;
    fxent = spawnfx( level._effect[fxid], fxpos );

    for (;;)
    {
        shotnum = shotsbase + randomint( shotsrange );

        for ( i = 0; i < shotnum; i++ )
        {
            triggerfx( fxent );
            wait( shotdelaybase + randomfloat( shotdelayrange ) );
        }

        wait( betweensetsbase + randomfloat( betweensetsrange ) );
    }
}

gunfireloopfxvec( fxid, fxpos, fxpos2, shotsmin, shotsmax, shotdelaymin, shotdelaymax, betweensetsmin, betweensetsmax )
{
    thread gunfireloopfxvecthread( fxid, fxpos, fxpos2, shotsmin, shotsmax, shotdelaymin, shotdelaymax, betweensetsmin, betweensetsmax );
}

gunfireloopfxvecthread( fxid, fxpos, fxpos2, shotsmin, shotsmax, shotdelaymin, shotdelaymax, betweensetsmin, betweensetsmax )
{
    level endon( "stop all gunfireloopfx" );
    wait 0.05;

    if ( betweensetsmax < betweensetsmin )
    {
        temp = betweensetsmax;
        betweensetsmax = betweensetsmin;
        betweensetsmin = temp;
    }

    betweensetsbase = betweensetsmin;
    betweensetsrange = betweensetsmax - betweensetsmin;

    if ( shotdelaymax < shotdelaymin )
    {
        temp = shotdelaymax;
        shotdelaymax = shotdelaymin;
        shotdelaymin = temp;
    }

    shotdelaybase = shotdelaymin;
    shotdelayrange = shotdelaymax - shotdelaymin;

    if ( shotsmax < shotsmin )
    {
        temp = shotsmax;
        shotsmax = shotsmin;
        shotsmin = temp;
    }

    shotsbase = shotsmin;
    shotsrange = shotsmax - shotsmin;
    fxpos2 = vectornormalize( fxpos2 - fxpos );
    fxent = spawnfx( level._effect[fxid], fxpos, fxpos2 );

    for (;;)
    {
        shotnum = shotsbase + randomint( shotsrange );

        for ( i = 0; i < int( shotnum / level.fxfireloopmod ); i++ )
        {
            triggerfx( fxent );
            delay = ( shotdelaybase + randomfloat( shotdelayrange ) ) * level.fxfireloopmod;

            if ( delay < 0.05 )
                delay = 0.05;

            wait( delay );
        }

        wait( shotdelaybase + randomfloat( shotdelayrange ) );
        wait( betweensetsbase + randomfloat( betweensetsrange ) );
    }
}

setfireloopmod( value )
{
    level.fxfireloopmod = 1 / value;
}

setup_fx()
{
    if ( !isdefined( self.script_fxid ) || !isdefined( self.script_fxcommand ) || !isdefined( self.script_delay ) )
        return;

    org = undefined;

    if ( isdefined( self.target ) )
    {
        ent = getent( self.target, "targetname" );

        if ( isdefined( ent ) )
            org = ent.origin;
    }

    fxstart = undefined;

    if ( isdefined( self.script_fxstart ) )
        fxstart = self.script_fxstart;

    fxstop = undefined;

    if ( isdefined( self.script_fxstop ) )
        fxstop = self.script_fxstop;

    if ( self.script_fxcommand == "OneShotfx" )
        oneshotfx( self.script_fxid, self.origin, self.script_delay, org );

    if ( self.script_fxcommand == "loopfx" )
        loopfx( self.script_fxid, self.origin, self.script_delay, org, fxstart, fxstop );

    if ( self.script_fxcommand == "loopsound" )
        loopsound( self.script_fxid, self.origin, self.script_delay );

    self delete();
}

script_print_fx()
{
/#
    if ( !isdefined( self.script_fxid ) || !isdefined( self.script_fxcommand ) || !isdefined( self.script_delay ) )
    {
        println( "Effect at origin ", self.origin, " doesn't have script_fxid/script_fxcommand/script_delay" );
        self delete();
        return;
    }

    if ( isdefined( self.target ) )
        org = getent( self.target, "targetname" ).origin;
    else
        org = "undefined";

    if ( self.script_fxcommand == "OneShotfx" )
        println( "mapsmp_fx::OneShotfx(\"" + self.script_fxid + "\", " + self.origin + ", " + self.script_delay + ", " + org + ");" );

    if ( self.script_fxcommand == "loopfx" )
        println( "mapsmp_fx::LoopFx(\"" + self.script_fxid + "\", " + self.origin + ", " + self.script_delay + ", " + org + ");" );

    if ( self.script_fxcommand == "loopsound" )
        println( "mapsmp_fx::LoopSound(\"" + self.script_fxid + "\", " + self.origin + ", " + self.script_delay + ", " + org + ");" );
#/
}

script_playfx( id, pos, pos2 )
{
    if ( !id )
        return;

    if ( isdefined( pos2 ) )
        playfx( id, pos, pos2 );
    else
        playfx( id, pos );
}

script_playfxontag( id, ent, tag )
{
    if ( !id )
        return;

    playfxontag( id, ent, tag );
}

grenadeexplosionfx( pos )
{
    playfx( level._effect["mechanical explosion"], pos );
    earthquake( 0.15, 0.5, pos, 250 );
}

soundfx( fxid, fxpos, endonnotify )
{
    org = spawn( "script_origin", ( 0, 0, 0 ) );
    org.origin = fxpos;
    org playloopsound( fxid );

    if ( isdefined( endonnotify ) )
        org thread soundfxdelete( endonnotify );
}

soundfxdelete( endonnotify )
{
    level waittill( endonnotify );

    self delete();
}

blenddelete( blend )
{
    self waittill( "death" );

    blend delete();
}

spawnfx_wrapper( fx_id, origin, forward, up )
{
/#
    assert( isdefined( level._effect[fx_id] ), "Missing level._effect[\"" + fx_id + "\"]. You did not setup the fx before calling it in createFx." );
#/
    fx_object = spawnfx( level._effect[fx_id], origin, forward, up );
    return fx_object;
}
