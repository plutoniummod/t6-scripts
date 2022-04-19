// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_ai_screecher;
#include maps\mp\zm_transit_utility;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_gump;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zm_transit;

init()
{
    level.screecher_should_burrow = ::screecher_should_burrow;
    level.screecher_should_runaway = ::screecher_should_runaway;
    level.screecher_cleanup = ::transit_screecher_cleanup;
    level.screecher_init_done = ::screecher_init_done;
    level.portals = [];
}

screecher_should_burrow()
{
    green_light = self.green_light;

    if ( isdefined( green_light ) )
    {
        if ( isdefined( green_light.burrow_active ) && green_light.burrow_active )
        {
/#
            screecher_print( "burrow: already active" );
#/
            return false;
        }

        if ( isdefined( green_light.claimed ) && green_light.claimed )
        {
/#
            screecher_print( "burrow: already claimed" );
#/
            return false;
        }

        ground_pos = groundpos( green_light.origin );
        self.ignoreall = 1;
        green_light.claimed = 1;
        self setgoalpos( ground_pos );

        self waittill( "goal" );

        self.state = "burrow_started";
        self setfreecameralockonallowed( 0 );
        self animscripted( ground_pos, self.angles, "zm_burrow" );
        self playsound( "zmb_screecher_dig" );

        if ( !( isdefined( green_light.burrow_active ) && green_light.burrow_active ) && ( isdefined( green_light.power_on ) && green_light.power_on ) )
            green_light thread create_portal();

        maps\mp\animscripts\zm_shared::donotetracks( "burrow_anim" );
        green_light notify( "burrow_done" );
        self.state = "burrow_finished";
        self delete();
        return true;
    }

    return false;
}

create_portal()
{
    self endon( "portal_stopped" );
    self.burrow_active = 1;
    ground_pos = groundpos( self.origin );

    if ( !isdefined( self.hole ) )
    {
        self.hole = spawn( "script_model", ground_pos + vectorscale( ( 0, 0, -1 ), 20.0 ) );
        self.hole.start_origin = self.hole.origin;
        self.hole setmodel( "p6_zm_screecher_hole" );
        self.hole playsound( "zmb_screecher_portal_spawn" );
    }

    if ( !isdefined( self.hole_fx ) )
    {
        self.hole_fx = spawn( "script_model", ground_pos );
        self.hole_fx setmodel( "tag_origin" );
    }

    wait 0.1;
    playfxontag( level._effect["screecher_hole"], self.hole_fx, "tag_origin" );
    self.hole moveto( self.hole.origin + vectorscale( ( 0, 0, 1 ), 20.0 ), 1.0 );

    self waittill( "burrow_done" );

    self thread portal_think();
}

portal_think()
{
    playfxontag( level._effect["screecher_vortex"], self.hole, "tag_origin" );
    self.hole_fx delete();
    self.hole playloopsound( "zmb_screecher_portal_loop", 2 );
    level.portals[level.portals.size] = self;
}

portal_player_watcher()
{
    self endon( "disconnect" );

    while ( true )
    {
        if ( !self isonground() )
            self player_wait_land();

        wait 0.1;
    }
}

player_wait_land()
{
    self endon( "disconnect" );

    while ( !self isonground() )
        wait 0.1;

    if ( level.portals.size > 0 )
    {
        remove_portal = undefined;

        foreach ( portal in level.portals )
        {
            dist_sq = distance2dsquared( self.origin, portal.origin );

            if ( dist_sq < 4096 )
            {
                remove_portal = portal;
                break;
            }
        }

        if ( isdefined( remove_portal ) )
        {
            arrayremovevalue( level.portals, remove_portal );
            portal portal_use( self );
            wait 0.5;
        }
    }
}

portal_use( player )
{
    player playsoundtoplayer( "zmb_screecher_portal_warp_2d", player );
    self thread teleport_player( player );
    playsoundatposition( "zmb_screecher_portal_end", self.hole.origin );
    self.hole delete();
    self.burrow_active = 0;
}

teleport_player( player )
{
    lights = getstructarray( "screecher_escape", "targetname" );
    lights = array_randomize( lights );
    dest_light = undefined;

    foreach ( light in lights )
    {
        if ( light == self )
            continue;

        if ( light other_players_close_to_light( player ) )
            continue;

        dest_light = light;
        break;
    }

    if ( isdefined( dest_light ) )
    {
        playsoundatposition( "zmb_screecher_portal_arrive", dest_light.origin );
        player maps\mp\zombies\_zm_gump::player_teleport_blackscreen_on();
        player setorigin( dest_light.origin );
        player notify( "used_screecher_hole" );
        player maps\mp\zombies\_zm_stats::increment_client_stat( "screecher_teleporters_used", 0 );
        player maps\mp\zombies\_zm_stats::increment_player_stat( "screecher_teleporters_used" );
    }
}

other_players_close_to_light( ignore_player )
{
    players = get_players();

    if ( players.size > 1 )
    {
        foreach ( player in players )
        {
            if ( player == ignore_player )
                continue;

            dist_sq = distance2dsquared( player.origin, self.origin );

            if ( dist_sq < 14400 )
                return true;
        }
    }

    return false;
}

screecher_should_runaway( player )
{
    if ( maps\mp\zm_transit::player_entered_safety_light( player ) )
    {
/#
        screecher_print( "runaway: green light" );
#/
        if ( !isdefined( player.screecher ) )
            player thread do_player_general_vox( "general", "screecher_flee_green" );

        return true;
    }

    if ( maps\mp\zm_transit::player_entered_safety_zone( player ) )
    {
/#
        screecher_print( "runaway: safety zone" );
#/
        if ( !isdefined( player.screecher ) )
            player thread do_player_general_vox( "general", "screecher_flee" );

        return true;
    }

    bus_dist_sq = distancesquared( player.origin, level.the_bus.origin );

    if ( bus_dist_sq < 62500 )
    {
/#
        screecher_print( "runaway: bus" );
#/
        if ( !isdefined( player.screecher ) )
            player thread do_player_general_vox( "general", "screecher_flee" );

        return true;
    }

    return false;
}

transit_screecher_cleanup()
{
    green_light = self.green_light;

    if ( isdefined( green_light ) )
    {
        if ( isdefined( green_light.claimed ) )
            green_light.claimed = undefined;

        if ( self.state == "burrow_started" )
        {
/#
            screecher_print( "clean up portal" );
#/
            green_light notify( "portal_stopped" );
            green_light.hole moveto( green_light.hole.start_origin, 1.0 );
            green_light.burrow_active = 0;

            if ( isdefined( green_light.hole_fx ) )
                green_light.hole_fx delete();
        }
    }
}

screecher_init_done()
{
    self endon( "death" );

    while ( true )
    {
        ground_ent = self getgroundent();

        if ( isdefined( ground_ent ) && ground_ent == level.the_bus )
        {
            self dodamage( self.health + 666, self.origin );
/#
            screecher_print( "Died on bus" );
#/
        }

        wait 0.1;
    }
}
