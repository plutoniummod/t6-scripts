// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_powerups;

init_ghost_piano()
{
    t_bullseye = getent( "bullseye", "script_noteworthy" );
    t_chalk_line = getent( "ee_bar_chalk_line_trigger", "targetname" );

    if ( !isdefined( t_bullseye ) || !isdefined( t_chalk_line ) )
        return;

    t_bullseye thread wait_for_valid_damage();
    t_chalk_line thread set_flags_while_players_stand_in_trigger();
    level thread mansion_ghost_plays_piano();
    level thread reward_think();
/#
    level thread devgui_support_ee();
#/
    flag_init( "player_piano_song_active" );
}

init_ee_ghost_piano_flags()
{
    self ent_flag_init( "ee_standing_behind_chalk_line" );
}

wait_for_valid_damage()
{
    self setcandamage( 1 );

    while ( true )
    {
        self waittill( "damage", e_inflictor, str_weapon_name );

        if ( is_ballistic_knife_variant( str_weapon_name ) )
        {
            if ( isdefined( e_inflictor ) && e_inflictor ent_flag_exist( "ee_standing_behind_chalk_line" ) && e_inflictor ent_flag( "ee_standing_behind_chalk_line" ) && !flag( "player_piano_song_active" ) )
                level notify( "player_can_interact_with_ghost_piano_player", e_inflictor );
        }
    }
}

is_ballistic_knife_variant( str_weapon )
{
    return issubstr( str_weapon, "knife_ballistic_" );
}

set_flags_while_players_stand_in_trigger()
{
    while ( true )
    {
        self waittill( "trigger", player );

        if ( !player ent_flag_exist( "ee_standing_behind_chalk_line" ) )
            player ent_flag_init( "ee_standing_behind_chalk_line" );

        if ( !player ent_flag( "ee_standing_behind_chalk_line" ) )
            player thread clear_flag_when_player_leaves_trigger( self );
    }
}

clear_flag_when_player_leaves_trigger( trigger )
{
    self endon( "death_or_disconnect" );
    self ent_flag_set( "ee_standing_behind_chalk_line" );

    while ( self istouching( trigger ) )
        wait 0.25;

    self ent_flag_clear( "ee_standing_behind_chalk_line" );
}

#using_animtree("fxanim_props_dlc3");

player_piano_starts()
{
/#
    iprintln( "player piano tune song start" );
#/
    flag_set( "player_piano_song_active" );
    level notify( "piano_play" );
    level setclientfield( "mansion_piano_play", 1 );
    level setclientfield( "saloon_piano_play", 1 );
    wait( getanimlength( %fxanim_gp_piano_old_anim ) );
/#
    iprintln( "player piano song done" );
#/
    level setclientfield( "mansion_piano_play", 0 );
    level setclientfield( "saloon_piano_play", 0 );
    flag_clear( "player_piano_song_active" );
}

mansion_ghost_plays_piano()
{
    while ( true )
    {
        flag_wait( "player_piano_song_active" );
        e_ghost = spawn_and_animate_ghost_pianist();
        flag_waitopen( "player_piano_song_active" );
        e_ghost thread delete_ghost_pianist();
    }
}

#using_animtree("zm_buried_ghost");

spawn_and_animate_ghost_pianist()
{
    s_anim = getstruct( "ee_mansion_piano_anim_struct", "targetname" );
    e_temp = spawn( "script_model", s_anim.origin );
    e_temp.angles = s_anim.angles;
    e_temp setclientfield( "ghost_fx", 3 );
    e_temp setmodel( "c_zom_zombie_buried_ghost_woman_fb" );
    e_temp useanimtree( -1 );
    e_temp setanim( %ai_zombie_ghost_playing_piano );
    e_temp setclientfield( "sndGhostAudio", 1 );
/#
    iprintln( "ghost piano player spawned" );
#/
    return e_temp;
}

reward_think()
{
    t_use = getent( "ee_ghost_piano_mansion_use_trigger", "targetname" );
    t_use sethintstring( &"ZM_BURIED_HINT_GHOST_PIANO", 10 );
    t_use setinvisibletoall();

    while ( true )
    {
        level waittill( "player_can_interact_with_ghost_piano_player", player );

        level thread player_piano_starts();

        if ( !player has_player_received_reward() )
        {
            t_use setvisibletoplayer( player );
            t_use thread player_can_use_ghost_piano_trigger( player );
        }

        flag_waitopen( "player_piano_song_active" );
        t_use setinvisibletoall();
        level notify( "ghost_piano_reward_unavailable" );
    }
}

player_can_use_ghost_piano_trigger( player )
{
    player endon( "death_or_disconnect" );
    level endon( "ghost_piano_reward_unavailable" );

    do
        self waittill( "trigger", user );
    while ( user != player || player.score < 10 || !is_player_valid( player ) );

    if ( !player has_player_received_reward() )
        self give_reward( player );
}

give_reward( player )
{
    player maps\mp\zombies\_zm_score::minus_to_player_score( 10 );
    player.got_easter_egg_reward = 1;
    self setinvisibletoplayer( player );
    player notify( "player_received_ghost_round_free_perk" );
    free_perk = player maps\mp\zombies\_zm_perks::give_random_perk();

    if ( is_true( level.disable_free_perks_before_power ) )
        player thread maps\mp\zombies\_zm_powerups::disable_perk_before_power( free_perk );
/#
    iprintln( "player got reward!!" );
#/
}

has_player_received_reward()
{
    return is_true( self.got_easter_egg_reward );
}

delete_ghost_pianist()
{
    self setclientfield( "ghost_fx", 5 );
    self playsound( "zmb_ai_ghost_death" );
    wait_network_frame();
    self delete();
/#
    iprintln( "ghost piano player deleted" );
#/
}

devgui_support_ee()
{
    while ( true )
    {
        str_notify = level waittill_any_return( "ghost_piano_warp_to_mansion_piano", "ghost_piano_warp_to_bar" );

        if ( str_notify == "ghost_piano_warp_to_mansion_piano" )
            get_players()[0] warp_to_struct( "ee_warp_mansion_piano", "targetname" );
        else if ( str_notify == "ghost_piano_warp_to_bar" )
            get_players()[0] warp_to_struct( "ee_warp_bar", "targetname" );
    }
}

warp_to_struct( str_value, str_key )
{
    if ( !isdefined( str_key ) )
        str_key = "targetname";

    s_warp = getstruct( str_value, str_key );
    self setorigin( s_warp.origin );

    if ( isdefined( s_warp.angles ) )
        self setplayerangles( s_warp.angles );
}
