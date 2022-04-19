// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_net;

init()
{
    level.dogs_enabled = 1;
    level.dog_rounds_enabled = 0;
    level.dog_round_count = 1;
    level.dog_spawners = [];
    level.enemy_dog_spawns = [];
    level.enemy_dog_locations = [];
    flag_init( "dog_clips" );
    precacherumble( "explosion_generic" );
    precacheshellshock( "dog_bite" );

    if ( getdvar( _hash_942939D4 ) == "" )
        setdvar( "zombie_dog_animset", "zombie" );

    if ( getdvar( _hash_CAA5B74F ) == "" )
        setdvar( "scr_dog_health_walk_multiplier", "4.0" );

    if ( getdvar( _hash_C7E63BA4 ) == "" )
        setdvar( "scr_dog_run_distance", "500" );

    level.melee_range_sav = getdvar( "ai_meleeRange" );
    level.melee_width_sav = getdvar( "ai_meleeWidth" );
    level.melee_height_sav = getdvar( "ai_meleeHeight" );
    setdvar( "dog_MeleeDamage", "100" );
    set_zombie_var( "dog_fire_trail_percent", 50 );
    level._effect["lightning_dog_spawn"] = loadfx( "maps/zombie/fx_zombie_dog_lightning_buildup" );
    level._effect["dog_eye_glow"] = loadfx( "maps/zombie/fx_zombie_dog_eyes" );
    level._effect["dog_gib"] = loadfx( "maps/zombie/fx_zombie_dog_explosion" );
    level._effect["dog_trail_fire"] = loadfx( "maps/zombie/fx_zombie_dog_fire_trail" );
    level._effect["dog_trail_ash"] = loadfx( "maps/zombie/fx_zombie_dog_ash_trail" );
    dog_spawner_init();
    level thread dog_clip_monitor();
}

enable_dog_rounds()
{
    level.dog_rounds_enabled = 1;

    if ( !isdefined( level.dog_round_track_override ) )
        level.dog_round_track_override = ::dog_round_tracker;

    level thread [[ level.dog_round_track_override ]]();
}

dog_spawner_init()
{
    level.dog_spawners = getentarray( "zombie_dog_spawner", "script_noteworthy" );
    later_dogs = getentarray( "later_round_dog_spawners", "script_noteworthy" );
    level.dog_spawners = arraycombine( level.dog_spawners, later_dogs, 1, 0 );

    if ( level.dog_spawners.size == 0 )
        return;

    for ( i = 0; i < level.dog_spawners.size; i++ )
    {
        if ( maps\mp\zombies\_zm_spawner::is_spawner_targeted_by_blocker( level.dog_spawners[i] ) )
        {
            level.dog_spawners[i].is_enabled = 0;
            continue;
        }

        level.dog_spawners[i].is_enabled = 1;
        level.dog_spawners[i].script_forcespawn = 1;
    }
/#
    assert( level.dog_spawners.size > 0 );
#/
    level.dog_health = 100;
    array_thread( level.dog_spawners, ::add_spawn_function, ::dog_init );
    level.enemy_dog_spawns = getentarray( "zombie_spawner_dog_init", "targetname" );
}

dog_round_spawning()
{
    level endon( "intermission" );
    level.dog_targets = getplayers();

    for ( i = 0; i < level.dog_targets.size; i++ )
        level.dog_targets[i].hunted_by = 0;
/#
    level endon( "kill_round" );

    if ( getdvarint( _hash_FA81816F ) == 2 || getdvarint( _hash_FA81816F ) >= 4 )
        return;
#/
    if ( level.intermission )
        return;

    level.dog_intermission = 1;
    level thread dog_round_aftermath();
    players = get_players();
    array_thread( players, ::play_dog_round );
    wait 1;
    playsoundatposition( "vox_zmba_event_dogstart_0", ( 0, 0, 0 ) );
    wait 6;

    if ( level.dog_round_count < 3 )
        max = players.size * 6;
    else
        max = players.size * 8;
/#
    if ( getdvar( _hash_4077D7E0 ) != "" )
        max = getdvarint( _hash_4077D7E0 );
#/
    level.zombie_total = max;
    dog_health_increase();
    count = 0;

    while ( count < max )
    {
        for ( num_player_valid = get_number_of_valid_players(); get_current_zombie_count() >= num_player_valid * 2; num_player_valid = get_number_of_valid_players() )
            wait 2;

        players = get_players();
        favorite_enemy = get_favorite_enemy();

        if ( isdefined( level.dog_spawn_func ) )
        {
            spawn_loc = [[ level.dog_spawn_func ]]( level.dog_spawners, favorite_enemy );
            ai = spawn_zombie( level.dog_spawners[0] );

            if ( isdefined( ai ) )
            {
                ai.favoriteenemy = favorite_enemy;
                spawn_loc thread dog_spawn_fx( ai, spawn_loc );
                level.zombie_total--;
                count++;
            }
        }
        else
        {
            spawn_point = dog_spawn_factory_logic( level.enemy_dog_spawns, favorite_enemy );
            ai = spawn_zombie( level.dog_spawners[0] );

            if ( isdefined( ai ) )
            {
                ai.favoriteenemy = favorite_enemy;
                spawn_point thread dog_spawn_fx( ai, spawn_point );
                level.zombie_total--;
                count++;
                flag_set( "dog_clips" );
            }
        }

        waiting_for_next_dog_spawn( count, max );
    }
}

waiting_for_next_dog_spawn( count, max )
{
    default_wait = 1.5;

    if ( level.dog_round_count == 1 )
        default_wait = 3;
    else if ( level.dog_round_count == 2 )
        default_wait = 2.5;
    else if ( level.dog_round_count == 3 )
        default_wait = 2;
    else
        default_wait = 1.5;

    default_wait -= count / max;
    wait( default_wait );
}

dog_round_aftermath()
{
    level waittill( "last_dog_down" );

    level thread maps\mp\zombies\_zm_audio::change_zombie_music( "dog_end" );
    power_up_origin = level.last_dog_origin;

    if ( isdefined( power_up_origin ) )
        level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop( "full_ammo", power_up_origin );

    wait 2;
    clientnotify( "dog_stop" );
    wait 6;
    level.dog_intermission = 0;
}

dog_spawn_fx( ai, ent )
{
    ai endon( "death" );
    ai setfreecameralockonallowed( 0 );
    playfx( level._effect["lightning_dog_spawn"], ent.origin );
    playsoundatposition( "zmb_hellhound_prespawn", ent.origin );
    wait 1.5;
    playsoundatposition( "zmb_hellhound_bolt", ent.origin );
    earthquake( 0.5, 0.75, ent.origin, 1000 );
    playrumbleonposition( "explosion_generic", ent.origin );
    playsoundatposition( "zmb_hellhound_spawn", ent.origin );
    angle = vectortoangles( ai.favoriteenemy.origin - ent.origin );
    angles = ( ai.angles[0], angle[1], ai.angles[2] );
    ai forceteleport( ent.origin, angles );
/#
    assert( isdefined( ai ), "Ent isn't defined." );
#/
/#
    assert( isalive( ai ), "Ent is dead." );
#/
/#
    assert( ai.isdog, "Ent isn't a dog;" );
#/
/#
    assert( is_magic_bullet_shield_enabled( ai ), "Ent doesn't have a magic bullet shield." );
#/
    ai zombie_setup_attack_properties_dog();
    ai stop_magic_bullet_shield();
    wait 0.1;
    ai show();
    ai setfreecameralockonallowed( 1 );
    ai.ignoreme = 0;
    ai notify( "visible" );
}

dog_spawn_sumpf_logic( dog_array, favorite_enemy )
{
/#
    assert( dog_array.size > 0, "Dog Spawner array is empty." );
#/
    dog_array = array_randomize( dog_array );

    for ( i = 0; i < dog_array.size; i++ )
    {
        if ( isdefined( level.old_dog_spawn ) && level.old_dog_spawn == dog_array[i] )
            continue;

        if ( distancesquared( dog_array[i].origin, favorite_enemy.origin ) > 160000 && distancesquared( dog_array[i].origin, favorite_enemy.origin ) < 640000 )
        {
            if ( distancesquared( ( 0, 0, dog_array[i].origin[2] ), ( 0, 0, favorite_enemy.origin[2] ) ) > 10000 )
                continue;
            else
            {
                level.old_dog_spawn = dog_array[i];
                return dog_array[i];
            }
        }
    }

    return dog_array[0];
}

dog_spawn_factory_logic( dog_array, favorite_enemy )
{
    dog_locs = array_randomize( level.enemy_dog_locations );

    for ( i = 0; i < dog_locs.size; i++ )
    {
        if ( isdefined( level.old_dog_spawn ) && level.old_dog_spawn == dog_locs[i] )
            continue;

        dist_squared = distancesquared( dog_locs[i].origin, favorite_enemy.origin );

        if ( dist_squared > 160000 && dist_squared < 1000000 )
        {
            level.old_dog_spawn = dog_locs[i];
            return dog_locs[i];
        }
    }

    return dog_locs[0];
}

get_favorite_enemy()
{
    dog_targets = getplayers();
    least_hunted = dog_targets[0];

    for ( i = 0; i < dog_targets.size; i++ )
    {
        if ( !isdefined( dog_targets[i].hunted_by ) )
            dog_targets[i].hunted_by = 0;

        if ( !is_player_valid( dog_targets[i] ) )
            continue;

        if ( !is_player_valid( least_hunted ) )
            least_hunted = dog_targets[i];

        if ( dog_targets[i].hunted_by < least_hunted.hunted_by )
            least_hunted = dog_targets[i];
    }

    least_hunted.hunted_by += 1;
    return least_hunted;
}

dog_health_increase()
{
    players = getplayers();

    if ( level.dog_round_count == 1 )
        level.dog_health = 400;
    else if ( level.dog_round_count == 2 )
        level.dog_health = 900;
    else if ( level.dog_round_count == 3 )
        level.dog_health = 1300;
    else if ( level.dog_round_count == 4 )
        level.dog_health = 1600;

    if ( level.dog_health > 1600 )
        level.dog_health = 1600;
}

dog_round_tracker()
{
    level.dog_round_count = 1;
    level.next_dog_round = level.round_number + randomintrange( 4, 7 );
    old_spawn_func = level.round_spawn_func;
    old_wait_func = level.round_wait_func;

    while ( true )
    {
        level waittill( "between_round_over" );
/#
        if ( getdvarint( _hash_4077D7E0 ) > 0 )
            level.next_dog_round = level.round_number;
#/
        if ( level.round_number == level.next_dog_round )
        {
            level.music_round_override = 1;
            old_spawn_func = level.round_spawn_func;
            old_wait_func = level.round_wait_func;
            dog_round_start();
            level.round_spawn_func = ::dog_round_spawning;
            level.next_dog_round = level.round_number + randomintrange( 4, 6 );
/#
            get_players()[0] iprintln( "Next dog round: " + level.next_dog_round );
#/
        }
        else if ( flag( "dog_round" ) )
        {
            dog_round_stop();
            level.round_spawn_func = old_spawn_func;
            level.round_wait_func = old_wait_func;
            level.music_round_override = 0;
            level.dog_round_count += 1;
        }
    }
}

dog_round_start()
{
    flag_set( "dog_round" );
    flag_set( "dog_clips" );
    level thread maps\mp\zombies\_zm_audio::change_zombie_music( "dog_start" );

    if ( !isdefined( level.doground_nomusic ) )
        level.doground_nomusic = 0;

    level.doground_nomusic = 1;
    level notify( "dog_round_starting" );
    clientnotify( "dog_start" );

    if ( isdefined( level.dog_melee_range ) )
        setdvar( "ai_meleeRange", level.dog_melee_range );
    else
        setdvar( "ai_meleeRange", 100 );
}

dog_round_stop()
{
    flag_clear( "dog_round" );
    flag_clear( "dog_clips" );

    if ( !isdefined( level.doground_nomusic ) )
        level.doground_nomusic = 0;

    level.doground_nomusic = 0;
    level notify( "dog_round_ending" );
    clientnotify( "dog_stop" );
    setdvar( "ai_meleeRange", level.melee_range_sav );
    setdvar( "ai_meleeWidth", level.melee_width_sav );
    setdvar( "ai_meleeHeight", level.melee_height_sav );
}

play_dog_round()
{
    self playlocalsound( "zmb_dog_round_start" );
    variation_count = 5;
    wait 4.5;
    players = getplayers();
    num = randomintrange( 0, players.size );
    players[num] maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "dog_spawn" );
}

dog_init()
{
    self.targetname = "zombie_dog";
    self.script_noteworthy = undefined;
    self.animname = "zombie_dog";
    self.ignoreall = 1;
    self.ignoreme = 1;
    self.allowdeath = 1;
    self.allowpain = 0;
    self.force_gib = 1;
    self.is_zombie = 1;
    self.has_legs = 1;
    self.gibbed = 0;
    self.head_gibbed = 0;
    self.default_goalheight = 40;
    self.ignore_inert = 1;
    self.grenadeawareness = 0;
    self.badplaceawareness = 0;
    self.ignoresuppression = 1;
    self.suppressionthreshold = 1;
    self.nododgemove = 1;
    self.dontshootwhilemoving = 1;
    self.pathenemylookahead = 0;
    self.badplaceawareness = 0;
    self.chatinitialized = 0;
    self.team = level.zombie_team;
    health_multiplier = 1.0;

    if ( getdvar( _hash_CAA5B74F ) != "" )
        health_multiplier = getdvarfloat( _hash_CAA5B74F );

    self.maxhealth = int( level.dog_health * health_multiplier );
    self.health = int( level.dog_health * health_multiplier );
    self.freezegun_damage = 0;
    self.zombie_move_speed = "sprint";
    self thread dog_run_think();
    self thread dog_stalk_audio();
    self thread maps\mp\zombies\_zm::round_spawn_failsafe();
    self ghost();
    self thread magic_bullet_shield();
    self dog_fx_eye_glow();
    self dog_fx_trail();
    self thread dog_death();
    level thread maps\mp\zombies\_zm_spawner::zombie_death_event( self );
    self thread maps\mp\zombies\_zm_spawner::enemy_death_detection();
    self.a.disablepain = 1;
    self disable_react();
    self clearenemy();
    self cleargoalvolume();
    self.flame_damage_time = 0;
    self.meleedamage = 40;
    self.thundergun_knockdown_func = ::dog_thundergun_knockdown;
    self maps\mp\zombies\_zm_spawner::zombie_history( "zombie_dog_spawn_init -> Spawned = " + self.origin );

    if ( isdefined( level.achievement_monitor_func ) )
        self [[ level.achievement_monitor_func ]]();
}

dog_fx_eye_glow()
{
    self.fx_dog_eye = spawn( "script_model", self gettagorigin( "J_EyeBall_LE" ) );
/#
    assert( isdefined( self.fx_dog_eye ) );
#/
    self.fx_dog_eye.angles = self gettagangles( "J_EyeBall_LE" );
    self.fx_dog_eye setmodel( "tag_origin" );
    self.fx_dog_eye linkto( self, "J_EyeBall_LE" );
}

dog_fx_trail()
{
    if ( !is_mature() || randomint( 100 ) > level.zombie_vars["dog_fire_trail_percent"] )
    {
        self.fx_dog_trail_type = level._effect["dog_trail_ash"];
        self.fx_dog_trail_sound = "zmb_hellhound_loop_breath";
    }
    else
    {
        self.a.nodeath = 1;
        self.fx_dog_trail_type = level._effect["dog_trail_fire"];
        self.fx_dog_trail_sound = "zmb_hellhound_loop_fire";
    }

    self.fx_dog_trail = spawn( "script_model", self gettagorigin( "tag_origin" ) );
/#
    assert( isdefined( self.fx_dog_trail ) );
#/
    self.fx_dog_trail.angles = self gettagangles( "tag_origin" );
    self.fx_dog_trail setmodel( "tag_origin" );
    self.fx_dog_trail linkto( self, "tag_origin" );
}

dog_death()
{
    self waittill( "death" );

    if ( get_current_zombie_count() == 0 && level.zombie_total == 0 )
    {
        level.last_dog_origin = self.origin;
        level notify( "last_dog_down" );
    }

    if ( isplayer( self.attacker ) )
    {
        event = "death";

        if ( issubstr( self.damageweapon, "knife_ballistic_" ) )
            event = "ballistic_knife_death";

        self.attacker maps\mp\zombies\_zm_score::player_add_points( event, self.damagemod, self.damagelocation, 1 );

        if ( randomintrange( 0, 100 ) >= 80 )
            self.attacker maps\mp\zombies\_zm_audio::create_and_play_dialog( "kill", "hellhound" );

        self.attacker maps\mp\zombies\_zm_stats::increment_client_stat( "zdogs_killed" );
        self.attacker maps\mp\zombies\_zm_stats::increment_player_stat( "zdogs_killed" );
    }

    if ( isdefined( self.attacker ) && isai( self.attacker ) )
        self.attacker notify( "killed", self );

    self stoploopsound();
/#
    assert( isdefined( self.fx_dog_eye ) );
#/
    self.fx_dog_eye delete();
/#
    assert( isdefined( self.fx_dog_trail ) );
#/
    self.fx_dog_trail delete();

    if ( isdefined( self.a.nodeath ) )
    {
        level thread dog_explode_fx( self.origin );
        self delete();
    }
    else
        self playsound( "zmb_hellhound_vocals_death" );
}

dog_explode_fx( origin )
{
    playfx( level._effect["dog_gib"], origin );
    playsoundatposition( "zmb_hellhound_explode", origin );
}

zombie_setup_attack_properties_dog()
{
    self maps\mp\zombies\_zm_spawner::zombie_history( "zombie_setup_attack_properties()" );
    self thread dog_behind_audio();
    self.ignoreall = 0;
    self.pathenemyfightdist = 64;
    self.meleeattackdist = 64;
    self.disablearrivals = 1;
    self.disableexits = 1;
}

stop_dog_sound_on_death()
{
    self waittill( "death" );

    self stopsounds();
}

dog_behind_audio()
{
    self thread stop_dog_sound_on_death();
    self endon( "death" );
    self waittill_any( "dog_running", "dog_combat" );
    self playsound( "zmb_hellhound_vocals_close" );
    wait 3;

    while ( true )
    {
        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            dogangle = angleclamp180( vectortoangles( self.origin - players[i].origin )[1] - players[i].angles[1] );

            if ( isalive( players[i] ) && !isdefined( players[i].revivetrigger ) )
            {
                if ( abs( dogangle ) > 90 && distance2d( self.origin, players[i].origin ) > 100 )
                {
                    self playsound( "zmb_hellhound_vocals_close" );
                    wait 3;
                }
            }
        }

        wait 0.75;
    }
}

dog_clip_monitor()
{
    clips_on = 0;
    level.dog_clips = getentarray( "dog_clips", "targetname" );

    while ( true )
    {
        for ( i = 0; i < level.dog_clips.size; i++ )
        {
            level.dog_clips[i] trigger_off();
            level.dog_clips[i] connectpaths();
        }

        flag_wait( "dog_clips" );

        if ( isdefined( level.no_dog_clip ) && level.no_dog_clip == 1 )
            return;

        for ( i = 0; i < level.dog_clips.size; i++ )
        {
            level.dog_clips[i] trigger_on();
            level.dog_clips[i] disconnectpaths();
            wait_network_frame();
        }

        dog_is_alive = 1;

        while ( dog_is_alive || flag( "dog_round" ) )
        {
            dog_is_alive = 0;
            dogs = getentarray( "zombie_dog", "targetname" );

            for ( i = 0; i < dogs.size; i++ )
            {
                if ( isalive( dogs[i] ) )
                    dog_is_alive = 1;
            }

            wait 1;
        }

        flag_clear( "dog_clips" );
        wait 1;
    }
}

special_dog_spawn( spawners, num_to_spawn )
{
    dogs = getaispeciesarray( "all", "zombie_dog" );

    if ( isdefined( dogs ) && dogs.size >= 9 )
        return false;

    if ( !isdefined( num_to_spawn ) )
        num_to_spawn = 1;

    spawn_point = undefined;
    count = 0;

    while ( count < num_to_spawn )
    {
        players = get_players();
        favorite_enemy = get_favorite_enemy();

        if ( isdefined( spawners ) )
        {
            spawn_point = spawners[randomint( spawners.size )];
            ai = spawn_zombie( spawn_point );

            if ( isdefined( ai ) )
            {
                ai.favoriteenemy = favorite_enemy;
                spawn_point thread dog_spawn_fx( ai );
                count++;
                flag_set( "dog_clips" );
            }
        }
        else if ( isdefined( level.dog_spawn_func ) )
        {
            spawn_loc = [[ level.dog_spawn_func ]]( level.dog_spawners, favorite_enemy );
            ai = spawn_zombie( level.dog_spawners[0] );

            if ( isdefined( ai ) )
            {
                ai.favoriteenemy = favorite_enemy;
                spawn_loc thread dog_spawn_fx( ai, spawn_loc );
                count++;
                flag_set( "dog_clips" );
            }
        }
        else
        {
            spawn_point = dog_spawn_factory_logic( level.enemy_dog_spawns, favorite_enemy );
            ai = spawn_zombie( level.dog_spawners[0] );

            if ( isdefined( ai ) )
            {
                ai.favoriteenemy = favorite_enemy;
                spawn_point thread dog_spawn_fx( ai, spawn_point );
                count++;
                flag_set( "dog_clips" );
            }
        }

        waiting_for_next_dog_spawn( count, num_to_spawn );
    }

    return true;
}

dog_run_think()
{
    self endon( "death" );

    self waittill( "visible" );

    if ( self.health > level.dog_health )
    {
        self.maxhealth = level.dog_health;
        self.health = level.dog_health;
    }
/#
    assert( isdefined( self.fx_dog_eye ) );
#/
    maps\mp\zombies\_zm_net::network_safe_play_fx_on_tag( "dog_fx", 2, level._effect["dog_eye_glow"], self.fx_dog_eye, "tag_origin" );
/#
    assert( isdefined( self.fx_dog_trail ) );
#/
    maps\mp\zombies\_zm_net::network_safe_play_fx_on_tag( "dog_fx", 2, self.fx_dog_trail_type, self.fx_dog_trail, "tag_origin" );
    self playloopsound( self.fx_dog_trail_sound );

    while ( true )
    {
        if ( !is_player_valid( self.favoriteenemy ) )
            self.favoriteenemy = get_favorite_enemy();

        wait 0.2;
    }
}

dog_stalk_audio()
{
    self endon( "death" );
    self endon( "dog_running" );
    self endon( "dog_combat" );

    while ( true )
    {
        self playsound( "zmb_hellhound_vocals_amb" );
        wait( randomfloatrange( 3, 6 ) );
    }
}

dog_thundergun_knockdown( player, gib )
{
    self endon( "death" );
    damage = int( self.maxhealth * 0.5 );
    self dodamage( damage, player.origin, player );
}
