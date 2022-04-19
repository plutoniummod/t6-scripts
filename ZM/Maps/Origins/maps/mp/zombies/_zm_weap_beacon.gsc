// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_clone;
#include maps\mp\zombies\_zm_audio;

init()
{
    if ( !beacon_exists() )
        return;
/#
    level.zombiemode_devgui_beacon_give = ::player_give_beacon;
#/
    registerclientfield( "world", "play_launch_artillery_fx_robot_0", 14000, 1, "int" );
    registerclientfield( "world", "play_launch_artillery_fx_robot_1", 14000, 1, "int" );
    registerclientfield( "world", "play_launch_artillery_fx_robot_2", 14000, 1, "int" );
    registerclientfield( "scriptmover", "play_beacon_fx", 14000, 1, "int" );
    registerclientfield( "scriptmover", "play_artillery_barrage", 14000, 2, "int" );
    precachemodel( "jun_missile" );
    level._effect["beacon_glow"] = loadfx( "maps/zombie_tomb/fx_tomb_beacon_glow" );
    level._effect["beacon_shell_explosion"] = loadfx( "maps/zombie_tomb/fx_tomb_beacon_exp" );
    level._effect["beacon_shell_trail"] = loadfx( "maps/zombie_tomb/fx_tomb_beacon_trail" );
    level._effect["beacon_launch_fx"] = loadfx( "maps/zombie_tomb/fx_tomb_beacon_launch" );
    level._effect["grenade_samantha_steal"] = loadfx( "maps/zombie/fx_zmb_blackhole_trap_end" );
    level.beacons = [];
    level.zombie_weapons_callbacks["beacon_zm"] = ::player_give_beacon;
    scriptmodelsuseanimtree( -1 );
}

player_give_beacon()
{
    self giveweapon( "beacon_zm" );
    self set_player_tactical_grenade( "beacon_zm" );
    self thread player_handle_beacon();
}

player_handle_beacon()
{
    self notify( "starting_beacon_watch" );
    self endon( "disconnect" );
    self endon( "starting_beacon_watch" );
    attract_dist_diff = level.beacon_attract_dist_diff;

    if ( !isdefined( attract_dist_diff ) )
        attract_dist_diff = 45;

    num_attractors = level.num_beacon_attractors;

    if ( !isdefined( num_attractors ) )
        num_attractors = 96;

    max_attract_dist = level.beacon_attract_dist;

    if ( !isdefined( max_attract_dist ) )
        max_attract_dist = 1536;

    while ( true )
    {
        grenade = get_thrown_beacon();
        self thread player_throw_beacon( grenade, num_attractors, max_attract_dist, attract_dist_diff );
        wait 0.05;
    }
}

watch_for_dud( model, actor )
{
    self endon( "death" );

    self waittill( "grenade_dud" );

    model.dud = 1;
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
    owner endon( "bled_out" );

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
        radiusdamage( self.origin + vectorscale( ( 0, 0, 1 ), 12.0 ), explosionradius, 1, 1, owner, "MOD_GRENADE_SPLASH", "beacon_zm" );

        if ( isdefined( owner ) )
            self detonate( owner );
        else
            self detonate( undefined );

        break;
    }

    if ( isdefined( damagearea ) )
        damagearea delete();
}

player_throw_beacon( grenade, num_attractors, max_attract_dist, attract_dist_diff )
{
    self endon( "disconnect" );
    self endon( "starting_beacon_watch" );

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
        model endon( "weapon_beacon_timeout" );
        model setmodel( "t6_wpn_zmb_homing_beacon_world" );
        model useanimtree( -1 );
        model linkto( grenade );
        model.angles = grenade.angles;
        model thread beacon_cleanup( grenade );
        model.owner = self;
        clone = undefined;

        if ( isdefined( level.beacon_dual_view ) && level.beacon_dual_view )
        {
            model setvisibletoallexceptteam( level.zombie_team );
            clone = maps\mp\zombies\_zm_clone::spawn_player_clone( self, vectorscale( ( 0, 0, -1 ), 999.0 ), level.beacon_clone_weapon, undefined );
            model.simulacrum = clone;
            clone maps\mp\zombies\_zm_clone::clone_animate( "idle" );
            clone thread clone_player_angles( self );
            clone notsolid();
            clone ghost();
        }

        grenade thread watch_for_dud( model, clone );
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
                model thread weapon_beacon_anims();

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
            model setclientfield( "play_beacon_fx", 1 );
            valid_poi = check_point_in_enabled_zone( grenade.origin, undefined, undefined );

            if ( isdefined( level.check_valid_poi ) )
                valid_poi = grenade [[ level.check_valid_poi ]]( valid_poi );

            if ( valid_poi )
            {
                grenade create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000 );
                grenade.attract_to_origin = 1;
                grenade thread create_zombie_point_of_interest_attractor_positions( 4, attract_dist_diff );
                grenade thread wait_for_attractor_positions_complete();
                grenade thread do_beacon_sound( model, info );
                model thread wait_and_explode( grenade );
                model.time_thrown = gettime();

                while ( isdefined( level.weapon_beacon_busy ) && level.weapon_beacon_busy )
                {
                    wait 0.1;
                    continue;
                }

                if ( flag( "three_robot_round" ) && flag( "fire_link_enabled" ) )
                    model thread start_artillery_launch_ee( grenade );
                else
                    model thread start_artillery_launch_normal( grenade );

                level.beacons[level.beacons.size] = grenade;
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

#using_animtree("zombie_beacon");

weapon_beacon_anims()
{
    n_time = getanimlength( %o_zombie_dlc4_homing_deploy );
    self setanim( %o_zombie_dlc4_homing_deploy );
    wait( n_time );
    self setanim( %o_zombie_dlc4_homing_spin );
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

beacon_cleanup( parent )
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

do_beacon_sound( model, info )
{
    self.monk_scream_vox = 0;

    if ( isdefined( level.grenade_safe_to_bounce ) )
    {
        if ( ![[ level.grenade_safe_to_bounce ]]( self.owner, "beacon_zm" ) )
            self.monk_scream_vox = 1;
    }

    if ( !self.monk_scream_vox && level.music_override == 0 )
    {
        if ( isdefined( level.beacon_dual_view ) && level.beacon_dual_view )
            self playsoundtoteam( "null", "allies" );
        else
            self playsound( "null" );
    }

    if ( !self.monk_scream_vox )
        self thread play_delayed_explode_vox();

    self waittill( "robot_artillery_barrage", position );

    level notify( "grenade_exploded", position, 100, 5000, 450 );
    beacon_index = -1;

    for ( i = 0; i < level.beacons.size; i++ )
    {
        if ( !isdefined( level.beacons[i] ) )
        {
            beacon_index = i;
            break;
        }
    }

    if ( beacon_index >= 0 )
        arrayremoveindex( level.beacons, beacon_index );

    for ( i = 0; i < info.sound_attractors.size; i++ )
    {
        if ( isdefined( info.sound_attractors[i] ) )
            info.sound_attractors[i] notify( "beacon_blown_up" );
    }

    self delete();
}

play_delayed_explode_vox()
{
    wait 6.5;

    if ( isdefined( self ) )
    {

    }
}

get_thrown_beacon()
{
    self endon( "disconnect" );
    self endon( "starting_beacon_watch" );

    while ( true )
    {
        self waittill( "grenade_fire", grenade, weapname );

        if ( weapname == "beacon_zm" )
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
    self endon( "beacon_blown_up" );

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

beacon_exists()
{
    return isdefined( level.zombie_weapons["beacon_zm"] );
}

wait_and_explode( grenade )
{
    self endon( "beacon_missile_launch" );

    grenade waittill( "explode", position );

    self notify( "weapon_beacon_timeout" );

    if ( isdefined( grenade ) )
        grenade notify( "robot_artillery_barrage", self.origin );
}

start_artillery_launch_normal( grenade )
{
    self endon( "weapon_beacon_timeout" );
    sp_giant_robot = undefined;

    while ( !isdefined( sp_giant_robot ) )
    {
        for ( i = 0; i < 3; i++ )
        {
            if ( isdefined( level.a_giant_robots[i].is_walking ) && level.a_giant_robots[i].is_walking )
            {
                if ( !( isdefined( level.a_giant_robots[i].weap_beacon_firing ) && level.a_giant_robots[i].weap_beacon_firing ) )
                {
                    sp_giant_robot = level.a_giant_robots[i];
                    self thread artillery_fx_logic( sp_giant_robot, grenade );
                    self notify( "beacon_missile_launch" );
                    level.weapon_beacon_busy = 1;
                    grenade.fuse_reset = 1;
                    grenade.fuse_time = 100;
                    grenade resetmissiledetonationtime( 100 );
                    break;
                }
            }
        }

        wait 0.1;
    }
}

start_artillery_launch_ee( grenade )
{
    self endon( "weapon_beacon_timeout" );
    sp_giant_robot = undefined;
    n_index = 0;
    a_robot_index = [];
    a_robot_index[0] = 1;
    a_robot_index[1] = 0;
    a_robot_index[2] = 2;

    while ( n_index < a_robot_index.size )
    {
        n_robot_num = a_robot_index[n_index];

        if ( isdefined( level.a_giant_robots[n_robot_num].is_walking ) && level.a_giant_robots[n_robot_num].is_walking )
        {
            if ( !( isdefined( level.a_giant_robots[n_robot_num].weap_beacon_firing ) && level.a_giant_robots[n_robot_num].weap_beacon_firing ) )
            {
                sp_giant_robot = level.a_giant_robots[n_robot_num];
                self thread artillery_fx_logic_ee( sp_giant_robot, grenade );
                self notify( "beacon_missile_launch" );
                level.weapon_beacon_busy = 1;
                grenade.fuse_reset = 1;
                grenade.fuse_time = 100;
                grenade resetmissiledetonationtime( 100 );
                wait 2.0;
                n_index++;
            }
        }
        else if ( n_index == 0 )
        {
            if ( !flag( "three_robot_round" ) )
            {
                self thread start_artillery_launch_normal( grenade );
                break;
            }
        }
        else if ( n_index > 0 )
            break;

        wait 0.1;
    }

    self thread artillery_barrage_logic( grenade, 1 );
}

artillery_fx_logic( sp_giant_robot, grenade )
{
    sp_giant_robot.weap_beacon_firing = 1;
    level setclientfield( "play_launch_artillery_fx_robot_" + sp_giant_robot.giant_robot_id, 1 );
    self thread homing_beacon_vo();
    wait 0.5;

    if ( isdefined( sp_giant_robot ) )
    {
        level setclientfield( "play_launch_artillery_fx_robot_" + sp_giant_robot.giant_robot_id, 0 );
        wait 3.0;
        self thread artillery_barrage_logic( grenade );
        wait 1.0;
        sp_giant_robot.weap_beacon_firing = 0;
    }
}

artillery_fx_logic_ee( sp_giant_robot, grenade )
{
    sp_giant_robot.weap_beacon_firing = 1;
    sp_giant_robot playsound( "zmb_homingbeacon_missiile_alarm" );
    level setclientfield( "play_launch_artillery_fx_robot_" + sp_giant_robot.giant_robot_id, 1 );
    self thread homing_beacon_vo();
    wait 0.5;

    if ( isdefined( sp_giant_robot ) )
        level setclientfield( "play_launch_artillery_fx_robot_" + sp_giant_robot.giant_robot_id, 0 );

    wait 1.0;
    sp_giant_robot.weap_beacon_firing = 0;
}

homing_beacon_vo()
{
    if ( isdefined( self.owner ) && isplayer( self.owner ) )
    {
        n_time = gettime();

        if ( isdefined( self.time_thrown ) )
        {
            if ( n_time < self.time_thrown + 3000 )
                self.owner maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "use_beacon" );
        }
    }
}

artillery_barrage_logic( grenade, b_ee )
{
    if ( !isdefined( b_ee ) )
        b_ee = 0;

    if ( isdefined( b_ee ) && b_ee )
    {
        a_v_land_offsets = self build_weap_beacon_landing_offsets_ee();
        a_v_start_offsets = self build_weap_beacon_start_offsets_ee();
        n_num_missiles = 15;
        n_clientfield = 2;
    }
    else
    {
        a_v_land_offsets = self build_weap_beacon_landing_offsets();
        a_v_start_offsets = self build_weap_beacon_start_offsets();
        n_num_missiles = 5;
        n_clientfield = 1;
    }

    self.a_v_land_spots = [];
    self.a_v_start_spots = [];

    for ( i = 0; i < n_num_missiles; i++ )
    {
        self.a_v_start_spots[i] = self.origin + a_v_start_offsets[i];
        self.a_v_land_spots[i] = self.origin + a_v_land_offsets[i];
        v_start_trace = self.a_v_start_spots[i] - vectorscale( ( 0, 0, 1 ), 5000.0 );
        trace = bullettrace( v_start_trace, self.a_v_land_spots[i], 0, undefined );
        self.a_v_land_spots[i] = trace["position"];
        wait 0.05;
    }

    for ( i = 0; i < n_num_missiles; i++ )
    {
        self setclientfield( "play_artillery_barrage", n_clientfield );
        self thread wait_and_do_weapon_beacon_damage( i );
        wait_network_frame();
        self setclientfield( "play_artillery_barrage", 0 );

        if ( i == 0 )
        {
            wait 1.0;
            continue;
        }

        wait 0.25;
    }

    level thread allow_beacons_to_be_targeted_by_giant_robot();
    wait 6.0;
    grenade notify( "robot_artillery_barrage", self.origin );
}

allow_beacons_to_be_targeted_by_giant_robot()
{
    wait 3.0;
    level.weapon_beacon_busy = 0;
}

build_weap_beacon_landing_offsets()
{
    a_offsets = [];
    a_offsets[0] = ( 0, 0, 0 );
    a_offsets[1] = vectorscale( ( -1, 1, 0 ), 72.0 );
    a_offsets[2] = vectorscale( ( 1, 1, 0 ), 72.0 );
    a_offsets[3] = vectorscale( ( 1, -1, 0 ), 72.0 );
    a_offsets[4] = vectorscale( ( -1, -1, 0 ), 72.0 );
    return a_offsets;
}

build_weap_beacon_start_offsets()
{
    a_offsets = [];
    a_offsets[0] = vectorscale( ( 0, 0, 1 ), 8500.0 );
    a_offsets[1] = ( -6500, 6500, 8500 );
    a_offsets[2] = ( 6500, 6500, 8500 );
    a_offsets[3] = ( 6500, -6500, 8500 );
    a_offsets[4] = ( -6500, -6500, 8500 );
    return a_offsets;
}

build_weap_beacon_landing_offsets_ee()
{
    a_offsets = [];
    a_offsets[0] = ( 0, 0, 0 );
    a_offsets[1] = vectorscale( ( -1, 1, 0 ), 72.0 );
    a_offsets[2] = vectorscale( ( 1, 1, 0 ), 72.0 );
    a_offsets[3] = vectorscale( ( 1, -1, 0 ), 72.0 );
    a_offsets[4] = vectorscale( ( -1, -1, 0 ), 72.0 );
    a_offsets[5] = vectorscale( ( -1, 1, 0 ), 72.0 );
    a_offsets[6] = vectorscale( ( 1, 1, 0 ), 72.0 );
    a_offsets[7] = vectorscale( ( 1, -1, 0 ), 72.0 );
    a_offsets[8] = vectorscale( ( -1, -1, 0 ), 72.0 );
    a_offsets[9] = vectorscale( ( -1, 1, 0 ), 72.0 );
    a_offsets[10] = vectorscale( ( 1, 1, 0 ), 72.0 );
    a_offsets[11] = vectorscale( ( 1, -1, 0 ), 72.0 );
    a_offsets[12] = vectorscale( ( -1, -1, 0 ), 72.0 );
    a_offsets[13] = vectorscale( ( -1, 1, 0 ), 72.0 );
    a_offsets[14] = vectorscale( ( 1, 1, 0 ), 72.0 );
    return a_offsets;
}

build_weap_beacon_start_offsets_ee()
{
    a_offsets = [];
    a_offsets[0] = vectorscale( ( 0, 0, 1 ), 8500.0 );
    a_offsets[1] = ( -6500, 6500, 8500 );
    a_offsets[2] = ( 6500, 6500, 8500 );
    a_offsets[3] = ( 6500, -6500, 8500 );
    a_offsets[4] = ( -6500, -6500, 8500 );
    a_offsets[5] = ( -6500, 6500, 8500 );
    a_offsets[6] = ( 6500, 6500, 8500 );
    a_offsets[7] = ( 6500, -6500, 8500 );
    a_offsets[8] = ( -6500, -6500, 8500 );
    a_offsets[9] = ( -6500, 6500, 8500 );
    a_offsets[10] = ( 6500, 6500, 8500 );
    a_offsets[11] = ( 6500, -6500, 8500 );
    a_offsets[12] = ( -6500, -6500, 8500 );
    a_offsets[13] = ( -6500, 6500, 8500 );
    a_offsets[14] = ( 6500, 6500, 8500 );
    return a_offsets;
}

wait_and_do_weapon_beacon_damage( index )
{
    wait 3.0;
    v_damage_origin = self.a_v_land_spots[index];
    level.n_weap_beacon_zombie_thrown_count = 0;
    a_zombies_to_kill = [];
    a_zombies = getaispeciesarray( "axis", "all" );

    foreach ( zombie in a_zombies )
    {
        n_distance = distance( zombie.origin, v_damage_origin );

        if ( n_distance <= 200 )
        {
            n_damage = linear_map( n_distance, 200, 0, 7000, 8000 );

            if ( n_damage >= zombie.health )
            {
                a_zombies_to_kill[a_zombies_to_kill.size] = zombie;
                continue;
            }

            zombie thread set_beacon_damage();
            zombie dodamage( n_damage, zombie.origin, self.owner, self.owner, "none", "MOD_GRENADE_SPLASH", 0, "beacon_zm" );
        }
    }

    if ( index == 0 )
    {
        radiusdamage( self.origin + vectorscale( ( 0, 0, 1 ), 12.0 ), 10, 1, 1, self.owner, "MOD_GRENADE_SPLASH", "beacon_zm" );
        self ghost();
        self stopanimscripted( 0 );
    }

    level thread weap_beacon_zombie_death( self, a_zombies_to_kill );
    self thread weap_beacon_rumble();
}

weap_beacon_zombie_death( model, a_zombies_to_kill )
{
    n_interval = 0;

    for ( i = 0; i < a_zombies_to_kill.size; i++ )
    {
        zombie = a_zombies_to_kill[i];

        if ( !isdefined( zombie ) || !isalive( zombie ) )
            continue;

        zombie thread set_beacon_damage();
        zombie dodamage( zombie.health, zombie.origin, model.owner, model.owner, "none", "MOD_GRENADE_SPLASH", 0, "beacon_zm" );
        n_interval++;
        zombie thread weapon_beacon_launch_ragdoll();

        if ( n_interval >= 4 )
        {
            wait_network_frame();
            n_interval = 0;
        }
    }
}

weapon_beacon_launch_ragdoll()
{
    if ( isdefined( self.is_mechz ) && self.is_mechz )
        return;

    if ( isdefined( self.is_giant_robot ) && self.is_giant_robot )
        return;

    if ( level.n_weap_beacon_zombie_thrown_count >= 5 )
        return;

    level.n_weap_beacon_zombie_thrown_count++;

    if ( isdefined( level.ragdoll_limit_check ) && ![[ level.ragdoll_limit_check ]]() )
    {
        level thread weap_beacon_gib( self );
        return;
    }

    self startragdoll();
    n_x = randomintrange( 50, 150 );
    n_y = randomintrange( 50, 150 );

    if ( cointoss() )
        n_x *= -1;

    if ( cointoss() )
        n_y *= -1;

    v_launch = ( n_x, n_y, randomintrange( 75, 250 ) );
    self launchragdoll( v_launch );
}

weap_beacon_gib( ai_zombie )
{
    a_gib_ref = [];
    a_gib_ref[0] = level._zombie_gib_piece_index_all;
    ai_zombie gib( "normal", a_gib_ref );
}

weap_beacon_rumble()
{
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( isalive( player ) && isdefined( player ) )
        {
            if ( distance2dsquared( player.origin, self.origin ) < 250000 )
                player thread execute_weap_beacon_rumble();
        }
    }
}

execute_weap_beacon_rumble()
{
    self endon( "death" );
    self endon( "disconnect" );
    self setclientfieldtoplayer( "player_rumble_and_shake", 3 );
    wait_network_frame();
    self setclientfieldtoplayer( "player_rumble_and_shake", 0 );
}

set_beacon_damage()
{
    self endon( "death" );
    self.set_beacon_damage = 1;
    wait 0.05;
    self.set_beacon_damage = 0;
}
