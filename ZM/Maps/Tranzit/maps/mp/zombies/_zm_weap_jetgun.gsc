// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\animscripts\zm_death;
#include maps\mp\animscripts\zm_run;

init()
{
    if ( !maps\mp\zombies\_zm_weapons::is_weapon_included( "jetgun_zm" ) )
        return;

    maps\mp\zombies\_zm_equipment::register_equipment( "jetgun_zm", &"ZOMBIE_EQUIP_JETGUN_PICKUP_HINT_STRING", &"ZOMBIE_EQUIP_JETGUN_HOWTO", "jetgun_zm_icon", "jetgun", ::jetgun_activation_watcher_thread, undefined, ::dropjetgun, ::pickupjetgun );
    maps\mp\gametypes_zm\_weaponobjects::createretrievablehint( "jetgun", &"ZOMBIE_EQUIP_JETGUN_PICKUP_HINT_STRING" );
    level._effect["jetgun_smoke_cloud"] = loadfx( "weapon/thunder_gun/fx_thundergun_smoke_cloud" );
    level._effect["jetgun_overheat"] = loadfx( "weapon/jet_gun/fx_jetgun_overheat" );
    level._effect["jetgun_vortex"] = loadfx( "weapon/jet_gun/fx_jetgun_on" );
    level._effect["jetgun_meat_grinder"] = loadfx( "weapon/jet_gun/fx_jetgun_kill" );
    set_zombie_var( "jetgun_cylinder_radius", 1024 );
    set_zombie_var( "jetgun_grind_range", 128 );
    set_zombie_var( "jetgun_gib_range", 256 );
    set_zombie_var( "jetgun_gib_damage", 50 );
    set_zombie_var( "jetgun_knockdown_range", 256 );
    set_zombie_var( "jetgun_drag_range", 2048 );
    set_zombie_var( "jetgun_knockdown_damage", 15 );
    set_zombie_var( "powerup_move_dist", 50 );
    set_zombie_var( "powerup_drag_range", 500 );
    level.jetgun_pulled_in_range = int( level.zombie_vars["jetgun_drag_range"] / 8 ) * level.zombie_vars["jetgun_drag_range"] / 8;
    level.jetgun_pulling_in_range = int( level.zombie_vars["jetgun_drag_range"] / 4 ) * level.zombie_vars["jetgun_drag_range"] / 4;
    level.jetgun_inner_range = int( level.zombie_vars["jetgun_drag_range"] / 2 ) * level.zombie_vars["jetgun_drag_range"] / 2;
    level.jetgun_outer_edge = int( level.zombie_vars["jetgun_drag_range"] * level.zombie_vars["jetgun_drag_range"] );
    level.jetgun_gib_refs = [];
    level.jetgun_gib_refs[level.jetgun_gib_refs.size] = "guts";
    level.jetgun_gib_refs[level.jetgun_gib_refs.size] = "right_arm";
    level.jetgun_gib_refs[level.jetgun_gib_refs.size] = "left_arm";
    level.jetgun_gib_refs[level.jetgun_gib_refs.size] = "right_leg";
    level.jetgun_gib_refs[level.jetgun_gib_refs.size] = "left_leg";
    level.jetgun_gib_refs[level.jetgun_gib_refs.size] = "no_legs";
/#
    level thread jetgun_devgui_dvar_think();
    level.zm_devgui_jetgun_never_overheat = ::never_overheat;
#/
    onplayerconnect_callback( ::jetgun_on_player_connect );
}

dropjetgun()
{
    item = self maps\mp\zombies\_zm_equipment::placed_equipment_think( "t6_wpn_zmb_jet_gun_world", "jetgun_zm", self.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), self.angles );

    if ( isdefined( item ) )
    {
        item.overheating = self.jetgun_overheating;
        item.heatval = self.jetgun_heatval;
        item.original_owner = self;
        item.owner = undefined;
        item.name = "jetgun_zm";
        item.requires_pickup = 1;
    }

    self.jetgun_overheating = undefined;
    self.jetgun_heatval = undefined;
    self takeweapon( "jetgun_zm" );
    return item;
}

pickupjetgun( item )
{
    item.owner = self;

    if ( isdefined( item.overheating ) && isdefined( item.heatval ) )
    {
        self.jetgun_overheating = item.overheating;
        self.jetgun_heatval = item.heatval;
    }

    item.overheating = undefined;
    item.heatval = undefined;
    self setcurrentweaponspinlerp( 0 );
}

jetgun_activation_watcher_thread()
{
    self endon( "zombified" );
    self endon( "disconnect" );
    self endon( "jetgun_zm_taken" );

    while ( true )
        self waittill_either( "jetgun_zm_activate", "jetgun_zm_deactivate" );
}

jetgun_devgui_dvar_think()
{
/#
    if ( !maps\mp\zombies\_zm_weapons::is_weapon_included( "jetgun_zm" ) )
        return;

    setdvar( "scr_jetgun_cylinder_radius", level.zombie_vars["jetgun_cylinder_radius"] );
    setdvar( "scr_jetgun_grind_range", level.zombie_vars["jetgun_grind_range"] );
    setdvar( "scr_jetgun_drag_range", level.zombie_vars["jetgun_drag_range"] );
    setdvar( "scr_jetgun_gib_range", level.zombie_vars["jetgun_gib_range"] );
    setdvar( "scr_jetgun_gib_damage", level.zombie_vars["jetgun_gib_damage"] );
    setdvar( "scr_jetgun_knockdown_range", level.zombie_vars["jetgun_knockdown_range"] );
    setdvar( "scr_jetgun_knockdown_damage", level.zombie_vars["jetgun_knockdown_damage"] );

    for (;;)
    {
        level.zombie_vars["jetgun_cylinder_radius"] = getdvarint( _hash_6ECD5E99 );
        level.zombie_vars["jetgun_grind_range"] = getdvarint( _hash_8562CAD8 );
        level.zombie_vars["jetgun_drag_range"] = getdvarint( _hash_ECC8AEC2 );
        level.zombie_vars["jetgun_gib_range"] = getdvarint( _hash_D5D25B16 );
        level.zombie_vars["jetgun_gib_damage"] = getdvarint( _hash_6F74DFC8 );
        level.zombie_vars["jetgun_knockdown_range"] = getdvarint( _hash_B7484BD2 );
        level.zombie_vars["jetgun_knockdown_damage"] = getdvarint( _hash_7FA8E804 );
        wait 0.5;
    }
#/
}

jetgun_on_player_connect()
{
    self thread wait_for_jetgun_fired();
    self thread watch_weapon_changes();
    self thread handle_overheated_jetgun();
}

get_jetgun_engine_direction()
{
    return self getcurrentweaponspinlerp();
}

set_jetgun_engine_direction( nv )
{
    self setcurrentweaponspinlerp( nv );
}

never_overheat()
{
/#
    self notify( "never_overheat" );
    self endon( "never_overheat" );
    self endon( "death_or_disconnect" );

    while ( true )
    {
        if ( self getcurrentweapon() == "jetgun_zm" )
            self setweaponoverheating( 0, 0 );

        wait 0.05;
    }
#/
}

watch_overheat()
{
    self endon( "death_or_disconnect" );
    self endon( "weapon_change" );

    if ( self getcurrentweapon() == "jetgun_zm" && isdefined( self.jetgun_overheating ) && isdefined( self.jetgun_heatval ) )
        self setweaponoverheating( self.jetgun_overheating, self.jetgun_heatval );

    while ( true )
    {
        if ( self getcurrentweapon() == "jetgun_zm" )
        {
            overheating = self isweaponoverheating( 0 );
            heat = self isweaponoverheating( 1 );
            self.jetgun_overheating = overheating;
            self.jetgun_heatval = heat;

            if ( overheating )
                self notify( "jetgun_overheated" );

            if ( heat > 75 )
                self thread play_overheat_fx();
        }

        wait 0.05;
    }
}

play_overheat_fx()
{
    if ( !( isdefined( self.overheat_fx_playing ) && self.overheat_fx_playing ) )
    {
        self.overheat_fx_playing = 1;
        playfxontag( level._effect["jetgun_overheat"], self, "tag_flash" );
        wait 5;

        if ( isdefined( self ) )
            self.overheat_fx_playing = 0;
    }
}

handle_overheated_jetgun()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "jetgun_overheated" );

        if ( self getcurrentweapon() == "jetgun_zm" )
        {
            if ( isdefined( level.explode_overheated_jetgun ) && level.explode_overheated_jetgun )
            {
                self thread maps\mp\zombies\_zm_equipment::equipment_release( "jetgun_zm" );
                weapon_org = self gettagorigin( "tag_weapon" );
                pcount = get_players().size;
                pickup_time = 360 / pcount;
                maps\mp\zombies\_zm_buildables::player_explode_buildable( "jetgun_zm", weapon_org, 250, 1, pickup_time );
                self.jetgun_overheating = undefined;
                self.jetgun_heatval = undefined;
                self playsound( "wpn_jetgun_explo" );
            }
            else if ( isdefined( level.unbuild_overheated_jetgun ) && level.unbuild_overheated_jetgun )
            {
                self thread maps\mp\zombies\_zm_equipment::equipment_release( "jetgun_zm" );
                maps\mp\zombies\_zm_buildables::unbuild_buildable( "jetgun_zm", 1 );
                self.jetgun_overheating = undefined;
                self.jetgun_heatval = undefined;
            }
            else if ( isdefined( level.take_overheated_jetgun ) && level.take_overheated_jetgun )
            {
                self thread maps\mp\zombies\_zm_equipment::equipment_release( "jetgun_zm" );
                self.jetgun_overheating = undefined;
                self.jetgun_heatval = undefined;
            }
        }
    }
}

watch_weapon_changes()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "weapon_change", weapon );

        if ( weapon == "jetgun_zm" )
        {
/#
            if ( getdvarint( _hash_BCDDAAFF ) > 0 )
                self thread zombie_drag_radius();
#/
            self thread watch_overheat();
        }
    }
}

wait_for_jetgun_fired()
{
    self endon( "disconnect" );

    self waittill( "spawned_player" );

    for (;;)
    {
        self waittill( "weapon_fired" );

        currentweapon = self getcurrentweapon();

        if ( currentweapon == "jetgun_zm" || currentweapon == "jetgun_upgraded_zm" )
            self jetgun_firing();
    }
}

jetgun_network_choke()
{
    level.jetgun_network_choke_count++;

    if ( !( level.jetgun_network_choke_count % 10 ) )
    {
        wait_network_frame();
        wait_network_frame();
        wait_network_frame();
    }
}

is_jetgun_firing()
{
    return abs( self get_jetgun_engine_direction() ) > 0.2;
}

jetgun_firing()
{
    if ( !isdefined( self.jetsound_ent ) )
    {
        self.jetsound_ent = spawn( "script_origin", self.origin );
        self.jetsound_ent linkto( self, "tag_origin" );
    }

    jetgun_fired = 0;

    if ( self is_jetgun_firing() && jetgun_fired == 0 )
    {
        self.jetsound_ent playloopsound( "wpn_jetgun_effect_plr_loop", 0.8 );
        self.jetsound_ent playsound( "wpn_jetgun_effect_plr_start" );
        self notify( "jgun_snd" );
    }

    while ( self is_jetgun_firing() )
    {
        jetgun_fired = 1;
        self thread jetgun_fired();
        view_pos = self gettagorigin( "tag_flash" );
        view_angles = self gettagangles( "tag_flash" );

        if ( self get_jetgun_engine_direction() < 0 )
            playfx( level._effect["jetgun_smoke_cloud"], view_pos - self getplayerviewheight(), anglestoforward( view_angles ), anglestoup( view_angles ) );
        else
            playfx( level._effect["jetgun_smoke_cloud"], view_pos - self getplayerviewheight(), anglestoforward( view_angles ) * -1, anglestoup( view_angles ) );

        wait 0.25;
    }

    if ( jetgun_fired == 1 )
    {
        self.jetsound_ent stoploopsound( 0.5 );
        self.jetsound_ent playsound( "wpn_jetgun_effect_plr_end" );
        self.jetsound_ent thread sound_ent_cleanup();
        jetgun_fired = 0;
    }
}

sound_ent_cleanup()
{
    self endon( "jgun_snd" );
    wait 4;

    if ( isdefined( self.jetsound_ent ) )
        self delete();
}

jetgun_fired()
{
    if ( !self is_jetgun_firing() )
        return;

    origin = self getweaponmuzzlepoint();
    physicsjetthrust( origin, self getweaponforwarddir() * -1, level.zombie_vars["jetgun_grind_range"], self get_jetgun_engine_direction(), 0.85 );

    if ( !isdefined( level.jetgun_knockdown_enemies ) )
    {
        level.jetgun_knockdown_enemies = [];
        level.jetgun_knockdown_gib = [];
        level.jetgun_drag_enemies = [];
        level.jetgun_fling_enemies = [];
        level.jetgun_grind_enemies = [];
    }

    powerups = maps\mp\zombies\_zm_powerups::get_powerups();

    if ( isdefined( powerups ) && powerups.size )
        self thread try_pull_powerups( powerups );

    self jetgun_get_enemies_in_range( self get_jetgun_engine_direction() );
    level.jetgun_network_choke_count = 0;

    foreach ( index, zombie in level.jetgun_fling_enemies )
    {
        jetgun_network_choke();

        if ( isdefined( zombie ) )
            zombie thread jetgun_fling_zombie( self, index );
    }

    foreach ( zombie in level.jetgun_drag_enemies )
    {
        jetgun_network_choke();

        if ( isdefined( zombie ) )
        {
            zombie.jetgun_owner = self;
            zombie thread jetgun_drag_zombie( origin, -1 * self get_jetgun_engine_direction() );
        }
    }

    level.jetgun_knockdown_enemies = [];
    level.jetgun_knockdown_gib = [];
    level.jetgun_drag_enemies = [];
    level.jetgun_fling_enemies = [];
    level.jetgun_grind_enemies = [];
}

try_pull_powerups( powerups )
{
    powerup_move_dist = level.zombie_vars["powerup_move_dist"] * -1 * self get_jetgun_engine_direction();
    powerup_range_squared = level.zombie_vars["powerup_drag_range"] * level.zombie_vars["powerup_drag_range"];
    view_pos = self getweaponmuzzlepoint();
    forward_view_angles = self getweaponforwarddir();

    foreach ( powerup in powerups )
    {
        if ( distancesquared( view_pos, powerup.origin ) > powerup_range_squared )
            continue;

        normal = vectornormalize( powerup.origin - view_pos );
        dot = vectordot( forward_view_angles, normal );

        if ( abs( dot ) < 0.7 )
            continue;

        powerup notify( "move_powerup", view_pos, powerup_move_dist );
    }
}

jetgun_get_enemies_in_range( invert )
{
    view_pos = self getweaponmuzzlepoint();
    zombies = get_array_of_closest( view_pos, get_round_enemy_array(), undefined, 3, level.zombie_vars["jetgun_drag_range"] );

    if ( !isdefined( zombies ) )
    {

    }

    knockdown_range_squared = level.zombie_vars["jetgun_knockdown_range"] * level.zombie_vars["jetgun_knockdown_range"];
    drag_range_squared = level.zombie_vars["jetgun_drag_range"] * level.zombie_vars["jetgun_drag_range"];
    gib_range_squared = level.zombie_vars["jetgun_gib_range"] * level.zombie_vars["jetgun_gib_range"];
    grind_range_squared = level.zombie_vars["jetgun_grind_range"] * level.zombie_vars["jetgun_grind_range"];
    cylinder_radius_squared = level.zombie_vars["jetgun_cylinder_radius"] * level.zombie_vars["jetgun_cylinder_radius"];
    forward_view_angles = self getweaponforwarddir();
    end_pos = view_pos + vectorscale( forward_view_angles, level.zombie_vars["jetgun_knockdown_range"] );
/#
    if ( 2 == getdvarint( _hash_BCDDAAFF ) )
    {
        near_circle_pos = view_pos + vectorscale( forward_view_angles, 2 );
        circle( near_circle_pos, level.zombie_vars["jetgun_cylinder_radius"], ( 1, 0, 0 ), 0, 0, 100 );
        line( near_circle_pos, end_pos, ( 0, 0, 1 ), 1, 0, 100 );
        circle( end_pos, level.zombie_vars["jetgun_cylinder_radius"], ( 1, 0, 0 ), 0, 0, 100 );
    }
#/
    for ( i = 0; i < zombies.size; i++ )
        self jetgun_check_enemies_in_range( zombies[i], view_pos, drag_range_squared, gib_range_squared, grind_range_squared, cylinder_radius_squared, forward_view_angles, end_pos, invert );
}

jetgun_check_enemies_in_range( zombie, view_pos, drag_range_squared, gib_range_squared, grind_range_squared, cylinder_radius_squared, forward_view_angles, end_pos, invert )
{
    if ( !isdefined( zombie ) )
        return;

    if ( !isdefined( zombie ) )
        return;

    if ( zombie enemy_killed_by_jetgun() )
        return;

    if ( !isdefined( zombie.ai_state ) || zombie.ai_state != "find_flesh" && zombie.ai_state != "zombieMoveOnBus" )
        return;

    if ( isdefined( zombie.in_the_ground ) && zombie.in_the_ground )
        return;

    if ( isdefined( zombie.is_avogadro ) && zombie.is_avogadro )
        return;

    if ( isdefined( zombie.isdog ) && zombie.isdog )
        return;

    if ( isdefined( zombie.isscreecher ) && zombie.isscreecher )
        return;

    if ( isdefined( self.animname ) && self.animname == "quad_zombie" )
        return;

    test_origin = zombie getcentroid();
    test_range_squared = distancesquared( view_pos, test_origin );

    if ( test_range_squared > drag_range_squared )
    {
        zombie jetgun_debug_print( "range", ( 1, 0, 0 ) );
        return;
    }

    normal = vectornormalize( test_origin - view_pos );
    dot = vectordot( forward_view_angles, normal );

    if ( abs( dot ) < 0.7 )
    {
        zombie jetgun_debug_print( "dot", ( 1, 0, 0 ) );
        return;
    }

    radial_origin = pointonsegmentnearesttopoint( view_pos, end_pos, test_origin );

    if ( distancesquared( test_origin, radial_origin ) > cylinder_radius_squared )
    {
        zombie jetgun_debug_print( "cylinder", ( 1, 0, 0 ) );
        return;
    }

    if ( 0 == zombie damageconetrace( view_pos, self ) )
    {
        zombie jetgun_debug_print( "cone", ( 1, 0, 0 ) );
        return;
    }

    jetgun_blow_suck = invert;

    if ( 0 > dot )
        jetgun_blow_suck *= -1;

    if ( test_range_squared < grind_range_squared )
    {
        level.jetgun_fling_enemies[level.jetgun_fling_enemies.size] = zombie;
        level.jetgun_grind_enemies[level.jetgun_grind_enemies.size] = dot < 0;
    }
    else if ( test_range_squared < drag_range_squared && dot > 0 )
        level.jetgun_drag_enemies[level.jetgun_drag_enemies.size] = zombie;
}

jetgun_debug_print( msg, color )
{
/#
    if ( !getdvarint( _hash_BCDDAAFF ) )
        return;

    if ( !isdefined( color ) )
        color = ( 1, 1, 1 );

    print3d( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), msg, color, 1, 1, 40 );
#/
}

jetgun_debug_print_on_ent( msg, color )
{
/#
    if ( !getdvarint( _hash_BCDDAAFF ) )
        return;

    if ( !isdefined( color ) )
        color = ( 1, 1, 1 );

    self notify( "new_jetgun_debug_print_on_ent" );
    self endon( "death" );
    self endon( "jetgun_end_drag_state" );
    self endon( "new_jetgun_debug_print_on_ent" );

    while ( true )
    {
        print3d( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), msg, color, 1, 1 );
        wait 0.05;
    }
#/
}

try_gibbing()
{
    if ( isdefined( self ) && isdefined( self.a ) && !( isdefined( self.isscreecher ) && self.isscreecher ) )
    {
        self.a.gib_ref = random( level.jetgun_gib_refs );
        self thread maps\mp\animscripts\zm_death::do_gib();
    }
}

jetgun_handle_death_notetracks( note )
{
    if ( note == "jetgunned" )
        self thread jetgun_grind_death_ending();
}

jetgun_grind_death_ending()
{
    if ( !isdefined( self ) )
        return;

    self hide();
    wait 0.1;
    self self_delete();
}

jetgun_grind_zombie( player )
{
    player endon( "death" );
    player endon( "disconnect" );
    self endon( "death" );

    if ( !isdefined( self.jetgun_grind ) )
    {
        self.jetgun_grind = 1;
        self notify( "grinding" );
        player set_jetgun_engine_direction( 0.5 * player get_jetgun_engine_direction() );

        if ( is_mature() )
        {
            if ( isdefined( level._effect["zombie_guts_explosion"] ) )
                playfx( level._effect["zombie_guts_explosion"], self gettagorigin( "J_SpineLower" ) );
        }

        self.nodeathragdoll = 1;
        self.handle_death_notetracks = ::jetgun_handle_death_notetracks;
        self dodamage( self.health + 666, player.origin, player );
    }
}

jetgun_fling_zombie( player, index )
{
    if ( !isdefined( self ) )
        return;

    if ( isdefined( self.jetgun_fling_func ) )
    {
        self [[ self.jetgun_fling_func ]]( player );
        return;
    }

    was_alive = isalive( self );

    if ( was_alive )
    {
        self.jetgun_fling = 1;
        self notify( "flinging" );
        deathanim = undefined;

        if ( is_mature() )
            player weaponplayejectbrass();

        if ( isdefined( self.has_legs ) && self.has_legs )
        {
            if ( isdefined( self.jetgun_drag_state ) && self.jetgun_drag_state == "jetgun_sprint" )
                deathanim = "zm_jetgun_sprint_death";
            else
                deathanim = "zm_jetgun_death";
        }
        else
            deathanim = "zm_jetgun_death_crawl";

        self.deathanim = deathanim;
        player playsound( "evt_jetgun_zmb_suck" );
    }

    self thread jetgun_grind_zombie( player );
}

jetgun_drag_zombie( vdir, speed )
{
    if ( isdefined( self.jetgun_drag_func ) )
    {
        self [[ self.jetgun_drag_func ]]( vdir, speed );
        return;
    }

    self zombie_do_drag( vdir, speed );
}

jetgun_knockdown_zombie( player, gib )
{
    self endon( "death" );
    return;

    if ( isdefined( self.jetgun_knockdown_func ) )
        self [[ self.jetgun_knockdown_func ]]( player, gib );
    else
        self dodamage( level.zombie_vars["jetgun_knockdown_damage"], player.origin, player );

    if ( gib )
    {
        self.a.gib_ref = random( level.jetgun_gib_refs );
        self thread maps\mp\animscripts\zm_death::do_gib();
    }

    self.jetgun_handle_pain_notetracks = ::handle_jetgun_pain_notetracks;
    self dodamage( level.zombie_vars["jetgun_knockdown_damage"], player.origin, player );
}

handle_jetgun_pain_notetracks( note )
{
    if ( note == "zombie_knockdown_ground_impact" )
        playfx( level._effect["jetgun_knockdown_ground"], self.origin, anglestoforward( self.angles ), anglestoup( self.angles ) );
}

is_jetgun_damage()
{
    return isdefined( self.damageweapon ) && ( self.damageweapon == "jetgun_zm" || self.damageweapon == "jetgun_upgraded_zm" ) && ( self.damagemod != "MOD_GRENADE" && self.damagemod != "MOD_GRENADE_SPLASH" );
}

enemy_killed_by_jetgun()
{
    return isdefined( self.jetgun_fling ) && self.jetgun_fling || isdefined( self.jetgun_grind ) && self.jetgun_grind;
}

zombie_do_drag( vdir, speed )
{
    if ( !self zombie_is_in_drag_state() )
    {
        self zombie_enter_drag_state( vdir, speed );
        self thread zombie_drag_think();
    }
    else
        self zombie_keep_in_drag_state( vdir, speed );
}

zombie_is_in_drag_state()
{
    return isdefined( self.drag_state ) && self.drag_state;
}

zombie_should_stay_in_drag_state()
{
    if ( !isdefined( self ) || !isalive( self ) )
        return false;

    if ( !isdefined( self.jetgun_owner ) || self.jetgun_owner getcurrentweapon() != "jetgun_zm" || !self.jetgun_owner is_jetgun_firing() )
        return false;

    if ( isdefined( self.drag_state ) && self.drag_state )
        return true;

    return false;
}

zombie_keep_in_drag_state( vdir, speed )
{
    self.drag_start_time = gettime();
    self.drag_target = vdir;
}

zombie_enter_drag_state( vdir, speed )
{
    self.drag_state = 1;
    self.jetgun_drag_state = "unaffected";
    self.was_traversing = isdefined( self.is_traversing ) && self.is_traversing;
    self notify( "killanimscript" );
    self zombie_keep_in_drag_state( vdir, speed );
    self.zombie_move_speed_pre_jetgun_drag = self.zombie_move_speed;
}

zombie_exit_drag_state()
{
    self notify( "jetgun_end_drag_state" );
    self.drag_state = 0;
    self.jetgun_drag_state = "unaffected";
    self.needs_run_update = 1;

    if ( isdefined( self.zombie_move_speed_pre_jetgun_drag ) )
    {
        self set_zombie_run_cycle( self.zombie_move_speed_pre_jetgun_drag );
        self.zombie_move_speed_pre_jetgun_drag = undefined;
    }
    else
        self set_zombie_run_cycle();

    if ( !( isdefined( self.isdog ) && self.isdog ) )
        self maps\mp\animscripts\zm_run::moverun();

    if ( isdefined( self.was_traversing ) && self.was_traversing )
    {
        self traversemode( "gravity" );
        self.a.nodeath = 0;
        self maps\mp\animscripts\zm_run::needsupdate();

        if ( !self.isdog )
            self maps\mp\animscripts\zm_run::moverun();

        self.is_traversing = 0;
        self notify( "zombie_end_traverse" );

        if ( is_mature() )
        {
            if ( isdefined( level._effect["zombie_guts_explosion"] ) )
                playfx( level._effect["zombie_guts_explosion"], self gettagorigin( "J_SpineLower" ) );
        }

        self.nodeathragdoll = 1;
        self dodamage( self.health + 666, self.origin, self );
    }
}

aiphysicstrace( start, end )
{
    result = physicstrace( start, end, ( 0, 0, 0 ), ( 0, 0, 0 ), self );
    return result["position"];
}

zombie_drag_think()
{
    self endon( "death" );
    self endon( "flinging" );
    self endon( "grinding" );

    while ( self zombie_should_stay_in_drag_state() )
    {
        self._distance_to_jetgun_owner = distancesquared( self.origin, self.jetgun_owner.origin );
        jetgun_network_choke();

        if ( self.zombie_move_speed == "sprint" || self._distance_to_jetgun_owner < level.jetgun_pulled_in_range )
            self jetgun_drag_set( "jetgun_sprint", "jetgun_walk_fast_crawl" );
        else if ( self._distance_to_jetgun_owner < level.jetgun_pulling_in_range )
            self jetgun_drag_set( "jetgun_walk_fast", "jetgun_walk_fast" );
        else if ( self._distance_to_jetgun_owner < level.jetgun_inner_range )
            self jetgun_drag_set( "jetgun_walk", "jetgun_walk_slow_crawl" );
        else if ( self._distance_to_jetgun_owner < level.jetgun_outer_edge )
            self jetgun_drag_set( "jetgun_walk_slow", "jetgun_walk_slow_crawl" );

        wait 0.1;
    }

    self thread zombie_exit_drag_state();
}

jetgun_drag_set( legsanim, crawlanim )
{
    self endon( "death" );
    self.needs_run_update = 1;

    if ( self.has_legs )
    {
        self._had_legs = 1;
        self set_zombie_run_cycle( legsanim );
    }
    else
    {
        self._had_legs = 0;
        self set_zombie_run_cycle( crawlanim );
    }
/#
    if ( self.jetgun_drag_state != legsanim )
        self thread jetgun_debug_print_on_ent( legsanim, ( 0, 0, 1 ) );
#/
    self.jetgun_drag_state = legsanim;
}

zombie_drag_radius()
{
/#
    self endon( "death_or_disconnect" );
    self endon( "weapon_change" );

    while ( true )
    {
        circle( self.origin, level.zombie_vars["jetgun_grind_range"], vectorscale( ( 1, 1, 1 ), 0.5 ) );
        circle( self.origin, level.zombie_vars["jetgun_drag_range"] / 8, ( 0, 0, 1 ) );
        circle( self.origin, level.zombie_vars["jetgun_drag_range"] / 4, ( 0, 1, 0 ) );
        circle( self.origin, level.zombie_vars["jetgun_drag_range"] / 2, ( 1, 0, 0 ) );
        circle( self.origin, level.zombie_vars["jetgun_drag_range"], ( 1, 0, 1 ) );
        wait 0.05;
    }
#/
}
