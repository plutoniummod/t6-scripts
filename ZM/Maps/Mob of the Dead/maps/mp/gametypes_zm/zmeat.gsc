// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_game_module_meat_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_spawner;

main()
{
    maps\mp\gametypes_zm\_zm_gametype::main();
    registerclientfield( "allplayers", "holding_meat", 7000, 1, "int" );
    registerclientfield( "scriptmover", "ring_glowfx", 7000, 1, "int" );
    registerclientfield( "scriptmover", "ring_glow_meatfx", 7000, 1, "int" );
    level.onprecachegametype = ::onprecachegametype;
    level.onstartgametype = ::onstartgametype;
    set_game_var( "ZM_roundLimit", 5 );
    set_game_var( "ZM_scoreLimit", 5 );
    set_gamemode_var( "post_init_zombie_spawn_func", ::meat_zombie_post_spawn_init );
    set_gamemode_var( "match_end_notify", "meat_end" );
    set_gamemode_var( "match_end_func", ::meat_end_match );
    level._no_static_unitriggers = 1;
    level._game_module_player_damage_callback = maps\mp\gametypes_zm\_zm_gametype::game_module_player_damage_callback;
    level._game_module_player_laststand_callback = ::meat_last_stand_callback;
    level.no_end_game_check = 1;
    maps\mp\gametypes_zm\_zm_gametype::post_gametype_main( "zmeat" );
    level thread maps\mp\gametypes_zm\_zm_gametype::init();
    level.zm_roundswitch = 1;
    level.zm_switchsides_on_roundswitch = 1;
    level._effect["meat_marker"] = loadfx( "maps/zombie/fx_zmb_meat_marker" );
    level._effect["butterflies"] = loadfx( "maps/zombie/fx_zmb_impact_noharm" );
    level._effect["meat_glow"] = loadfx( "maps/zombie/fx_zmb_meat_glow" );
    level._effect["meat_glow3p"] = loadfx( "maps/zombie/fx_zmb_meat_glow_3p" );
    level._effect["spawn_cloud"] = loadfx( "maps/zombie/fx_zmb_race_zombie_spawn_cloud" );
    level._effect["fw_burst"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_burst_center" );
    level._effect["fw_impact"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_drop_impact" );
    level._effect["fw_drop"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_drop_trail" );
    level._effect["fw_trail"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_trail" );
    level._effect["fw_trail_cheap"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_trail_intro" );
    level._effect["fw_pre_burst"] = loadfx( "maps/zombie/fx_zmb_race_fireworks_burst_small" );
    level._effect["meat_bounce"] = loadfx( "maps/zombie/fx_zmb_meat_collision_glow" );
    level._effect["ring_glow"] = loadfx( "misc/fx_zombie_powerup_on" );
    level.can_revive_game_module = ::can_revive;
    onplayerconnect_callback( ::meat_on_player_connect );
    spawn_level_meat_manager();
    init_animtree();
}

onprecachegametype()
{
    level thread maps\mp\zombies\_zm_game_module_meat_utility::init_item_meat( "zmeat" );
    maps\mp\gametypes_zm\_zm_gametype::rungametypeprecache( "zmeat" );
    game_mode_objects = getstructarray( "game_mode_object", "targetname" );
    meat_objects = getstructarray( "meat_object", "targetname" );
    all_structs = arraycombine( game_mode_objects, meat_objects, 1, 0 );

    for ( i = 0; i < all_structs.size; i++ )
    {
        if ( isdefined( all_structs[i].script_parameters ) )
            precachemodel( all_structs[i].script_parameters );
    }

    precacheshellshock( "grief_stab_zm" );
    precacheitem( "minigun_zm" );
    precacheshader( "faction_cdc" );
    precacheshader( "faction_cia" );
    precachemodel( "p6_zm_sign_meat_01_step1" );
    precachemodel( "p6_zm_sign_meat_01_step2" );
    precachemodel( "p6_zm_sign_meat_01_step3" );
    precachemodel( "p6_zm_sign_meat_01_step4" );
}

meat_hub_start_func()
{
    level thread meat_player_initial_spawn();
    level thread item_meat_reset( level._meat_start_point );
    level thread spawn_meat_zombies();
    level thread monitor_meat_on_team();
    level thread init_minigun_ring();
    level thread init_splitter_ring();
    level thread init_ammo_ring();
    level thread hide_non_meat_objects();
    level thread setup_meat_world_objects();
    level._zombie_path_timer_override = ::zombie_path_timer_override;
    level.zombie_health = level.zombie_vars["zombie_health_start"];
    level._zombie_spawning = 0;
    level._poi_override = ::meat_poi_override_func;
    level._meat_on_team = undefined;
    level._meat_zombie_spawn_timer = 2;
    level._meat_zombie_spawn_health = 1;
    level._minigun_time_override = 15;
    level._get_game_module_players = ::get_game_module_players;
    level.powerup_drop_count = 0;
    level.meat_spawners = level.zombie_spawners;

    if ( !( isdefined( level._meat_callback_initialized ) && level._meat_callback_initialized ) )
    {
        maps\mp\zombies\_zm::register_player_damage_callback( maps\mp\zombies\_zm_game_module::damage_callback_no_pvp_damage );
        level._meat_callback_initialized = 1;
    }

    setmatchtalkflag( "DeadChatWithDead", 1 );
    setmatchtalkflag( "DeadChatWithTeam", 1 );
    setmatchtalkflag( "DeadHearTeamLiving", 1 );
    setmatchtalkflag( "DeadHearAllLiving", 1 );
    setmatchtalkflag( "EveryoneHearsEveryone", 1 );
    setteamhasmeat( "allies", 0 );
    setteamhasmeat( "axis", 0 );
    level thread zmbmusicsetupmeat();
    level.zombie_spawn_fx = level._effect["spawn_cloud"];
    weapon_spawns = getentarray( "weapon_upgrade", "targetname" );

    for ( i = 0; i < weapon_spawns.size; i++ )
        weapon_spawns[i] trigger_off();

    level thread monitor_meat_on_side();
    level thread item_meat_watch_for_throw();
    level thread hold_meat_monitor();
    flag_wait( "start_encounters_match_logic" );
    level thread wait_for_team_death( 1 );
    level thread wait_for_team_death( 2 );
    level.team_a_downed = 0;
    level.team_b_downed = 0;
}

meat_on_player_connect()
{
    hotjoined = flag( "initial_players_connected" );
    self thread spawn_player_meat_manager();
    self thread wait_for_player_disconnect();
    self thread wait_for_player_downed();
/#
    self thread watch_debug_input();
#/
    if ( hotjoined )
    {
        one = 1;
        two = 2;

        if ( get_game_var( "switchedsides" ) )
        {
            one = 2;
            two = 1;
        }

        if ( get_game_var( "side_selection" ) == 1 )
        {
            if ( self.team == "allies" )
                self._meat_team = one;
            else
                self._meat_team = two;
        }
        else if ( self.team == "allies" )
            self._meat_team = two;
        else
            self._meat_team = one;

        self meat_player_setup();
    }
}

meat_on_player_disconnect()
{
    team0 = 1;
    team1 = 2;
    team_counts = [];
    team_counts[team0] = 0;
    team_counts[team1] = 0;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
        team_counts[players[i]._meat_team] += 1;

    if ( team_counts[team0] == 0 )
        maps\mp\gametypes_zm\_zm_gametype::end_rounds_early( "B" );

    if ( team_counts[team1] == 0 )
        maps\mp\gametypes_zm\_zm_gametype::end_rounds_early( "A" );
}

wait_for_player_disconnect()
{
    level endon( "end_game" );

    self waittill( "disconnect" );

    meat_on_player_disconnect();
}

watch_debug_input()
{
/#
    self endon( "disconnect" );

    for (;;)
    {
        if ( self actionslottwobuttonpressed() )
        {
            if ( getdvar( _hash_B188A91 ) != "" )
            {
                self disableinvulnerability();
                self dodamage( self.health + 666, self.origin );
            }
        }

        wait 0.05;
    }
#/
}

zmbmusicsetupmeat()
{
    level.zmb_music_states["game_over"] = undefined;
    level thread maps\mp\zombies\_zm_audio::setupmusicstate( "waiting", "ENC_WAITING", 0, 0, 0, undefined );
    level thread maps\mp\zombies\_zm_audio::setupmusicstate( "round_start", "ENC_ROUND_START", 0, 0, 0, undefined );
    level thread maps\mp\zombies\_zm_audio::setupmusicstate( "round_end", "ENC_ROUND_END", 0, 0, 0, undefined );
    level thread maps\mp\zombies\_zm_audio::setupmusicstate( "halftime", "ENC_HALFTIME", 0, 0, 0, undefined );
    level thread maps\mp\zombies\_zm_audio::setupmusicstate( "match_over", "ENC_MATCH_OVER", 0, 0, 0, undefined );
}

monitor_meat_on_side()
{
    level endon( "meat_end" );

    level waittill( "meat_grabbed" );

    last_team = level._meat_on_team;
    level.meat_lost_time_limit = 5000;

    while ( true )
    {
        if ( isdefined( level.item_meat ) )
        {
            if ( !isdefined( level._meat_team_1_volume ) || !isdefined( level._meat_team_2_volume ) )
                iprintlnbold( "BUG: There is something wrong with the team volumes" );

            if ( isdefined( level._meat_team_1_volume ) && level.item_meat istouching( level._meat_team_1_volume ) )
            {
                level._meat_on_team = 1;
                level.meat_lost_time = undefined;
            }
            else if ( isdefined( level._meat_team_2_volume ) && level.item_meat istouching( level._meat_team_2_volume ) )
            {
                level._meat_on_team = 2;
                level.meat_lost_time = undefined;
            }
            else if ( isdefined( last_team ) )
            {
                if ( !isdefined( level.meat_lost_time ) )
                    level.meat_lost_time = gettime();
                else if ( gettime() - level.meat_lost_time > level.meat_lost_time_limit )
                {
                    add_meat_event( "level_lost_meat" );
                    level thread item_meat_reset( level._meat_start_point, 1 );
                    level.meat_lost_time = undefined;

                    level waittill( "meat_grabbed" );
                }
            }
        }
        else
        {
            player_with_meat = get_player_with_meat();

            if ( !isdefined( player_with_meat ) )
            {
                if ( !isdefined( level.meat_lost_time ) )
                    level.meat_lost_time = gettime();
                else if ( gettime() - level.meat_lost_time > level.meat_lost_time_limit )
                {
                    add_meat_event( "level_lost_meat" );
                    level thread item_meat_reset( level._meat_start_point, 1 );
                    level.meat_lost_time = undefined;

                    level waittill( "meat_grabbed" );
                }
            }
            else
                level.meat_lost_time = undefined;
        }

        if ( isdefined( level._meat_on_team ) && isdefined( last_team ) && level._meat_on_team != last_team )
        {
            level notify( "clear_ignore_all" );
            add_meat_event( "level_meat_team", level._meat_on_team );
            last_team = level._meat_on_team;
            assign_meat_to_team( undefined, level._meat_on_team );
/#
            if ( isdefined( level.item_meat ) )
                playfx( level._effect["spawn_cloud"], level.item_meat.origin );
#/
        }

        wait 0.05;
    }
}

item_meat_watch_for_throw()
{
    level endon( "meat_end" );

    for (;;)
    {
        level waittill( "meat_thrown", who );

        add_meat_event( "player_thrown", who );

        if ( isdefined( who._spawning_meat ) && who._spawning_meat )
            continue;

        if ( randomintrange( 1, 101 ) <= 10 )
        {

        }

        who._has_meat = 0;

        if ( isdefined( who._has_meat_hud ) )
            who._has_meat_hud destroy();

        assign_meat_to_team( undefined, level._meat_on_team );
    }
}

hold_meat_monitor()
{
    level endon( "meat_end" );

    level waittill( "meat_grabbed" );

    while ( true )
    {
        player = get_player_with_meat();

        if ( !isdefined( player ) )
        {
            wait 0.2;
            continue;
        }

        if ( !should_try_to_bring_back_teammate( player._meat_team ) )
        {
            wait 0.2;
            continue;
        }

        if ( !( isdefined( player._bringing_back_teammate ) && player._bringing_back_teammate ) )
            player thread bring_back_teammate_progress();

        wait 0.2;
    }
}

meat_zombie_post_spawn_init()
{

}

create_item_meat_watcher()
{
    wait 0.05;
    watcher = self maps\mp\gametypes_zm\_weaponobjects::createuseweaponobjectwatcher( "item_meat", get_gamemode_var( "item_meat_name" ), self.team );
    watcher.pickup = ::item_meat_on_pickup;
    watcher.onspawn = ::item_meat_spawned;
    watcher.onspawnretrievetriggers = ::play_item_meat_on_spawn_retrieve_trigger;
    watcher.headicon = 0;
}

item_meat_spawned( unused0, unused1 )
{
    maps\mp\gametypes_zm\_weaponobjects::voidonspawn( unused0, unused1 );
    self.meat_is_moving = 0;
    self.meat_is_flying = 0;
}

wait_for_player_downed()
{
    self endon( "disconnect" );

    while ( isdefined( self ) )
    {
        self waittill_any( "player_downed", "fake_death", "death" );
        add_meat_event( "player_down", self );
        wait 0.1;

        if ( isdefined( self._meat_team ) )
        {
            self thread watch_save_player();
            players = get_players_on_meat_team( self._meat_team );

            if ( players.size >= 2 )
            {

            }
        }
    }
}

item_meat_watch_stationary()
{
    self endon( "death" );
    self endon( "picked_up" );
    self.meat_is_moving = 1;

    self waittill( "stationary" );

    self playloopsound( "zmb_meat_looper", 2 );

    if ( !( isdefined( self._fake_meat ) && self._fake_meat ) )
        add_meat_event( "meat_stationary", self );
    else
        add_meat_event( "fake_meat_stationary", self );

    if ( !( isdefined( self._fake_meat ) && self._fake_meat ) )
    {
        level._meat_moving = 0;
        level._meat_splitter_activated = 0;
        level._last_person_to_throw_meat = undefined;
    }

    self.meat_is_moving = 0;

    if ( isdefined( level._meat_on_team ) )
    {
        teamplayers = get_players_on_meat_team( level._meat_on_team );

        for ( i = 0; i < teamplayers.size; i++ )
        {
            if ( isdefined( teamplayers[i] ) && isdefined( teamplayers[i]._encounters_team ) )
            {
                level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "meat_land", teamplayers[i]._encounters_team );
                break;
            }
        }
    }
}

item_meat_watch_bounce()
{
    self endon( "death" );
    self endon( "picked_up" );
    self.meat_is_flying = 1;

    self waittill( "grenade_bounce", pos, normal, ent );

    if ( !( isdefined( self._fake_meat ) && self._fake_meat ) )
        add_meat_event( "meat_bounce", self, pos, normal, ent );
    else
        add_meat_event( "fake_meat_bounce", self, pos, normal, ent );

    if ( isdefined( level.meat_bounce_override ) )
    {
        self thread [[ level.meat_bounce_override ]]( pos, normal, ent );
        return;
    }

    if ( isdefined( level.spawned_collmap ) )
    {
        if ( isdefined( ent ) && ent == level.spawned_collmap )
            playfx( level._effect["meat_bounce"], pos, normal );
    }

    if ( isdefined( ent ) && isplayer( ent ) )
    {
        add_meat_event( "player_hit_player", self.owner, ent );
        self.owner hit_player_with_meat( ent );
    }

    self.meat_is_flying = 0;
    self thread watch_for_roll();
    playfxontag( level._effect["meat_marker"], self, "tag_origin" );
}

watch_for_roll()
{
    self endon( "stationary" );
    self endon( "death" );
    self endon( "picked_up" );
    self.meat_is_rolling = 0;

    while ( true )
    {
        old_z = self.origin[2];
        wait 1;

        if ( abs( old_z - self.origin[2] ) < 10 )
        {
            self.meat_is_rolling = 1;
            self playloopsound( "zmb_meat_looper", 2 );
        }
    }
}

stop_rolling()
{
    self.origin = self.origin;
    self.angles = self.angles;
}

hit_player_with_meat( hit_player )
{
/#
    println( "MEAT: Player " + self.name + " hit " + hit_player.name + " with the meat\\n" );
#/
}

item_meat_pickup()
{
    self.meat_is_moving = 0;
    self.meat_is_flying = 0;
    level._meat_moving = 0;
    level._meat_splitter_activated = 0;
    self notify( "picked_up" );
}

player_wait_take_meat( meat_name )
{
    self.dont_touch_the_meat = 1;

    if ( isdefined( self.pre_meat_weapon ) && self hasweapon( self.pre_meat_weapon ) )
        self switchtoweapon( self.pre_meat_weapon );
    else
    {
        primaryweapons = self getweaponslistprimaries();

        if ( isdefined( primaryweapons ) && primaryweapons.size > 0 )
            self switchtoweapon( primaryweapons[0] );
        else
        {
/#
            assert( 0, "Player has no weapon" );
#/
            self maps\mp\zombies\_zm_weapons::give_fallback_weapon();
        }
    }

    self waittill_notify_or_timeout( "weapon_change_complete", 3 );
    self takeweapon( meat_name );
    self.pre_meat_weapon = undefined;

    if ( self.is_drinking )
        self decrement_is_drinking();

    self.dont_touch_the_meat = 0;
}

cleanup_meat()
{
    if ( isdefined( self.altmodel ) )
        self.altmodel delete();

    self delete();
}

init_animtree()
{
    scriptmodelsuseanimtree( -1 );
}

#using_animtree("zombie_meat");

animate_meat( grenade )
{
    grenade waittill_any( "bounce", "stationary", "death" );
    waittillframeend;

    if ( isdefined( grenade ) )
    {
        grenade hide();
        altmodel = spawn( "script_model", grenade.origin );
        altmodel setmodel( get_gamemode_var( "item_meat_model" ) );
        altmodel useanimtree( -1 );
        altmodel.angles = grenade.angles;
        altmodel linkto( grenade, "", ( 0, 0, 0 ), ( 0, 0, 0 ) );
        altmodel setanim( %o_zombie_head_idle_v1 );
        grenade.altmodel = altmodel;

        while ( isdefined( grenade ) )
            wait 0.05;

        if ( isdefined( altmodel ) )
            altmodel delete();
    }
}

indexinarray( array, value )
{
    if ( !isdefined( array ) || !isarray( array ) || !isdefined( value ) || !isinarray( array, value ) )
        return undefined;

    foreach ( index, item in array )
    {
        if ( item == value )
            return index;
    }

    return undefined;
}

item_meat_on_spawn_retrieve_trigger( watcher, player, weaponname )
{
    self endon( "death" );
    add_meat_event( "meat_spawn", self );
    thread animate_meat( self );

    while ( isdefined( level.splitting_meat ) && level.splitting_meat )
        wait 0.15;

    if ( isdefined( player ) )
    {
        self setowner( player );
        self setteam( player.pers["team"] );
        self.owner = player;
        self.oldangles = self.angles;

        if ( player hasweapon( weaponname ) )
        {
            if ( !( isdefined( self._fake_meat ) && self._fake_meat ) )
                player thread player_wait_take_meat( weaponname );
            else
            {
                player takeweapon( weaponname );
                player decrement_is_drinking();
            }
        }

        if ( !( isdefined( self._fake_meat ) && self._fake_meat ) )
        {
            if ( !( isdefined( self._respawned_meat ) && self._respawned_meat ) )
            {
                level notify( "meat_thrown", player );
                level._last_person_to_throw_meat = player;
                level._last_person_to_throw_meat_time = gettime();
            }
        }
    }

    if ( !( isdefined( self._fake_meat ) && self._fake_meat ) )
    {
        level._meat_moving = 1;

        if ( isdefined( level.item_meat ) && level.item_meat != self )
            level.item_meat cleanup_meat();

        level.item_meat = self;
    }

    self thread item_meat_watch_stationary();
    self thread item_meat_watch_bounce();
    self.item_meat_pick_up_trigger = spawn( "trigger_radius_use", self.origin, 0, 36, 72 );
    self.item_meat_pick_up_trigger setcursorhint( "HINT_NOICON" );
    self.item_meat_pick_up_trigger sethintstring( &"ZOMBIE_MEAT_PICKUP" );
    self.item_meat_pick_up_trigger enablelinkto();
    self.item_meat_pick_up_trigger linkto( self );
    self.item_meat_pick_up_trigger triggerignoreteam();
    level.item_meat_pick_up_trigger = self.item_meat_pick_up_trigger;
    self thread item_meat_watch_shutdown();
    self.meat_id = indexinarray( level._fake_meats, self );

    if ( !isdefined( self.meat_id ) )
        self.meat_id = 0;

    if ( isdefined( level.dont_allow_meat_interaction ) && level.dont_allow_meat_interaction )
        self.item_meat_pick_up_trigger setinvisibletoall();
    else
    {
        self thread item_meat_watch_trigger( self.meat_id, self.item_meat_pick_up_trigger, ::item_meat_on_pickup, level.meat_pickupsoundplayer, level.meat_pickupsound );
        self thread kick_meat_monitor();
        self thread last_stand_meat_nudge();
    }

    self._respawned_meat = undefined;
}

last_stand_meat_nudge()
{
    level endon( "meat_grabbed" );
    level endon( "end_meat" );
    self endon( "death" );
    wait 0.15;

    while ( true )
    {
        players = get_players();

        foreach ( player in players )
        {
            if ( distancesquared( player.origin, self.origin ) < 2304 && player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
                player thread kick_the_meat( self, 1 );
        }

        wait 0.05;
    }
}

kick_meat_monitor()
{
    level endon( "meat_grabbed" );
    level endon( "end_meat" );
    self endon( "death" );
    kick_meat_timeout = 150;

    while ( true )
    {
        players = get_players();
        curr_time = gettime();

        foreach ( player in players )
        {
            if ( isdefined( level._last_person_to_throw_meat ) && player == level._last_person_to_throw_meat && curr_time - level._last_person_to_throw_meat_time <= kick_meat_timeout )
                continue;

            if ( distancesquared( player.origin, self.origin ) < 2304 && player issprinting() && !player usebuttonpressed() )
            {
                if ( isdefined( player._meat_team ) && isdefined( level._meat_on_team ) && level._meat_on_team == player._meat_team )
                {
                    add_meat_event( "player_kick_meat", player, self );
                    player thread kick_the_meat( self );
                }
            }
        }

        wait 0.05;
    }
}

is_meat( weapon )
{
    return weapon == get_gamemode_var( "item_meat_name" );
}

spike_the_meat( meat )
{
    if ( isdefined( self._kicking_meat ) && self._kicking_meat )
        return;

    fake_meat = 0;
    self._kicking_meat = 1;
    self._spawning_meat = 1;
    org = self getweaponmuzzlepoint();
    vel = meat getvelocity();

    if ( !( isdefined( meat._fake_meat ) && meat._fake_meat ) )
    {
        meat cleanup_meat();
        level._last_person_to_throw_meat = self;
        level._last_person_to_throw_meat_time = gettime();
        level._meat_splitter_activated = 0;
    }
    else
    {
        fake_meat = 1;
        meat cleanup_meat();
    }

    kickangles = self.angles;
    kickangles += ( randomfloatrange( -30, -20 ), randomfloatrange( -5, 5 ), 0 );
    launchdir = anglestoforward( kickangles );
    speed = length( vel ) * 1.5;
    launchvel = vectorscale( launchdir, speed );
    grenade = self magicgrenadetype( get_gamemode_var( "item_meat_name" ), org, ( launchvel[0], launchvel[1], 380 ) );
    grenade playsound( "zmb_meat_meat_tossed" );
    grenade thread waittill_loopstart();

    if ( fake_meat )
    {
        grenade._fake_meat = 1;
        grenade thread delete_on_real_meat_pickup();
        level._kicked_meat = grenade;
    }

    wait 0.1;
    self._spawning_meat = 0;
    self._kicking_meat = 0;

    if ( !fake_meat )
    {
        level notify( "meat_thrown", self );
        level notify( "meat_kicked" );
    }
}

show_meat_throw_hint()
{
    level endon( "meat_thrown" );
    self endon( "player_downed" );
    self thread meat_screen_message_delete_on_death();
    wait 1;
    self meat_create_hint_message( &"ZOMBIE_THROW_MEAT_HINT" );
    self thread meat_screen_message_delete();
}

meat_create_hint_message( string_message_1, string_message_2, string_message_3, n_offset_y )
{
    if ( !isdefined( n_offset_y ) )
        n_offset_y = 0;

    if ( !isdefined( self._screen_message_1 ) )
    {
        self._screen_message_1 = newclienthudelem( self );
        self._screen_message_1.elemtype = "font";
        self._screen_message_1.font = "objective";
        self._screen_message_1.fontscale = 1.8;
        self._screen_message_1.horzalign = "center";
        self._screen_message_1.vertalign = "middle";
        self._screen_message_1.alignx = "center";
        self._screen_message_1.aligny = "middle";
        self._screen_message_1.y = -60 + n_offset_y;
        self._screen_message_1.sort = 2;
        self._screen_message_1.color = ( 1, 1, 1 );
        self._screen_message_1.alpha = 0.7;
        self._screen_message_1.hidewheninmenu = 1;
    }

    self._screen_message_1 settext( string_message_1 );

    if ( isdefined( string_message_2 ) )
    {
        if ( !isdefined( self._screen_message_2 ) )
        {
            self._screen_message_2 = newclienthudelem( self );
            self._screen_message_2.elemtype = "font";
            self._screen_message_2.font = "objective";
            self._screen_message_2.fontscale = 1.8;
            self._screen_message_2.horzalign = "center";
            self._screen_message_2.vertalign = "middle";
            self._screen_message_2.alignx = "center";
            self._screen_message_2.aligny = "middle";
            self._screen_message_2.y = -33 + n_offset_y;
            self._screen_message_2.sort = 2;
            self._screen_message_2.color = ( 1, 1, 1 );
            self._screen_message_2.alpha = 0.7;
            self._screen_message_2.hidewheninmenu = 1;
        }

        level._screen_message_2 settext( string_message_2 );
    }
    else if ( isdefined( self._screen_message_2 ) )
        self._screen_message_2 destroy();

    if ( isdefined( string_message_3 ) )
    {
        if ( !isdefined( self._screen_message_3 ) )
        {
            self._screen_message_3 = newclienthudelem( self );
            self._screen_message_3.elemtype = "font";
            self._screen_message_3.font = "objective";
            self._screen_message_3.fontscale = 1.8;
            self._screen_message_3.horzalign = "center";
            self._screen_message_3.vertalign = "middle";
            self._screen_message_3.alignx = "center";
            self._screen_message_3.aligny = "middle";
            self._screen_message_3.y = -6 + n_offset_y;
            self._screen_message_3.sort = 2;
            self._screen_message_3.color = ( 1, 1, 1 );
            self._screen_message_3.alpha = 0.7;
            self._screen_message_3.hidewheninmenu = 1;
        }

        self._screen_message_3 settext( string_message_3 );
    }
    else if ( isdefined( self._screen_message_3 ) )
        self._screen_message_3 destroy();
}

meat_screen_message_delete()
{
    self endon( "disconnect" );
    level waittill_notify_or_timeout( "meat_thrown", 5 );

    if ( isdefined( self._screen_message_1 ) )
        self._screen_message_1 destroy();

    if ( isdefined( self._screen_message_2 ) )
        self._screen_message_2 destroy();

    if ( isdefined( self._screen_message_3 ) )
        self._screen_message_3 destroy();
}

meat_screen_message_delete_on_death()
{
    level endon( "meat_thrown" );
    self endon( "disconnect" );

    self waittill( "player_downed" );

    if ( isdefined( self._screen_message_1 ) )
        self._screen_message_1 destroy();

    if ( isdefined( self._screen_message_2 ) )
        self._screen_message_2 destroy();

    if ( isdefined( self._screen_message_3 ) )
        self._screen_message_3 destroy();
}

set_ignore_all()
{
    level endon( "clear_ignore_all" );

    if ( isdefined( level._zombies_ignoring_all ) && level._zombies_ignoring_all )
        return;

    level._zombies_ignoring_all = 1;
    zombies = getaiarray( level.zombie_team );

    foreach ( zombie in zombies )
    {
        if ( isdefined( zombie ) )
            zombie.ignoreall = 1;
    }

    wait 0.5;
    clear_ignore_all();
}

clear_ignore_all()
{
    if ( !( isdefined( level._zombies_ignoring_all ) && level._zombies_ignoring_all ) )
        return;

    zombies = getaiarray( level.zombie_team );

    foreach ( zombie in zombies )
    {
        if ( isdefined( zombie ) )
            zombie.ignoreall = 0;
    }

    level._zombies_ignoring_all = 0;
}

bring_back_teammate_progress()
{
    self notify( "bring_back_teammate_progress" );
    self endon( "bring_back_teammate_progress" );
    self endon( "disconnect" );
    player = self;
    player._bringing_back_teammate = 1;
    revivetime = 15;
    progress = 0;

    while ( player_has_meat( player ) && is_player_valid( player ) && progress >= 0 )
    {
        if ( !isdefined( player.revive_team_progressbar ) )
        {
            player.revive_team_progressbar = player createprimaryprogressbar();
            player.revive_team_progressbar updatebar( 0.01, 1 / revivetime );
            player.revive_team_progressbar.progresstext = player createprimaryprogressbartext();
            player.revive_team_progressbar.progresstext settext( &"ZOMBIE_MEAT_RESPAWN_TEAMMATE" );
            player thread destroy_revive_progress_on_downed();
        }

        progress++;

        if ( progress > revivetime * 10 )
        {
            level bring_back_dead_teammate( player._meat_team );
            player destroy_revive_progress();
            wait 1;
            player._bringing_back_teammate = 0;
            progress = -1;
        }

        wait 0.1;
    }

    player._bringing_back_teammate = 0;
    player destroy_revive_progress();
}

should_try_to_bring_back_teammate( team )
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i]._meat_team == team && players[i].sessionstate == "spectator" )
            return true;
    }

    return false;
}

bring_back_dead_teammate( team )
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i]._meat_team == team && players[i].sessionstate == "spectator" )
        {
            player = players[i];
            break;
        }
    }

    if ( !isdefined( player ) )
        return;

    player playsound( level.zmb_laugh_alias );
    wait 0.25;
    playfx( level._effect["poltergeist"], player.spectator_respawn.origin );
    playsoundatposition( "zmb_bolt", player.spectator_respawn.origin );
    earthquake( 0.5, 0.75, player.spectator_respawn.origin, 1000 );
    level.custom_spawnplayer = ::respawn_meat_player;
    player.pers["spectator_respawn"] = player.spectator_respawn;
    player [[ level.spawnplayer ]]();
    level.custom_spawnplayer = undefined;
}

respawn_meat_player()
{
    spawnpoint = self maps\mp\gametypes_zm\_globallogic_score::getpersstat( "meat_spectator_respawn" );
    self spawn( spawnpoint.origin, spawnpoint.angles );
    self._meat_team = self.pers["zteam"];
    self._encounters_team = self.pers["encounters_team"];
    self.characterindex = self.pers["characterindex"];
    self._team_name = self.pers["team_name"];
    self.spectator_respawn = self.pers["meat_spectator_respawn"];
    self reviveplayer();
    self.is_burning = 0;
    self.is_zombie = 0;
    self.ignoreme = 0;
}

destroy_revive_progress_on_downed()
{
    level endon( "end_game" );
    level endon( "meat_end" );
    self waittill_any( "fake_death", "player_downed", "death" );
    self destroy_revive_progress();
}

destroy_revive_progress()
{
    if ( isdefined( self.revive_team_progressbar ) )
    {
        self.revive_team_progressbar destroyelem();
        self.revive_team_progressbar.progresstext destroyelem();
    }
}

kick_the_meat( meat, laststand_nudge )
{
    if ( isdefined( self._kicking_meat ) && self._kicking_meat )
        return;

    fake_meat = 0;
    self._kicking_meat = 1;
    self._spawning_meat = 1;
    org = meat.origin;

    if ( !( isdefined( meat._fake_meat ) && meat._fake_meat ) )
    {
        meat cleanup_meat();
        level._last_person_to_throw_meat = self;
        level._last_person_to_throw_meat_time = gettime();
        level._meat_splitter_activated = 0;
    }
    else
    {
        fake_meat = 1;
        meat cleanup_meat();
    }

    kickangles = self.angles;
    kickangles += ( randomfloatrange( -30, -20 ), randomfloatrange( -5, 5 ), 0 );
    launchdir = anglestoforward( kickangles );
    vel = self getvelocity();
    speed = length( vel ) * 1.5;
    height_boost = 380;

    if ( isdefined( laststand_nudge ) && laststand_nudge )
    {
        if ( vel == ( 0, 0, 0 ) )
            vel = ( 30, 30, 5 );

        speed = length( vel ) * 2;
        height_boost = 120;
    }

    launchvel = vectorscale( launchdir, speed );
    grenade = self magicgrenadetype( get_gamemode_var( "item_meat_name" ), org, ( launchvel[0], launchvel[1], height_boost ) );
    grenade playsound( "zmb_meat_meat_tossed" );
    grenade thread waittill_loopstart();

    if ( fake_meat )
    {
        grenade._fake_meat = 1;
        grenade thread delete_on_real_meat_pickup();
        level._kicked_meat = grenade;
    }

    wait 0.1;
    self._spawning_meat = 0;
    self._kicking_meat = 0;

    if ( !fake_meat )
    {
        level notify( "meat_thrown", self );
        level notify( "meat_kicked" );
    }
}

delete_on_real_meat_pickup()
{
    if ( !( isdefined( self._fake_meat ) && self._fake_meat ) )
        return;

    self endon( "death" );
    level waittill_any( "meat_grabbed", "end_game", "meat_kicked" );
    add_meat_event( "fake_meat_killed_by_real", self );

    if ( isdefined( level._kicked_meat ) && level._kicked_meat == self )
        level._kicked_meat = undefined;

    if ( isdefined( self ) )
        self cleanup_meat();
}

play_item_meat_on_spawn_retrieve_trigger( watcher, player )
{
    self item_meat_on_spawn_retrieve_trigger( watcher, player, get_gamemode_var( "item_meat_name" ) );
}

can_revive( revivee )
{
    if ( self hasweapon( get_gamemode_var( "item_meat_name" ) ) )
        return false;

    if ( !self maps\mp\zombies\_zm_laststand::is_reviving_any() && isdefined( level.item_meat_pick_up_trigger ) && self istouching( level.item_meat_pick_up_trigger ) )
        return false;

    return true;
}

pickup_origin()
{
    origin = self get_eye();

    if ( !isdefined( origin ) )
        origin = self gettagorigin( "tag_weapon" );

    if ( !isdefined( origin ) )
        origin = self gettagorigin( "tag_weapon_right" );

    if ( !isdefined( origin ) )
        origin = self.origin;

    return origin;
}

can_spike_meat()
{
    if ( isdefined( level._last_person_to_throw_meat ) && self == level._last_person_to_throw_meat )
        return false;

    meat = level.item_meat;
    meat_spike_dist_sq = 4096;
    meat_spike_dot = 0.1;

    if ( isdefined( meat ) )
    {
        view_pos = self getweaponmuzzlepoint();

        if ( distancesquared( view_pos, meat.origin ) < meat_spike_dist_sq )
            return true;
    }

    return false;
}

start_encounters_round_logic()
{
    if ( isdefined( level.flag["start_zombie_round_logic"] ) )
        flag_wait( "start_zombie_round_logic" );

    flag_wait( "initial_players_connected" );

    if ( !flag( "start_encounters_match_logic" ) )
        flag_set( "start_encounters_match_logic" );
}

onstartgametype()
{
    thread start_encounters_round_logic();
    maps\mp\gametypes_zm\_zm_gametype::rungametypemain( "zmeat", ::meat_hub_start_func, 1 );
}

hide_non_meat_objects()
{
    door_trigs = getentarray( "zombie_door", "targetname" );

    for ( i = 0; i < door_trigs.size; i++ )
    {
        if ( isdefined( door_trigs[i] ) )
            door_trigs[i] delete();
    }

    objects = getentarray();

    for ( i = 0; i < objects.size; i++ )
    {
        if ( objects[i] is_meat_object() )
            continue;

        if ( objects[i] iszbarrier() )
            continue;

        if ( isdefined( objects[i].spawnflags ) && objects[i].spawnflags == 1 )
            objects[i] connectpaths();

        objects[i] notsolid();
        objects[i] hide();
    }
}

is_meat_object()
{
    if ( !isdefined( self.script_parameters ) )
        return true;

    tokens = strtok( self.script_parameters, " " );

    for ( i = 0; i < tokens.size; i++ )
    {
        if ( tokens[i] == "meat_remove" )
            return false;
    }

    return true;
}

setup_meat_world_objects()
{
    objects = getentarray( level.scr_zm_map_start_location, "script_noteworthy" );

    for ( i = 0; i < objects.size; i++ )
    {
        if ( !objects[i] is_meat_object() )
            continue;

        if ( isdefined( objects[i].script_gameobjectname ) )
            continue;

        if ( isdefined( objects[i].script_vector ) )
        {
            objects[i] moveto( objects[i].origin + objects[i].script_vector, 0.05 );

            objects[i] waittill( "movedone" );
        }

        if ( isdefined( objects[i].spawnflags ) && objects[i].spawnflags == 1 && !( isdefined( level._dont_reconnect_paths ) && level._dont_reconnect_paths ) )
            objects[i] disconnectpaths();
    }

    level clientnotify( "meat_" + level.scr_zm_map_start_location );
}

spawn_meat_zombies()
{
    level endon( "meat_end" );
    force_riser = 0;
    force_chaser = 0;
    num = 0;
    max_ai_num = 15;

    if ( getdvarint( _hash_CD22CF55 ) > 0 )
        max_ai_num = 0;

    if ( getdvarint( _hash_FA81816F ) == 2 )
        max_ai_num = -1;

    level waittill( "meat_grabbed" );

    while ( true )
    {
        ai = getaiarray( level.zombie_team );

        if ( ai.size > max_ai_num )
            wait 0.1;
        else
        {
            if ( num % 2 == 0 )
                spawn_points = level._meat_team_1_zombie_spawn_points;
            else
                spawn_points = level._meat_team_2_zombie_spawn_points;

            num++;
            spawn_point = undefined;
            dist = 512;
            distcheck = dist * dist;
            startindex = randomint( spawn_points.size );

            while ( !isdefined( spawn_point ) )
            {
                for ( i = 0; i < spawn_points.size; i++ )
                {
                    index = ( startindex + i ) % spawn_points.size;
                    point = spawn_points[index];

                    if ( num % 2 == 0 )
                        players = get_players_on_meat_team( 1 );
                    else
                        players = get_players_on_meat_team( 2 );

                    clear = 1;

                    foreach ( player in players )
                    {
                        if ( distancesquared( player.origin, point.origin ) < distcheck )
                            clear = 0;
                    }

                    if ( clear )
                    {
                        spawn_point = point;
                        break;
                    }
                }

                if ( dist <= 128 )
                    spawn_point = point;
                else
                {
                    dist /= 4;
                    distcheck = dist * dist;
                }

                wait 0.05;
            }

            zombie = spawn_meat_zombie( level.meat_spawners[0], "meat_zombie", spawn_point, level._meat_zombie_spawn_health );

            if ( isdefined( zombie ) )
                zombie maps\mp\zombies\_zm_game_module::make_supersprinter();
        }

        wait( level._meat_zombie_spawn_timer );
    }
}

spawn_meat_zombie( spawner, target_name, spawn_point, round_number )
{
    level endon( "meat_end" );

    if ( !isdefined( spawner ) )
    {
        iprintlnbold( "BUG: There is something wrong with the zombie spawners" );
        return;
    }

    while ( isdefined( level._meat_zombie_spawning ) && level._meat_zombie_spawning )
        wait 0.05;

    level._meat_zombie_spawning = 1;
    level.zombie_spawn_locations = [];
    level.zombie_spawn_locations[level.zombie_spawn_locations.size] = spawn_point;
    zombie = maps\mp\zombies\_zm_utility::spawn_zombie( spawner, target_name, spawn_point, round_number );

    if ( isdefined( zombie ) )
    {
        zombie thread maps\mp\zombies\_zm_spawner::zombie_spawn_init();
        zombie thread maps\mp\zombies\_zm::round_spawn_failsafe();
    }
    else
        iprintlnbold( "BUG: There is something wrong with the zombie spawning" );

    spawner._spawning = undefined;
    level._meat_zombie_spawning = 0;
    return zombie;
}

monitor_meat_on_team()
{
    level endon( "meat_end" );

    while ( true )
    {
        players = get_players();

        if ( isdefined( level._meat_on_team ) )
        {
            for ( i = 0; i < players.size; i++ )
            {
                if ( !isdefined( players[i] ) )
                    continue;

                if ( players[i]._meat_team == level._meat_on_team )
                {
                    if ( players[i].ignoreme )
                        players[i].ignoreme = 0;
                }
                else if ( !players[i].ignoreme )
                    players[i].ignoreme = 1;

                wait 0.05;
            }
        }
        else
        {
            for ( i = 0; i < players.size; i++ )
            {
                if ( !isdefined( players[i] ) )
                    continue;

                if ( players[i].ignoreme )
                    players[i].ignoreme = 0;

                wait 0.05;
            }
        }

        wait 0.1;
    }
}

item_meat_reset( origin, immediate )
{
    level notify( "new_meat" );
    level endon( "new_meat" );

    if ( isdefined( level.item_meat ) )
    {
        level.item_meat cleanup_meat();
        level.item_meat = undefined;
    }

    if ( !( isdefined( immediate ) && immediate ) )
        level waittill( "reset_meat" );

    item_meat_clear();

    if ( isdefined( origin ) )
        item_meat_spawn( origin );
}

meat_player_initial_spawn()
{
    players = get_players();
    one = 1;
    two = 2;

    if ( get_game_var( "switchedsides" ) )
    {
        one = 2;
        two = 1;
    }

    for ( i = 0; i < players.size; i++ )
    {
        if ( get_game_var( "side_selection" ) == 1 )
        {
            if ( players[i].team == "allies" )
                players[i]._meat_team = one;
            else
                players[i]._meat_team = two;
        }
        else if ( players[i].team == "allies" )
            players[i]._meat_team = two;
        else
            players[i]._meat_team = one;

        if ( isdefined( level.custom_player_fake_death_cleanup ) )
            players[i] [[ level.custom_player_fake_death_cleanup ]]();

        players[i] setstance( "stand" );

        if ( isdefined( players[i]._meat_team ) )
        {
            if ( players[i]._meat_team == one )
                players[i]._meat_team = one;
            else
                players[i]._meat_team = two;
        }
        else if ( players[i].team == "axis" )
            players[i]._meat_team = one;
        else
            players[i]._meat_team = two;

        players[i] meat_player_setup();
    }

    waittillframeend;
    maps\mp\gametypes_zm\_zm_gametype::start_round();
    award_grenades_for_team( 1 );
    award_grenades_for_team( 2 );
}

meat_player_setup()
{
    self.pers["zteam"] = self._meat_team;
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "encounters_team", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "characterindex", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "team_name", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "spectator_respawn", 0 );
    self.pers["encounters_team"] = self._encounters_team;
    self.pers["characterindex"] = self.characterindex;
    self.pers["team_name"] = self._team_name;
    self.pers["meat_spectator_respawn"] = self.spectator_respawn;
    self.score = 1000;
    self.pers["score"] = 1000;
    self takeallweapons();
    self giveweapon( "knife_zm" );
    self give_start_weapon( 1 );

    if ( !isdefined( self._saved_by_throw ) )
        self._saved_by_throw = 0;

    self setmovespeedscale( 1 );
    self._has_meat = 0;
    self setclientfield( "holding_meat", 0 );
    self freeze_player_controls( 1 );
}

can_touch_meat()
{
    if ( isdefined( self.dont_touch_the_meat ) && self.dont_touch_the_meat )
        return 0;

    meat = level.item_meat;

    if ( isdefined( meat ) )
    {
        meatorg = meat.origin + vectorscale( ( 0, 0, 1 ), 8.0 );
        trace = bullettrace( self pickup_origin(), meatorg, 0, meat );
        return distancesquared( trace["position"], meatorg ) < 1;
    }

    return 0;
}

trying_to_use()
{
    self.use_ever_released |= !self usebuttonpressed();
    return self.use_ever_released && self usebuttonpressed();
}

trying_to_spike( item )
{
    return item.meat_is_flying && self meleebuttonpressed();
}

item_quick_trigger( meat_id, trigger )
{
    self endon( "death" );
    meat_trigger_time = 150;

    if ( isdefined( trigger.radius ) )
        radius = trigger.radius + 15.0;
    else
        radius = 51.0;

    trigrad2 = radius * radius;
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];
        player.use_ever_released = !player usebuttonpressed();
    }

    while ( isdefined( trigger ) )
    {
        trigorg = trigger.origin;
        players = get_players();

        if ( players.size )
        {
            random_start_point = randomint( players.size );

            for ( i = 0; i < players.size; i++ )
            {
                player = players[( i + random_start_point ) % players.size];

                if ( !isdefined( player.trying_to_trigger_meat ) )
                    player.trying_to_trigger_meat = [];

                if ( !isdefined( player.trying_to_trigger_meat_time ) )
                    player.trying_to_trigger_meat_time = [];

                if ( player maps\mp\zombies\_zm_laststand::is_reviving_any() )
                    continue;

                meleeing = player ismeleeing();

                if ( isdefined( trigger ) && player istouching( trigger ) && distance2dsquared( player.origin, trigorg ) < trigrad2 && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() && ( player trying_to_use() || self.meat_is_flying && meleeing ) && player can_touch_meat() )
                {
                    if ( self.meat_is_flying && meleeing )
                    {
                        if ( player can_spike_meat() )
                        {
                            player.trying_to_trigger_meat[meat_id] = 0;
                            trigger notify( "usetrigger", player );
                        }
                    }
                    else if ( !( isdefined( player.trying_to_trigger_meat[meat_id] ) && player.trying_to_trigger_meat[meat_id] ) )
                    {
                        player.trying_to_trigger_meat[meat_id] = 1;
                        player.trying_to_trigger_meat_time[meat_id] = gettime();
                    }
                    else if ( gettime() - player.trying_to_trigger_meat_time[meat_id] >= meat_trigger_time )
                    {
                        player.trying_to_trigger_meat[meat_id] = 0;
                        trigger notify( "usetrigger", player );
                    }

                    continue;
                }

                player.trying_to_trigger_meat[meat_id] = 0;
                player.trying_to_trigger_meat_time[meat_id] = undefined;
            }
        }

        wait 0.05;
    }
}

item_meat_watch_trigger( meat_id, trigger, callback, playersoundonuse, npcsoundonuse )
{
    self endon( "death" );
    self thread item_quick_trigger( meat_id, trigger );

    while ( true )
    {
        trigger waittill( "usetrigger", player );

        if ( !isalive( player ) )
            continue;

        if ( !is_player_valid( player ) )
            continue;

        if ( player has_powerup_weapon() )
            continue;

        if ( player maps\mp\zombies\_zm_laststand::is_reviving_any() )
            continue;

        volley = self.meat_is_flying && player meleebuttonpressed();
        player.volley_meat = volley;

        if ( isdefined( self._fake_meat ) && self._fake_meat )
            add_meat_event( "player_fake_take", player, self );
        else if ( volley )
            add_meat_event( "player_volley", player, self );
        else if ( self.meat_is_moving )
            add_meat_event( "player_catch", player, self );
        else
            add_meat_event( "player_take", player, self );

        if ( isdefined( self._fake_meat ) && self._fake_meat )
        {
            player playlocalsound( level.zmb_laugh_alias );
            wait_network_frame();

            if ( !isdefined( self ) )
                return;

            self cleanup_meat();
            return;
        }

        curr_weap = player getcurrentweapon();

        if ( !is_meat( curr_weap ) )
            player.pre_meat_weapon = curr_weap;

        if ( self.meat_is_moving )
        {
            if ( volley )
                self item_meat_volley( player );
            else
                self item_meat_caught( player, self.meat_is_flying );
        }

        self item_meat_pickup();

        if ( isdefined( playersoundonuse ) )
            player playlocalsound( playersoundonuse );

        if ( isdefined( npcsoundonuse ) )
            player playsound( npcsoundonuse );

        if ( volley )
            player thread spike_the_meat( self );
        else
        {
            self thread [[ callback ]]( player );

            if ( !isdefined( player._meat_hint_shown ) )
            {
                player thread show_meat_throw_hint();
                player._meat_hint_shown = 1;
            }
        }
    }
}

item_meat_volley( player )
{
/#
    println( "MEAT: Spiked the meat\\n" );
#/
}

item_meat_caught( player, in_air )
{
    if ( in_air )
    {
/#
        println( "MEAT: Caught the meat on the fly\\n" );
#/
    }
    else
    {
/#
        println( "MEAT: Caught the meat while moving\\n" );
#/
    }
}

item_meat_on_pickup( player )
{
/#
    assert( !player maps\mp\zombies\_zm_laststand::player_is_in_laststand(), "Player in last stand triggered meat pickup" );
#/
    player maps\mp\gametypes_zm\_weaponobjects::deleteweaponobjecthelper( self );
    self cleanup_meat();
    level.item_meat = undefined;
    level._last_person_to_throw_meat = undefined;
    assign_meat_to_team( player );
    level notify( "meat_grabbed" );
    player notify( "meat_grabbed" );
    level thread zmbvoxmeatonteamspecific( player._encounters_team );

    if ( !player hasweapon( get_gamemode_var( "item_meat_name" ) ) )
        player giveweapon( get_gamemode_var( "item_meat_name" ) );

    player increment_is_drinking();
    player switchtoweapon( get_gamemode_var( "item_meat_name" ) );
    player setweaponammoclip( get_gamemode_var( "item_meat_name" ), 2 );
    player thread waittill_thrown();
}

waittill_thrown()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "reset_downed" );

    self waittill( "grenade_fire", grenade );

    grenade playsound( "zmb_meat_meat_tossed" );
    grenade thread waittill_loopstart();
}

waittill_loopstart()
{
    self endon( "stationary" );
    self endon( "death" );
    level endon( "meat_grabbed" );
    level endon( "end_game" );
    level endon( "meat_kicked" );

    while ( true )
    {
        self waittill( "grenade_bounce", pos, normal, ent );

        self stopsounds();
        wait 0.05;
        self playsound( "zmb_meat_bounce" );
    }
}

item_meat_watch_shutdown()
{
    self waittill( "death" );

    if ( isdefined( self.item_meat_pick_up_trigger ) )
    {
        self.item_meat_pick_up_trigger delete();
        level.item_meat_pick_up_trigger = undefined;
    }
}

item_meat_clear()
{
    if ( isdefined( level.item_meat ) )
    {
        level.item_meat cleanup_meat();
        level.item_meat = undefined;
    }

    if ( isdefined( level._fake_meats ) )
    {
        foreach ( meat in level._fake_meats )
        {
            if ( isdefined( meat ) )
                meat cleanup_meat();
        }

        level._fake_meats = undefined;
    }
}

zombie_path_timer_override()
{
    return gettime() + randomfloatrange( 0.35, 1 ) * 1000;
}

meat_poi_override_func()
{
    if ( isdefined( level.item_meat ) && ( isdefined( level.item_meat.meat_is_moving ) && level.item_meat.meat_is_moving ) )
    {
        if ( abs( level.item_meat.origin[2] - groundpos( level.item_meat.origin )[2] ) < 35 )
        {
            level._zombies_ignoring_all = 0;
            level notify( "clear_ignore_all" );
            return undefined;
        }

        level thread set_ignore_all();
        meat_poi = [];
        meat_poi[0] = groundpos( level.item_meat.origin );
        meat_poi[1] = level.item_meat;
        return meat_poi;
    }

    level._zombies_ignoring_all = 0;
    return undefined;
}

meat_end_match( winning_team )
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( isdefined( players[i].has_minigun ) && players[i].has_minigun )
        {
            primaryweapons = players[i] getweaponslistprimaries();

            for ( x = 0; x < primaryweapons.size; x++ )
            {
                if ( primaryweapons[x] == "minigun_zm" )
                    players[i] takeweapon( "minigun_zm" );
            }

            players[i] notify( "minigun_time_over" );
            players[i].zombie_vars["zombie_powerup_minigun_on"] = 0;
            players[i]._show_solo_hud = 0;
            players[i].has_minigun = 0;
            players[i].has_powerup_weapon = 0;
        }

        if ( isdefined( players[i]._has_meat_hud ) )
            players[i]._has_meat_hud destroy();

        if ( players[i] hasweapon( get_gamemode_var( "item_meat_name" ) ) )
        {
            players[i] takeweapon( get_gamemode_var( "item_meat_name" ) );
            players[i] decrement_is_drinking();
        }
    }

    level notify( "game_module_ended", winning_team );
    wait 0.1;
    level delay_thread( 2, ::item_meat_clear );

    if ( isdefined( level.gameended ) && level.gameended )
        level clientnotify( "end_meat" );
}

updatedownedcounters()
{
    if ( self._encounters_team == "A" )
    {
        level.team_a_downed++;
        self thread waitforrevive( "A" );
        level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "meat_revive_" + level.team_a_downed, "A" );
    }
    else
    {
        level.team_b_downed++;
        self thread waitforrevive( "B" );
        level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "meat_revive_" + level.team_b_downed, "B" );
    }
}

waitforrevive( team )
{
    self endon( "death" );

    self waittill( "player_revived" );

    if ( team == "A" )
        level.team_a_downed--;
    else
        level.team_b_downed--;
}

assign_meat_to_team( player, team_num )
{
    meat_team = undefined;
    players = get_players();

    if ( isdefined( player ) )
    {
        for ( i = 0; i < players.size; i++ )
        {
            if ( !isdefined( players[i] ) )
                continue;

            if ( players[i] != player || isdefined( player._meat_hint_shown ) && player._meat_hint_shown )
                players[i] iprintlnbold( &"ZOMBIE_GRABBED_MEAT", player.name );
        }

        meat_team = player._meat_team;
    }
    else if ( isdefined( team_num ) )
    {
        for ( i = 0; i < players.size; i++ )
        {
            if ( players[i]._meat_team == team_num )
            {
                players[i] iprintlnbold( &"ZOMBIE_YOUR_TEAM_MEAT" );
                continue;
            }

            players[i] iprintlnbold( &"ZOMBIE_OTHER_TEAM_MEAT" );
        }

        meat_team = team_num;
    }

    level._meat_on_team = meat_team;
    teamplayers = get_players_on_meat_team( meat_team );

    if ( isdefined( teamplayers ) && teamplayers.size > 0 )
    {
        if ( teamplayers[0]._encounters_team == "B" )
        {
            setteamhasmeat( "allies", 1 );
            setteamhasmeat( "axis", 0 );
        }
        else if ( teamplayers[0]._encounters_team == "A" )
        {
            setteamhasmeat( "allies", 0 );
            setteamhasmeat( "axis", 1 );
        }
    }

    for ( i = 0; i < players.size; i++ )
    {
        if ( !isdefined( players[i] ) )
            continue;

        if ( isdefined( player ) && players[i] == player )
        {
            if ( isdefined( players[i]._has_meat ) && players[i]._has_meat )
                continue;

            players[i]._has_meat = 1;
            players[i] thread slow_down_player_with_meat();
            players[i] thread reset_meat_when_player_downed();
            players[i] thread reset_meat_when_player_disconnected();
            continue;
        }
    }
}

zmbvoxmeatonteamspecific( team )
{
    if ( !isdefined( level.zmbvoxteamlasthadmeat ) )
        level.zmbvoxteamlasthadmeat = team;

    if ( level.zmbvoxteamlasthadmeat == team )
        return;

    level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "meat_grab", team );
    level.zmbvoxteamlasthadmeat = team;
    otherteam = maps\mp\zombies\_zm_audio_announcer::getotherteam( team );
    level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "meat_grab_" + otherteam, otherteam );
}

create_meat_team_hud( meat_team, destroy_only )
{
    if ( isdefined( self._has_meat_hud ) )
    {
        self._has_meat_hud destroy();

        if ( isdefined( destroy_only ) )
            return;
    }

    if ( !isdefined( meat_team ) )
        return;

    elem = newclienthudelem( self );
    elem.hidewheninmenu = 1;
    elem.horzalign = "LEFT";
    elem.vertalign = "BOTTOM";
    elem.alignx = "left";
    elem.aligny = "middle";
    elem.x = 10;
    elem.y = -10;
    elem.foreground = 1;
    elem.font = "default";
    elem.fontscale = 1.4;
    elem.color = vectorscale( ( 1, 1, 0 ), 0.9 );
    elem.alpha = 1.0;

    if ( isdefined( self._meat_team ) && self._meat_team == meat_team )
        elem.label = &"ZOMBIE_TEAM_HAS_MEAT";
    else
        elem.label = &"ZOMBIE_OTHER_TEAM_HAS_MEAT";

    self._has_meat_hud = elem;
}

create_meat_player_hud()
{
    if ( isdefined( self._has_meat_hud ) )
        self._has_meat_hud destroy();

    elem = newclienthudelem( self );
    elem.hidewheninmenu = 1;
    elem.horzalign = "LEFT";
    elem.vertalign = "BOTTOM";
    elem.alignx = "left";
    elem.aligny = "middle";
    elem.x = 10;
    elem.y = -10;
    elem.foreground = 1;
    elem.font = "default";
    elem.fontscale = 1.4;
    elem.color = vectorscale( ( 1, 1, 0 ), 0.9 );
    elem.alpha = 1.0;
    elem.label = &"ZOMBIE_PLAYER_HAS_MEAT";
    self._has_meat_hud = elem;
}

slow_down_player_with_meat()
{
    self endon( "disconnect" );
    self setclientfield( "holding_meat", 1 );
    self setmovespeedscale( 0.6 );
    self thread zmbvoxstartholdcounter();

    while ( isdefined( self._has_meat ) && self._has_meat )
    {
        level._meat_player_tracker_origin = self.origin;
        wait 0.2;
    }

    self setmovespeedscale( 1 );
    self setclientfield( "holding_meat", 0 );
}

zmbvoxstartholdcounter()
{
    for ( meat_hold_counter = 0; isdefined( self._has_meat ) && self._has_meat; meat_hold_counter++ )
    {
        if ( meat_hold_counter >= 15 )
        {
            self thread maps\mp\zombies\_zm_audio_announcer::leaderdialogonplayer( "meat_hold" );
            break;
        }

        wait 0.5;
    }
}

reset_meat_when_player_downed()
{
    self notify( "reset_downed" );
    self endon( "reset_downed" );
    level endon( "meat_reset" );
    level endon( "meat_thrown" );
    self waittill_any( "player_downed", "death", "fake_death", "replace_weapon_powerup" );
    self._has_meat = 0;
    self._spawning_meat = 1;
    grenade = self magicgrenadetype( get_gamemode_var( "item_meat_name" ), self.origin + ( randomintrange( 5, 10 ), randomintrange( 5, 10 ), 15 ), ( randomintrange( 5, 10 ), randomintrange( 5, 10 ), 0 ) );
    grenade._respawned_meat = 1;
    level._last_person_to_throw_meat = undefined;
    playsoundatposition( "zmb_spawn_powerup", self.origin );
    wait 0.1;
    self._spawning_meat = undefined;
    level notify( "meat_reset" );
}

meat_last_stand_callback( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
    if ( isdefined( self._has_meat ) && self._has_meat )
        level thread item_meat_drop( self.origin, self._meat_team );
}

reset_meat_when_player_disconnected()
{
    level endon( "meat_thrown" );
    level endon( "meat_reset" );
    level endon( "meat_end" );
    team = self._meat_team;

    self waittill( "disconnect" );

    level thread item_meat_drop( level._meat_player_tracker_origin, team );
}

item_meat_drop( org, team )
{
    players = get_alive_players_on_meat_team( team );

    if ( players.size > 0 )
    {
        player = players[0];
        player endon( "disconnect" );
        player._spawning_meat = 1;
        grenade = player magicgrenadetype( get_gamemode_var( "item_meat_name" ), org + ( randomintrange( 5, 10 ), randomintrange( 5, 10 ), 15 ), ( 0, 0, 0 ) );
        grenade._respawned_meat = 1;
        level._last_person_to_throw_meat = undefined;
        playsoundatposition( "zmb_spawn_powerup", grenade.origin );
        wait 0.1;
        player._spawning_meat = undefined;
        level notify( "meat_reset" );
    }
}

player_has_meat( player )
{
    return player getcurrentweapon() == get_gamemode_var( "item_meat_name" );
}

get_player_with_meat()
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( isdefined( players[i]._has_meat ) && players[i]._has_meat )
            return players[i];
    }

    return undefined;
}

spawn_player_meat_manager()
{
    self thread player_watch_weapon_change();
    self thread player_watch_grenade_throw();
}

player_watch_weapon_change()
{
    self endon( "death_or_disconnect" );

    for (;;)
    {
        self waittill( "weapon_change", weapon );

        if ( weapon == get_gamemode_var( "item_meat_name" ) )
        {
            add_meat_event( "player_meat", self );
            continue;
        }

        add_meat_event( "player_no_meat", self );
    }
}

player_watch_grenade_throw()
{
    self endon( "death_or_disconnect" );

    for (;;)
    {
        self waittill( "grenade_fire", weapon, weapname );

        if ( weapname == get_gamemode_var( "item_meat_name" ) )
        {
            add_meat_event( "player_grenade_fire", self, weapon );
            weapon thread item_meat_on_spawn_retrieve_trigger( undefined, self, get_gamemode_var( "item_meat_name" ) );
        }
    }
}

spawn_level_meat_manager()
{
/#
    level.meat_manager = spawnstruct();
    level.meat_manager.events = [];
    level.meat_manager thread handle_meat_events();
#/
}

add_meat_event( e, p1, p2, p3, p4 )
{
/#
    event = spawnstruct();
    event.e = e;
    event.numparams = 0;
    event.param = [];

    if ( isdefined( p1 ) )
    {
        event.param[0] = p1;
        event.numparams = 1;
    }

    if ( isdefined( p2 ) )
    {
        event.param[1] = p2;
        event.numparams = 2;
    }

    if ( isdefined( p3 ) )
    {
        event.param[2] = p3;
        event.numparams = 3;
    }

    if ( isdefined( p4 ) )
    {
        event.param[3] = p4;
        event.numparams = 4;
    }

    if ( isdefined( level.meat_manager ) )
        level.meat_manager.events[level.meat_manager.events.size] = event;
#/
}

handle_meat_events()
{
    while ( true )
    {
        while ( self.events.size )
        {
            self handle_meat_event( self.events[0] );
            arrayremoveindex( self.events, 0 );
        }

        wait 0.05;
    }
}

paramstr( param )
{
/#
    if ( !isdefined( param ) )
        return "undefined";

    if ( isplayer( param ) )
        return param.name;

    if ( isstring( param ) || isint( param ) || isfloat( param ) || isvec( param ) )
        return param;

    if ( isarray( param ) )
        return "[]";

    return "<other type>";
#/
}

handle_meat_event( event )
{
/#
    estr = "ZM MEAT: [" + event.e + "](";

    for ( i = 0; i < event.numparams; i++ )
    {
        estr += paramstr( event.param[i] );

        if ( i < event.numparams - 1 )
            estr += ",";
    }

    estr += ") \\n";
    println( estr );
#/
}
