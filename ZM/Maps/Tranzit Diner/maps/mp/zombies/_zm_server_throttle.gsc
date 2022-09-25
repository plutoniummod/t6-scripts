// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

server_choke_init( id, max )
{
    if ( !isdefined( level.zombie_server_choke_ids_max ) )
    {
        level.zombie_server_choke_ids_max = [];
        level.zombie_server_choke_ids_count = [];
    }

    level.zombie_server_choke_ids_max[id] = max;
    level.zombie_server_choke_ids_count[id] = 0;
    level thread server_choke_thread( id );
}

server_choke_thread( id )
{
    while ( true )
    {
        wait 0.05;
        level.zombie_server_choke_ids_count[id] = 0;
    }
}

server_choke_safe( id )
{
    return level.zombie_server_choke_ids_count[id] < level.zombie_server_choke_ids_max[id];
}

server_choke_action( id, choke_action, arg1, arg2, arg3 )
{
    assert( isdefined( level.zombie_server_choke_ids_max[id] ), "server Choke: " + id + " undefined" );

    while ( !server_choke_safe( id ) )
        wait 0.05;

    level.zombie_server_choke_ids_count[id]++;

    if ( !isdefined( arg1 ) )
        return [[ choke_action ]]();

    if ( !isdefined( arg2 ) )
        return [[ choke_action ]]( arg1 );

    if ( !isdefined( arg3 ) )
        return [[ choke_action ]]( arg1, arg2 );

    return [[ choke_action ]]( arg1, arg2, arg3 );
}

server_entity_valid( entity )
{
    if ( !isdefined( entity ) )
        return false;

    return true;
}

server_safe_init( id, max )
{
    if ( !isdefined( level.zombie_server_choke_ids_max ) || !isdefined( level.zombie_server_choke_ids_max[id] ) )
        server_choke_init( id, max );

    assert( max == level.zombie_server_choke_ids_max[id] );
}

_server_safe_ground_trace( pos )
{
    return groundpos( pos );
}

server_safe_ground_trace( id, max, origin )
{
    server_safe_init( id, max );
    return server_choke_action( id, ::_server_safe_ground_trace, origin );
}

_server_safe_ground_trace_ignore_water( pos )
{
    return groundpos_ignore_water( pos );
}

server_safe_ground_trace_ignore_water( id, max, origin )
{
    server_safe_init( id, max );
    return server_choke_action( id, ::_server_safe_ground_trace_ignore_water, origin );
}
