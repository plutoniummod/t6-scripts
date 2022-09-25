// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zm_nuked_gamemodes;
#include maps\mp\zm_nuked_ffotd;
#include maps\mp\zm_nuked_fx;
#include maps\mp\zombies\_zm;
#include maps\mp\animscripts\zm_death;
#include maps\mp\zombies\_load;
#include maps\mp\teams\_teamset_cdc;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\zm_nuked_perks;
#include maps\mp\_sticky_grenade;
#include maps\mp\zombies\_zm_weap_tazer_knuckles;
#include maps\mp\zombies\_zm_weap_bowie;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_weap_ballistic_knife;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\animscripts\zm_run;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\_compass;

gamemode_callback_setup()
{
    maps\mp\zm_nuked_gamemodes::init();
}

survival_init()
{
    level.force_team_characters = 1;
    level.should_use_cia = 0;

    if ( randomint( 100 ) > 50 )
        level.should_use_cia = 1;

    level.precachecustomcharacters = ::precache_team_characters;
    level.givecustomcharacters = ::give_team_characters;
    flag_wait( "start_zombie_round_logic" );
}

zstandard_preinit()
{
    survival_init();
}

createfx_callback()
{
    ents = getentarray();

    for ( i = 0; i < ents.size; i++ )
    {
        if ( ents[i].classname != "info_player_start" )
            ents[i] delete();
    }
}

main()
{
    level thread maps\mp\zm_nuked_ffotd::main_start();
    level.level_createfx_callback_thread = ::createfx_callback;
    level.default_game_mode = "zstandard";
    level.default_start_location = "nuked";
    level.zombiemode_using_perk_intro_fx = 1;
    level.revive_machine_spawned = 0;
    level.riser_fx_on_client = 1;
    setup_rex_starts();
    maps\mp\zm_nuked_fx::main();
    maps\mp\zombies\_zm::init_fx();
    maps\mp\animscripts\zm_death::precache_gib_fx();
    level.zombiemode = 1;
    level._no_water_risers = 1;
    precachemodel( "p6_zm_nuked_rocket_cam" );
    precacheshellshock( "default" );
    precacherumble( "damage_light" );
    precachemodel( "collision_wall_128x128x10_standard" );
    precachemodel( "collision_player_256x256x10" );
    precachemodel( "collision_player_512x512x10" );
    precachemodel( "fx_axis_createfx" );
    maps\mp\zombies\_load::main();

    if ( getdvar( "createfx" ) == "1" )
        return;

    maps\mp\teams\_teamset_cdc::level_init();
    maps\mp\gametypes_zm\_spawning::level_use_unified_spawning( 1 );
    level.givecustomloadout = ::givecustomloadout;
    level.precachecustomcharacters = ::precache_team_characters;
    level.givecustomcharacters = ::give_team_characters;
    initcharacterstartindex();
    level.custom_player_fake_death = ::nuked_player_fake_death;
    level.custom_player_fake_death_cleanup = ::nuked_player_fake_death_cleanup;
    level.initial_round_wait_func = ::initial_round_wait_func;
    level.ignore_path_delays = 1;
    level.calc_closest_player_using_paths = 1;
    level.melee_miss_func = ::melee_miss_func;
    level.zombie_init_done = ::zombie_init_done;
    level._zombie_path_timer_override = ::zombie_path_timer_override;
    level.zombiemode_using_pack_a_punch = 1;
    level.zombiemode_reusing_pack_a_punch = 1;
    level.pap_interaction_height = 47;
    level.taser_trig_adjustment = ( -7, -2, 0 );
    level.zombiemode_using_doubletap_perk = 1;
    level.zombiemode_using_juggernaut_perk = 1;
    level.zombiemode_using_revive_perk = 1;
    level.zombiemode_using_sleightofhand_perk = 1;
    level.register_offhand_weapons_for_level_defaults_override = ::offhand_weapon_overrride;
    level.zombiemode_offhand_weapon_give_override = ::offhand_weapon_give_override;
    level._zombie_custom_add_weapons = ::custom_add_weapons;
    level._allow_melee_weapon_switching = 1;
    level.custom_ai_type = [];
    level.raygun2_included = 1;
    include_weapons();
    include_powerups();
    include_equipment_for_level();
    registerclientfield( "world", "zombie_eye_change", 4000, 1, "int" );
    maps\mp\zm_nuked_perks::init_nuked_perks();
    maps\mp\zombies\_zm::init();

    if ( level.splitscreen && getdvarint( "splitscreen_playerCount" ) > 2 )
    {

    }
    else
        level.custom_intermission = ::nuked_standard_intermission;

    level thread maps\mp\_sticky_grenade::init();
    maps\mp\zombies\_zm_weap_tazer_knuckles::init();
    maps\mp\zombies\_zm_weap_bowie::init();
    level.legacy_cymbal_monkey = 1;
    maps\mp\zombies\_zm_weap_cymbal_monkey::init();
    maps\mp\zombies\_zm_weap_claymore::init();
    maps\mp\zombies\_zm_weap_ballistic_knife::init();
    level.special_weapon_magicbox_check = ::nuked_special_weapon_magicbox_check;
    precacheitem( "death_throe_zm" );
    level.zones = [];
    level.zone_manager_init_func = ::nuked_zone_init;
    init_zones[0] = "culdesac_yellow_zone";
    init_zones[1] = "culdesac_green_zone";
    level thread maps\mp\zombies\_zm_zonemgr::manage_zones( init_zones );
    level.zombie_ai_limit = 24;
    level thread inermission_rocket_init();
    flag_init( "rocket_hit_nuketown" );
    flag_init( "moon_transmission_over" );

    if ( level.round_number == 1 && is_true( level.enable_magic ) && level.gamedifficulty != 0 )
    {
        level thread zombie_eye_glow_change();
        level thread switch_announcer_to_richtofen();
        level thread moon_transmission_vo();
        level thread marlton_vo_inside_bunker();
        level thread bus_random_horn();
    }

    level thread nuked_mannequin_init();
    level thread fake_lighting_cleanup();
    level thread bus_taser_blocker();
    level thread nuked_doomsday_clock_think();
    level thread nuked_population_sign_think();
    level thread maps\mp\zm_nuked_perks::perks_from_the_sky();
    level thread perks_behind_door();
    level.destructible_callbacks["headless"] = ::sndmusegg3_counter;
    level thread sndswitchannouncervox( "sam" );
    level thread sndgameend();

    if ( level.round_number == 1 && is_true( level.enable_magic ) && level.gamedifficulty != 0 )
        level thread sndmusiceastereggs();

    setdvar( "zombiemode_path_minz_bias", 28 );
    level.speed_change_round = 15;
    level.speed_change_max = 5;
    level thread nuked_update_traversals();
    level thread nuked_collision_patch();
    level thread maps\mp\zm_nuked_ffotd::main_end();
}

door_powerup_drop( powerup_name, drop_spot, powerup_team, powerup_location )
{
    if ( isdefined( level.door_powerup ) )
        level.door_powerup powerup_delete();

    powerup = maps\mp\zombies\_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_spot + vectorscale( ( 0, 0, 1 ), 40.0 ) );
    level notify( "powerup_dropped", powerup );

    if ( isdefined( powerup ) )
    {
        powerup.grabbed_level_notify = "magic_door_power_up_grabbed";
        powerup maps\mp\zombies\_zm_powerups::powerup_setup( powerup_name, powerup_team, powerup_location );
        powerup thread maps\mp\zombies\_zm_powerups::powerup_wobble();
        powerup thread maps\mp\zombies\_zm_powerups::powerup_grab( powerup_team );
        powerup thread maps\mp\zombies\_zm_powerups::powerup_move();
        level.door_powerup = powerup;
    }
}

perks_behind_door()
{
    if ( !( isdefined( level.enable_magic ) && level.enable_magic ) )
        return;

    level endon( "magic_door_power_up_grabbed" );
    flag_wait( "initial_blackscreen_passed" );
    door_perk_drop_list = [];
    door_perk_drop_list[0] = "nuke";
    door_perk_drop_list[1] = "double_points";
    door_perk_drop_list[2] = "insta_kill";
    door_perk_drop_list[3] = "fire_sale";
    door_perk_drop_list[4] = "full_ammo";
    index = 0;
    ammodrop = getstruct( "zm_nuked_ammo_drop", "script_noteworthy" );
    perk_type = door_perk_drop_list[index];
    index++;
    door_powerup_drop( perk_type, ammodrop.origin );

    while ( true )
    {
        level waittill( "nuke_clock_moved" );

        if ( index == door_perk_drop_list.size )
            index = 0;

        perk_type = door_perk_drop_list[index];
        index++;
        door_powerup_drop( perk_type, ammodrop.origin );
    }
}

nuked_doomsday_clock_think()
{
    min_hand_model = getent( "clock_min_hand", "targetname" );
    min_hand_model.position = 0;

    while ( true )
    {
        level waittill( "update_doomsday_clock" );

        level thread update_doomsday_clock( min_hand_model );
    }
}

update_doomsday_clock( min_hand_model )
{
    while ( is_true( min_hand_model.is_updating ) )
        wait 0.05;

    min_hand_model.is_updating = 1;

    if ( min_hand_model.position == 0 )
    {
        min_hand_model.position = 3;
        min_hand_model rotatepitch( -90, 1 );
        min_hand_model playsound( "zmb_clock_hand" );

        min_hand_model waittill( "rotatedone" );

        min_hand_model playsound( "zmb_clock_chime" );
    }
    else
    {
        min_hand_model.position--;
        min_hand_model rotatepitch( 30, 1 );
        min_hand_model playsound( "zmb_clock_hand" );

        min_hand_model waittill( "rotatedone" );
    }

    level notify( "nuke_clock_moved" );
    min_hand_model.is_updating = 0;
}

fall_down( vdir, stance )
{
    self endon( "disconnect" );
    level endon( "game_module_ended" );
    self ghost();
    origin = self.origin;
    xyspeed = ( 0, 0, 0 );
    angles = self getplayerangles();
    angles = ( angles[0], angles[1], angles[2] + randomfloatrange( -5, 5 ) );

    if ( isdefined( vdir ) && length( vdir ) > 0 )
    {
        xyspeedmag = 40 + randomint( 12 ) + randomint( 12 );
        xyspeed = xyspeedmag * vectornormalize( ( vdir[0], vdir[1], 0 ) );
    }

    linker = spawn( "script_origin", ( 0, 0, 0 ) );
    linker.origin = origin;
    linker.angles = angles;
    self._fall_down_anchor = linker;
    self playerlinkto( linker );
    self playsoundtoplayer( "zmb_player_death_fall", self );
    falling = stance != "prone";

    if ( falling )
    {
        origin = playerphysicstrace( origin, origin + xyspeed );
        eye = self get_eye();
        floor_height = 10 + origin[2] - eye[2];
        origin += ( 0, 0, floor_height );
        lerptime = 0.5;
        linker moveto( origin, lerptime, lerptime );
        linker rotateto( angles, lerptime, lerptime );
    }

    self freezecontrols( 1 );

    if ( falling )
        linker waittill( "movedone" );

    self giveweapon( "death_throe_zm" );
    self switchtoweapon( "death_throe_zm" );

    if ( falling )
    {
        bounce = randomint( 4 ) + 8;
        origin = origin + ( 0, 0, bounce ) - xyspeed * 0.1;
        lerptime = bounce / 50.0;
        linker moveto( origin, lerptime, 0, lerptime );

        linker waittill( "movedone" );

        origin = origin + ( 0, 0, bounce * -1 ) + xyspeed * 0.1;
        lerptime /= 2.0;
        linker moveto( origin, lerptime, lerptime );

        linker waittill( "movedone" );

        linker moveto( origin, 5, 0 );
    }

    wait 15;
    linker delete();
}

nuked_player_fake_death_cleanup()
{
    if ( isdefined( self._fall_down_anchor ) )
    {
        self._fall_down_anchor delete();
        self._fall_down_anchor = undefined;
    }
}

nuked_player_fake_death( vdir )
{
    level notify( "fake_death" );
    self notify( "fake_death" );
    stance = self getstance();
    self.ignoreme = 1;
    self enableinvulnerability();
    self takeallweapons();

    if ( isdefined( self.insta_killed ) && self.insta_killed )
    {
        self maps\mp\zombies\_zm::player_fake_death();
        self allowprone( 1 );
        self allowcrouch( 0 );
        self allowstand( 0 );
        wait 0.25;
        self freezecontrols( 1 );
    }
    else
    {
        self freezecontrols( 1 );
        self thread fall_down( vdir, stance );
        wait 1;
    }
}

initial_round_wait_func()
{
    flag_wait( "initial_blackscreen_passed" );
}

melee_miss_func()
{
    if ( isdefined( self.enemy ) )
    {
        if ( self.enemy maps\mp\zombies\_zm_laststand::is_reviving_any() )
        {
            dist_sq = distancesquared( self.enemy.origin, self.origin );
            melee_dist_sq = self.meleeattackdist * self.meleeattackdist;

            if ( dist_sq < melee_dist_sq )
                self.enemy dodamage( self.meleedamage, self.origin, self, self, "none", "MOD_MELEE" );
        }
    }
}

zombie_init_done()
{
    self.allowpain = 0;

    if ( isdefined( self.script_parameters ) && self.script_parameters == "crater" )
        self thread zombie_crater_locomotion();

    self setphysparams( 15, 0, 48 );
}

zombie_crater_locomotion()
{
    self endon( "death" );
    stand_trigger = getentarray( "zombie_crawler_standup", "targetname" );

    while ( is_true( self.needs_run_update ) )
        wait 0.1;

    self allowpitchangle( 1 );
    self setpitchorient();

    if ( self.zombie_move_speed == "sprint" )
        self setanimstatefromasd( "zm_move_sprint_crawl", 2 );
    else
        self setanimstatefromasd( "zm_move_sprint_crawl", 1 );

    touched = 0;

    while ( !touched )
    {
        if ( isdefined( self.completed_emerging_into_playable_area ) && self.completed_emerging_into_playable_area )
        {
            self allowpitchangle( 0 );
            self clearpitchorient();
            return;
        }

        for ( i = 0; i < stand_trigger.size; i++ )
        {
            if ( self istouching( stand_trigger[i] ) )
            {
                touched = 1;
                break;
            }
        }

        wait 0.1;
    }

    self allowpitchangle( 0 );
    self clearpitchorient();
    self maps\mp\animscripts\zm_run::needsupdate();
}

zombie_path_timer_override()
{
    timer = gettime() + 100.0;
    return timer;
}

nuked_update_traversals()
{
    level.yellow_awning_clip = getentarray( "yellow_awning_clip", "targetname" );
    level.yellow_patio_clip = getentarray( "yellow_patio_clip", "targetname" );
    level.green_awning_clip = getentarray( "green_awning_clip", "targetname" );
    level.green_patio_clip = getentarray( "green_patio_clip", "targetname" );
    level.yellow_awning = 0;
    level.yellow_patio = 0;
    level.green_awning = 0;
    level.green_patio = 0;
    wait 5;

    while ( true )
    {
        level.yellow_backyard = 0;
        level.green_backyard = 0;
        level.culdesac = 0;
        level.other = 0;
        nuked_update_player_zones();

        if ( !level.culdesac && !level.other )
        {
            if ( level.yellow_backyard > 0 )
            {
                set_yellow_awning( 1 );
                set_yellow_patio( 0 );
            }

            if ( level.green_backyard > 0 )
            {
                set_green_awning( 1 );
                set_green_patio( 0 );
            }
        }
        else if ( !level.yellow_backyard && !level.green_backyard && !level.other )
        {
            set_yellow_awning( 0 );
            set_yellow_patio( 1 );
            set_green_awning( 0 );
            set_green_patio( 1 );
        }
        else if ( !level.other )
        {
            set_yellow_awning( 0 );
            set_yellow_patio( 0 );
            set_green_awning( 0 );
            set_green_patio( 0 );
        }
        else
        {
            set_yellow_awning( 1 );
            set_yellow_patio( 1 );
            set_green_awning( 1 );
            set_green_patio( 1 );
        }

        wait 0.2;
    }
}

set_yellow_awning( enable )
{
    if ( enable )
    {
        if ( !level.yellow_awning )
        {
            level.yellow_awning = 1;
            house_clip( level.yellow_awning_clip, 1 );
        }
    }
    else if ( level.yellow_awning )
    {
        level.yellow_awning = 0;
        house_clip( level.yellow_awning_clip, 0 );
    }
}

set_yellow_patio( enable )
{
    if ( enable )
    {
        if ( !level.yellow_patio )
        {
            level.yellow_patio = 1;
            house_clip( level.yellow_patio_clip, 1 );
        }
    }
    else if ( level.yellow_patio )
    {
        level.yellow_patio = 0;
        house_clip( level.yellow_patio_clip, 0 );
    }
}

set_green_awning( enable )
{
    if ( enable )
    {
        if ( !level.green_awning )
        {
            level.green_awning = 1;
            house_clip( level.green_awning_clip, 1 );
        }
    }
    else if ( level.green_awning )
    {
        level.green_awning = 0;
        house_clip( level.green_awning_clip, 0 );
    }
}

set_green_patio( enable )
{
    if ( enable )
    {
        if ( !level.green_patio )
        {
            level.green_patio = 1;
            house_clip( level.green_patio_clip, 1 );
        }
    }
    else if ( level.green_patio )
    {
        level.green_patio = 0;
        house_clip( level.green_patio_clip, 0 );
    }
}

nuked_update_player_zones()
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( is_player_valid( players[i] ) )
        {
            if ( players[i] maps\mp\zombies\_zm_zonemgr::entity_in_zone( "openhouse1_backyard_zone" ) )
            {
                level.green_backyard++;
                continue;
            }

            if ( players[i] maps\mp\zombies\_zm_zonemgr::entity_in_zone( "openhouse2_backyard_zone" ) )
            {
                level.yellow_backyard++;
                continue;
            }

            if ( players[i] maps\mp\zombies\_zm_zonemgr::entity_in_zone( "culdesac_green_zone" ) || players[i] maps\mp\zombies\_zm_zonemgr::entity_in_zone( "culdesac_yellow_zone" ) )
            {
                level.culdesac++;
                continue;
            }

            level.other++;
        }
    }
}

house_clip( clips, connect )
{
    for ( i = 0; i < clips.size; i++ )
    {
        if ( connect )
        {
            clips[i] notsolid();
            clips[i] connectpaths();
            continue;
        }

        clips[i] solid();
        clips[i] disconnectpaths();
    }
}

setup_rex_starts()
{
    add_gametype( "zstandard", ::dummy, "zstandard", ::dummy );
    add_gameloc( "nuked", ::dummy, "nuked", ::dummy );
}

dummy()
{

}

precache_team_characters()
{
    precachemodel( "c_zom_player_cdc_fb" );
    precachemodel( "c_zom_hazmat_viewhands_light" );
    precachemodel( "c_zom_player_cia_fb" );
    precachemodel( "c_zom_suit_viewhands" );
}

give_team_characters()
{
    if ( isdefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_suit_viewhands" ) )
        return;

    self detachall();
    self set_player_is_female( 0 );

    if ( isdefined( level.should_use_cia ) && level.should_use_cia )
    {
        self setmodel( "c_zom_player_cia_fb" );
        self setviewmodel( "c_zom_suit_viewhands" );
        self.characterindex = 0;
    }
    else
    {
        self setmodel( "c_zom_player_cdc_fb" );
        self setviewmodel( "c_zom_hazmat_viewhands_light" );
        self.characterindex = 1;
    }

    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
    self set_player_tombstone_index();
}

initcharacterstartindex()
{
    level.characterstartindex = randomint( 4 );
}

selectcharacterindextouse()
{
    if ( level.characterstartindex >= 4 )
        level.characterstartindex = 0;

    self.characterindex = level.characterstartindex;
    level.characterstartindex++;
    return self.characterindex;
}

givecustomloadout( takeallweapons, alreadyspawned )
{
    self giveweapon( "knife_zm" );
    self give_start_weapon( 1 );
}

nuked_zone_init()
{
    flag_init( "always_on" );
    flag_set( "always_on" );
    add_adjacent_zone( "culdesac_yellow_zone", "culdesac_green_zone", "always_on" );
    add_adjacent_zone( "culdesac_yellow_zone", "openhouse2_f1_zone", "culdesac_2_openhouse2_f1" );
    add_adjacent_zone( "openhouse2_backyard_zone", "openhouse2_f1_zone", "openhouse2_f1_2_openhouse2_backyard" );
    add_adjacent_zone( "openhouse2_f1_zone", "openhouse2_f2_zone", "openhouse2_f1_2_openhouse2_f2" );
    add_adjacent_zone( "openhouse2_backyard_zone", "openhouse2_f2_zone", "openhouse2_f1_2_openhouse2_f2" );
    add_adjacent_zone( "openhouse2_backyard_zone", "openhouse2_f2_zone", "openhouse2_backyard_2_openhouse2_f2" );
    add_adjacent_zone( "culdesac_green_zone", "openhouse1_f1_zone", "culdesac_2_openhouse1_f1" );
    add_adjacent_zone( "openhouse1_f1_zone", "openhouse1_backyard_zone", "openhouse1_f1_2_openhouse1_backyard" );
    add_adjacent_zone( "openhouse1_f2_zone", "openhouse1_f1_zone", "openhouse1_f2_openhouse1_f1" );
    add_adjacent_zone( "openhouse1_f2_zone", "openhouse1_backyard_zone", "openhouse1_f2_openhouse1_f1" );
    add_adjacent_zone( "openhouse1_backyard_zone", "openhouse1_f2_zone", "openhouse1_backyard_2_openhouse1_f2" );
    add_adjacent_zone( "culdesac_yellow_zone", "truck_zone", "culdesac_2_truck" );
    add_adjacent_zone( "culdesac_green_zone", "truck_zone", "culdesac_2_truck" );
    add_adjacent_zone( "openhouse2_backyard_zone", "ammo_door_zone", "openhouse2_backyard_2_ammo_door" );
}

include_powerups()
{
    include_powerup( "nuke" );
    include_powerup( "insta_kill" );
    include_powerup( "double_points" );
    include_powerup( "full_ammo" );
    include_powerup( "fire_sale" );
}

include_perks()
{

}

include_equipment_for_level()
{

}

include_weapons()
{
    include_weapon( "knife_zm", 0 );
    include_weapon( "frag_grenade_zm", 0 );
    include_weapon( "claymore_zm", 0 );
    include_weapon( "sticky_grenade_zm", 0 );
    include_weapon( "m1911_zm", 0 );
    include_weapon( "m1911_upgraded_zm", 0 );
    include_weapon( "python_zm" );
    include_weapon( "python_upgraded_zm", 0 );
    include_weapon( "judge_zm" );
    include_weapon( "judge_upgraded_zm", 0 );
    include_weapon( "kard_zm" );
    include_weapon( "kard_upgraded_zm", 0 );
    include_weapon( "fiveseven_zm" );
    include_weapon( "fiveseven_upgraded_zm", 0 );
    include_weapon( "beretta93r_zm", 0 );
    include_weapon( "beretta93r_upgraded_zm", 0 );
    include_weapon( "fivesevendw_zm" );
    include_weapon( "fivesevendw_upgraded_zm", 0 );
    include_weapon( "ak74u_zm", 0 );
    include_weapon( "ak74u_upgraded_zm", 0 );
    include_weapon( "mp5k_zm", 0 );
    include_weapon( "mp5k_upgraded_zm", 0 );
    include_weapon( "qcw05_zm" );
    include_weapon( "qcw05_upgraded_zm", 0 );
    include_weapon( "870mcs_zm", 0 );
    include_weapon( "870mcs_upgraded_zm", 0 );
    include_weapon( "rottweil72_zm", 0 );
    include_weapon( "rottweil72_upgraded_zm", 0 );
    include_weapon( "saiga12_zm" );
    include_weapon( "saiga12_upgraded_zm", 0 );
    include_weapon( "srm1216_zm" );
    include_weapon( "srm1216_upgraded_zm", 0 );
    include_weapon( "m14_zm", 0 );
    include_weapon( "m14_upgraded_zm", 0 );
    include_weapon( "saritch_zm" );
    include_weapon( "saritch_upgraded_zm", 0 );
    include_weapon( "m16_zm", 0 );
    include_weapon( "m16_gl_upgraded_zm", 0 );
    include_weapon( "xm8_zm" );
    include_weapon( "xm8_upgraded_zm", 0 );
    include_weapon( "type95_zm" );
    include_weapon( "type95_upgraded_zm", 0 );
    include_weapon( "tar21_zm" );
    include_weapon( "tar21_upgraded_zm", 0 );
    include_weapon( "galil_zm" );
    include_weapon( "galil_upgraded_zm", 0 );
    include_weapon( "fnfal_zm" );
    include_weapon( "fnfal_upgraded_zm", 0 );
    include_weapon( "dsr50_zm" );
    include_weapon( "dsr50_upgraded_zm", 0 );
    include_weapon( "barretm82_zm" );
    include_weapon( "barretm82_upgraded_zm", 0 );
    include_weapon( "rpd_zm" );
    include_weapon( "rpd_upgraded_zm", 0 );
    include_weapon( "hamr_zm" );
    include_weapon( "hamr_upgraded_zm", 0 );
    include_weapon( "usrpg_zm" );
    include_weapon( "usrpg_upgraded_zm", 0 );
    include_weapon( "m32_zm" );
    include_weapon( "m32_upgraded_zm", 0 );
    include_weapon( "hk416_zm" );
    include_weapon( "hk416_upgraded_zm", 0 );
    include_weapon( "lsat_zm" );
    include_weapon( "lsat_upgraded_zm", 0 );
    include_weapon( "cymbal_monkey_zm" );
    include_weapon( "ray_gun_zm" );
    include_weapon( "ray_gun_upgraded_zm", 0 );
    include_weapon( "tazer_knuckles_zm", 0 );
    include_weapon( "knife_ballistic_no_melee_zm", 0 );
    include_weapon( "knife_ballistic_no_melee_upgraded_zm", 0 );
    include_weapon( "knife_ballistic_zm" );
    include_weapon( "knife_ballistic_upgraded_zm", 0 );
    include_weapon( "knife_ballistic_bowie_zm", 0 );
    include_weapon( "knife_ballistic_bowie_upgraded_zm", 0 );
    level._uses_retrievable_ballisitic_knives = 1;
    add_limited_weapon( "m1911_zm", 0 );
    add_limited_weapon( "knife_ballistic_zm", 1 );
    add_limited_weapon( "jetgun_zm", 1 );
    add_limited_weapon( "ray_gun_zm", 4 );
    add_limited_weapon( "ray_gun_upgraded_zm", 4 );
    add_limited_weapon( "knife_ballistic_upgraded_zm", 0 );
    add_limited_weapon( "knife_ballistic_no_melee_zm", 0 );
    add_limited_weapon( "knife_ballistic_no_melee_upgraded_zm", 0 );
    add_limited_weapon( "knife_ballistic_bowie_zm", 0 );
    add_limited_weapon( "knife_ballistic_bowie_upgraded_zm", 0 );

    if ( isdefined( level.raygun2_included ) && level.raygun2_included )
    {
        include_weapon( "raygun_mark2_zm" );
        include_weapon( "raygun_mark2_upgraded_zm", 0 );
        add_weapon_to_content( "raygun_mark2_zm", "dlc3" );
        add_limited_weapon( "raygun_mark2_zm", 1 );
        add_limited_weapon( "raygun_mark2_upgraded_zm", 1 );
    }
}

offhand_weapon_overrride()
{
    register_lethal_grenade_for_level( "frag_grenade_zm" );
    register_lethal_grenade_for_level( "sticky_grenade_zm" );
    level.zombie_lethal_grenade_player_init = "frag_grenade_zm";
    register_tactical_grenade_for_level( "cymbal_monkey_zm" );
    level.zombie_tactical_grenade_player_init = undefined;
    register_placeable_mine_for_level( "claymore_zm" );
    level.zombie_placeable_mine_player_init = undefined;
    register_melee_weapon_for_level( "knife_zm" );
    register_melee_weapon_for_level( "bowie_knife_zm" );
    register_melee_weapon_for_level( "tazer_knuckles_zm" );
    level.zombie_melee_weapon_player_init = "knife_zm";
    level.zombie_equipment_player_init = undefined;
}

offhand_weapon_give_override( str_weapon )
{
    self endon( "death" );

    if ( is_tactical_grenade( str_weapon ) && isdefined( self get_player_tactical_grenade() ) && !self is_player_tactical_grenade( str_weapon ) )
    {
        self setweaponammoclip( self get_player_tactical_grenade(), 0 );
        self takeweapon( self get_player_tactical_grenade() );
    }

    return 0;
}

custom_add_weapons()
{
    add_zombie_weapon( "m1911_zm", "m1911_upgraded_zm", &"ZOMBIE_WEAPON_M1911", 50, "", "", undefined );
    add_zombie_weapon( "python_zm", "python_upgraded_zm", &"ZOMBIE_WEAPON_PYTHON", 50, "wpck_python", "", undefined, 1 );
    add_zombie_weapon( "judge_zm", "judge_upgraded_zm", &"ZOMBIE_WEAPON_JUDGE", 50, "wpck_judge", "", undefined, 1 );
    add_zombie_weapon( "kard_zm", "kard_upgraded_zm", &"ZOMBIE_WEAPON_KARD", 50, "wpck_kap", "", undefined, 1 );
    add_zombie_weapon( "fiveseven_zm", "fiveseven_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVEN", 50, "wpck_57", "", undefined, 1 );
    add_zombie_weapon( "beretta93r_zm", "beretta93r_upgraded_zm", &"ZOMBIE_WEAPON_BERETTA93r", 1000, "", "", undefined );
    add_zombie_weapon( "fivesevendw_zm", "fivesevendw_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVENDW", 50, "wpck_duel57", "", undefined, 1 );
    add_zombie_weapon( "ak74u_zm", "ak74u_upgraded_zm", &"ZOMBIE_WEAPON_AK74U", 1200, "smg", "", undefined );
    add_zombie_weapon( "mp5k_zm", "mp5k_upgraded_zm", &"ZOMBIE_WEAPON_MP5K", 1000, "smg", "", undefined );
    add_zombie_weapon( "qcw05_zm", "qcw05_upgraded_zm", &"ZOMBIE_WEAPON_QCW05", 50, "wpck_chicom", "", undefined, 1 );
    add_zombie_weapon( "870mcs_zm", "870mcs_upgraded_zm", &"ZOMBIE_WEAPON_870MCS", 1500, "shotgun", "", undefined );
    add_zombie_weapon( "rottweil72_zm", "rottweil72_upgraded_zm", &"ZOMBIE_WEAPON_ROTTWEIL72", 500, "shotgun", "", undefined );
    add_zombie_weapon( "saiga12_zm", "saiga12_upgraded_zm", &"ZOMBIE_WEAPON_SAIGA12", 50, "wpck_saiga12", "", undefined, 1 );
    add_zombie_weapon( "srm1216_zm", "srm1216_upgraded_zm", &"ZOMBIE_WEAPON_SRM1216", 50, "wpck_m1216", "", undefined, 1 );
    add_zombie_weapon( "m14_zm", "m14_upgraded_zm", &"ZOMBIE_WEAPON_M14", 500, "rifle", "", undefined );
    add_zombie_weapon( "saritch_zm", "saritch_upgraded_zm", &"ZOMBIE_WEAPON_SARITCH", 50, "wpck_sidr", "", undefined, 1 );
    add_zombie_weapon( "m16_zm", "m16_gl_upgraded_zm", &"ZOMBIE_WEAPON_M16", 1200, "burstrifle", "", undefined );
    add_zombie_weapon( "xm8_zm", "xm8_upgraded_zm", &"ZOMBIE_WEAPON_XM8", 50, "wpck_m8a1", "", undefined, 1 );
    add_zombie_weapon( "type95_zm", "type95_upgraded_zm", &"ZOMBIE_WEAPON_TYPE95", 50, "wpck_type25", "", undefined, 1 );
    add_zombie_weapon( "tar21_zm", "tar21_upgraded_zm", &"ZOMBIE_WEAPON_TAR21", 50, "wpck_x95l", "", undefined, 1 );
    add_zombie_weapon( "galil_zm", "galil_upgraded_zm", &"ZOMBIE_WEAPON_GALIL", 50, "wpck_galil", "", undefined, 1 );
    add_zombie_weapon( "fnfal_zm", "fnfal_upgraded_zm", &"ZOMBIE_WEAPON_FNFAL", 50, "wpck_fal", "", undefined, 1 );
    add_zombie_weapon( "dsr50_zm", "dsr50_upgraded_zm", &"ZOMBIE_WEAPON_DR50", 50, "wpck_dsr50", "", undefined, 1 );
    add_zombie_weapon( "barretm82_zm", "barretm82_upgraded_zm", &"ZOMBIE_WEAPON_BARRETM82", 50, "sniper", "", undefined );
    add_zombie_weapon( "rpd_zm", "rpd_upgraded_zm", &"ZOMBIE_WEAPON_RPD", 50, "wpck_rpd", "", undefined, 1 );
    add_zombie_weapon( "hamr_zm", "hamr_upgraded_zm", &"ZOMBIE_WEAPON_HAMR", 50, "wpck_hamr", "", undefined, 1 );
    add_zombie_weapon( "frag_grenade_zm", undefined, &"ZOMBIE_WEAPON_FRAG_GRENADE", 250, "grenade", "", 250 );
    add_zombie_weapon( "sticky_grenade_zm", undefined, &"ZOMBIE_WEAPON_STICKY_GRENADE", 250, "grenade", "", 250 );
    add_zombie_weapon( "claymore_zm", undefined, &"ZOMBIE_WEAPON_CLAYMORE", 1000, "grenade", "", undefined );
    add_zombie_weapon( "usrpg_zm", "usrpg_upgraded_zm", &"ZOMBIE_WEAPON_USRPG", 50, "wpck_rpg", "", undefined, 1 );
    add_zombie_weapon( "m32_zm", "m32_upgraded_zm", &"ZOMBIE_WEAPON_M32", 50, "wpck_m32", "", undefined, 1 );
    add_zombie_weapon( "cymbal_monkey_zm", undefined, &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
    add_zombie_weapon( "ray_gun_zm", "ray_gun_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN", 10000, "wpck_ray", "", undefined, 1 );
    add_zombie_weapon( "knife_ballistic_zm", "knife_ballistic_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "sickle", "", undefined );
    add_zombie_weapon( "knife_ballistic_bowie_zm", "knife_ballistic_bowie_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "wpck_knife", "", undefined, 1 );
    add_zombie_weapon( "knife_ballistic_no_melee_zm", "knife_ballistic_no_melee_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "sickle", "", undefined );
    add_zombie_weapon( "tazer_knuckles_zm", undefined, &"ZOMBIE_WEAPON_TAZER_KNUCKLES", 100, "tazerknuckles", "", undefined );
    add_zombie_weapon( "hk416_zm", "hk416_upgraded_zm", &"ZOMBIE_WEAPON_HK416", 100, "", "", undefined );
    add_zombie_weapon( "lsat_zm", "lsat_upgraded_zm", &"ZOMBIE_WEAPON_LSAT", 100, "", "", undefined );

    if ( isdefined( level.raygun2_included ) && level.raygun2_included )
        add_zombie_weapon( "raygun_mark2_zm", "raygun_mark2_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN_MARK2", 10000, "raygun_mark2", "", undefined );
}

nuked_population_sign_think()
{
    tens_model = getent( "counter_tens", "targetname" );
    ones_model = getent( "counter_ones", "targetname" );
    step = 36.0;
    ones = 0;
    tens = 0;
    local_zombies_killed = 0;
    tens_model rotateroll( step, 0.05 );
    ones_model rotateroll( step, 0.05 );

    while ( true )
    {
        if ( local_zombies_killed < level.total_zombies_killed - level.zombie_total_subtract )
        {
            ones--;
            time = set_dvar_float_if_unset( "scr_dial_rotate_time", "0.5" );

            if ( ones < 0 )
            {
                ones = 9;
                tens_model rotateroll( 0 - step, time );
                tens_model playsound( "zmb_counter_flip" );
                tens--;
            }

            if ( tens < 0 )
                tens = 9;

            ones_model rotateroll( 0 - step, time );
            ones_model playsound( "zmb_counter_flip" );

            ones_model waittill( "rotatedone" );

            level.population_count = ones + tens * 10;

            if ( level.population_count == 0 || level.population_count == 33 || level.population_count == 66 || level.population_count == 99 )
                level notify( "update_doomsday_clock" );

            local_zombies_killed++;
        }

        wait 0.05;
    }
}

assign_lowest_unused_character_index()
{
    charindexarray = [];
    charindexarray[0] = 0;
    charindexarray[1] = 1;
    charindexarray[2] = 2;
    charindexarray[3] = 3;
    players = get_players();

    if ( players.size == 1 )
    {
        charindexarray = array_randomize( charindexarray );
        return charindexarray[0];
    }
    else if ( players.size == 2 )
    {
        foreach ( player in players )
        {
            if ( isdefined( player.characterindex ) )
            {
                if ( player.characterindex == 0 || player.characterindex == 1 )
                {
                    if ( randomint( 100 ) > 50 )
                        return 2;

                    return 3;
                }
                else if ( player.characterindex == 2 || player.characterindex == 3 )
                {
                    if ( randomint( 100 ) > 50 )
                        return 0;

                    return 1;
                }
            }
        }
    }
    else
    {
        foreach ( player in players )
        {
            if ( isdefined( player.characterindex ) )
                arrayremovevalue( charindexarray, player.characterindex, 0 );
        }

        if ( charindexarray.size > 0 )
            return charindexarray[0];
    }

    return 0;
}

nuked_mannequin_init()
{
    keep_count = 28;
    level.mannequin_count = 0;
    destructibles = getentarray( "destructible", "targetname" );
    mannequins = nuked_mannequin_filter( destructibles );

    if ( mannequins.size <= 0 )
        return;

    remove_count = mannequins.size - keep_count;
    remove_count = clamp( remove_count, 0, remove_count );
    mannequins = array_randomize( mannequins );

    for ( i = 0; i < remove_count; i++ )
    {
        assert( isdefined( mannequins[i].target ) );
        collision = getent( mannequins[i].target, "targetname" );
        assert( isdefined( collision ) );
        collision delete();
        mannequins[i] delete();
        level.mannequin_count--;
    }

    level waittill( "prematch_over" );

    level.mannequin_time = gettime();
}

nuked_mannequin_filter( destructibles )
{
    mannequins = [];

    for ( i = 0; i < destructibles.size; i++ )
    {
        destructible = destructibles[i];

        if ( issubstr( destructible.destructibledef, "male" ) )
        {
            mannequins[mannequins.size] = destructible;
            level.mannequin_count++;
        }
    }

    return mannequins;
}

custom_debris_function()
{
    cost = 1000;

    if ( isdefined( self.zombie_cost ) )
        cost = self.zombie_cost;

    while ( true )
    {
        if ( isdefined( self.script_noteworthy ) )
        {
            if ( self.script_noteworthy == "electric_door" || self.script_noteworthy == "electric_buyable_door" )
            {
                self sethintstring( &"ZOMBIE_NEED_POWER" );
                flag_wait( "power_on" );
            }
        }

        self set_hint_string( self, "default_buy_door", cost );

        self waittill( "trigger", who, force );

        if ( getdvarint( _hash_2ECA0C0E ) > 0 || is_true( force ) )
        {

        }
        else
        {
            if ( !who usebuttonpressed() )
                continue;

            if ( who in_revive_trigger() )
                continue;
        }

        if ( is_player_valid( who ) )
        {
            players = get_players();

            if ( getdvarint( _hash_2ECA0C0E ) > 0 )
            {

            }
            else if ( who.score >= self.zombie_cost )
                who maps\mp\zombies\_zm_score::minus_to_player_score( self.zombie_cost );
            else
            {
                play_sound_at_pos( "no_purchase", self.origin );
                who maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "door_deny", undefined, 1 );
                continue;
            }

            bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", who.name, who.score, level.round_number, self.zombie_cost, self.script_flag, self.origin, "door" );
            junk = getentarray( self.target, "targetname" );

            if ( isdefined( self.script_flag ) )
            {
                tokens = strtok( self.script_flag, "," );

                for ( i = 0; i < tokens.size; i++ )
                    flag_set( tokens[i] );
            }

            play_sound_at_pos( "purchase", self.origin );
            level notify( "junk purchased" );
            move_ent = undefined;
            clip = undefined;

            for ( i = 0; i < junk.size; i++ )
            {
                junk[i] connectpaths();

                if ( isdefined( junk[i].script_noteworthy ) )
                {
                    if ( junk[i].script_noteworthy == "clip" )
                    {
                        clip = junk[i];
                        continue;
                    }
                }

                struct = undefined;

                if ( isdefined( junk[i].script_linkto ) )
                {
                    struct = getstruct( junk[i].script_linkto, "script_linkname" );

                    if ( isdefined( struct ) )
                    {
                        move_ent = junk[i];
                        junk[i] thread maps\mp\zombies\_zm_blockers::debris_move( struct );
                    }
                    else
                        junk[i] delete();

                    continue;
                }

                junk[i] delete();
            }

            all_trigs = getentarray( self.target, "target" );

            for ( i = 0; i < all_trigs.size; i++ )
                all_trigs[i] delete();

            if ( isdefined( clip ) )
            {
                if ( isdefined( move_ent ) )
                    move_ent waittill( "movedone" );

                clip delete();
            }

            break;
        }
    }
}

sndgameend()
{
    level waittill( "intermission" );

    playsoundatposition( "zmb_endgame", ( 0, 0, 0 ) );
}

sndmusiceastereggs()
{
    level.music_override = 0;
    level thread sndmusegg1();
    level thread sndmusegg2();
}

sndmusegg1()
{
    level waittill( "nuke_clock_moved" );

    level waittill( "magic_door_power_up_grabbed" );

    min_hand_model = getent( "clock_min_hand", "targetname" );

    if ( level.population_count == 15 && level.music_override == 0 )
        level thread sndmuseggplay( spawn( "script_origin", ( 0, 0, 0 ) ), "zmb_nuked_song_1", 88 );
}

sndmusegg2()
{
    origins = [];
    origins[0] = ( -1998, 632, -48 );
    origins[1] = ( -80, 35, -18 );
    origins[2] = ( 617, 313, 152 );
    level.meteor_counter = 0;
    level.music_override = 0;

    for ( i = 0; i < origins.size; i++ )
        level thread sndmusegg2_wait( origins[i] );
}

sndmusegg2_wait( bear_origin )
{
    temp_ent = spawn( "script_origin", bear_origin );
    temp_ent playloopsound( "zmb_meteor_loop" );
    temp_ent thread maps\mp\zombies\_zm_sidequests::fake_use( "main_music_egg_hit", ::sndmusegg2_override );

    temp_ent waittill( "main_music_egg_hit", player );

    temp_ent stoploopsound( 1 );
    player playsound( "zmb_meteor_activate" );
    level.meteor_counter += 1;

    if ( level.meteor_counter == 3 )
        level thread sndmuseggplay( temp_ent, "zmb_nuked_song_2", 60 );
    else
    {
        wait 1.5;
        temp_ent delete();
    }
}

sndmusegg2_override()
{
    if ( isdefined( level.music_override ) && level.music_override )
        return false;

    return true;
}

sndmusegg3_counter( event, attacker )
{
    if ( level.mannequin_count <= 0 )
        return;
/#
    println( "CAYERS: " + level.mannequin_count );
#/
    level.mannequin_count--;

    if ( level.mannequin_count <= 0 )
    {
        while ( isdefined( level.music_override ) && level.music_override )
            wait 5;

        level thread sndmuseggplay( spawn( "script_origin", ( 0, 0, 0 ) ), "zmb_nuked_song_3", 80 );
    }
}

sndmuseggplay( ent, alias, time )
{
    level.music_override = 1;
    wait 1;
    ent playsound( alias );
    level thread sndeggmusicwait( time );
    level waittill_either( "end_game", "sndSongDone" );
    ent stopsounds();
    wait 0.05;
    ent delete();
    level.music_override = 0;
}

sndeggmusicwait( time )
{
    level endon( "end_game" );
    wait( time );
    level notify( "sndSongDone" );
}

nuked_standard_intermission()
{
    self closemenu();
    self closeingamemenu();
    level endon( "stop_intermission" );
    self endon( "disconnect" );
    self endon( "death" );
    self notify( "_zombie_game_over" );
    self.score = self.score_total;
    self.sessionstate = "intermission";
    self.spectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;
    self.friendlydamage = undefined;
    self.game_over_bg = newclienthudelem( self );
    self.game_over_bg.x = 0;
    self.game_over_bg.y = 0;
    self.game_over_bg.horzalign = "fullscreen";
    self.game_over_bg.vertalign = "fullscreen";
    self.game_over_bg.foreground = 1;
    self.game_over_bg.sort = 1;
    self.game_over_bg setshader( "black", 640, 480 );
    self.game_over_bg.alpha = 1;
    clientnotify( "znfg" );
    level thread moon_rocket_follow_path();
    wait 0.1;
    self.game_over_bg fadeovertime( 1 );
    self.game_over_bg.alpha = 0;
    flag_wait( "rocket_hit_nuketown" );
    self.game_over_bg fadeovertime( 1 );
    self.game_over_bg.alpha = 1;
}

moon_rocket_follow_path()
{
    rocket_start_struct = getstruct( "inertmission_rocket_start", "targetname" );
    rocket_end_struct = getstruct( "inertmission_rocket_end", "targetname" );
    rocket_cam_start_struct = getstruct( "intermission_rocket_cam_start", "targetname" );
    rocket_cam_end_struct = getstruct( "intermission_rocket_cam_end", "targetname" );
    rocket_camera_ent = spawn( "script_model", rocket_cam_start_struct.origin );
    rocket_camera_ent.angles = rocket_cam_start_struct.angles;
    rocket = getent( "intermission_rocket", "targetname" );
    rocket show();
    rocket.origin = rocket_start_struct.origin;
    camera = spawn( "script_model", rocket_cam_start_struct.origin );
    camera.angles = rocket_cam_start_struct.angles;
    camera setmodel( "tag_origin" );
    exploder( 676 );
    players = get_players();

    foreach ( player in players )
    {
        player setclientuivisibilityflag( "hud_visible", 0 );
        player thread player_rocket_rumble();
        player thread intermission_rocket_blur();
        player setdepthoffield( 0, 128, 7000, 10000, 6, 1.8 );
        player camerasetposition( camera );
        player camerasetlookat();
        player cameraactivate( 1 );
    }

    rocket moveto( rocket_end_struct.origin, 9 );
    rocket rotateto( rocket_end_struct.angles, 11 );
    camera moveto( rocket_cam_end_struct.origin, 9 );
    camera rotateto( rocket_cam_end_struct.angles, 8 );
    playfxontag( level._effect["rocket_entry"], rocket, "tag_fx" );
    playfxontag( level._effect["rocket_entry_light"], rocket, "tag_fx" );
    wait 7.5;
    flag_set( "rocket_hit_nuketown" );
}

intermission_rocket_blur()
{
    while ( !flag( "rocket_hit_nuketown" ) )
    {
        blur = randomfloatrange( 1, 5 );
        self setblur( blur, 1 );
        wait( randomintrange( 1, 3 ) );
    }
}

inermission_rocket_init()
{
    rocket = getent( "intermission_rocket", "targetname" );
    rocket hide();
}

player_rocket_rumble()
{
    while ( !flag( "rocket_hit_nuketown" ) )
    {
        self playrumbleonentity( "damage_light" );
        wait 1;
    }
}

bus_taser_blocker()
{
    trig = getent( "bus_taser_trigger", "targetname" );

    if ( isdefined( trig ) )
        clip = getent( trig.target, "targetname" );

    trig waittill( "trigger" );

    if ( isdefined( clip ) )
        clip delete();
}

marlton_vo_inside_bunker()
{
    marlton_bunker_trig = getent( "marlton_bunker_trig", "targetname" );
    marlton_sound_pos = marlton_bunker_trig.origin;
    marlton_vo = [];
    marlton_vo[marlton_vo.size] = "vox_plr_3_pap_wait_0";
    marlton_vo[marlton_vo.size] = "vox_plr_3_pap_wait2_0";
    marlton_vo[marlton_vo.size] = "vox_plr_3_pap_wait2_2";
    marlton_vo[marlton_vo.size] = "vox_plr_3_avogadro_attack_1";
    marlton_vo[marlton_vo.size] = "vox_plr_3_avogadro_attack_2";
    marlton_vo[marlton_vo.size] = "vox_plr_3_build_add_1";
    marlton_vo[marlton_vo.size] = "vox_plr_3_build_pck_bjetgun_0";
    marlton_vo[marlton_vo.size] = "vox_plr_3_bus_zom_chase_1";
    marlton_vo[marlton_vo.size] = "vox_plr_3_bus_zom_roof_4";
    marlton_vo[marlton_vo.size] = "vox_plr_3_cough_0";
    marlton_vo[marlton_vo.size] = "vox_plr_3_map_in_fog_0";
    marlton_vo[marlton_vo.size] = "vox_plr_3_map_in_fog_1";
    marlton_vo[marlton_vo.size] = "vox_plr_3_map_in_fog_2";
    marlton_vo[marlton_vo.size] = "vox_plr_3_oh_shit_0_alt01";

    while ( true )
    {
        marlton_bunker_trig waittill( "trigger" );

        playsoundatposition( marlton_vo[randomintrange( 0, marlton_vo.size )], marlton_sound_pos );
        wait_for_next_round( level.round_number );
    }
}

wait_for_next_round( current_round )
{
    while ( level.round_number <= current_round )
        wait 1;
}

moon_transmission_vo()
{
    start_round = 3;
    end_round = 25;
    moon_transmission_struct = getstruct( "moon_transmission_struct", "targetname" );
    wait_for_round_range( 3 );
    playsoundatposition( "vox_nuked_tbase_transmission_0", moon_transmission_struct.origin );
    wait_for_round_range( randomintrange( 4, 9 ) );
    playsoundatposition( "vox_nuked_tbase_transmission_1", moon_transmission_struct.origin );
    wait_for_round_range( randomintrange( 10, 17 ) );
    playsoundatposition( "vox_nuked_tbase_transmission_2", moon_transmission_struct.origin );
    wait_for_round_range( randomintrange( 18, 22 ) );
    playsoundatposition( "vox_nuked_tbase_transmission_3", moon_transmission_struct.origin );
    wait_for_round_range( 25 );
    playsoundatposition( "vox_nuked_tbase_transmission_4", moon_transmission_struct.origin );
    flag_set( "moon_transmission_over" );
}

wait_for_round_range( round )
{
    while ( level.round_number < round )
        wait 1;
}

death_to_all_zombies()
{
    zombies = getaiarray( level.zombie_team );

    foreach ( index, zombie in zombies )
    {
        if ( !isalive( zombie ) )
            continue;

        if ( isdefined( zombie ) )
            zombie dodamage( zombie.health + 666, zombie.origin );

        if ( index % 3 == 0 )
            wait_network_frame();
    }
}

zombie_eye_glow_change()
{
    flag_wait( "moon_transmission_over" );
    flag_clear( "spawn_zombies" );
    death_to_all_zombies();
    level.zombie_spawners = getentarray( "zombie_spawner_beyes", "script_noteworthy" );

    if ( isdefined( level._game_module_custom_spawn_init_func ) )
        [[ level._game_module_custom_spawn_init_func ]]();

    flag_set( "spawn_zombies" );
    level setclientfield( "zombie_eye_change", 1 );
}

switch_announcer_to_richtofen()
{
    flag_wait( "moon_transmission_over" );
    sndswitchannouncervox( "richtofen" );
}

bus_random_horn()
{
    horn_struct = getstruct( "bus_horn_struct", "targetname" );
    wait_for_round_range( randomintrange( 5, 10 ) );
    playsoundatposition( "zmb_bus_horn_leave", horn_struct.origin );
}

fake_lighting_cleanup()
{
    ent = getent( "nuke_reflection", "targetname" );

    if ( isdefined( ent ) )
        ent delete();
}

nuked_collision_patch()
{
    minimap_upperr = spawn( "script_origin", ( 2146, 1354, 384 ) );
    minimap_upperr.targetname = "minimap_corner";
    maps\mp\_compass::setupminimap( "compass_map_zm_nuked" );
    collision1 = spawn( "script_model", ( -48, -700, 100 ) );
    collision1 setmodel( "collision_wall_128x128x10_standard" );
    collision1.angles = ( 0, 0, 0 );
    collision1 ghost();
    collision2 = spawn( "script_model", ( 11, -759, 100 ) );
    collision2 setmodel( "collision_wall_128x128x10_standard" );
    collision2.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
    collision2 ghost();
    collision3 = spawn( "script_model", ( -48, -818, 100 ) );
    collision3 setmodel( "collision_wall_128x128x10_standard" );
    collision3.angles = ( 0, 0, 0 );
    collision3 ghost();
    collision4 = spawn( "script_model", ( -107, -759, 100 ) );
    collision4 setmodel( "collision_wall_128x128x10_standard" );
    collision4.angles = vectorscale( ( 0, 1, 0 ), 270.0 );
    collision4 ghost();
    collision5 = spawn( "script_model", ( -48, -759, 169 ) );
    collision5 setmodel( "collision_wall_128x128x10_standard" );
    collision5.angles = ( 0, 270, 90 );
    collision5 ghost();
    collision6 = spawn( "script_model", ( -48, -759, 31 ) );
    collision6 setmodel( "collision_wall_128x128x10_standard" );
    collision6.angles = ( 0, 270, 90 );
    collision6 ghost();
    collision7 = spawn( "script_model", ( -490, 963, 63 ) );
    collision7 setmodel( "collision_player_256x256x10" );
    collision7.angles = ( 0, 25.2, -90 );
    collision7 ghost();
    collision8 = spawn( "script_model", ( 752, 1079, 120 ) );
    collision8 setmodel( "collision_player_512x512x10" );
    collision8.angles = vectorscale( ( 0, 0, -1 ), 90.0 );
    collision8 ghost();
    collision9 = spawn( "script_model", ( -1349, 1016, 0 ) );
    collision9 setmodel( "collision_wall_128x128x10_standard" );
    collision9.angles = vectorscale( ( 0, 1, 0 ), 339.8 );
    collision9 ghost();
    collision10 = spawn( "script_model", ( 132, 280, 25 ) );
    collision10 setmodel( "collision_wall_128x128x10_standard" );
    collision10.angles = vectorscale( ( 0, 1, 0 ), 20.4 );
    collision10 ghost();
}

nuked_special_weapon_magicbox_check( weapon )
{
    if ( isdefined( level.raygun2_included ) && level.raygun2_included )
    {
        if ( weapon == "ray_gun_zm" )
        {
            if ( self has_weapon_or_upgrade( "raygun_mark2_zm" ) )
                return false;
        }

        if ( weapon == "raygun_mark2_zm" )
        {
            if ( self has_weapon_or_upgrade( "ray_gun_zm" ) )
                return false;

            if ( randomint( 100 ) >= 33 )
                return false;
        }
    }

    return true;
}
