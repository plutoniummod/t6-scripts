// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_createfx;
#include maps\mp\_utility;

addcallback( event, func )
{
    assert( isdefined( event ), "Trying to set a callback on an undefined event." );

    if ( !isdefined( level._callbacks ) || !isdefined( level._callbacks[event] ) )
        level._callbacks[event] = [];

    level._callbacks[event] = add_to_array( level._callbacks[event], func, 0 );
}

callback( event )
{
    if ( isdefined( level._callbacks ) && isdefined( level._callbacks[event] ) )
    {
        for ( i = 0; i < level._callbacks[event].size; i++ )
        {
            callback = level._callbacks[event][i];

            if ( isdefined( callback ) )
                self thread [[ callback ]]();
        }
    }
}

onfinalizeinitialization_callback( func )
{
    addcallback( "on_finalize_initialization", func );
}

triggeroff()
{
    if ( !isdefined( self.realorigin ) )
        self.realorigin = self.origin;

    if ( self.origin == self.realorigin )
        self.origin += vectorscale( ( 0, 0, -1 ), 10000.0 );
}

triggeron()
{
    if ( isdefined( self.realorigin ) )
        self.origin = self.realorigin;
}

error( msg )
{
/#
    println( "^c*ERROR* ", msg );
    wait 0.05;

    if ( getdvar( _hash_F49A52C ) != "1" )
    {
/#
        assertmsg( "This is a forced error - attach the log file" );
#/
    }
#/
}

warning( msg )
{
/#
    println( "^1WARNING: " + msg );
#/
}

spawn_array_struct()
{
    s = spawnstruct();
    s.a = [];
    return s;
}

within_fov( start_origin, start_angles, end_origin, fov )
{
    normal = vectornormalize( end_origin - start_origin );
    forward = anglestoforward( start_angles );
    dot = vectordot( forward, normal );
    return dot >= fov;
}

append_array_struct( dst_s, src_s )
{
    for ( i = 0; i < src_s.a.size; i++ )
        dst_s.a[dst_s.a.size] = src_s.a[i];
}

exploder( num )
{
    [[ level.exploderfunction ]]( num );
}

exploder_stop( num )
{
    stop_exploder( num );
}

exploder_sound()
{
    if ( isdefined( self.script_delay ) )
        wait( self.script_delay );

    self playsound( level.scr_sound[self.script_sound] );
}

cannon_effect()
{
    if ( isdefined( self.v["repeat"] ) )
    {
        for ( i = 0; i < self.v["repeat"]; i++ )
        {
            playfx( level._effect[self.v["fxid"]], self.v["origin"], self.v["forward"], self.v["up"] );
            self exploder_delay();
        }

        return;
    }

    self exploder_delay();

    if ( isdefined( self.looper ) )
        self.looper delete();

    self.looper = spawnfx( getfx( self.v["fxid"] ), self.v["origin"], self.v["forward"], self.v["up"] );
    triggerfx( self.looper );
    exploder_playsound();
}

exploder_delay()
{
    if ( !isdefined( self.v["delay"] ) )
        self.v["delay"] = 0;

    min_delay = self.v["delay"];
    max_delay = self.v["delay"] + 0.001;

    if ( isdefined( self.v["delay_min"] ) )
        min_delay = self.v["delay_min"];

    if ( isdefined( self.v["delay_max"] ) )
        max_delay = self.v["delay_max"];

    if ( min_delay > 0 )
        wait( randomfloatrange( min_delay, max_delay ) );
}

exploder_playsound()
{
    if ( !isdefined( self.v["soundalias"] ) || self.v["soundalias"] == "nil" )
        return;

    play_sound_in_space( self.v["soundalias"], self.v["origin"] );
}

brush_delete()
{
    num = self.v["exploder"];

    if ( isdefined( self.v["delay"] ) )
        wait( self.v["delay"] );
    else
        wait 0.05;

    if ( !isdefined( self.model ) )
        return;

    assert( isdefined( self.model ) );

    if ( level.createfx_enabled )
    {
        if ( isdefined( self.exploded ) )
            return;

        self.exploded = 1;
        self.model hide();
        self.model notsolid();
        wait 3;
        self.exploded = undefined;
        self.model show();
        self.model solid();
        return;
    }

    if ( !isdefined( self.v["fxid"] ) || self.v["fxid"] == "No FX" )
        self.v["exploder"] = undefined;

    waittillframeend;
    self.model delete();
}

brush_show()
{
    if ( isdefined( self.v["delay"] ) )
        wait( self.v["delay"] );

    assert( isdefined( self.model ) );
    self.model show();
    self.model solid();

    if ( level.createfx_enabled )
    {
        if ( isdefined( self.exploded ) )
            return;

        self.exploded = 1;
        wait 3;
        self.exploded = undefined;
        self.model hide();
        self.model notsolid();
    }
}

brush_throw()
{
    if ( isdefined( self.v["delay"] ) )
        wait( self.v["delay"] );

    ent = undefined;

    if ( isdefined( self.v["target"] ) )
        ent = getent( self.v["target"], "targetname" );

    if ( !isdefined( ent ) )
    {
        self.model delete();
        return;
    }

    self.model show();
    startorg = self.v["origin"];
    startang = self.v["angles"];
    org = ent.origin;
    temp_vec = org - self.v["origin"];
    x = temp_vec[0];
    y = temp_vec[1];
    z = temp_vec[2];
    self.model rotatevelocity( ( x, y, z ), 12 );
    self.model movegravity( ( x, y, z ), 12 );

    if ( level.createfx_enabled )
    {
        if ( isdefined( self.exploded ) )
            return;

        self.exploded = 1;
        wait 3;
        self.exploded = undefined;
        self.v["origin"] = startorg;
        self.v["angles"] = startang;
        self.model hide();
        return;
    }

    self.v["exploder"] = undefined;
    wait 6;
    self.model delete();
}

getplant()
{
    start = self.origin + vectorscale( ( 0, 0, 1 ), 10.0 );
    range = 11;
    forward = anglestoforward( self.angles );
    forward = vectorscale( forward, range );
    traceorigins[0] = start + forward;
    traceorigins[1] = start;
    trace = bullettrace( traceorigins[0], traceorigins[0] + vectorscale( ( 0, 0, -1 ), 18.0 ), 0, undefined );

    if ( trace["fraction"] < 1 )
    {
        temp = spawnstruct();
        temp.origin = trace["position"];
        temp.angles = orienttonormal( trace["normal"] );
        return temp;
    }

    trace = bullettrace( traceorigins[1], traceorigins[1] + vectorscale( ( 0, 0, -1 ), 18.0 ), 0, undefined );

    if ( trace["fraction"] < 1 )
    {
        temp = spawnstruct();
        temp.origin = trace["position"];
        temp.angles = orienttonormal( trace["normal"] );
        return temp;
    }

    traceorigins[2] = start + vectorscale( ( 1, 1, 0 ), 16.0 );
    traceorigins[3] = start + vectorscale( ( 1, -1, 0 ), 16.0 );
    traceorigins[4] = start + vectorscale( ( -1, -1, 0 ), 16.0 );
    traceorigins[5] = start + vectorscale( ( -1, 1, 0 ), 16.0 );
    besttracefraction = undefined;
    besttraceposition = undefined;

    for ( i = 0; i < traceorigins.size; i++ )
    {
        trace = bullettrace( traceorigins[i], traceorigins[i] + vectorscale( ( 0, 0, -1 ), 1000.0 ), 0, undefined );

        if ( !isdefined( besttracefraction ) || trace["fraction"] < besttracefraction )
        {
            besttracefraction = trace["fraction"];
            besttraceposition = trace["position"];
        }
    }

    if ( besttracefraction == 1 )
        besttraceposition = self.origin;

    temp = spawnstruct();
    temp.origin = besttraceposition;
    temp.angles = orienttonormal( trace["normal"] );
    return temp;
}

orienttonormal( normal )
{
    hor_normal = ( normal[0], normal[1], 0 );
    hor_length = length( hor_normal );

    if ( !hor_length )
        return ( 0, 0, 0 );

    hor_dir = vectornormalize( hor_normal );
    neg_height = normal[2] * -1;
    tangent = ( hor_dir[0] * neg_height, hor_dir[1] * neg_height, hor_length );
    plant_angle = vectortoangles( tangent );
    return plant_angle;
}

array_levelthread( ents, process, var, excluders )
{
    exclude = [];

    for ( i = 0; i < ents.size; i++ )
        exclude[i] = 0;

    if ( isdefined( excluders ) )
    {
        for ( i = 0; i < ents.size; i++ )
        {
            for ( p = 0; p < excluders.size; p++ )
            {
                if ( ents[i] == excluders[p] )
                    exclude[i] = 1;
            }
        }
    }

    for ( i = 0; i < ents.size; i++ )
    {
        if ( !exclude[i] )
        {
            if ( isdefined( var ) )
            {
                level thread [[ process ]]( ents[i], var );
                continue;
            }

            level thread [[ process ]]( ents[i] );
        }
    }
}

deleteplacedentity( entity )
{
    entities = getentarray( entity, "classname" );

    for ( i = 0; i < entities.size; i++ )
        entities[i] delete();
}

playsoundonplayers( sound, team )
{
    assert( isdefined( level.players ) );

    if ( level.splitscreen )
    {
        if ( isdefined( level.players[0] ) )
            level.players[0] playlocalsound( sound );
    }
    else if ( isdefined( team ) )
    {
        for ( i = 0; i < level.players.size; i++ )
        {
            player = level.players[i];

            if ( isdefined( player.pers["team"] ) && player.pers["team"] == team )
                player playlocalsound( sound );
        }
    }
    else
    {
        for ( i = 0; i < level.players.size; i++ )
            level.players[i] playlocalsound( sound );
    }
}

get_player_height()
{
    return 70.0;
}

isbulletimpactmod( smeansofdeath )
{
    return issubstr( smeansofdeath, "BULLET" ) || smeansofdeath == "MOD_HEAD_SHOT";
}

get_team_alive_players_s( teamname )
{
    teamplayers_s = spawn_array_struct();

    if ( isdefined( teamname ) && isdefined( level.aliveplayers ) && isdefined( level.aliveplayers[teamname] ) )
    {
        for ( i = 0; i < level.aliveplayers[teamname].size; i++ )
            teamplayers_s.a[teamplayers_s.a.size] = level.aliveplayers[teamname][i];
    }

    return teamplayers_s;
}

get_all_alive_players_s()
{
    allplayers_s = spawn_array_struct();

    if ( isdefined( level.aliveplayers ) )
    {
        keys = getarraykeys( level.aliveplayers );

        for ( i = 0; i < keys.size; i++ )
        {
            team = keys[i];

            for ( j = 0; j < level.aliveplayers[team].size; j++ )
                allplayers_s.a[allplayers_s.a.size] = level.aliveplayers[team][j];
        }
    }

    return allplayers_s;
}

waitrespawnbutton()
{
    self endon( "disconnect" );
    self endon( "end_respawn" );

    while ( self usebuttonpressed() != 1 )
        wait 0.05;
}

setlowermessage( text, time, combinemessageandtimer )
{
    if ( !isdefined( self.lowermessage ) )
        return;

    if ( isdefined( self.lowermessageoverride ) && text != &"" )
    {
        text = self.lowermessageoverride;
        time = undefined;
    }

    self notify( "lower_message_set" );
    self.lowermessage settext( text );

    if ( isdefined( time ) && time > 0 )
    {
        if ( !isdefined( combinemessageandtimer ) || !combinemessageandtimer )
            self.lowertimer.label = &"";
        else
        {
            self.lowermessage settext( "" );
            self.lowertimer.label = text;
        }

        self.lowertimer settimer( time );
    }
    else
    {
        self.lowertimer settext( "" );
        self.lowertimer.label = &"";
    }

    if ( self issplitscreen() )
        self.lowermessage.fontscale = 1.4;

    self.lowermessage fadeovertime( 0.05 );
    self.lowermessage.alpha = 1;
    self.lowertimer fadeovertime( 0.05 );
    self.lowertimer.alpha = 1;
}

setlowermessagevalue( text, value, combinemessage )
{
    if ( !isdefined( self.lowermessage ) )
        return;

    if ( isdefined( self.lowermessageoverride ) && text != &"" )
    {
        text = self.lowermessageoverride;
        time = undefined;
    }

    self notify( "lower_message_set" );

    if ( !isdefined( combinemessage ) || !combinemessage )
        self.lowermessage settext( text );
    else
        self.lowermessage settext( "" );

    if ( isdefined( value ) && value > 0 )
    {
        if ( !isdefined( combinemessage ) || !combinemessage )
            self.lowertimer.label = &"";
        else
            self.lowertimer.label = text;

        self.lowertimer setvalue( value );
    }
    else
    {
        self.lowertimer settext( "" );
        self.lowertimer.label = &"";
    }

    if ( self issplitscreen() )
        self.lowermessage.fontscale = 1.4;

    self.lowermessage fadeovertime( 0.05 );
    self.lowermessage.alpha = 1;
    self.lowertimer fadeovertime( 0.05 );
    self.lowertimer.alpha = 1;
}

clearlowermessage( fadetime )
{
    if ( !isdefined( self.lowermessage ) )
        return;

    self notify( "lower_message_set" );

    if ( !isdefined( fadetime ) || fadetime == 0 )
        setlowermessage( &"" );
    else
    {
        self endon( "disconnect" );
        self endon( "lower_message_set" );
        self.lowermessage fadeovertime( fadetime );
        self.lowermessage.alpha = 0;
        self.lowertimer fadeovertime( fadetime );
        self.lowertimer.alpha = 0;
        wait( fadetime );
        self setlowermessage( "" );
    }
}

printonteam( text, team )
{
    assert( isdefined( level.players ) );

    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];

        if ( isdefined( player.pers["team"] ) && player.pers["team"] == team )
            player iprintln( text );
    }
}

printboldonteam( text, team )
{
    assert( isdefined( level.players ) );

    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];

        if ( isdefined( player.pers["team"] ) && player.pers["team"] == team )
            player iprintlnbold( text );
    }
}

printboldonteamarg( text, team, arg )
{
    assert( isdefined( level.players ) );

    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];

        if ( isdefined( player.pers["team"] ) && player.pers["team"] == team )
            player iprintlnbold( text, arg );
    }
}

printonteamarg( text, team, arg )
{

}

printonplayers( text, team )
{
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        if ( isdefined( team ) )
        {
            if ( isdefined( players[i].pers["team"] ) && players[i].pers["team"] == team )
                players[i] iprintln( text );

            continue;
        }

        players[i] iprintln( text );
    }
}

printandsoundoneveryone( team, enemyteam, printfriendly, printenemy, soundfriendly, soundenemy, printarg )
{
    shoulddosounds = isdefined( soundfriendly );
    shoulddoenemysounds = 0;

    if ( isdefined( soundenemy ) )
    {
        assert( shoulddosounds );
        shoulddoenemysounds = 1;
    }

    if ( !isdefined( printarg ) )
        printarg = "";

    if ( level.splitscreen || !shoulddosounds )
    {
        for ( i = 0; i < level.players.size; i++ )
        {
            player = level.players[i];
            playerteam = player.pers["team"];

            if ( isdefined( playerteam ) )
            {
                if ( playerteam == team && isdefined( printfriendly ) && printfriendly != &"" )
                {
                    player iprintln( printfriendly, printarg );
                    continue;
                }

                if ( isdefined( printenemy ) && printenemy != &"" )
                {
                    if ( isdefined( enemyteam ) && playerteam == enemyteam )
                    {
                        player iprintln( printenemy, printarg );
                        continue;
                    }

                    if ( !isdefined( enemyteam ) && playerteam != team )
                        player iprintln( printenemy, printarg );
                }
            }
        }

        if ( shoulddosounds )
        {
            assert( level.splitscreen );
            level.players[0] playlocalsound( soundfriendly );
        }
    }
    else
    {
        assert( shoulddosounds );

        if ( shoulddoenemysounds )
        {
            for ( i = 0; i < level.players.size; i++ )
            {
                player = level.players[i];
                playerteam = player.pers["team"];

                if ( isdefined( playerteam ) )
                {
                    if ( playerteam == team )
                    {
                        if ( isdefined( printfriendly ) && printfriendly != &"" )
                            player iprintln( printfriendly, printarg );

                        player playlocalsound( soundfriendly );
                        continue;
                    }

                    if ( isdefined( enemyteam ) && playerteam == enemyteam || !isdefined( enemyteam ) && playerteam != team )
                    {
                        if ( isdefined( printenemy ) && printenemy != &"" )
                            player iprintln( printenemy, printarg );

                        player playlocalsound( soundenemy );
                    }
                }
            }
        }
        else
        {
            for ( i = 0; i < level.players.size; i++ )
            {
                player = level.players[i];
                playerteam = player.pers["team"];

                if ( isdefined( playerteam ) )
                {
                    if ( playerteam == team )
                    {
                        if ( isdefined( printfriendly ) && printfriendly != &"" )
                            player iprintln( printfriendly, printarg );

                        player playlocalsound( soundfriendly );
                        continue;
                    }

                    if ( isdefined( printenemy ) && printenemy != &"" )
                    {
                        if ( isdefined( enemyteam ) && playerteam == enemyteam )
                        {
                            player iprintln( printenemy, printarg );
                            continue;
                        }

                        if ( !isdefined( enemyteam ) && playerteam != team )
                            player iprintln( printenemy, printarg );
                    }
                }
            }
        }
    }
}

_playlocalsound( soundalias )
{
    if ( level.splitscreen && !self ishost() )
        return;

    self playlocalsound( soundalias );
}

dvarintvalue( dvar, defval, minval, maxval )
{
    dvar = "scr_" + level.gametype + "_" + dvar;

    if ( getdvar( dvar ) == "" )
    {
        setdvar( dvar, defval );
        return defval;
    }

    value = getdvarint( dvar );

    if ( value > maxval )
        value = maxval;
    else if ( value < minval )
        value = minval;
    else
        return value;

    setdvar( dvar, value );
    return value;
}

dvarfloatvalue( dvar, defval, minval, maxval )
{
    dvar = "scr_" + level.gametype + "_" + dvar;

    if ( getdvar( dvar ) == "" )
    {
        setdvar( dvar, defval );
        return defval;
    }

    value = getdvarfloat( dvar );

    if ( value > maxval )
        value = maxval;
    else if ( value < minval )
        value = minval;
    else
        return value;

    setdvar( dvar, value );
    return value;
}

play_sound_on_tag( alias, tag )
{
    if ( isdefined( tag ) )
    {
        org = spawn( "script_origin", self gettagorigin( tag ) );
        org linkto( self, tag, ( 0, 0, 0 ), ( 0, 0, 0 ) );
    }
    else
    {
        org = spawn( "script_origin", ( 0, 0, 0 ) );
        org.origin = self.origin;
        org.angles = self.angles;
        org linkto( self );
    }

    org playsound( alias );
    wait 5.0;
    org delete();
}

createloopeffect( fxid )
{
    ent = maps\mp\_createfx::createeffect( "loopfx", fxid );
    ent.v["delay"] = 0.5;
    return ent;
}

createoneshoteffect( fxid )
{
    ent = maps\mp\_createfx::createeffect( "oneshotfx", fxid );
    ent.v["delay"] = -15;
    return ent;
}

loop_fx_sound( alias, origin, ender, timeout )
{
    org = spawn( "script_origin", ( 0, 0, 0 ) );

    if ( isdefined( ender ) )
    {
        thread loop_sound_delete( ender, org );
        self endon( ender );
    }

    org.origin = origin;
    org playloopsound( alias );

    if ( !isdefined( timeout ) )
        return;

    wait( timeout );
}

exploder_damage()
{
    if ( isdefined( self.v["delay"] ) )
        delay = self.v["delay"];
    else
        delay = 0;

    if ( isdefined( self.v["damage_radius"] ) )
        radius = self.v["damage_radius"];
    else
        radius = 128;

    damage = self.v["damage"];
    origin = self.v["origin"];
    wait( delay );
    radiusdamage( origin, radius, damage, damage );
}

exploder_before_load( num )
{
    waittillframeend;
    waittillframeend;
    activate_exploder( num );
}

exploder_after_load( num )
{
    activate_exploder( num );
}

getexploderid( ent )
{
    if ( !isdefined( level._exploder_ids ) )
    {
        level._exploder_ids = [];
        level._exploder_id = 1;
    }

    if ( !isdefined( level._exploder_ids[ent.v["exploder"]] ) )
    {
        level._exploder_ids[ent.v["exploder"]] = level._exploder_id;
        level._exploder_id++;
    }

    return level._exploder_ids[ent.v["exploder"]];
}

activate_exploder_on_clients( num )
{
    if ( !isdefined( level._exploder_ids[num] ) )
        return;

    if ( !isdefined( level._client_exploders[num] ) )
        level._client_exploders[num] = 1;

    if ( !isdefined( level._client_exploder_ids[num] ) )
        level._client_exploder_ids[num] = 1;

    activateclientexploder( level._exploder_ids[num] );
}

delete_exploder_on_clients( num )
{
    if ( !isdefined( level._exploder_ids[num] ) )
        return;

    if ( !isdefined( level._client_exploders[num] ) )
        return;

    level._client_exploders[num] = undefined;
    level._client_exploder_ids[num] = undefined;
    deactivateclientexploder( level._exploder_ids[num] );
}

activate_individual_exploder()
{
    level notify( "exploder" + self.v["exploder"] );

    if ( level.createfx_enabled || !level.clientscripts || !isdefined( level._exploder_ids[int( self.v["exploder"] )] ) || isdefined( self.v["exploder_server"] ) )
    {
/#
        println( "Exploder " + self.v["exploder"] + " created on server." );
#/
        if ( isdefined( self.v["firefx"] ) )
            self thread fire_effect();

        if ( isdefined( self.v["fxid"] ) && self.v["fxid"] != "No FX" )
            self thread cannon_effect();
        else if ( isdefined( self.v["soundalias"] ) )
            self thread sound_effect();
    }

    if ( isdefined( self.v["trailfx"] ) )
        self thread trail_effect();

    if ( isdefined( self.v["damage"] ) )
        self thread exploder_damage();

    if ( self.v["exploder_type"] == "exploder" )
        self thread brush_show();
    else if ( self.v["exploder_type"] == "exploderchunk" || self.v["exploder_type"] == "exploderchunk visible" )
        self thread brush_throw();
    else
        self thread brush_delete();
}

trail_effect()
{
    self exploder_delay();

    if ( !isdefined( self.v["trailfxtag"] ) )
        self.v["trailfxtag"] = "tag_origin";

    temp_ent = undefined;

    if ( self.v["trailfxtag"] == "tag_origin" )
        playfxontag( level._effect[self.v["trailfx"]], self.model, self.v["trailfxtag"] );
    else
    {
        temp_ent = spawn( "script_model", self.model.origin );
        temp_ent setmodel( "tag_origin" );
        temp_ent linkto( self.model, self.v["trailfxtag"] );
        playfxontag( level._effect[self.v["trailfx"]], temp_ent, "tag_origin" );
    }

    if ( isdefined( self.v["trailfxsound"] ) )
    {
        if ( !isdefined( temp_ent ) )
            self.model playloopsound( self.v["trailfxsound"] );
        else
            temp_ent playloopsound( self.v["trailfxsound"] );
    }

    if ( isdefined( self.v["ender"] ) && isdefined( temp_ent ) )
        level thread trail_effect_ender( temp_ent, self.v["ender"] );

    if ( !isdefined( self.v["trailfxtimeout"] ) )
        return;

    wait( self.v["trailfxtimeout"] );

    if ( isdefined( temp_ent ) )
        temp_ent delete();
}

trail_effect_ender( ent, ender )
{
    ent endon( "death" );

    self waittill( ender );

    ent delete();
}

activate_exploder( num )
{
    num = int( num );
/#
    if ( level.createfx_enabled )
    {
        for ( i = 0; i < level.createfxent.size; i++ )
        {
            ent = level.createfxent[i];

            if ( !isdefined( ent ) )
                continue;

            if ( ent.v["type"] != "exploder" )
                continue;

            if ( !isdefined( ent.v["exploder"] ) )
                continue;

            if ( ent.v["exploder"] != num )
                continue;

            if ( isdefined( ent.v["exploder_server"] ) )
                client_send = 0;

            ent activate_individual_exploder();
        }

        return;
    }
#/
    client_send = 1;

    if ( isdefined( level.createfxexploders[num] ) )
    {
        for ( i = 0; i < level.createfxexploders[num].size; i++ )
        {
            if ( client_send && isdefined( level.createfxexploders[num][i].v["exploder_server"] ) )
                client_send = 0;

            level.createfxexploders[num][i] activate_individual_exploder();
        }
    }

    if ( level.clientscripts )
    {
        if ( !level.createfx_enabled && client_send == 1 )
            activate_exploder_on_clients( num );
    }
}

stop_exploder( num )
{
    num = int( num );

    if ( level.clientscripts )
    {
        if ( !level.createfx_enabled )
            delete_exploder_on_clients( num );
    }

    if ( isdefined( level.createfxexploders[num] ) )
    {
        for ( i = 0; i < level.createfxexploders[num].size; i++ )
        {
            if ( !isdefined( level.createfxexploders[num][i].looper ) )
                continue;

            level.createfxexploders[num][i].looper delete();
        }
    }
}

sound_effect()
{
    self effect_soundalias();
}

effect_soundalias()
{
    if ( !isdefined( self.v["delay"] ) )
        self.v["delay"] = 0;

    origin = self.v["origin"];
    alias = self.v["soundalias"];
    wait( self.v["delay"] );
    play_sound_in_space( alias, origin );
}

play_sound_in_space( alias, origin, master )
{
    org = spawn( "script_origin", ( 0, 0, 1 ) );

    if ( !isdefined( origin ) )
        origin = self.origin;

    org.origin = origin;

    if ( isdefined( master ) && master )
        org playsoundasmaster( alias );
    else
        org playsound( alias );

    wait 10.0;
    org delete();
}

loop_sound_in_space( alias, origin, ender )
{
    org = spawn( "script_origin", ( 0, 0, 1 ) );

    if ( !isdefined( origin ) )
        origin = self.origin;

    org.origin = origin;
    org playloopsound( alias );

    level waittill( ender );

    org stoploopsound();
    wait 0.1;
    org delete();
}

fire_effect()
{
    if ( !isdefined( self.v["delay"] ) )
        self.v["delay"] = 0;

    delay = self.v["delay"];

    if ( isdefined( self.v["delay_min"] ) && isdefined( self.v["delay_max"] ) )
        delay = self.v["delay_min"] + randomfloat( self.v["delay_max"] - self.v["delay_min"] );

    forward = self.v["forward"];
    up = self.v["up"];
    org = undefined;
    firefxsound = self.v["firefxsound"];
    origin = self.v["origin"];
    firefx = self.v["firefx"];
    ender = self.v["ender"];

    if ( !isdefined( ender ) )
        ender = "createfx_effectStopper";

    timeout = self.v["firefxtimeout"];
    firefxdelay = 0.5;

    if ( isdefined( self.v["firefxdelay"] ) )
        firefxdelay = self.v["firefxdelay"];

    wait( delay );

    if ( isdefined( firefxsound ) )
        level thread loop_fx_sound( firefxsound, origin, ender, timeout );

    playfx( level._effect[firefx], self.v["origin"], forward, up );
}

loop_sound_delete( ender, ent )
{
    ent endon( "death" );

    self waittill( ender );

    ent delete();
}

createexploder( fxid )
{
    ent = maps\mp\_createfx::createeffect( "exploder", fxid );
    ent.v["delay"] = 0;
    ent.v["exploder"] = 1;
    ent.v["exploder_type"] = "normal";
    return ent;
}

getotherteam( team )
{
    if ( team == "allies" )
        return "axis";
    else if ( team == "axis" )
        return "allies";
    else
        return "allies";
/#
    assertmsg( "getOtherTeam: invalid team " + team );
#/
}

getteammask( team )
{
    if ( !level.teambased || !isdefined( team ) || !isdefined( level.spawnsystem.ispawn_teammask[team] ) )
        return level.spawnsystem.ispawn_teammask_free;

    return level.spawnsystem.ispawn_teammask[team];
}

getotherteamsmask( skip_team )
{
    mask = 0;

    foreach ( team in level.teams )
    {
        if ( team == skip_team )
            continue;

        mask |= getteammask( team );
    }

    return mask;
}

wait_endon( waittime, endonstring, endonstring2, endonstring3, endonstring4 )
{
    self endon( endonstring );

    if ( isdefined( endonstring2 ) )
        self endon( endonstring2 );

    if ( isdefined( endonstring3 ) )
        self endon( endonstring3 );

    if ( isdefined( endonstring4 ) )
        self endon( endonstring4 );

    wait( waittime );
    return 1;
}

ismg( weapon )
{
    return issubstr( weapon, "_bipod_" );
}

plot_points( plotpoints, r, g, b, timer )
{
/#
    lastpoint = plotpoints[0];

    if ( !isdefined( r ) )
        r = 1;

    if ( !isdefined( g ) )
        g = 1;

    if ( !isdefined( b ) )
        b = 1;

    if ( !isdefined( timer ) )
        timer = 0.05;

    for ( i = 1; i < plotpoints.size; i++ )
    {
        line( lastpoint, plotpoints[i], ( r, g, b ), 1, timer );
        lastpoint = plotpoints[i];
    }
#/
}

player_flag_wait( msg )
{
    while ( !self.flag[msg] )
        self waittill( msg );
}

player_flag_wait_either( flag1, flag2 )
{
    for (;;)
    {
        if ( flag( flag1 ) )
            return;

        if ( flag( flag2 ) )
            return;

        self waittill_either( flag1, flag2 );
    }
}

player_flag_waitopen( msg )
{
    while ( self.flag[msg] )
        self waittill( msg );
}

player_flag_init( message, trigger )
{
    if ( !isdefined( self.flag ) )
    {
        self.flag = [];
        self.flags_lock = [];
    }

    assert( !isdefined( self.flag[message] ), "Attempt to reinitialize existing message: " + message );
    self.flag[message] = 0;
/#
    self.flags_lock[message] = 0;
#/
}

player_flag_set_delayed( message, delay )
{
    wait( delay );
    player_flag_set( message );
}

player_flag_set( message )
{
/#
    assert( isdefined( self.flag[message] ), "Attempt to set a flag before calling flag_init: " + message );
    assert( self.flag[message] == self.flags_lock[message] );
    self.flags_lock[message] = 1;
#/
    self.flag[message] = 1;
    self notify( message );
}

player_flag_clear( message )
{
/#
    assert( isdefined( self.flag[message] ), "Attempt to set a flag before calling flag_init: " + message );
    assert( self.flag[message] == self.flags_lock[message] );
    self.flags_lock[message] = 0;
#/
    self.flag[message] = 0;
    self notify( message );
}

player_flag( message )
{
    assert( isdefined( message ), "Tried to check flag but the flag was not defined." );

    if ( !self.flag[message] )
        return false;

    return true;
}

registerclientsys( ssysname )
{
    if ( !isdefined( level._clientsys ) )
        level._clientsys = [];

    if ( level._clientsys.size >= 32 )
    {
/#
        error( "Max num client systems exceeded." );
#/
        return;
    }

    if ( isdefined( level._clientsys[ssysname] ) )
    {
/#
        error( "Attempt to re-register client system : " + ssysname );
#/
        return;
    }
    else
    {
        level._clientsys[ssysname] = spawnstruct();
        level._clientsys[ssysname].sysid = clientsysregister( ssysname );
    }
}

setclientsysstate( ssysname, ssysstate, player )
{
    if ( !isdefined( level._clientsys ) )
    {
/#
        error( "setClientSysState called before registration of any systems." );
#/
        return;
    }

    if ( !isdefined( level._clientsys[ssysname] ) )
    {
/#
        error( "setClientSysState called on unregistered system " + ssysname );
#/
        return;
    }

    if ( isdefined( player ) )
        player clientsyssetstate( level._clientsys[ssysname].sysid, ssysstate );
    else
    {
        clientsyssetstate( level._clientsys[ssysname].sysid, ssysstate );
        level._clientsys[ssysname].sysstate = ssysstate;
    }
}

getclientsysstate( ssysname )
{
    if ( !isdefined( level._clientsys ) )
    {
/#
        error( "Cannot getClientSysState before registering any client systems." );
#/
        return "";
    }

    if ( !isdefined( level._clientsys[ssysname] ) )
    {
/#
        error( "Client system " + ssysname + " cannot return state, as it is unregistered." );
#/
        return "";
    }

    if ( isdefined( level._clientsys[ssysname].sysstate ) )
        return level._clientsys[ssysname].sysstate;

    return "";
}

clientnotify( event )
{
    if ( level.clientscripts )
    {
        if ( isplayer( self ) )
            maps\mp\_utility::setclientsysstate( "levelNotify", event, self );
        else
            maps\mp\_utility::setclientsysstate( "levelNotify", event );
    }
}

alphabet_compare( a, b )
{
    list = [];
    val = 1;
    list["0"] = val;
    val++;
    list["1"] = val;
    val++;
    list["2"] = val;
    val++;
    list["3"] = val;
    val++;
    list["4"] = val;
    val++;
    list["5"] = val;
    val++;
    list["6"] = val;
    val++;
    list["7"] = val;
    val++;
    list["8"] = val;
    val++;
    list["9"] = val;
    val++;
    list["_"] = val;
    val++;
    list["a"] = val;
    val++;
    list["b"] = val;
    val++;
    list["c"] = val;
    val++;
    list["d"] = val;
    val++;
    list["e"] = val;
    val++;
    list["f"] = val;
    val++;
    list["g"] = val;
    val++;
    list["h"] = val;
    val++;
    list["i"] = val;
    val++;
    list["j"] = val;
    val++;
    list["k"] = val;
    val++;
    list["l"] = val;
    val++;
    list["m"] = val;
    val++;
    list["n"] = val;
    val++;
    list["o"] = val;
    val++;
    list["p"] = val;
    val++;
    list["q"] = val;
    val++;
    list["r"] = val;
    val++;
    list["s"] = val;
    val++;
    list["t"] = val;
    val++;
    list["u"] = val;
    val++;
    list["v"] = val;
    val++;
    list["w"] = val;
    val++;
    list["x"] = val;
    val++;
    list["y"] = val;
    val++;
    list["z"] = val;
    val++;
    a = tolower( a );
    b = tolower( b );
    val1 = 0;

    if ( isdefined( list[a] ) )
        val1 = list[a];

    val2 = 0;

    if ( isdefined( list[b] ) )
        val2 = list[b];

    if ( val1 > val2 )
        return "1st";

    if ( val1 < val2 )
        return "2nd";

    return "same";
}

is_later_in_alphabet( string1, string2 )
{
    count = string1.size;

    if ( count >= string2.size )
        count = string2.size;

    for ( i = 0; i < count; i++ )
    {
        val = alphabet_compare( string1[i], string2[i] );

        if ( val == "1st" )
            return 1;

        if ( val == "2nd" )
            return 0;
    }

    return string1.size > string2.size;
}

alphabetize( array )
{
    if ( array.size <= 1 )
        return array;

    count = 0;

    for (;;)
    {
        changed = 0;

        for ( i = 0; i < array.size - 1; i++ )
        {
            if ( is_later_in_alphabet( array[i], array[i + 1] ) )
            {
                val = array[i];
                array[i] = array[i + 1];
                array[i + 1] = val;
                changed = 1;
                count++;

                if ( count >= 9 )
                {
                    count = 0;
                    wait 0.05;
                }
            }
        }

        if ( !changed )
            return array;
    }

    return array;
}

get_players()
{
    players = getplayers();
    return players;
}

getfx( fx )
{
    assert( isdefined( level._effect[fx] ), "Fx " + fx + " is not defined in level._effect." );
    return level._effect[fx];
}

struct_arrayspawn()
{
    struct = spawnstruct();
    struct.array = [];
    struct.lastindex = 0;
    return struct;
}

structarray_add( struct, object )
{
    assert( !isdefined( object.struct_array_index ) );
    struct.array[struct.lastindex] = object;
    object.struct_array_index = struct.lastindex;
    struct.lastindex++;
}

structarray_remove( struct, object )
{
    structarray_swaptolast( struct, object );
    struct.array[struct.lastindex - 1] = undefined;
    struct.lastindex--;
}

structarray_swaptolast( struct, object )
{
    struct structarray_swap( struct.array[struct.lastindex - 1], object );
}

structarray_shuffle( struct, shuffle )
{
    for ( i = 0; i < shuffle; i++ )
        struct structarray_swap( struct.array[i], struct.array[randomint( struct.lastindex )] );
}

structarray_swap( object1, object2 )
{
    index1 = object1.struct_array_index;
    index2 = object2.struct_array_index;
    self.array[index2] = object1;
    self.array[index1] = object2;
    self.array[index1].struct_array_index = index1;
    self.array[index2].struct_array_index = index2;
}

waittill_either( msg1, msg2 )
{
    self endon( msg1 );

    self waittill( msg2 );
}

combinearrays( array1, array2 )
{
    assert( isdefined( array1 ) || isdefined( array2 ) );

    if ( !isdefined( array1 ) && isdefined( array2 ) )
        return array2;

    if ( !isdefined( array2 ) && isdefined( array1 ) )
        return array1;

    foreach ( elem in array2 )
        array1[array1.size] = elem;

    return array1;
}

getclosest( org, array, dist )
{
    return comparesizes( org, array, dist, ::closerfunc );
}

getclosestfx( org, fxarray, dist )
{
    return comparesizesfx( org, fxarray, dist, ::closerfunc );
}

getfarthest( org, array, dist )
{
    return comparesizes( org, array, dist, ::fartherfunc );
}

comparesizesfx( org, array, dist, comparefunc )
{
    if ( !array.size )
        return undefined;

    if ( isdefined( dist ) )
    {
        distsqr = dist * dist;
        struct = undefined;
        keys = getarraykeys( array );

        for ( i = 0; i < keys.size; i++ )
        {
            newdistsqr = distancesquared( array[keys[i]].v["origin"], org );

            if ( [[ comparefunc ]]( newdistsqr, distsqr ) )
                continue;

            distsqr = newdistsqr;
            struct = array[keys[i]];
        }

        return struct;
    }

    keys = getarraykeys( array );
    struct = array[keys[0]];
    distsqr = distancesquared( struct.v["origin"], org );

    for ( i = 1; i < keys.size; i++ )
    {
        newdistsqr = distancesquared( array[keys[i]].v["origin"], org );

        if ( [[ comparefunc ]]( newdistsqr, distsqr ) )
            continue;

        distsqr = newdistsqr;
        struct = array[keys[i]];
    }

    return struct;
}

comparesizes( org, array, dist, comparefunc )
{
    if ( !array.size )
        return undefined;

    if ( isdefined( dist ) )
    {
        distsqr = dist * dist;
        ent = undefined;
        keys = getarraykeys( array );

        for ( i = 0; i < keys.size; i++ )
        {
            if ( !isdefined( array[keys[i]] ) )
                continue;

            newdistsqr = distancesquared( array[keys[i]].origin, org );

            if ( [[ comparefunc ]]( newdistsqr, distsqr ) )
                continue;

            distsqr = newdistsqr;
            ent = array[keys[i]];
        }

        return ent;
    }

    keys = getarraykeys( array );
    ent = array[keys[0]];
    distsqr = distancesquared( ent.origin, org );

    for ( i = 1; i < keys.size; i++ )
    {
        if ( !isdefined( array[keys[i]] ) )
            continue;

        newdistsqr = distancesquared( array[keys[i]].origin, org );

        if ( [[ comparefunc ]]( newdistsqr, distsqr ) )
            continue;

        distsqr = newdistsqr;
        ent = array[keys[i]];
    }

    return ent;
}

closerfunc( dist1, dist2 )
{
    return dist1 >= dist2;
}

fartherfunc( dist1, dist2 )
{
    return dist1 <= dist2;
}

get_array_of_closest( org, array, excluders = [], max = array.size, maxdist )
{
    maxdists2rd = undefined;

    if ( isdefined( maxdist ) )
        maxdists2rd = maxdist * maxdist;

    dist = [];
    index = [];

    for ( i = 0; i < array.size; i++ )
    {
        if ( !isdefined( array[i] ) )
            continue;

        excluded = 0;

        for ( p = 0; p < excluders.size; p++ )
        {
            if ( array[i] != excluders[p] )
                continue;

            excluded = 1;
            break;
        }

        if ( excluded )
            continue;

        length = distancesquared( org, array[i].origin );

        if ( isdefined( maxdists2rd ) && maxdists2rd < length )
            continue;

        dist[dist.size] = length;
        index[index.size] = i;
    }

    for (;;)
    {
        change = 0;

        for ( i = 0; i < dist.size - 1; i++ )
        {
            if ( dist[i] <= dist[i + 1] )
                continue;

            change = 1;
            temp = dist[i];
            dist[i] = dist[i + 1];
            dist[i + 1] = temp;
            temp = index[i];
            index[i] = index[i + 1];
            index[i + 1] = temp;
        }

        if ( !change )
            break;
    }

    newarray = [];

    if ( max > dist.size )
        max = dist.size;

    for ( i = 0; i < max; i++ )
        newarray[i] = array[index[i]];

    return newarray;
}

set_dvar_if_unset( dvar, value, reset = 0 )
{
    if ( reset || getdvar( dvar ) == "" )
    {
        setdvar( dvar, value );
        return value;
    }

    return getdvar( dvar );
}

set_dvar_float_if_unset( dvar, value, reset = 0 )
{
    if ( reset || getdvar( dvar ) == "" )
        setdvar( dvar, value );

    return getdvarfloat( dvar );
}

set_dvar_int_if_unset( dvar, value, reset = 0 )
{
    if ( reset || getdvar( dvar ) == "" )
    {
        setdvar( dvar, value );
        return int( value );
    }

    return getdvarint( dvar );
}

drawcylinder( pos, rad, height, duration, stop_notify )
{
/#
    if ( !isdefined( duration ) )
        duration = 0;

    level thread drawcylinder_think( pos, rad, height, duration, stop_notify );
#/
}

drawcylinder_think( pos, rad, height, seconds, stop_notify )
{
/#
    if ( isdefined( stop_notify ) )
        level endon( stop_notify );

    stop_time = gettime() + seconds * 1000;
    currad = rad;
    curheight = height;

    for (;;)
    {
        if ( seconds > 0 && stop_time <= gettime() )
            return;

        for ( r = 0; r < 20; r++ )
        {
            theta = r / 20 * 360;
            theta2 = ( r + 1 ) / 20 * 360;
            line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, 0 ) );
            line( pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ), pos + ( cos( theta2 ) * currad, sin( theta2 ) * currad, curheight ) );
            line( pos + ( cos( theta ) * currad, sin( theta ) * currad, 0 ), pos + ( cos( theta ) * currad, sin( theta ) * currad, curheight ) );
        }

        wait 0.05;
    }
#/
}

is_bot()
{
    return isplayer( self ) && isdefined( self.pers["isBot"] ) && self.pers["isBot"] != 0;
}

add_trigger_to_ent( ent )
{
    if ( !isdefined( ent._triggers ) )
        ent._triggers = [];

    ent._triggers[self getentitynumber()] = 1;
}

remove_trigger_from_ent( ent )
{
    if ( !isdefined( ent ) )
        return;

    if ( !isdefined( ent._triggers ) )
        return;

    if ( !isdefined( ent._triggers[self getentitynumber()] ) )
        return;

    ent._triggers[self getentitynumber()] = 0;
}

ent_already_in_trigger( trig )
{
    if ( !isdefined( self._triggers ) )
        return false;

    if ( !isdefined( self._triggers[trig getentitynumber()] ) )
        return false;

    if ( !self._triggers[trig getentitynumber()] )
        return false;

    return true;
}

trigger_thread_death_monitor( ent, ender )
{
    ent waittill( "death" );

    self endon( ender );
    self remove_trigger_from_ent( ent );
}

trigger_thread( ent, on_enter_payload, on_exit_payload )
{
    ent endon( "entityshutdown" );
    ent endon( "death" );

    if ( ent ent_already_in_trigger( self ) )
        return;

    self add_trigger_to_ent( ent );
    ender = "end_trig_death_monitor" + self getentitynumber() + " " + ent getentitynumber();
    self thread trigger_thread_death_monitor( ent, ender );
    endon_condition = "leave_trigger_" + self getentitynumber();

    if ( isdefined( on_enter_payload ) )
        self thread [[ on_enter_payload ]]( ent, endon_condition );

    while ( isdefined( ent ) && ent istouching( self ) )
        wait 0.01;

    ent notify( endon_condition );

    if ( isdefined( ent ) && isdefined( on_exit_payload ) )
        self thread [[ on_exit_payload ]]( ent );

    if ( isdefined( ent ) )
        self remove_trigger_from_ent( ent );

    self notify( ender );
}

isoneround()
{
    if ( level.roundlimit == 1 )
        return true;

    return false;
}

isfirstround()
{
    if ( level.roundlimit > 1 && game["roundsplayed"] == 0 )
        return true;

    return false;
}

islastround()
{
    if ( level.roundlimit > 1 && game["roundsplayed"] >= level.roundlimit - 1 )
        return true;

    return false;
}

waslastround()
{
    if ( level.forcedend )
        return true;

    if ( isdefined( level.shouldplayovertimeround ) )
    {
        if ( [[ level.shouldplayovertimeround ]]() )
        {
            level.nextroundisovertime = 1;
            return false;
        }
        else if ( isdefined( game["overtime_round"] ) )
            return true;
    }

    if ( hitroundlimit() || hitscorelimit() || hitroundwinlimit() )
        return true;

    return false;
}

hitroundlimit()
{
    if ( level.roundlimit <= 0 )
        return 0;

    return getroundsplayed() >= level.roundlimit;
}

anyteamhitroundwinlimit()
{
    foreach ( team in level.teams )
    {
        if ( getroundswon( team ) >= level.roundwinlimit )
            return true;
    }

    return false;
}

anyteamhitroundlimitwithdraws()
{
    tie_wins = game["roundswon"]["tie"];

    foreach ( team in level.teams )
    {
        if ( getroundswon( team ) + tie_wins >= level.roundwinlimit )
            return true;
    }

    return false;
}

getroundwinlimitwinningteam()
{
    max_wins = 0;
    winning_team = undefined;

    foreach ( team in level.teams )
    {
        wins = getroundswon( team );

        if ( !isdefined( winning_team ) )
        {
            max_wins = wins;
            winning_team = team;
            continue;
        }

        if ( wins == max_wins )
        {
            winning_team = "tie";
            continue;
        }

        if ( wins > max_wins )
        {
            max_wins = wins;
            winning_team = team;
        }
    }

    return winning_team;
}

hitroundwinlimit()
{
    if ( !isdefined( level.roundwinlimit ) || level.roundwinlimit <= 0 )
        return false;

    if ( anyteamhitroundwinlimit() )
        return true;

    if ( anyteamhitroundlimitwithdraws() )
    {
        if ( getroundwinlimitwinningteam() != "tie" )
            return true;
    }

    return false;
}

anyteamhitscorelimit()
{
    foreach ( team in level.teams )
    {
        if ( game["teamScores"][team] >= level.scorelimit )
            return true;
    }

    return false;
}

hitscorelimit()
{
    if ( isscoreroundbased() )
        return false;

    if ( level.scorelimit <= 0 )
        return false;

    if ( level.teambased )
    {
        if ( anyteamhitscorelimit() )
            return true;
    }
    else
    {
        for ( i = 0; i < level.players.size; i++ )
        {
            player = level.players[i];

            if ( isdefined( player.pointstowin ) && player.pointstowin >= level.scorelimit )
                return true;
        }
    }

    return false;
}

getroundswon( team )
{
    return game["roundswon"][team];
}

getotherteamsroundswon( skip_team )
{
    roundswon = 0;

    foreach ( team in level.teams )
    {
        if ( team == skip_team )
            continue;

        roundswon += game["roundswon"][team];
    }

    return roundswon;
}

getroundsplayed()
{
    return game["roundsplayed"];
}

isscoreroundbased()
{
    return level.scoreroundbased;
}

isroundbased()
{
    if ( level.roundlimit != 1 && level.roundwinlimit != 1 )
        return true;

    return false;
}

waittillnotmoving()
{
    if ( self ishacked() )
    {
        wait 0.05;
        return;
    }

    if ( self.classname == "grenade" )
        self waittill( "stationary" );
    else
    {
        for ( prevorigin = self.origin; 1; prevorigin = self.origin )
        {
            wait 0.15;

            if ( self.origin == prevorigin )
                break;
        }
    }
}

mayapplyscreeneffect()
{
    assert( isdefined( self ) );
    assert( isplayer( self ) );
    return !isdefined( self.viewlockedentity );
}

getdvarfloatdefault( dvarname, defaultvalue )
{
    value = getdvar( dvarname );

    if ( value != "" )
        return float( value );

    return defaultvalue;
}

getdvarintdefault( dvarname, defaultvalue )
{
    value = getdvar( dvarname );

    if ( value != "" )
        return int( value );

    return defaultvalue;
}

closestpointonline( point, linestart, lineend )
{
    linemagsqrd = lengthsquared( lineend - linestart );
    t = ( ( point[0] - linestart[0] ) * ( lineend[0] - linestart[0] ) + ( point[1] - linestart[1] ) * ( lineend[1] - linestart[1] ) + ( point[2] - linestart[2] ) * ( lineend[2] - linestart[2] ) ) / linemagsqrd;

    if ( t < 0.0 )
        return linestart;
    else if ( t > 1.0 )
        return lineend;

    start_x = linestart[0] + t * ( lineend[0] - linestart[0] );
    start_y = linestart[1] + t * ( lineend[1] - linestart[1] );
    start_z = linestart[2] + t * ( lineend[2] - linestart[2] );
    return ( start_x, start_y, start_z );
}

isstrstart( string1, substr )
{
    return getsubstr( string1, 0, substr.size ) == substr;
}

spread_array_thread( entities, process, var1, var2, var3 )
{
    keys = getarraykeys( entities );

    if ( isdefined( var3 ) )
    {
        for ( i = 0; i < keys.size; i++ )
        {
            entities[keys[i]] thread [[ process ]]( var1, var2, var3 );
            wait 0.1;
        }

        return;
    }

    if ( isdefined( var2 ) )
    {
        for ( i = 0; i < keys.size; i++ )
        {
            entities[keys[i]] thread [[ process ]]( var1, var2 );
            wait 0.1;
        }

        return;
    }

    if ( isdefined( var1 ) )
    {
        for ( i = 0; i < keys.size; i++ )
        {
            entities[keys[i]] thread [[ process ]]( var1 );
            wait 0.1;
        }

        return;
    }

    for ( i = 0; i < keys.size; i++ )
    {
        entities[keys[i]] thread [[ process ]]();
        wait 0.1;
    }
}

freeze_player_controls( boolean )
{
    assert( isdefined( boolean ), "'freeze_player_controls()' has not been passed an argument properly." );

    if ( boolean && isdefined( self ) )
        self freezecontrols( boolean );
    else if ( !boolean && isdefined( self ) && !level.gameended )
        self freezecontrols( boolean );
}

gethostplayer()
{
    players = get_players();

    for ( index = 0; index < players.size; index++ )
    {
        if ( players[index] ishost() )
            return players[index];
    }
}

gethostplayerforbots()
{
    players = get_players();

    for ( index = 0; index < players.size; index++ )
    {
        if ( players[index] ishostforbots() )
            return players[index];
    }
}

ispregame()
{
    return isdefined( level.pregame ) && level.pregame;
}

iskillstreaksenabled()
{
    return isdefined( level.killstreaksenabled ) && level.killstreaksenabled;
}

isrankenabled()
{
    return isdefined( level.rankenabled ) && level.rankenabled;
}

playsmokesound( position, duration, startsound, stopsound, loopsound )
{
    smokesound = spawn( "script_origin", ( 0, 0, 1 ) );
    smokesound.origin = position;
    smokesound playsound( startsound );
    smokesound playloopsound( loopsound );

    if ( duration > 0.5 )
        wait( duration - 0.5 );

    thread playsoundinspace( stopsound, position );
    smokesound stoploopsound( 0.5 );
    wait 0.5;
    smokesound delete();
}

playsoundinspace( alias, origin, master )
{
    org = spawn( "script_origin", ( 0, 0, 1 ) );

    if ( !isdefined( origin ) )
        origin = self.origin;

    org.origin = origin;

    if ( isdefined( master ) && master )
        org playsoundasmaster( alias );
    else
        org playsound( alias );

    wait 10.0;
    org delete();
}

get2dyaw( start, end )
{
    yaw = 0;
    vector = ( end[0] - start[0], end[1] - start[1], 0 );
    return vectoangles( vector );
}

vectoangles( vector )
{
    yaw = 0;
    vecx = vector[0];
    vecy = vector[1];

    if ( vecx == 0 && vecy == 0 )
        return 0;

    if ( vecy < 0.001 && vecy > -0.001 )
        vecy = 0.001;

    yaw = atan( vecx / vecy );

    if ( vecy < 0 )
        yaw += 180;

    return 90 - yaw;
}

deleteaftertime( time )
{
    assert( isdefined( self ) );
    assert( isdefined( time ) );
    assert( time >= 0.05 );
    self thread deleteaftertimethread( time );
}

deleteaftertimethread( time )
{
    self endon( "death" );
    wait( time );
    self delete();
}

setusingremote( remotename )
{
    if ( isdefined( self.carryicon ) )
        self.carryicon.alpha = 0;

    assert( !self isusingremote() );
    self.usingremote = remotename;
    self disableoffhandweapons();
    self notify( "using_remote" );
}

getremotename()
{
    assert( self isusingremote() );
    return self.usingremote;
}

isusingremote()
{
    return isdefined( self.usingremote );
}

getlastweapon()
{
    last_weapon = undefined;

    if ( self hasweapon( self.lastnonkillstreakweapon ) )
        last_weapon = self.lastnonkillstreakweapon;
    else if ( self hasweapon( self.lastdroppableweapon ) )
        last_weapon = self.lastdroppableweapon;

    assert( isdefined( last_weapon ) );
    return last_weapon;
}

freezecontrolswrapper( frozen )
{
    if ( isdefined( level.hostmigrationtimer ) )
    {
        self freeze_player_controls( 1 );
        return;
    }

    self freeze_player_controls( frozen );
}

setobjectivetext( team, text )
{
    game["strings"]["objective_" + team] = text;
    precachestring( text );
}

setobjectivescoretext( team, text )
{
    game["strings"]["objective_score_" + team] = text;
    precachestring( text );
}

setobjectivehinttext( team, text )
{
    game["strings"]["objective_hint_" + team] = text;
    precachestring( text );
}

getobjectivetext( team )
{
    return game["strings"]["objective_" + team];
}

getobjectivescoretext( team )
{
    return game["strings"]["objective_score_" + team];
}

getobjectivehinttext( team )
{
    return game["strings"]["objective_hint_" + team];
}

registerroundswitch( minvalue, maxvalue )
{
    level.roundswitch = clamp( getgametypesetting( "roundSwitch" ), minvalue, maxvalue );
    level.roundswitchmin = minvalue;
    level.roundswitchmax = maxvalue;
}

registerroundlimit( minvalue, maxvalue )
{
    level.roundlimit = clamp( getgametypesetting( "roundLimit" ), minvalue, maxvalue );
    level.roundlimitmin = minvalue;
    level.roundlimitmax = maxvalue;
}

registerroundwinlimit( minvalue, maxvalue )
{
    level.roundwinlimit = clamp( getgametypesetting( "roundWinLimit" ), minvalue, maxvalue );
    level.roundwinlimitmin = minvalue;
    level.roundwinlimitmax = maxvalue;
}

registerscorelimit( minvalue, maxvalue )
{
    level.scorelimit = clamp( getgametypesetting( "scoreLimit" ), minvalue, maxvalue );
    level.scorelimitmin = minvalue;
    level.scorelimitmax = maxvalue;
    setdvar( "ui_scorelimit", level.scorelimit );
}

registertimelimit( minvalue, maxvalue )
{
    level.timelimit = clamp( getgametypesetting( "timeLimit" ), minvalue, maxvalue );
    level.timelimitmin = minvalue;
    level.timelimitmax = maxvalue;
    setdvar( "ui_timelimit", level.timelimit );
}

registernumlives( minvalue, maxvalue )
{
    level.numlives = clamp( getgametypesetting( "playerNumLives" ), minvalue, maxvalue );
    level.numlivesmin = minvalue;
    level.numlivesmax = maxvalue;
}

getplayerfromclientnum( clientnum )
{
    if ( clientnum < 0 )
        return undefined;

    for ( i = 0; i < level.players.size; i++ )
    {
        if ( level.players[i] getentitynumber() == clientnum )
            return level.players[i];
    }

    return undefined;
}

setclientfield( field_name, value )
{
    if ( self == level )
        codesetworldclientfield( field_name, value );
    else
        codesetclientfield( self, field_name, value );
}

setclientfieldtoplayer( field_name, value )
{
    codesetplayerstateclientfield( self, field_name, value );
}

getclientfield( field_name )
{
    if ( self == level )
        return codegetworldclientfield( field_name );
    else
        return codegetclientfield( self, field_name );
}

getclientfieldtoplayer( field_name )
{
    return codegetplayerstateclientfield( self, field_name );
}

isenemyplayer( player )
{
    assert( isdefined( player ) );

    if ( !isplayer( player ) )
        return false;

    if ( level.teambased )
    {
        if ( player.team == self.team )
            return false;
    }
    else if ( player == self )
        return false;

    return true;
}

getweaponclass( weapon )
{
    assert( isdefined( weapon ) );

    if ( !isdefined( weapon ) )
        return undefined;

    if ( !isdefined( level.weaponclassarray ) )
        level.weaponclassarray = [];

    if ( isdefined( level.weaponclassarray[weapon] ) )
        return level.weaponclassarray[weapon];

    baseweaponindex = getbaseweaponitemindex( weapon ) + 1;
    weaponclass = tablelookupcolumnforrow( "mp/statstable.csv", baseweaponindex, 2 );
    level.weaponclassarray[weapon] = weaponclass;
    return weaponclass;
}

ispressbuild()
{
    buildtype = getdvar( _hash_19B966D7 );

    if ( isdefined( buildtype ) && buildtype == "press" )
        return true;

    return false;
}

isflashbanged()
{
    return isdefined( self.flashendtime ) && gettime() < self.flashendtime;
}

ishacked()
{
    return isdefined( self.hacked ) && self.hacked;
}

domaxdamage( origin, attacker, inflictor, headshot, mod )
{
    if ( isdefined( self.damagedtodeath ) && self.damagedtodeath )
        return;

    if ( isdefined( self.maxhealth ) )
        damage = self.maxhealth + 1;
    else
        damage = self.health + 1;

    self.damagedtodeath = 1;
    self dodamage( damage, origin, attacker, inflictor, headshot, mod );
}
