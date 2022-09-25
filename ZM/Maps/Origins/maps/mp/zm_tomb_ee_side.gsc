// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zm_tomb_vo;
#include maps\mp\zm_tomb_ee_lights;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zm_tomb_amb;

init()
{
    precacheshader( "zm_tm_wth_dog" );
    precachemodel( "p6_zm_tm_tablet" );
    precachemodel( "p6_zm_tm_tablet_muddy" );
    precachemodel( "p6_zm_tm_radio_01" );
    precachemodel( "p6_zm_tm_radio_01_panel2_blood" );
    registerclientfield( "world", "wagon_1_fire", 14000, 1, "int" );
    registerclientfield( "world", "wagon_2_fire", 14000, 1, "int" );
    registerclientfield( "world", "wagon_3_fire", 14000, 1, "int" );
    registerclientfield( "actor", "ee_zombie_tablet_fx", 14000, 1, "int" );
    registerclientfield( "toplayer", "ee_beacon_reward", 14000, 1, "int" );
    onplayerconnect_callback( ::onplayerconnect_ee_jump_scare );
    onplayerconnect_callback( ::onplayerconnect_ee_oneinchpunch );
    sq_one_inch_punch();
    a_triggers = getentarray( "audio_bump_trigger", "targetname" );

    foreach ( trigger in a_triggers )
    {
        if ( isdefined( trigger.script_sound ) && trigger.script_sound == "zmb_perks_bump_bottle" )
            trigger thread check_for_change();
    }

    level thread wagon_fire_challenge();
    level thread wall_hole_poster();
    level thread quadrotor_medallions();
    level thread maps\mp\zm_tomb_ee_lights::main();
    level thread radio_ee_song();
}

quadrotor_medallions()
{
    flag_init( "ee_medallions_collected" );
    level thread quadrotor_medallions_vo();
    level.n_ee_medallions = 4;
    flag_wait( "ee_medallions_collected" );
    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "side_sting_4" );
    s_mg_spawn = getstruct( "mgspawn", "targetname" );
    v_spawnpt = s_mg_spawn.origin;
    v_spawnang = s_mg_spawn.angles;
    player = get_players()[0];
    options = player maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( "mg08_upgraded_zm" );
    m_mg_model = spawn_weapon_model( "mg08_upgraded_zm", undefined, v_spawnpt, v_spawnang, options );
    playfxontag( level._effect["special_glow"], m_mg_model, "tag_origin" );
    t_weapon_swap = tomb_spawn_trigger_radius( v_spawnpt, 100, 1 );
    t_weapon_swap.require_look_at = 1;
    t_weapon_swap.hint_string = &"ZM_TOMB_X2PU";
    t_weapon_swap.hint_parm1 = getweapondisplayname( "mg08_upgraded_zm" );

    for ( b_retrieved = 0; !b_retrieved; b_retrieved = swap_mg( e_player ) )
        t_weapon_swap waittill( "trigger", e_player );

    t_weapon_swap tomb_unitrigger_delete();
    m_mg_model delete();
}

quadrotor_medallions_vo()
{
    n_vo_counter = 0;

    while ( n_vo_counter < 4 )
    {
        level waittill( "quadrotor_medallion_found", v_quadrotor );

        v_quadrotor playsound( "zmb_medallion_pickup" );

        if ( isdefined( v_quadrotor ) )
        {
            maxissay( "vox_maxi_drone_pickups_" + n_vo_counter, v_quadrotor );
            n_vo_counter++;

            if ( isdefined( v_quadrotor ) && n_vo_counter == 4 )
                maxissay( "vox_maxi_drone_pickups_" + n_vo_counter, v_quadrotor );
        }
    }
}

swap_mg( e_player )
{
    str_current_weapon = e_player getcurrentweapon();
    str_reward_weapon = maps\mp\zombies\_zm_weapons::get_upgrade_weapon( "mg08_zm" );

    if ( is_player_valid( e_player ) && !e_player.is_drinking && !is_placeable_mine( str_current_weapon ) && !is_equipment( str_current_weapon ) && level.revive_tool != str_current_weapon && "none" != str_current_weapon && !e_player hacker_active() )
    {
        if ( e_player hasweapon( str_reward_weapon ) )
            e_player givemaxammo( str_reward_weapon );
        else
        {
            a_weapons = e_player getweaponslistprimaries();

            if ( isdefined( a_weapons ) && a_weapons.size >= get_player_weapon_limit( e_player ) )
                e_player takeweapon( str_current_weapon );

            e_player giveweapon( str_reward_weapon, 0, e_player maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( str_reward_weapon ) );
            e_player givestartammo( str_reward_weapon );
            e_player switchtoweapon( str_reward_weapon );
        }

        return true;
    }
    else
        return false;
}

wall_hole_poster()
{
    m_poster = getent( "hole_poster", "targetname" );
    m_poster setcandamage( 1 );
    m_poster.health = 1000;
    m_poster.maxhealth = m_poster.health;

    while ( true )
    {
        m_poster waittill( "damage" );

        if ( m_poster.health <= 0 )
            m_poster physicslaunch( m_poster.origin, ( 0, 0, 0 ) );
    }
}

wagon_fire_challenge()
{
    flag_init( "ee_wagon_timer_start" );
    flag_init( "ee_wagon_challenge_complete" );
    s_powerup = getstruct( "wagon_powerup", "targetname" );
    flag_wait( "start_zombie_round_logic" );
    wagon_fire_start();

    while ( true )
    {
        flag_wait( "ee_wagon_timer_start" );
        flag_wait_or_timeout( "ee_wagon_challenge_complete", 30 );

        if ( !flag( "ee_wagon_challenge_complete" ) )
        {
            wagon_fire_start();
            flag_clear( "ee_wagon_timer_start" );
        }
        else
        {
            maps\mp\zombies\_zm_powerups::specific_powerup_drop( "zombie_blood", s_powerup.origin );

            level waittill( "end_of_round" );

            waittillframeend;

            while ( level.weather_rain > 0 )
            {
                level waittill( "end_of_round" );

                waittillframeend;
            }

            wagon_fire_start();
            flag_clear( "ee_wagon_timer_start" );
            flag_clear( "ee_wagon_challenge_complete" );
        }
    }
}

wagon_fire_start()
{
    level.n_wagon_fires_out = 0;
    a_triggers = getentarray( "wagon_damage_trigger", "targetname" );

    foreach ( trigger in a_triggers )
    {
        trigger thread wagon_fire_trigger_watch();
        level setclientfield( trigger.script_noteworthy, 1 );
    }
}

wagon_fire_trigger_watch()
{
    self notify( "watch_reset" );
    self endon( "watch_reset" );

    while ( true )
    {
        self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );

        if ( isplayer( attacker ) && ( attacker getcurrentweapon() == "staff_water_zm" || attacker getcurrentweapon() == "staff_water_upgraded_zm" ) )
        {
            level.n_wagon_fires_out++;

            if ( !flag( "ee_wagon_timer_start" ) )
                flag_set( "ee_wagon_timer_start" );

            level setclientfield( self.script_noteworthy, 0 );

            if ( level.n_wagon_fires_out == 3 )
            {
                flag_set( "ee_wagon_challenge_complete" );
                level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "side_sting_1" );
            }

            return;
        }
    }
}

check_for_change()
{
    while ( true )
    {
        self waittill( "trigger", e_player );

        if ( e_player getstance() == "prone" )
        {
            e_player maps\mp\zombies\_zm_score::add_to_player_score( 25 );
            play_sound_at_pos( "purchase", e_player.origin );
            break;
        }

        wait 0.1;
    }
}

onplayerconnect_ee_jump_scare()
{
    self endon( "disconnect" );

    if ( !isdefined( level.jump_scare_lookat_point ) )
        level.jump_scare_lookat_point = getstruct( "struct_gg_look", "targetname" );

    if ( !isdefined( level.b_saw_jump_scare ) )
        level.b_saw_jump_scare = 0;

    while ( !level.b_saw_jump_scare )
    {
        n_time = 0;

        while ( self adsbuttonpressed() && n_time < 25 )
        {
            n_time++;
            wait 0.05;
        }

        if ( n_time >= 25 && self adsbuttonpressed() && self maps\mp\zombies\_zm_zonemgr::is_player_in_zone( "zone_nml_18" ) && sq_is_weapon_sniper( self getcurrentweapon() ) && is_player_looking_at( level.jump_scare_lookat_point.origin, 0.998, 0, undefined ) )
        {
            self playsoundtoplayer( "zmb_easteregg_scarydog", self );
            self.wth_elem = newclienthudelem( self );
            self.wth_elem.horzalign = "fullscreen";
            self.wth_elem.vertalign = "fullscreen";
            self.wth_elem.sort = 1000;
            self.wth_elem.foreground = 0;
            self.wth_elem setshader( "zm_tm_wth_dog", 640, 480 );
            self.wth_elem.hidewheninmenu = 1;
            j_time = 0;

            while ( self adsbuttonpressed() && j_time < 5 )
            {
                j_time++;
                wait 0.05;
            }

            self.wth_elem destroy();
            level.b_saw_jump_scare = 1;
        }

        wait 0.05;
    }
}

sq_is_weapon_sniper( str_weapon )
{
    a_snipers = array( "dsr50" );

    foreach ( str_sniper in a_snipers )
    {
        if ( issubstr( str_weapon, str_sniper ) && !issubstr( str_weapon, "+is" ) )
            return true;
    }

    return false;
}

onplayerconnect_ee_oneinchpunch()
{
    self.sq_one_inch_punch_stage = 0;
    self.sq_one_inch_punch_kills = 0;
}

sq_one_inch_punch_disconnect_watch()
{
    self waittill( "disconnect" );

    if ( isdefined( self.sq_one_inch_punch_tablet ) )
        self.sq_one_inch_punch_tablet delete();

    spawn_tablet_model( self.sq_one_inch_punch_tablet_num, "bunker", "muddy" );
    level.n_tablets_remaining++;
}

sq_one_inch_punch_death_watch()
{
    self endon( "disconnect" );

    self waittill( "bled_out" );

    if ( self.sq_one_inch_punch_stage < 6 )
    {
        self.sq_one_inch_punch_stage = 0;
        self.sq_one_inch_punch_kills = 0;

        if ( isdefined( self.sq_one_inch_punch_tablet ) )
            self.sq_one_inch_punch_tablet delete();

        spawn_tablet_model( self.sq_one_inch_punch_tablet_num, "bunker", "muddy" );
        level.n_tablets_remaining++;
    }
}

sq_one_inch_punch()
{
    maps\mp\zombies\_zm_spawner::add_custom_zombie_spawn_logic( ::bunker_volume_death_check );
    maps\mp\zombies\_zm_spawner::add_custom_zombie_spawn_logic( ::church_volume_death_check );
    level.n_tablets_remaining = 4;
    a_tablets = [];

    for ( n_player_id = 0; n_player_id < level.n_tablets_remaining; n_player_id++ )
        a_tablets[n_player_id] = spawn_tablet_model( n_player_id + 1, "bunker", "muddy" );

    t_bunker = getent( "trigger_oneinchpunch_bunker_table", "targetname" );
    t_bunker thread bunker_trigger_thread();
    t_bunker setcursorhint( "HINT_NOICON" );
    t_birdbath = getent( "trigger_oneinchpunch_church_birdbath", "targetname" );
    t_birdbath thread birdbath_trigger_thread();
    t_birdbath setcursorhint( "HINT_NOICON" );
}

bunker_trigger_thread()
{
    while ( true )
    {
        self waittill( "trigger", player );

        if ( player.sq_one_inch_punch_stage == 0 )
        {
            player.sq_one_inch_punch_stage++;
            player.sq_one_inch_punch_tablet_num = level.n_tablets_remaining;
            player setclientfieldtoplayer( "player_tablet_state", 2 );
            player playsound( "zmb_squest_oiptablet_pickup" );
            player thread sq_one_inch_punch_disconnect_watch();
            player thread sq_one_inch_punch_death_watch();
            m_tablet = getent( "tablet_bunker_" + level.n_tablets_remaining, "targetname" );
            m_tablet delete();
            level.n_tablets_remaining--;
/#
            iprintln( "1 - take the tablet to the church" );
#/
        }

        if ( player.sq_one_inch_punch_stage == 4 )
        {
            player.sq_one_inch_punch_tablet = spawn_tablet_model( player.sq_one_inch_punch_tablet_num, "bunker", "clean" );
            player.sq_one_inch_punch_stage++;
            player setclientfieldtoplayer( "player_tablet_state", 0 );
            player playsound( "zmb_squest_oiptablet_place_table" );
/#
            iprintln( "5 - charge the tablet in the bunker" );
#/
        }
        else if ( player.sq_one_inch_punch_stage == 6 && ( isdefined( player.beacon_ready ) && player.beacon_ready ) )
        {
            player setclientfieldtoplayer( "ee_beacon_reward", 0 );
            player maps\mp\zombies\_zm_weapons::weapon_give( "beacon_zm" );
            player thread richtofenrespondvoplay( "get_beacon" );

            if ( isdefined( level.zombie_include_weapons["beacon_zm"] ) && !level.zombie_include_weapons["beacon_zm"] )
            {
                level.zombie_include_weapons["beacon_zm"] = 1;
                level.zombie_weapons["beacon_zm"].is_in_box = 1;
            }

            player playsound( "zmb_squest_oiptablet_get_reward" );
            player.sq_one_inch_punch_stage++;
/#
            iprintln( "7 - tablet is activated; bestow rewards" );
#/
        }
    }
}

birdbath_trigger_thread()
{
    while ( true )
    {
        self waittill( "trigger", player );

        if ( player.sq_one_inch_punch_stage == 1 )
        {
            if ( isdefined( player.sq_one_inch_punch_reclean ) )
            {
                player.sq_one_inch_punch_reclean = undefined;
                player.sq_one_inch_punch_stage++;
                player.sq_one_inch_punch_tablet = spawn_tablet_model( player.sq_one_inch_punch_tablet_num, "church", "clean" );
                level thread tablet_cleanliness_chastise( player, 1 );
            }
            else
                player.sq_one_inch_punch_tablet = spawn_tablet_model( player.sq_one_inch_punch_tablet_num, "church", "muddy" );

            player playsound( "zmb_squest_oiptablet_bathe" );
            player setclientfieldtoplayer( "player_tablet_state", 0 );
            player.sq_one_inch_punch_stage++;
/#
            iprintln( "2 - charge the tablet in the church" );
#/
        }

        if ( player.sq_one_inch_punch_stage == 3 )
        {
            player setclientfieldtoplayer( "player_tablet_state", 1 );
            player.sq_one_inch_punch_stage++;

            if ( isdefined( player.sq_one_inch_punch_tablet ) )
                player.sq_one_inch_punch_tablet delete();

            player playsound( "zmb_squest_oiptablet_pickup_clean" );
            player thread tablet_cleanliness_thread();
/#
            iprintln( "4 - take the tablet to the tank bunker" );
#/
        }
    }
}

tablet_cleanliness_thread()
{
    self endon( "death_or_disconnect" );

    while ( self.sq_one_inch_punch_stage == 4 )
    {
        if ( self.is_player_slowed )
        {
            self setclientfieldtoplayer( "player_tablet_state", 2 );
            self playsoundtoplayer( "zmb_squest_oiptablet_dirtied", self );
            self.sq_one_inch_punch_stage = 1;
            self.sq_one_inch_punch_reclean = 1;
            level thread tablet_cleanliness_chastise( self );
/#
            iprintln( "1 - take the tablet to the church" );
#/
        }

        wait 1;
    }
}

tablet_cleanliness_chastise( e_player, b_cleaned )
{
    if ( !isdefined( b_cleaned ) )
        b_cleaned = 0;

    if ( !isdefined( e_player ) || isdefined( level.sam_talking ) && level.sam_talking || flag( "story_vo_playing" ) )
        return;

    flag_set( "story_vo_playing" );
    e_player set_player_dontspeak( 1 );
    level.sam_talking = 1;
    str_line = "vox_sam_generic_chastise_7";

    if ( b_cleaned )
        str_line = "vox_sam_generic_chastise_8";

    if ( isdefined( e_player ) )
        e_player playsoundtoplayer( str_line, e_player );

    n_duration = soundgetplaybacktime( str_line );
    wait( n_duration / 1000 );
    level.sam_talking = 0;
    flag_clear( "story_vo_playing" );

    if ( isdefined( e_player ) )
        e_player set_player_dontspeak( 0 );
}

bunker_volume_death_check()
{
    self waittill( "death" );

    if ( !isdefined( self ) )
        return;

    volume_name = "oneinchpunch_bunker_volume";
    volume = getent( volume_name, "targetname" );
    assert( isdefined( volume ), volume_name + " does not exist" );
    attacker = self.attacker;

    if ( isdefined( attacker ) && isplayer( attacker ) )
    {
        if ( attacker.sq_one_inch_punch_stage == 5 && ( self.damagemod == "MOD_MELEE" || self.damageweapon == "tomb_shield_zm" ) )
        {
            if ( self istouching( volume ) )
            {
                self setclientfield( "ee_zombie_tablet_fx", 1 );
                attacker.sq_one_inch_punch_kills++;
/#
                iprintln( "kill count: " + attacker.sq_one_inch_punch_kills );
#/
                if ( attacker.sq_one_inch_punch_kills >= 20 )
                {
                    attacker thread bunker_spawn_reward();
                    attacker.sq_one_inch_punch_stage++;
                    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "side_sting_3" );
/#
                    iprintln( "6 - activate the tablet in the bunker" );
#/
                }
            }
        }
    }
}

bunker_spawn_reward()
{
    self endon( "disconnect" );
    wait 2;
    self setclientfieldtoplayer( "ee_beacon_reward", 1 );
    wait 2;
    self.beacon_ready = 1;
}

church_volume_death_check()
{
    self waittill( "death" );

    if ( !isdefined( self ) )
        return;

    volume_name = "oneinchpunch_church_volume";
    volume = getent( volume_name, "targetname" );
    assert( isdefined( volume ), volume_name + " does not exist" );
    attacker = self.attacker;

    if ( isdefined( attacker ) && isplayer( attacker ) )
    {
        if ( attacker.sq_one_inch_punch_stage == 2 && ( self.damagemod == "MOD_MELEE" || self.damageweapon == "tomb_shield_zm" ) )
        {
            if ( self istouching( volume ) )
            {
                self setclientfield( "ee_zombie_tablet_fx", 1 );
                attacker.sq_one_inch_punch_kills++;
/#
                iprintln( "kill count: " + attacker.sq_one_inch_punch_kills );
#/
                if ( attacker.sq_one_inch_punch_kills >= 20 )
                {
                    attacker.sq_one_inch_punch_stage++;
                    attacker.sq_one_inch_punch_kills = 0;
                    attacker.sq_one_inch_punch_tablet delete();
                    attacker.sq_one_inch_punch_tablet = spawn_tablet_model( attacker.sq_one_inch_punch_tablet_num, "church", "clean" );
                    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "side_sting_6" );
/#
                    iprintln( "3 - tablet is charged, pick up the tablet from the birdbath" );
#/
                }
            }
        }
    }
}

spawn_tablet_model( n_player_id, str_location, str_state )
{
    s_tablet_spawn = getstruct( "oneinchpunch_" + str_location + "_tablet_" + n_player_id, "targetname" );
    v_spawnpt = s_tablet_spawn.origin;
    v_spawnang = s_tablet_spawn.angles;
    m_tablet = spawn( "script_model", v_spawnpt );
    m_tablet.angles = v_spawnang;

    if ( str_state == "clean" )
    {
        m_tablet setmodel( "p6_zm_tm_tablet" );

        if ( str_location == "church" )
            m_tablet playsound( "zmb_squest_oiptablet_charged" );
    }
    else
        m_tablet setmodel( "p6_zm_tm_tablet_muddy" );

    m_tablet.targetname = "tablet_" + str_location + "_" + n_player_id;
    return m_tablet;
}

radio_ee_song()
{
    level.found_ee_radio_count = 0;
    wait 3;
    a_structs = getstructarray( "ee_radio_pos", "targetname" );

    foreach ( unitrigger_stub in a_structs )
    {
        unitrigger_stub.radius = 50;
        unitrigger_stub.height = 128;
        unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
        unitrigger_stub.cursor_hint = "HINT_NOICON";
        unitrigger_stub.require_look_at = 1;
        m_radio = spawn( "script_model", unitrigger_stub.origin );
        m_radio.angles = unitrigger_stub.angles;
        m_radio setmodel( "p6_zm_tm_radio_01" );
        m_radio attach( "p6_zm_tm_radio_01_panel2_blood", "tag_j_cover" );
        maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::radio_ee_think );
/#
        unitrigger_stub thread radio_ee_debug();
#/
        wait_network_frame();
    }
}

radio_ee_debug()
{
/#
    self endon( "stop_display" );

    while ( true )
    {
        print3d( self.origin, "R", vectorscale( ( 1, 0, 1 ), 255.0 ), 1 );
        wait 0.05;
    }
#/
}

radio_ee_think()
{
    self endon( "kill_trigger" );

    while ( true )
    {
        self waittill( "trigger", player );

        if ( is_player_valid( player ) && !( isdefined( level.music_override ) && level.music_override ) )
        {
            level.found_ee_radio_count++;

            if ( level.found_ee_radio_count == 3 )
            {
                level.music_override = 1;
                ent = spawn( "script_origin", ( 0, 0, 0 ) );
                level thread maps\mp\zm_tomb_amb::sndmuseggplay( ent, "mus_zmb_secret_song_a7x", 352 );
            }
/#
            self.stub notify( "stop_display" );
#/
            maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.stub );
            return;
        }
    }
}
