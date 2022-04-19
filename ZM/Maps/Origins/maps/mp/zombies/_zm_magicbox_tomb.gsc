// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_magicbox;

init()
{
    registerclientfield( "zbarrier", "magicbox_initial_fx", 2000, 1, "int" );
    registerclientfield( "zbarrier", "magicbox_amb_fx", 2000, 2, "int" );
    registerclientfield( "zbarrier", "magicbox_open_fx", 2000, 1, "int" );
    registerclientfield( "zbarrier", "magicbox_leaving_fx", 2000, 1, "int" );
    level._effect["lght_marker"] = loadfx( "maps/zombie_tomb/fx_tomb_marker" );
    level._effect["lght_marker_flare"] = loadfx( "maps/zombie/fx_zmb_tranzit_marker_fl" );
    level._effect["poltergeist"] = loadfx( "system_elements/fx_null" );
    level._effect["box_powered"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_on" );
    level._effect["box_unpowered"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_off" );
    level._effect["box_gone_ambient"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_amb_base" );
    level._effect["box_here_ambient"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_amb_slab" );
    level._effect["box_is_open"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_open" );
    level._effect["box_portal"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_portal" );
    level._effect["box_is_leaving"] = loadfx( "maps/zombie_tomb/fx_tomb_magicbox_leave" );
    level.chest_joker_model = "zombie_teddybear";
    precachemodel( level.chest_joker_model );
    level.chest_joker_custom_movement = ::custom_joker_movement;
    level.custom_magic_box_timer_til_despawn = ::custom_magic_box_timer_til_despawn;
    level.custom_magic_box_do_weapon_rise = ::custom_magic_box_do_weapon_rise;
    level.custom_magic_box_weapon_wait = ::custom_magic_box_weapon_wait;
    level.custom_magicbox_float_height = 50;
    level.magic_box_zbarrier_state_func = ::set_magic_box_zbarrier_state;
    level thread wait_then_create_base_magic_box_fx();
    level thread handle_fire_sale();
}

custom_joker_movement()
{
    v_origin = self.weapon_model.origin - vectorscale( ( 0, 0, 1 ), 5.0 );
    self.weapon_model delete();
    m_lock = spawn( "script_model", v_origin );
    m_lock setmodel( level.chest_joker_model );
    m_lock.angles = self.angles + vectorscale( ( 0, 1, 0 ), 270.0 );
    m_lock playsound( "zmb_hellbox_bear" );
    wait 0.5;
    level notify( "weapon_fly_away_start" );
    wait 1;
    m_lock rotateyaw( 3000, 4, 4 );
    wait 3;
    v_angles = anglestoforward( self.angles - vectorscale( ( 0, 1, 0 ), 90.0 ) );
    m_lock moveto( m_lock.origin + 20 * v_angles, 0.5, 0.5 );

    m_lock waittill( "movedone" );

    m_lock moveto( m_lock.origin + -100 * v_angles, 0.5, 0.5 );

    m_lock waittill( "movedone" );

    m_lock delete();
    self notify( "box_moving" );
    level notify( "weapon_fly_away_end" );
}

custom_magic_box_timer_til_despawn( magic_box )
{
    self endon( "kill_weapon_movement" );
    putbacktime = 12;
    v_float = anglestoforward( magic_box.angles - vectorscale( ( 0, 1, 0 ), 90.0 ) ) * 40;
    self moveto( self.origin - v_float * 0.25, putbacktime, putbacktime * 0.5 );
    wait( putbacktime );

    if ( isdefined( self ) )
        self delete();
}

custom_magic_box_weapon_wait()
{
    wait 0.5;
}

wait_then_create_base_magic_box_fx()
{
    while ( !isdefined( level.chests ) )
        wait 0.5;

    while ( !isdefined( level.chests[level.chests.size - 1].zbarrier ) )
        wait 0.5;

    foreach ( chest in level.chests )
        chest.zbarrier setclientfield( "magicbox_initial_fx", 1 );
}

set_magic_box_zbarrier_state( state )
{
    for ( i = 0; i < self getnumzbarrierpieces(); i++ )
        self hidezbarrierpiece( i );

    self notify( "zbarrier_state_change" );

    switch ( state )
    {
        case "away":
            self showzbarrierpiece( 0 );
            self.state = "away";
            self.owner.is_locked = 0;
            break;
        case "arriving":
            self showzbarrierpiece( 1 );
            self thread magic_box_arrives();
            self.state = "arriving";
            break;
        case "initial":
            self showzbarrierpiece( 1 );
            self thread magic_box_initial();
            thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.owner.unitrigger_stub, maps\mp\zombies\_zm_magicbox::magicbox_unitrigger_think );
            self.state = "close";
            break;
        case "open":
            self showzbarrierpiece( 2 );
            self thread magic_box_opens();
            self.state = "open";
            break;
        case "close":
            self showzbarrierpiece( 2 );
            self thread magic_box_closes();
            self.state = "close";
            break;
        case "leaving":
            self showzbarrierpiece( 1 );
            self thread magic_box_leaves();
            self.state = "leaving";
            self.owner.is_locked = 0;
            break;
        default:
            if ( isdefined( level.custom_magicbox_state_handler ) )
                self [[ level.custom_magicbox_state_handler ]]( state );

            break;
    }
}

magic_box_initial()
{
    self setzbarrierpiecestate( 1, "open" );
    wait 1;
    self setclientfield( "magicbox_amb_fx", 1 );
}

magic_box_arrives()
{
    self setclientfield( "magicbox_leaving_fx", 0 );
    self setzbarrierpiecestate( 1, "opening" );

    while ( self getzbarrierpiecestate( 1 ) == "opening" )
        wait 0.05;

    self notify( "arrived" );
    self.state = "close";
    s_zone_capture_area = level.zone_capture.zones[self.zone_capture_area];

    if ( isdefined( s_zone_capture_area ) )
    {
        if ( !s_zone_capture_area ent_flag( "player_controlled" ) )
            self setclientfield( "magicbox_amb_fx", 1 );
        else
            self setclientfield( "magicbox_amb_fx", 2 );
    }
}

magic_box_leaves()
{
    self setclientfield( "magicbox_leaving_fx", 1 );
    self setclientfield( "magicbox_open_fx", 0 );
    self setzbarrierpiecestate( 1, "closing" );
    self playsound( "zmb_hellbox_rise" );

    while ( self getzbarrierpiecestate( 1 ) == "closing" )
        wait 0.1;

    self notify( "left" );
    s_zone_capture_area = level.zone_capture.zones[self.zone_capture_area];

    if ( isdefined( s_zone_capture_area ) )
    {
        if ( s_zone_capture_area ent_flag( "player_controlled" ) )
            self setclientfield( "magicbox_amb_fx", 3 );
        else
            self setclientfield( "magicbox_amb_fx", 0 );
    }

    if ( isdefined( level.dig_magic_box_moved ) && !level.dig_magic_box_moved )
        level.dig_magic_box_moved = 1;
}

magic_box_opens()
{
    self setclientfield( "magicbox_open_fx", 1 );
    self setzbarrierpiecestate( 2, "opening" );
    self playsound( "zmb_hellbox_open" );

    while ( self getzbarrierpiecestate( 2 ) == "opening" )
        wait 0.1;

    self notify( "opened" );
    self thread magic_box_open_idle();
}

magic_box_open_idle()
{
    self endon( "stop_open_idle" );
    self hidezbarrierpiece( 2 );
    self showzbarrierpiece( 5 );

    while ( true )
    {
        self setzbarrierpiecestate( 5, "opening" );

        while ( self getzbarrierpiecestate( 5 ) != "open" )
            wait 0.05;
    }
}

magic_box_closes()
{
    self notify( "stop_open_idle" );
    self hidezbarrierpiece( 5 );
    self showzbarrierpiece( 2 );
    self setzbarrierpiecestate( 2, "closing" );
    self playsound( "zmb_hellbox_close" );
    self setclientfield( "magicbox_open_fx", 0 );

    while ( self getzbarrierpiecestate( 2 ) == "closing" )
        wait 0.1;

    self notify( "closed" );
}

custom_magic_box_do_weapon_rise()
{
    self endon( "box_hacked_respin" );
    wait 0.5;
    self setzbarrierpiecestate( 3, "closed" );
    self setzbarrierpiecestate( 4, "closed" );
    wait_network_frame();
    self zbarrierpieceuseboxriselogic( 3 );
    self zbarrierpieceuseboxriselogic( 4 );
    self showzbarrierpiece( 3 );
    self showzbarrierpiece( 4 );
    self setzbarrierpiecestate( 3, "opening" );
    self setzbarrierpiecestate( 4, "opening" );

    while ( self getzbarrierpiecestate( 3 ) != "open" )
        wait 0.5;

    self hidezbarrierpiece( 3 );
    self hidezbarrierpiece( 4 );
}

handle_fire_sale()
{
    while ( true )
    {
        level waittill( "fire_sale_off" );

        for ( i = 0; i < level.chests.size; i++ )
        {
            if ( level.chest_index != i && isdefined( level.chests[i].was_temp ) )
            {
                if ( isdefined( level.chests[i].zbarrier.zone_capture_area ) && level.zone_capture.zones[level.chests[i].zbarrier.zone_capture_area] ent_flag( "player_controlled" ) )
                {
                    level.chests[i].zbarrier setclientfield( "magicbox_amb_fx", 3 );
                    continue;
                }

                level.chests[i].zbarrier setclientfield( "magicbox_amb_fx", 0 );
            }
        }
    }
}
