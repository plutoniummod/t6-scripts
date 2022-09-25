// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_perk_vulture;

enable_vulture_perk_for_level()
{
    maps\mp\zombies\_zm_perks::register_perk_basic_info( "specialty_nomotionsensor", "vulture", 3000, &"ZOMBIE_PERK_VULTURE", "zombie_perk_bottle_vulture" );
    maps\mp\zombies\_zm_perks::register_perk_precache_func( "specialty_nomotionsensor", ::vulture_precache );
    maps\mp\zombies\_zm_perks::register_perk_clientfields( "specialty_nomotionsensor", ::vulture_register_clientfield, ::vulture_set_clientfield );
    maps\mp\zombies\_zm_perks::register_perk_threads( "specialty_nomotionsensor", ::give_vulture_perk, ::take_vulture_perk );
    maps\mp\zombies\_zm_perks::register_perk_machine( "specialty_nomotionsensor", ::vulture_perk_machine_setup, ::vulture_perk_machine_think );
    maps\mp\zombies\_zm_perks::register_perk_host_migration_func( "specialty_nomotionsensor", ::vulture_host_migration_func );
}

vulture_precache()
{
    precacheitem( "zombie_perk_bottle_vulture" );
    precacheshader( "specialty_vulture_zombies" );
    precachestring( &"ZOMBIE_PERK_VULTURE" );
    precachemodel( "p6_zm_vending_vultureaid" );
    precachemodel( "p6_zm_vending_vultureaid_on" );
    precachemodel( "p6_zm_perk_vulture_ammo" );
    precachemodel( "p6_zm_perk_vulture_points" );
    level._effect["vulture_light"] = loadfx( "misc/fx_zombie_cola_jugg_on" );
    level._effect["vulture_perk_zombie_stink"] = loadfx( "maps/zombie/fx_zm_vulture_perk_stink" );
    level._effect["vulture_perk_zombie_stink_trail"] = loadfx( "maps/zombie/fx_zm_vulture_perk_stink_trail" );
    level._effect["vulture_perk_bonus_drop"] = loadfx( "misc/fx_zombie_powerup_vulture" );
    level._effect["vulture_drop_picked_up"] = loadfx( "misc/fx_zombie_powerup_grab" );
    level._effect["vulture_perk_wallbuy_static"] = loadfx( "maps/zombie/fx_zm_vulture_wallbuy_rifle" );
    level._effect["vulture_perk_wallbuy_dynamic"] = loadfx( "maps/zombie/fx_zm_vulture_glow_question" );
    level._effect["vulture_perk_machine_glow_doubletap"] = loadfx( "maps/zombie/fx_zm_vulture_glow_dbltap" );
    level._effect["vulture_perk_machine_glow_juggernog"] = loadfx( "maps/zombie/fx_zm_vulture_glow_jugg" );
    level._effect["vulture_perk_machine_glow_revive"] = loadfx( "maps/zombie/fx_zm_vulture_glow_revive" );
    level._effect["vulture_perk_machine_glow_speed"] = loadfx( "maps/zombie/fx_zm_vulture_glow_speed" );
    level._effect["vulture_perk_machine_glow_marathon"] = loadfx( "maps/zombie/fx_zm_vulture_glow_marathon" );
    level._effect["vulture_perk_machine_glow_mule_kick"] = loadfx( "maps/zombie/fx_zm_vulture_glow_mule" );
    level._effect["vulture_perk_machine_glow_pack_a_punch"] = loadfx( "maps/zombie/fx_zm_vulture_glow_pap" );
    level._effect["vulture_perk_machine_glow_vulture"] = loadfx( "maps/zombie/fx_zm_vulture_glow_vulture" );
    level._effect["vulture_perk_mystery_box_glow"] = loadfx( "maps/zombie/fx_zm_vulture_glow_mystery_box" );
    level._effect["vulture_perk_powerup_drop"] = loadfx( "maps/zombie/fx_zm_vulture_glow_powerup" );
    level._effect["vulture_perk_zombie_eye_glow"] = loadfx( "misc/fx_zombie_eye_vulture" );
    onplayerconnect_callback( ::vulture_player_connect_callback );
}

vulture_player_connect_callback()
{
    self thread end_game_turn_off_vulture_overlay();
}

end_game_turn_off_vulture_overlay()
{
    self endon( "disconnect" );

    level waittill( "end_game" );

    self thread take_vulture_perk();
}

init_vulture()
{
    setdvarint( "zombies_perk_vulture_pickup_time", 12 );
    setdvarint( "zombies_perk_vulture_pickup_time_stink", 16 );
    setdvarint( "zombies_perk_vulture_drop_chance", 65 );
    setdvarint( "zombies_perk_vulture_ammo_chance", 33 );
    setdvarint( "zombies_perk_vulture_points_chance", 33 );
    setdvarint( "zombies_perk_vulture_stink_chance", 33 );
    setdvarint( "zombies_perk_vulture_drops_max", 20 );
    setdvarint( "zombies_perk_vulture_network_drops_max", 5 );
    setdvarint( "zombies_perk_vulture_network_time_frame", 250 );
    setdvarint( "zombies_perk_vulture_spawn_stink_zombie_cooldown", 12 );
    setdvarint( "zombies_perk_vulture_max_stink_zombies", 4 );
    level.perk_vulture = spawnstruct();
    level.perk_vulture.zombie_stink_array = [];
    level.perk_vulture.drop_time_last = 0;
    level.perk_vulture.drop_slots_for_network = 0;
    level.perk_vulture.last_stink_zombie_spawned = 0;
    level.perk_vulture.use_exit_behavior = 0;
    level.perk_vulture.clientfields = spawnstruct();
    level.perk_vulture.clientfields.scriptmovers = [];
    level.perk_vulture.clientfields.scriptmovers["vulture_stink_fx"] = 0;
    level.perk_vulture.clientfields.scriptmovers["vulture_drop_fx"] = 1;
    level.perk_vulture.clientfields.scriptmovers["vulture_drop_pickup"] = 2;
    level.perk_vulture.clientfields.scriptmovers["vulture_powerup_drop"] = 3;
    level.perk_vulture.clientfields.actors = [];
    level.perk_vulture.clientfields.actors["vulture_stink_trail_fx"] = 0;
    level.perk_vulture.clientfields.actors["vulture_eye_glow"] = 1;
    level.perk_vulture.clientfields.toplayer = [];
    level.perk_vulture.clientfields.toplayer["vulture_perk_active"] = 0;
    registerclientfield( "toplayer", "vulture_perk_toplayer", 12000, 1, "int" );
    registerclientfield( "actor", "vulture_perk_actor", 12000, 2, "int" );
    registerclientfield( "scriptmover", "vulture_perk_scriptmover", 12000, 4, "int" );
    registerclientfield( "zbarrier", "vulture_perk_zbarrier", 12000, 1, "int" );
    registerclientfield( "toplayer", "sndVultureStink", 12000, 1, "int" );
    registerclientfield( "world", "vulture_perk_disable_solo_quick_revive_glow", 12000, 1, "int" );
    registerclientfield( "toplayer", "vulture_perk_disease_meter", 12000, 5, "float" );
    maps\mp\_visionset_mgr::vsmgr_register_info( "overlay", "vulture_stink_overlay", 12000, 120, 31, 1 );
    maps\mp\zombies\_zm_spawner::add_cusom_zombie_spawn_logic( ::vulture_zombie_spawn_func );
    register_zombie_death_event_callback( ::zombies_drop_stink_on_death );
    level thread vulture_perk_watch_mystery_box();
    level thread vulture_perk_watch_fire_sale();
    level thread vulture_perk_watch_powerup_drops();
    level thread vulture_handle_solo_quick_revive();
    assert( !isdefined( level.exit_level_func ), "vulture perk is attempting to use level.exit_level_func, but one already exists for this level!" );
    level.exit_level_func = ::vulture_zombies_find_exit_point;
    level.perk_vulture.invalid_bonus_ammo_weapons = array( "time_bomb_zm", "time_bomb_detonator_zm" );

    if ( !isdefined( level.perk_vulture.func_zombies_find_valid_exit_locations ) )
        level.perk_vulture.func_zombies_find_valid_exit_locations = ::get_valid_exit_points_for_zombie;

    setup_splitscreen_optimizations();
    initialize_bonus_entity_pool();
    initialize_stink_entity_pool();
/#
    level.vulture_devgui_spawn_stink = ::vulture_devgui_spawn_stink;
#/
}

add_additional_stink_locations_for_zone( str_zone, a_zones )
{
    if ( !isdefined( level.perk_vulture.zones_for_extra_stink_locations ) )
        level.perk_vulture.zones_for_extra_stink_locations = [];

    level.perk_vulture.zones_for_extra_stink_locations[str_zone] = a_zones;
}

vulture_register_clientfield()
{
    registerclientfield( "toplayer", "perk_vulture", 12000, 2, "int" );
}

vulture_set_clientfield( state )
{
    self setclientfieldtoplayer( "perk_vulture", state );
}

give_vulture_perk()
{
    vulture_debug_text( "player " + self getentitynumber() + " has vulture perk!" );

    if ( !isdefined( self.perk_vulture ) )
        self.perk_vulture = spawnstruct();

    self.perk_vulture.active = 1;
    self vulture_vision_toggle( 1 );
    self vulture_clientfield_toplayer_set( "vulture_perk_active" );
    self thread _vulture_perk_think();
}

take_vulture_perk()
{
    if ( isdefined( self.perk_vulture ) && ( isdefined( self.perk_vulture.active ) && self.perk_vulture.active ) )
    {
        vulture_debug_text( "player " + self getentitynumber() + " has lost vulture perk!" );
        self.perk_vulture.active = 0;

        if ( !self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
            self.ignoreme = 0;

        self vulture_vision_toggle( 0 );
        self vulture_clientfield_toplayer_clear( "vulture_perk_active" );
        self set_vulture_overlay( 0 );
        self.vulture_stink_value = 0;
        self setclientfieldtoplayer( "vulture_perk_disease_meter", 0 );
        self notify( "vulture_perk_lost" );
    }
}

vulture_host_migration_func()
{
    a_vulture_perk_machines = getentarray( "vending_vulture", "targetname" );

    foreach ( perk_machine in a_vulture_perk_machines )
    {
        if ( isdefined( perk_machine.model ) && perk_machine.model == "p6_zm_vending_vultureaid_on" )
        {
            perk_machine maps\mp\zombies\_zm_perks::perk_fx( undefined, 1 );
            perk_machine thread maps\mp\zombies\_zm_perks::perk_fx( "vulture_light" );
        }
    }

    foreach ( ent in level.perk_vulture.stink_ent_pool )
    {
        if ( isdefined( ent ) )
        {
            arrayremovevalue( level.perk_vulture.zombie_stink_array, ent, 0 );
            ent clear_stink_ent();
        }
    }

    foreach ( ent in level.perk_vulture.bonus_drop_ent_pool )
    {
        if ( isdefined( ent ) )
            ent clear_bonus_ent();
    }
}

vulture_perk_add_invalid_bonus_ammo_weapon( str_weapon )
{
    assert( isdefined( level.perk_vulture ), "vulture_perk_add_invalid_bonus_ammo_weapon() was called before vulture perk was initialized. Make sure this is called after the vulture perk initialization func!" );
    level.perk_vulture.invalid_bonus_ammo_weapons[level.perk_vulture.invalid_bonus_ammo_weapons.size] = str_weapon;
}

vulture_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
    use_trigger.script_sound = "mus_perks_vulture_jingle";
    use_trigger.script_string = "vulture_perk";
    use_trigger.script_label = "mus_perks_vulture_sting";
    use_trigger.target = "vending_vulture";
    perk_machine.script_string = "vulture_perk";
    perk_machine.targetname = "vending_vulture";
    bump_trigger.script_string = "vulture_perk";
}

vulture_perk_machine_think()
{
    init_vulture();

    while ( true )
    {
        machine = getentarray( "vending_vulture", "targetname" );
        machine_triggers = getentarray( "vending_vulture", "target" );
        array_thread( machine_triggers, maps\mp\zombies\_zm_perks::set_power_on, 0 );

        for ( i = 0; i < machine.size; i++ )
            machine[i] setmodel( "p6_zm_vending_vultureaid" );

        level waittill( "specialty_nomotionsensor" + "_on" );

        level notify( "specialty_nomotionsensor" + "_power_on" );

        for ( i = 0; i < machine.size; i++ )
        {
            machine[i] setmodel( "p6_zm_vending_vultureaid_on" );
            machine[i] vibrate( vectorscale( ( 0, -1, 0 ), 100.0 ), 0.3, 0.4, 3 );
            machine[i] playsound( "zmb_perks_power_on" );
            machine[i] thread maps\mp\zombies\_zm_perks::perk_fx( "vulture_light" );
            machine[i] thread maps\mp\zombies\_zm_perks::play_loop_on_machine();
        }

        array_thread( machine_triggers, maps\mp\zombies\_zm_perks::set_power_on, 1 );

        level waittill( "specialty_nomotionsensor" + "_off" );

        array_thread( machine, maps\mp\zombies\_zm_perks::turn_perk_off );
    }
}

do_vulture_death( player )
{
    if ( isdefined( self ) )
        self thread _do_vulture_death( player );
}

_do_vulture_death( player )
{
    if ( should_do_vulture_drop( self.origin ) )
    {
        str_bonus = get_vulture_drop_type();
        str_identifier = "_" + self getentitynumber() + "_" + gettime();
        v_drop_origin = groundtrace( self.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), self.origin - vectorscale( ( 0, 0, -1 ), 100.0 ), 0, self )["position"];
        player thread show_debug_info( self.origin, str_identifier, str_bonus );
        self thread vulture_drop_funcs( self.origin, player, str_identifier, str_bonus );
    }
}

vulture_drop_funcs( v_origin, player, str_identifier, str_bonus )
{
    vulture_drop_count_increment();

    switch ( str_bonus )
    {
        case "ammo":
            e_temp = player _vulture_drop_model( str_identifier, "p6_zm_perk_vulture_ammo", v_origin, vectorscale( ( 0, 0, 1 ), 15.0 ) );
            self thread check_vulture_drop_pickup( e_temp, player, str_identifier, str_bonus );
            break;
        case "points":
            e_temp = player _vulture_drop_model( str_identifier, "p6_zm_perk_vulture_points", v_origin, vectorscale( ( 0, 0, 1 ), 15.0 ) );
            self thread check_vulture_drop_pickup( e_temp, player, str_identifier, str_bonus );
            break;
        case "stink":
            self _drop_zombie_stink( player, str_identifier, str_bonus );
            break;
    }
}

_drop_zombie_stink( player, str_identifier, str_bonus )
{
    self clear_zombie_stink_fx();
    e_temp = player zombie_drops_stink( self, str_identifier );
    e_temp = player _vulture_spawn_fx( str_identifier, self.origin, str_bonus, e_temp );
    clean_up_stink( e_temp );
}

zombie_drops_stink( ai_zombie, str_identifier )
{
    e_temp = ai_zombie.stink_ent;

    if ( isdefined( e_temp ) )
    {
        e_temp thread delay_showing_vulture_ent( self, ai_zombie.origin );
        level.perk_vulture.zombie_stink_array[level.perk_vulture.zombie_stink_array.size] = e_temp;
        self delay_notify( str_identifier, getdvarint( _hash_DDE8D546 ) );
    }

    return e_temp;
}

delay_showing_vulture_ent( player, v_moveto_pos, str_model, func )
{
    self.drop_time = gettime();
    wait_network_frame();
    wait_network_frame();
    self.origin = v_moveto_pos;
    wait_network_frame();

    if ( isdefined( str_model ) )
        self setmodel( str_model );

    self show();

    if ( isplayer( player ) )
    {
        self setinvisibletoall();
        self setvisibletoplayer( player );
    }

    if ( isdefined( func ) )
        self [[ func ]]();
}

clean_up_stink( e_temp )
{
    e_temp vulture_clientfield_scriptmover_clear( "vulture_stink_fx" );
    arrayremovevalue( level.perk_vulture.zombie_stink_array, e_temp, 0 );
    wait 4;
    e_temp clear_stink_ent();
}

_delete_vulture_ent( n_delay )
{
    if ( !isdefined( n_delay ) )
        n_delay = 0;

    if ( n_delay > 0 )
    {
        self ghost();
        wait( n_delay );
    }

    self clear_bonus_ent();
}

_vulture_drop_model( str_identifier, str_model, v_model_origin, v_offset )
{
    if ( !isdefined( v_offset ) )
        v_offset = ( 0, 0, 0 );

    if ( !isdefined( self.perk_vulture_models ) )
        self.perk_vulture_models = [];

    e_temp = get_unused_bonus_ent();

    if ( !isdefined( e_temp ) )
    {
        self notify( str_identifier );
        return;
    }

    e_temp thread delay_showing_vulture_ent( self, v_model_origin + v_offset, str_model, ::set_vulture_drop_fx );
    self.perk_vulture_models[self.perk_vulture_models.size] = e_temp;
    e_temp setinvisibletoall();
    e_temp setvisibletoplayer( self );
    e_temp thread _vulture_drop_model_thread( str_identifier, self );
    return e_temp;
}

set_vulture_drop_fx()
{
    self vulture_clientfield_scriptmover_set( "vulture_drop_fx" );
}

_vulture_drop_model_thread( str_identifier, player )
{
    self thread _vulture_model_blink_timeout( player );
    player waittill_any( str_identifier, "death_or_disconnect", "vulture_perk_lost" );
    self vulture_clientfield_scriptmover_clear( "vulture_drop_fx" );
    n_delete_delay = 0.1;

    if ( isdefined( self.picked_up ) && self.picked_up )
    {
        self _play_vulture_drop_pickup_fx();
        n_delete_delay = 1;
    }

    if ( isdefined( player.perk_vulture_models ) )
    {
        arrayremovevalue( player.perk_vulture_models, self, 0 );
        self.perk_vulture_models = remove_undefined_from_array( player.perk_vulture_models );
    }

    self _delete_vulture_ent( n_delete_delay );
}

_vulture_model_blink_timeout( player )
{
    self endon( "death" );
    player endon( "death" );
    player endon( "disconnect" );
    self endon( "stop_vulture_behavior" );
    n_time_total = getdvarint( _hash_34FA67DE );
    n_frames = n_time_total * 20;
    n_section = int( n_frames / 6 );
    n_flash_slow = n_section * 3;
    n_flash_medium = n_section * 4;
    n_flash_fast = n_section * 5;
    b_show = 1;
    i = 0;

    while ( i < n_frames )
    {
        if ( i < n_flash_slow )
            n_multiplier = n_flash_slow;
        else if ( i < n_flash_medium )
            n_multiplier = 10;
        else if ( i < n_flash_fast )
            n_multiplier = 5;
        else
            n_multiplier = 2;

        if ( b_show )
        {
            self show();
            self setinvisibletoall();
            self setvisibletoplayer( player );
        }
        else
            self ghost();

        b_show = !b_show;
        i += n_multiplier;
        wait( 0.05 * n_multiplier );
    }
}

_vulture_spawn_fx( str_identifier, v_fx_origin, str_bonus, e_temp )
{
    b_delete = 0;

    if ( !isdefined( e_temp ) )
    {
        e_temp = get_unused_bonus_ent();

        if ( !isdefined( e_temp ) )
        {
            self notify( str_identifier );
            return;
        }

        b_delete = 1;
    }

    e_temp thread delay_showing_vulture_ent( self, v_fx_origin, "tag_origin", ::clientfield_set_vulture_stink_enabled );

    if ( isplayer( self ) )
        self waittill_any( str_identifier, "disconnect", "vulture_perk_lost" );
    else
        self waittill( str_identifier );

    if ( b_delete )
        e_temp _delete_vulture_ent();

    return e_temp;
}

clientfield_set_vulture_stink_enabled()
{
    self vulture_clientfield_scriptmover_set( "vulture_stink_fx" );
}

should_do_vulture_drop( v_death_origin )
{
    b_is_inside_playable_area = check_point_in_enabled_zone( v_death_origin, 1 );
    b_ents_are_available = get_unused_bonus_ent_count() > 0;
    b_network_slots_available = level.perk_vulture.drop_slots_for_network < getdvarint( _hash_1786213A );
    n_roll = randomint( 100 );
    b_passed_roll = n_roll > 100 - getdvarint( _hash_70E3B3FA );
    b_is_stink_zombie = isdefined( self.is_stink_zombie ) && self.is_stink_zombie;
    b_should_drop = b_is_stink_zombie || b_is_inside_playable_area && b_ents_are_available && b_network_slots_available && b_passed_roll;
    return b_should_drop;
}

get_vulture_drop_type()
{
    n_chance_ammo = getdvarint( _hash_F75E07AF );
    n_chance_points = getdvarint( _hash_D7BCDBE2 );
    n_chance_stink = getdvarint( _hash_4918C38E );
    n_total_weight = n_chance_ammo + n_chance_points;
    n_cutoff_ammo = n_chance_ammo;
    n_cutoff_points = n_chance_ammo + n_chance_points;
    n_roll = randomint( n_total_weight );

    if ( n_roll < n_cutoff_ammo )
        str_bonus = "ammo";
    else
        str_bonus = "points";

    if ( isdefined( self.is_stink_zombie ) && self.is_stink_zombie )
        str_bonus = "stink";

    return str_bonus;
}

show_debug_info( v_drop_point, str_identifier, str_bonus )
{
/#
    n_radius = 32;

    if ( str_bonus == "stink" )
        n_radius = 70;

    if ( getdvarint( _hash_38E68F2B ) )
    {
        self endon( str_identifier );
        vulture_debug_text( "zombie dropped " + str_bonus );

        for ( i = 0; i < get_vulture_drop_duration( str_bonus ) * 20; i++ )
        {
            circle( v_drop_point, n_radius, get_debug_circle_color( str_bonus ), 0, 1, 1 );
            wait 0.05;
        }
    }
#/
}

get_vulture_drop_duration( str_bonus )
{
    str_dvar = "zombies_perk_vulture_pickup_time";

    if ( str_bonus == "stink" )
        str_dvar = "zombies_perk_vulture_pickup_time_stink";

    n_duration = getdvarint( str_dvar );
    return n_duration;
}

get_debug_circle_color( str_bonus )
{
    switch ( str_bonus )
    {
        case "ammo":
            v_color = ( 0, 0, 1 );
            break;
        case "points":
            v_color = ( 1, 1, 0 );
            break;
        case "stink":
            v_color = ( 0, 1, 0 );
            break;
        default:
            v_color = ( 1, 1, 1 );
            break;
    }

    return v_color;
}

check_vulture_drop_pickup( e_temp, player, str_identifier, str_bonus )
{
    if ( !isdefined( e_temp ) )
        return;

    player endon( "death" );
    player endon( "disconnect" );
    e_temp endon( "death" );
    e_temp endon( "stop_vulture_behavior" );
    wait_network_frame();
    n_times_to_check = int( get_vulture_drop_duration( str_bonus ) / 0.15 );

    for ( i = 0; i < n_times_to_check; i++ )
    {
        b_player_inside_radius = distancesquared( e_temp.origin, player.origin ) < 1024;

        if ( b_player_inside_radius )
        {
            e_temp.picked_up = 1;
            break;
        }

        wait 0.15;
    }

    player notify( str_identifier );

    if ( b_player_inside_radius )
        player give_vulture_bonus( str_bonus );
}

_handle_zombie_stink( b_player_inside_radius )
{
    if ( !isdefined( self.perk_vulture.is_in_zombie_stink ) )
        self.perk_vulture.is_in_zombie_stink = 0;

    b_in_stink_last_check = self.perk_vulture.is_in_zombie_stink;
    self.perk_vulture.is_in_zombie_stink = b_player_inside_radius;

    if ( self.perk_vulture.is_in_zombie_stink )
    {
        n_current_time = gettime();

        if ( !b_in_stink_last_check )
        {
            self.perk_vulture.stink_time_entered = n_current_time;
            self toggle_stink_overlay( 1 );
            self thread stink_react_vo();
        }

        b_should_ignore_player = isdefined( self.perk_vulture.stink_time_entered ) && ( n_current_time - self.perk_vulture.stink_time_entered ) * 0.001 >= 0.0;

        if ( b_should_ignore_player )
            self.ignoreme = 1;

        if ( get_targetable_player_count() == 0 || !self are_any_players_in_adjacent_zone() )
        {
            if ( b_should_ignore_player && !level.perk_vulture.use_exit_behavior )
            {
                level.perk_vulture.use_exit_behavior = 1;
                level.default_find_exit_position_override = ::vulture_perk_should_zombies_resume_find_flesh;
                self thread vulture_zombies_find_exit_point();
            }
        }
    }
    else if ( b_in_stink_last_check )
    {
        self.perk_vulture.stink_time_exit = gettime();
        self thread _zombies_reacquire_player_after_leaving_stink();
    }
}

stink_react_vo()
{
    self endon( "death" );
    self endon( "disconnect" );
    wait 1.0;
    chance = get_response_chance( "vulture_stink" );

    if ( chance > randomintrange( 1, 100 ) )
        self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "vulture_stink" );
}

get_targetable_player_count()
{
    n_targetable_player_count = 0;

    foreach ( player in get_players() )
    {
        if ( !isdefined( player.ignoreme ) || !player.ignoreme )
            n_targetable_player_count++;
    }

    return n_targetable_player_count;
}

are_any_players_in_adjacent_zone()
{
    b_players_in_adjacent_zone = 0;
    str_zone = self maps\mp\zombies\_zm_zonemgr::get_player_zone();

    foreach ( player in get_players() )
    {
        if ( player == self )
            continue;

        str_zone_compare = player maps\mp\zombies\_zm_zonemgr::get_player_zone();

        if ( isinarray( level.zones[str_zone].adjacent_zones, str_zone_compare ) && ( isdefined( level.zones[str_zone].adjacent_zones[str_zone_compare].is_connected ) && level.zones[str_zone].adjacent_zones[str_zone_compare].is_connected ) )
        {
            b_players_in_adjacent_zone = 1;
            break;
        }
    }

    return b_players_in_adjacent_zone;
}

toggle_stink_overlay( b_show_overlay )
{
    if ( !isdefined( self.vulture_stink_value ) )
        self.vulture_stink_value = 0;

    if ( b_show_overlay )
        self thread _ramp_up_stink_overlay();
    else
        self thread _ramp_down_stink_overlay();
}

_ramp_up_stink_overlay( b_instant_change )
{
    if ( !isdefined( b_instant_change ) )
        b_instant_change = 0;

    self notify( "vulture_perk_stink_ramp_up_done" );
    self endon( "vulture_perk_stink_ramp_up_done" );
    self endon( "death_or_disconnect" );
    self endon( "vulture_perk_lost" );
    self setclientfieldtoplayer( "sndVultureStink", 1 );

    if ( !isdefined( level.perk_vulture.stink_change_increment ) )
        level.perk_vulture.stink_change_increment = pow( 2, 5 ) * 0.25 / 8;

    while ( self.perk_vulture.is_in_zombie_stink )
    {
        self.vulture_stink_value += level.perk_vulture.stink_change_increment;

        if ( self.vulture_stink_value > pow( 2, 5 ) - 1 )
            self.vulture_stink_value = pow( 2, 5 ) - 1;

        fraction = self _get_disease_meter_fraction();
        self setclientfieldtoplayer( "vulture_perk_disease_meter", fraction );
        self set_vulture_overlay( fraction );
        vulture_debug_text( "disease counter = " + self.vulture_stink_value );
        wait 0.25;
    }
}

set_vulture_overlay( fraction )
{
    state = level.vsmgr["overlay"].info["vulture_stink_overlay"].state;

    if ( fraction > 0 )
        state maps\mp\_visionset_mgr::vsmgr_set_state_active( self, 1 - fraction );
    else
        state maps\mp\_visionset_mgr::vsmgr_set_state_inactive( self );
}

_get_disease_meter_fraction()
{
    return self.vulture_stink_value / ( pow( 2, 5 ) - 1 );
}

_ramp_down_stink_overlay( b_instant_change )
{
    if ( !isdefined( b_instant_change ) )
        b_instant_change = 0;

    self notify( "vulture_perk_stink_ramp_down_done" );
    self endon( "vulture_perk_stink_ramp_down_done" );
    self endon( "death_or_disconnect" );
    self endon( "vulture_perk_lost" );
    self setclientfieldtoplayer( "sndVultureStink", 0 );

    if ( !isdefined( level.perk_vulture.stink_change_decrement ) )
        level.perk_vulture.stink_change_decrement = pow( 2, 5 ) * 0.25 / 4;

    while ( !self.perk_vulture.is_in_zombie_stink && self.vulture_stink_value > 0 )
    {
        self.vulture_stink_value -= level.perk_vulture.stink_change_decrement;

        if ( self.vulture_stink_value < 0 )
            self.vulture_stink_value = 0;

        fraction = self _get_disease_meter_fraction();
        self set_vulture_overlay( fraction );
        self setclientfieldtoplayer( "vulture_perk_disease_meter", fraction );
        vulture_debug_text( "disease counter = " + self.vulture_stink_value );
        wait 0.25;
    }
}

_zombies_reacquire_player_after_leaving_stink()
{
    self endon( "death_or_disconnect" );
    self notify( "vulture_perk_stop_zombie_reacquire_player" );
    self endon( "vulture_perk_stop_zombie_reacquire_player" );
    self toggle_stink_overlay( 0 );

    while ( self.vulture_stink_value > 0 )
    {
        vulture_debug_text( "zombies ignoring player..." );
        wait 0.25;
    }

    self.ignoreme = 0;
    level.perk_vulture.use_exit_behavior = 0;
}

vulture_perk_should_zombies_resume_find_flesh()
{
    b_should_find_flesh = !is_player_in_zombie_stink();
    return b_should_find_flesh;
}

is_player_in_zombie_stink()
{
    a_players = get_players();
    b_player_in_zombie_stink = 0;

    for ( i = 0; !b_player_in_zombie_stink && i < a_players.size; i++ )
    {
        if ( isdefined( a_players[i].is_in_zombie_stink ) && a_players[i].is_in_zombie_stink )
            b_player_in_zombie_stink = 1;
    }

    return b_player_in_zombie_stink;
}

give_vulture_bonus( str_bonus )
{
    switch ( str_bonus )
    {
        case "ammo":
            self give_bonus_ammo();
            break;
        case "points":
            self give_bonus_points();
            break;
        case "stink":
            self give_bonus_stink();
            break;
        default:
            assert( "invalid bonus string '" + str_bonus + "' used in give_vulture_bonus()!" );
            break;
    }
}

give_bonus_ammo()
{
    str_weapon_current = self getcurrentweapon();

    if ( str_weapon_current != "none" )
    {
        n_heat_value = self isweaponoverheating( 1, str_weapon_current );
        n_fuel_total = weaponfuellife( str_weapon_current );
        b_is_fuel_weapon = n_fuel_total > 0;
        b_is_overheating_weapon = n_heat_value > 0;

        if ( b_is_overheating_weapon )
        {
            n_ammo_refunded = randomintrange( 1, 3 );
            b_weapon_is_overheating = self isweaponoverheating();
            self setweaponoverheating( b_weapon_is_overheating, n_heat_value - n_ammo_refunded );
        }
        else if ( b_is_fuel_weapon )
        {
            n_fuel_used = self getweaponammofuel( str_weapon_current );
            n_fuel_refunded = randomintrange( int( n_fuel_total * 0.01 ), int( n_fuel_total * 0.03 ) );
            self setweaponammofuel( str_weapon_current, n_fuel_used - n_fuel_refunded );
            n_ammo_refunded = n_fuel_refunded / n_fuel_total * 100;
        }
        else if ( is_valid_ammo_bonus_weapon( str_weapon_current ) )
        {
            n_ammo_count_current = self getweaponammostock( str_weapon_current );
            n_ammo_count_max = weaponmaxammo( str_weapon_current );
            n_ammo_refunded = clamp( int( n_ammo_count_max * randomfloatrange( 0.0, 0.025 ) ), 1, n_ammo_count_max );
            b_is_custom_weapon = self handle_custom_weapon_refunds( str_weapon_current );

            if ( !b_is_custom_weapon )
                self setweaponammostock( str_weapon_current, n_ammo_count_current + n_ammo_refunded );
        }

        self playsoundtoplayer( "zmb_vulture_drop_pickup_ammo", self );
        chance = get_response_chance( "vulture_ammo_drop" );

        if ( chance > randomintrange( 1, 100 ) )
            self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "vulture_ammo_drop" );
/#
        if ( getdvarint( _hash_38E68F2B ) )
        {
            if ( !isdefined( n_ammo_refunded ) )
                n_ammo_refunded = 0;

            vulture_debug_text( str_weapon_current + " bullets given: " + n_ammo_refunded );
        }
#/
    }
}

is_valid_ammo_bonus_weapon( str_weapon )
{
    return !( is_placeable_mine( str_weapon ) || maps\mp\zombies\_zm_equipment::is_placeable_equipment( str_weapon ) || isinarray( level.perk_vulture.invalid_bonus_ammo_weapons, str_weapon ) );
}

_play_vulture_drop_pickup_fx()
{
    self vulture_clientfield_scriptmover_set( "vulture_drop_pickup" );
}

give_bonus_points( v_fx_origin )
{
    n_multiplier = randomintrange( 1, 5 );
    self maps\mp\zombies\_zm_score::player_add_points( "vulture", 5 * n_multiplier );
    self playsoundtoplayer( "zmb_vulture_drop_pickup_money", self );
    chance = get_response_chance( "vulture_money_drop" );

    if ( chance > randomintrange( 1, 100 ) )
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "vulture_money_drop" );
}

give_bonus_stink( v_drop_origin )
{
    self _handle_zombie_stink( 0 );
}

_vulture_perk_think()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "vulture_perk_lost" );

    while ( true )
    {
        b_player_in_zombie_stink = 0;

        if ( !isdefined( level.perk_vulture.zombie_stink_array ) )
            level.perk_vulture.zombie_stink_array = [];

        if ( level.perk_vulture.zombie_stink_array.size > 0 )
        {
            a_close_points = arraysort( level.perk_vulture.zombie_stink_array, self.origin, 1, 300 );

            if ( a_close_points.size > 0 )
                b_player_in_zombie_stink = self _is_player_in_zombie_stink( a_close_points );
        }

        self _handle_zombie_stink( b_player_in_zombie_stink );
        wait( randomfloatrange( 0.25, 0.5 ) );
    }
}

_is_player_in_zombie_stink( a_points )
{
    b_is_in_stink = 0;

    for ( i = 0; i < a_points.size; i++ )
    {
        if ( distancesquared( a_points[i].origin, self.origin ) < 4900 )
            b_is_in_stink = 1;
    }

    return b_is_in_stink;
}

vulture_drop_count_increment()
{
    level.perk_vulture.drop_slots_for_network++;
    level thread _decrement_network_slots_after_time();
}

_decrement_network_slots_after_time()
{
    wait( getdvarint( _hash_DB295746 ) * 0.001 );
    level.perk_vulture.drop_slots_for_network--;
}

vulture_zombie_spawn_func()
{
    self endon( "death" );
    self thread add_zombie_eye_glow();

    self waittill( "completed_emerging_into_playable_area" );

    if ( self should_zombie_have_stink() )
    {
        self stink_zombie_array_add();
/#
        if ( isdefined( self.stink_ent ) )
        {
            while ( true )
            {
                if ( getdvarint( _hash_38E68F2B ) )
                    debugstar( self.origin, 2, ( 0, 1, 0 ) );

                wait 0.1;
            }
        }
#/
    }
}

add_zombie_eye_glow()
{
    self endon( "death" );

    self waittill( "risen" );

    self vulture_clientfield_actor_set( "vulture_eye_glow" );
}

zombies_drop_stink_on_death()
{
    self vulture_clientfield_actor_clear( "vulture_eye_glow" );

    if ( isdefined( self.attacker ) && isplayer( self.attacker ) && self.attacker hasperk( "specialty_nomotionsensor" ) )
        self thread do_vulture_death( self.attacker );
    else if ( isdefined( self.is_stink_zombie ) && self.is_stink_zombie && isdefined( self.stink_ent ) )
    {
        str_identifier = "_" + self getentitynumber() + "_" + gettime();
        self thread _drop_zombie_stink( level, str_identifier, "stink" );
    }
}

clear_zombie_stink_fx()
{
    self vulture_clientfield_actor_clear( "vulture_stink_trail_fx" );
}

stink_zombie_array_add()
{
    if ( get_unused_stink_ent_count() > 0 )
    {
        self.stink_ent = get_unused_stink_ent();

        if ( isdefined( self.stink_ent ) )
        {
            self.stink_ent.owner = self;
            wait_network_frame();
            wait_network_frame();
            self.stink_ent thread _show_debug_location();
            self vulture_clientfield_actor_set( "vulture_stink_trail_fx" );
            level.perk_vulture.last_stink_zombie_spawned = gettime();
            self.is_stink_zombie = 1;
        }
    }
    else
        self.is_stink_zombie = 0;
}

should_zombie_have_stink()
{
    b_is_zombie = isdefined( self.animname ) && self.animname == "zombie";
    b_cooldown_up = gettime() - level.perk_vulture.last_stink_zombie_spawned > getdvarint( _hash_47A03A7E ) * 1000;
    b_roll_passed = 100 - randomint( 100 ) > 50;
    b_stink_ent_available = get_unused_stink_ent_count() > 0;
    b_should_have_stink = b_is_zombie && b_roll_passed && b_cooldown_up && b_stink_ent_available;
    return b_should_have_stink;
}

vulture_debug_text( str_text )
{
/#
    if ( getdvarint( _hash_38E68F2B ) )
        iprintln( str_text );
#/
}

vulture_clientfield_scriptmover_set( str_field_name )
{
    assert( isdefined( level.perk_vulture.clientfields.scriptmovers[str_field_name] ), str_field_name + " is not a valid client field for vulture perk!" );
    n_value = self getclientfield( "vulture_perk_scriptmover" );
    n_value |= 1 << level.perk_vulture.clientfields.scriptmovers[str_field_name];
    self setclientfield( "vulture_perk_scriptmover", n_value );
}

vulture_clientfield_scriptmover_clear( str_field_name )
{
    assert( isdefined( level.perk_vulture.clientfields.scriptmovers[str_field_name] ), str_field_name + " is not a valid client field for vulture perk!" );
    n_value = self getclientfield( "vulture_perk_scriptmover" );
    n_value &= ~( 1 << level.perk_vulture.clientfields.scriptmovers[str_field_name] );
    self setclientfield( "vulture_perk_scriptmover", n_value );
}

vulture_clientfield_actor_set( str_field_name )
{
    assert( isdefined( level.perk_vulture.clientfields.actors[str_field_name] ), str_field_name + " is not a valid field for vulture_clientfield_actor_set!" );
    n_value = getclientfield( "vulture_perk_actor" );
    n_value |= 1 << level.perk_vulture.clientfields.actors[str_field_name];
    self setclientfield( "vulture_perk_actor", n_value );
}

vulture_clientfield_actor_clear( str_field_name )
{
    assert( isdefined( level.perk_vulture.clientfields.actors[str_field_name] ), str_field_name + " is not a valid field for vulture_clientfield_actor_clear!" );
    n_value = getclientfield( "vulture_perk_actor" );
    n_value &= ~( 1 << level.perk_vulture.clientfields.actors[str_field_name] );
    self setclientfield( "vulture_perk_actor", n_value );
}

vulture_clientfield_toplayer_set( str_field_name )
{
    assert( isdefined( level.perk_vulture.clientfields.toplayer[str_field_name] ), str_field_name + " is not a valid client field for vulture perk!" );
    n_value = self getclientfieldtoplayer( "vulture_perk_toplayer" );
    n_value |= 1 << level.perk_vulture.clientfields.toplayer[str_field_name];
    self setclientfieldtoplayer( "vulture_perk_toplayer", n_value );
}

vulture_clientfield_toplayer_clear( str_field_name )
{
    assert( isdefined( level.perk_vulture.clientfields.toplayer[str_field_name] ), str_field_name + " is not a valid client field for vulture perk!" );
    n_value = self getclientfieldtoplayer( "vulture_perk_toplayer" );
    n_value &= ~( 1 << level.perk_vulture.clientfields.toplayer[str_field_name] );
    self setclientfieldtoplayer( "vulture_perk_toplayer", n_value );
}

vulture_perk_watch_mystery_box()
{
    wait_network_frame();

    while ( isdefined( level.chests ) && level.chests.size > 0 && isdefined( level.chest_index ) )
    {
        level.chests[level.chest_index].zbarrier vulture_perk_shows_mystery_box( 1 );
        flag_wait( "moving_chest_now" );
        level.chests[level.chest_index].zbarrier vulture_perk_shows_mystery_box( 0 );
        flag_waitopen( "moving_chest_now" );
    }
}

vulture_perk_shows_mystery_box( b_show )
{
    self setclientfield( "vulture_perk_zbarrier", b_show );
}

vulture_perk_watch_fire_sale()
{
    wait_network_frame();

    while ( isdefined( level.chests ) && level.chests.size > 0 )
    {
        level waittill( "powerup fire sale" );

        for ( i = 0; i < level.chests.size; i++ )
        {
            if ( i != level.chest_index )
                level.chests[i] thread vulture_fire_sale_box_fx_enable();
        }

        level waittill( "fire_sale_off" );

        for ( i = 0; i < level.chests.size; i++ )
        {
            if ( i != level.chest_index )
                level.chests[i] thread vulture_fire_sale_box_fx_disable();
        }
    }
}

vulture_fire_sale_box_fx_enable()
{
    if ( self.zbarrier.state == "arriving" )
        self.zbarrier waittill( "arrived" );

    self.zbarrier setclientfield( "vulture_perk_zbarrier", 1 );
}

vulture_fire_sale_box_fx_disable()
{
    self.zbarrier setclientfield( "vulture_perk_zbarrier", 0 );
}

vulture_perk_watch_powerup_drops()
{
    while ( true )
    {
        level waittill( "powerup_dropped", m_powerup );

        m_powerup thread _powerup_drop_think();
    }
}

_powerup_drop_think()
{
    e_temp = spawn( "script_model", self.origin );
    e_temp setmodel( "tag_origin" );
    e_temp vulture_clientfield_scriptmover_set( "vulture_powerup_drop" );
    self waittill_any( "powerup_timedout", "powerup_grabbed", "death" );
    e_temp vulture_clientfield_scriptmover_clear( "vulture_powerup_drop" );
    wait_network_frame();
    wait_network_frame();
    wait_network_frame();
    e_temp delete();
}

vulture_zombies_find_exit_point()
{
/#
    if ( getdvarint( _hash_38E68F2B ) > 0 )
    {
        foreach ( struct in level.enemy_dog_locations )
            debugstar( struct.origin, 200, ( 1, 1, 1 ) );
    }
#/
    a_zombies = get_round_enemy_array();

    for ( i = 0; i < a_zombies.size; i++ )
        a_zombies[i] thread zombie_goes_to_exit_location();
}

zombie_goes_to_exit_location()
{
    self endon( "death" );

    if ( !( isdefined( self.completed_emerging_into_playable_area ) && self.completed_emerging_into_playable_area ) )
    {
        self waittill( "completed_emerging_into_playable_area" );

        wait 1;
    }

    s_goal = _get_zombie_exit_point();
    self notify( "stop_find_flesh" );
    self notify( "zombie_acquire_enemy" );

    if ( isdefined( s_goal ) )
        self setgoalpos( s_goal.origin );

    while ( true )
    {
        b_passed_override = 1;

        if ( isdefined( level.default_find_exit_position_override ) )
            b_passed_override = [[ level.default_find_exit_position_override ]]();

        if ( !flag( "wait_and_revive" ) && b_passed_override )
            break;

        wait 0.1;
    }

    self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
}

_get_zombie_exit_point()
{
    player = get_players()[0];
    n_dot_best = 9999999;
    a_exit_points = self [[ level.perk_vulture.func_zombies_find_valid_exit_locations ]]();
    assert( a_exit_points.size > 0, "_get_zombie_exit_point() couldn't find any zombie exit points for player at " + player.origin + "! Add more dog_locations!" );

    for ( i = 0; i < a_exit_points.size; i++ )
    {
        v_to_player = vectornormalize( player.origin - self.origin );
        v_to_goal = a_exit_points[i].origin - self.origin;
        n_dot = vectordot( v_to_player, v_to_goal );

        if ( n_dot < n_dot_best && distancesquared( player.origin, a_exit_points[i].origin ) > 360000 )
        {
            nd_best = a_exit_points[i];
            n_dot_best = n_dot;
        }
/#
        if ( getdvarint( _hash_38E68F2B ) )
            debugstar( a_exit_points[i].origin, 200, ( 1, 0, 0 ) );
#/
    }

    return nd_best;
}

get_valid_exit_points_for_zombie()
{
    a_exit_points = level.enemy_dog_locations;

    if ( isdefined( level.perk_vulture.zones_for_extra_stink_locations ) && level.perk_vulture.zones_for_extra_stink_locations.size > 0 )
    {
        a_zones_with_extra_stink_locations = getarraykeys( level.perk_vulture.zones_for_extra_stink_locations );

        foreach ( zone in level.active_zone_names )
        {
            if ( isinarray( a_zones_with_extra_stink_locations, zone ) )
            {
                a_zones_temp = level.perk_vulture.zones_for_extra_stink_locations[zone];

                for ( i = 0; i < a_zones_temp.size; i++ )
                    a_exit_points = arraycombine( a_exit_points, get_zone_dog_locations( a_zones_temp[i] ), 0, 0 );
            }
        }
    }

    return a_exit_points;
}

get_zone_dog_locations( str_zone )
{
    a_dog_locations = [];

    if ( isdefined( level.zones[str_zone] ) && isdefined( level.zones[str_zone].dog_locations ) )
        a_dog_locations = level.zones[str_zone].dog_locations;

    return a_dog_locations;
}

vulture_vision_toggle( b_enable )
{

}

vulture_handle_solo_quick_revive()
{
    flag_wait( "initial_blackscreen_passed" );

    if ( flag( "solo_game" ) )
    {
        flag_wait( "solo_revive" );
        setclientfield( "vulture_perk_disable_solo_quick_revive_glow", 1 );
    }
}

vulture_devgui_spawn_stink()
{
/#
    player = gethostplayer();
    forward_dir = vectornormalize( anglestoforward( player.angles ) );
    target_pos = player.origin + forward_dir * 100 + vectorscale( ( 0, 0, 1 ), 50.0 );
    target_pos_down = target_pos + vectorscale( ( 0, 0, -1 ), 150.0 );
    str_bonus = "stink";
    str_identifier = "_" + "test_" + gettime();
    drop_pos = groundtrace( target_pos, target_pos_down, 0, player )["position"];
    setdvarint( "zombies_debug_vulture_perk", 1 );
    player thread show_debug_info( drop_pos, str_identifier, str_bonus );
    e_temp = player maps\mp\zombies\_zm_perk_vulture::zombie_drops_stink( drop_pos, str_identifier );
    e_temp = player maps\mp\zombies\_zm_perk_vulture::_vulture_spawn_fx( str_identifier, drop_pos, str_bonus, e_temp );
    maps\mp\zombies\_zm_perk_vulture::clean_up_stink( e_temp );
#/
}

setup_splitscreen_optimizations()
{
    if ( level.splitscreen && getdvarint( "splitscreen_playerCount" ) > 2 )
    {
        setdvarint( "zombies_perk_vulture_drops_max", int( getdvarint( _hash_612F9831 ) * 0.5 ) );
        setdvarint( "zombies_perk_vulture_spawn_stink_zombie_cooldown", int( getdvarint( _hash_47A03A7E ) * 2 ) );
        setdvarint( "zombies_perk_vulture_max_stink_zombies", int( getdvarint( _hash_16BCAE6A ) * 0.5 ) );
    }
}

initialize_bonus_entity_pool()
{
    n_ent_pool_size = getdvarint( _hash_612F9831 );
    level.perk_vulture.bonus_drop_ent_pool = [];

    for ( i = 0; i < n_ent_pool_size; i++ )
    {
        e_temp = spawn( "script_model", ( 0, 0, 0 ) );
        e_temp setmodel( "tag_origin" );
        e_temp.targetname = "vulture_perk_bonus_pool_ent";
        e_temp.in_use = 0;
        level.perk_vulture.bonus_drop_ent_pool[level.perk_vulture.bonus_drop_ent_pool.size] = e_temp;
    }
}

get_unused_bonus_ent()
{
    e_found = undefined;

    for ( i = 0; i < level.perk_vulture.bonus_drop_ent_pool.size && !isdefined( e_found ); i++ )
    {
        if ( !level.perk_vulture.bonus_drop_ent_pool[i].in_use )
        {
            e_found = level.perk_vulture.bonus_drop_ent_pool[i];
            e_found.in_use = 1;
        }
    }

    return e_found;
}

get_unused_bonus_ent_count()
{
    n_found = 0;

    for ( i = 0; i < level.perk_vulture.bonus_drop_ent_pool.size; i++ )
    {
        if ( !level.perk_vulture.bonus_drop_ent_pool[i].in_use )
            n_found++;
    }

    return n_found;
}

clear_bonus_ent()
{
    self notify( "stop_vulture_behavior" );
    self vulture_clientfield_scriptmover_clear( "vulture_drop_fx" );
    self.in_use = 0;
    self setmodel( "tag_origin" );
    self ghost();
}

initialize_stink_entity_pool()
{
    n_ent_pool_size = getdvarint( _hash_16BCAE6A );
    level.perk_vulture.stink_ent_pool = [];

    for ( i = 0; i < n_ent_pool_size; i++ )
    {
        e_temp = spawn( "script_model", ( 0, 0, 0 ) );
        e_temp setmodel( "tag_origin" );
        e_temp.targetname = "vulture_perk_bonus_pool_ent";
        e_temp.in_use = 0;
        level.perk_vulture.stink_ent_pool[level.perk_vulture.stink_ent_pool.size] = e_temp;
    }
}

get_unused_stink_ent_count()
{
    n_found = 0;

    for ( i = 0; i < level.perk_vulture.stink_ent_pool.size; i++ )
    {
        if ( !level.perk_vulture.stink_ent_pool[i].in_use )
        {
            n_found++;
            continue;
        }

        if ( !isdefined( level.perk_vulture.stink_ent_pool[i].owner ) && !isdefined( level.perk_vulture.stink_ent_pool[i].drop_time ) )
        {
            level.perk_vulture.stink_ent_pool[i] clear_stink_ent();
            n_found++;
        }
    }

    return n_found;
}

get_unused_stink_ent()
{
    e_found = undefined;

    for ( i = 0; i < level.perk_vulture.stink_ent_pool.size && !isdefined( e_found ); i++ )
    {
        if ( !level.perk_vulture.stink_ent_pool[i].in_use )
        {
            e_found = level.perk_vulture.stink_ent_pool[i];
            e_found.in_use = 1;
            vulture_debug_text( "vulture stink >> ent " + e_found getentitynumber() + " in use" );
        }
    }

    return e_found;
}

clear_stink_ent()
{
    vulture_debug_text( "vulture stink >> ent " + self getentitynumber() + " CLEAR" );
    self vulture_clientfield_scriptmover_clear( "vulture_stink_fx" );
    self notify( "stop_vulture_behavior" );
    self.in_use = 0;
    self.drop_time = undefined;
    self.owner = undefined;
    self setmodel( "tag_origin" );
    self ghost();
}

_show_debug_location()
{
/#
    while ( self.in_use )
    {
        if ( getdvarint( _hash_38E68F2B ) > 0 )
        {
            debugstar( self.origin, 1, ( 0, 0, 1 ) );
            print3d( self.origin, self getentitynumber(), ( 0, 0, 1 ), 1, 1, 1 );
        }

        wait 0.05;
    }
#/
}

handle_custom_weapon_refunds( str_weapon )
{
    b_is_custom_weapon = 0;

    if ( issubstr( str_weapon, "knife_ballistic" ) )
    {
        self _refund_oldest_ballistic_knife( str_weapon );
        b_is_custom_weapon = 1;
    }

    return b_is_custom_weapon;
}

_refund_oldest_ballistic_knife( str_weapon )
{
    self endon( "death_or_disconnect" );
    self endon( "vulture_perk_lost" );

    if ( isdefined( self.weaponobjectwatcherarray ) && self.weaponobjectwatcherarray.size > 0 )
    {
        b_found_weapon_object = 0;

        for ( i = 0; i < self.weaponobjectwatcherarray.size; i++ )
        {
            if ( isdefined( self.weaponobjectwatcherarray[i].weapon ) && self.weaponobjectwatcherarray[i].weapon == str_weapon )
            {
                s_found = self.weaponobjectwatcherarray[i];
                break;
            }
        }

        if ( isdefined( s_found ) )
        {
            if ( isdefined( s_found.objectarray ) && s_found.objectarray.size > 0 )
            {
                e_oldest = undefined;

                for ( i = 0; i < s_found.objectarray.size; i++ )
                {
                    if ( isdefined( s_found.objectarray[i] ) )
                    {
                        if ( !isdefined( s_found.objectarray[i].retrievabletrigger ) || !isdefined( s_found.objectarray[i].retrievabletrigger.owner ) || s_found.objectarray[i].retrievabletrigger.owner != self || !isdefined( s_found.objectarray[i].birthtime ) )
                            continue;

                        if ( !isdefined( e_oldest ) )
                            e_oldest = s_found.objectarray[i];

                        if ( s_found.objectarray[i].birthtime < e_oldest.birthtime )
                            e_oldest = s_found.objectarray[i];
                    }
                }

                if ( isdefined( e_oldest ) )
                {
                    e_oldest.retrievabletrigger.force_pickup = 1;
                    e_oldest.retrievabletrigger notify( "trigger", self );
                }
            }
        }
    }
}
