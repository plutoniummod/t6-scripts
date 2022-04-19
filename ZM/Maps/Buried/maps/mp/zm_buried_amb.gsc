// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zm_alcatraz_utility;
#include maps\mp\_ambientpackage;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_zonemgr;

main()
{
    level.sndzombieentcontext = 1;

    if ( is_classic() )
    {
        thread sndmusicegg();
        thread sndstingersetup();
        onplayerconnect_callback( ::sndtrackers );
    }
}

sndtrackers()
{
    self thread sndbackgroundmustracker();
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
    flag_wait( "start_zombie_round_logic" );
    level sndstingersetupstates();
    level thread sndstingerroundwait();
    level thread sndboardmonitor();
    level thread locationstingerwait();
}

sndstingersetupstates()
{
    createstingerstate( "door_open", "mus_event_group_03", 2.5, "ignore" );
    createstingerstate( "boards_gone", "mus_event_group_02", 0.5, "ignore" );
    createstingerstate( "zone_tunnels_center", "mus_event_location_tunnels", 0.75, "queue" );
    createstingerstate( "zone_stables", "mus_event_location_stables", 0.75, "queue" );
    createstingerstate( "zone_underground_courthouse", "mus_event_location_courthouse", 0.75, "queue" );
    createstingerstate( "zone_underground_bar", "mus_event_location_bar", 0.75, "queue" );
    createstingerstate( "zone_toy_store", "mus_event_location_toystore", 0.75, "queue" );
    createstingerstate( "zone_underground_jail", "mus_event_location_jail", 0.75, "queue" );
    createstingerstate( "zone_general_store", "mus_event_location_genstore", 0.75, "queue" );
    createstingerstate( "zone_morgue", "mus_event_location_morgue", 0.75, "queue" );
    createstingerstate( "zone_church_main", "mus_event_location_church", 0.75, "queue" );
    createstingerstate( "zone_mansion_lawn", "mus_event_location_mansionlawn", 0.75, "queue" );
    createstingerstate( "zone_mansion", "mus_event_location_mansion", 0.75, "queue" );
    createstingerstate( "zone_maze", "mus_event_location_maze", 0.75, "queue" );
    createstingerstate( "zone_maze_staircase", "mus_event_location_mazeend", 0.75, "queue" );
    createstingerstate( "zone_candy_store", "mus_event_location_candystore", 0.75, "queue" );
    createstingerstate( "zone_street_lighteast", "mus_event_location_street_east", 0.75, "queue" );
    createstingerstate( "zone_street_lightwest", "mus_event_location_street_west", 0.75, "queue" );
    createstingerstate( "zone_start_lower", "mus_event_location_diamondmine", 0.75, "queue" );
    createstingerstate( "sloth_escape", "mus_event_sloth_breakout", 0, "reject" );
    createstingerstate( "poweron", "mus_event_poweron", 0, "reject" );
    createstingerstate( "sidequest_1", "mus_sidequest_0", 0, "reject" );
    createstingerstate( "sidequest_2", "mus_sidequest_1", 0, "reject" );
    createstingerstate( "sidequest_3", "mus_sidequest_2", 0, "reject" );
    createstingerstate( "sidequest_4", "mus_sidequest_3", 0, "reject" );
    createstingerstate( "sidequest_5", "mus_sidequest_4", 0, "reject" );
    createstingerstate( "sidequest_6", "mus_sidequest_5", 0, "reject" );
    createstingerstate( "sidequest_7", "mus_sidequest_6", 0, "reject" );
    createstingerstate( "sidequest_8", "mus_sidequest_7", 0, "reject" );
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

locationstingerwait( zone_name, type )
{
    array = sndlocationsarray();
    sndnorepeats = 3;
    numcut = 0;
    level.sndlastzone = undefined;
    level.sndlocationplayed = 0;
    level thread sndlocationbetweenroundswait();

    while ( true )
    {
        level waittill( "newzoneActive", activezone );

        wait 0.1;

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
        level.sndlocationplayed = 1;
        array = sndcurrentlocationarray( array, activezone, numcut, sndnorepeats );
        level.sndlastzone = activezone;

        if ( numcut >= sndnorepeats )
            numcut = 0;
        else
            numcut++;

        level waittill( "between_round_over" );

        while ( is_true( level.sndroundwait ) )
            wait 0.1;

        level.sndlocationplayed = 0;
    }
}

sndlocationsarray()
{
    array = [];
    array[0] = "zone_tunnels_center";
    array[1] = "zone_church_main";
    array[2] = "zone_mansion";
    array[3] = "zone_maze";
    array[4] = "zone_maze_staircase";
    array[5] = "zone_street_lightwest";
    array[6] = "zone_toy_store";
    array[7] = "zone_candy_store";
    array[8] = "zone_underground_courthouse";
    array[9] = "zone_start_lower";
    return array;
}

sndlocationshouldplay( array, activezone )
{
    shouldplay = 0;

    if ( activezone == "zone_start_lower" && !flag( "fountain_transport_active" ) )
        return shouldplay;

    if ( is_true( level.music_override ) )
        return shouldplay;

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
        {
            s.ent playsound( s.states[state].alias );
            s.ent thread playstingerstop();
        }
    }
    else if ( isdefined( player ) )
    {
        player playsoundtoplayer( s.states[state].alias, player );
        wait 8;
    }
    else
    {
        s.ent playsoundwithnotify( s.states[state].alias, "sndStingerDone" );
        s.ent thread playstingerstop();

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
    wait 25;
    level.sndroundwait = 0;

    while ( true )
    {
        level waittill( "end_of_round" );

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

playstingerstop()
{
    self endon( "sndStingerDone" );
    level endon( "sndStingerDone" );

    level waittill( "end_of_round" );

    wait 2;
    self stopsounds();
}

sndbackgroundmustracker()
{
    self endon( "disconnect" );
    self.prevzone = "null";
    self.prevcase = 99;

    while ( true )
    {
        level waittill( "newzoneActive", activezone );

        if ( self.prevzone != activezone )
        {
            if ( self maps\mp\zombies\_zm_zonemgr::is_player_in_zone( activezone ) )
            {
                self.prevzone = activezone;

                switch ( activezone )
                {
                    case "zone_start_lower":
                    case "zone_start":
                        if ( self.prevcase != 0 )
                        {
                            self setclientfieldtoplayer( "sndBackgroundMus", 0 );
                            self.prevcase = 0;
                        }

                        break;
                    case "zone_maze_staircase":
                    case "zone_maze":
                    case "zone_mansion_lawn":
                    case "zone_mansion_backyard":
                    case "zone_mansion":
                        if ( self.prevcase != 2 )
                        {
                            self setclientfieldtoplayer( "sndBackgroundMus", 2 );
                            self.prevcase = 2;
                        }

                        break;
                    default:
                        if ( self.prevcase != 1 )
                        {
                            self setclientfieldtoplayer( "sndBackgroundMus", 1 );
                            self.prevcase = 1;
                        }

                        break;
                }
            }
        }
    }
}

sndshoulditplay( activezone )
{
    if ( self.prevzone == activezone )
        return false;

    if ( !self maps\mp\zombies\_zm_zonemgr::is_player_in_zone( activezone ) )
        return false;

    return true;
}

sndlastlifesetup()
{
    flag_wait( "start_zombie_round_logic" );
    level thread sndlastlife_multi();
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
    origins[0] = ( -1215.63, -499.975, 291.89 );
    origins[1] = ( 552.009, -342.824, 27.3921 );
    origins[2] = ( 2827.28, 306.468, 92.783 );
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
        level thread sndmuseggplay( temp_ent, "mus_zmb_secret_song", 363 );
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
    level setclientfield( "mus_zmb_egg_snapshot_loop", 1 );
    level thread sndeggmusicwait( time );
    level waittill_either( "end_game", "sndSongDone" );
    ent stopsounds();
    level setclientfield( "mus_zmb_egg_snapshot_loop", 0 );
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

sndmusicquestendgame( alias, length )
{
    while ( is_true( level.music_override ) )
        wait 1;

    level.music_override = 1;
    level setclientfield( "mus_zmb_egg_snapshot_loop", 1 );
    ent = spawn( "script_origin", ( 0, 0, 0 ) );
    ent playsound( alias );
    wait( length );
    level setclientfield( "mus_zmb_egg_snapshot_loop", 0 );
    level.music_override = 0;
    wait 0.05;
    ent delete();
    wait 1;
    level thread sndendgamemusicredux( alias, length );
}

easter_egg_song_vo( player )
{
    if ( isalive( player ) )
        player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "quest", "find_secret" );
}

sndendgamemusicredux( alias, length )
{
    m_endgame_machine = getstruct( "sq_endgame_machine", "targetname" );
    temp_ent = spawn( "script_origin", m_endgame_machine.origin );
    temp_ent thread maps\mp\zombies\_zm_sidequests::fake_use( "main_music_egg_hit", ::sndmusicegg_override );
    temp_ent playloopsound( "zmb_meteor_loop" );

    temp_ent waittill( "main_music_egg_hit", player );

    temp_ent stoploopsound( 1 );
    level.music_override = 1;
    temp_ent playsound( "zmb_endgame_mach_button" );
    level setclientfield( "mus_zmb_egg_snapshot_loop", 1 );
    temp_ent playsound( alias );
    wait( length );
    level setclientfield( "mus_zmb_egg_snapshot_loop", 0 );
    level.music_override = 0;
    wait 0.05;
    temp_ent delete();
}
