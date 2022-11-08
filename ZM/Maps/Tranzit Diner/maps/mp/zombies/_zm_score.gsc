// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_pers_upgrades_functions;

init()
{
    level.score_cf_info = [];
    score_cf_register_info( "damage", 1, 7 );
    score_cf_register_info( "death_normal", 1, 3 );
    score_cf_register_info( "death_torso", 1, 3 );
    score_cf_register_info( "death_neck", 1, 3 );
    score_cf_register_info( "death_head", 1, 3 );
    score_cf_register_info( "death_melee", 1, 3 );

    if ( !level.createfx_enabled )
        registerclientfield( "allplayers", "score_cf_double_points_active", 1, 1, "int" );
}

score_cf_register_info( name, version, max_count )
{
    if ( level.createfx_enabled )
        return;

    info = spawnstruct();
    info.name = name;
    info.cf_field = "score_cf_" + name;
    info.version = version;
    info.max_count = max_count;
    info.bit_count = getminbitcountfornum( max_count );
    info.players = [];
    level.score_cf_info[name] = info;
    registerclientfield( "allplayers", info.cf_field, info.version, info.bit_count, "int" );
}

score_cf_increment_info( name )
{
    info = level.score_cf_info[name];
    player_ent_index = self getentitynumber();

    if ( !isdefined( info.players[player_ent_index] ) )
        info.players[player_ent_index] = 0;

    info.players[player_ent_index]++;

    if ( info.players[player_ent_index] > info.max_count )
        info.players[player_ent_index] = 0;

    self setclientfield( info.cf_field, info.players[player_ent_index] );
}

score_cf_monitor()
{
    if ( level.createfx_enabled )
        return;

    info_keys = getarraykeys( level.score_cf_info );

    while ( true )
    {
        wait_network_frame();
        players = get_players();

        for ( player_index = 0; player_index < players.size; player_index++ )
        {
            player = players[player_index];
            player_ent_index = player getentitynumber();

            for ( info_index = 0; info_index < info_keys.size; info_index++ )
            {
                info = level.score_cf_info[info_keys[info_index]];
                info.players[player_ent_index] = 0;
                player setclientfield( info.cf_field, 0 );
            }
        }
    }
}

player_add_points( event, mod, hit_location, is_dog, zombie_team, damage_weapon )
{
    if ( level.intermission )
        return;

    if ( !is_player_valid( self ) )
        return;

    player_points = 0;
    team_points = 0;
    multiplier = get_points_multiplier( self );

    switch ( event )
    {
        case "death":
            player_points = get_zombie_death_player_points();
            team_points = get_zombie_death_team_points();
            points = self player_add_points_kill_bonus( mod, hit_location );

            if ( level.zombie_vars[self.team]["zombie_powerup_insta_kill_on"] == 1 && mod == "MOD_UNKNOWN" )
                points *= 2;

            player_points += points;

            if ( team_points > 0 )
                team_points += points;

            if ( mod == "MOD_GRENADE" || mod == "MOD_GRENADE_SPLASH" )
            {
                self maps\mp\zombies\_zm_stats::increment_client_stat( "grenade_kills" );
                self maps\mp\zombies\_zm_stats::increment_player_stat( "grenade_kills" );
            }

            break;
        case "ballistic_knife_death":
            player_points = get_zombie_death_player_points() + level.zombie_vars["zombie_score_bonus_melee"];
            self score_cf_increment_info( "death_melee" );
            break;
        case "damage_light":
            player_points = level.zombie_vars["zombie_score_damage_light"];
            self score_cf_increment_info( "damage" );
            break;
        case "damage":
            player_points = level.zombie_vars["zombie_score_damage_normal"];
            self score_cf_increment_info( "damage" );
            break;
        case "damage_ads":
            player_points = int( level.zombie_vars["zombie_score_damage_normal"] * 1.25 );
            self score_cf_increment_info( "damage" );
            break;
        case "rebuild_board":
        case "carpenter_powerup":
            player_points = mod;
            break;
        case "bonus_points_powerup":
            player_points = mod;
            break;
        case "nuke_powerup":
            player_points = mod;
            team_points = mod;
            break;
        case "thundergun_fling":
        case "riotshield_fling":
        case "jetgun_fling":
            player_points = mod;
            break;
        case "hacker_transfer":
            player_points = mod;
            break;
        case "reviver":
            player_points = mod;
            break;
        case "vulture":
            player_points = mod;
            break;
        case "build_wallbuy":
            player_points = mod;
            break;
        default:
            assert( 0, "Unknown point event" );
            break;
    }

    player_points = multiplier * round_up_score( player_points, 5 );
    team_points = multiplier * round_up_score( team_points, 5 );

    if ( isdefined( self.point_split_receiver ) && ( event == "death" || event == "ballistic_knife_death" ) )
    {
        split_player_points = player_points - round_up_score( player_points * self.point_split_keep_percent, 10 );
        self.point_split_receiver add_to_player_score( split_player_points );
        player_points -= split_player_points;
    }

    if ( is_true( level.pers_upgrade_pistol_points ) )
        player_points = self maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_pistol_points_set_score( player_points, event, mod, damage_weapon );

    self add_to_player_score( player_points );
    self.pers["score"] = self.score;

    if ( isdefined( level._game_module_point_adjustment ) )
        level [[ level._game_module_point_adjustment ]]( self, zombie_team, player_points );
}

get_points_multiplier( player )
{
    multiplier = level.zombie_vars[player.team]["zombie_point_scalar"];

    if ( isdefined( level.current_game_module ) && level.current_game_module == 2 )
    {
        if ( isdefined( level._race_team_double_points ) && level._race_team_double_points == player._race_team )
            return multiplier;
        else
            return 1;
    }

    return multiplier;
}

get_zombie_death_player_points()
{
    players = get_players();

    if ( players.size == 1 )
        points = level.zombie_vars["zombie_score_kill_1player"];
    else if ( players.size == 2 )
        points = level.zombie_vars["zombie_score_kill_2player"];
    else if ( players.size == 3 )
        points = level.zombie_vars["zombie_score_kill_3player"];
    else
        points = level.zombie_vars["zombie_score_kill_4player"];

    return points;
}

get_zombie_death_team_points()
{
    players = get_players();

    if ( players.size == 1 )
        points = level.zombie_vars["zombie_score_kill_1p_team"];
    else if ( players.size == 2 )
        points = level.zombie_vars["zombie_score_kill_2p_team"];
    else if ( players.size == 3 )
        points = level.zombie_vars["zombie_score_kill_3p_team"];
    else
        points = level.zombie_vars["zombie_score_kill_4p_team"];

    return points;
}

player_add_points_kill_bonus( mod, hit_location )
{
    if ( mod == "MOD_MELEE" )
    {
        self score_cf_increment_info( "death_melee" );
        return level.zombie_vars["zombie_score_bonus_melee"];
    }

    if ( mod == "MOD_BURNED" )
    {
        self score_cf_increment_info( "death_torso" );
        return level.zombie_vars["zombie_score_bonus_burn"];
    }

    score = 0;

    if ( isdefined( hit_location ) )
    {
        switch ( hit_location )
        {
            case "helmet":
            case "head":
                self score_cf_increment_info( "death_head" );
                score = level.zombie_vars["zombie_score_bonus_head"];
                break;
            case "neck":
                self score_cf_increment_info( "death_neck" );
                score = level.zombie_vars["zombie_score_bonus_neck"];
                break;
            case "torso_upper":
            case "torso_lower":
                self score_cf_increment_info( "death_torso" );
                score = level.zombie_vars["zombie_score_bonus_torso"];
                break;
            default:
                self score_cf_increment_info( "death_normal" );
                break;
        }
    }

    return score;
}

player_reduce_points( event, mod, hit_location )
{
    if ( level.intermission )
        return;

    points = 0;

    switch ( event )
    {
        case "no_revive_penalty":
            percent = level.zombie_vars["penalty_no_revive"];
            points = self.score * percent;
            break;
        case "died":
            percent = level.zombie_vars["penalty_died"];
            points = self.score * percent;
            break;
        case "downed":
            percent = level.zombie_vars["penalty_downed"];
            self notify( "I_am_down" );
            points = self.score * percent;
            self.score_lost_when_downed = round_up_to_ten( int( points ) );
            break;
        default:
            assert( 0, "Unknown point event" );
            break;
    }

    points = self.score - round_up_to_ten( int( points ) );

    if ( points < 0 )
        points = 0;

    self.score = points;
}

add_to_player_score( points, add_to_total = 1 )
{
    if ( !isdefined( points ) || level.intermission )
        return;

    self.score += points;
    self.pers["score"] = self.score;

    if ( add_to_total )
        self.score_total += points;

    self incrementplayerstat( "score", points );
}

minus_to_player_score( points, ignore_double_points_upgrade )
{
    if ( !isdefined( points ) || level.intermission )
        return;

    if ( !is_true( ignore_double_points_upgrade ) )
    {
        if ( is_true( level.pers_upgrade_double_points ) )
            points = maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_double_points_set_score( points );
    }

    self.score -= points;
    self.pers["score"] = self.score;
    level notify( "spent_points", self, points );
}

add_to_team_score( points )
{

}

minus_to_team_score( points )
{

}

player_died_penalty()
{
    players = get_players( self.team );

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] != self && !players[i].is_zombie )
            players[i] player_reduce_points( "no_revive_penalty" );
    }
}

player_downed_penalty()
{
/#
    println( "ZM >> LAST STAND - player_downed_penalty " );
#/
    self player_reduce_points( "downed" );
}
