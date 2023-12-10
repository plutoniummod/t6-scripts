// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_callbacks;
#include clientscripts\mp\zombies\_zm_powerups;
#include clientscripts\mp\zombies\_zm_buildables;

is_valid_type_for_callback( type )
{
    switch ( type )
    {
        case "NA":
        case "actor":
        case "general":
        case "missile":
        case "plane":
        case "player":
        case "scriptmover":
        case "turret":
        case "vehicle":
            return true;
        default:
            return false;
    }
}

register_clientflag_callback( type, flag, function )
{
    if ( !is_valid_type_for_callback( type ) )
    {
/#
        assertmsg( type + " is not a valid entity type to have a callback function registered." );
#/
        return;
    }

    if ( isdefined( level._client_flag_callbacks[type][flag] ) )
    {
        if ( level._client_flag_callbacks[type][flag] == function )
            return;

/#
        println( "*** Free client flags for type " + type );
        free = "";

        for ( i = 0; i < 16; i++ )
        {
            if ( !isdefined( level._client_flag_callbacks[type][i] ) )
                free = free + ( i + " " );
        }

        if ( free == "" )
            free = "No free flags.";

        println( "*** " + free );
#/
/#
        assertmsg( "Flag " + flag + " is already registered for ent type " + type + ".  Please use a different flag number.  See console for list of free flags for this type." );
#/
        return;
    }

    level._client_flag_callbacks[type][flag] = function;
}

ignore_triggers( timer )
{
    self endon( "death" );
    self.ignoretriggers = 1;

    if ( isdefined( timer ) )
        wait( timer );
    else
        wait 0.5;

    self.ignoretriggers = 0;
}

clamp( val, val_min, val_max )
{
    if ( val < val_min )
        val = val_min;
    else if ( val > val_max )
        val = val_max;

    return val;
}

is_mature()
{
    if ( level.onlinegame )
        return 1;

    return ismaturecontentenabled();
}

init_fog_vol_to_visionset_monitor( default_visionset, default_trans_in, host_migration_active )
{
    level._fv2vs_default_visionset = default_visionset;
    level._fv2vs_default_trans_in = default_trans_in;
    level._fv2vs_unset_visionset = "_fv2vs_unset";
    level._fv2vs_prev_visionsets = [];
    level._fv2vs_prev_visionsets[0] = level._fv2vs_unset_visionset;
    level._fv2vs_prev_visionsets[1] = level._fv2vs_unset_visionset;
    level._fv2vs_prev_visionsets[2] = level._fv2vs_unset_visionset;
    level._fv2vs_prev_visionsets[3] = level._fv2vs_unset_visionset;

    if ( !isdefined( host_migration_active ) )
    {
        level._fv2vs_infos = [];
        fog_vol_to_visionset_set_info( -1, default_visionset, default_trans_in );
    }

    level._fogvols_inited = 1;
}

fog_vol_to_visionset_set_suffix( suffix )
{
    level._fv2vs_suffix = suffix;
}

fog_vol_to_visionset_set_info( id, visionset, trans_in )
{
    if ( !isdefined( trans_in ) )
        trans_in = level._fv2vs_default_trans_in;

    level._fv2vs_infos[id] = spawnstruct();
    level._fv2vs_infos[id].visionset = visionset;
    level._fv2vs_infos[id].trans_in = trans_in;
}

fog_vol_to_visionset_instant_transition_monitor()
{
    level endon( "vsionset_mgr_incontrol" );
    level._fv2vs_force_instant_transition = 0;
    level thread fog_vol_to_visionset_hostmigration_monitor();

    while ( true )
    {
        level waittill_any( "demo_jump", "demo_player_switch", "visionset_manager_none_state" );
/#
        println( "CLIENT: force instant transition" );
#/
        level._fv2vs_force_instant_transition = 1;
    }
}

fog_vol_to_visionset_hostmigration_monitor()
{
    level endon( "vsionset_mgr_incontrol" );
    level waittill( "hmo" );
    wait 3;
/#
    println( "CLIENT: force instant transition due to host migration" );
#/
    init_fog_vol_to_visionset_monitor( level._fv2vs_default_visionset, level._fv2vs_default_trans_in, 1 );
    level thread fog_vol_to_visionset_monitor();
    level thread reset_player_fv2vs_infos_on_respawn();
    wait 1;
    level notify( "visionset_mgr_reset" );
}

fog_vol_to_visionset_monitor()
{
    level endon( "hmo" );
    level endon( "vsionset_mgr_incontrol" );
    level thread fog_vol_to_visionset_instant_transition_monitor();

    while ( true )
    {
        wait 0.01;
        players = getlocalplayers();

        for ( localclientnum = 0; localclientnum < players.size; localclientnum++ )
        {
            if ( isdefined( level.vsmgr_is_type_currently_default_func ) && ![[ level.vsmgr_is_type_currently_default_func ]]( localclientnum, "visionset" ) )
            {
                level._fv2vs_prev_visionsets[localclientnum] = level._fv2vs_unset_visionset;
                continue;
            }

            id = getworldfogscriptid( localclientnum );
            assert( isdefined( level._fv2vs_infos[id] ), "WorldFogScriptID '" + id + "' was not registered with fog_vol_to_visionset_set_info()" );
            new_visionset = level._fv2vs_infos[id].visionset + level._fv2vs_suffix;
            assert( isdefined( level._fv2vs_infos[id] ), "WorldFogScriptId '" + id + "' was not registered with fog_vol_to_visionset_set_info()" );

            if ( level._fv2vs_prev_visionsets[localclientnum] != new_visionset || level._fv2vs_force_instant_transition )
            {
/#

#/
                trans = level._fv2vs_infos[id].trans_in;

                if ( level._fv2vs_force_instant_transition )
                {
/#
                    println( "Force instant transition set. " + new_visionset );
#/
                    trans = 0;
                }

                visionsetnaked( localclientnum, new_visionset, trans );
                level._fv2vs_prev_visionsets[localclientnum] = new_visionset;
            }
        }

        level._fv2vs_force_instant_transition = 0;
    }
}

callback( event, clientnum )
{
    if ( isdefined( level._callbacks ) && isdefined( level._callbacks[event] ) )
    {
        for ( i = 0; i < level._callbacks[event].size; i++ )
        {
            callback = level._callbacks[event][i];

            if ( isdefined( callback ) )
                self thread [[ callback ]]( clientnum );
        }
    }
}

onplayerconnect_callback( func )
{
    clientscripts\mp\zombies\_callbacks::addcallback( "on_player_connect", func );
}

waittill_notify_or_timeout( msg, timer )
{
    self endon( msg );
    wait( timer );
}

include_powerup( powerup_name )
{
    clientscripts\mp\zombies\_zm_powerups::include_zombie_powerup( powerup_name );
}

is_encounter()
{
    if ( is_true( level._is_encounter ) )
        return true;

    var = getdvar( #"ui_zm_gamemodegroup" );

    if ( var == "zencounter" )
    {
        level._is_encounter = 1;
        return true;
    }

    return false;
}

is_createfx_active()
{
    if ( !isdefined( level.createfx_enabled ) )
        level.createfx_enabled = getdvar( #"createfx" ) != "";

    return level.createfx_enabled;
}

include_buildable( buildable_name )
{
    clientscripts\mp\zombies\_zm_buildables::include_zombie_buildable( buildable_name );
}

add_zombie_buildable( buildable_name )
{
    clientscripts\mp\zombies\_zm_buildables::add_zombie_buildable( buildable_name );
}

set_clientfield_buildables_code_callbacks()
{
    clientscripts\mp\zombies\_zm_buildables::set_clientfield_buildables_code_callbacks();
}

spawn_weapon_model( localclientnum, weapon, model, origin, angles, options )
{
    if ( !isdefined( model ) )
        model = getweaponmodel( weapon );

    weapon_model = spawn( localclientnum, origin, "script_model" );

    if ( isdefined( angles ) )
        weapon_model.angles = angles;

    weapon_model useweaponmodel( weapon, model, options );

    if ( isdefined( options ) )
        weapon_model useweaponmodel( weapon, model, options );
    else
        weapon_model useweaponmodel( weapon, model );

    return weapon_model;
}

reset_player_fv2vs_infos_on_respawn()
{
    level endon( "hmo" );
    level endon( "vsionset_mgr_incontrol" );

    while ( true )
    {
        level waittill( "respawn" );
        players = getlocalplayers();

        for ( localclientnum = 0; localclientnum < players.size; localclientnum++ )
            level._fv2vs_prev_visionsets[localclientnum] = level._fv2vs_unset_visionset;
    }
}

get_array_of_closest( org, array, excluders, max, maxdist )
{
    if ( !isdefined( max ) )
        max = array.size;

    if ( !isdefined( excluders ) )
        excluders = [];

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

is_classic()
{
    var = getdvar( #"ui_zm_gamemodegroup" );

    if ( var == "zclassic" )
        return true;

    return false;
}

is_gametype_active( a_gametypes )
{
    b_is_gametype_active = 0;

    if ( !isarray( a_gametypes ) )
        a_gametypes = array( a_gametypes );

    for ( i = 0; i < a_gametypes.size; i++ )
    {
        if ( getdvar( #"g_gametype" ) == a_gametypes[i] )
            b_is_gametype_active = 1;
    }

    return b_is_gametype_active;
}