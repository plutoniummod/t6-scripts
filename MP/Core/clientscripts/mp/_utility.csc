// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility_code;

error( message )
{
/#
    println( "^c * ERROR * ", message );
    wait 0.05;
#/
}

getstruct( name, type )
{
    if ( !isdefined( level.struct_class_names ) )
        return undefined;

    array = level.struct_class_names[type][name];

    if ( !isdefined( array ) )
    {
/#
        println( "**** Getstruct returns undefined on " + name + " : " + " type." );
#/
        return undefined;
    }

    if ( array.size > 1 )
    {
/#
        assertmsg( "getstruct used for more than one struct of type " + type + " called " + name + "." );
#/
        return undefined;
    }

    return array[0];
}

getstructarray( name, type )
{
    assert( isdefined( level.struct_class_names ), "Tried to getstruct before the structs were init" );
    array = level.struct_class_names[type][name];

    if ( !isdefined( array ) )
        return [];
    else
        return array;
}

play_sound_in_space( localclientnum, alias, origin )
{
    playsound( localclientnum, alias, origin );
}

vector_compare( vec1, vec2 )
{
    return abs( vec1[0] - vec2[0] ) < 0.001 && abs( vec1[1] - vec2[1] ) < 0.001 && abs( vec1[2] - vec2[2] ) < 0.001;
}

array_func( entities, func, arg1, arg2, arg3, arg4, arg5 )
{
    if ( !isdefined( entities ) )
        return;

    if ( isarray( entities ) )
    {
        if ( entities.size )
        {
            keys = getarraykeys( entities );

            for ( i = 0; i < keys.size; i++ )
                single_func( entities[keys[i]], func, arg1, arg2, arg3, arg4, arg5 );
        }
    }
    else
        single_func( entities, func, arg1, arg2, arg3, arg4, arg5 );
}

single_func( entity, func, arg1, arg2, arg3, arg4, arg5 )
{
    if ( isdefined( arg5 ) )
        entity [[ func ]]( arg1, arg2, arg3, arg4, arg5 );
    else if ( isdefined( arg4 ) )
        entity [[ func ]]( arg1, arg2, arg3, arg4 );
    else if ( isdefined( arg3 ) )
        entity [[ func ]]( arg1, arg2, arg3 );
    else if ( isdefined( arg2 ) )
        entity [[ func ]]( arg1, arg2 );
    else if ( isdefined( arg1 ) )
        entity [[ func ]]( arg1 );
    else
        entity [[ func ]]();
}

array_thread( entities, func, arg1, arg2, arg3, arg4, arg5 )
{
    if ( !isdefined( entities ) )
        return;

    if ( isarray( entities ) )
    {
        if ( entities.size )
        {
            keys = getarraykeys( entities );

            for ( i = 0; i < keys.size; i++ )
                single_thread( entities[keys[i]], func, arg1, arg2, arg3, arg4, arg5 );
        }
    }
    else
        single_thread( entities, func, arg1, arg2, arg3, arg4, arg5 );
}

single_thread( entity, func, arg1, arg2, arg3, arg4, arg5 )
{
    if ( isdefined( arg5 ) )
        entity thread [[ func ]]( arg1, arg2, arg3, arg4, arg5 );
    else if ( isdefined( arg4 ) )
        entity thread [[ func ]]( arg1, arg2, arg3, arg4 );
    else if ( isdefined( arg3 ) )
        entity thread [[ func ]]( arg1, arg2, arg3 );
    else if ( isdefined( arg2 ) )
        entity thread [[ func ]]( arg1, arg2 );
    else if ( isdefined( arg1 ) )
        entity thread [[ func ]]( arg1 );
    else
        entity thread [[ func ]]();
}

registersystem( ssysname, cbfunc )
{
    if ( !isdefined( level._systemstates ) )
        level._systemstates = [];

    if ( level._systemstates.size >= 32 )
    {
/#
        error( "Max num client systems exceeded." );
#/
        return;
    }

    if ( isdefined( level._systemstates[ssysname] ) )
    {
/#
        error( "Attempt to re-register client system : " + ssysname );
#/
        return;
    }
    else
    {
        level._systemstates[ssysname] = spawnstruct();
        level._systemstates[ssysname].callback = cbfunc;
    }
}

loop_sound_delete( ender, entid )
{
    self waittill( ender );
    deletefakeent( 0, entid );
}

loop_fx_sound( clientnum, alias, origin, ender )
{
    entid = spawnfakeent( clientnum );

    if ( isdefined( ender ) )
    {
        thread loop_sound_delete( ender, entid );
        self endon( ender );
    }

    setfakeentorg( clientnum, entid, origin );
    playloopsound( clientnum, entid, alias );
}

waitforallclients()
{
    localclient = 0;

    if ( !isdefined( level.localplayers ) )
    {
        while ( !isdefined( level.localplayers ) )
            wait 0.01;
    }

    while ( localclient < level.localplayers.size )
    {
        waitforclient( localclient );
        localclient++;
    }
}

waitforclient( client )
{
    while ( !clienthassnapshot( client ) )
        wait 0.01;
}

waittill_string( msg, ent )
{
    if ( msg != "death" )
        self endon( "death" );

    ent endon( "die" );
    self waittill( msg );
    ent notify( "returned", msg );
}

waittill_dobj( localclientnum )
{
    while ( isdefined( self ) && !self hasdobj( localclientnum ) )
        wait 0.01;
}

waittill_any_return( string1, string2, string3, string4, string5, string6 )
{
    if ( ( !isdefined( string1 ) || string1 != "death" ) && ( !isdefined( string2 ) || string2 != "death" ) && ( !isdefined( string3 ) || string3 != "death" ) && ( !isdefined( string4 ) || string4 != "death" ) && ( !isdefined( string5 ) || string5 != "death" ) && ( !isdefined( string6 ) || string6 != "death" ) )
        self endon( "death" );

    ent = spawnstruct();

    if ( isdefined( string1 ) )
        self thread waittill_string( string1, ent );

    if ( isdefined( string2 ) )
        self thread waittill_string( string2, ent );

    if ( isdefined( string3 ) )
        self thread waittill_string( string3, ent );

    if ( isdefined( string4 ) )
        self thread waittill_string( string4, ent );

    if ( isdefined( string5 ) )
        self thread waittill_string( string5, ent );

    if ( isdefined( string6 ) )
        self thread waittill_string( string6, ent );

    ent waittill( "returned", msg );
    ent notify( "die" );
    return msg;
}

waittill_any( string1, string2, string3, string4, string5 )
{
    assert( isdefined( string1 ) );

    if ( isdefined( string2 ) )
        self endon( string2 );

    if ( isdefined( string3 ) )
        self endon( string3 );

    if ( isdefined( string4 ) )
        self endon( string4 );

    if ( isdefined( string5 ) )
        self endon( string5 );

    self waittill( string1 );
}

within_fov( start_origin, start_angles, end_origin, fov )
{
    normal = vectornormalize( end_origin - start_origin );
    forward = anglestoforward( start_angles );
    dot = vectordot( forward, normal );
    return dot >= fov;
}

array( a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z )
{
    array = [];

    if ( isdefined( a ) )
        array[0] = a;
    else
        return array;

    if ( isdefined( b ) )
        array[1] = b;
    else
        return array;

    if ( isdefined( c ) )
        array[2] = c;
    else
        return array;

    if ( isdefined( d ) )
        array[3] = d;
    else
        return array;

    if ( isdefined( e ) )
        array[4] = e;
    else
        return array;

    if ( isdefined( f ) )
        array[5] = f;
    else
        return array;

    if ( isdefined( g ) )
        array[6] = g;
    else
        return array;

    if ( isdefined( h ) )
        array[7] = h;
    else
        return array;

    if ( isdefined( i ) )
        array[8] = i;
    else
        return array;

    if ( isdefined( j ) )
        array[9] = j;
    else
        return array;

    if ( isdefined( k ) )
        array[10] = k;
    else
        return array;

    if ( isdefined( l ) )
        array[11] = l;
    else
        return array;

    if ( isdefined( m ) )
        array[12] = m;
    else
        return array;

    if ( isdefined( n ) )
        array[13] = n;
    else
        return array;

    if ( isdefined( o ) )
        array[14] = o;
    else
        return array;

    if ( isdefined( p ) )
        array[15] = p;
    else
        return array;

    if ( isdefined( q ) )
        array[16] = q;
    else
        return array;

    if ( isdefined( r ) )
        array[17] = r;
    else
        return array;

    if ( isdefined( s ) )
        array[18] = s;
    else
        return array;

    if ( isdefined( t ) )
        array[19] = t;
    else
        return array;

    if ( isdefined( u ) )
        array[20] = u;
    else
        return array;

    if ( isdefined( v ) )
        array[21] = v;
    else
        return array;

    if ( isdefined( w ) )
        array[22] = w;
    else
        return array;

    if ( isdefined( x ) )
        array[23] = x;
    else
        return array;

    if ( isdefined( y ) )
        array[24] = y;
    else
        return array;

    if ( isdefined( z ) )
        array[25] = z;

    return array;
}

add_to_array( array, ent, allow_dupes )
{
    if ( !isdefined( ent ) )
        return array;

    if ( !isdefined( allow_dupes ) )
        allow_dupes = 1;

    if ( !isdefined( array ) )
        array[0] = ent;
    else if ( allow_dupes || !isinarray( array, ent ) )
        array[array.size] = ent;

    return array;
}

array_delete( array )
{
    for ( i = 0; i < array.size; i++ )
        array[i] delete();
}

array_randomize( array )
{
    for ( i = 0; i < array.size; i++ )
    {
        j = randomint( array.size );
        temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }

    return array;
}

array_reverse( array )
{
    array2 = [];

    for ( i = array.size - 1; i >= 0; i-- )
        array2[array2.size] = array[i];

    return array2;
}

array_exclude( array, arrayexclude )
{
    newarray = arraycopy( array );

    for ( i = 0; i < arrayexclude.size; i++ )
        arrayremovevalue( newarray, arrayexclude[i] );

    return newarray;
}

array_notify( ents, notifier )
{
    for ( i = 0; i < ents.size; i++ )
        ents[i] notify( notifier );
}

array_wait( array, msg, timeout )
{
    keys = getarraykeys( array );
    structs = [];

    for ( i = 0; i < keys.size; i++ )
    {
        key = keys[i];
        structs[key] = spawnstruct();
        structs[key]._array_wait = 1;
        structs[key] thread array_waitlogic1( array[key], msg, timeout );
    }

    for ( i = 0; i < keys.size; i++ )
    {
        key = keys[i];

        if ( isdefined( array[key] ) && structs[key]._array_wait )
            structs[key] waittill( "_array_wait" );
    }
}

array_waitlogic1( ent, msg, timeout )
{
    self array_waitlogic2( ent, msg, timeout );
    self._array_wait = 0;
    self notify( "_array_wait" );
}

array_waitlogic2( ent, msg, timeout )
{
    ent endon( msg );
    ent endon( "death" );

    if ( isdefined( timeout ) )
        wait( timeout );
    else
        ent waittill( msg );
}

array_check_for_dupes( array, single )
{
    for ( i = 0; i < array.size; i++ )
    {
        if ( array[i] == single )
            return false;
    }

    return true;
}

array_swap( array, index1, index2 )
{
    assert( index1 < array.size, "index1 to swap out of range" );
    assert( index2 < array.size, "index2 to swap out of range" );
    temp = array[index1];
    array[index1] = array[index2];
    array[index2] = temp;
    return array;
}

random( array )
{
    return array[randomint( array.size )];
}

add_trigger_to_ent( ent, trig )
{
    if ( !isdefined( ent._triggers ) )
        ent._triggers = [];

    ent._triggers[trig getentitynumber()] = 1;
}

remove_trigger_from_ent( ent, trig )
{
    if ( !isdefined( ent._triggers ) )
        return;

    if ( !isdefined( ent._triggers[trig getentitynumber()] ) )
        return;

    ent._triggers[trig getentitynumber()] = 0;
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

trigger_thread( ent, on_enter_payload, on_exit_payload )
{
    ent endon( "entityshutdown" );

    if ( ent ent_already_in_trigger( self ) )
        return;

    add_trigger_to_ent( ent, self );

    if ( isdefined( on_enter_payload ) )
        [[ on_enter_payload ]]( ent );

    while ( isdefined( ent ) && ent istouching( self ) )
        wait 0.01;

    if ( isdefined( ent ) && isdefined( on_exit_payload ) )
        [[ on_exit_payload ]]( ent );

    if ( isdefined( ent ) )
        remove_trigger_from_ent( ent, self );
}

local_player_trigger_thread_always_exit( ent, on_enter_payload, on_exit_payload )
{
    if ( ent ent_already_in_trigger( self ) )
        return;

    add_trigger_to_ent( ent, self );

    if ( isdefined( on_enter_payload ) )
        [[ on_enter_payload ]]( ent );

    while ( isdefined( ent ) && ent istouching( self ) && ent issplitscreenhost() )
        wait 0.01;

    if ( isdefined( on_exit_payload ) )
        [[ on_exit_payload ]]( ent );

    if ( isdefined( ent ) )
        remove_trigger_from_ent( ent, self );
}

friendnotfoe( localclientindex )
{
    player = getlocalplayer( localclientindex );

    if ( isdefined( player ) && player getinkillcam( localclientindex ) )
        player = getnonpredictedlocalplayer( localclientindex );

    if ( isdefined( player ) && isdefined( player.team ) )
    {
        team = player.team;

        if ( team == "free" )
        {
            owner = self getowner( localclientindex );

            if ( isdefined( owner ) && owner == player )
                return true;
        }
        else if ( self.team == team )
            return true;
    }

    return false;
}

watchforplayerrespawnforteambasedfx( localclientnum, entity, startfxfunc, fxhandle, optarg1 )
{
    entity endon( "entityshutdown" );
    entity endon( "teamBased_fx_reinitialized" );

    for (;;)
    {
        level waittill( "respawn", clientnum );

        if ( clientnum != localclientnum )
            continue;

        if ( isdefined( fxhandle ) )
            stopfx( localclientnum, fxhandle );

        waittillframeend;

        if ( isdefined( optarg1 ) )
            entity thread [[ startfxfunc ]]( localclientnum, optarg1 );
        else
            entity thread [[ startfxfunc ]]( localclientnum );

        break;
    }
}

waittillsnapprocessed( localclientindex )
{
    for (;;)
    {
        level waittill( "snap_processed", snapshotlocalclientnum );

        if ( localclientindex != snapshotlocalclientnum )
            continue;

        break;
    }
}

local_player_entity_thread( localclientnum, entity, func, arg1, arg2, arg3, arg4 )
{
    entity endon( "entityshutdown" );
    entity waittill_dobj( localclientnum );
    single_thread( entity, func, localclientnum, arg1, arg2, arg3, arg4 );
}

local_players_entity_thread( entity, func, arg1, arg2, arg3, arg4 )
{
    players = level.localplayers;

    for ( i = 0; i < players.size; i++ )
        players[i] thread local_player_entity_thread( i, entity, func, arg1, arg2, arg3, arg4 );
}

is_true( check )
{
    return isdefined( check ) && check;
}

is_false( check )
{
    return isdefined( check ) && !check;
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

debug_line( from, to, color, time )
{
/#
    level.debug_line = getdvarintdefault( "scr_debug_line", 0 );

    if ( isdefined( level.debug_line ) && level.debug_line == 1.0 )
    {
        if ( !isdefined( time ) )
            time = 1000;

        line( from, to, color, 1, 1, time );
    }
#/
}

debug_star( origin, color, time )
{
/#
    level.debug_star = getdvarintdefault( "scr_debug_star", 0 );

    if ( isdefined( level.debug_star ) && level.debug_star == 1.0 )
    {
        if ( !isdefined( time ) )
            time = 1000;

        if ( !isdefined( color ) )
            color = ( 1, 1, 1 );

        debugstar( origin, time, color );
    }
#/
}

initutility()
{
    level.isdemoplaying = isdemoplaying();
    level.localplayers = [];
    level.numgametypereservedobjectives = [];
    level.releasedobjectives = [];
    maxlocalclients = getmaxlocalclients();

    for ( localclientnum = 0; localclientnum < maxlocalclients; localclientnum++ )
    {
        level.releasedobjectives[localclientnum] = [];
        level.numgametypereservedobjectives[localclientnum] = 0;
    }

    waitforclient( 0 );
    level.localplayers = getlocalplayers();
}

servertime()
{
    for (;;)
    {
        level.servertime = getservertime( 0 );
        wait 0.01;
    }
}

serverwait( localclientnum, seconds, waitbetweenchecks, level_endon )
{
    if ( isdefined( level_endon ) )
        level endon( level_endon );

    if ( level.isdemoplaying && seconds != 0 )
    {
        if ( !isdefined( waitbetweenchecks ) )
            waitbetweenchecks = 0.2;

        waitcompletedsuccessfully = 0;
        starttime = level.servertime;
        lasttime = starttime;
        endtime = starttime + seconds * 1000;

        while ( level.servertime < endtime && level.servertime >= lasttime )
        {
            lasttime = level.servertime;
            wait( waitbetweenchecks );
        }

        if ( lasttime < level.servertime )
            waitcompletedsuccessfully = 1;
    }
    else
    {
        waitrealtime( seconds );
        waitcompletedsuccessfully = 1;
    }

    return waitcompletedsuccessfully;
}

isplayerviewlinkedtoentity( localclientnum )
{
    if ( self isdriving( localclientnum ) )
        return true;

    if ( self islocalplayerweaponviewonlylinked() )
        return true;

    return false;
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

isgrenadelauncherweapon( weapon )
{
    if ( getsubstr( weapon, 0, 2 ) == "gl_" )
        return true;

    switch ( weapon )
    {
        case "china_lake_mp":
        case "xm25_mp":
            return true;
        default:
            return false;
    }
}

isdumbrocketlauncherweapon( weapon )
{
    switch ( weapon )
    {
        case "ai_tank_drone_rocket_mp":
        case "m220_tow_mp":
        case "rpg_mp":
        case "smaw_mp":
        case "usrpg_mp":
            return true;
        default:
            return false;
    }
}

isguidedrocketlauncherweapon( weapon )
{
    switch ( weapon )
    {
        case "fhj18_mp":
        case "javelin_mp":
        case "m202_flash_mp":
        case "m72_law_mp":
        case "smaw_mp":
            return true;
        default:
            return false;
    }
}

isrocketlauncherweapon( weapon )
{
    if ( isdumbrocketlauncherweapon( weapon ) )
        return true;

    if ( isguidedrocketlauncherweapon( weapon ) )
        return true;

    return false;
}

islauncherweapon( weapon )
{
    if ( isrocketlauncherweapon( weapon ) )
        return true;

    if ( isgrenadelauncherweapon( weapon ) )
        return true;

    return false;
}

getnextobjid( localclientnum )
{
    nextid = 0;

    if ( level.releasedobjectives[localclientnum].size > 0 )
    {
        nextid = level.releasedobjectives[localclientnum][level.releasedobjectives[localclientnum].size - 1];
        level.releasedobjectives[localclientnum][level.releasedobjectives[localclientnum].size - 1] = undefined;
    }
    else
    {
        nextid = level.numgametypereservedobjectives[localclientnum];
        level.numgametypereservedobjectives[localclientnum]++;
    }

/#
    if ( nextid > 31 )
        println( "^3SCRIPT WARNING: Ran out of objective IDs" );

    assert( nextid < 32 );
#/

    if ( nextid > 31 )
        nextid = 31;

    return nextid;
}

releaseobjid( localclientnum, objid )
{
    assert( objid < level.numgametypereservedobjectives[localclientnum] );

    for ( i = 0; i < level.releasedobjectives[localclientnum].size; i++ )
    {
        if ( objid == level.releasedobjectives[localclientnum][i] && objid == 31 )
            return;

        assert( objid != level.releasedobjectives[localclientnum][i] );
    }

    level.releasedobjectives[localclientnum][level.releasedobjectives[localclientnum].size] = objid;
}

clamp( val, val_min, val_max )
{
    if ( val < val_min )
        val = val_min;
    else if ( val > val_max )
        val = val_max;

    return val;
}

newtimer()
{
    s_timer = spawnstruct();
    s_timer.n_time_created = gettime();
    return s_timer;
}

timergettime()
{
    t_now = gettime();
    return t_now - self.n_time_created;
}

timergettimeseconds()
{
    return timergettime() / 1000;
}

timerwait( n_wait )
{
    wait( n_wait );
    return timergettimeseconds();
}

lerpdvar( str_dvar, n_val, n_lerp_time, b_saved_dvar )
{
    n_start_val = getdvarflaot( str_dvar );
    s_timer = newtimer();

    do
    {
        n_time_delta = s_timer timerwait( 0.05 );
        n_curr_val = lerpfloat( n_start_val, n_val, n_time_delta / n_lerp_time );

        if ( is_true( b_saved_dvar ) )
        {
            setsaveddvar( str_dvar, n_curr_val );
            continue;
        }

        setdvar( str_dvar, n_curr_val );
    }
    while (n_time_delta < n_lerp_time );
}

newservertimer()
{
    s_timer = spawnstruct();
    s_timer.n_time_created = level.servertime;
    return s_timer;
}

timerservergettime()
{
    t_now = level.servertime;
    return t_now - self.n_time_created;
}

timerservergettimeseconds()
{
    return level.servertime / 1000;
}

servertimerwait( localclientnum, n_wait )
{
    serverwait( localclientnum, n_wait );
    return timerservergettimeseconds();
}

serverlerpdvar( localclientnum, str_dvar, n_val, n_lerp_time, b_saved_dvar )
{
    n_start_val = getdvarflaot( str_dvar );
    s_timer = newtimer();

    do
    {
        n_time_delta = s_timer servertimerwait( localclientnum, 0.05 );
        n_curr_val = lerpfloat( n_start_val, n_val, n_time_delta / n_lerp_time );

        if ( is_true( b_saved_dvar ) )
        {
            setsaveddvar( str_dvar, n_curr_val );
            continue;
        }

        setdvar( str_dvar, n_curr_val );
    }
    while (n_time_delta < n_lerp_time );
}