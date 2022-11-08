// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_powerups;

init()
{
    registerclientfield( "actor", "fire_char_fx", 14000, 1, "int" );
    registerclientfield( "toplayer", "fire_muzzle_fx", 14000, 1, "int" );
    onplayerconnect_callback( ::onplayerconnect );
    maps\mp\zombies\_zm_ai_basic::init_inert_zombies();
    maps\mp\zombies\_zm_spawner::register_zombie_damage_callback( ::staff_fire_zombie_damage_response );
    maps\mp\zombies\_zm_spawner::register_zombie_death_event_callback( ::staff_fire_death_event );
}

precache()
{
    precacheitem( "staff_fire_melee_zm" );
}

onplayerconnect()
{
    self thread onplayerspawned();
}

onplayerspawned()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "spawned_player" );

        self thread watch_staff_fire_upgrade_fired();
        self thread watch_staff_fire_fired();
        self thread watch_staff_usage();
    }
}

watch_staff_fire_fired()
{
    self notify( "watch_staff_fired" );
    self endon( "disconnect" );
    self endon( "watch_staff_fired" );

    while ( true )
    {
        self waittill( "missile_fire", e_projectile, str_weapon );

        if ( is_true( e_projectile.additional_shot ) )
            continue;

        if ( str_weapon == "staff_fire_zm" || str_weapon == "staff_fire_upgraded_zm" )
            self fire_spread_shots( str_weapon );
    }
}

watch_staff_fire_upgrade_fired()
{
    self notify( "watch_staff_upgrade_fired" );
    self endon( "disconnect" );
    self endon( "watch_staff_upgrade_fired" );

    while ( true )
    {
        self waittill( "grenade_fire", e_projectile, str_weapon );

        if ( is_true( e_projectile.additional_shot ) )
            continue;

        if ( str_weapon == "staff_fire_upgraded2_zm" || str_weapon == "staff_fire_upgraded3_zm" )
        {
            e_projectile thread fire_staff_update_grenade_fuse();
            e_projectile thread fire_staff_area_of_effect( self, str_weapon );
            self fire_additional_shots( str_weapon );
        }
    }
}

fire_spread_shots( str_weapon )
{
    wait_network_frame();
    wait_network_frame();
    v_fwd = self getweaponforwarddir();
    fire_angles = vectortoangles( v_fwd );
    fire_origin = self getweaponmuzzlepoint();
    trace = bullettrace( fire_origin, fire_origin + v_fwd * 100.0, 0, undefined );

    if ( trace["fraction"] != 1 )
        return;

    v_left_angles = ( fire_angles[0], fire_angles[1] - 15, fire_angles[2] );
    v_left = anglestoforward( v_left_angles );
    e_proj = magicbullet( str_weapon, fire_origin + v_fwd * 50.0, fire_origin + v_left * 100.0, self );
    e_proj.additional_shot = 1;
    wait_network_frame();
    wait_network_frame();
    v_fwd = self getweaponforwarddir();
    fire_angles = vectortoangles( v_fwd );
    fire_origin = self getweaponmuzzlepoint();
    v_right_angles = ( fire_angles[0], fire_angles[1] + 15, fire_angles[2] );
    v_right = anglestoforward( v_right_angles );
    e_proj = magicbullet( str_weapon, fire_origin + v_fwd * 50.0, fire_origin + v_right * 100.0, self );
    e_proj.additional_shot = 1;
}

fire_staff_area_of_effect( e_attacker, str_weapon )
{
    self waittill( "explode", v_pos );

    ent = spawn( "script_origin", v_pos );
    ent playloopsound( "wpn_firestaff_grenade_loop", 1 );
/#
    level thread puzzle_debug_position( "X", vectorscale( ( 1, 0, 0 ), 255.0 ), v_pos, undefined, 5.0 );
#/
    n_alive_time = 5.0;
    aoe_radius = 80;

    if ( str_weapon == "staff_fire_upgraded3_zm" )
        aoe_radius = 100;

    n_step_size = 0.2;

    while ( n_alive_time > 0.0 )
    {
        if ( n_alive_time - n_step_size <= 0.0 )
            aoe_radius *= 2;

        a_targets = getaiarray( "axis" );
        a_targets = get_array_of_closest( v_pos, a_targets, undefined, undefined, aoe_radius );
        wait( n_step_size );
        n_alive_time -= n_step_size;

        foreach ( e_target in a_targets )
        {
            if ( isdefined( e_target ) && isalive( e_target ) )
            {
                if ( !is_true( self.is_on_fire ) )
                    e_target thread flame_damage_fx( str_weapon, e_attacker );
            }
        }
    }

    ent playsound( "wpn_firestaff_proj_impact" );
    ent delete();
}

grenade_waittill_still_or_bounce()
{
    self endon( "death" );
    self endon( "grenade_bounce" );
    wait 0.5;

    do
    {
        prev_origin = self.origin;
        wait_network_frame();
        wait_network_frame();
    }
    while ( prev_origin != self.origin );
}

fire_staff_update_grenade_fuse()
{
    self endon( "death" );
    self grenade_waittill_still_or_bounce();
    self notify( "fire_aoe_start", self.origin );
    self resetmissiledetonationtime( 0.0 );
}

fire_additional_shots( str_weapon )
{
    self endon( "disconnect" );
    self endon( "weapon_change" );
    n_shots = 1;

    if ( str_weapon == "staff_fire_upgraded3_zm" )
        n_shots = 2;

    for ( i = 1; i <= n_shots; i++ )
    {
        wait 0.35;

        if ( isdefined( self ) && self getcurrentweapon() == "staff_fire_upgraded_zm" )
        {
            v_player_angles = vectortoangles( self getweaponforwarddir() );
            n_player_pitch = v_player_angles[0];
            n_player_pitch += 5 * i;
            n_player_yaw = v_player_angles[1] + randomfloatrange( -15.0, 15.0 );
            v_shot_angles = ( n_player_pitch, n_player_yaw, v_player_angles[2] );
            v_shot_start = self getweaponmuzzlepoint();
            v_shot_end = v_shot_start + anglestoforward( v_shot_angles );
            e_proj = magicbullet( str_weapon, v_shot_start, v_shot_end, self );
            e_proj.additional_shot = 1;
            e_proj thread fire_staff_update_grenade_fuse();
            e_proj thread fire_staff_area_of_effect( self, str_weapon );
            self setclientfieldtoplayer( "fire_muzzle_fx", 1 );
            wait_network_frame();
            self setclientfieldtoplayer( "fire_muzzle_fx", 0 );
        }
    }
}

staff_fire_zombie_damage_response( mod, hit_location, hit_origin, player, amount )
{
    if ( self is_staff_fire_damage() && mod != "MOD_MELEE" )
    {
        self thread staff_fire_zombie_hit_response_internal( mod, self.damageweapon, player, amount );
        return true;
    }

    return false;
}

is_staff_fire_damage()
{
    return isdefined( self.damageweapon ) && ( self.damageweapon == "staff_fire_zm" || self.damageweapon == "staff_fire_upgraded_zm" || self.damageweapon == "staff_fire_upgraded2_zm" || self.damageweapon == "staff_fire_upgraded3_zm" ) && !is_true( self.set_beacon_damage );
}

staff_fire_zombie_hit_response_internal( mod, damageweapon, player, amount )
{
    player endon( "disconnect" );

    if ( !isalive( self ) )
        return;

    if ( mod != "MOD_BURNED" && mod != "MOD_GRENADE_SPLASH" )
    {
        pct_from_center = ( amount - 1.0 ) / 10.0;
        pct_damage = 0.5 + 0.5 * pct_from_center;

        if ( is_true( self.is_mechz ) )
        {
            self thread mechz_flame_damage( damageweapon, player, pct_damage );
            return;
        }

        self thread flame_damage_fx( damageweapon, player, pct_damage );
    }
}

staff_fire_death_event()
{
    if ( is_staff_fire_damage() && self.damagemod != "MOD_MELEE" )
    {
        self setclientfield( "fire_char_fx", 1 );
        self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "death", self.animname );
        self thread zombie_eye_glow_stop();
    }
}

on_fire_timeout( n_duration )
{
    self endon( "death" );
    wait( n_duration );
    self.is_on_fire = 0;
    self notify( "stop_flame_damage" );
}

flame_damage_fx( damageweapon, e_attacker, pct_damage = 1.0 )
{
    was_on_fire = is_true( self.is_on_fire );
    n_initial_dmg = get_impact_damage( damageweapon ) * pct_damage;
    is_upgraded = damageweapon == "staff_fire_upgraded_zm" || damageweapon == "staff_fire_upgraded2_zm" || damageweapon == "staff_fire_upgraded3_zm";

    if ( is_upgraded && pct_damage > 0.5 && n_initial_dmg > self.health && cointoss() )
    {
        self do_damage_network_safe( e_attacker, self.health, damageweapon, "MOD_BURNED" );

        if ( cointoss() )
            self thread zombie_gib_all();
        else
            self thread zombie_gib_guts();

        return;
    }

    self endon( "death" );

    if ( !was_on_fire )
    {
        self.is_on_fire = 1;
        self thread zombie_set_and_restore_flame_state();
        wait 0.5;
        self thread flame_damage_over_time( e_attacker, damageweapon, pct_damage );
    }

    if ( n_initial_dmg > 0 )
        self do_damage_network_safe( e_attacker, n_initial_dmg, damageweapon, "MOD_BURNED" );
}

_fire_stun_zombie_internal( do_stun, run_cycle )
{
    if ( !isalive( self ) )
        return;

    if ( is_true( self.has_legs ) )
        self set_zombie_run_cycle( run_cycle );

    if ( do_stun )
        self animscripted( self.origin, self.angles, "zm_afterlife_stun" );
}

fire_stun_zombie_choked( do_stun, run_cycle )
{
    maps\mp\zombies\_zm_net::network_safe_init( "fire_stun", 2 );
    self maps\mp\zombies\_zm_net::network_choke_action( "fire_stun", ::_fire_stun_zombie_internal, do_stun, run_cycle );
}

zombie_set_and_restore_flame_state()
{
    if ( !isalive( self ) )
        return;

    if ( is_true( self.is_mechz ) )
        return;

    self setclientfield( "fire_char_fx", 1 );
    self.disablemelee = 1;
    prev_run_cycle = self.zombie_move_speed;

    if ( is_true( self.has_legs ) )
        self.deathanim = "zm_death_fire";

    if ( self.ai_state == "find_flesh" )
        self fire_stun_zombie_choked( 1, "burned" );

    self waittill( "stop_flame_damage" );

    self.deathanim = undefined;
    self.disablemelee = undefined;

    if ( self.ai_state == "find_flesh" )
        self fire_stun_zombie_choked( 0, prev_run_cycle );

    self setclientfield( "fire_char_fx", 0 );
}

get_impact_damage( damageweapon )
{
    switch ( damageweapon )
    {
        case "staff_fire_zm":
            return 2050;
        case "staff_fire_upgraded_zm":
            return 3300;
        case "staff_fire_upgraded2_zm":
            return 11500;
        case "staff_fire_upgraded3_zm":
            return 20000;
        case "one_inch_punch_fire_zm":
            return 0;
        default:
            return 0;
    }
}

get_damage_per_second( damageweapon )
{
    switch ( damageweapon )
    {
        case "staff_fire_zm":
            return 75;
        case "staff_fire_upgraded_zm":
            return 150;
        case "staff_fire_upgraded2_zm":
            return 300;
        case "staff_fire_upgraded3_zm":
            return 450;
        case "one_inch_punch_fire_zm":
            return 250;
        default:
            return self.health;
    }
}

get_damage_duration( damageweapon )
{
    switch ( damageweapon )
    {
        case "staff_fire_zm":
            return 8;
        case "staff_fire_upgraded_zm":
            return 8;
        case "staff_fire_upgraded2_zm":
            return 8;
        case "staff_fire_upgraded3_zm":
            return 8;
        case "one_inch_punch_fire_zm":
            return 8;
        default:
            return 8;
    }
}

flame_damage_over_time( e_attacker, damageweapon, pct_damage )
{
    e_attacker endon( "disconnect" );
    self endon( "death" );
    self endon( "stop_flame_damage" );
    n_damage = get_damage_per_second( damageweapon );
    n_duration = get_damage_duration( damageweapon );
    n_damage *= pct_damage;
    self thread on_fire_timeout( n_duration );

    while ( true )
    {
        if ( isdefined( e_attacker ) && isplayer( e_attacker ) )
        {
            if ( e_attacker maps\mp\zombies\_zm_powerups::is_insta_kill_active() )
                n_damage = self.health;
        }

        self do_damage_network_safe( e_attacker, n_damage, damageweapon, "MOD_BURNED" );
        wait 1.0;
    }
}

mechz_flame_damage( damageweapon, e_attacker, pct_damage )
{
    self endon( "death" );
    n_initial_dmg = get_impact_damage( damageweapon );

    if ( n_initial_dmg > 0 )
        self do_damage_network_safe( e_attacker, n_initial_dmg, damageweapon, "MOD_BURNED" );
}

stop_zombie()
{
    e_linker = spawn( "script_origin", ( 0, 0, 0 ) );
    e_linker.origin = self.origin;
    e_linker.angles = self.angles;
    self linkto( e_linker );

    self waittill( "death" );

    e_linker delete();
}
