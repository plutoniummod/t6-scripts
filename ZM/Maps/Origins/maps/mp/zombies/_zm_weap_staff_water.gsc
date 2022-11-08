// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_powerups;

init()
{
    level._effect["staff_water_blizzard"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_ice_ug_impact_hit" );
    level._effect["staff_water_ice_shard"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_ice_trail_bolt" );
    level._effect["staff_water_shatter"] = loadfx( "weapon/zmb_staff/fx_zmb_staff_ice_exp" );
    registerclientfield( "scriptmover", "staff_blizzard_fx", 14000, 1, "int" );
    registerclientfield( "actor", "anim_rate", 14000, 2, "float" );
    registerclientfield( "actor", "attach_bullet_model", 14000, 1, "int" );
    onplayerconnect_callback( ::onplayerconnect );
    precacheitem( "staff_water_fake_dart_zm" );
    precacheitem( "staff_water_dart_zm" );
    flag_init( "blizzard_active" );
    init_tag_array();
    level thread water_dart_cleanup();
    maps\mp\zombies\_zm_spawner::register_zombie_death_event_callback( ::staff_water_death_event );
    maps\mp\zombies\_zm_spawner::add_cusom_zombie_spawn_logic( ::staff_water_on_zombie_spawned );
}

precache()
{
    precacheitem( "staff_water_melee_zm" );
}

init_tag_array()
{
    level.zombie_water_icicle_tag = [];
    level.zombie_water_icicle_tag[0] = "j_hip_le";
    level.zombie_water_icicle_tag[1] = "j_hip_ri";
    level.zombie_water_icicle_tag[2] = "j_spine4";
    level.zombie_water_icicle_tag[3] = "j_elbow_le";
    level.zombie_water_icicle_tag[4] = "j_elbow_ri";
    level.zombie_water_icicle_tag[5] = "j_clavicle_le";
    level.zombie_water_icicle_tag[6] = "j_clavicle_ri";
}

water_dart_cleanup()
{
    while ( true )
    {
        a_grenades = getentarray( "grenade", "classname" );

        foreach ( e_grenade in a_grenades )
        {
            if ( isdefined( e_grenade.model ) && e_grenade.model == "p6_zm_tm_staff_projectile_ice" )
            {
                time = gettime();

                if ( time - e_grenade.birthtime >= 1000 )
                    e_grenade delete();
            }
        }

        wait 0.1;
    }
}

onplayerconnect()
{
    self thread onplayerspawned();
}

onplayerspawned()
{
    self endon( "disconnect" );
    self thread watch_staff_water_fired();
    self thread watch_staff_water_impact();
    self thread watch_staff_usage();
}

watch_staff_water_fired()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "missile_fire", e_projectile, str_weapon );

        if ( str_weapon == "staff_water_zm" || str_weapon == "staff_water_upgraded_zm" )
        {
            wait_network_frame();
            _icicle_locate_target( str_weapon );
            wait_network_frame();
            _icicle_locate_target( str_weapon );
            wait_network_frame();
            _icicle_locate_target( str_weapon );
        }
    }
}

watch_staff_water_impact()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "projectile_impact", str_weapon, v_explode_point, n_radius, str_name, n_impact );

        if ( str_weapon == "staff_water_upgraded2_zm" || str_weapon == "staff_water_upgraded3_zm" )
        {
            n_lifetime = 6.0;

            if ( str_weapon == "staff_water_upgraded3_zm" )
                n_lifetime = 9.0;

            self thread staff_water_position_source( v_explode_point, n_lifetime, str_weapon );
        }
    }
}

staff_water_kill_zombie( player, str_weapon )
{
    self freeze_zombie();
    self do_damage_network_safe( player, self.health, str_weapon, "MOD_RIFLE_BULLET" );

    if ( isdefined( self.deathanim ) )
        self waittillmatch( "death_anim", "shatter" );

    if ( isdefined( self ) )
        self thread frozen_zombie_shatter();

    player maps\mp\zombies\_zm_score::player_add_points( "death", "", "" );
}

freeze_zombie()
{
    if ( is_true( self.is_mechz ) )
        return;

    if ( !self.isdog )
    {
        if ( self.has_legs )
        {
            if ( !self hasanimstatefromasd( "zm_death_freeze" ) )
                return;

            self.deathanim = "zm_death_freeze";
        }
        else
        {
            if ( !self hasanimstatefromasd( "zm_death_freeze_crawl" ) )
                return;

            self.deathanim = "zm_death_freeze_crawl";
        }
    }
    else
        self.a.nodeath = undefined;

    if ( is_true( self.is_traversing ) )
        self.deathanim = undefined;
}

_network_safe_play_fx( fx, v_origin )
{
    playfx( fx, v_origin, ( 0, 0, 1 ), ( 1, 0, 0 ) );
}

network_safe_play_fx( id, max, fx, v_origin )
{
    network_safe_init( id, max );
    network_choke_action( id, ::_network_safe_play_fx, fx, v_origin );
}

frozen_zombie_shatter()
{
    if ( is_true( self.is_mechz ) )
        return;

    if ( isdefined( self ) )
    {
        if ( is_mature() )
        {
            v_fx = self gettagorigin( "J_SpineLower" );
            level thread network_safe_play_fx( "frozen_shatter", 2, level._effect["staff_water_shatter"], v_fx );
            self thread frozen_zombie_gib( "normal" );
        }
        else
            self startragdoll();
    }
}

frozen_zombie_gib( gib_type )
{
    gibarray = [];
    gibarray[gibarray.size] = level._zombie_gib_piece_index_all;
    self gib( gib_type, gibarray );
    self ghost();
    wait 0.4;

    if ( isdefined( self ) )
        self self_delete();
}

staff_water_position_source( v_detonate, n_lifetime_sec, str_weapon )
{
    self endon( "disconnect" );

    if ( isdefined( v_detonate ) )
    {
        level notify( "blizzard_shot" );
        e_fx = spawn( "script_model", v_detonate + vectorscale( ( 0, 0, 1 ), 33.0 ) );
        e_fx setmodel( "tag_origin" );
        e_fx setclientfield( "staff_blizzard_fx", 1 );
        e_fx thread puzzle_debug_position( "X", ( 0, 64, 255 ) );
        wait 1;
        flag_set( "blizzard_active" );
        e_fx thread ice_staff_blizzard_do_kills( self, str_weapon );
        e_fx thread whirlwind_rumble_nearby_players( "blizzard_active" );
        e_fx thread ice_staff_blizzard_timeout( n_lifetime_sec );
        e_fx thread ice_staff_blizzard_off();

        e_fx waittill( "blizzard_off" );

        flag_clear( "blizzard_active" );
        e_fx notify( "stop_debug_position" );
        wait 0.1;
        e_fx setclientfield( "staff_blizzard_fx", 0 );
        wait 0.1;
        e_fx delete();
    }
}

ice_staff_blizzard_do_kills( player, str_weapon )
{
    player endon( "disconnect" );
    self endon( "blizzard_off" );

    while ( true )
    {
        a_zombies = getaiarray( level.zombie_team );

        foreach ( zombie in a_zombies )
        {
            if ( !is_true( zombie.is_on_ice ) )
            {
                if ( distancesquared( self.origin, zombie.origin ) <= 30625 )
                {
                    if ( is_true( zombie.is_mechz ) )
                    {
                        zombie thread ice_affect_mechz( player, 1 );
                        continue;
                    }

                    if ( isalive( zombie ) )
                        zombie thread ice_affect_zombie( str_weapon, player, 1 );
                }
            }
        }

        wait 0.1;
    }
}

ice_staff_blizzard_timeout( n_time )
{
    self endon( "death" );
    self endon( "blizzard_off" );
    wait( n_time );
    self notify( "blizzard_off" );
}

ice_staff_blizzard_off()
{
    self endon( "death" );
    self endon( "blizzard_off" );

    level waittill( "blizzard_shot" );

    self notify( "blizzard_off" );
}

get_ice_blast_range( n_charge )
{
    switch ( n_charge )
    {
        case 1:
        case 0:
            n_range = 250000;
            break;
        case 2:
            n_range = 640000;
            break;
        case 3:
            n_range = 1000000;
            break;
    }

    return n_range;
}

staff_water_zombie_range( v_source, n_range )
{
    a_enemies = [];
    a_zombies = getaiarray( level.zombie_team );
    a_zombies = get_array_of_closest( v_source, a_zombies );

    if ( isdefined( a_zombies ) )
    {
        for ( i = 0; i < a_zombies.size; i++ )
        {
            if ( !isdefined( a_zombies[i] ) )
                continue;

            v_zombie_pos = a_zombies[i] gettagorigin( "j_head" );

            if ( distancesquared( v_source, v_zombie_pos ) > n_range )
                continue;

            if ( !bullet_trace_throttled( v_source, v_zombie_pos, undefined ) )
                continue;

            if ( isdefined( a_zombies[i] ) && isalive( a_zombies[i] ) )
                a_enemies[a_enemies.size] = a_zombies[i];
        }
    }

    return a_enemies;
}

is_staff_water_damage()
{
    return isdefined( self.damageweapon ) && ( self.damageweapon == "staff_water_zm" || self.damageweapon == "staff_water_upgraded_zm" || self.damageweapon == "staff_water_fake_dart_zm" ) && !is_true( self.set_beacon_damage );
}

ice_affect_mechz( e_player, is_upgraded )
{
    if ( is_true( self.is_on_ice ) )
        return;

    self.is_on_ice = 1;

    if ( is_upgraded )
        self do_damage_network_safe( e_player, 3300, "staff_water_upgraded_zm", "MOD_RIFLE_BULLET" );
    else
        self do_damage_network_safe( e_player, 2050, "staff_water_zm", "MOD_RIFLE_BULLET" );

    wait 1.0;
    self.is_on_ice = 0;
}

ice_affect_zombie( str_weapon = "staff_water_zm", e_player, always_kill = 0, n_mod = 1 )
{
    self endon( "death" );
    instakill_on = e_player maps\mp\zombies\_zm_powerups::is_insta_kill_active();

    if ( str_weapon == "staff_water_zm" )
        n_damage = 2050;
    else if ( str_weapon == "staff_water_upgraded_zm" || str_weapon == "staff_water_upgraded2_zm" || str_weapon == "staff_water_upgraded3_zm" )
        n_damage = 3300;
    else if ( str_weapon == "one_inch_punch_ice_zm" )
        n_damage = 11275;

    if ( is_true( self.is_on_ice ) )
        return;

    self.is_on_ice = 1;
    self setclientfield( "attach_bullet_model", 1 );
    n_speed = 0.3;
    self set_anim_rate( 0.3 );

    if ( instakill_on || always_kill )
        wait( randomfloatrange( 0.5, 0.7 ) );
    else
        wait( randomfloatrange( 1.8, 2.3 ) );

    if ( self.health < n_damage || instakill_on || always_kill )
    {
        self set_anim_rate( 1.0 );
        wait_network_frame();

        if ( str_weapon != "one_inch_punch_ice_zm" )
            staff_water_kill_zombie( e_player, str_weapon );
    }
    else
    {
        self do_damage_network_safe( e_player, n_damage, str_weapon, "MOD_RIFLE_BULLET" );
        self.deathanim = undefined;
        self setclientfield( "attach_bullet_model", 0 );
        wait 0.5;
        self set_anim_rate( 1.0 );
        self.is_on_ice = 0;
    }
}

set_anim_rate( n_speed )
{
    self setclientfield( "anim_rate", n_speed );
    n_rate = self getclientfield( "anim_rate" );
    self setentityanimrate( n_rate );

    if ( n_speed != 1.0 )
        self.preserve_asd_substates = 1;

    wait_network_frame();

    if ( !is_true( self.is_traversing ) )
    {
        self.needs_run_update = 1;
        self notify( "needs_run_update" );
    }

    wait_network_frame();

    if ( n_speed == 1.0 )
        self.preserve_asd_substates = 0;
}

staff_water_on_zombie_spawned()
{
    self setclientfield( "anim_rate", 1 );
    n_rate = self getclientfield( "anim_rate" );
    self setentityanimrate( n_rate );
}

staff_water_death_event()
{
    if ( is_staff_water_damage() && self.damagemod != "MOD_MELEE" )
    {
        self.no_gib = 1;
        self.nodeathragdoll = 1;
        self freeze_zombie();

        if ( isdefined( self.deathanim ) )
            self waittillmatch( "death_anim", "shatter" );

        self thread frozen_zombie_shatter();
    }
}

_icicle_locate_target( str_weapon )
{
    is_upgraded = str_weapon == "staff_water_upgraded_zm";
    fire_angles = self getplayerangles();
    fire_origin = self getplayercamerapos();
    a_targets = getaiarray( "axis" );
    a_targets = get_array_of_closest( self.origin, a_targets, undefined, undefined, 600 );

    foreach ( target in a_targets )
    {
        if ( is_true( target.is_on_ice ) )
            continue;

        if ( within_fov( fire_origin, fire_angles, target gettagorigin( "j_spine4" ), cos( 25 ) ) )
        {
            if ( isai( target ) )
            {
                a_tags = [];
                a_tags[0] = "j_hip_le";
                a_tags[1] = "j_hip_ri";
                a_tags[2] = "j_spine4";
                a_tags[3] = "j_elbow_le";
                a_tags[4] = "j_elbow_ri";
                a_tags[5] = "j_clavicle_le";
                a_tags[6] = "j_clavicle_ri";
                str_tag = a_tags[randomint( a_tags.size )];
                b_trace_pass = bullet_trace_throttled( fire_origin, target gettagorigin( str_tag ), target );

                if ( b_trace_pass && isdefined( target ) && isalive( target ) )
                {
                    if ( is_true( target.is_mechz ) )
                        target thread ice_affect_mechz( self, is_upgraded );
                    else
                        target thread ice_affect_zombie( str_weapon, self );

                    return;
                }
            }
        }
    }
}

_icicle_get_spread( n_spread )
{
    n_x = randomintrange( n_spread * -1, n_spread );
    n_y = randomintrange( n_spread * -1, n_spread );
    n_z = randomintrange( n_spread * -1, n_spread );
    return ( n_x, n_y, n_z );
}
