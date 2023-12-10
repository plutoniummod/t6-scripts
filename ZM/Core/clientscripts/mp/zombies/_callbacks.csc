// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_vehicle;
#include clientscripts\mp\zombies\_players;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_explode;
#include clientscripts\mp\_footsteps;
#include clientscripts\mp\zombies\_callbacks;
#include clientscripts\mp\_fx;
#include clientscripts\mp\zombies\_zm_gump;

statechange( clientnum, system, newstate )
{
    if ( !isdefined( level._systemstates ) )
        level._systemstates = [];

    if ( !isdefined( level._systemstates[system] ) )
        level._systemstates[system] = spawnstruct();

    level._systemstates[system].state = newstate;

    if ( isdefined( level._systemstates[system].callback ) )
        [[ level._systemstates[system].callback ]]( clientnum, newstate );
    else
    {
/#
        println( "*** Unhandled client system state change - " + system + " - has no registered callback function." );
#/
    }
}

maprestart()
{
/#
    println( "*** Client script VM map restart." );
#/
    waitforclient( 0 );
    level thread clientscripts\mp\_utility::initutility();
    wait 0.016;
    level.localplayers = getlocalplayers();
}

localclientconnect( clientnum )
{
/#
    println( "*** Client script VM : Local client connect " + clientnum );
#/
    level thread clientscripts\mp\zombies\_players::on_connect( clientnum );
}

localclientdisconnect( clientnum )
{
/#
    println( "*** Client script VM : Local client disconnect " + clientnum );
#/
}

glass_smash( org, dir )
{
    level notify( "glass_smash", org, dir );
}

soundsetambientstate( ambientroom, ambientpackage, roomcollidercent, packagecollidercent, defaultroom )
{
    clientscripts\mp\_ambientpackage::setcurrentambientstate( ambientroom, ambientpackage, roomcollidercent, packagecollidercent, defaultroom );
}

soundsetaiambientstate( triggers, actors, numtriggers )
{
    self thread clientscripts\mp\_ambientpackage::setcurrentaiambientstate( triggers, actors, numtriggers );
}

playerspawned( localclientnum )
{
    self endon( "entityshutdown" );

    if ( isdefined( level._playerspawned_override ) )
    {
        self thread [[ level._playerspawned_override ]]( localclientnum );
        return;
    }

/#
    println( "Player spawned" );
#/
    self thread clientscripts\mp\_explode::playerspawned( localclientnum );
    self thread clientscripts\mp\zombies\_players::dtp_effects();

    if ( !sessionmodeiszombiesgame() )
    {

    }

    if ( isdefined( level._faceanimcbfunc ) )
        self thread [[ level._faceanimcbfunc ]]( localclientnum );
}

codecallback_gibevent( localclientnum, type, locations )
{
    if ( isdefined( level._gibeventcbfunc ) )
        self thread [[ level._gibeventcbfunc ]]( localclientnum, type, locations );
}

codecallback_precachegametype()
{
    if ( isdefined( level.callbackprecachegametype ) )
        [[ level.callbackprecachegametype ]]();
}

codecallback_startgametype()
{
    if ( isdefined( level.callbackstartgametype ) && ( !isdefined( level.gametypestarted ) || !level.gametypestarted ) )
    {
        [[ level.callbackstartgametype ]]();
        level.gametypestarted = 1;
    }
}

entityspawned( localclientnum )
{
    self endon( "entityshutdown" );

    if ( isdefined( level._entityspawned_override ) )
    {
        self thread [[ level._entityspawned_override ]]( localclientnum );
        return;
    }

    if ( !isdefined( self.type ) )
    {
/#
        println( "Entity type undefined!" );
#/
        return;
    }
}

entityshutdown_callback( localclientnum, entity )
{
    if ( isdefined( level._entityshutdowncbfunc ) )
        [[ level._entityshutdowncbfunc ]]( localclientnum, entity );
}

localclientchanged_callback( localclientnum )
{
    level.localplayers = getlocalplayers();
}

airsupport( localclientnum, x, y, z, type, yaw, team, teamfaction, owner, exittype, time, height )
{
    pos = ( x, y, z );

    switch ( teamfaction )
    {
        case "v":
            teamfaction = "vietcong";
            break;
        case "n":
        case "nva":
            teamfaction = "nva";
            break;
        case "j":
            teamfaction = "japanese";
            break;
        case "m":
            teamfaction = "marines";
            break;
        case "s":
            teamfaction = "specops";
            break;
        case "r":
            teamfaction = "russian";
            break;
        default:
/#
            println( "Warning: Invalid team char provided, defaulted to marines" );
#/
/#
            println( "Teamfaction received: " + teamfaction + "\\n" );
#/
            teamfaction = "marines";
            break;
    }

    switch ( team )
    {
        case "x":
            team = "axis";
            break;
        case "l":
            team = "allies";
            break;
        case "r":
            team = "free";
            break;
        default:
/#
            println( "Invalid team used with playclientAirstike/napalm: " + team + "\\n" );
#/
            team = "allies";
            break;
    }

    data = spawnstruct();
    data.team = team;
    data.owner = owner;
    data.bombsite = pos;
    data.yaw = yaw;
    direction = ( 0, yaw, 0 );
    data.direction = direction;
    data.flyheight = height;

    if ( type == "a" )
    {
        planehalfdistance = 12000;
        data.planehalfdistance = planehalfdistance;
        data.startpoint = pos + vectorscale( anglestoforward( direction ), -1 * planehalfdistance );
        data.endpoint = pos + vectorscale( anglestoforward( direction ), planehalfdistance );
        data.planemodel = "t5_veh_air_b52";
        data.flybysound = "null";
        data.washsound = "veh_b52_flyby_wash";
        data.apextime = 6145;
        data.exittype = -1;
        data.flyspeed = 2000;
        data.flytime = planehalfdistance * 2 / data.flyspeed;
        planetype = "airstrike";
    }
    else if ( type == "n" )
    {
        planehalfdistance = 24000;
        data.planehalfdistance = planehalfdistance;
        data.startpoint = pos + vectorscale( anglestoforward( direction ), -1 * planehalfdistance );
        data.endpoint = pos + vectorscale( anglestoforward( direction ), planehalfdistance );
        data.flybysound = "null";
        data.washsound = "evt_us_napalm_wash";
        data.apextime = 2362;
        data.exittype = exittype;
        data.flyspeed = 7000;
        data.flytime = planehalfdistance * 2 / data.flyspeed;
        planetype = "napalm";
    }
    else
    {
/#
        println( "" );
        println( "Unhandled airsupport type, only A (airstrike) and N (napalm) supported" );
        println( type );
        println( "" );
#/
        return;
    }
}

demo_jump( localclientnum, time )
{
    level notify( "demo_jump", time );
    level notify( "demo_jump" + localclientnum, time );
}

demo_player_switch( localclientnum )
{
    level notify( "demo_player_switch" );
    level notify( "demo_player_switch" + localclientnum );
}

player_switch( localclientnum )
{
    level notify( "player_switch" );
    level notify( "player_switch" + localclientnum );
}

killcam_begin( localclientnum, time )
{
    level notify( "killcam_begin", time );
    level notify( "killcam_begin" + localclientnum, time );
}

killcam_end( localclientnum, time )
{
    level notify( "killcam_end", time );
    level notify( "killcam_end" + localclientnum, time );
}

stunned_callback( localclientnum, set )
{
    self.stunned = set;
/#
    println( "stunned_callback" );
#/

    if ( set )
        self notify( "stunned" );
    else
        self notify( "not_stunned" );
}

emp_callback( localclientnum, set )
{
    self.emp = set;
/#
    println( "emp_callback" );
#/

    if ( set )
        self notify( "emp" );
    else
        self notify( "not_emp" );
}

proximity_callback( localclientnum, set )
{
    self.enemyinproximity = set;
}

client_flag_debug( msg )
{
/#
    if ( getdvarintdefault( "scr_client_flag_debug", 0 ) > 0 )
        println( msg );
#/
}

client_flag_callback( localclientnum, flag, set )
{
    assert( isdefined( level._client_flag_callbacks ) );
/#
    client_flag_debug( "*** client_flag_callback(): localClientNum: " + localclientnum + " flag: " + flag + " set: " + set + " self: " + self getentitynumber() + " self.type: " + self.type );
#/

    if ( !isdefined( level._client_flag_callbacks[self.type] ) )
    {
/#
        client_flag_debug( "*** client_flag_callback(): no callback defined for self.type: " + self.type );
#/
        return;
    }

    if ( isarray( level._client_flag_callbacks[self.type] ) )
    {
        if ( isdefined( level._client_flag_callbacks[self.type][flag] ) )
            self thread [[ level._client_flag_callbacks[self.type][flag] ]]( localclientnum, set );
    }
    else
        self thread [[ level._client_flag_callbacks[self.type] ]]( localclientnum, flag, set );
}

client_flagasval_callback( localclientnum, val )
{
    if ( isdefined( level._client_flagasval_callbacks ) && isdefined( level._client_flagasval_callbacks[self.type] ) )
        self thread [[ level._client_flagasval_callbacks[self.type] ]]( localclientnum, val );
}

codecallback_creatingcorpse( localclientnum, player )
{
    if ( self isburning() )
    {

    }
}

codecallback_playerjump( client_num, player, ground_type, firstperson, quiet, islouder )
{
    clientscripts\mp\_footsteps::playerjump( client_num, player, ground_type, firstperson, quiet, islouder );
}

codecallback_playerland( client_num, player, ground_type, firstperson, quiet, damageplayer, islouder )
{
    clientscripts\mp\_footsteps::playerland( client_num, player, ground_type, firstperson, quiet, damageplayer, islouder );
}

codecallback_playerfoliage( client_num, player, firstperson, quiet )
{
    clientscripts\mp\_footsteps::playerfoliage( client_num, player, firstperson, quiet );
}

codecallback_finalizeinitialization()
{
    callback( "on_finalize_initialization" );
}

onfinalizeinitialization_callback( func )
{
    clientscripts\mp\zombies\_callbacks::addcallback( "on_finalize_initialization", func );
}

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

callback_activate_exploder( exploder_id )
{
    if ( !isdefined( level._exploder_ids ) )
        return;

    keys = getarraykeys( level._exploder_ids );
    exploder = undefined;

    for ( i = 0; i < keys.size; i++ )
    {
        if ( level._exploder_ids[keys[i]] == exploder_id )
        {
            exploder = keys[i];
            break;
        }
    }

    if ( !isdefined( exploder ) )
        return;

    clientscripts\mp\_fx::activate_exploder( exploder );
}

callback_deactivate_exploder( exploder_id )
{
    if ( !isdefined( level._exploder_ids ) )
        return;

    keys = getarraykeys( level._exploder_ids );
    exploder = undefined;

    for ( i = 0; i < keys.size; i++ )
    {
        if ( level._exploder_ids[keys[i]] == exploder_id )
        {
            exploder = keys[i];
            break;
        }
    }

    if ( !isdefined( exploder ) )
        return;

    clientscripts\mp\_fx::deactivate_exploder( exploder );
}

codecallback_hostmigration()
{
/#
    println( "*** Client:  CodeCallback_HostMigration()" );
#/
    level thread prevent_round_switch_animation();
    clientscripts\mp\zombies\_zm_gump::hostmigration_blackscreen();
}

prevent_round_switch_animation()
{
    allowroundanimation( 0 );
    wait 3;
    allowroundanimation( 1 );
}

chargeshotweaponsoundnotify( localclientnum, weaponname, chargeshotlevel )
{
    if ( isdefined( level.sndchargeshot_func ) )
        self [[ level.sndchargeshot_func ]]( localclientnum, weaponname, chargeshotlevel );
}
