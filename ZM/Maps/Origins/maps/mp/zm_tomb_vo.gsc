// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\zombies\_zm_unitrigger;

init_level_specific_audio()
{
    flag_init( "story_vo_playing" );
    flag_init( "round_one_narrative_vo_complete" );
    flag_init( "maxis_audiolog_gr0_playing" );
    flag_init( "maxis_audiolog_gr1_playing" );
    flag_init( "maxis_audiolog_gr2_playing" );
    flag_init( "maxis_audio_log_1" );
    flag_init( "maxis_audio_log_2" );
    flag_init( "maxis_audio_log_3" );
    flag_init( "maxis_audio_log_4" );
    flag_init( "maxis_audio_log_5" );
    flag_init( "maxis_audio_log_6" );
    flag_init( "generator_find_vo_playing" );
    flag_init( "samantha_intro_done" );
    flag_init( "maxis_crafted_intro_done" );
    level.oh_shit_vo_cooldown = 0;
    level.remove_perk_vo_delay = 1;
    setdvar( "zombie_kills", "5" );
    setdvar( "zombie_kill_timer", "6" );

    if ( is_classic() )
    {
        level._audio_custom_response_line = ::tomb_audio_custom_response_line;
        level.audio_get_mod_type = ::tomb_audio_get_mod_type_override;
        level.custom_kill_damaged_vo = maps\mp\zombies\_zm_audio::custom_kill_damaged_vo;
        level._custom_zombie_oh_shit_vox_func = ::tomb_custom_zombie_oh_shit_vox;
        level.gib_on_damage = ::tomb_custom_crawler_spawned_vo;
        level._audio_custom_weapon_check = ::tomb_audio_custom_weapon_check;
        level._magic_box_used_vo = ::tomb_magic_box_used_vo;
        level thread start_narrative_vo();
        level thread first_magic_box_seen_vo();
        level thread start_samantha_intro_vo();
        level.zombie_custom_craftable_built_vo = ::tomb_drone_built_vo;
        level thread discover_dig_site_vo();
        level thread maxis_audio_logs();
        level thread discover_pack_a_punch();
    }

    tomb_add_player_dialogue( "player", "general", "no_money_weapon", "nomoney_generic", undefined );
    tomb_add_player_dialogue( "player", "general", "no_money_box", "nomoney_generic", undefined );
    tomb_add_player_dialogue( "player", "general", "perk_deny", "nomoney_generic", undefined );
    tomb_add_player_dialogue( "player", "general", "no_money_capture", "nomoney_generic", undefined );
    tomb_add_player_dialogue( "player", "perk", "specialty_armorvest", "perk_jugga", undefined );
    tomb_add_player_dialogue( "player", "perk", "specialty_quickrevive", "perk_revive", undefined );
    tomb_add_player_dialogue( "player", "perk", "specialty_fastreload", "perk_speed", undefined );
    tomb_add_player_dialogue( "player", "perk", "specialty_longersprint", "perk_stamine", undefined );
    tomb_add_player_dialogue( "player", "perk", "specialty_additionalprimaryweapon", "perk_mule", undefined );
    tomb_add_player_dialogue( "player", "kill", "closekill", "kill_close", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "damage", "kill_damaged", undefined, 50 );
    tomb_add_player_dialogue( "player", "kill", "headshot", "kill_headshot", "resp_kill_headshot", 25 );
    tomb_add_player_dialogue( "player", "kill", "raygun", "kill_ray", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "raymk2", "kill_raymk2", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "one_inch_punch", "kill_one_inch", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "ice_staff", "kill_ice", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "ice_staff_upgrade", "kill_ice_upgrade", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "fire_staff", "kill_fire", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "fire_staff_upgrade", "kill_fire_upgrade", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "light_staff", "kill_light", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "light_staff_upgrade", "kill_light_upgrade", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "wind_staff", "kill_wind", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "wind_staff_upgrade", "kill_wind_upgrade", undefined, 15 );
    tomb_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_0_neg", "head_rspnd_to_plr_0_neg", undefined, 100 );
    tomb_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_0_pos", "head_rspnd_to_plr_0_pos", undefined, 100 );
    tomb_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_1_neg", "head_rspnd_to_plr_1_neg", undefined, 100 );
    tomb_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_1_pos", "head_rspnd_to_plr_1_pos", undefined, 100 );
    tomb_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_2_neg", "head_rspnd_to_plr_2_neg", undefined, 100 );
    tomb_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_2_pos", "head_rspnd_to_plr_2_pos", undefined, 100 );
    tomb_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_3_neg", "head_rspnd_to_plr_3_neg", undefined, 100 );
    tomb_add_player_dialogue( "player", "kill", "headshot_respond_to_plr_3_pos", "head_rspnd_to_plr_3_pos", undefined, 100 );
    tomb_add_player_dialogue( "player", "powerup", "zombie_blood", "powerup_zombie_blood", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "revive_up", "revive_player", "revive_player", 100 );
    tomb_add_player_dialogue( "player", "general", "heal_revived_pos", "heal_revived_pos", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "heal_revived_neg", "heal_revived_neg", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "exert_sigh", "exert_sigh", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "exert_laugh", "exert_laugh", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "pain_high", "pain_high", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "build_dd_pickup", "build_dd_pickup", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "build_dd_brain_pickup", "pickup_brain", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "build_dd_final", "build_dd_final", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "build_dd_plc", "build_dd_take", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "build_zs_pickup", "build_zs_pickup", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "build_zs_final", "build_zs_final", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "build_zs_plc", "build_zs_take", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "record_pickup", "pickup_record", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "gramophone_pickup", "pickup_gramophone", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "place_gramophone", "place_gramophone", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "staff_part_pickup", "pickup_staff_part", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "crystal_pickup", "pickup_crystal", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "pickup_fire", "pickup_fire", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "pickup_ice", "pickup_ice", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "pickup_light", "pickup_light", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "pickup_wind", "pickup_wind", undefined, 100 );
    tomb_add_player_dialogue( "player", "puzzle", "try_puzzle", "activate_generic", undefined );
    tomb_add_player_dialogue( "player", "puzzle", "puzzle_confused", "confusion_generic", undefined );
    tomb_add_player_dialogue( "player", "puzzle", "puzzle_good", "outcome_yes_generic", undefined );
    tomb_add_player_dialogue( "player", "puzzle", "puzzle_bad", "outcome_no_generic", undefined );
    tomb_add_player_dialogue( "player", "puzzle", "berate_respond", "generic_chastise", undefined );
    tomb_add_player_dialogue( "player", "puzzle", "encourage_respond", "generic_encourage", undefined );
    tomb_add_player_dialogue( "player", "staff", "first_piece", "1st_staff_found", undefined );
    tomb_add_player_dialogue( "player", "general", "build_pickup", "pickup_generic", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "reboard", "rebuild_boards", undefined, 100 );
    tomb_add_player_dialogue( "player", "weapon_pickup", "explo", "wpck_explo", undefined, 100 );
    tomb_add_player_dialogue( "player", "weapon_pickup", "raygun_mark2_zm", "wpck_raymk2", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "use_box_intro", "use_box_intro", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "use_box_2nd_time", "use_box_2nd_time", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "take_weapon_intro", "take_weapon_intro", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "take_weapon_2nd_time", "take_weapon_2nd_time", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "discover_wall_buy", "discover_wall_buy", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "generic_wall_buy", "generic_wall_buy", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "pap_arm", "pap_arm", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "pap_discovered", "capture_zones", undefined, 100 );
    tomb_add_player_dialogue( "player", "tank", "discover_tank", "discover_tank", undefined );
    tomb_add_player_dialogue( "player", "tank", "tank_flame_zombie", "kill_tank", undefined );
    tomb_add_player_dialogue( "player", "tank", "tank_buy", "buy_tank", undefined );
    tomb_add_player_dialogue( "player", "tank", "tank_leave", "exit_tank", undefined );
    tomb_add_player_dialogue( "player", "tank", "tank_cooling", "cool_tank", undefined );
    tomb_add_player_dialogue( "player", "tank", "tank_left_behind", "miss_tank", undefined );
    tomb_add_player_dialogue( "player", "general", "siren_1st_time", "siren_1st_time", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "siren_generic", "siren_generic", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "multiple_mechs", "multiple_mechs", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "discover_mech", "discover_mech", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "mech_defeated", "mech_defeated", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "mech_grab", "rspnd_mech_grab", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "shoot_mech_arm", "shoot_mech_arm", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "shoot_mech_head", "shoot_mech_head", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "shoot_mech_power", "shoot_mech_power", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "rspnd_mech_jump", "rspnd_mech_jump", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "enter_robot", "enter_robot", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "purge_robot", "purge_robot", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "exit_robot", "exit_robot", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "air_chute_landing", "air_chute_landing", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "robot_crush_golden", "robot_crush_golden", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "robot_crush_player", "robot_crush_player", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "discover_robot", "discover_robot", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "see_robots", "see_robots", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "robot_crush_zombie", "robot_crush_zombie", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "robot_crush_mech", "robot_crush_mech", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "shoot_robot", "shoot_robot", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "warn_robot_foot", "warn_robot_foot", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "warn_robot", "warn_robot", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "use_beacon", "use_beacon", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "srnd_rspnd_to_plr_0_neg", "srnd_rspnd_to_plr_0_neg", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "srnd_rspnd_to_plr_1_neg", "srnd_rspnd_to_plr_1_neg", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "srnd_rspnd_to_plr_2_neg", "srnd_rspnd_to_plr_2_neg", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "srnd_rspnd_to_plr_3_neg", "srnd_rspnd_to_plr_3_neg", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "srnd_rspnd_to_plr_0_pos", "srnd_rspnd_to_plr_0_pos", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "srnd_rspnd_to_plr_1_pos", "srnd_rspnd_to_plr_1_pos", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "srnd_rspnd_to_plr_2_pos", "srnd_rspnd_to_plr_2_pos", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "srnd_rspnd_to_plr_3_pos", "srnd_rspnd_to_plr_3_pos", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "achievement", "earn_acheivement", undefined, 100 );
    tomb_add_player_dialogue( "player", "quest", "find_secret", "find_secret", undefined, 100 );
    tomb_add_player_dialogue( "player", "perk", "one_inch", "perk_one_inch", undefined, 100 );
    tomb_add_player_dialogue( "player", "digging", "pickup_shovel", "pickup_shovel", undefined, 100 );
    tomb_add_player_dialogue( "player", "digging", "dig_gun", "dig_gun", undefined, 15 );
    tomb_add_player_dialogue( "player", "digging", "dig_grenade", "dig_grenade", undefined, 15 );
    tomb_add_player_dialogue( "player", "digging", "dig_zombie", "dig_zombie", undefined, 15 );
    tomb_add_player_dialogue( "player", "digging", "dig_staff_part", "dig_staff_part", undefined, 100 );
    tomb_add_player_dialogue( "player", "digging", "dig_powerup", "dig_powerup", undefined, 15 );
    tomb_add_player_dialogue( "player", "digging", "dig_cash", "dig_cash", undefined, 15 );
    tomb_add_player_dialogue( "player", "soul_box", "zm_box_encourage", "zm_box_encourage", undefined, 100 );
    tomb_add_player_dialogue( "player", "zone_capture", "capture_started", "capture_zombies", undefined, 100 );
    tomb_add_player_dialogue( "player", "zone_capture", "recapture_started", "roaming_zombies", undefined, 100 );
    tomb_add_player_dialogue( "player", "zone_capture", "recapture_generator_attacked", "recapture_initiated", undefined, 100 );
    tomb_add_player_dialogue( "player", "zone_capture", "recapture_prevented", "recapture_prevented", undefined, 100 );
    tomb_add_player_dialogue( "player", "zone_capture", "all_generators_captured", "zones_held", undefined, 100 );
    tomb_add_player_dialogue( "player", "lockdown", "power_off", "lockdown_generic", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "struggle_mud", "struggle_mud", undefined, 100 );
    tomb_add_player_dialogue( "player", "general", "discover_dig_site", "discover_dig_site", undefined, 100 );
    tomb_add_player_dialogue( "player", "quadrotor", "kill_drone", "kill_drone", undefined, 100 );
    tomb_add_player_dialogue( "player", "quadrotor", "rspnd_drone_revive", "rspnd_drone_revive", undefined, 100 );
    tomb_add_player_dialogue( "player", "wunderfizz", "perk_wonder", "perk_wonder", undefined, 100 );
    tomb_add_player_dialogue( "player", "samantha", "hear_samantha_1", "hear_samantha_1", undefined, 100 );
    tomb_add_player_dialogue( "player", "samantha", "heroes_confer", "heroes_confer", undefined, 100 );
    tomb_add_player_dialogue( "player", "samantha", "hear_samantha_3", "hear_samantha_3", undefined, 100 );
    init_sam_promises();
}

tomb_add_player_dialogue( speaker, category, type, alias, response, chance )
{
    level.vox zmbvoxadd( speaker, category, type, alias, response );

    if ( isdefined( chance ) )
        add_vox_response_chance( type, chance );
}

tomb_audio_get_mod_type_override( impact, mod, weapon, zombie, instakill, dist, player )
{
    close_dist = 4096;
    med_dist = 15376;
    far_dist = 75625;
    a_str_mod = [];

    if ( isdefined( zombie.staff_dmg ) )
        weapon = zombie.staff_dmg;
    else if ( isdefined( zombie ) && isdefined( zombie.damageweapon ) )
        weapon = zombie.damageweapon;

    if ( weapon == "staff_water_zm" || weapon == "staff_water_upgraded_zm" )
        a_str_mod[a_str_mod.size] = "ice_staff";

    if ( weapon == "staff_water_upgraded2_zm" || weapon == "staff_water_upgraded3_zm" )
        a_str_mod[a_str_mod.size] = "ice_staff_upgrade";

    if ( weapon == "staff_fire_zm" || weapon == "staff_fire_upgraded_zm" )
        a_str_mod[a_str_mod.size] = "fire_staff";

    if ( weapon == "staff_fire_upgraded2_zm" || weapon == "staff_fire_upgraded3_zm" )
        a_str_mod[a_str_mod.size] = "fire_staff_upgrade";

    if ( weapon == "staff_lightning_zm" || weapon == "staff_lightning_upgraded_zm" )
        a_str_mod[a_str_mod.size] = "light_staff";

    if ( weapon == "staff_lightning_upgraded2_zm" || weapon == "staff_lightning_upgraded3_zm" )
        a_str_mod[a_str_mod.size] = "light_staff_upgrade";

    if ( weapon == "staff_air_zm" || weapon == "staff_air_upgraded_zm" )
        a_str_mod[a_str_mod.size] = "wind_staff";

    if ( weapon == "staff_air_upgraded2_zm" || weapon == "staff_air_upgraded3_zm" )
        a_str_mod[a_str_mod.size] = "wind_staff_upgrade";

    if ( is_headshot( weapon, impact, mod ) && dist >= far_dist )
        a_str_mod[a_str_mod.size] = "headshot";

    if ( weapon == "ray_gun_zm" || weapon == "ray_gun_upgraded_zm" )
    {
        if ( dist > far_dist )
        {
            if ( !instakill )
                a_str_mod[a_str_mod.size] = "raygun";
            else
                a_str_mod[a_str_mod.size] = "weapon_instakill";
        }
    }

    if ( weapon == "raygun_mark2_zm" || weapon == "raygun_mark2_upgraded_zm" )
    {
        if ( dist > far_dist )
        {
            if ( !instakill )
                a_str_mod[a_str_mod.size] = "raymk2";
            else
                a_str_mod[a_str_mod.size] = "weapon_instakill";
        }
    }

    if ( is_explosive_damage( mod ) && weapon != "ray_gun_zm" && weapon != "ray_gun_upgraded_zm" && weapon != "raygun_mark2_zm" && weapon != "raygun_mark2_upgraded_zm" && !( isdefined( zombie.is_on_fire ) && zombie.is_on_fire ) )
    {
        if ( !issubstr( weapon, "staff" ) )
        {
            if ( !instakill )
                a_str_mod[a_str_mod.size] = "explosive";
            else
                a_str_mod[a_str_mod.size] = "weapon_instakill";
        }
    }

    if ( instakill )
    {
        if ( mod == "MOD_MELEE" )
            a_str_mod[a_str_mod.size] = "melee_instakill";
        else
            a_str_mod[a_str_mod.size] = "weapon_instakill";
    }

    if ( mod != "MOD_MELEE" && !zombie.has_legs )
        a_str_mod[a_str_mod.size] = "crawler";

    if ( mod != "MOD_BURNED" && dist < close_dist )
        a_str_mod[a_str_mod.size] = "closekill";

    if ( a_str_mod.size == 0 )
        str_mod_final = "default";
    else if ( a_str_mod.size == 1 )
        str_mod_final = a_str_mod[0];
    else
    {
        for ( i = 0; i < a_str_mod.size; i++ )
        {
            if ( cointoss() )
                str_mod_final = a_str_mod[i];
        }

        str_mod_final = a_str_mod[randomint( a_str_mod.size )];
    }

    return str_mod_final;
}

tomb_custom_zombie_oh_shit_vox()
{
    self endon( "death_or_disconnect" );

    while ( true )
    {
        wait 1;

        if ( isdefined( self.oh_shit_vo_cooldown ) && self.oh_shit_vo_cooldown )
            continue;

        players = get_players();
        zombs = get_round_enemy_array();

        if ( players.size <= 1 )
        {
            n_distance = 250;
            n_zombies = 5;
            n_chance = 30;
            n_cooldown_time = 20;
        }
        else
        {
            n_distance = 250;
            n_zombies = 5;
            n_chance = 30;
            n_cooldown_time = 15;
        }

        close_zombs = 0;

        for ( i = 0; i < zombs.size; i++ )
        {
            if ( isdefined( zombs[i].favoriteenemy ) && zombs[i].favoriteenemy == self || !isdefined( zombs[i].favoriteenemy ) )
            {
                if ( distancesquared( zombs[i].origin, self.origin ) < n_distance * n_distance )
                    close_zombs++;
            }
        }

        if ( close_zombs >= n_zombies )
        {
            if ( randomint( 100 ) < n_chance && !( isdefined( self.giant_robot_transition ) && self.giant_robot_transition ) && !isdefined( self.in_giant_robot_head ) )
            {
                self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "oh_shit" );
                self thread global_oh_shit_cooldown_timer( n_cooldown_time );
                wait( n_cooldown_time );
            }
        }
    }
}

global_oh_shit_cooldown_timer( n_cooldown_time )
{
    self endon( "disconnect" );
    self.oh_shit_vo_cooldown = 1;
    wait( n_cooldown_time );
    self.oh_shit_vo_cooldown = 0;
}

tomb_custom_crawler_spawned_vo()
{
    self endon( "death" );

    if ( isdefined( self.a.gib_ref ) && isalive( self ) )
    {
        if ( self.a.gib_ref == "no_legs" || self.a.gib_ref == "right_leg" || self.a.gib_ref == "left_leg" )
        {
            if ( isdefined( self.attacker ) && isplayer( self.attacker ) )
            {
                if ( isdefined( self.attacker.crawler_created_vo_cooldown ) && self.attacker.crawler_created_vo_cooldown )
                    return;

                rand = randomintrange( 0, 100 );

                if ( rand < 15 )
                {
                    self.attacker maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "crawl_spawn" );
                    self.attacker thread crawler_created_vo_cooldown();
                }
            }
        }
    }
}

crawler_created_vo_cooldown()
{
    self endon( "disconnect" );
    self.crawler_created_vo_cooldown = 1;
    wait 30;
    self.crawler_created_vo_cooldown = 0;
}

tomb_audio_custom_weapon_check( weapon, magic_box )
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( isdefined( magic_box ) && magic_box )
    {
        if ( isdefined( self.magic_box_uses ) && self.magic_box_uses == 1 )
            self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "take_weapon_intro" );
        else if ( isdefined( self.magic_box_uses ) && self.magic_box_uses == 2 )
            self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "take_weapon_2nd_time" );
        else
        {
            type = self maps\mp\zombies\_zm_weapons::weapon_type_check( weapon );
            return type;
        }
    }
    else if ( issubstr( weapon, "staff" ) )
    {
        if ( weapon == "staff_fire_zm" )
        {
            self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "pickup_fire" );
            level notify( "staff_crafted_vo", self, 1 );
        }
        else if ( weapon == "staff_water_zm" )
        {
            self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "pickup_ice" );
            level notify( "staff_crafted_vo", self, 4 );
        }
        else if ( weapon == "staff_air_zm" )
        {
            self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "pickup_wind" );
            level notify( "staff_crafted_vo", self, 2 );
        }
        else if ( weapon == "staff_lightning_zm" )
        {
            self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "pickup_light" );
            level notify( "staff_crafted_vo", self, 3 );
        }
    }
    else if ( !isdefined( self.wallbuys_purchased ) )
    {
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "discover_wall_buy" );
        self.wallbuys_purchased = 1;
    }
    else if ( weapon == "sticky_grenade_zm" || weapon == "claymore_zm" )
        self maps\mp\zombies\_zm_audio::create_and_play_dialog( "weapon_pickup", "explo" );
    else
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "generic_wall_buy" );

    return "crappy";
}

tomb_magic_box_used_vo()
{
    if ( !isdefined( self.magic_box_uses ) )
        self.magic_box_uses = 1;
    else
        self.magic_box_uses++;

    if ( self.magic_box_uses == 1 )
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "use_box_intro" );
    else if ( self.magic_box_uses == 2 )
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "use_box_2nd_time" );
}

easter_egg_song_vo( player )
{
    wait 3.5;

    if ( isalive( player ) )
        player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "quest", "find_secret" );
    else
    {
        while ( true )
        {
            a_players = getplayers();

            foreach ( player in a_players )
            {
                if ( isalive( player ) )
                {
                    if ( !( isdefined( player.dontspeak ) && player.dontspeak ) )
                        player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "quest", "find_secret" );
                }
            }
        }

        wait 0.1;
    }
}

play_gramophone_place_vo()
{
    if ( !( isdefined( self.dontspeak ) && self.dontspeak ) )
    {
        if ( !( isdefined( self.gramophone_place_vo ) && self.gramophone_place_vo ) )
        {
            self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "place_gramophone" );
            self.gramophone_place_vo = 1;
        }
    }
}

setup_personality_character_exerts()
{
    level.exert_sounds[1]["burp"][0] = "vox_plr_0_exert_burp_0";
    level.exert_sounds[1]["burp"][1] = "vox_plr_0_exert_burp_1";
    level.exert_sounds[1]["burp"][2] = "vox_plr_0_exert_burp_2";
    level.exert_sounds[1]["burp"][3] = "vox_plr_0_exert_burp_3";
    level.exert_sounds[1]["burp"][4] = "vox_plr_0_exert_burp_4";
    level.exert_sounds[1]["burp"][5] = "vox_plr_0_exert_burp_5";
    level.exert_sounds[1]["burp"][6] = "vox_plr_0_exert_burp_6";
    level.exert_sounds[2]["burp"][0] = "vox_plr_1_exert_burp_0";
    level.exert_sounds[2]["burp"][1] = "vox_plr_1_exert_burp_1";
    level.exert_sounds[2]["burp"][2] = "vox_plr_1_exert_burp_2";
    level.exert_sounds[2]["burp"][3] = "vox_plr_1_exert_burp_3";
    level.exert_sounds[3]["burp"][0] = "vox_plr_2_exert_burp_0";
    level.exert_sounds[3]["burp"][1] = "vox_plr_2_exert_burp_1";
    level.exert_sounds[3]["burp"][2] = "vox_plr_2_exert_burp_2";
    level.exert_sounds[3]["burp"][3] = "vox_plr_2_exert_burp_3";
    level.exert_sounds[3]["burp"][4] = "vox_plr_2_exert_burp_4";
    level.exert_sounds[3]["burp"][5] = "vox_plr_2_exert_burp_5";
    level.exert_sounds[3]["burp"][6] = "vox_plr_2_exert_burp_6";
    level.exert_sounds[4]["burp"][0] = "vox_plr_3_exert_burp_0";
    level.exert_sounds[4]["burp"][1] = "vox_plr_3_exert_burp_1";
    level.exert_sounds[4]["burp"][2] = "vox_plr_3_exert_burp_2";
    level.exert_sounds[4]["burp"][3] = "vox_plr_3_exert_burp_3";
    level.exert_sounds[4]["burp"][4] = "vox_plr_3_exert_burp_4";
    level.exert_sounds[4]["burp"][5] = "vox_plr_3_exert_burp_5";
    level.exert_sounds[4]["burp"][6] = "vox_plr_3_exert_burp_6";
    level.exert_sounds[1]["hitmed"][0] = "vox_plr_0_exert_pain_medium_0";
    level.exert_sounds[1]["hitmed"][1] = "vox_plr_0_exert_pain_medium_1";
    level.exert_sounds[1]["hitmed"][2] = "vox_plr_0_exert_pain_medium_2";
    level.exert_sounds[1]["hitmed"][3] = "vox_plr_0_exert_pain_medium_3";
    level.exert_sounds[2]["hitmed"][0] = "vox_plr_1_exert_pain_medium_0";
    level.exert_sounds[2]["hitmed"][1] = "vox_plr_1_exert_pain_medium_1";
    level.exert_sounds[2]["hitmed"][2] = "vox_plr_1_exert_pain_medium_2";
    level.exert_sounds[2]["hitmed"][3] = "vox_plr_1_exert_pain_medium_3";
    level.exert_sounds[3]["hitmed"][0] = "vox_plr_2_exert_pain_medium_0";
    level.exert_sounds[3]["hitmed"][1] = "vox_plr_2_exert_pain_medium_1";
    level.exert_sounds[3]["hitmed"][2] = "vox_plr_2_exert_pain_medium_2";
    level.exert_sounds[3]["hitmed"][3] = "vox_plr_2_exert_pain_medium_3";
    level.exert_sounds[4]["hitmed"][0] = "vox_plr_3_exert_pain_medium_0";
    level.exert_sounds[4]["hitmed"][1] = "vox_plr_3_exert_pain_medium_1";
    level.exert_sounds[4]["hitmed"][2] = "vox_plr_3_exert_pain_medium_2";
    level.exert_sounds[4]["hitmed"][3] = "vox_plr_3_exert_pain_medium_3";
    level.exert_sounds[1]["hitlrg"][0] = "vox_plr_0_exert_pain_high_0";
    level.exert_sounds[1]["hitlrg"][1] = "vox_plr_0_exert_pain_high_1";
    level.exert_sounds[1]["hitlrg"][2] = "vox_plr_0_exert_pain_high_2";
    level.exert_sounds[1]["hitlrg"][3] = "vox_plr_0_exert_pain_high_3";
    level.exert_sounds[2]["hitlrg"][0] = "vox_plr_1_exert_pain_high_0";
    level.exert_sounds[2]["hitlrg"][1] = "vox_plr_1_exert_pain_high_1";
    level.exert_sounds[2]["hitlrg"][2] = "vox_plr_1_exert_pain_high_2";
    level.exert_sounds[2]["hitlrg"][3] = "vox_plr_1_exert_pain_high_3";
    level.exert_sounds[3]["hitlrg"][0] = "vox_plr_2_exert_pain_high_0";
    level.exert_sounds[3]["hitlrg"][1] = "vox_plr_2_exert_pain_high_1";
    level.exert_sounds[3]["hitlrg"][2] = "vox_plr_2_exert_pain_high_2";
    level.exert_sounds[3]["hitlrg"][3] = "vox_plr_2_exert_pain_high_3";
    level.exert_sounds[4]["hitlrg"][0] = "vox_plr_3_exert_pain_high_0";
    level.exert_sounds[4]["hitlrg"][1] = "vox_plr_3_exert_pain_high_1";
    level.exert_sounds[4]["hitlrg"][2] = "vox_plr_3_exert_pain_high_2";
    level.exert_sounds[4]["hitlrg"][3] = "vox_plr_3_exert_pain_high_3";
}

tomb_audio_custom_response_line( player, index, category, type )
{
    if ( type == "revive_up" )
        player thread play_pos_neg_response_on_closest_player( "general", "heal_revived", "kills" );
    else if ( type == "headshot" )
        player thread play_pos_neg_response_on_closest_player( "kill", "headshot_respond_to_plr_" + player.characterindex, "kills" );
    else if ( type == "oh_shit" )
    {
        player thread play_pos_neg_response_on_closest_player( "general", "srnd_rspnd_to_plr_" + player.characterindex, "kills" );
        player thread global_oh_shit_cooldown_timer( 15 );
    }
}

play_vo_category_on_closest_player( category, type )
{
    a_players = getplayers();

    if ( a_players.size <= 1 )
        return;

    arrayremovevalue( a_players, self );
    a_closest = arraysort( a_players, self.origin, 1 );

    if ( distancesquared( self.origin, a_closest[0].origin ) <= 250000 )
    {
        if ( isalive( a_closest[0] ) )
            a_closest[0] maps\mp\zombies\_zm_audio::create_and_play_dialog( category, type );
    }
}

play_pos_neg_response_on_closest_player( category, type, str_stat )
{
    a_players = getplayers();

    if ( a_players.size <= 1 )
        return;

    arrayremovevalue( a_players, self );
    a_closest = arraysort( a_players, self.origin, 1 );

    foreach ( player in a_closest )
    {
        if ( distancesquared( self.origin, player.origin ) <= 250000 )
        {
            if ( isalive( player ) )
            {
                str_suffix = get_positive_or_negative_suffix( self, player, str_stat );

                if ( isdefined( str_suffix ) )
                    type += str_suffix;

                player maps\mp\zombies\_zm_audio::create_and_play_dialog( category, type );
                break;
            }
        }
    }
}

get_positive_or_negative_suffix( e_player1, e_player2, str_stat )
{
    n_player1_stat = e_player1 maps\mp\gametypes_zm\_globallogic_score::getpersstat( str_stat );
    n_player2_stat = e_player2 maps\mp\gametypes_zm\_globallogic_score::getpersstat( str_stat );

    if ( !isdefined( n_player1_stat ) || !isdefined( n_player2_stat ) )
        return undefined;

    if ( n_player1_stat >= n_player2_stat )
        str_result = "_pos";
    else
        str_result = "_neg";

    return str_result;
}

struggle_mud_vo()
{
    self endon( "disconnect" );
    self.played_mud_vo = 1;
    self maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "struggle_mud" );

    self waittill( "mud_slowdown_cleared" );

    self thread struggle_mud_vo_cooldown();
}

struggle_mud_vo_cooldown()
{
    self endon( "disconnect" );
    wait 600;
    self.played_mud_vo = 0;
}

discover_dig_site_vo()
{
    flag_wait( "activate_zone_nml" );
    s_origin = getstruct( "discover_dig_site_vo_trigger", "targetname" );
    s_origin.unitrigger_stub = spawnstruct();
    s_origin.unitrigger_stub.origin = s_origin.origin;
    s_origin.unitrigger_stub.script_width = 320;
    s_origin.unitrigger_stub.script_length = 88;
    s_origin.unitrigger_stub.script_height = 256;
    s_origin.unitrigger_stub.script_unitrigger_type = "unitrigger_box";
    s_origin.unitrigger_stub.angles = ( 0, 0, 0 );
    maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( s_origin.unitrigger_stub, ::discover_dig_site_trigger_touch );
}

discover_dig_site_trigger_touch()
{
    while ( true )
    {
        self waittill( "trigger", player );

        if ( isplayer( player ) )
        {
            if ( !( isdefined( player.dontspeak ) && player.dontspeak ) )
            {
                player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "discover_dig_site" );
                maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.stub );
                break;
            }
        }
    }
}

maxis_audio_logs()
{
    a_s_radios = getstructarray( "maxis_audio_log", "targetname" );

    foreach ( s_origin in a_s_radios )
    {
        s_origin.unitrigger_stub = spawnstruct();
        s_origin.unitrigger_stub.origin = s_origin.origin;
        s_origin.unitrigger_stub.radius = 36;
        s_origin.unitrigger_stub.height = 256;
        s_origin.unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
        s_origin.unitrigger_stub.hint_string = &"ZM_TOMB_MAXIS_AUDIOLOG";
        s_origin.unitrigger_stub.cursor_hint = "HINT_NOICON";
        s_origin.unitrigger_stub.require_look_at = 1;
        s_origin.unitrigger_stub.script_int = s_origin.script_int;
        maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( s_origin.unitrigger_stub, ::maxis_audio_log_think );
    }
}

discover_pack_a_punch()
{
    t_pap_intro = getent( "pack_a_punch_intro_trigger", "targetname" );

    if ( !isdefined( t_pap_intro ) )
        return;

    s_lookat = getstruct( t_pap_intro.target, "targetname" );

    while ( true )
    {
        t_pap_intro waittill( "trigger", e_player );

        if ( !isdefined( e_player.discover_pap_vo_played ) )
            e_player.discover_pap_vo_played = 0;

        if ( !e_player.discover_pap_vo_played )
        {
            if ( vectordot( anglestoforward( e_player getplayerangles() ), vectornormalize( s_lookat.origin - e_player.origin ) ) > 0.8 && e_player can_player_speak() )
            {
                e_player.discover_pap_vo_played = 1;
                e_player create_and_play_dialog( "general", "pap_discovered" );

                foreach ( player in get_players() )
                {
                    if ( distance( player.origin, e_player.origin ) < 800 )
                        player.discover_pap_vo_played = 1;
                }
            }
        }
    }
}

can_player_speak()
{
    return isplayer( self ) && !( isdefined( self.dontspeak ) && self.dontspeak ) && self getclientfieldtoplayer( "isspeaking" ) == 0;
}

maxis_audio_log_think()
{
    self waittill( "trigger", player );

    if ( !isplayer( player ) || !is_player_valid( player ) )
        return;

    level thread play_maxis_audio_log( self.stub.origin, self.stub.script_int );
}

play_maxis_audio_log( v_trigger_origin, n_audiolog_id )
{
    a_audiolog = get_audiolog_vo();
    a_audiolog_to_play = a_audiolog[n_audiolog_id];

    if ( n_audiolog_id == 4 )
        flag_set( "maxis_audiolog_gr0_playing" );
    else if ( n_audiolog_id == 5 )
        flag_set( "maxis_audiolog_gr1_playing" );
    else if ( n_audiolog_id == 6 )
        flag_set( "maxis_audiolog_gr2_playing" );

    e_vo_origin = spawn( "script_origin", v_trigger_origin );
    flag_set( "maxis_audio_log_" + n_audiolog_id );
    a_s_triggers = getstructarray( "maxis_audio_log", "targetname" );

    foreach ( s_trigger in a_s_triggers )
    {
        if ( s_trigger.script_int == n_audiolog_id )
            break;
    }

    level thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( s_trigger.unitrigger_stub );

    for ( i = 0; i < a_audiolog_to_play.size; i++ )
    {
        e_vo_origin playsoundwithnotify( a_audiolog_to_play[i], a_audiolog_to_play[i] + "_done" );

        e_vo_origin waittill( a_audiolog_to_play[i] + "_done" );
    }

    e_vo_origin delete();

    if ( n_audiolog_id == 4 )
        flag_clear( "maxis_audiolog_gr0_playing" );
    else if ( n_audiolog_id == 5 )
        flag_clear( "maxis_audiolog_gr1_playing" );
    else if ( n_audiolog_id == 6 )
        flag_clear( "maxis_audiolog_gr2_playing" );

    level thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( s_trigger.unitrigger_stub, ::maxis_audio_log_think );
}

reset_maxis_audiolog_unitrigger( n_robot_id )
{
    if ( n_robot_id == 0 )
        n_script_int = 4;
    else if ( n_robot_id == 1 )
        n_script_int = 5;
    else if ( n_robot_id == 2 )
        n_script_int = 6;

    if ( flag( "maxis_audio_log_" + n_script_int ) )
        return;

    a_s_radios = getstructarray( "maxis_audio_log", "targetname" );

    foreach ( s_origin in a_s_radios )
    {
        if ( s_origin.script_int == n_script_int )
        {
            if ( isdefined( s_origin.unitrigger_stub ) )
                maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( s_origin.unitrigger_stub );
        }
    }
}

restart_maxis_audiolog_unitrigger( n_robot_id )
{
    if ( n_robot_id == 0 )
        n_script_int = 4;
    else if ( n_robot_id == 1 )
        n_script_int = 5;
    else if ( n_robot_id == 2 )
        n_script_int = 6;

    a_s_radios = getstructarray( "maxis_audio_log", "targetname" );

    foreach ( s_origin in a_s_radios )
    {
        if ( s_origin.script_int == n_script_int )
        {
            if ( isdefined( s_origin.unitrigger_stub ) )
                maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( s_origin.unitrigger_stub, ::maxis_audio_log_think );
        }
    }
}

get_audiolog_vo()
{
    a_audiologs = [];
    a_audiologs[1] = [];
    a_audiologs[1][0] = "vox_maxi_audio_log_1_1_0";
    a_audiologs[1][1] = "vox_maxi_audio_log_1_2_0";
    a_audiologs[1][2] = "vox_maxi_audio_log_1_3_0";
    a_audiologs[2] = [];
    a_audiologs[2][0] = "vox_maxi_audio_log_2_1_0";
    a_audiologs[2][1] = "vox_maxi_audio_log_2_2_0";
    a_audiologs[3] = [];
    a_audiologs[3][0] = "vox_maxi_audio_log_3_1_0";
    a_audiologs[3][1] = "vox_maxi_audio_log_3_2_0";
    a_audiologs[3][2] = "vox_maxi_audio_log_3_3_0";
    a_audiologs[4] = [];
    a_audiologs[4][0] = "vox_maxi_audio_log_4_1_0";
    a_audiologs[4][1] = "vox_maxi_audio_log_4_2_0";
    a_audiologs[4][2] = "vox_maxi_audio_log_4_3_0";
    a_audiologs[5] = [];
    a_audiologs[5][0] = "vox_maxi_audio_log_5_1_0";
    a_audiologs[5][1] = "vox_maxi_audio_log_5_2_0";
    a_audiologs[5][2] = "vox_maxi_audio_log_5_3_0";
    a_audiologs[6] = [];
    a_audiologs[6][0] = "vox_maxi_audio_log_6_1_0";
    a_audiologs[6][1] = "vox_maxi_audio_log_6_2_0";
    return a_audiologs;
}

start_narrative_vo()
{
    flag_wait( "start_zombie_round_logic" );
    set_players_dontspeak( 1 );
    wait 10;

    if ( is_game_solo() )
        game_start_solo_vo();
    else
        game_start_vo();

    level waittill( "end_of_round" );

    level thread round_two_end_narrative_vo();

    if ( is_game_solo() )
        round_one_end_solo_vo();
    else
        round_one_end_vo();

    flag_set( "round_one_narrative_vo_complete" );
}

start_samantha_intro_vo()
{
    while ( true )
    {
        level waittill( "start_of_round" );

        if ( level.round_number == 5 )
            samantha_intro_1();
        else if ( level.round_number == 6 )
            samantha_intro_2();
        else if ( level.round_number == 7 )
        {
            samantha_intro_3();
            flag_set( "samantha_intro_done" );
            break;
        }
    }
}

samantha_intro_1()
{
/#
    iprintln( "samantha_intro_1" );
#/
    players = getplayers();

    if ( !isdefined( players[0] ) )
        return;

    flag_waitopen( "story_vo_playing" );
    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );
    samanthasay( "vox_sam_sam_help_5_0", players[0], 1, 1 );
    players = getplayers();

    foreach ( player in players )
    {
        if ( player.character_name != "Richtofen" )
        {
            player play_category_on_player_character_if_present( "hear_samantha_1", player.character_name );
            wait 1;
            play_line_on_player_character_if_present( "vox_plr_2_hear_samantha_1_0", "Richtofen" );
            break;
        }
    }

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

samantha_intro_2()
{
/#
    iprintln( "samantha_intro_2" );
#/
    player_richtofen = get_player_character_if_present( "Richtofen" );

    if ( !isdefined( player_richtofen ) )
        return;

    flag_waitopen( "story_vo_playing" );
    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );

    if ( isdefined( player_richtofen ) )
    {
        nearest_friend = get_nearest_friend_within_speaking_distance( player_richtofen );

        if ( isdefined( nearest_friend ) )
        {
            nearest_friend play_category_on_player_character_if_present( "heroes_confer", nearest_friend.character_name );
            wait 1;
            play_line_on_player_character_if_present( "vox_plr_2_heroes_confer_0", "Richtofen" );
        }
    }

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

samantha_intro_3()
{
/#
    iprintln( "samantha_intro_3" );
#/
    players = getplayers();

    if ( !isdefined( players[0] ) )
        return;

    flag_waitopen( "story_vo_playing" );
    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );
    samanthasay( "vox_sam_hear_samantha_3_0", players[0], 1, 1 );
    players = getplayers();
    player = players[randomintrange( 0, players.size )];

    if ( isdefined( player ) )
        player play_category_on_player_character_if_present( "hear_samantha_3", player.character_name );

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

play_category_on_player_character_if_present( category, character_name )
{
    vox_line_prefix = undefined;

    switch ( character_name )
    {
        case "Dempsey":
            vox_line_prefix = "vox_plr_0_";
            break;
        case "Nikolai":
            vox_line_prefix = "vox_plr_1_";
            break;
        case "Richtofen":
            vox_line_prefix = "vox_plr_2_";
            break;
        case "Takeo":
            vox_line_prefix = "vox_plr_3_";
            break;
    }

    vox_line = vox_line_prefix + category + "_0";
    play_line_on_player_character_if_present( vox_line, character_name );
}

get_nearest_friend_within_speaking_distance( other_player )
{
    distance_nearest = 800;
    nearest_friend = undefined;
    players = getplayers();

    foreach ( player in players )
    {
        distance_between_players = distance( player.origin, other_player.origin );

        if ( player != other_player && distance_between_players < distance_nearest )
        {
            nearest_friend = player;
            distance_nearest = distance_between_players;
        }
    }

    if ( isdefined( nearest_friend ) )
        return nearest_friend;
    else
        return undefined;
}

play_line_on_player_character_if_present( vox_line, character_name )
{
    player_character = get_player_character_if_present( character_name );

    if ( isdefined( player_character ) )
    {
/#
        iprintln( "" + character_name + " says " + vox_line );
#/
        player_character playsoundwithnotify( vox_line, "sound_done" + vox_line );

        player_character waittill( "sound_done" + vox_line );

        return true;
    }
    else
        return false;
}

get_player_character_if_present( character_name )
{
    players = getplayers();

    foreach ( player in players )
    {
        if ( player.character_name == character_name )
            return player;
    }

    return undefined;
}

round_two_end_narrative_vo()
{
    level waittill( "end_of_round" );

    flag_wait( "round_one_narrative_vo_complete" );

    if ( flag( "generator_find_vo_playing" ) )
    {
        flag_waitopen( "generator_find_vo_playing" );
        wait 3;
    }

    if ( is_game_solo() )
        round_two_end_solo_vo();
}

game_start_solo_vo()
{
    if ( flag( "story_vo_playing" ) )
        return;

    players = getplayers();
    e_speaker = players[0];

    if ( !isdefined( e_speaker ) )
        return;

    a_convo = build_game_start_solo_convo();
    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );
    lines = a_convo[e_speaker.character_name];

    if ( isarray( lines ) )
    {
        for ( i = 0; i < lines.size; i++ )
        {
            e_speaker playsoundwithnotify( lines[i], "sound_done" + lines[i] );

            e_speaker waittill( "sound_done" + lines[i] );

            wait 1.0;
        }
    }
    else
    {
        e_speaker playsoundwithnotify( a_convo[e_speaker.character_name], "sound_done" + a_convo[e_speaker.character_name] );

        e_speaker waittill( "sound_done" + a_convo[e_speaker.character_name] );
    }

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

build_game_start_solo_convo()
{
    a_game_start_solo_convo = [];
    a_game_start_solo_convo["Dempsey"] = "vox_plr_0_game_start_0";
    a_game_start_solo_convo["Nikolai"] = "vox_plr_1_game_start_0";
    a_game_start_solo_convo["Richtofen"] = [];
    a_game_start_solo_convo["Richtofen"][0] = "vox_plr_2_game_start_0";
    a_game_start_solo_convo["Richtofen"][1] = "vox_plr_2_game_start_1";
    a_game_start_solo_convo["Takeo"] = "vox_plr_3_game_start_0";
    return a_game_start_solo_convo;
}

game_start_vo()
{
    players = getplayers();

    if ( players.size <= 1 )
        return;

    if ( flag( "story_vo_playing" ) )
        return;

    a_game_start_convo = build_game_start_convo();
    flag_set( "story_vo_playing" );
    e_dempsey = undefined;
    e_nikolai = undefined;
    e_richtofen = undefined;
    e_takeo = undefined;

    foreach ( player in players )
    {
        if ( isdefined( player ) )
        {
            switch ( player.character_name )
            {
                case "Dempsey":
                    e_dempsey = player;
                    break;
                case "Nikolai":
                    e_nikolai = player;
                    break;
                case "Richtofen":
                    e_richtofen = player;
                    break;
                case "Takeo":
                    e_takeo = player;
                    break;
            }
        }
    }

    set_players_dontspeak( 1 );

    for ( i = 0; i < a_game_start_convo.size; i++ )
    {
        players = getplayers();

        if ( players.size <= 1 )
        {
            set_players_dontspeak( 0 );
            flag_clear( "story_vo_playing" );
            return;
        }

        if ( !isdefined( e_richtofen ) )
            continue;

        line_number = i + 1;

        if ( line_number == 2 )
        {
            a_richtofen_lines = a_game_start_convo["line_" + line_number];

            for ( j = 0; j < a_richtofen_lines.size; j++ )
            {
                e_richtofen playsoundwithnotify( a_richtofen_lines[j], "sound_done" + a_richtofen_lines[j] );

                e_richtofen waittill( "sound_done" + a_richtofen_lines[j] );
            }

            continue;
        }

        arrayremovevalue( players, e_richtofen );
        players = get_array_of_closest( e_richtofen.origin, players );
        e_speaker = players[0];

        if ( !isdefined( e_speaker ) )
            continue;

        e_speaker playsoundwithnotify( a_game_start_convo["line_" + line_number][e_speaker.character_name], "sound_done" + a_game_start_convo["line_" + line_number][e_speaker.character_name] );

        e_speaker waittill( "sound_done" + a_game_start_convo["line_" + line_number][e_speaker.character_name] );
    }

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

build_game_start_convo()
{
    a_game_start_convo = [];
    a_game_start_convo["line_1"] = [];
    a_game_start_convo["line_1"]["Dempsey"] = "vox_plr_0_game_start_meet_2_0";
    a_game_start_convo["line_1"]["Nikolai"] = "vox_plr_1_game_start_meet_1_0";
    a_game_start_convo["line_1"]["Takeo"] = "vox_plr_3_game_start_meet_3_0";
    a_game_start_convo["line_2"] = [];
    a_game_start_convo["line_2"][0] = "vox_plr_2_game_start_meet_4_0";
    a_game_start_convo["line_2"][1] = "vox_plr_2_generator_find_0";
    a_game_start_convo["line_3"] = [];
    a_game_start_convo["line_3"]["Dempsey"] = "vox_plr_0_generator_find_0";
    a_game_start_convo["line_3"]["Nikolai"] = "vox_plr_1_generator_find_0";
    a_game_start_convo["line_3"]["Takeo"] = "vox_plr_3_generator_find_0";
    return a_game_start_convo;
}

run_staff_crafted_vo( str_sam_line )
{
    wait 1.0;

    while ( isdefined( self.isspeaking ) && self.isspeaking )
        wait_network_frame();

    if ( level.n_staffs_crafted == 4 )
        all_staffs_crafted_vo();
    else if ( isdefined( str_sam_line ) )
    {
        flag_waitopen( "story_vo_playing" );
        flag_set( "story_vo_playing" );
        set_players_dontspeak( 1 );
        samanthasay( str_sam_line, self, 1 );
        set_players_dontspeak( 0 );
        flag_clear( "story_vo_playing" );
    }
}

staff_craft_vo()
{
    staff_crafted = [];
    lines = array( "vox_sam_1st_staff_crafted_0", "vox_sam_2nd_staff_crafted_0", "vox_sam_3rd_staff_crafted_0" );

    while ( staff_crafted.size < 4 )
    {
        level waittill( "staff_crafted_vo", e_crafter, n_element );

        if ( !( isdefined( staff_crafted[n_element] ) && staff_crafted[n_element] ) )
        {
            staff_crafted[n_element] = 1;
            line = lines[level.n_staffs_crafted - 1];
            e_crafter thread run_staff_crafted_vo( line );
        }
    }
}

all_staffs_crafted_vo()
{
    while ( flag( "story_vo_playing" ) )
        wait_network_frame();

    a_convo = build_all_staffs_crafted_vo();
    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );

    for ( i = 0; i < a_convo.size; i++ )
    {
        line_number = i + 1;
        index = "line_" + line_number;

        if ( isdefined( a_convo[index]["Sam"] ) )
        {
            samanthasay( a_convo[index]["Sam"], self );
            continue;
        }

        line = a_convo[index][self.character_name];
        self playsoundwithnotify( line, "sound_done" + line );

        self waittill( "sound_done" + line );
    }

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

build_all_staffs_crafted_vo()
{
    a_staff_convo = [];
    a_staff_convo["line_1"] = [];
    a_staff_convo["line_1"]["Sam"] = "vox_sam_4th_staff_crafted_0";
    a_staff_convo["line_2"] = [];
    a_staff_convo["line_2"]["Dempsey"] = "vox_plr_0_4th_staff_crafted_0";
    a_staff_convo["line_2"]["Nikolai"] = "vox_plr_1_4th_staff_crafted_0";
    a_staff_convo["line_2"]["Richtofen"] = "vox_plr_2_4th_staff_crafted_0";
    a_staff_convo["line_2"]["Takeo"] = "vox_plr_3_4th_staff_crafted_0";
    a_staff_convo["line_3"] = [];
    a_staff_convo["line_3"]["Sam"] = "vox_sam_4th_staff_crafted_1";
    a_staff_convo["line_4"] = [];
    a_staff_convo["line_4"]["Dempsey"] = "vox_plr_0_4th_staff_crafted_1";
    a_staff_convo["line_4"]["Nikolai"] = "vox_plr_1_4th_staff_crafted_1";
    a_staff_convo["line_4"]["Richtofen"] = "vox_plr_2_4th_staff_crafted_1";
    a_staff_convo["line_4"]["Takeo"] = "vox_plr_3_4th_staff_crafted_1";
    a_staff_convo["line_5"] = [];
    a_staff_convo["line_5"]["Sam"] = "vox_sam_generic_encourage_6";
    return a_staff_convo;
}

get_left_behind_plea()
{
    pl_num = 0;

    if ( self.character_name == "Nikolai" )
        pl_num = 1;
    else if ( self.character_name == "Richtofen" )
        pl_num = 2;
    else if ( self.character_name == "Takeo" )
        pl_num = 3;

    return "vox_plr_" + pl_num + "_miss_tank_" + randomint( 3 );
}

get_left_behind_response( e_victim )
{
    if ( self.character_name == "Dempsey" )
    {
        if ( cointoss() )
            return "vox_plr_0_tank_rspnd_generic_0";
        else if ( e_victim.character_name == "Nikolai" )
            return "vox_plr_0_tank_rspnd_to_plr_1_0";
        else if ( e_victim.character_name == "Richtofen" )
            return "vox_plr_0_tank_rspnd_to_plr_2_0";
        else if ( e_victim.character_name == "Takeo" )
            return "vox_plr_0_tank_rspnd_to_plr_3_0";
    }
    else if ( self.character_name == "Nikolai" )
    {
        if ( cointoss() )
            return "vox_plr_1_tank_rspnd_generic_0";
        else if ( e_victim.character_name == "Dempsey" )
            return "vox_plr_1_tank_rspnd_to_plr_0_0";
        else if ( e_victim.character_name == "Richtofen" )
            return "vox_plr_1_tank_rspnd_to_plr_2_0";
        else if ( e_victim.character_name == "Takeo" )
            return "vox_plr_1_tank_rspnd_to_plr_3_0";
    }
    else if ( self.character_name == "Richtofen" )
    {
        if ( cointoss() )
            return "vox_plr_2_tank_rspnd_generic_0";
        else if ( e_victim.character_name == "Dempsey" )
            return "vox_plr_2_tank_rspnd_to_plr_0_0";
        else if ( e_victim.character_name == "Nikolai" )
            return "vox_plr_2_tank_rspnd_to_plr_1_0";
        else if ( e_victim.character_name == "Takeo" )
            return "vox_plr_2_tank_rspnd_to_plr_3_0";
    }
    else if ( self.character_name == "Takeo" )
    {
        if ( cointoss() )
            return "vox_plr_3_tank_rspnd_generic_0";
        else if ( e_victim.character_name == "Dempsey" )
            return "vox_plr_3_tank_rspnd_to_plr_0_0";
        else if ( e_victim.character_name == "Nikolai" )
            return "vox_plr_3_tank_rspnd_to_plr_1_0";
        else if ( e_victim.character_name == "Richtofen" )
            return "vox_plr_3_tank_rspnd_to_plr_2_0";
    }

    return undefined;
}

tank_left_behind_vo( e_victim, e_rider )
{
    if ( !isdefined( e_victim ) || !isdefined( e_rider ) )
        return;

    if ( flag( "story_vo_playing" ) )
        return;

    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );
    e_victim.isspeaking = 1;
    e_rider.isspeaking = 1;
    str_plea_line = e_victim get_left_behind_plea();
    e_victim playsoundwithnotify( str_plea_line, "sound_done" + str_plea_line );

    e_victim waittill( "sound_done" + str_plea_line );

    str_rider_line = e_rider get_left_behind_response( e_victim );
    e_victim playsoundwithnotify( str_rider_line, "sound_done" + str_rider_line );

    e_victim waittill( "sound_done" + str_rider_line );

    e_victim.isspeaking = 0;
    e_rider.isspeaking = 0;
    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

round_one_end_solo_vo()
{
    if ( flag( "story_vo_playing" ) )
        return;

    players = getplayers();
    e_speaker = players[0];

    if ( !isdefined( e_speaker ) )
        return;

    a_convo = build_round_one_end_solo_convo();
    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );
    lines = a_convo[e_speaker.character_name];

    if ( isarray( lines ) )
    {
        for ( i = 0; i < lines.size; i++ )
        {
            e_speaker playsoundwithnotify( lines[i], "sound_done" + lines[i] );

            e_speaker waittill( "sound_done" + lines[i] );

            wait 1.0;
        }
    }
    else
    {
        e_speaker playsoundwithnotify( a_convo[e_speaker.character_name], "sound_done" + a_convo[e_speaker.character_name] );

        e_speaker waittill( "sound_done" + a_convo[e_speaker.character_name] );
    }

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

build_round_one_end_solo_convo()
{
    a_round_one_end_solo_convo = [];
    a_round_one_end_solo_convo["Dempsey"] = [];
    a_round_one_end_solo_convo["Dempsey"][0] = "vox_plr_0_end_round_1_5_0";
    a_round_one_end_solo_convo["Dempsey"][1] = "vox_plr_0_end_round_1_6_1";
    a_round_one_end_solo_convo["Nikolai"] = "vox_plr_1_end_round_1_9_0";
    a_round_one_end_solo_convo["Richtofen"] = "vox_plr_2_end_round_1_7_0";
    a_round_one_end_solo_convo["Takeo"] = "vox_plr_3_end_round_1_8_0";
    return a_round_one_end_solo_convo;
}

round_one_end_vo()
{
    players = getplayers();

    if ( players.size <= 1 )
        return;

    if ( flag( "story_vo_playing" ) )
        return;

    a_convo = build_round_one_end_convo();
    flag_set( "story_vo_playing" );
    e_dempsey = undefined;
    e_nikolai = undefined;
    e_richtofen = undefined;
    e_takeo = undefined;

    foreach ( player in players )
    {
        if ( isdefined( player ) )
        {
            switch ( player.character_name )
            {
                case "Dempsey":
                    e_dempsey = player;
                    break;
                case "Nikolai":
                    e_nikolai = player;
                    break;
                case "Richtofen":
                    e_richtofen = player;
                    break;
                case "Takeo":
                    e_takeo = player;
                    break;
            }
        }
    }

    set_players_dontspeak( 1 );

    for ( i = 0; i < a_convo.size; i++ )
    {
        players = getplayers();

        if ( players.size <= 1 )
        {
            set_players_dontspeak( 0 );
            flag_clear( "story_vo_playing" );
            return;
        }

        if ( !isdefined( e_richtofen ) )
            continue;

        line_number = i + 1;

        if ( line_number == 2 )
        {
            a_richtofen_lines = a_convo["line_" + line_number];

            for ( j = 0; j < a_richtofen_lines.size; j++ )
            {
                e_richtofen playsoundwithnotify( a_richtofen_lines[j], "sound_done" + a_richtofen_lines[j] );

                e_richtofen waittill( "sound_done" + a_richtofen_lines[j] );
            }

            continue;
        }

        arrayremovevalue( players, e_richtofen );
        players = get_array_of_closest( e_richtofen.origin, players );
        e_speaker = players[0];

        if ( !isdefined( e_speaker ) )
            continue;

        e_speaker playsoundwithnotify( a_convo["line_" + line_number][e_speaker.character_name], "sound_done" + a_convo["line_" + line_number][e_speaker.character_name] );

        e_speaker waittill( "sound_done" + a_convo["line_" + line_number][e_speaker.character_name] );
    }

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

build_round_one_end_convo()
{
    a_round_one_end_convo = [];
    a_round_one_end_convo["line_1"] = [];
    a_round_one_end_convo["line_1"]["Dempsey"] = "vox_plr_0_end_round_1_1_0";
    a_round_one_end_convo["line_1"]["Nikolai"] = "vox_plr_1_end_round_1_3_0";
    a_round_one_end_convo["line_1"]["Takeo"] = "vox_plr_3_end_round_1_2_0";
    a_round_one_end_convo["line_2"] = [];
    a_round_one_end_convo["line_2"][0] = "vox_plr_2_story_exposition_4_0";
    a_round_one_end_convo["line_3"] = [];
    a_round_one_end_convo["line_3"]["Dempsey"] = "vox_plr_0_during_round_1_0";
    a_round_one_end_convo["line_3"]["Nikolai"] = "vox_plr_1_during_round_2_0";
    a_round_one_end_convo["line_3"]["Takeo"] = "vox_plr_3_during_round_2_0";
    return a_round_one_end_convo;
}

round_two_end_solo_vo()
{
    if ( flag( "story_vo_playing" ) )
        return;

    players = getplayers();
    e_speaker = players[0];

    if ( !isdefined( e_speaker ) )
        return;

    a_convo = build_round_two_end_solo_convo();
    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );
    lines = a_convo[e_speaker.character_name];

    if ( isarray( lines ) )
    {
        for ( i = 0; i < lines.size; i++ )
        {
            e_speaker playsoundwithnotify( lines[i], "sound_done" + lines[i] );

            e_speaker waittill( "sound_done" + lines[i] );

            wait 1.0;
        }
    }
    else
    {
        e_speaker playsoundwithnotify( a_convo[e_speaker.character_name], "sound_done" + a_convo[e_speaker.character_name] );

        e_speaker waittill( "sound_done" + a_convo[e_speaker.character_name] );
    }

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

build_round_two_end_solo_convo()
{
    a_round_two_end_solo_convo = [];
    a_round_two_end_solo_convo["Dempsey"] = "vox_plr_0_end_round_2_1_0";
    a_round_two_end_solo_convo["Nikolai"] = "vox_plr_1_end_round_2_5_0";
    a_round_two_end_solo_convo["Richtofen"] = [];
    a_round_two_end_solo_convo["Richtofen"][0] = "vox_plr_2_end_round_2_2_0";
    a_round_two_end_solo_convo["Richtofen"][1] = "vox_plr_2_end_round_2_3_1";
    a_round_two_end_solo_convo["Takeo"] = "vox_plr_3_end_round_2_4_0";
    return a_round_two_end_solo_convo;
}

first_magic_box_seen_vo()
{
    flag_wait( "start_zombie_round_logic" );
    magicbox = level.chests[level.chest_index];
    a_players = getplayers();

    foreach ( player in a_players )
        player thread wait_and_play_first_magic_box_seen_vo( magicbox.unitrigger_stub );
}

wait_and_play_first_magic_box_seen_vo( struct )
{
    self endon( "disconnect" );
    level endon( "first_maigc_box_discovered" );

    while ( true )
    {
        if ( distancesquared( self.origin, struct.origin ) < 40000 )
        {
            if ( self is_player_looking_at( struct.origin, 0.75 ) )
            {
                if ( !( isdefined( self.dontspeak ) && self.dontspeak ) )
                {
                    if ( flag( "story_vo_playing" ) )
                    {
                        wait 0.1;
                        continue;
                    }

                    players = getplayers();
                    a_speakers = [];

                    foreach ( player in players )
                    {
                        if ( isdefined( player ) && distance2dsquared( player.origin, self.origin ) <= 1000000 )
                        {
                            switch ( player.character_name )
                            {
                                case "Dempsey":
                                    e_dempsey = player;
                                    a_speakers[a_speakers.size] = e_dempsey;
                                    break;
                                case "Nikolai":
                                    e_nikolai = player;
                                    a_speakers[a_speakers.size] = e_nikolai;
                                    break;
                                case "Richtofen":
                                    e_richtofen = player;
                                    a_speakers[a_speakers.size] = e_richtofen;
                                    break;
                                case "Takeo":
                                    e_takeo = player;
                                    a_speakers[a_speakers.size] = e_takeo;
                                    break;
                            }
                        }
                    }

                    if ( !isdefined( e_richtofen ) )
                    {
                        wait 0.1;
                        continue;
                    }

                    if ( a_speakers.size < 2 )
                    {
                        wait 0.1;
                        continue;
                    }

                    flag_set( "story_vo_playing" );
                    set_players_dontspeak( 1 );
                    a_convo = build_first_magic_box_seen_vo();

                    if ( isdefined( e_richtofen ) )
                    {
                        e_richtofen playsoundwithnotify( a_convo[0][e_richtofen.character_name], "sound_done" + a_convo[0][e_richtofen.character_name] );

                        e_richtofen waittill( "sound_done" + a_convo[0][e_richtofen.character_name] );
                    }

                    if ( isdefined( struct.trigger_target ) && isdefined( struct.trigger_target.is_locked ) )
                    {
                        arrayremovevalue( a_speakers, e_richtofen );
                        a_speakers = get_array_of_closest( e_richtofen.origin, a_speakers );
                        e_speaker = a_speakers[0];

                        if ( distancesquared( e_speaker.origin, e_richtofen.origin ) < 2250000 )
                        {
                            if ( isdefined( e_speaker ) )
                            {
                                e_speaker playsoundwithnotify( a_convo[1][e_speaker.character_name], "sound_done" + a_convo[1][e_speaker.character_name] );

                                e_speaker waittill( "sound_done" + a_convo[1][e_speaker.character_name] );
                            }
                        }
                    }

                    if ( isdefined( struct.trigger_target ) && isdefined( struct.trigger_target.is_locked ) )
                    {
                        if ( struct.trigger_target.is_locked == 1 )
                        {
                            if ( isdefined( e_richtofen ) )
                            {
                                e_richtofen playsoundwithnotify( a_convo[2][e_richtofen.character_name], "sound_done" + a_convo[2][e_richtofen.character_name] );

                                e_richtofen waittill( "sound_done" + a_convo[2][e_richtofen.character_name] );
                            }
                        }
                    }

                    set_players_dontspeak( 0 );
                    flag_clear( "story_vo_playing" );
                    level notify( "first_maigc_box_discovered" );
                    break;
                }
            }
        }

        wait 0.1;
    }
}

build_first_magic_box_seen_vo()
{
    a_first_magic_box_seen_convo = [];
    a_first_magic_box_seen_convo[0] = [];
    a_first_magic_box_seen_convo[0]["Richtofen"] = "vox_plr_2_respond_maxis_1_0";
    a_first_magic_box_seen_convo[1] = [];
    a_first_magic_box_seen_convo[1]["Dempsey"] = "vox_plr_0_respond_maxis_2_0";
    a_first_magic_box_seen_convo[1]["Takeo"] = "vox_plr_3_respond_maxis_3_0";
    a_first_magic_box_seen_convo[1]["Nikolai"] = "vox_plr_1_respond_maxis_4_0";
    a_first_magic_box_seen_convo[2] = [];
    a_first_magic_box_seen_convo[2]["Richtofen"] = "vox_plr_2_respond_maxis_5_0";
    return a_first_magic_box_seen_convo;
}

tomb_drone_built_vo( s_craftable )
{
    if ( s_craftable.weaponname != "equip_dieseldrone_zm" )
        return;

    flag_waitopen( "story_vo_playing" );
    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );
    wait 1;
    e_vo_origin = get_speaking_location_maxis_drone( self, s_craftable );
    vox_line = "vox_maxi_maxis_drone_1_0";
    e_vo_origin playsoundwithnotify( vox_line, "sound_done" + vox_line );
/#
    iprintln( "Maxis says " + vox_line );
#/
    e_vo_origin waittill( "sound_done" + vox_line );

    e_vo_origin delete();
    wait 1;
    e_vo_origin = get_speaking_location_maxis_drone( self, s_craftable );
    vox_line = "vox_maxi_maxis_drone_4_0";
    e_vo_origin playsoundwithnotify( vox_line, "sound_done" + vox_line );
/#
    iprintln( "Maxis says " + vox_line );
#/
    e_vo_origin waittill( "sound_done" + vox_line );

    e_vo_origin delete();
    wait 1;

    if ( isdefined( self ) && self.character_name == "Richtofen" )
    {
        vox_line = "vox_plr_2_maxis_drone_5_0";
/#
        iprintln( "" + self.character_name + " says " + vox_line );
#/
        self playsoundwithnotify( vox_line, "sound_done" + vox_line );

        self waittill( "sound_done" + vox_line );
    }

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
    flag_set( "maxis_crafted_intro_done" );
}

get_speaking_location_maxis_drone( player, s_craftable )
{
    e_vo_origin = undefined;

    if ( isdefined( level.maxis_quadrotor ) )
    {
        e_vo_origin = spawn( "script_origin", level.maxis_quadrotor.origin );
        e_vo_origin linkto( level.maxis_quadrotor );
    }
    else
    {
        player = b_player_has_dieseldrone_weapon();

        if ( isdefined( player ) )
        {
            e_vo_origin = spawn( "script_origin", player.origin );
            e_vo_origin linkto( player );
        }
        else
            e_vo_origin = spawn( "script_origin", s_craftable.origin );
    }

    return e_vo_origin;
}

b_player_has_dieseldrone_weapon()
{
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( player hasweapon( "equip_dieseldrone_zm" ) )
            return player;
    }

    return undefined;
}

set_players_dontspeak( bool )
{
    players = getplayers();

    if ( bool )
    {
        foreach ( player in players )
        {
            if ( isdefined( player ) )
            {
                player.dontspeak = 1;
                player setclientfieldtoplayer( "isspeaking", 1 );
            }
        }

        foreach ( player in players )
        {
            while ( isdefined( player ) && ( isdefined( player.isspeaking ) && player.isspeaking ) )
                wait 0.1;
        }
    }
    else
    {
        foreach ( player in players )
        {
            if ( isdefined( player ) )
            {
                player.dontspeak = 0;
                player setclientfieldtoplayer( "isspeaking", 0 );
            }
        }
    }
}

set_player_dontspeak( bool )
{
    if ( bool )
    {
        self.dontspeak = 1;
        self setclientfieldtoplayer( "isspeaking", 1 );

        while ( isdefined( self ) && ( isdefined( self.isspeaking ) && self.isspeaking ) )
            wait 0.1;
    }
    else
    {
        self.dontspeak = 0;
        self setclientfieldtoplayer( "isspeaking", 0 );
    }
}

is_game_solo()
{
    players = getplayers();

    if ( players.size == 1 )
        return true;
    else
        return false;
}

add_puzzle_completion_line( n_element_enum, str_line )
{
    if ( !isdefined( level.puzzle_completion_lines ) )
    {
        level.puzzle_completion_lines = [];
        level.puzzle_completion_lines_count = [];
    }

    if ( !isdefined( level.puzzle_completion_lines[n_element_enum] ) )
    {
        level.puzzle_completion_lines[n_element_enum] = [];
        level.puzzle_completion_lines_count[n_element_enum] = 0;
    }

    level.puzzle_completion_lines[n_element_enum][level.puzzle_completion_lines[n_element_enum].size] = str_line;
}

say_puzzle_completion_line( n_element_enum )
{
    level notify( "quest_progressed" );
    wait 4.0;

    if ( level.puzzle_completion_lines_count[n_element_enum] >= level.puzzle_completion_lines[n_element_enum].size )
    {
/#
        iprintlnbold( "Out of puzzle completion lines for element " + n_element_enum );
#/
        return;
    }

    str_line = level.puzzle_completion_lines[n_element_enum][level.puzzle_completion_lines_count[n_element_enum]];
    level.puzzle_completion_lines_count[n_element_enum]++;
    set_players_dontspeak( 1 );
    level samanthasay( str_line, self );
    set_players_dontspeak( 0 );
}

watch_occasional_line( str_category, str_line, str_notify, n_time_between = 30.0, n_times_to_play = 100 )
{
    for ( i = 0; i < n_times_to_play; i++ )
    {
        level waittill( str_notify, e_player );

        if ( isdefined( e_player ) )
        {
            e_player maps\mp\zombies\_zm_audio::create_and_play_dialog( str_category, str_line );
            wait( n_time_between );
        }
    }
}

watch_one_shot_line( str_category, str_line, str_notify )
{
    while ( true )
    {
        level waittill( str_notify, e_player );

        if ( isdefined( e_player ) )
        {
            e_player maps\mp\zombies\_zm_audio::create_and_play_dialog( str_category, str_line );
            return;
        }
    }
}

watch_one_shot_samantha_line( str_line, str_notify )
{
    while ( true )
    {
        level waittill( str_notify, e_play_on );

        if ( isdefined( e_play_on ) )
        {
            set_players_dontspeak( 1 );

            if ( samanthasay( str_line, e_play_on ) )
            {
                set_players_dontspeak( 0 );
                return;
            }

            set_players_dontspeak( 0 );
        }
    }
}

watch_one_shot_samantha_clue( str_line, str_notify, str_endon )
{
    if ( isdefined( str_endon ) )
        level endon( str_endon );

    if ( !isdefined( level.next_samantha_clue_time ) )
        level.next_samantha_clue_time = gettime();

    while ( true )
    {
        level waittill( str_notify, e_player );

        wait 10;

        if ( isdefined( e_player ) && ( isdefined( e_player.vo_promises_playing ) && e_player.vo_promises_playing ) )
            continue;

        while ( isdefined( level.sam_talking ) && level.sam_talking )
            wait_network_frame();

        if ( level.next_samantha_clue_time > gettime() )
            continue;

        if ( !isplayer( e_player ) )
        {
            a_players = getplayers();

            foreach ( player in a_players )
            {
                if ( player.zombie_vars["zombie_powerup_zombie_blood_on"] )
                {
                    e_player = player;
                    break;
                }
            }
        }

        if ( isdefined( e_player ) && isplayer( e_player ) && e_player.zombie_vars["zombie_powerup_zombie_blood_on"] && flag( "samantha_intro_done" ) )
        {
            flag_waitopen( "story_vo_playing" );
            flag_set( "story_vo_playing" );

            while ( isdefined( e_player.isspeaking ) && e_player.isspeaking )
                wait_network_frame();

            if ( !is_player_valid( e_player ) )
                continue;

            set_players_dontspeak( 1 );
            level.sam_talking = 1;
            e_player playsoundtoplayer( str_line, e_player );
            n_duration = soundgetplaybacktime( str_line );
            wait( n_duration / 1000 );
            level.sam_talking = 0;
            level.next_samantha_clue_time = gettime() + 300000;
            flag_clear( "story_vo_playing" );
            set_players_dontspeak( 0 );
            return;
        }
    }
}

samantha_discourage_reset()
{
    n_min_time = 60000 * 5;
    n_max_time = 60000 * 10;
    level.sam_next_beratement = gettime() + randomintrange( n_min_time, n_max_time );
}

samantha_encourage_watch_good_lines()
{
    while ( true )
    {
        level waittill( "vo_puzzle_good", e_player );

        wait 1.0;
        level notify( "quest_progressed", e_player, 1 );
    }
}

samantha_encourage_think()
{
    original_list = array( "vox_sam_generic_encourage_0", "vox_sam_generic_encourage_1", "vox_sam_generic_encourage_2", "vox_sam_generic_encourage_3", "vox_sam_generic_encourage_4", "vox_sam_generic_encourage_5" );
    available_list = [];
    n_min_time = 60000 * 5;
    n_max_time = 60000 * 10;
    next_encouragement = 0;
    level thread samantha_encourage_watch_good_lines();

    while ( true )
    {
        if ( available_list.size == 0 )
            available_list = arraycopy( original_list );

        e_player = undefined;
        say_something = 0;

        level waittill( "quest_progressed", e_player, say_something );

        samantha_discourage_reset();

        if ( gettime() < next_encouragement )
            continue;

        if ( !( isdefined( say_something ) && say_something ) )
            continue;

        if ( !isdefined( e_player ) )
            continue;

        if ( !is_player_valid( e_player ) )
            continue;

        if ( isdefined( level.sam_talking ) && level.sam_talking )
            continue;

        while ( flag( "story_vo_playing" ) || isdefined( e_player.isspeaking ) && e_player.isspeaking )
            wait_network_frame();

        line = random( available_list );
        arrayremovevalue( available_list, line );
        set_players_dontspeak( 1 );

        if ( samanthasay( line, e_player, 1 ) )
        {
            set_players_dontspeak( 0 );
            e_player maps\mp\zombies\_zm_audio::create_and_play_dialog( "puzzle", "encourage_respond" );
            next_encouragement = gettime() + randomintrange( n_min_time, n_max_time );
        }

        set_players_dontspeak( 0 );
    }
}

samantha_discourage_think()
{
    level endon( "ee_all_staffs_upgraded" );
    original_list = array( "vox_sam_generic_chastise_0", "vox_sam_generic_chastise_1", "vox_sam_generic_chastise_2", "vox_sam_generic_chastise_3", "vox_sam_generic_chastise_4", "vox_sam_generic_chastise_5", "vox_sam_generic_chastise_6" );
    available_list = [];
    flag_wait( "samantha_intro_done" );

    while ( true )
    {
        if ( available_list.size == 0 )
            available_list = arraycopy( original_list );

        samantha_discourage_reset();

        while ( gettime() < level.sam_next_beratement )
            wait 1.0;

        line = random( available_list );
        arrayremovevalue( available_list, line );
        a_players = getplayers();

        while ( a_players.size > 0 )
        {
            e_player = random( a_players );
            arrayremovevalue( a_players, e_player );

            if ( is_player_valid( e_player ) )
            {
                samanthasay( line, e_player, 1 );
                e_player maps\mp\zombies\_zm_audio::create_and_play_dialog( "puzzle", "berate_respond" );
                break;
            }
        }
    }
}

samanthasay( vox_line, e_source, b_wait_for_nearby_speakers = 0, intro_line = 0 )
{
    level endon( "end_game" );

    if ( !intro_line && !flag( "samantha_intro_done" ) )
        return false;
    else if ( intro_line && flag( "samantha_intro_done" ) )
        return false;

    while ( isdefined( level.sam_talking ) && level.sam_talking )
        wait_network_frame();

    level.sam_talking = 1;

    if ( b_wait_for_nearby_speakers )
    {
        nearbyplayers = get_array_of_closest( e_source.origin, get_players(), undefined, undefined, 256 );

        if ( isdefined( nearbyplayers ) && nearbyplayers.size > 0 )
        {
            foreach ( player in nearbyplayers )
            {
                while ( isdefined( player ) && ( isdefined( player.isspeaking ) && player.isspeaking ) )
                    wait 0.05;
            }
        }
    }

    level thread samanthasayvoplay( e_source, vox_line );

    level waittill( "SamanthaSay_vo_finished" );

    return true;
}

samanthasayvoplay( e_source, vox_line )
{
    e_source playsoundwithnotify( vox_line, "sound_done" + vox_line );

    e_source waittill( "sound_done" + vox_line );

    level.sam_talking = 0;
    level notify( "SamanthaSay_vo_finished" );
}

maxissay( vox_line, m_spot_override, b_wait_for_nearby_speakers )
{
    level endon( "end_game" );
    level endon( "intermission" );

    if ( isdefined( level.intermission ) && level.intermission )
        return;

    if ( !flag( "maxis_crafted_intro_done" ) )
        return;

    while ( isdefined( level.maxis_talking ) && level.maxis_talking )
        wait 0.05;

    level.maxis_talking = 1;
/#
    iprintlnbold( "Maxis Says: " + vox_line );
#/
    if ( isdefined( m_spot_override ) )
        m_vo_spot = m_spot_override;

    if ( isdefined( b_wait_for_nearby_speakers ) && b_wait_for_nearby_speakers )
    {
        nearbyplayers = get_array_of_closest( m_vo_spot.origin, get_players(), undefined, undefined, 256 );

        if ( isdefined( nearbyplayers ) && nearbyplayers.size > 0 )
        {
            foreach ( player in nearbyplayers )
            {
                while ( isdefined( player ) && ( isdefined( player.isspeaking ) && player.isspeaking ) )
                    wait 0.05;
            }
        }
    }

    level thread maxissayvoplay( m_vo_spot, vox_line );

    level waittill( "MaxisSay_vo_finished" );
}

maxissayvoplay( m_vo_spot, vox_line )
{
    m_vo_spot playsoundwithnotify( vox_line, "sound_done" + vox_line );
    m_vo_spot waittill_either( "sound_done" + vox_line, "death" );
    level.maxis_talking = 0;
    level notify( "MaxisSay_vo_finished" );
}

richtofenrespondvoplay( vox_category, b_richtofen_first = 0, str_flag )
{
    if ( flag( "story_vo_playing" ) )
        return;

    flag_set( "story_vo_playing" );
    set_players_dontspeak( 1 );

    if ( b_richtofen_first )
    {
        if ( self.character_name == "Richtofen" )
        {
            str_vox_line = "vox_plr_" + self.characterindex + "_" + vox_category + "_0";
            self playsoundwithnotify( str_vox_line, "rich_done" );

            self waittill( "rich_done" );

            wait 0.5;

            foreach ( player in getplayers() )
            {
                if ( player.character_name != "Richtofen" && distance2d( player.origin, self.origin ) < 800 )
                {
                    str_vox_line = "vox_plr_" + player.characterindex + "_" + vox_category + "_0";
                    player playsoundwithnotify( str_vox_line, "rich_done" );

                    player waittill( "rich_done" );
                }
            }
        }
        else
        {
            foreach ( player in getplayers() )
            {
                if ( player.character_name == "Richtofen" && distance2d( player.origin, self.origin ) < 800 )
                {
                    str_vox_line = "vox_plr_" + player.characterindex + "_" + vox_category + "_0";
                    player playsoundwithnotify( str_vox_line, "rich_done" );

                    player waittill( "rich_done" );

                    wait 0.5;
                }
            }

            if ( isdefined( self ) )
            {
                str_vox_line = "vox_plr_" + self.characterindex + "_" + vox_category + "_0";
                self playsoundwithnotify( str_vox_line, "rich_response" );

                self waittill( "rich_response" );
            }
        }
    }
    else if ( self.character_name == "Richtofen" )
    {
        foreach ( player in getplayers() )
        {
            if ( player.character_name != "Richtofen" && distance2d( player.origin, self.origin ) < 800 )
            {
                str_vox_line = "vox_plr_" + player.characterindex + "_" + vox_category + "_0";
                player playsoundwithnotify( str_vox_line, "rich_done" );

                player waittill( "rich_done" );

                wait 0.5;
            }
        }

        if ( isdefined( self ) )
        {
            str_vox_line = "vox_plr_" + self.characterindex + "_" + vox_category + "_0";
            self playsoundwithnotify( str_vox_line, "rich_done" );

            self waittill( "rich_done" );
        }
    }
    else
    {
        str_vox_line = "vox_plr_" + self.characterindex + "_" + vox_category + "_0";
        self playsoundwithnotify( str_vox_line, "rich_response" );

        self waittill( "rich_response" );

        wait 0.5;

        foreach ( player in getplayers() )
        {
            if ( player.character_name == "Richtofen" && distance2d( player.origin, self.origin ) < 800 )
            {
                str_vox_line = "vox_plr_" + player.characterindex + "_" + vox_category + "_0";
                player playsoundwithnotify( str_vox_line, "rich_done" );

                player waittill( "rich_done" );
            }
        }
    }

    if ( isdefined( str_flag ) )
        flag_set( str_flag );

    set_players_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
}

wunderfizz_used_vo()
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( isdefined( self.has_used_perk_random ) && self.has_used_perk_random )
        return;

    if ( isdefined( self.character_name ) && self.character_name != "Richtofen" )
        return;

    if ( flag( "story_vo_playing" ) )
        return;

    if ( isdefined( self.dontspeak ) && self.dontspeak )
        return;

    set_players_dontspeak( 1 );
    self.has_used_perk_random = 1;

    for ( i = 1; i < 4; i++ )
    {
        vox_line = "vox_plr_2_discover_wonder_" + i + "_0";
        self playsoundwithnotify( vox_line, "sound_done" + vox_line );

        self waittill( "sound_done" + vox_line );

        wait 0.1;
    }

    set_players_dontspeak( 0 );
}

init_sam_promises()
{
    level.vo_promises["Richtofen_1"][0] = "vox_sam_hear_samantha_2_plr_2_0";
    level.vo_promises["Richtofen_1"][1] = "vox_plr_2_hear_samantha_2_0";
    level.vo_promises["Richtofen_2"][0] = "vox_sam_sam_richtofen_1_0";
    level.vo_promises["Richtofen_2"][1] = "vox_sam_sam_richtofen_2_0";
    level.vo_promises["Richtofen_2"][2] = "vox_plr_2_sam_richtofen_3_0";
    level.vo_promises["Richtofen_3"][0] = "vox_sam_sam_richtofen_4_0";
    level.vo_promises["Richtofen_3"][1] = "vox_plr_2_sam_richtofen_5_0";
    level.vo_promises["Richtofen_3"][2] = "vox_plr_2_sam_richtofen_6_0";
    level.vo_promises["Dempsey_1"][0] = "vox_sam_hear_samantha_2_plr_0_0";
    level.vo_promises["Dempsey_1"][1] = "vox_plr_0_hear_samantha_2_0";
    level.vo_promises["Dempsey_2"][0] = "vox_sam_sam_dempsey_1_0";
    level.vo_promises["Dempsey_2"][1] = "vox_sam_sam_dempsey_1_1";
    level.vo_promises["Dempsey_2"][2] = "vox_plr_0_sam_dempsey_1_0";
    level.vo_promises["Dempsey_3"][0] = "vox_sam_sam_dempsey_2_0";
    level.vo_promises["Dempsey_3"][1] = "vox_sam_sam_dempsey_2_1";
    level.vo_promises["Dempsey_3"][2] = "vox_plr_0_sam_dempsey_2_0";
    level.vo_promises["Nikolai_1"][0] = "vox_sam_hear_samantha_2_plr_1_0";
    level.vo_promises["Nikolai_1"][1] = "vox_plr_1_hear_samantha_2_0";
    level.vo_promises["Nikolai_2"][0] = "vox_sam_sam_nikolai_1_0";
    level.vo_promises["Nikolai_2"][1] = "vox_sam_sam_nikolai_1_1";
    level.vo_promises["Nikolai_2"][2] = "vox_plr_1_sam_nikolai_1_0";
    level.vo_promises["Nikolai_3"][0] = "vox_sam_sam_nikolai_2_0";
    level.vo_promises["Nikolai_3"][1] = "vox_sam_sam_nikolai_2_1";
    level.vo_promises["Nikolai_3"][2] = "vox_plr_1_sam_nikolai_2_0";
    level.vo_promises["Takeo_1"][0] = "vox_sam_hear_samantha_2_plr_3_0";
    level.vo_promises["Takeo_1"][1] = "vox_plr_3_hear_samantha_2_0";
    level.vo_promises["Takeo_2"][0] = "vox_sam_sam_takeo_1_0";
    level.vo_promises["Takeo_2"][1] = "vox_sam_sam_takeo_1_1";
    level.vo_promises["Takeo_2"][2] = "vox_plr_3_sam_takeo_1_0";
    level.vo_promises["Takeo_3"][0] = "vox_sam_sam_takeo_2_0";
    level.vo_promises["Takeo_3"][1] = "vox_sam_sam_takeo_2_1";
    level.vo_promises["Takeo_3"][2] = "vox_plr_3_sam_takeo_2_0";
    level thread sam_promises_watch();
}

sam_promises_watch()
{
    flag_wait( "samantha_intro_done" );

    while ( true )
    {
        level waittill( "player_zombie_blood", e_player );

        a_players = get_players();

        if ( randomint( 100 ) < 20 )
            e_player thread sam_promises_conversation();
    }
}

sam_promises_conversation()
{
    self endon( "disconnect" );
    self.vo_promises_playing = 1;
    wait 3;

    if ( !isdefined( self.n_vo_promises ) )
        self.n_vo_promises = 1;

    if ( self.n_vo_promises > 3 || isdefined( self.b_promise_cooldown ) && self.b_promise_cooldown || flag( "story_vo_playing" ) )
    {
        self.vo_promises_playing = undefined;
        return;
    }

    a_promises = level.vo_promises[self.character_name + "_" + self.n_vo_promises];
    self.n_vo_promises++;
    self thread sam_promises_cooldown();
    level.sam_talking = 1;
    self set_player_dontspeak( 1 );
    flag_set( "story_vo_playing" );
    self play_sam_promises_conversation( a_promises );
    level.sam_talking = 0;
    self set_player_dontspeak( 0 );
    flag_clear( "story_vo_playing" );
    self.vo_promises_playing = undefined;
}

play_sam_promises_conversation( a_promises )
{
    for ( i = 0; i < a_promises.size; i++ )
    {
        self endon( "zombie_blood_over" );
        self endon( "disconnect" );

        if ( issubstr( a_promises[i], "sam_sam" ) || issubstr( a_promises[i], "samantha" ) )
        {
            self thread sam_promises_conversation_ended_early( a_promises[i] );
            self playsoundtoplayer( a_promises[i], self );
            n_duration = soundgetplaybacktime( a_promises[i] );
            wait( n_duration / 1000 );
            self notify( "promises_VO_end_early" );
        }
        else
        {
            self playsoundwithnotify( a_promises[i], "player_done" );

            self waittill( "player_done" );
        }

        wait 0.3;
    }
}

sam_promises_conversation_ended_early( str_alias )
{
    self notify( "promises_VO_end_early" );
    self endon( "promises_VO_end_early" );

    while ( self.zombie_vars["zombie_powerup_zombie_blood_on"] )
        wait 0.05;

    self stoplocalsound( str_alias );
}

sam_promises_cooldown()
{
    self endon( "disconnect" );
    self.b_promise_cooldown = 1;

    level waittill( "end_of_round" );

    self.b_promise_cooldown = undefined;
}
