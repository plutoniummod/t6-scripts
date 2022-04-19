// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zm_buried;
#include maps\mp\zombies\_zm_ai_sloth;

should_ignore_candybooze( player )
{
    if ( player maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_underground_courthouse" ) || player maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_underground_courthouse2" ) )
    {
        if ( !maps\mp\zm_buried::is_courthouse_open() )
            return true;
    }

    if ( player maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_tunnels_north2" ) )
    {
        if ( !maps\mp\zm_buried::is_courthouse_open() )
            return true;
    }

    if ( player maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_tunnels_center" ) || player maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_tunnels_north" ) || player maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_tunnels_south" ) )
    {
        if ( !maps\mp\zm_buried::is_tunnel_open() )
            return true;
    }

    if ( player maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_start_lower" ) )
        return true;

    if ( player maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_underground_bar" ) )
    {
        if ( !maps\mp\zombies\_zm_ai_sloth::is_bar_open() )
            return true;
    }

    return false;
}

watch_crash_pos()
{
    dist_crash = 4096;
    level.crash_pos = [];
    level.crash_pos[level.crash_pos.size] = ( 3452, 1012, 56 );
    level.crash_pos[level.crash_pos.size] = ( 3452, 1092, 56 );
    level.crash_pos[level.crash_pos.size] = ( 3452, 1056, 56 );

    while ( true )
    {
        if ( !isdefined( self.state ) || self.state != "berserk" )
        {
            wait 0.1;
            continue;
        }

        foreach ( pos in level.crash_pos )
        {
            dist = distancesquared( self.origin, pos );

            if ( dist < dist_crash )
            {
                self.anchor.origin = self.origin;
                self.anchor.angles = self.angles;
                self linkto( self.anchor );
                self setclientfield( "sloth_berserk", 0 );
                self sloth_set_state( "crash", 0 );
                wait 0.25;
                self unlink();
            }
        }

        wait 0.05;
    }
}

sloth_is_pain()
{
    if ( is_true( self.is_pain ) )
    {
        anim_state = self getanimstatefromasd();

        if ( anim_state == "zm_pain" || anim_state == "zm_pain_no_restart" )
            return true;
        else
        {
            self.reset_asd = undefined;
            self animmode( "normal" );
            self.is_pain = 0;
            self.damage_accumulating = 0;
            self notify( "stop_accumulation" );
/#
            sloth_print( "pain was interrupted" );
#/
        }
    }

    return false;
}

sloth_is_traversing()
{
    if ( is_true( self.is_traversing ) )
    {
        anim_state = self getanimstatefromasd();

        if ( anim_state == "zm_traverse" || anim_state == "zm_traverse_no_restart" || anim_state == "zm_traverse_barrier" || anim_state == "zm_traverse_barrier_no_restart" || anim_state == "zm_sling_equipment" || anim_state == "zm_unsling_equipment" || anim_state == "zm_sling_magicbox" || anim_state == "zm_unsling_magicbox" || anim_state == "zm_sloth_crawlerhold_sling" || anim_state == "zm_sloth_crawlerhold_unsling" || anim_state == "zm_sloth_crawlerhold_sling_hunched" || anim_state == "zm_sloth_crawlerhold_unsling_hunched" )
            return true;
        else
        {
            self.is_traversing = 0;
/#
            sloth_print( "traverse was interrupted" );
#/
        }
    }

    return false;
}

sloth_face_object( facee, type, data, dot_limit )
{
    if ( type == "angle" )
        self orientmode( "face angle", data );
    else if ( type == "point" )
        self orientmode( "face point", data );

    time_started = gettime();

    while ( true )
    {
        if ( type == "angle" )
        {
            delta = abs( self.angles[1] - data );

            if ( delta <= 15 )
                break;
        }
        else if ( isdefined( dot_limit ) )
        {
            if ( self is_facing( facee, dot_limit ) )
                break;
        }
        else if ( self is_facing( facee ) )
            break;

        if ( gettime() - time_started > 1000 )
        {
/#
            sloth_print( "face took too long" );
#/
            break;
        }

        wait 0.1;
    }
/#
    time_elapsed = gettime() - time_started;
    sloth_print( "time to face: " + time_elapsed );
#/
}

sloth_print( str )
{
/#
    if ( getdvarint( _hash_B6252E7C ) )
    {
        iprintln( "sloth: " + str );

        if ( isdefined( self.debug_msg ) )
        {
            self.debug_msg[self.debug_msg.size] = str;

            if ( self.debug_msg.size > 64 )
                self.debug_msg = [];
        }
        else
        {
            self.debug_msg = [];
            self.debug_msg[self.debug_msg.size] = str;
        }
    }
#/
}

sloth_debug_context( item, dist )
{
/#
    if ( is_true( self.context_debug ) )
    {
        debugstar( item.origin, 100, ( 1, 1, 1 ) );
        circle( item.origin, dist, ( 1, 1, 1 ), 0, 1, 100 );
    }
#/
}
