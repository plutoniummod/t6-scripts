// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_game_module_utility;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\gametypes_zm\zmeat;
#include maps\mp\zombies\_zm_powerups;

award_grenades_for_team( team )
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( !isdefined( players[i]._meat_team ) || players[i]._meat_team != team )
            continue;

        lethal_grenade = players[i] get_player_lethal_grenade();
        players[i] giveweapon( lethal_grenade );
        players[i] setweaponammoclip( lethal_grenade, 4 );
    }
}

get_players_on_meat_team( team )
{
    players = get_players();
    players_on_team = [];

    for ( i = 0; i < players.size; i++ )
    {
        if ( !isdefined( players[i]._meat_team ) || players[i]._meat_team != team )
            continue;

        players_on_team[players_on_team.size] = players[i];
    }

    return players_on_team;
}

get_alive_players_on_meat_team( team )
{
    players = get_players();
    players_on_team = [];

    for ( i = 0; i < players.size; i++ )
    {
        if ( !isdefined( players[i]._meat_team ) || players[i]._meat_team != team )
            continue;

        if ( players[i].sessionstate == "spectator" || players[i] maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
            continue;

        players_on_team[players_on_team.size] = players[i];
    }

    return players_on_team;
}

init_minigun_ring()
{
    if ( isdefined( level._minigun_ring ) )
        return;

    ring_pos = getstruct( level._meat_location + "_meat_minigun", "script_noteworthy" );

    if ( !isdefined( ring_pos ) )
        return;

    level._minigun_ring = spawn( "script_model", ring_pos.origin );
    level._minigun_ring.angles = ring_pos.angles;
    level._minigun_ring setmodel( ring_pos.script_parameters );
    level._minigun_ring_clip = getent( level._meat_location + "_meat_minigun_clip", "script_noteworthy" );

    if ( isdefined( level._minigun_ring_clip ) )
        level._minigun_ring_clip linkto( level._minigun_ring );
    else
        iprintlnbold( "BUG: no level._minigun_ring_clip" );

    level._minigun_ring_trig = getent( level._meat_location + "_meat_minigun_trig", "targetname" );

    if ( isdefined( level._minigun_ring_trig ) )
    {
        level._minigun_ring_trig enablelinkto();
        level._minigun_ring_trig linkto( level._minigun_ring );
        level._minigun_icon = spawn( "script_model", level._minigun_ring_trig.origin );
        level._minigun_icon setmodel( getweaponmodel( "minigun_zm" ) );
        level._minigun_icon linkto( level._minigun_ring );
        level._minigun_icon setclientfield( "ring_glowfx", 1 );
        level thread ring_toss( level._minigun_ring_trig, "minigun" );
    }
    else
        iprintlnbold( "BUG: no level._minigun_ring_trig" );

    level._minigun_ring thread move_ring( ring_pos );
    level._minigun_ring thread rotate_ring( 1 );
}

init_ammo_ring()
{
    if ( isdefined( level._ammo_ring ) )
        return;

    name = level._meat_location + "_meat_ammo";
    ring_pos = getstruct( name, "script_noteworthy" );

    if ( !isdefined( ring_pos ) )
        return;

    level._ammo_ring = spawn( "script_model", ring_pos.origin );
    level._ammo_ring.angles = ring_pos.angles;
    level._ammo_ring setmodel( ring_pos.script_parameters );
    name = level._meat_location + "_meat_ammo_clip";
    level._ammo_ring_clip = getent( name, "script_noteworthy" );

    if ( isdefined( level._ammo_ring_clip ) )
        level._ammo_ring_clip linkto( level._ammo_ring );
    else
        iprintlnbold( "BUG: no level._ammo_ring_clip" );

    name = level._meat_location + "_meat_ammo_trig";
    level._ammo_ring_trig = getent( name, "targetname" );

    if ( isdefined( level._ammo_ring_clip ) )
    {
        level._ammo_ring_trig enablelinkto();
        level._ammo_ring_trig linkto( level._ammo_ring );
        level._ammo_icon = spawn( "script_model", level._ammo_ring_trig.origin );
        level._ammo_icon setmodel( "zombie_ammocan" );
        level._ammo_icon linkto( level._ammo_ring );
        level._ammo_icon setclientfield( "ring_glowfx", 1 );
        level thread ring_toss( level._ammo_ring_trig, "ammo" );
    }
    else
        iprintlnbold( "BUG: no level._ammo_ring_trig" );

    level._ammo_ring thread move_ring( ring_pos );
    level._ammo_ring thread rotate_ring( 1 );
}

init_splitter_ring()
{
    if ( isdefined( level._splitter_ring ) )
        return;

    ring_pos = getstruct( level._meat_location + "_meat_splitter", "script_noteworthy" );

    if ( !isdefined( ring_pos ) )
        return;

    level._splitter_ring = spawn( "script_model", ring_pos.origin );
    level._splitter_ring.angles = ring_pos.angles;
    level._splitter_ring setmodel( ring_pos.script_parameters );
    level._splitter_ring_trig1 = getent( level._meat_location + "_meat_splitter_trig_1", "targetname" );
    level._splitter_ring_trig2 = getent( level._meat_location + "_meat_splitter_trig_2", "targetname" );

    if ( isdefined( level._splitter_ring_trig1 ) && isdefined( level._splitter_ring_trig2 ) )
    {
        level._splitter_ring_trig1 enablelinkto();
        level._splitter_ring_trig2 enablelinkto();
    }
    else
        iprintlnbold( "BUG: missing at least one level._splitter_ring_trig" );

    level._splitter_ring notsolid();
    level._meat_icon = spawn( "script_model", level._splitter_ring.origin );
    level._meat_icon setmodel( getweaponmodel( get_gamemode_var( "item_meat_name" ) ) );
    level._meat_icon linkto( level._splitter_ring );
    level._meat_icon setclientfield( "ring_glow_meatfx", 1 );

    if ( isdefined( level._splitter_ring_trig1 ) && isdefined( level._splitter_ring_trig2 ) )
    {
        level._splitter_ring_trig1 linkto( level._splitter_ring );
        level._splitter_ring_trig2 linkto( level._splitter_ring );
        level thread ring_toss( level._splitter_ring_trig1, "splitter" );
        level thread ring_toss( level._splitter_ring_trig2, "splitter" );
    }

    level._splitter_ring thread move_ring( ring_pos );
}

ring_toss( trig, type )
{
    level endon( "end_game" );

    while ( true )
    {
        if ( isdefined( level._ring_triggered ) && level._ring_triggered )
        {
            wait 0.05;
            continue;
        }

        if ( isdefined( level.item_meat ) && ( isdefined( level.item_meat.meat_is_moving ) && level.item_meat.meat_is_moving ) )
        {
            if ( level.item_meat istouching( trig ) )
            {
                level thread ring_toss_prize( type, trig );
                level._ring_triggered = 1;
                level thread ring_cooldown();
            }
        }

        wait 0.05;
    }
}

ring_cooldown()
{
    wait 3;
    level._ring_triggered = 0;
}

ring_toss_prize( type, trig )
{
    switch ( type )
    {
        case "splitter":
            level thread meat_splitter( trig );
            break;
        case "minigun":
            level thread minigun_prize( trig );
            break;
        case "ammo":
            level thread ammo_prize( trig );
            break;
    }
}

meat_splitter( trig )
{
    level endon( "meat_grabbed" );
    level endon( "meat_kicked" );

    while ( isdefined( level.item_meat ) && level.item_meat istouching( trig ) )
        wait 0.05;

    exit_trig = getent( trig.target, "targetname" );
    exit_struct = getstruct( trig.target, "targetname" );

    while ( isdefined( level.item_meat ) && !level.item_meat istouching( exit_trig ) )
        wait 0.05;

    while ( isdefined( level.item_meat ) && level.item_meat istouching( exit_trig ) )
        wait 0.05;

    if ( !isdefined( level.item_meat ) )
        return;

    playfx( level._effect["fw_burst"], exit_trig.origin );
    flare_dir = vectornormalize( anglestoforward( exit_struct.angles ) );
    velocity = vectorscale( flare_dir, randomintrange( 400, 600 ) );
    velocity1 = ( velocity[0] + 75, velocity[1] + 75, randomintrange( 75, 125 ) );
    velocity2 = ( velocity[0] - 75, velocity[1] - 75, randomintrange( 75, 125 ) );
    velocity3 = ( velocity[0], velocity[1], 100 );
    level._fake_meats = [];
    level._meat_splitter_activated = 1;
    org = exit_trig.origin;
    player = get_players()[0];
    player._spawning_meat = 1;
    player endon( "disconnect" );
    thread split_meat( player, org, velocity1, velocity2, velocity );
    level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "meat_ring_splitter", undefined, undefined, 1 );
    wait 0.1;

    while ( isdefined( level.splitting_meat ) && level.splitting_meat )
        wait 0.05;

    player._spawning_meat = 0;
}

split_meat( player, org, vel1, vel2, vel3 )
{
    level.splitting_meat = 1;
    level.item_meat cleanup_meat();
    wait_network_frame();
    level._fake_meats[level._fake_meats.size] = player magicgrenadetype( get_gamemode_var( "item_meat_name" ), org, vel1 );
    wait_network_frame();
    level._fake_meats[level._fake_meats.size] = player magicgrenadetype( get_gamemode_var( "item_meat_name" ), org, vel2 );
    wait_network_frame();
    level._fake_meats[level._fake_meats.size] = player magicgrenadetype( get_gamemode_var( "item_meat_name" ), org, vel3 );
    real_meat = random( level._fake_meats );

    foreach ( meat in level._fake_meats )
    {
        if ( real_meat != meat )
        {
            meat._fake_meat = 1;
            meat thread maps\mp\gametypes_zm\zmeat::delete_on_real_meat_pickup();
            continue;
        }

        meat._fake_meat = 0;
        level.item_meat = meat;
    }

    level.splitting_meat = 0;
}

minigun_prize( trig )
{
    while ( isdefined( level.item_meat ) && level.item_meat istouching( trig ) )
        wait 0.05;

    if ( !isdefined( level.item_meat ) )
        return;

    if ( isdefined( level._minigun_toss_cooldown ) && level._minigun_toss_cooldown )
        return;

    level thread minigun_toss_cooldown();

    if ( !is_player_valid( level._last_person_to_throw_meat ) )
        return;

    level._last_person_to_throw_meat thread maps\mp\zombies\_zm_powerups::powerup_vo( "minigun" );
    level thread maps\mp\zombies\_zm_powerups::minigun_weapon_powerup( level._last_person_to_throw_meat );
    level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "meat_ring_minigun", undefined, undefined, 1 );
}

ammo_prize( trig )
{
    while ( isdefined( level.item_meat ) && level.item_meat istouching( trig ) )
        wait 0.05;

    if ( !isdefined( level.item_meat ) )
        return;

    if ( isdefined( level._ammo_toss_cooldown ) && level._ammo_toss_cooldown )
        return;

    playfx( level._effect["poltergeist"], trig.origin );
    level thread ammo_toss_cooldown();
    level._last_person_to_throw_meat thread maps\mp\zombies\_zm_powerups::powerup_vo( "full_ammo" );
    level thread maps\mp\zombies\_zm_powerups::full_ammo_powerup( undefined, level._last_person_to_throw_meat );
    level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "meat_ring_ammo", undefined, undefined, 1 );
}

minigun_toss_cooldown()
{
    level._minigun_toss_cooldown = 1;

    if ( isdefined( level._minigun_icon ) )
        level._minigun_icon delete();

    waittill_any_or_timeout( 120, "meat_end" );
    playfx( level._effect["poltergeist"], level._minigun_ring_trig.origin );
    level._minigun_icon = spawn( "script_model", level._minigun_ring_trig.origin );
    level._minigun_icon setmodel( getweaponmodel( "minigun_zm" ) );
    level._minigun_icon linkto( level._minigun_ring );
    level._minigun_icon setclientfield( "ring_glowfx", 1 );
    level._minigun_toss_cooldown = 0;
}

ammo_toss_cooldown()
{
    level._ammo_toss_cooldown = 1;

    if ( isdefined( level._ammo_icon ) )
        level._ammo_icon delete();

    waittill_any_or_timeout( 60, "meat_end" );
    playfx( level._effect["poltergeist"], level._ammo_ring_trig.origin );
    level._ammo_icon = spawn( "script_model", level._ammo_ring_trig.origin );
    level._ammo_icon setmodel( "zombie_ammocan" );
    level._ammo_icon linkto( level._ammo_ring );
    level._ammo_icon setclientfield( "ring_glowfx", 1 );
    level._ammo_toss_cooldown = 0;
}

wait_for_team_death( team )
{
    level endon( "meat_end" );
    encounters_team = undefined;

    while ( true )
    {
        wait 1;

        while ( isdefined( level._checking_for_save ) && level._checking_for_save )
            wait 0.1;

        alive_team_players = get_alive_players_on_meat_team( team );

        if ( alive_team_players.size > 0 )
        {
            encounters_team = alive_team_players[0]._encounters_team;
            continue;
        }

        break;
    }

    if ( !isdefined( encounters_team ) )
        return;

    winning_team = "A";

    if ( encounters_team == "A" )
        winning_team = "B";

    level notify( "meat_end", winning_team );
}

check_should_save_player( team )
{
    if ( !isdefined( level._meat_on_team ) )
        return false;

    level._checking_for_save = 1;
    players = get_players_on_meat_team( team );

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];

        if ( isdefined( level._last_person_to_throw_meat ) && level._last_person_to_throw_meat == player )
        {
            while ( isdefined( level.item_meat.meat_is_moving ) && level.item_meat.meat_is_moving || isdefined( level._meat_splitter_activated ) && level._meat_splitter_activated || isdefined( level.item_meat.meat_is_flying ) && level.item_meat.meat_is_flying )
            {
                if ( level._meat_on_team != player._meat_team )
                    break;

                if ( isdefined( level.item_meat.meat_is_rolling ) && level.item_meat.meat_is_rolling && level._meat_on_team == player._meat_team )
                    break;

                wait 0.05;
            }

            if ( !isdefined( player ) )
            {
                level._checking_for_save = 0;
                return false;
            }

            if ( !( isdefined( player.last_damage_from_zombie_or_player ) && player.last_damage_from_zombie_or_player ) )
            {
                level._checking_for_save = 0;
                return false;
            }

            if ( level._meat_on_team != player._meat_team && isdefined( level._last_person_to_throw_meat ) && level._last_person_to_throw_meat == player )
            {
                if ( player maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
                {
                    level thread revive_saved_player( player );
                    return true;
                }
            }
        }
    }

    level._checking_for_save = 0;
    return false;
}

watch_save_player()
{
    if ( !isdefined( level._meat_on_team ) )
        return false;

    if ( !isdefined( level._last_person_to_throw_meat ) || level._last_person_to_throw_meat != self )
        return false;

    level._checking_for_save = 1;

    while ( isdefined( level.splitting_meat ) && level.splitting_meat || isdefined( level.item_meat ) && ( isdefined( level.item_meat.meat_is_moving ) && level.item_meat.meat_is_moving || isdefined( level.item_meat.meat_is_flying ) && level.item_meat.meat_is_flying ) )
    {
        if ( level._meat_on_team != self._meat_team )
            break;

        if ( isdefined( level.item_meat ) && ( isdefined( level.item_meat.meat_is_rolling ) && level.item_meat.meat_is_rolling ) && level._meat_on_team == self._meat_team )
            break;

        wait 0.05;
    }

    if ( level._meat_on_team != self._meat_team && isdefined( level._last_person_to_throw_meat ) && level._last_person_to_throw_meat == self )
    {
        if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            level thread revive_saved_player( self );
            return true;
        }
    }

    level._checking_for_save = 0;
    return false;
}

revive_saved_player( player )
{
    player endon( "disconnect" );
    player iprintlnbold( &"ZOMBIE_PLAYER_SAVED" );
    player playsound( level.zmb_laugh_alias );
    wait 0.25;
    playfx( level._effect["poltergeist"], player.origin );
    playsoundatposition( "zmb_bolt", player.origin );
    earthquake( 0.5, 0.75, player.origin, 1000 );
    player thread maps\mp\zombies\_zm_laststand::auto_revive( player );
    player._saved_by_throw++;
    level._checking_for_save = 0;
}

get_game_module_players( player )
{
    return get_players_on_meat_team( player._meat_team );
}

item_meat_spawn( origin )
{
    org = origin;
    player = get_players()[0];
    player._spawning_meat = 1;
    player magicgrenadetype( get_gamemode_var( "item_meat_name" ), org, ( 0, 0, 0 ) );
    playsoundatposition( "zmb_spawn_powerup", org );
    wait 0.1;
    player._spawning_meat = undefined;
}

init_item_meat( gametype )
{
    if ( gametype == "zgrief" )
    {
        set_gamemode_var_once( "item_meat_name", "item_meat_zm" );
        set_gamemode_var_once( "item_meat_model", "t6_wpn_zmb_meat_world" );
    }
    else
    {
        set_gamemode_var_once( "item_meat_name", "item_head_zm" );
        set_gamemode_var_once( "item_meat_model", "t6_wpn_zmb_severedhead_world" );
    }

    precacheitem( get_gamemode_var( "item_meat_name" ) );
    set_gamemode_var_once( "start_item_meat_name", get_gamemode_var( "item_meat_name" ) );
    level.meat_weaponidx = getweaponindexfromname( get_gamemode_var( "item_meat_name" ) );
    level.meat_pickupsound = getweaponpickupsound( level.meat_weaponidx );
    level.meat_pickupsoundplayer = getweaponpickupsoundplayer( level.meat_weaponidx );
}

meat_intro( launch_spot )
{
    flag_wait( "start_encounters_match_logic" );
    wait 3;
    level thread multi_launch( launch_spot );
    launch_meat( launch_spot );
    drop_meat( level._meat_start_point );
    level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "meat_drop", undefined, undefined, 1 );
}

launch_meat( launch_spot )
{
    level waittill( "launch_meat" );

    spots = getstructarray( launch_spot, "targetname" );

    if ( isdefined( spots ) && spots.size > 0 )
    {
        spot = random( spots );
        meat = spawn( "script_model", spot.origin );
        meat setmodel( "tag_origin" );
        wait_network_frame();
        playfxontag( level._effect["fw_trail"], meat, "tag_origin" );
        meat playloopsound( "zmb_souls_loop", 0.75 );
        dest = spot;

        while ( isdefined( dest ) && isdefined( dest.target ) )
        {
            new_dest = getstruct( dest.target, "targetname" );
            dest = new_dest;
            dist = distance( new_dest.origin, meat.origin );
            time = dist / 700;
            meat moveto( new_dest.origin, time );

            meat waittill( "movedone" );
        }

        meat playsound( "zmb_souls_end" );
        playfx( level._effect["fw_burst"], meat.origin );
        wait( randomfloatrange( 0.2, 0.5 ) );
        meat playsound( "zmb_souls_end" );
        playfx( level._effect["fw_burst"], meat.origin + ( randomintrange( 50, 150 ), randomintrange( 50, 150 ), randomintrange( -20, 20 ) ) );
        wait( randomfloatrange( 0.5, 0.75 ) );
        meat playsound( "zmb_souls_end" );
        playfx( level._effect["fw_burst"], meat.origin + ( randomintrange( -150, -50 ), randomintrange( -150, 50 ), randomintrange( -20, 20 ) ) );
        wait( randomfloatrange( 0.5, 0.75 ) );
        meat playsound( "zmb_souls_end" );
        playfx( level._effect["fw_burst"], meat.origin );
        meat delete();
    }
}

multi_launch( launch_spot )
{
    spots = getstructarray( launch_spot, "targetname" );

    if ( isdefined( spots ) && spots.size > 0 )
    {
        for ( x = 0; x < 3; x++ )
        {
            for ( i = 0; i < spots.size; i++ )
            {
                delay = randomfloatrange( 0.1, 0.25 );
                level thread fake_launch( spots[i], delay );
            }

            wait( randomfloatrange( 0.25, 0.75 ) );

            if ( x > 1 )
                level notify( "launch_meat" );
        }
    }
    else
    {
        wait( randomfloatrange( 0.25, 0.75 ) );
        level notify( "launch_meat" );
    }
}

fake_launch( launch_spot, delay )
{
    wait( delay );
    wait( randomfloatrange( 0.1, 4 ) );
    meat = spawn( "script_model", launch_spot.origin + ( randomintrange( -60, 60 ), randomintrange( -60, 60 ), 0 ) );
    meat setmodel( "tag_origin" );
    wait_network_frame();
    playfxontag( level._effect["fw_trail_cheap"], meat, "tag_origin" );
    meat playloopsound( "zmb_souls_loop", 0.75 );
    dest = launch_spot;

    while ( isdefined( dest ) && isdefined( dest.target ) )
    {
        random_offset = ( randomintrange( -60, 60 ), randomintrange( -60, 60 ), 0 );
        new_dest = getstruct( dest.target, "targetname" );
        dest = new_dest;
        dist = distance( new_dest.origin + random_offset, meat.origin );
        time = dist / 700;
        meat moveto( new_dest.origin + random_offset, time );

        meat waittill( "movedone" );
    }

    meat playsound( "zmb_souls_end" );
    playfx( level._effect["fw_pre_burst"], meat.origin );
    meat delete();
}

drop_meat( drop_spot )
{
    meat = spawn( "script_model", drop_spot + vectorscale( ( 0, 0, 1 ), 600.0 ) );
    meat setmodel( "tag_origin" );
    dist = distance( meat.origin, drop_spot );
    time = dist / 400;
    wait 2;
    meat moveto( drop_spot, time );
    wait_network_frame();
    playfxontag( level._effect["fw_drop"], meat, "tag_origin" );

    meat waittill( "movedone" );

    playfx( level._effect["fw_impact"], drop_spot );
    level notify( "reset_meat" );
    meat delete();
}
