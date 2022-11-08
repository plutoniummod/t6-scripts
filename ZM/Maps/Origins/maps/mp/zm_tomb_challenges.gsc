// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zm_tomb_vo;
#include raw\maps\mp\_zm_challenges;
#include maps\mp\zombies\_zm_challenges;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_powerup_zombie_blood;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_weap_one_inch_punch;

challenges_init()
{
    level.challenges_add_stats = ::tomb_challenges_add_stats;
    maps\mp\zombies\_zm_challenges::init();
}

tomb_challenges_add_stats()
{
    n_kills = 115;
    n_zone_caps = 6;
    n_points_spent = 30000;
    n_boxes_filled = 4;
/#
    if ( getdvarint( _hash_FA81816F ) > 0 )
    {
        n_kills = 1;
        n_zone_caps = 2;
        n_points_spent = 500;
        n_boxes_filled = 1;
    }
#/
    add_stat( "zc_headshots", 0, &"ZM_TOMB_CH1", n_kills, undefined, ::reward_packed_weapon );
    add_stat( "zc_zone_captures", 0, &"ZM_TOMB_CH2", n_zone_caps, undefined, ::reward_powerup_max_ammo );
    add_stat( "zc_points_spent", 0, &"ZM_TOMB_CH3", n_points_spent, undefined, ::reward_double_tap, ::track_points_spent );
    add_stat( "zc_boxes_filled", 1, &"ZM_TOMB_CHT", n_boxes_filled, undefined, ::reward_one_inch_punch, ::init_box_footprints );
}

track_points_spent()
{
    while ( true )
    {
        level waittill( "spent_points", player, points );

        player increment_stat( "zc_points_spent", points );
    }
}

init_box_footprints()
{
    level.n_soul_boxes_completed = 0;
    flag_init( "vo_soul_box_intro_played" );
    flag_init( "vo_soul_box_continue_played" );
    a_boxes = getentarray( "foot_box", "script_noteworthy" );
    array_thread( a_boxes, ::box_footprint_think );
}

#using_animtree("fxanim_props_dlc4");

box_footprint_think()
{
    self.n_souls_absorbed = 0;
    n_souls_required = 30;
/#
    if ( getdvarint( _hash_FA81816F ) > 0 )
        n_souls_required = 10;
#/
    self useanimtree( #animtree );
    self thread watch_for_foot_stomp();
    wait 1;
    self setclientfield( "foot_print_box_glow", 1 );
    wait 1;
    self setclientfield( "foot_print_box_glow", 0 );

    while ( self.n_souls_absorbed < n_souls_required )
    {
        self waittill( "soul_absorbed", player );

        self.n_souls_absorbed++;

        if ( self.n_souls_absorbed == 1 )
        {
            self clearanim( %o_zombie_dlc4_challenge_box_close, 0 );
            self setanim( %o_zombie_dlc4_challenge_box_open );
            self delay_thread( 1, ::setclientfield, "foot_print_box_glow", 1 );

            if ( isdefined( player ) && !flag( "vo_soul_box_intro_played" ) )
                player delay_thread( 1.5, ::richtofenrespondvoplay, "zm_box_start", 0, "vo_soul_box_intro_played" );
        }

        if ( self.n_souls_absorbed == floor( n_souls_required / 4 ) )
        {
            if ( isdefined( player ) && flag( "vo_soul_box_intro_played" ) && !flag( "vo_soul_box_continue_played" ) )
                player thread richtofenrespondvoplay( "zm_box_continue", 1, "vo_soul_box_continue_played" );
        }

        if ( self.n_souls_absorbed == floor( n_souls_required / 2 ) || self.n_souls_absorbed == floor( n_souls_required / 1.3 ) )
        {
            if ( isdefined( player ) )
                player create_and_play_dialog( "soul_box", "zm_box_encourage" );
        }

        if ( self.n_souls_absorbed == n_souls_required )
        {
            wait 1;
            self clearanim( %o_zombie_dlc4_challenge_box_open, 0 );
            self setanim( %o_zombie_dlc4_challenge_box_close );
        }
    }

    self notify( "box_finished" );
    level.n_soul_boxes_completed++;
    e_volume = getent( self.target, "targetname" );
    e_volume delete();
    self delay_thread( 0.5, ::setclientfield, "foot_print_box_glow", 0 );
    wait 1;
    self movez( 30, 1, 1 );
    wait 0.5;
    n_rotations = randomintrange( 5, 7 );
    v_start_angles = self.angles;

    for ( i = 0; i < n_rotations; i++ )
    {
        v_rotate_angles = v_start_angles + ( randomfloatrange( -10, 10 ), randomfloatrange( -10, 10 ), randomfloatrange( -10, 10 ) );
        n_rotate_time = randomfloatrange( 0.2, 0.4 );
        self rotateto( v_rotate_angles, n_rotate_time );

        self waittill( "rotatedone" );
    }

    self rotateto( v_start_angles, 0.3 );
    self movez( -60, 0.5, 0.5 );

    self waittill( "rotatedone" );

    trace_start = self.origin + vectorscale( ( 0, 0, 1 ), 200.0 );
    trace_end = self.origin;
    fx_trace = bullettrace( trace_start, trace_end, 0, self );
    playfx( level._effect["mech_booster_landing"], fx_trace["position"], anglestoforward( self.angles ), anglestoup( self.angles ) );
    playsoundatposition( "zmb_footprintbox_disappear", self.origin );

    self waittill( "movedone" );

    level maps\mp\zombies\_zm_challenges::increment_stat( "zc_boxes_filled" );

    if ( isdefined( player ) )
    {
        if ( level.n_soul_boxes_completed == 1 )
            player thread richtofenrespondvoplay( "zm_box_complete" );
        else if ( level.n_soul_boxes_completed == 4 )
            player thread richtofenrespondvoplay( "zm_box_final_complete", 1 );
    }

    self delete();
}

watch_for_foot_stomp()
{
    self endon( "box_finished" );

    while ( true )
    {
        self waittill( "robot_foot_stomp" );

        self clearanim( %o_zombie_dlc4_challenge_box_open, 0 );
        self setanim( %o_zombie_dlc4_challenge_box_close );
        self setclientfield( "foot_print_box_glow", 0 );
        self.n_souls_absorbed = 0;
        wait 5;
    }
}

footprint_zombie_killed( attacker )
{
    a_volumes = getentarray( "foot_box_volume", "script_noteworthy" );

    foreach ( e_volume in a_volumes )
    {
        if ( self istouching( e_volume ) && isdefined( attacker ) && isplayer( attacker ) )
        {
            self setclientfield( "foot_print_box_fx", 1 );
            m_box = getent( e_volume.target, "targetname" );
            m_box notify( "soul_absorbed", attacker );
            return true;
        }
    }

    return false;
}

reward_packed_weapon( player, s_stat )
{
    if ( !isdefined( s_stat.str_reward_weapon ) )
    {
        a_weapons = array( "scar_zm", "galil_zm", "mp44_zm" );
        s_stat.str_reward_weapon = maps\mp\zombies\_zm_weapons::get_upgrade_weapon( random( a_weapons ) );
    }

    m_weapon = spawn( "script_model", self.origin );
    m_weapon.angles = self.angles + vectorscale( ( 0, 1, 0 ), 180.0 );
    m_weapon playsound( "zmb_spawn_powerup" );
    m_weapon playloopsound( "zmb_spawn_powerup_loop", 0.5 );
    str_model = getweaponmodel( s_stat.str_reward_weapon );
    options = player maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( s_stat.str_reward_weapon );
    m_weapon useweaponmodel( s_stat.str_reward_weapon, str_model, options );
    wait_network_frame();

    if ( !reward_rise_and_grab( m_weapon, 50, 2, 2, 10 ) )
        return false;

    weapon_limit = get_player_weapon_limit( player );
    primaries = player getweaponslistprimaries();

    if ( isdefined( primaries ) && primaries.size >= weapon_limit )
        player maps\mp\zombies\_zm_weapons::weapon_give( s_stat.str_reward_weapon );
    else
    {
        player giveweapon( s_stat.str_reward_weapon, 0, player maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( s_stat.str_reward_weapon ) );
        player givestartammo( s_stat.str_reward_weapon );
    }

    player switchtoweapon( s_stat.str_reward_weapon );
    m_weapon stoploopsound( 0.1 );
    player playsound( "zmb_powerup_grabbed" );
    m_weapon delete();
    return true;
}

reward_powerup_max_ammo( player, s_stat )
{
    return reward_powerup( player, "full_ammo" );
}

reward_powerup_double_points( player, n_timeout )
{
    return reward_powerup( player, "double_points", n_timeout );
}

reward_powerup_zombie_blood( player, n_timeout )
{
    return reward_powerup( player, "zombie_blood", n_timeout );
}

reward_powerup( player, str_powerup, n_timeout = 10 )
{
    if ( !isdefined( level.zombie_powerups[str_powerup] ) )
        return;

    s_powerup = level.zombie_powerups[str_powerup];
    m_reward = spawn( "script_model", self.origin );
    m_reward.angles = self.angles + vectorscale( ( 0, 1, 0 ), 180.0 );
    m_reward setmodel( s_powerup.model_name );
    m_reward playsound( "zmb_spawn_powerup" );
    m_reward playloopsound( "zmb_spawn_powerup_loop", 0.5 );
    wait_network_frame();

    if ( !reward_rise_and_grab( m_reward, 50, 2, 2, n_timeout ) )
        return 0;

    m_reward.hint = s_powerup.hint;

    if ( !isdefined( player ) )
        player = self.player_using;

    switch ( str_powerup )
    {
        case "full_ammo":
            level thread maps\mp\zombies\_zm_powerups::full_ammo_powerup( m_reward, player );
            player thread powerup_vo( "full_ammo" );
            level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "full_ammo", player.pers["team"] );
            break;
        case "double_points":
            level thread maps\mp\zombies\_zm_powerups::double_points_powerup( m_reward, player );
            player thread powerup_vo( "double_points" );
            level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "double_points", player.pers["team"] );
            break;
        case "zombie_blood":
            level thread maps\mp\zombies\_zm_powerup_zombie_blood::zombie_blood_powerup( m_reward, player );
            level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "zombie_blood", player.pers["team"] );
    }

    wait 0.1;
    m_reward stoploopsound( 0.1 );
    player playsound( "zmb_powerup_grabbed" );
    m_reward delete();
    return 1;
}

reward_double_tap( player, s_stat )
{
    m_reward = spawn( "script_model", self.origin );
    m_reward.angles = self.angles + vectorscale( ( 0, 1, 0 ), 180.0 );
    str_model = getweaponmodel( "zombie_perk_bottle_doubletap" );
    m_reward setmodel( str_model );
    m_reward playsound( "zmb_spawn_powerup" );
    m_reward playloopsound( "zmb_spawn_powerup_loop", 0.5 );
    wait_network_frame();

    if ( !reward_rise_and_grab( m_reward, 50, 2, 2, 10 ) )
        return false;

    if ( player hasperk( "specialty_rof" ) || player has_perk_paused( "specialty_rof" ) )
    {
        m_reward thread bottle_reject_sink( player );
        return false;
    }

    m_reward stoploopsound( 0.1 );
    player playsound( "zmb_powerup_grabbed" );
    m_reward thread maps\mp\zombies\_zm_perks::vending_trigger_post_think( player, "specialty_rof" );
    m_reward delete();
    return true;
}

bottle_reject_sink( player )
{
    n_time = 1;
    player playlocalsound( level.zmb_laugh_alias );
    self thread maps\mp\zombies\_zm_challenges::reward_sink( 0, 61, n_time );
    wait( n_time );
    self delete();
}

reward_one_inch_punch( player, s_stat )
{
    m_reward = spawn( "script_model", self.origin );
    m_reward.angles = self.angles + vectorscale( ( 0, 1, 0 ), 180.0 );
    m_reward setmodel( "tag_origin" );
    playfxontag( level._effect["staff_soul"], m_reward, "tag_origin" );
    m_reward playsound( "zmb_spawn_powerup" );
    m_reward playloopsound( "zmb_spawn_powerup_loop", 0.5 );
    wait_network_frame();

    if ( !reward_rise_and_grab( m_reward, 50, 2, 2, 10 ) )
        return false;

    player thread maps\mp\zombies\_zm_weap_one_inch_punch::one_inch_punch_melee_attack();
    m_reward stoploopsound( 0.1 );
    player playsound( "zmb_powerup_grabbed" );
    m_reward delete();
    player thread one_inch_punch_watch_for_death( s_stat );
    return true;
}

one_inch_punch_watch_for_death( s_stat )
{
    self endon( "disconnect" );

    self waittill( "bled_out" );

    if ( s_stat.b_reward_claimed )
        s_stat.b_reward_claimed = 0;

    s_stat.a_b_player_rewarded[self.characterindex] = 0;
}

reward_beacon( player, s_stat )
{
    m_reward = spawn( "script_model", self.origin );
    m_reward.angles = self.angles + vectorscale( ( 0, 1, 0 ), 180.0 );
    str_model = getweaponmodel( "beacon_zm" );
    m_reward setmodel( str_model );
    m_reward playsound( "zmb_spawn_powerup" );
    m_reward playloopsound( "zmb_spawn_powerup_loop", 0.5 );
    wait_network_frame();

    if ( !reward_rise_and_grab( m_reward, 50, 2, 2, 10 ) )
        return false;

    player maps\mp\zombies\_zm_weapons::weapon_give( "beacon_zm" );

    if ( isdefined( level.zombie_include_weapons["beacon_zm"] ) && !level.zombie_include_weapons["beacon_zm"] )
    {
        level.zombie_include_weapons["beacon_zm"] = 1;
        level.zombie_weapons["beacon_zm"].is_in_box = 1;
    }

    m_reward stoploopsound( 0.1 );
    player playsound( "zmb_powerup_grabbed" );
    m_reward delete();
    return true;
}
