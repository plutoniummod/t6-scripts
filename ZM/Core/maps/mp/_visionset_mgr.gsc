// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
    if ( level.createfx_enabled )
        return;

    level.vsmgr_initializing = 1;
    level.vsmgr_default_info_name = "none";
    level.vsmgr = [];
    level thread register_type( "visionset" );
    level thread register_type( "overlay" );
    onfinalizeinitialization_callback( ::finalize_clientfields );
    level thread monitor();
    level thread onplayerconnect();
}

vsmgr_register_info( type, name, version, priority, lerp_step_count, activate_per_player, lerp_thread, ref_count_lerp_thread )
{
    if ( level.createfx_enabled )
        return;

    assert( level.vsmgr_initializing, "All info registration in the visionset_mgr system must occur during the first frame while the system is initializing" );
    lower_name = tolower( name );
    validate_info( type, lower_name, priority );
    add_sorted_name_key( type, lower_name );
    add_sorted_priority_key( type, lower_name, priority );
    level.vsmgr[type].info[lower_name] = spawnstruct();
    level.vsmgr[type].info[lower_name] add_info( type, lower_name, version, priority, lerp_step_count, activate_per_player, lerp_thread, ref_count_lerp_thread );

    if ( level.vsmgr[type].highest_version < version )
        level.vsmgr[type].highest_version = version;
}

vsmgr_activate( type, name, player, opt_param_1, opt_param_2 )
{
    if ( level.vsmgr[type].info[name].state.activate_per_player )
    {
        activate_per_player( type, name, player, opt_param_1, opt_param_2 );
        return;
    }

    state = level.vsmgr[type].info[name].state;

    if ( state.ref_count_lerp_thread )
    {
        state.ref_count++;

        if ( 1 < state.ref_count )
            return;
    }

    if ( isdefined( state.lerp_thread ) )
        state thread lerp_thread_wrapper( state.lerp_thread, opt_param_1, opt_param_2 );
    else
    {
        players = getplayers();

        for ( player_index = 0; player_index < players.size; player_index++ )
            state vsmgr_set_state_active( players[player_index], 1 );
    }
}

vsmgr_deactivate( type, name, player )
{
    if ( level.vsmgr[type].info[name].state.activate_per_player )
    {
        deactivate_per_player( type, name, player );
        return;
    }

    state = level.vsmgr[type].info[name].state;

    if ( state.ref_count_lerp_thread )
    {
        state.ref_count--;

        if ( 0 < state.ref_count )
            return;
    }

    state notify( "deactivate" );
    players = getplayers();

    for ( player_index = 0; player_index < players.size; player_index++ )
        state vsmgr_set_state_inactive( players[player_index] );
}

vsmgr_set_state_active( player, lerp )
{
    player_entnum = player getentitynumber();

    if ( !isdefined( self.players[player_entnum] ) )
        return;

    self.players[player_entnum].active = 1;
    self.players[player_entnum].lerp = lerp;
}

vsmgr_set_state_inactive( player )
{
    player_entnum = player getentitynumber();

    if ( !isdefined( self.players[player_entnum] ) )
        return;

    self.players[player_entnum].active = 0;
    self.players[player_entnum].lerp = 0;
}

vsmgr_timeout_lerp_thread( timeout, opt_param_2 )
{
    players = getplayers();

    for ( player_index = 0; player_index < players.size; player_index++ )
        self vsmgr_set_state_active( players[player_index], 1 );

    wait( timeout );
    vsmgr_deactivate( self.type, self.name );
}

vsmgr_timeout_lerp_thread_per_player( player, timeout, opt_param_2 )
{
    self vsmgr_set_state_active( player, 1 );
    wait( timeout );
    deactivate_per_player( self.type, self.name, player );
}

vsmgr_duration_lerp_thread( duration, max_duration )
{
    start_time = gettime();
    end_time = start_time + int( duration * 1000 );

    if ( isdefined( max_duration ) )
        start_time = end_time - int( max_duration * 1000 );

    while ( true )
    {
        lerp = calc_remaining_duration_lerp( start_time, end_time );

        if ( 0 >= lerp )
            break;

        players = getplayers();

        for ( player_index = 0; player_index < players.size; player_index++ )
            self vsmgr_set_state_active( players[player_index], lerp );

        wait 0.05;
    }

    vsmgr_deactivate( self.type, self.name );
}

vsmgr_duration_lerp_thread_per_player( player, duration, max_duration )
{
    start_time = gettime();
    end_time = start_time + int( duration * 1000 );

    if ( isdefined( max_duration ) )
        start_time = end_time - int( max_duration * 1000 );

    while ( true )
    {
        lerp = calc_remaining_duration_lerp( start_time, end_time );

        if ( 0 >= lerp )
            break;

        self vsmgr_set_state_active( player, lerp );
        wait 0.05;
    }

    deactivate_per_player( self.type, self.name, player );
}

register_type( type )
{
    level.vsmgr[type] = spawnstruct();
    level.vsmgr[type].type = type;
    level.vsmgr[type].in_use = 0;
    level.vsmgr[type].highest_version = 0;
    level.vsmgr[type].cf_slot_name = type + "_slot";
    level.vsmgr[type].cf_lerp_name = type + "_lerp";
    level.vsmgr[type].info = [];
    level.vsmgr[type].sorted_name_keys = [];
    level.vsmgr[type].sorted_prio_keys = [];
    vsmgr_register_info( type, level.vsmgr_default_info_name, 1, 0, 1, 0, undefined );
}

finalize_clientfields()
{
    typekeys = getarraykeys( level.vsmgr );

    for ( type_index = 0; type_index < typekeys.size; type_index++ )
        level.vsmgr[typekeys[type_index]] thread finalize_type_clientfields();

    level.vsmgr_initializing = 0;
}

finalize_type_clientfields()
{
    if ( 1 >= self.info.size )
        return;

    self.in_use = 1;
    self.cf_slot_bit_count = getminbitcountfornum( self.info.size - 1 );
    self.cf_lerp_bit_count = self.info[self.sorted_name_keys[0]].lerp_bit_count;

    for ( i = 0; i < self.sorted_name_keys.size; i++ )
    {
        self.info[self.sorted_name_keys[i]].slot_index = i;

        if ( self.info[self.sorted_name_keys[i]].lerp_bit_count > self.cf_lerp_bit_count )
            self.cf_lerp_bit_count = self.info[self.sorted_name_keys[i]].lerp_bit_count;
    }

    registerclientfield( "toplayer", self.cf_slot_name, self.highest_version, self.cf_slot_bit_count, "int" );

    if ( 1 < self.cf_lerp_bit_count )
        registerclientfield( "toplayer", self.cf_lerp_name, self.highest_version, self.cf_lerp_bit_count, "float" );
}

validate_info( type, name, priority )
{
    keys = getarraykeys( level.vsmgr );

    for ( i = 0; i < keys.size; i++ )
    {
        if ( type == keys[i] )
            break;
    }

    assert( i < keys.size, "In visionset_mgr, type '" + type + "'is unknown" );
    keys = getarraykeys( level.vsmgr[type].info );

    for ( i = 0; i < keys.size; i++ )
    {
        assert( level.vsmgr[type].info[keys[i]].name != name, "In visionset_mgr of type '" + type + "': name '" + name + "' has previously been registered" );
        assert( level.vsmgr[type].info[keys[i]].priority != priority, "In visionset_mgr of type '" + type + "': priority '" + priority + "' requested for name '" + name + "' has previously been registered under name '" + level.vsmgr[type].info[keys[i]].name + "'" );
    }
}

add_sorted_name_key( type, name )
{
    for ( i = 0; i < level.vsmgr[type].sorted_name_keys.size; i++ )
    {
        if ( name < level.vsmgr[type].sorted_name_keys[i] )
            break;
    }

    arrayinsert( level.vsmgr[type].sorted_name_keys, name, i );
}

add_sorted_priority_key( type, name, priority )
{
    for ( i = 0; i < level.vsmgr[type].sorted_prio_keys.size; i++ )
    {
        if ( priority > level.vsmgr[type].info[level.vsmgr[type].sorted_prio_keys[i]].priority )
            break;
    }

    arrayinsert( level.vsmgr[type].sorted_prio_keys, name, i );
}

add_info( type, name, version, priority, lerp_step_count, activate_per_player, lerp_thread, ref_count_lerp_thread )
{
    self.type = type;
    self.name = name;
    self.version = version;
    self.priority = priority;
    self.lerp_step_count = lerp_step_count;
    self.lerp_bit_count = getminbitcountfornum( lerp_step_count );

    if ( !isdefined( ref_count_lerp_thread ) )
        ref_count_lerp_thread = 0;

    self.state = spawnstruct();
    self.state.type = type;
    self.state.name = name;
    self.state.activate_per_player = activate_per_player;
    self.state.lerp_thread = lerp_thread;
    self.state.ref_count_lerp_thread = ref_count_lerp_thread;
    self.state.players = [];

    if ( ref_count_lerp_thread && !activate_per_player )
        self.state.ref_count = 0;
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connected", player );

        player thread on_player_connect();
    }
}

on_player_connect()
{
    self._player_entnum = self getentitynumber();
    typekeys = getarraykeys( level.vsmgr );

    for ( type_index = 0; type_index < typekeys.size; type_index++ )
    {
        type = typekeys[type_index];

        if ( !level.vsmgr[type].in_use )
            continue;

        for ( name_index = 0; name_index < level.vsmgr[type].sorted_name_keys.size; name_index++ )
        {
            name_key = level.vsmgr[type].sorted_name_keys[name_index];
            level.vsmgr[type].info[name_key].state.players[self._player_entnum] = spawnstruct();
            level.vsmgr[type].info[name_key].state.players[self._player_entnum].active = 0;
            level.vsmgr[type].info[name_key].state.players[self._player_entnum].lerp = 0;

            if ( level.vsmgr[type].info[name_key].state.ref_count_lerp_thread && level.vsmgr[type].info[name_key].state.activate_per_player )
                level.vsmgr[type].info[name_key].state.players[self._player_entnum].ref_count = 0;
        }

        level.vsmgr[type].info[level.vsmgr_default_info_name].state vsmgr_set_state_active( self, 1 );
    }
}

monitor()
{
    while ( level.vsmgr_initializing )
        wait 0.05;

    typekeys = getarraykeys( level.vsmgr );

    while ( true )
    {
        wait 0.05;
        waittillframeend;
        players = get_players();

        for ( type_index = 0; type_index < typekeys.size; type_index++ )
        {
            type = typekeys[type_index];

            if ( !level.vsmgr[type].in_use )
                continue;

            for ( player_index = 0; player_index < players.size; player_index++ )
            {
/#
                if ( is_true( players[player_index].pers["isBot"] ) )
                    continue;
#/
                update_clientfields( players[player_index], level.vsmgr[type] );
            }
        }
    }
}

get_first_active_name( type_struct )
{
    size = type_struct.sorted_prio_keys.size;

    for ( prio_index = 0; prio_index < size; prio_index++ )
    {
        prio_key = type_struct.sorted_prio_keys[prio_index];

        if ( type_struct.info[prio_key].state.players[self._player_entnum].active )
            return prio_key;
    }

    return level.vsmgr_default_info_name;
}

update_clientfields( player, type_struct )
{
    name = player get_first_active_name( type_struct );
    player setclientfieldtoplayer( type_struct.cf_slot_name, type_struct.info[name].slot_index );

    if ( 1 < type_struct.cf_lerp_bit_count )
        player setclientfieldtoplayer( type_struct.cf_lerp_name, type_struct.info[name].state.players[player._player_entnum].lerp );
}

lerp_thread_wrapper( func, opt_param_1, opt_param_2 )
{
    self notify( "deactivate" );
    self endon( "deactivate" );
    self [[ func ]]( opt_param_1, opt_param_2 );
}

lerp_thread_per_player_wrapper( func, player, opt_param_1, opt_param_2 )
{
    player_entnum = player getentitynumber();
    self notify( "deactivate" );
    self endon( "deactivate" );
    self.players[player_entnum] notify( "deactivate" );
    self.players[player_entnum] endon( "deactivate" );
    player endon( "disconnect" );
    self [[ func ]]( player, opt_param_1, opt_param_2 );
}

activate_per_player( type, name, player, opt_param_1, opt_param_2 )
{
    player_entnum = player getentitynumber();
    state = level.vsmgr[type].info[name].state;

    if ( state.ref_count_lerp_thread )
    {
        state.players[player_entnum].ref_count++;

        if ( 1 < state.players[player_entnum].ref_count )
            return;
    }

    if ( isdefined( state.lerp_thread ) )
        state thread lerp_thread_per_player_wrapper( state.lerp_thread, player, opt_param_1, opt_param_2 );
    else
        state vsmgr_set_state_active( player, 1 );
}

deactivate_per_player( type, name, player )
{
    player_entnum = player getentitynumber();
    state = level.vsmgr[type].info[name].state;

    if ( state.ref_count_lerp_thread )
    {
        state.players[player_entnum].ref_count--;

        if ( 0 < state.players[player_entnum].ref_count )
            return;
    }

    state vsmgr_set_state_inactive( player );
    state notify( "deactivate" );
}

calc_remaining_duration_lerp( start_time, end_time )
{
    now = gettime();
    frac = float( end_time - now ) / float( end_time - start_time );
    return clamp( frac, 0, 1 );
}
