// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_craftables;
#include maps\mp\zm_tomb_utility;
#include maps\mp\gametypes_zm\_hud;
#include maps\mp\zm_tomb_vo;
#include maps\mp\zombies\_zm_score;

#using_animtree("fxanim_props_dlc4");

teleporter_init()
{
    registerclientfield( "scriptmover", "teleporter_fx", 14000, 1, "int" );
    precacheshellshock( "lava" );
    level.teleport = [];
    level.n_active_links = 0;
    level.n_countdown = 0;
    level.n_teleport_delay = 0;
    level.teleport_cost = 0;
    level.n_teleport_cooldown = 0;
    level.is_cooldown = 0;
    level.n_active_timer = -1;
    level.n_teleport_time = 0;
    level.a_teleport_models = [];
    a_entrance_models = getentarray( "teleport_model", "targetname" );

    foreach ( e_model in a_entrance_models )
    {
        e_model useanimtree( -1 );
        level.a_teleport_models[e_model.script_int] = e_model;
    }

    array_thread( a_entrance_models, ::teleporter_samantha_chamber_line );
    a_portal_frames = getentarray( "portal_exit_frame", "script_noteworthy" );
    level.a_portal_exit_frames = [];

    foreach ( e_frame in a_portal_frames )
    {
        e_frame useanimtree( -1 );
        e_frame ghost();
        level.a_portal_exit_frames[e_frame.script_int] = e_frame;
    }

    level.a_teleport_exits = [];
    a_exits = getstructarray( "portal_exit", "script_noteworthy" );

    foreach ( s_portal in a_exits )
        level.a_teleport_exits[s_portal.script_int] = s_portal;

    level.a_teleport_exit_triggers = [];
    a_trigs = getstructarray( "chamber_exit_trigger", "script_noteworthy" );

    foreach ( s_trig in a_trigs )
        level.a_teleport_exit_triggers[s_trig.script_int] = s_trig;

    a_s_teleporters = getstructarray( "trigger_teleport_pad", "targetname" );
    array_thread( a_s_teleporters, ::run_chamber_entrance_teleporter );
    spawn_stargate_fx_origins();
    root = %root;
    i = %fxanim_zom_tomb_portal_open_anim;
    i = %fxanim_zom_tomb_portal_collapse_anim;
}

init_animtree()
{
    scriptmodelsuseanimtree( -1 );
}

teleporter_samantha_chamber_line()
{
    max_dist_sq = 640000.0;
    level.sam_chamber_line_played = 0;
    flag_wait( "samantha_intro_done" );

    while ( !level.sam_chamber_line_played )
    {
        a_players = getplayers();

        foreach ( e_player in a_players )
        {
            dist_sq = distance2dsquared( self.origin, e_player.origin );
            height_diff = abs( self.origin[2] - e_player.origin[2] );

            if ( dist_sq < max_dist_sq && height_diff < 150 && !( isdefined( e_player.isspeaking ) && e_player.isspeaking ) )
            {
                level thread play_teleporter_samantha_chamber_line( e_player );
                return;
            }
        }

        wait 0.1;
    }
}

play_teleporter_samantha_chamber_line( e_player )
{
    if ( level.sam_chamber_line_played )
        return;

    level.sam_chamber_line_played = 1;
    flag_waitopen( "story_vo_playing" );
    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );
    maps\mp\zm_tomb_vo::samanthasay( "vox_sam_enter_chamber_1_0", e_player, 1 );
    maps\mp\zm_tomb_vo::samanthasay( "vox_sam_enter_chamber_2_0", e_player );
    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

run_chamber_exit( n_enum )
{
    s_portal = level.a_teleport_exits[n_enum];
    s_activate_pos = level.a_teleport_exit_triggers[n_enum];
    e_portal_frame = level.a_portal_exit_frames[n_enum];
    e_portal_frame show();
    str_building_flag = e_portal_frame.targetname + "_building";
    flag_init( str_building_flag );
    s_activate_pos.trigger_stub = tomb_spawn_trigger_radius( s_activate_pos.origin, 50.0, 1 );
    s_activate_pos.trigger_stub set_unitrigger_hint_string( &"ZM_TOMB_TELE" );
    s_portal.target = s_activate_pos.target;
    s_portal.origin = e_portal_frame gettagorigin( "fx_portal_jnt" );
    s_portal.angles = e_portal_frame gettagangles( "fx_portal_jnt" );
    s_portal.angles = ( s_portal.angles[0], s_portal.angles[1] + 180, s_portal.angles[2] );
    str_fx = get_teleport_fx_from_enum( n_enum );
    collapse_time = getanimlength( %fxanim_zom_tomb_portal_collapse_anim );
    open_time = getanimlength( %fxanim_zom_tomb_portal_open_anim );
    flag_wait( "start_zombie_round_logic" );

    while ( true )
    {
        s_activate_pos.trigger_stub waittill( "trigger", e_player );

        if ( !is_player_valid( e_player ) )
            continue;

        if ( e_player.score < level.teleport_cost )
            continue;

        s_activate_pos.trigger_stub set_unitrigger_hint_string( "" );
        s_activate_pos.trigger_stub trigger_off();

        if ( level.teleport_cost > 0 )
            e_player maps\mp\zombies\_zm_score::minus_to_player_score( level.teleport_cost );

        e_portal_frame playloopsound( "zmb_teleporter_loop_pre", 1 );
        e_portal_frame setanim( %fxanim_zom_tomb_portal_open_anim, 1.0, 0.1, 1 );
        flag_set( str_building_flag );
        e_portal_frame thread whirlwind_rumble_nearby_players( str_building_flag );
        wait( open_time );
        e_portal_frame setanim( %fxanim_zom_tomb_portal_open_1frame_anim, 1.0, 0.1, 1 );
        wait_network_frame();
        flag_clear( str_building_flag );
        e_fx = spawn( "script_model", s_portal.origin );
        e_fx.angles = s_portal.angles;
        e_fx setmodel( "tag_origin" );
        e_fx setclientfield( "element_glow_fx", n_enum + 4 );
        rumble_nearby_players( e_fx.origin, 1000, 2 );
        e_portal_frame playloopsound( "zmb_teleporter_loop_post", 1 );
        s_portal thread teleporter_radius_think();
        wait 20.0;
        e_portal_frame setanim( %fxanim_zom_tomb_portal_collapse_anim, 1.0, 0.1, 1 );
        e_portal_frame stoploopsound( 0.5 );
        e_portal_frame playsound( "zmb_teleporter_anim_collapse_pew" );
        s_portal notify( "teleporter_radius_stop" );
        e_fx setclientfield( "element_glow_fx", 0 );
        wait( collapse_time );
        e_fx delete();
        s_activate_pos.trigger_stub trigger_on();
        s_activate_pos.trigger_stub set_unitrigger_hint_string( &"ZM_TOMB_TELE" );
    }
}

run_chamber_entrance_teleporter()
{
    self endon( "death" );
    fx_glow = get_teleport_fx_from_enum( self.script_int );
    e_model = level.a_teleport_models[self.script_int];
    self.origin = e_model gettagorigin( "fx_portal_jnt" );
    self.angles = e_model gettagangles( "fx_portal_jnt" );
    self.angles = ( self.angles[0], self.angles[1] + 180, self.angles[2] );
    self.trigger_stub = tomb_spawn_trigger_radius( self.origin - vectorscale( ( 0, 0, 1 ), 30.0 ), 50.0 );
    flag_init( "enable_teleporter_" + self.script_int );
    str_building_flag = "teleporter_building_" + self.script_int;
    flag_init( str_building_flag );
    collapse_time = getanimlength( %fxanim_zom_tomb_portal_collapse_anim );
    open_time = getanimlength( %fxanim_zom_tomb_portal_open_anim );
    flag_wait( "start_zombie_round_logic" );
    e_model setanim( %fxanim_zom_tomb_portal_collapse_anim, 1.0, 0.1, 1 );
    wait( collapse_time );

    while ( true )
    {
        flag_wait( "enable_teleporter_" + self.script_int );
        flag_set( str_building_flag );
        e_model thread whirlwind_rumble_nearby_players( str_building_flag );
        e_model setanim( %fxanim_zom_tomb_portal_open_anim, 1.0, 0.1, 1 );
        e_model playloopsound( "zmb_teleporter_loop_pre", 1 );
        wait( open_time );
        e_model setanim( %fxanim_zom_tomb_portal_open_1frame_anim, 1.0, 0.1, 1 );
        wait_network_frame();
        e_fx = spawn( "script_model", self.origin );
        e_fx.angles = self.angles;
        e_fx setmodel( "tag_origin" );
        e_fx setclientfield( "element_glow_fx", self.script_int + 4 );
        rumble_nearby_players( e_fx.origin, 1000, 2 );
        e_model playloopsound( "zmb_teleporter_loop_post", 1 );

        if ( !( isdefined( self.exit_enabled ) && self.exit_enabled ) )
        {
            self.exit_enabled = 1;
            level thread run_chamber_exit( self.script_int );
        }

        self thread stargate_teleport_think();
        flag_clear( str_building_flag );
        flag_waitopen( "enable_teleporter_" + self.script_int );
        level notify( "disable_teleporter_" + self.script_int );
        e_fx setclientfield( "element_glow_fx", 0 );
        e_model stoploopsound( 0.5 );
        e_model playsound( "zmb_teleporter_anim_collapse_pew" );
        e_model setanim( %fxanim_zom_tomb_portal_collapse_anim, 1.0, 0.1, 1 );
        wait( collapse_time );
        e_fx delete();
    }
}

teleporter_radius_think( radius )
{
    if ( !isdefined( radius ) )
        radius = 120.0;

    self endon( "teleporter_radius_stop" );
    radius_sq = radius * radius;

    while ( true )
    {
        a_players = getplayers();

        foreach ( e_player in a_players )
        {
            dist_sq = distancesquared( e_player.origin, self.origin );

            if ( dist_sq < radius_sq && e_player getstance() != "prone" && !( isdefined( e_player.teleporting ) && e_player.teleporting ) )
            {
                playfx( level._effect["teleport_3p"], self.origin, ( 1, 0, 0 ), ( 0, 0, 1 ) );
                playsoundatposition( "zmb_teleporter_tele_3d", self.origin );
                level thread stargate_teleport_player( self.target, e_player );
            }
        }

        wait_network_frame();
    }
}

stargate_teleport_think()
{
    self endon( "death" );
    level endon( "disable_teleporter_" + self.script_int );
    e_potal = level.a_teleport_models[self.script_int];

    while ( true )
    {
        self.trigger_stub waittill( "trigger", e_player );

        if ( e_player getstance() != "prone" && !( isdefined( e_player.teleporting ) && e_player.teleporting ) )
        {
            playfx( level._effect["teleport_3p"], self.origin, ( 1, 0, 0 ), ( 0, 0, 1 ) );
            playsoundatposition( "zmb_teleporter_tele_3d", self.origin );
            level notify( "player_teleported", e_player, self.script_int );
            level thread stargate_teleport_player( self.target, e_player );
        }
    }
}

stargate_teleport_enable( n_index )
{
    flag_set( "enable_teleporter_" + n_index );
}

stargate_teleport_disable( n_index )
{
    flag_clear( "enable_teleporter_" + n_index );
}

stargate_play_fx()
{
    self.e_fx setclientfield( "teleporter_fx", 1 );

    self waittill( "stop_teleport_fx" );

    self.e_fx setclientfield( "teleporter_fx", 0 );
}

spawn_stargate_fx_origins()
{
    a_teleport_positions = getstructarray( "teleport_room", "script_noteworthy" );

    foreach ( s_teleport in a_teleport_positions )
    {
        v_fx_pos = s_teleport.origin + ( 0, 0, 64 ) + anglestoforward( s_teleport.angles ) * 120;
        s_teleport.e_fx = spawn( "script_model", v_fx_pos );
        s_teleport.e_fx setmodel( "tag_origin" );
        s_teleport.e_fx.angles = s_teleport.angles + vectorscale( ( 0, 1, 0 ), 180.0 );
    }
}

stargate_teleport_player( str_teleport_to, player, n_teleport_time_sec, show_fx )
{
    if ( !isdefined( n_teleport_time_sec ) )
        n_teleport_time_sec = 2.0;

    if ( !isdefined( show_fx ) )
        show_fx = 1;

    player.teleporting = 1;

    if ( show_fx )
    {
        player thread fadetoblackforxsec( 0, 0.3, 0.0, 0.5, "white" );
        wait_network_frame();
    }

    n_pos = player.characterindex;
    prone_offset = vectorscale( ( 0, 0, 1 ), 49.0 );
    crouch_offset = vectorscale( ( 0, 0, 1 ), 20.0 );
    stand_offset = ( 0, 0, 0 );
    image_room = getstruct( "teleport_room_" + n_pos, "targetname" );
    player disableoffhandweapons();
    player disableweapons();
    player freezecontrols( 1 );
    wait_network_frame();

    if ( player getstance() == "prone" )
        desired_origin = image_room.origin + prone_offset;
    else if ( player getstance() == "crouch" )
        desired_origin = image_room.origin + crouch_offset;
    else
        desired_origin = image_room.origin + stand_offset;

    player.teleport_origin = spawn( "script_model", player.origin );
    player.teleport_origin setmodel( "tag_origin" );
    player.teleport_origin.angles = player.angles;
    player playerlinktoabsolute( player.teleport_origin, "tag_origin" );
    player.teleport_origin.origin = desired_origin;
    player.teleport_origin.angles = image_room.angles;

    if ( show_fx )
        player playsoundtoplayer( "zmb_teleporter_tele_2d", player );

    wait_network_frame();
    player.teleport_origin.angles = image_room.angles;

    if ( show_fx )
        image_room thread stargate_play_fx();

    wait( n_teleport_time_sec );

    if ( show_fx )
    {
        player thread fadetoblackforxsec( 0, 0.3, 0.0, 0.5, "white" );
        wait_network_frame();
    }

    image_room notify( "stop_teleport_fx" );
    a_pos = getstructarray( str_teleport_to, "targetname" );
    s_pos = get_free_teleport_pos( player, a_pos );
    player unlink();

    if ( isdefined( player.teleport_origin ) )
    {
        player.teleport_origin delete();
        player.teleport_origin = undefined;
    }

    player setorigin( s_pos.origin );
    player setplayerangles( s_pos.angles );
    player enableweapons();
    player enableoffhandweapons();
    player freezecontrols( 0 );
    player.teleporting = 0;
}

is_teleport_landing_valid( s_pos, n_radius )
{
    n_radius_sq = n_radius * n_radius;
    a_players = getplayers();

    foreach ( e_player in a_players )
    {
        if ( distance2dsquared( s_pos.origin, e_player.origin ) < n_radius_sq )
            return false;
    }

    return true;
}

get_free_teleport_pos( player, a_structs )
{
    n_player_radius = 64;

    while ( true )
    {
        a_players = getplayers();

        foreach ( s_pos in a_structs )
        {
            if ( is_teleport_landing_valid( s_pos, n_player_radius ) )
                return s_pos;
        }

        wait 0.05;
    }
}
