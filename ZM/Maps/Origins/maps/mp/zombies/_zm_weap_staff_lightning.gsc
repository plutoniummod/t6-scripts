// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_score;
#include maps\mp\animscripts\shared;

init()
{
    level._effect["lightning_miss"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_elec_ug_impact_miss" );
    level._effect["lightning_arc"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_elec_trail_bolt_cheap" );
    level._effect["lightning_impact"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_elec_ug_impact_hit_torso" );
    level._effect["tesla_shock_eyes"] = loadfx( "maps/zombie/fx_zombie_tesla_shock_eyes" );
    registerclientfield( "actor", "lightning_impact_fx", 14000, 1, "int" );
    registerclientfield( "scriptmover", "lightning_miss_fx", 14000, 1, "int" );
    registerclientfield( "actor", "lightning_arc_fx", 14000, 1, "int" );
    set_zombie_var( "tesla_head_gib_chance", 50 );
    onplayerconnect_callback( ::onplayerconnect );
    maps\mp\zombies\_zm_spawner::register_zombie_damage_callback( ::staff_lightning_zombie_damage_response );
    maps\mp\zombies\_zm_spawner::register_zombie_death_event_callback( ::staff_lightning_death_event );
}

precache()
{
    precacheitem( "staff_lightning_melee_zm" );
}

onplayerconnect()
{
    self thread onplayerspawned();
}

onplayerspawned()
{
    self endon( "disconnect" );
    self thread watch_staff_lightning_fired();
    self thread watch_staff_usage();
}

watch_staff_lightning_fired()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "missile_fire", e_projectile, str_weapon );

        if ( str_weapon == "staff_lightning_upgraded2_zm" || str_weapon == "staff_lightning_upgraded3_zm" )
        {
            fire_angles = vectortoangles( self getweaponforwarddir() );
            fire_origin = self getweaponmuzzlepoint();
            self thread staff_lightning_position_source( fire_origin, fire_angles, str_weapon );
        }
    }
}

lightning_ball_wait( n_lifetime_after_move )
{
    level endon( "lightning_ball_created" );

    self waittill( "movedone" );

    wait( n_lifetime_after_move );
    return 1;
}

staff_lightning_position_source( v_detonate, v_angles, str_weapon )
{
    self endon( "disconnect" );
    level notify( "lightning_ball_created" );

    if ( !isdefined( v_angles ) )
        v_angles = ( 0, 0, 0 );

    e_ball_fx = spawn( "script_model", v_detonate + anglestoforward( v_angles ) * 100.0 );
    e_ball_fx.angles = v_angles;
    e_ball_fx.str_weapon = str_weapon;
    e_ball_fx setmodel( "tag_origin" );
    e_ball_fx.n_range = get_lightning_blast_range( self.chargeshotlevel );
    e_ball_fx.n_damage_per_sec = get_lightning_ball_damage_per_sec( self.chargeshotlevel );
    e_ball_fx setclientfield( "lightning_miss_fx", 1 );
    n_shot_range = staff_lightning_get_shot_range( self.chargeshotlevel );
    v_end = v_detonate + anglestoforward( v_angles ) * n_shot_range;
    trace = bullettrace( v_detonate, v_end, 0, undefined );

    if ( trace["fraction"] != 1 )
        v_end = trace["position"];

    staff_lightning_ball_speed = n_shot_range / 8.0;
    n_dist = distance( e_ball_fx.origin, v_end );
    n_max_movetime_s = n_shot_range / staff_lightning_ball_speed;
    n_movetime_s = n_dist / staff_lightning_ball_speed;
    n_leftover_time = n_max_movetime_s - n_movetime_s;
    e_ball_fx thread staff_lightning_ball_kill_zombies( self );
/#
    e_ball_fx thread puzzle_debug_position( "X", ( 175, 0, 255 ) );
#/
    e_ball_fx moveto( v_end, n_movetime_s );
    finished_playing = e_ball_fx lightning_ball_wait( n_leftover_time );
    e_ball_fx notify( "stop_killing" );
    e_ball_fx notify( "stop_debug_position" );

    if ( is_true( finished_playing ) )
        wait 3.0;

    if ( isdefined( e_ball_fx ) )
        e_ball_fx delete();
}

staff_lightning_ball_kill_zombies( e_attacker )
{
    self endon( "death" );
    self endon( "stop_killing" );

    while ( true )
    {
        a_zombies = staff_lightning_get_valid_targets( e_attacker, self.origin );

        if ( isdefined( a_zombies ) )
        {
            foreach ( zombie in a_zombies )
            {
                if ( staff_lightning_is_target_valid( zombie ) )
                {
                    e_attacker thread staff_lightning_arc_fx( self, zombie );
                    wait 0.2;
                }
            }
        }

        wait 0.5;
    }
}

staff_lightning_get_valid_targets( player, v_source )
{
    player endon( "disconnect" );
    a_enemies = [];
    a_zombies = getaiarray( level.zombie_team );
    a_zombies = get_array_of_closest( v_source, a_zombies, undefined, undefined, self.n_range );

    if ( isdefined( a_zombies ) )
    {
        foreach ( ai_zombie in a_zombies )
        {
            if ( staff_lightning_is_target_valid( ai_zombie ) )
                a_enemies[a_enemies.size] = ai_zombie;
        }
    }

    return a_enemies;
}

staff_lightning_get_shot_range( n_charge )
{
    switch ( n_charge )
    {
        case 3:
            return 1200;
        default:
            return 800;
    }
}

get_lightning_blast_range( n_charge )
{
    switch ( n_charge )
    {
        case 1:
            n_range = 200;
            break;
        case 2:
            n_range = 150;
            break;
        case 3:
        default:
            n_range = 250;
            break;
    }

    return n_range;
}

get_lightning_ball_damage_per_sec( n_charge )
{
    if ( !isdefined( n_charge ) )
        return 2500;

    switch ( n_charge )
    {
        case 3:
            return 3500;
        default:
            return 2500;
    }
}

staff_lightning_is_target_valid( ai_zombie )
{
    if ( !isdefined( ai_zombie ) )
        return false;

    if ( is_true( ai_zombie.is_being_zapped ) )
        return false;

    if ( is_true( ai_zombie.is_mechz ) )
        return false;

    return true;
}

staff_lightning_ball_damage_over_time( e_source, e_target, e_attacker )
{
    e_attacker endon( "disconnect" );
    e_target setclientfield( "lightning_impact_fx", 1 );
    e_target thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "electrocute", e_target.animname );
    n_range_sq = e_source.n_range * e_source.n_range;
    e_target.is_being_zapped = 1;
    e_target setclientfield( "lightning_arc_fx", 1 );
    wait 0.5;

    if ( isdefined( e_source ) )
    {
        if ( !isdefined( e_source.n_damage_per_sec ) )
            e_source.n_damage_per_sec = get_lightning_ball_damage_per_sec( e_attacker.chargeshotlevel );

        n_damage_per_pulse = e_source.n_damage_per_sec * 1.0;
    }

    while ( isdefined( e_source ) && isalive( e_target ) )
    {
        e_target thread stun_zombie();
        wait 1.0;

        if ( !isdefined( e_source ) || !isalive( e_target ) )
            break;

        n_dist_sq = distancesquared( e_source.origin, e_target.origin );

        if ( n_dist_sq > n_range_sq )
            break;

        if ( isalive( e_target ) && isdefined( e_source ) )
        {
            instakill_on = e_attacker maps\mp\zombies\_zm_powerups::is_insta_kill_active();

            if ( n_damage_per_pulse < e_target.health && !instakill_on )
                e_target do_damage_network_safe( e_attacker, n_damage_per_pulse, e_source.str_weapon, "MOD_RIFLE_BULLET" );
            else
            {
                e_target thread zombie_shock_eyes();
                e_target thread staff_lightning_kill_zombie( e_attacker, e_source.str_weapon );
                break;
            }
        }
    }

    if ( isdefined( e_target ) )
    {
        e_target.is_being_zapped = 0;
        e_target setclientfield( "lightning_arc_fx", 0 );
    }
}

staff_lightning_arc_fx( e_source, ai_zombie )
{
    self endon( "disconnect" );

    if ( !isdefined( ai_zombie ) )
        return;

    if ( !bullet_trace_throttled( e_source.origin, ai_zombie.origin + vectorscale( ( 0, 0, 1 ), 20.0 ), ai_zombie ) )
        return;

    if ( isdefined( e_source ) && isdefined( ai_zombie ) && isalive( ai_zombie ) )
        level thread staff_lightning_ball_damage_over_time( e_source, ai_zombie, self );
}

staff_lightning_kill_zombie( player, str_weapon )
{
    player endon( "disconnect" );

    if ( !isalive( self ) )
        return;

    if ( is_true( self.has_legs ) )
    {
        if ( !self hasanimstatefromasd( "zm_death_tesla" ) )
            return;

        self.deathanim = "zm_death_tesla";
    }
    else
    {
        if ( !self hasanimstatefromasd( "zm_death_tesla_crawl" ) )
            return;

        self.deathanim = "zm_death_tesla_crawl";
    }

    if ( is_true( self.is_traversing ) )
        self.deathanim = undefined;

    self do_damage_network_safe( player, self.health, str_weapon, "MOD_RIFLE_BULLET" );
    player maps\mp\zombies\_zm_score::player_add_points( "death", "", "" );
}

staff_lightning_death_fx()
{
    if ( isdefined( self ) )
    {
        self setclientfield( "lightning_impact_fx", 1 );
        self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "electrocute", self.animname );
        self thread zombie_shock_eyes();
    }
}

zombie_shock_eyes_network_safe( fx, entity, tag )
{
    if ( network_entity_valid( entity ) )
    {
        if ( !is_true( self.head_gibbed ) )
            playfxontag( fx, entity, tag );
    }
}

zombie_shock_eyes()
{
    if ( isdefined( self.head_gibbed ) && self.head_gibbed )
        return;

    maps\mp\zombies\_zm_net::network_safe_init( "shock_eyes", 2 );
    maps\mp\zombies\_zm_net::network_choke_action( "shock_eyes", ::zombie_shock_eyes_network_safe, level._effect["tesla_shock_eyes"], self, "J_Eyeball_LE" );
}

staff_lightning_zombie_damage_response( mod, hit_location, hit_origin, player, amount )
{
    if ( self is_staff_lightning_damage() && self.damagemod != "MOD_RIFLE_BULLET" )
        self thread stun_zombie();

    return 0;
}

is_staff_lightning_damage()
{
    return isdefined( self.damageweapon ) && ( self.damageweapon == "staff_lightning_zm" || self.damageweapon == "staff_lightning_upgraded_zm" ) && !is_true( self.set_beacon_damage );
}

staff_lightning_death_event()
{
    if ( is_staff_lightning_damage() && self.damagemod != "MOD_MELEE" )
    {
        if ( is_true( self.is_mechz ) )
            return;

        self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "death", self.animname );
        self thread zombie_eye_glow_stop();

        if ( is_true( self.has_legs ) )
        {
            if ( !self hasanimstatefromasd( "zm_death_tesla" ) )
                return;

            self.deathanim = "zm_death_tesla";
        }
        else
        {
            if ( !self hasanimstatefromasd( "zm_death_tesla_crawl" ) )
                return;

            self.deathanim = "zm_death_tesla_crawl";
        }

        if ( is_true( self.is_traversing ) )
            self.deathanim = undefined;

        tag = "J_SpineUpper";
        self setclientfield( "lightning_impact_fx", 1 );
        self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "electrocute", self.animname );
        self thread zombie_shock_eyes();

        if ( isdefined( self.deathanim ) )
            self waittillmatch( "death_anim", "die" );

        self do_damage_network_safe( self.attacker, self.health, self.damageweapon, "MOD_RIFLE_BULLET" );
    }
}

stun_zombie()
{
    self endon( "death" );

    if ( is_true( self.is_mechz ) )
        return;

    if ( is_true( self.is_electrocuted ) )
        return;

    if ( !isdefined( self.ai_state ) || self.ai_state != "find_flesh" )
        return;

    self.forcemovementscriptstate = 1;
    self.ignoreall = 1;
    self.is_electrocuted = 1;
    tag = "J_SpineUpper";
    network_safe_play_fx_on_tag( "lightning_impact", 2, level._effect["lightning_impact"], self, tag );

    if ( is_true( self.has_legs ) )
        self animscripted( self.origin, self.angles, "zm_electric_stun" );

    self maps\mp\animscripts\shared::donotetracks( "stunned" );
    self.forcemovementscriptstate = 0;
    self.ignoreall = 0;
    self.is_electrocuted = 0;
}
