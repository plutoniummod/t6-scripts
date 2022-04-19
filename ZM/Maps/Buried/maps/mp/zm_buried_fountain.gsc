// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zm_buried_classic;
#include maps\mp\zombies\_zm_ai_ghost;
#include maps\mp\zombies\_zm_stats;

init_fountain()
{
    flag_init( "courtyard_fountain_broken" );
    flag_init( "maze_fountain_broken" );
    flag_init( "fountain_transport_active" );
    level._effect["fountain_break"] = loadfx( "maps/zombie_buried/fx_buried_fountain_break" );
    level._effect["fountain_spray"] = loadfx( "maps/zombie_buried/fx_buried_fountain_spray" );
    level._effect["fountain_teleport"] = loadfx( "maps/zombie_buried/fx_buried_teleport_flash" );
    level thread fountain_setup();
    level thread maze_fountain_collmap();
}

fountain_setup()
{
    flag_wait( "initial_blackscreen_passed" );
    fountain_debug_print( "fountain scripts running" );
    level thread set_flag_on_notify( "courtyard_fountain_open", "courtyard_fountain_broken" );
    level thread sloth_fountain_think();
    level thread maze_fountain_think();
    level thread fountain_transport_think();
/#
    level thread debug_warp_player_to_fountain();
#/
}

maze_fountain_collmap()
{
    collmap = getentarray( "maze_fountain_collmap", "targetname" );
    flag_wait( "maze_fountain_broken" );
    array_thread( collmap, ::self_delete );
}

sloth_fountain_think()
{
    flag_wait( "courtyard_fountain_broken" );
    level setclientfield( "sloth_fountain_start", 1 );
    s_courtyard_fountain = getstruct( "courtyard_fountain_struct", "targetname" );

    if ( isdefined( s_courtyard_fountain ) )
    {
        sound_offset = vectorscale( ( 0, 0, 1 ), 100.0 );
        sound_ent = spawn( "script_origin", s_courtyard_fountain.origin + sound_offset );
        playfx( level._effect["fx_buried_fountain_spray"], s_courtyard_fountain.origin );
        playfx( level._effect["fountain_break"], s_courtyard_fountain.origin );
        sound_ent playloopsound( "zmb_fountain_spray", 0.2 );
    }

    show_maze_fountain_water();
    fountain_debug_print( "courtyard_fountain_broken" );
}

set_flag_on_notify( notifystr, strflag )
{
    if ( notifystr != "death" )
        self endon( "death" );

    if ( !level.flag[strflag] )
    {
        self waittill( notifystr );

        flag_set( strflag );
    }
}

maze_fountain_think()
{
    hide_maze_fountain_water();
    wait_for_maze_fountain_to_be_destroyed();
    destroy_maze_fountain();
    flag_wait( "courtyard_fountain_broken" );
    flag_set( "fountain_transport_active" );
}

hide_maze_fountain_water()
{
    t_water = getent( "maze_fountain_water_trigger", "targetname" );
    t_water enablelinkto();
    m_water = getent( "maze_fountain_water", "targetname" );
    t_water linkto( m_water );
    m_water movez( -475, 0.05 );
}

show_maze_fountain_water()
{
    m_water = getent( "maze_fountain_water", "targetname" );
    m_water movez( 398, 6 );
    m_water ghost();
    fountain_debug_print( "maze water ready" );
}

wait_for_maze_fountain_to_be_destroyed()
{
/#
    level endon( "_destroy_maze_fountain" );
#/
    t_damage = getent( "maze_fountain_trigger", "targetname" );
    health = 1000;

    while ( health > 0 )
    {
        t_damage waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname, idflags );

        if ( damage < 50 )
            damage = 0;

        if ( isdefined( type ) && ( type == "MOD_EXPLOSIVE" || type == "MOD_EXPLOSIVE_SPLASH" || type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" || type == "MOD_PROJECTILE" || type == "MOD_PROJECTILE_SPLASH" ) )
            health -= damage;
    }
}

destroy_maze_fountain()
{
    s_fountain = getstruct( "maze_fountain_struct", "targetname" );
    level setclientfield( "maze_fountain_start", 1 );

    if ( isdefined( s_fountain ) )
        playfx( level._effect["fountain_break"], s_fountain.origin );

    s_fountain_clip = getent( "maze_fountain_clip", "targetname" );
    s_fountain_clip delete();
    flag_set( "maze_fountain_broken" );
}

fountain_transport_think()
{
    t_transporter = getent( "maze_fountain_water_trigger", "targetname" );

    while ( true )
    {
        t_transporter waittill( "trigger", player );

        if ( !isdefined( player.is_in_fountain_transport_trigger ) || !player.is_in_fountain_transport_trigger )
        {
            player.is_in_fountain_transport_trigger = 1;

            if ( flag( "fountain_transport_active" ) )
                player thread transport_player_to_start_zone();
            else
                player thread delay_transport_check();
        }
    }
}

delay_transport_check()
{
    self endon( "death" );
    self endon( "bled_out" );
    wait 1;
    self.is_in_fountain_transport_trigger = 0;
}

transport_player_to_start_zone()
{
    self endon( "death_or_disconnect" );
    fountain_debug_print( "transport player!" );

    if ( !isdefined( level._fountain_transporter ) )
    {
        level._fountain_transporter = spawnstruct();
        level._fountain_transporter.index = 0;
        level._fountain_transporter.end_points = getstructarray( "fountain_transport_end_location", "targetname" );
    }

    self playsoundtoplayer( "zmb_buried_teleport", self );
    self play_teleport_fx();
    self flash_screen_white();
    wait_network_frame();

    if ( level._fountain_transporter.index >= level._fountain_transporter.end_points.size )
        level._fountain_transporter.index = 0;

    tries = 0;

    while ( positionwouldtelefrag( level._fountain_transporter.end_points[level._fountain_transporter.index].origin ) )
    {
        tries++;

        if ( tries >= 4 )
        {
            tries = 0;
            wait 0.05;
        }

        level._fountain_transporter.index++;

        if ( level._fountain_transporter.index >= level._fountain_transporter.end_points.size )
            level._fountain_transporter.index = 0;
    }

    self setorigin( level._fountain_transporter.end_points[level._fountain_transporter.index].origin );
    self setplayerangles( level._fountain_transporter.end_points[level._fountain_transporter.index].angles );
    level._fountain_transporter.index++;
    wait_network_frame();
    self play_teleport_fx();
    self thread flash_screen_fade_out();
    self maps\mp\zm_buried_classic::buried_set_start_area_lighting();
    self thread maps\mp\zombies\_zm_ai_ghost::behave_after_fountain_transport( self );
    self maps\mp\zombies\_zm_stats::increment_client_stat( "buried_fountain_transporter_used", 0 );
    self maps\mp\zombies\_zm_stats::increment_player_stat( "buried_fountain_transporter_used" );
    self notify( "player_used_fountain_teleporter" );
    wait_network_frame();
    wait_network_frame();
    self.is_in_fountain_transport_trigger = 0;
}

play_teleport_fx()
{
    playfx( level._effect["fountain_teleport"], self gettagorigin( "J_SpineLower" ) );
}

flash_screen_white()
{
    self endon( "death_or_disconnect" );
    self.hud_transporter_flash = self create_client_hud_elem();
    self.hud_transporter_flash fadeovertime( 0.2 );
    self.hud_transporter_flash.alpha = 1;
    wait 0.2;
}

flash_screen_fade_out()
{
    self.hud_transporter_flash fadeovertime( 0.2 );
    self.hud_transporter_flash.alpha = 0;
    wait 0.2;
    self.hud_transporter_flash destroy();
    self.hud_transporter_flash = undefined;
}

create_client_hud_elem()
{
    hud_elem = newclienthudelem( self );
    hud_elem.x = 0;
    hud_elem.y = 0;
    hud_elem.horzalign = "fullscreen";
    hud_elem.vertalign = "fullscreen";
    hud_elem.foreground = 1;
    hud_elem.alpha = 0;
    hud_elem.hidewheninmenu = 0;
    hud_elem.shader = "white";
    hud_elem setshader( "white", 640, 480 );
    return hud_elem;
}

debug_warp_player_to_fountain()
{
    while ( true )
    {
        str_notify = level waittill_any_return( "warp_player_to_maze_fountain", "warp_player_to_courtyard_fountain" );

        if ( str_notify == "warp_player_to_maze_fountain" )
            str_warp_point = "teleport_player_to_maze_fountain";
        else if ( str_notify == "warp_player_to_courtyard_fountain" )
            str_warp_point = "teleport_player_to_courtyard_fountain";

        foreach ( player in get_players() )
        {
            _warp_player_to_maze_fountain( player, str_warp_point );
            wait 0.25;
        }
    }
}

_warp_player_to_maze_fountain( player, str_teleport_point )
{
    fountain_debug_print( "teleporting player to " + str_teleport_point );
    s_warp = getstruct( str_teleport_point, "targetname" );

    for ( origin = s_warp.origin; positionwouldtelefrag( origin ); origin = s_warp.origin + ( randomfloatrange( -64, 64 ), randomfloatrange( -64, 64 ), 0 ) )
        wait 0.05;

    player setorigin( origin );
    player setplayerangles( s_warp.angles );
}

fountain_debug_print( str_text )
{
/#
    if ( getdvarint( _hash_AE3F04F6 ) > 0 )
        iprintlnbold( str_text );
#/
}
