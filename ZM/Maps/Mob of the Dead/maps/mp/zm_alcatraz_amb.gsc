// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zm_alcatraz_utility;
#include maps\mp\_ambientpackage;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_sidequests;

main()
{
    level.sndperksacolaloopoverride = ::sndperksacolaloop;
    level.sndperksacolajingleoverride = ::sndperksacolajingle;
    thread sndstingersetup();
    thread sndlastlifesetup();
    thread sndsetupendgamemusicstates();
    thread sndspectatorsetup();

    if ( is_classic() )
        thread sndmusicegg();
}

sndspectatorsetup()
{
    flag_wait( "initial_players_connected" );
    players = getplayers();

    foreach ( player in players )
        player thread sndspectatorafterliferevert();
}

sndspectatorafterliferevert()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "spawned_spectator" );

        while ( self.sessionstate == "spectator" )
            wait 1;

        self clientnotify( "sndSR" );
    }
}

sndsetupendgamemusicstates()
{
    flag_wait( "start_zombie_round_logic" );
    level thread maps\mp\zombies\_zm_audio::setupmusicstate( "game_over_final_good", "mus_zombie_game_over_final_good", 1, 0, undefined, "SILENCE" );
    level thread maps\mp\zombies\_zm_audio::setupmusicstate( "game_over_final_bad", "mus_zombie_game_over_final_bad", 1, 0, undefined, "SILENCE" );
    level thread maps\mp\zombies\_zm_audio::setupmusicstate( "game_over_nomove", "mus_zombie_game_over_nomove", 1, 0, undefined, "SILENCE" );
}

sndperksacolajingle( perksacola )
{
    if ( !isdefined( self.jingle_is_playing ) )
        self.jingle_is_playing = 0;

    if ( !isdefined( self.script_sound ) )
        return;

    if ( !isdefined( self.sndent ) )
        return;

    if ( self.jingle_is_playing == 0 && level.music_override == 0 )
    {
        self.jingle_is_playing = 1;
        self.sndent stoploopsound( 1 );
        self.sndent playsoundwithnotify( self.script_sound, "sndJingleDone" );

        self.sndent waittill( "sndJingleDone" );

        self.sndent playloopsound( "zmb_perksacola_alcatraz_loop", 1 );
        self.jingle_is_playing = 0;
    }
}

sndperksacolaloop()
{
    self endon( "death" );
    self.sndent = spawn( "script_origin", self.origin );
    self.sndent playloopsound( "zmb_perksacola_alcatraz_loop", 1 );

    while ( true )
    {
        wait( randomfloatrange( 31, 45 ) );

        if ( randomint( 100 ) < 15 )
            self thread sndperksacolajingle();
    }
}

sndeventstingertriggers()
{
    flag_wait( "start_zombie_round_logic" );
    triggers = getentarray( "sndMusicEventStinger", "targetname" );

    foreach ( trigger in triggers )
        trigger thread sndeventstingertriggerthink();
}

sndeventstingertriggerthink()
{
    struct = getstruct( self.target, "targetname" );

    while ( true )
    {
        self waittill( "trigger" );

        playsoundatposition( struct.script_sound, struct.origin );
        level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "trigger_stinger" );
        wait 5;
    }
}

sndeventtension()
{
    flag_wait( "start_zombie_round_logic" );
    wait 30;
    struct = spawnstruct();

    while ( true )
    {
        tension = sndgettensionlevel( struct );
        waittime = tension.waittime;
        level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( tension.tension_level );
        level thread waitfornexttension( waittime );

        level waittill( "sndNextTensionEvent" );
    }
}

sndgettensionlevel( struct )
{
    tension_level = 0;
    players = getplayers();

    foreach ( player in players )
    {
        if ( is_true( player.laststand ) )
            tension_level++;
    }

    num_zombs = get_current_zombie_count();

    if ( num_zombs >= 12 )
        tension_level++;

    enemies = getaispeciesarray( "axis", "all" );

    foreach ( enemy in enemies )
    {
        if ( enemy.animname == "brutus_zombie" )
            tension_level++;
    }

    if ( tension_level > 2 )
    {
        struct.tension_level = "tension_high";
        struct.waittime = 90;
    }
    else
    {
        struct.tension_level = "tension_low";
        struct.waittime = 140;
    }

    return struct;
}

waitfornexttension( time )
{
    level endon( "sndNextTensionEvent" );
    wait( time );
    level notify( "sndNextTensionEvent" );
}

sndboardmonitor()
{
    while ( true )
    {
        level waittill( "last_board_torn", barrier_origin );

        players = getplayers();

        foreach ( player in players )
        {
            if ( distancesquared( player.origin, barrier_origin ) <= 22500 )
            {
                level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "boards_gone" );
                break;
            }
        }
    }
}

locationstingersetup()
{
    level thread locationstingerwait();
}

locationstingerwait( zone_name, type )
{
    array = sndlocationsarray();
    sndnorepeats = 3;
    numcut = 0;
    level.sndlastzone = undefined;
    level thread sndlocationbetweenroundswait();

    while ( true )
    {
        level waittill( "newzoneActive", activezone );

        if ( !sndlocationshouldplay( array, activezone ) )
            continue;

        if ( is_true( level.sndroundwait ) )
            continue;
        else if ( is_true( level.sndstinger.isplaying ) )
        {
            level thread sndlocationqueue( activezone );
            continue;
        }

        level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( activezone );
        array = sndcurrentlocationarray( array, activezone, numcut, sndnorepeats );
        level.sndlastzone = activezone;

        if ( numcut >= sndnorepeats )
            numcut = 0;
        else
            numcut++;

        level waittill( "between_round_over" );

        while ( is_true( level.sndroundwait ) )
            wait 0.1;
    }
}

sndlocationsarray()
{
    array = [];
    array[0] = "zone_cellblock_east";
    array[1] = "cellblock_shower";
    array[2] = "zone_infirmary";
    array[3] = "zone_citadel_stairs";
    array[4] = "zone_roof";
    array[5] = "zone_dock";
    array[6] = "zone_studio";
    array[7] = "zone_warden_office";
    return array;
}

sndlocationshouldplay( array, activezone )
{
    shouldplay = 0;

    foreach ( place in array )
    {
        if ( place == activezone )
            shouldplay = 1;
    }

    if ( shouldplay == 0 )
        return shouldplay;

    playersinlocal = 0;
    players = getplayers();

    foreach ( player in players )
    {
        if ( player maps\mp\zombies\_zm_zonemgr::is_player_in_zone( activezone ) )
        {
            if ( !is_true( player.afterlife ) )
                playersinlocal++;
        }
    }

    if ( playersinlocal >= 1 )
        shouldplay = 1;
    else
        shouldplay = 0;

    return shouldplay;
}

sndcurrentlocationarray( current_array, activezone, numcut, max_num_removed )
{
    if ( numcut >= max_num_removed )
        current_array = sndlocationsarray();

    foreach ( place in current_array )
    {
        if ( place == activezone )
        {
            arrayremovevalue( current_array, place );
            break;
        }
    }

    return current_array;
}

sndlocationbetweenrounds()
{
    level endon( "newzoneActive" );
    activezones = maps\mp\zombies\_zm_zonemgr::get_active_zone_names();

    foreach ( zone in activezones )
    {
        if ( isdefined( level.sndlastzone ) && zone == level.sndlastzone )
            continue;

        players = getplayers();

        foreach ( player in players )
        {
            if ( is_true( player.afterlife ) )
                continue;

            if ( player maps\mp\zombies\_zm_zonemgr::is_player_in_zone( zone ) )
            {
                wait 0.1;
                level notify( "newzoneActive", zone );
                return;
            }
        }
    }
}

sndlocationbetweenroundswait()
{
    flag_wait( "afterlife_start_over" );

    while ( is_true( level.sndroundwait ) )
        wait 0.1;

    while ( true )
    {
        level thread sndlocationbetweenrounds();

        level waittill( "between_round_over" );

        while ( is_true( level.sndroundwait ) )
            wait 0.1;
    }
}

sndlocationqueue( zone )
{
    level endon( "newzoneActive" );

    while ( is_true( level.sndstinger.isplaying ) )
        wait 0.5;

    level notify( "newzoneActive", zone );
}

sndstingersetup()
{
    level.sndmusicstingerevent = ::sndplaystinger;
    level.sndstinger = spawnstruct();
    level.sndstinger.ent = spawn( "script_origin", ( 0, 0, 0 ) );
    level.sndstinger.queue = 0;
    level.sndstinger.isplaying = 0;
    level.sndstinger.states = [];
    level.sndroundwait = 1;
    createstingerstate( "door_open", "mus_event_group_03", 2.5, "ignore" );
    createstingerstate( "gondola", "mus_event_tension_strings_01", 0.1, "reject" );
    createstingerstate( "boards_gone", "mus_event_group_02", 0.5, "ignore" );
    createstingerstate( "trigger_stinger", "mus_event_group_02", 0.1, "ignore" );
    createstingerstate( "brutus_spawn", "mus_event_brutus_spawn", 1.5, "queue" );
    createstingerstate( "brutus_death", "mus_event_brutus_death", 0.1, "ignore" );
    createstingerstate( "tension_low", "mus_event_tension_piano_01", 0.75, "reject" );
    createstingerstate( "tension_high", "mus_event_tension_piano_02", 0.75, "reject" );
    createstingerstate( "zone_cellblock_east", "mus_event_location_cellblock", 0.75, "queue" );
    createstingerstate( "zone_infirmary", "mus_event_location_infirmary", 0.75, "queue" );
    createstingerstate( "zone_studio", "mus_event_location_powerroom", 0.75, "queue" );
    createstingerstate( "zone_roof", "mus_event_location_roof", 0.75, "queue" );
    createstingerstate( "cellblock_shower", "mus_event_location_shower", 0.75, "queue" );
    createstingerstate( "zone_citadel_stairs", "mus_event_location_stairwell", 0.75, "queue" );
    createstingerstate( "zone_dock", "mus_event_location_dock", 0.75, "queue" );
    createstingerstate( "zone_warden_office", "mus_event_location_warden", 0.75, "queue" );
    createstingerstate( "piece_1", "mus_event_piece_1", 0, "queue" );
    createstingerstate( "piece_2", "mus_event_piece_2", 0, "queue" );
    createstingerstate( "piece_3", "mus_event_piece_3", 0, "queue" );
    createstingerstate( "piece_4", "mus_event_piece_4", 0, "queue" );
    createstingerstate( "piece_5", "mus_event_piece_5", 0, "queue" );
    createstingerstate( "piece_mid", "mus_event_piece_mid", 0, "ignore" );
    createstingerstate( "gas_1", "mus_event_piece_1", 0, "reject" );
    createstingerstate( "gas_2", "mus_event_piece_2", 0, "reject" );
    createstingerstate( "gas_3", "mus_event_piece_3", 0, "reject" );
    createstingerstate( "gas_4", "mus_event_piece_4", 0, "reject" );
    createstingerstate( "gas_5", "mus_event_piece_5", 0, "reject" );
    createstingerstate( "plane_crafted_1", "mus_event_plane_1", 0, "reject" );
    createstingerstate( "plane_crafted_2", "mus_event_plane_2", 0, "reject" );
    createstingerstate( "plane_crafted_3", "mus_event_plane_3", 0, "reject" );
    createstingerstate( "plane_crafted_4", "mus_event_plane_4", 0, "reject" );
    createstingerstate( "plane_crafted_5", "mus_event_plane_5", 0, "reject" );
    createstingerstate( "trap", "mus_event_trap", 0, "reject" );
    createstingerstate( "tomahawk_1", "mus_event_tomahawk_2", 0.5, "ignore" );
    createstingerstate( "tomahawk_2", "mus_event_tomahawk_3", 0.5, "ignore" );
    createstingerstate( "tomahawk_3", "mus_event_tomahawk_4", 0.5, "ignore" );
    createstingerstate( "quest_generic", "mus_event_quest_generic", 0.5, "reject" );
    createstingerstate( "laundry_defend", "mus_laundry_defend", 0, "ignore" );
    createstingerstate( "plane_takeoff", "mus_event_plane_takeoff", 0, "ignore" );
    createstingerstate( "at_golden_gate", "mus_event_golden_gate", 0, "ignore" );
    createstingerstate( "spoon", "mus_event_spoon", 0, "ignore" );
    createstingerstate( "spork", "mus_event_spork", 0, "ignore" );
    level thread sndstingerroundwait();
    level thread sndboardmonitor();
    level thread locationstingersetup();
}

createstingerstate( state, alias, prewait, interrupt )
{
    s = level.sndstinger;

    if ( !isdefined( s.states[state] ) )
    {
        s.states[state] = spawnstruct();
        s.states[state].alias = alias;
        s.states[state].prewait = prewait;
        s.states[state].interrupt = interrupt;
    }
}

sndplaystinger( state, player )
{
    s = level.sndstinger;

    if ( !isdefined( s.states[state] ) )
        return;

    interrupt = s.states[state].interrupt == "ignore";

    if ( !is_true( s.isplaying ) || is_true( interrupt ) )
    {
        if ( interrupt )
        {
            wait( s.states[state].prewait );
            playstinger( state, player, 1 );
        }
        else if ( !level.sndroundwait )
        {
            s.isplaying = 1;
            wait( s.states[state].prewait );
            playstinger( state, player, 0 );
            level notify( "sndStingerDone" );
            s.isplaying = 0;
        }
        else if ( s.states[state].interrupt == "queue" )
            level thread sndqueuestinger( state, player );

        return;
    }

    if ( s.states[state].interrupt == "queue" )
        level thread sndqueuestinger( state, player );
}

playstinger( state, player, ignore )
{
    s = level.sndstinger;

    if ( !isdefined( s.states[state] ) )
        return;

    if ( is_true( level.music_override ) )
        return;

    if ( is_true( ignore ) )
    {
        if ( isdefined( player ) )
            player playsoundtoplayer( s.states[state].alias, player );
        else
            s.ent playsound( s.states[state].alias );
    }
    else if ( isdefined( player ) )
    {
        player playsoundtoplayer( s.states[state].alias, player );
        wait 8;
    }
    else
    {
        s.ent playsoundwithnotify( s.states[state].alias, "sndStingerDone" );

        s.ent waittill( "sndStingerDone" );
    }
}

sndqueuestinger( state, player )
{
    s = level.sndstinger;

    if ( is_true( s.queue ) )
        return;
    else
    {
        s.queue = 1;

        while ( true )
        {
            if ( is_true( level.sndroundwait ) || is_true( s.isplaying ) )
                wait 0.5;
            else
                break;
        }

        level thread sndplaystinger( state, player );
        s.queue = 0;
    }
}

sndstingerroundwait()
{
    flag_wait( "afterlife_start_over" );
    wait 28;
    level.sndroundwait = 0;

    while ( true )
    {
        level waittill( "end_of_round" );

        level notify( "sndStopBrutusLoop" );
        level thread sndstingerroundwait_start();
    }
}

sndstingerroundwait_start()
{
    level.sndroundwait = 1;
    wait 0.05;
    level thread sndstingerroundwait_end();
}

sndstingerroundwait_end()
{
    level endon( "end_of_round" );

    level waittill( "between_round_over" );

    wait 28;
    level.sndroundwait = 0;
}

sndlastlifesetup()
{
    flag_wait( "start_zombie_round_logic" );

    if ( flag( "solo_game" ) )
        level thread sndlastlife_solo();
    else
        level thread sndlastlife_multi();
}

sndlastlife_solo()
{
    return;
    player = getplayers()[0];

    while ( true )
    {
        player waittill( "sndLifeGone" );

        if ( player.lives == 0 )
        {
            while ( is_true( player.afterlife ) )
                wait 0.1;

            level notify( "sndStopBrutusLoop" );
            level thread maps\mp\zombies\_zm_audio::change_zombie_music( "last_life" );

            level waittill( "end_of_round" );
        }
    }
}

sndlastlife_multi()
{
    level endon( "end_of_round" );
    level thread sndlastlife_multi_reset();
    sndplayersdead = 0;

    while ( true )
    {
        level waittill( "bleed_out" );

        sndplayersdead++;
        players = getplayers();

        if ( players.size - sndplayersdead <= 1 )
        {
            last_alive = sndlastlife_multi_getlastplayer();

            while ( last_alive.lives > 0 )
                wait 0.1;

            while ( is_true( last_alive.afterlife ) )
                wait 0.1;

            level notify( "sndStopBrutusLoop" );
            level thread maps\mp\zombies\_zm_audio::change_zombie_music( "last_life" );
            return;
        }
    }
}

sndlastlife_multi_getlastplayer()
{
    level endon( "end_of_round" );
    wait 0.5;
    players = getplayers();

    foreach ( dude in players )
    {
        if ( dude.sessionstate == "spectator" )
            continue;

        return dude;
    }
}

sndlastlife_multi_reset()
{
    level waittill( "end_of_round" );

    level thread sndlastlife_multi();
}

sndmusicegg()
{
    origins = [];
    origins[0] = ( 338, 10673, 1378 );
    origins[1] = ( 2897, 9475, 1564 );
    origins[2] = ( -1157, 5217, -72 );
    level.meteor_counter = 0;
    level.music_override = 0;

    for ( i = 0; i < origins.size; i++ )
        level thread sndmusicegg_wait( origins[i] );
}

sndmusicegg_wait( bottle_origin )
{
    temp_ent = spawn( "script_origin", bottle_origin );
    temp_ent playloopsound( "zmb_meteor_loop" );
    temp_ent thread maps\mp\zombies\_zm_sidequests::fake_use( "main_music_egg_hit", ::sndmusicegg_override );

    temp_ent waittill( "main_music_egg_hit", player );

    temp_ent stoploopsound( 1 );
    player playsound( "zmb_meteor_activate" );
    level.meteor_counter += 1;

    if ( level.meteor_counter == 3 )
    {
        level thread sndmuseggplay( temp_ent, "mus_zmb_secret_song", 170 );
        level thread easter_egg_song_vo( player );
    }
    else
    {
        wait 1.5;
        temp_ent delete();
    }
}

sndmusicegg_override()
{
    if ( is_true( level.music_override ) )
        return false;

    return true;
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
