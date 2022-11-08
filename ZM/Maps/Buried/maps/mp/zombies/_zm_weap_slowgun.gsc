// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_audio;

init()
{
    if ( !maps\mp\zombies\_zm_weapons::is_weapon_included( "slowgun_zm" ) )
        return;

    registerclientfield( "actor", "slowgun_fx", 12000, 3, "int" );
    registerclientfield( "actor", "anim_rate", 7000, 5, "float" );
    registerclientfield( "allplayers", "anim_rate", 7000, 5, "float" );
    registerclientfield( "toplayer", "sndParalyzerLoop", 12000, 1, "int" );
    registerclientfield( "toplayer", "slowgun_fx", 12000, 1, "int" );
    level.sliquifier_distance_checks = 0;
    maps\mp\zombies\_zm_spawner::add_cusom_zombie_spawn_logic( ::slowgun_on_zombie_spawned );
    maps\mp\zombies\_zm_spawner::register_zombie_damage_callback( ::slowgun_zombie_damage_response );
    maps\mp\zombies\_zm_spawner::register_zombie_death_animscript_callback( ::slowgun_zombie_death_response );
    level._effect["zombie_slowgun_explosion"] = loadfx( "weapon/paralyzer/fx_paralyzer_body_disintegrate" );
    level._effect["zombie_slowgun_explosion_ug"] = loadfx( "weapon/paralyzer/fx_paralyzer_body_disintegrate_ug" );
    level._effect["zombie_slowgun_sizzle"] = loadfx( "weapon/paralyzer/fx_paralyzer_hit_dmg" );
    level._effect["zombie_slowgun_sizzle_ug"] = loadfx( "weapon/paralyzer/fx_paralyzer_hit_dmg_ug" );
    level._effect["player_slowgun_sizzle"] = loadfx( "weapon/paralyzer/fx_paralyzer_hit_noharm" );
    level._effect["player_slowgun_sizzle_ug"] = loadfx( "weapon/paralyzer/fx_paralyzer_hit_noharm" );
    level._effect["player_slowgun_sizzle_1st"] = loadfx( "weapon/paralyzer/fx_paralyzer_hit_noharm_view" );
    onplayerconnect_callback( ::slowgun_player_connect );
    level.slowgun_damage = 40;
    level.slowgun_damage_ug = 60;
    level.slowgun_damage_mod = "MOD_PROJECTILE_SPLASH";
    precacherumble( "damage_heavy" );
/#
    level thread show_anim_rates();
#/
}

slowgun_player_connect()
{
    self thread watch_reset_anim_rate();
    self thread watch_slowgun_fired();
    self thread sndwatchforweapswitch();
}

sndwatchforweapswitch()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "weapon_change", weapon );

        if ( weapon == "slowgun_zm" || weapon == "slowgun_upgraded_zm" )
        {
            self setclientfieldtoplayer( "sndParalyzerLoop", 1 );

            self waittill( "weapon_change" );

            self setclientfieldtoplayer( "sndParalyzerLoop", 0 );
        }
    }
}

watch_reset_anim_rate()
{
    self set_anim_rate( 1.0 );
    self setclientfieldtoplayer( "slowgun_fx", 0 );

    while ( true )
    {
        self waittill_any( "spawned", "entering_last_stand", "player_revived", "player_suicide", "respawned" );
        self setclientfieldtoplayer( "slowgun_fx", 0 );
        self set_anim_rate( 1.0 );
    }
}

watch_slowgun_fired()
{
    self endon( "disconnect" );

    self waittill( "spawned_player" );

    for (;;)
    {
        self waittill( "weapon_fired", weapon );

        if ( weapon == "slowgun_zm" )
        {
            self slowgun_fired( 0 );
            continue;
        }

        if ( weapon == "slowgun_upgraded_zm" )
            self slowgun_fired( 1 );
    }
}

slowgun_fired( upgraded )
{
    origin = self getweaponmuzzlepoint();
    forward = self getweaponforwarddir();
/#
    show_muzzle( origin, forward );
#/
    targets = self get_targets_in_range( upgraded, origin, forward );

    if ( targets.size )
    {
        foreach ( target in targets )
        {
            if ( isplayer( target ) )
            {
                if ( is_player_valid( target ) && self != target )
                    target thread player_paralyzed( self, upgraded );

                continue;
            }

            if ( isdefined( target.paralyzer_hit_callback ) )
            {
                target thread [[ target.paralyzer_hit_callback ]]( self, upgraded );
                continue;
            }

            target thread zombie_paralyzed( self, upgraded );
        }
    }

    dot = vectordot( forward, ( 0, 0, -1 ) );

    if ( dot > 0.8 )
        self thread player_paralyzed( self, upgraded );
}

slowgun_get_enemies_in_range( upgraded, position, forward, possible_targets )
{
    inner_range = 12;
    outer_range = 660;
    cylinder_radius = 48;
    level.slowgun_enemies = [];
    view_pos = position;

    if ( !isdefined( possible_targets ) )
        return level.slowgun_enemies;

    slowgun_inner_range_squared = inner_range * inner_range;
    slowgun_outer_range_squared = outer_range * outer_range;
    cylinder_radius_squared = cylinder_radius * cylinder_radius;
    forward_view_angles = forward;
    end_pos = view_pos + vectorscale( forward_view_angles, outer_range );
/#
    if ( 2 == getdvarint( _hash_61A711C2 ) )
    {
        near_circle_pos = view_pos + vectorscale( forward_view_angles, 2 );
        circle( near_circle_pos, cylinder_radius, ( 1, 0, 0 ), 0, 0, 100 );
        line( near_circle_pos, end_pos, ( 0, 0, 1 ), 1, 0, 100 );
        circle( end_pos, cylinder_radius, ( 1, 0, 0 ), 0, 0, 100 );
    }
#/
    for ( i = 0; i < possible_targets.size; i++ )
    {
        if ( !isdefined( possible_targets[i] ) || !isalive( possible_targets[i] ) )
            continue;

        test_origin = possible_targets[i] getcentroid();
        test_range_squared = distancesquared( view_pos, test_origin );

        if ( test_range_squared > slowgun_outer_range_squared )
        {
            possible_targets[i] slowgun_debug_print( "range", ( 1, 0, 0 ) );
            continue;
        }

        normal = vectornormalize( test_origin - view_pos );
        dot = vectordot( forward_view_angles, normal );

        if ( 0 > dot )
        {
            possible_targets[i] slowgun_debug_print( "dot", ( 1, 0, 0 ) );
            continue;
        }

        radial_origin = pointonsegmentnearesttopoint( view_pos, end_pos, test_origin );

        if ( distancesquared( test_origin, radial_origin ) > cylinder_radius_squared )
        {
            possible_targets[i] slowgun_debug_print( "cylinder", ( 1, 0, 0 ) );
            continue;
        }

        if ( 0 == possible_targets[i] damageconetrace( view_pos, self ) )
        {
            possible_targets[i] slowgun_debug_print( "cone", ( 1, 0, 0 ) );
            continue;
        }

        level.slowgun_enemies[level.slowgun_enemies.size] = possible_targets[i];
    }

    return level.slowgun_enemies;
}

get_targets_in_range( upgraded, position, forward )
{
    if ( !isdefined( self.slowgun_targets ) || gettime() - self.slowgun_target_time > 150 )
    {
        targets = [];
        possible_targets = getaispeciesarray( level.zombie_team, "all" );
        possible_targets = arraycombine( possible_targets, get_players(), 1, 0 );

        if ( isdefined( level.possible_slowgun_targets ) && level.possible_slowgun_targets.size > 0 )
            possible_targets = arraycombine( possible_targets, level.possible_slowgun_targets, 1, 0 );

        targets = slowgun_get_enemies_in_range( 0, position, forward, possible_targets );
        self.slowgun_targets = targets;
        self.slowgun_target_time = gettime();
    }

    return self.slowgun_targets;
}

slowgun_on_zombie_spawned()
{
    self set_anim_rate( 1.0 );
    self.paralyzer_hit_callback = ::zombie_paralyzed;
    self.paralyzer_damaged_multiplier = 1;
    self.paralyzer_score_time_ms = gettime();
    self.paralyzer_slowtime = 0;
    self setclientfield( "slowgun_fx", 0 );
}

can_be_paralyzed( zombie )
{
    if ( is_true( zombie.is_ghost ) )
        return false;

    if ( is_true( zombie.guts_explosion ) )
        return false;

    if ( isdefined( zombie ) && zombie.health > 0 )
        return true;

    return false;
}

set_anim_rate( rate )
{
    if ( isdefined( self ) )
    {
        self.slowgun_anim_rate = rate;

        if ( !is_true( level.ignore_slowgun_anim_rates ) && !is_true( self.ignore_slowgun_anim_rates ) )
        {
            self setclientfield( "anim_rate", rate );
            qrate = self getclientfield( "anim_rate" );
            self setentityanimrate( qrate );

            if ( isdefined( self.set_anim_rate ) )
                self [[ self.set_anim_rate ]]( rate );
        }
    }
}

reset_anim()
{
    wait_network_frame();

    if ( !isdefined( self ) )
        return;

    if ( is_true( self.is_traversing ) )
    {
        animstate = self getanimstatefromasd();

        if ( !is_true( self.no_restart ) )
        {
            self.no_restart = 1;
            animstate += "_no_restart";
        }

        substate = self getanimsubstatefromasd();
        self setanimstatefromasd( animstate, substate );
    }
    else
    {
        self.needs_run_update = 1;
        self notify( "needs_run_update" );
    }
}

zombie_change_rate( time, newrate )
{
    self set_anim_rate( newrate );

    if ( isdefined( self.reset_anim ) )
        self thread [[ self.reset_anim ]]();
    else
        self thread reset_anim();

    if ( time > 0 )
        wait( time );
}

zombie_slow_for_time( time, multiplier = 2.0 )
{
    paralyzer_time_per_frame = 0.1 * ( 1.0 + multiplier );

    if ( self.paralyzer_slowtime <= time )
        self.paralyzer_slowtime = time + paralyzer_time_per_frame;
    else
        self.paralyzer_slowtime += paralyzer_time_per_frame;

    if ( !isdefined( self.slowgun_anim_rate ) )
        self.slowgun_anim_rate = 1;

    if ( !isdefined( self.slowgun_desired_anim_rate ) )
        self.slowgun_desired_anim_rate = 1;

    if ( self.slowgun_desired_anim_rate > 0.3 )
        self.slowgun_desired_anim_rate -= 0.2;
    else
        self.slowgun_desired_anim_rate = 0.05;

    if ( is_true( self.slowing ) )
        return;

    self.slowing = 1;
    self.preserve_asd_substates = 1;
    self playloopsound( "wpn_paralyzer_slowed_loop", 0.1 );

    while ( self.paralyzer_slowtime > 0 && isalive( self ) )
    {
        if ( self.paralyzer_slowtime < 0.1 )
            self.slowgun_desired_anim_rate = 1;
        else if ( self.paralyzer_slowtime < 2 * 0.1 )
            self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, 0.8 );
        else if ( self.paralyzer_slowtime < 3 * 0.1 )
            self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, 0.6 );
        else if ( self.paralyzer_slowtime < 4 * 0.1 )
            self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, 0.4 );
        else if ( self.paralyzer_slowtime < 5 * 0.1 )
            self.slowgun_desired_anim_rate = max( self.slowgun_desired_anim_rate, 0.2 );

        if ( self.slowgun_desired_anim_rate == self.slowgun_anim_rate )
        {
            self.paralyzer_slowtime -= 0.1;
            wait 0.1;
        }
        else if ( self.slowgun_desired_anim_rate >= self.slowgun_anim_rate )
        {
            new_rate = self.slowgun_desired_anim_rate;

            if ( self.slowgun_desired_anim_rate - self.slowgun_anim_rate > 0.2 )
                new_rate = self.slowgun_anim_rate + 0.2;

            self.paralyzer_slowtime -= 0.1;
            zombie_change_rate( 0.1, new_rate );
            self.paralyzer_damaged_multiplier = 1;
        }
        else if ( self.slowgun_desired_anim_rate <= self.slowgun_anim_rate )
        {
            new_rate = self.slowgun_desired_anim_rate;

            if ( self.slowgun_anim_rate - self.slowgun_desired_anim_rate > 0.2 )
                new_rate = self.slowgun_anim_rate - 0.2;

            self.paralyzer_slowtime -= 0.25;
            zombie_change_rate( 0.25, new_rate );
        }
    }

    if ( self.slowgun_anim_rate < 1 )
        self zombie_change_rate( 0, 1 );

    self.preserve_asd_substates = 0;
    self.slowing = 0;
    self.paralyzer_damaged_multiplier = 1;
    self setclientfield( "slowgun_fx", 0 );
    self stoploopsound( 0.1 );
}

zombie_paralyzed( player, upgraded )
{
    if ( !can_be_paralyzed( self ) )
        return;

    insta = player maps\mp\zombies\_zm_powerups::is_insta_kill_active();

    if ( upgraded )
        self setclientfield( "slowgun_fx", 5 );
    else
        self setclientfield( "slowgun_fx", 1 );

    if ( self.slowgun_anim_rate <= 0.1 || insta && self.slowgun_anim_rate <= 0.5 )
    {
        if ( upgraded )
            damage = level.slowgun_damage_ug;
        else
            damage = level.slowgun_damage;

        damage *= randomfloatrange( 0.667, 1.5 );
        damage *= self.paralyzer_damaged_multiplier;

        if ( !isdefined( self.paralyzer_damage ) )
            self.paralyzer_damage = 0;

        if ( self.paralyzer_damage > 47073 )
            damage *= 47073 / self.paralyzer_damage;

        self.paralyzer_damage += damage;

        if ( insta )
            damage = self.health + 666;

        if ( isalive( self ) )
            self dodamage( damage, player.origin, player, player, "none", level.slowgun_damage_mod, 0, "slowgun_zm" );

        self.paralyzer_damaged_multiplier *= 1.15;
        self.paralyzer_damaged_multiplier = min( self.paralyzer_damaged_multiplier, 50 );
    }
    else
        self.paralyzer_damaged_multiplier = 1;

    self zombie_slow_for_time( 0.2 );
}

get_extra_damage( amount, mod, slow )
{
    mult = 1.0 - slow;
    return amount * slow;
}

slowgun_zombie_damage_response( mod, hit_location, hit_origin, player, amount )
{
    if ( !self is_slowgun_damage( self.damagemod, self.damageweapon ) )
    {
        if ( isdefined( self.slowgun_anim_rate ) && self.slowgun_anim_rate < 1.0 && mod != level.slowgun_damage_mod )
        {
            extra_damage = get_extra_damage( amount, mod, self.slowgun_anim_rate );

            if ( extra_damage > 0 )
            {
                if ( isalive( self ) )
                    self dodamage( extra_damage, hit_origin, player, player, hit_location, level.slowgun_damage_mod, 0, "slowgun_zm" );

                if ( !isalive( self ) )
                    return true;
            }
        }

        return false;
    }

    if ( gettime() - self.paralyzer_score_time_ms >= 500 )
    {
        self.paralyzer_score_time_ms = gettime();

        if ( self.paralyzer_damage < 47073 )
            player maps\mp\zombies\_zm_score::player_add_points( "damage", mod, hit_location, self.isdog, level.zombie_team );
    }

    if ( player maps\mp\zombies\_zm_powerups::is_insta_kill_active() )
        amount = self.health + 666;

    if ( isalive( self ) )
        self dodamage( amount, hit_origin, player, player, hit_location, mod, 0, "slowgun_zm" );

    return true;
}

explosion_choke()
{
    if ( !isdefined( level.slowgun_explosion_time ) )
        level.slowgun_explosion_time = 0;

    if ( level.slowgun_explosion_time != gettime() )
    {
        level.slowgun_explosion_count = 0;
        level.slowgun_explosion_time = gettime();
    }

    while ( level.slowgun_explosion_count > 4 )
    {
        wait 0.05;

        if ( level.slowgun_explosion_time != gettime() )
        {
            level.slowgun_explosion_count = 0;
            level.slowgun_explosion_time = gettime();
        }
    }

    level.slowgun_explosion_count++;
}

explode_into_dust( player, upgraded )
{
    if ( isdefined( self.marked_for_insta_upgraded_death ) )
        return;

    explosion_choke();

    if ( upgraded )
        self setclientfield( "slowgun_fx", 6 );
    else
        self setclientfield( "slowgun_fx", 2 );

    self.guts_explosion = 1;
    self ghost();
}

slowgun_zombie_death_response()
{
    if ( !self is_slowgun_damage( self.damagemod, self.damageweapon ) )
        return false;

    level maps\mp\zombies\_zm_spawner::zombie_death_points( self.origin, self.damagemod, self.damagelocation, self.attacker, self );
    self thread explode_into_dust( self.attacker, self.damageweapon == "slowgun_upgraded_zm" );
    return true;
}

is_slowgun_damage( mod, weapon )
{
    return isdefined( weapon ) && ( weapon == "slowgun_zm" || weapon == "slowgun_upgraded_zm" );
}

setjumpenabled( onoff )
{
    if ( onoff )
    {
        if ( isdefined( self.jump_was_enabled ) )
        {
            self allowjump( self.jump_was_enabled );
            self.jump_was_enabled = undefined;
        }
        else
            self allowjump( 1 );
    }
    else if ( !isdefined( self.jump_was_enabled ) )
        self.jump_was_enabled = self allowjump( 0 );
}

get_ahead_ent()
{
    velocity = self getvelocity();

    if ( lengthsquared( velocity ) < 225 )
        return undefined;

    start = self geteyeapprox();
    end = start + velocity * 0.25;
    mins = ( 0, 0, 0 );
    maxs = ( 0, 0, 0 );
    trace = physicstrace( start, end, vectorscale( ( -1, -1, 0 ), 15.0 ), vectorscale( ( 1, 1, 0 ), 15.0 ), self, level.physicstracemaskclip );

    if ( isdefined( trace["entity"] ) )
        return trace["entity"];
    else if ( trace["fraction"] < 0.99 || trace["surfacetype"] != "none" )
        return level;

    return undefined;
}

bump()
{
    self playrumbleonentity( "damage_heavy" );
    earthquake( 0.5, 0.15, self.origin, 1000, self );
}

player_fly_rumble()
{
    self endon( "player_slow_stop_flying" );
    self endon( "disconnect" );
    self endon( "platform_collapse" );
    self.slowgun_flying = 1;
    last_ground = self getgroundent();
    last_ahead = undefined;

    while ( true )
    {
        ground = self getgroundent();

        if ( isdefined( ground ) != isdefined( last_ground ) || ground != last_ground )
        {
            if ( isdefined( ground ) )
                self bump();
        }

        if ( isdefined( ground ) && !self.slowgun_flying )
        {
            self thread dont_tread_on_z();
            return;
        }

        last_ground = ground;

        if ( isdefined( ground ) )
            last_ahead = undefined;
        else
        {
            ahead = self get_ahead_ent();

            if ( isdefined( ahead ) )
            {
                if ( isdefined( ahead ) != isdefined( last_ahead ) || ahead != last_ahead )
                {
                    self playsoundtoplayer( "zmb_invis_barrier_hit", self );
                    chance = get_response_chance( "invisible_collision" );

                    if ( chance > randomintrange( 1, 100 ) )
                        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "invisible_collision" );

                    self bump();
                }
            }

            last_ahead = ahead;
        }

        wait 0.15;
    }
}

dont_tread_on_z()
{
    if ( !isdefined( level.ghost_head_damage ) )
        level.ghost_head_damage = 30;

    ground = self getgroundent();

    if ( isdefined( ground ) && isdefined( ground.team ) && ground.team == level.zombie_team )
    {
        first_ground = ground;

        while ( !isdefined( ground ) || isdefined( ground.team ) && ground.team == level.zombie_team )
        {
            if ( is_true( self.slowgun_flying ) )
                return;

            if ( isdefined( ground ) )
            {
                self dodamage( level.ghost_head_damage, ground.origin, ground );

                if ( is_true( ground.is_ghost ) )
                {
                    level.ghost_head_damage *= 1.5;

                    if ( self.score > 4000 )
                        self.score -= 4000;
                    else
                        self.score = 0;
                }
            }
            else
                self dodamage( level.ghost_head_damage, first_ground.origin, first_ground );

            wait 0.25;
            ground = self getgroundent();
        }
    }
}

player_slow_for_time( time )
{
    self notify( "player_slow_for_time" );
    self endon( "player_slow_for_time" );
    self endon( "disconnect" );

    if ( !is_true( self.slowgun_flying ) )
        self thread player_fly_rumble();

    self setclientfieldtoplayer( "slowgun_fx", 1 );
    self set_anim_rate( 0.05 );
    wait( time );
    self set_anim_rate( 1.0 );
    self setclientfieldtoplayer( "slowgun_fx", 0 );
    self.slowgun_flying = 0;
}

player_paralyzed( byplayer, upgraded )
{
    self notify( "player_paralyzed" );
    self endon( "player_paralyzed" );
    self endon( "death" );

    if ( isdefined( level.slowgun_allow_player_paralyze ) )
    {
        if ( !self [[ level.slowgun_allow_player_paralyze ]]() )
            return;
    }

    if ( self != byplayer )
    {
        sizzle = "player_slowgun_sizzle";

        if ( upgraded )
            sizzle = "player_slowgun_sizzle_ug";

        if ( isdefined( level._effect[sizzle] ) )
            playfxontag( level._effect[sizzle], self, "J_SpineLower" );
    }

    self thread player_slow_for_time( 0.25 );
}

slowgun_debug_print( msg, color )
{
/#
    if ( getdvarint( _hash_61A711C2 ) != 2 )
        return;

    if ( !isdefined( color ) )
        color = ( 1, 1, 1 );

    print3d( self.origin + vectorscale( ( 0, 0, 1 ), 60.0 ), msg, color, 1, 1, 40 );
#/
}

show_anim_rate( pos, dsquared )
{
/#
    if ( distancesquared( pos, self.origin ) > dsquared )
        return;

    rate = self getentityanimrate();
    color = ( 1 - rate, rate, 0 );
    text = "" + int( rate * 100 ) + " S";
    print3d( self.origin + ( 0, 0, 0 ), text, color, 1, 0.5, 1 );
#/
}

show_slow_time( pos, dsquared, insta )
{
/#
    if ( distancesquared( pos, self.origin ) > dsquared )
        return;

    rate = self.paralyzer_slowtime;

    if ( !isdefined( rate ) || rate < 0.05 )
        return;

    if ( self getentityanimrate() <= 0.1 || insta && self getentityanimrate() <= 0.5 )
        color = ( 1, 0, 0 );
    else
        color = ( 0, 1, 0 );

    text = "" + rate + "";
    print3d( self.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), text, color, 1, 0.5, 1 );
#/
}

show_anim_rates()
{
/#
    while ( true )
    {
        if ( getdvarint( _hash_61A711C2 ) == 1 )
        {
            lp = get_players()[0];
            insta = lp maps\mp\zombies\_zm_powerups::is_insta_kill_active();
            zombies = getaispeciesarray( "all", "all" );

            if ( isdefined( zombies ) )
            {
                foreach ( zombie in zombies )
                    zombie show_slow_time( lp.origin, 360000, insta );
            }

            if ( isdefined( level.sloth ) )
                level.sloth show_slow_time( lp.origin, 360000, 0 );
        }

        if ( getdvarint( _hash_61A711C2 ) == 3 )
        {
            lp = get_players()[0];

            foreach ( player in get_players() )
                player show_anim_rate( lp.origin, 360000 );

            zombies = getaispeciesarray( "all", "all" );

            if ( isdefined( zombies ) )
            {
                foreach ( zombie in zombies )
                    zombie show_anim_rate( lp.origin, 360000 );
            }
        }

        wait 0.05;
    }
#/
}

show_muzzle( origin, forward )
{
/#
    if ( getdvarint( _hash_61A711C2 ) == 4 )
    {
        seconds = 0.25;
        grey = vectorscale( ( 1, 1, 1 ), 0.3 );
        green = ( 0, 1, 0 );
        start = origin;
        end = origin + 12 * forward;
        frames = int( 20 * seconds );
        line( start, end, green, 1, 0, frames );
    }
#/
}
