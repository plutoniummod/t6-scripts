// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_clone;

init()
{
    if ( !cymbal_monkey_exists() )
        return;
/#
    level.zombiemode_devgui_cymbal_monkey_give = ::player_give_cymbal_monkey;
#/
    if ( isdefined( level.legacy_cymbal_monkey ) && level.legacy_cymbal_monkey )
        level.cymbal_monkey_model = "weapon_zombie_monkey_bomb";
    else
        level.cymbal_monkey_model = "t6_wpn_zmb_monkey_bomb_world";

    level._effect["monkey_glow"] = loadfx( "maps/zombie/fx_zombie_monkey_light" );
    level._effect["grenade_samantha_steal"] = loadfx( "maps/zombie/fx_zmb_blackhole_trap_end" );
    level.cymbal_monkeys = [];
    scriptmodelsuseanimtree( -1 );
}

player_give_cymbal_monkey()
{
    self giveweapon( "cymbal_monkey_zm" );
    self set_player_tactical_grenade( "cymbal_monkey_zm" );
    self thread player_handle_cymbal_monkey();
}

player_handle_cymbal_monkey()
{
    self notify( "starting_monkey_watch" );
    self endon( "disconnect" );
    self endon( "starting_monkey_watch" );
    attract_dist_diff = level.monkey_attract_dist_diff;

    if ( !isdefined( attract_dist_diff ) )
        attract_dist_diff = 45;

    num_attractors = level.num_monkey_attractors;

    if ( !isdefined( num_attractors ) )
        num_attractors = 96;

    max_attract_dist = level.monkey_attract_dist;

    if ( !isdefined( max_attract_dist ) )
        max_attract_dist = 1536;

    while ( true )
    {
        grenade = get_thrown_monkey();
        self player_throw_cymbal_monkey( grenade, num_attractors, max_attract_dist, attract_dist_diff );
        wait 0.05;
    }
}

watch_for_dud( model, actor )
{
    self endon( "death" );

    self waittill( "grenade_dud" );

    model.dud = 1;
    self playsound( "zmb_vox_monkey_scream" );
    self.monk_scream_vox = 1;
    wait 3;

    if ( isdefined( model ) )
        model delete();

    if ( isdefined( actor ) )
        actor delete();

    if ( isdefined( self.damagearea ) )
        self.damagearea delete();

    if ( isdefined( self ) )
        self delete();
}

#using_animtree("zombie_cymbal_monkey");

watch_for_emp( model, actor )
{
    self endon( "death" );

    if ( !should_watch_for_emp() )
        return;

    while ( true )
    {
        level waittill( "emp_detonate", origin, radius );

        if ( distancesquared( origin, self.origin ) < radius * radius )
            break;
    }

    self.stun_fx = 1;

    if ( isdefined( level._equipment_emp_destroy_fx ) )
        playfx( level._equipment_emp_destroy_fx, self.origin + vectorscale( ( 0, 0, 1 ), 5.0 ), ( 0, randomfloat( 360 ), 0 ) );

    wait 0.15;
    self.attract_to_origin = 0;
    self deactivate_zombie_point_of_interest();
    model clearanim( %o_monkey_bomb, 0 );
    wait 1;
    self detonate();
    wait 1;

    if ( isdefined( model ) )
        model delete();

    if ( isdefined( actor ) )
        actor delete();

    if ( isdefined( self.damagearea ) )
        self.damagearea delete();

    if ( isdefined( self ) )
        self delete();
}

clone_player_angles( owner )
{
    self endon( "death" );
    owner endon( "death" );

    while ( isdefined( self ) )
    {
        self.angles = owner.angles;
        wait 0.05;
    }
}

show_briefly( showtime )
{
    self endon( "show_owner" );

    if ( isdefined( self.show_for_time ) )
    {
        self.show_for_time = showtime;
        return;
    }

    self.show_for_time = showtime;
    self setvisibletoall();

    while ( self.show_for_time > 0 )
    {
        self.show_for_time -= 0.05;
        wait 0.05;
    }

    self setvisibletoallexceptteam( level.zombie_team );
    self.show_for_time = undefined;
}

show_owner_on_attack( owner )
{
    owner endon( "hide_owner" );
    owner endon( "show_owner" );
    self endon( "explode" );
    self endon( "death" );
    self endon( "grenade_dud" );
    owner.show_for_time = undefined;

    for (;;)
    {
        owner waittill( "weapon_fired" );

        owner thread show_briefly( 0.5 );
    }
}

hide_owner( owner )
{
    owner notify( "hide_owner" );
    owner endon( "hide_owner" );
    owner setperk( "specialty_immunemms" );
    owner.no_burning_sfx = 1;
    owner notify( "stop_flame_sounds" );
    owner setvisibletoallexceptteam( level.zombie_team );
    owner.hide_owner = 1;

    if ( isdefined( level._effect["human_disappears"] ) )
        playfx( level._effect["human_disappears"], owner.origin );

    self thread show_owner_on_attack( owner );
    evt = self waittill_any_return( "explode", "death", "grenade_dud" );
/#
    println( "ZMCLONE: Player visible again because of " + evt );
#/
    owner notify( "show_owner" );
    owner unsetperk( "specialty_immunemms" );

    if ( isdefined( level._effect["human_disappears"] ) )
        playfx( level._effect["human_disappears"], owner.origin );

    owner.no_burning_sfx = undefined;
    owner setvisibletoall();
    owner.hide_owner = undefined;
    owner show();
}

proximity_detonate( owner )
{
    wait 1.5;

    if ( !isdefined( self ) )
        return;

    detonateradius = 96;
    explosionradius = detonateradius * 2;
    damagearea = spawn( "trigger_radius", self.origin + ( 0, 0, 0 - detonateradius ), 4, detonateradius, detonateradius * 1.5 );
    damagearea setexcludeteamfortrigger( owner.team );
    damagearea enablelinkto();
    damagearea linkto( self );
    self.damagearea = damagearea;

    while ( isdefined( self ) )
    {
        damagearea waittill( "trigger", ent );

        if ( isdefined( owner ) && ent == owner )
            continue;

        if ( isdefined( ent.team ) && ent.team == owner.team )
            continue;

        self playsound( "wpn_claymore_alert" );
        dist = distance( self.origin, ent.origin );
        radiusdamage( self.origin + vectorscale( ( 0, 0, 1 ), 12.0 ), explosionradius, 1, 1, owner, "MOD_GRENADE_SPLASH", "cymbal_monkey_zm" );

        if ( isdefined( owner ) )
            self detonate( owner );
        else
            self detonate( undefined );

        break;
    }

    if ( isdefined( damagearea ) )
        damagearea delete();
}

player_throw_cymbal_monkey( grenade, num_attractors, max_attract_dist, attract_dist_diff )
{
    self endon( "disconnect" );
    self endon( "starting_monkey_watch" );

    if ( isdefined( grenade ) )
    {
        grenade endon( "death" );

        if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            if ( isdefined( grenade.damagearea ) )
                grenade.damagearea delete();

            grenade delete();
            return;
        }

        grenade hide();
        model = spawn( "script_model", grenade.origin );
        model setmodel( level.cymbal_monkey_model );
        model useanimtree( -1 );
        model linkto( grenade );
        model.angles = grenade.angles;
        model thread monkey_cleanup( grenade );
        clone = undefined;

        if ( isdefined( level.cymbal_monkey_dual_view ) && level.cymbal_monkey_dual_view )
        {
            model setvisibletoallexceptteam( level.zombie_team );
            clone = maps\mp\zombies\_zm_clone::spawn_player_clone( self, vectorscale( ( 0, 0, -1 ), 999.0 ), level.cymbal_monkey_clone_weapon, undefined );
            model.simulacrum = clone;
            clone maps\mp\zombies\_zm_clone::clone_animate( "idle" );
            clone thread clone_player_angles( self );
            clone notsolid();
            clone ghost();
        }

        grenade thread watch_for_dud( model, clone );
        grenade thread watch_for_emp( model, clone );
        info = spawnstruct();
        info.sound_attractors = [];
        grenade thread monitor_zombie_groans( info );

        grenade waittill( "stationary" );

        if ( isdefined( level.grenade_planted ) )
            self thread [[ level.grenade_planted ]]( grenade, model );

        if ( isdefined( grenade ) )
        {
            if ( isdefined( model ) )
            {
                model setanim( %o_monkey_bomb );

                if ( !( isdefined( grenade.backlinked ) && grenade.backlinked ) )
                {
                    model unlink();
                    model.origin = grenade.origin;
                    model.angles = grenade.angles;
                }
            }

            if ( isdefined( clone ) )
            {
                clone forceteleport( grenade.origin, grenade.angles );
                clone thread hide_owner( self );
                grenade thread proximity_detonate( self );
                clone show();
                clone setinvisibletoall();
                clone setvisibletoteam( level.zombie_team );
            }

            grenade resetmissiledetonationtime();
            playfxontag( level._effect["monkey_glow"], model, "origin_animate_jnt" );
            valid_poi = check_point_in_enabled_zone( grenade.origin, undefined, undefined );

            if ( isdefined( level.check_valid_poi ) )
                valid_poi = grenade [[ level.check_valid_poi ]]( valid_poi );

            if ( valid_poi )
            {
                grenade create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000 );
                grenade.attract_to_origin = 1;
                grenade thread create_zombie_point_of_interest_attractor_positions( 4, attract_dist_diff );
                grenade thread wait_for_attractor_positions_complete();
                grenade thread do_monkey_sound( model, info );
                level.cymbal_monkeys[level.cymbal_monkeys.size] = grenade;
            }
            else
            {
                grenade.script_noteworthy = undefined;
                level thread grenade_stolen_by_sam( grenade, model, clone );
            }
        }
        else
        {
            grenade.script_noteworthy = undefined;
            level thread grenade_stolen_by_sam( grenade, model, clone );
        }
    }
}

grenade_stolen_by_sam( ent_grenade, ent_model, ent_actor )
{
    if ( !isdefined( ent_model ) )
        return;

    direction = ent_model.origin;
    direction = ( direction[1], direction[0], 0 );

    if ( direction[1] < 0 || direction[0] > 0 && direction[1] > 0 )
        direction = ( direction[0], direction[1] * -1, 0 );
    else if ( direction[0] < 0 )
        direction = ( direction[0] * -1, direction[1], 0 );

    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( isalive( players[i] ) )
            players[i] playlocalsound( level.zmb_laugh_alias );
    }

    playfxontag( level._effect["grenade_samantha_steal"], ent_model, "tag_origin" );
    ent_model movez( 60, 1.0, 0.25, 0.25 );
    ent_model vibrate( direction, 1.5, 2.5, 1.0 );

    ent_model waittill( "movedone" );

    if ( isdefined( self.damagearea ) )
        self.damagearea delete();

    ent_model delete();

    if ( isdefined( ent_actor ) )
        ent_actor delete();

    if ( isdefined( ent_grenade ) )
    {
        if ( isdefined( ent_grenade.damagearea ) )
            ent_grenade.damagearea delete();

        ent_grenade delete();
    }
}

wait_for_attractor_positions_complete()
{
    self waittill( "attractor_positions_generated" );

    self.attract_to_origin = 0;
}

monkey_cleanup( parent )
{
    while ( true )
    {
        if ( !isdefined( parent ) )
        {
            if ( isdefined( self ) && ( isdefined( self.dud ) && self.dud ) )
                wait 6;

            if ( isdefined( self.simulacrum ) )
                self.simulacrum delete();

            self_delete();
            return;
        }

        wait 0.05;
    }
}

do_monkey_sound( model, info )
{
    self.monk_scream_vox = 0;

    if ( isdefined( level.grenade_safe_to_bounce ) )
    {
        if ( ![[ level.grenade_safe_to_bounce ]]( self.owner, "cymbal_monkey_zm" ) )
        {
            self playsound( "zmb_vox_monkey_scream" );
            self.monk_scream_vox = 1;
        }
    }

    if ( !self.monk_scream_vox && level.music_override == 0 )
    {
        if ( isdefined( level.cymbal_monkey_dual_view ) && level.cymbal_monkey_dual_view )
            self playsoundtoteam( "zmb_monkey_song", "allies" );
        else
            self playsound( "zmb_monkey_song" );
    }

    if ( !self.monk_scream_vox )
        self thread play_delayed_explode_vox();

    self waittill( "explode", position );

    level notify( "grenade_exploded", position, 100, 5000, 450 );
    monkey_index = -1;

    for ( i = 0; i < level.cymbal_monkeys.size; i++ )
    {
        if ( !isdefined( level.cymbal_monkeys[i] ) )
        {
            monkey_index = i;
            break;
        }
    }

    if ( monkey_index >= 0 )
        arrayremoveindex( level.cymbal_monkeys, monkey_index );

    if ( isdefined( model ) )
        model clearanim( %o_monkey_bomb, 0.2 );

    for ( i = 0; i < info.sound_attractors.size; i++ )
    {
        if ( isdefined( info.sound_attractors[i] ) )
            info.sound_attractors[i] notify( "monkey_blown_up" );
    }
}

play_delayed_explode_vox()
{
    wait 6.5;

    if ( isdefined( self ) )
        self playsound( "zmb_vox_monkey_explode" );
}

get_thrown_monkey()
{
    self endon( "disconnect" );
    self endon( "starting_monkey_watch" );

    while ( true )
    {
        self waittill( "grenade_fire", grenade, weapname );

        if ( weapname == "cymbal_monkey_zm" )
        {
            grenade.use_grenade_special_long_bookmark = 1;
            grenade.grenade_multiattack_bookmark_count = 1;
            return grenade;
        }

        wait 0.05;
    }
}

monitor_zombie_groans( info )
{
    self endon( "explode" );

    while ( true )
    {
        if ( !isdefined( self ) )
            return;

        if ( !isdefined( self.attractor_array ) )
        {
            wait 0.05;
            continue;
        }

        for ( i = 0; i < self.attractor_array.size; i++ )
        {
            if ( array_check_for_dupes( info.sound_attractors, self.attractor_array[i] ) )
            {
                if ( isdefined( self.origin ) && isdefined( self.attractor_array[i].origin ) )
                {
                    if ( distancesquared( self.origin, self.attractor_array[i].origin ) < 250000 )
                    {
                        info.sound_attractors[info.sound_attractors.size] = self.attractor_array[i];
                        self.attractor_array[i] thread play_zombie_groans();
                    }
                }
            }
        }

        wait 0.05;
    }
}

play_zombie_groans()
{
    self endon( "death" );
    self endon( "monkey_blown_up" );

    while ( true )
    {
        if ( isdefined( self ) )
        {
            self playsound( "zmb_vox_zombie_groan" );
            wait( randomfloatrange( 2, 3 ) );
        }
        else
            return;
    }
}

cymbal_monkey_exists()
{
    return isdefined( level.zombie_weapons["cymbal_monkey_zm"] );
}
