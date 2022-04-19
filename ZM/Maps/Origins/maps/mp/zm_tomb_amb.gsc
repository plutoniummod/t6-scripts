// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_ambientpackage;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_zonemgr;

main()
{
    level thread sndsetupendgamemusicstates();

    if ( is_classic() )
    {
        thread sndmusicegg();
        thread snd115egg();
        thread sndstingersetup();
        onplayerconnect_callback( ::sndtrackers );
        level thread sndmaelstrom();
    }
}

sndsetupendgamemusicstates()
{
    flag_wait( "start_zombie_round_logic" );
    level thread maps\mp\zombies\_zm_audio::setupmusicstate( "game_over_ee", "mus_zombie_game_over_ee", 1, 0, undefined, "SILENCE" );
}

sndtrackers()
{

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
    level thread snddoormusictrigs();
}

sndstingersetupstates()
{
    createstingerstate( "door_open", "mus_event_group_03", 2.5, "ignore" );
    createstingerstate( "boards_gone", "mus_event_group_02", 0.5, "ignore" );
    createstingerstate( "zone_nml_18", "mus_event_location_hilltop", 0.75, "queue" );
    createstingerstate( "zone_village_2", "mus_event_location_church", 0.75, "queue" );
    createstingerstate( "ug_bottom_zone", "mus_event_location_crypt", 0.75, "queue" );
    createstingerstate( "zone_robot_head", "mus_event_location_robot", 0.75, "queue" );
    createstingerstate( "zone_air_stairs", "mus_event_cave_air", 0.75, "queue" );
    createstingerstate( "zone_fire_stairs", "mus_event_cave_fire", 0.75, "queue" );
    createstingerstate( "zone_bolt_stairs", "mus_event_cave_bolt", 0.75, "queue" );
    createstingerstate( "zone_ice_stairs", "mus_event_cave_ice", 0.75, "queue" );
    createstingerstate( "poweron", "mus_event_poweron", 0, "reject" );
    createstingerstate( "tank_ride", "mus_event_tank_ride", 0, "queue" );
    createstingerstate( "generator_1", "mus_event_generator_1", 1, "reject" );
    createstingerstate( "generator_2", "mus_event_generator_2", 1, "reject" );
    createstingerstate( "generator_3", "mus_event_generator_3", 1, "reject" );
    createstingerstate( "generator_4", "mus_event_generator_4", 1, "reject" );
    createstingerstate( "generator_5", "mus_event_generator_5", 1, "reject" );
    createstingerstate( "generator_6", "mus_event_generator_6", 1, "reject" );
    createstingerstate( "staff_fire", "mus_event_staff_fire", 0.1, "reject" );
    createstingerstate( "staff_ice", "mus_event_staff_ice", 0.1, "reject" );
    createstingerstate( "staff_lightning", "mus_event_staff_lightning", 0.1, "reject" );
    createstingerstate( "staff_wind", "mus_event_staff_wind", 0.1, "reject" );
    createstingerstate( "staff_fire_upgraded", "mus_event_staff_fire_upgraded", 0.1, "reject" );
    createstingerstate( "staff_ice_upgraded", "mus_event_staff_ice_upgraded", 0.1, "reject" );
    createstingerstate( "staff_lightning_upgraded", "mus_event_staff_lightning_upgraded", 0.1, "reject" );
    createstingerstate( "staff_wind_upgraded", "mus_event_staff_wind_upgraded", 0.1, "reject" );
    createstingerstate( "staff_all_upgraded", "mus_event_staff_all_upgraded", 0.1, "reject" );
    createstingerstate( "side_sting_1", "mus_side_stinger_1", 0.1, "reject" );
    createstingerstate( "side_sting_2", "mus_side_stinger_2", 0.1, "reject" );
    createstingerstate( "side_sting_3", "mus_side_stinger_3", 0.1, "reject" );
    createstingerstate( "side_sting_4", "mus_side_stinger_4", 0.1, "reject" );
    createstingerstate( "side_sting_5", "mus_side_stinger_5", 0.1, "reject" );
    createstingerstate( "side_sting_6", "mus_side_stinger_6", 0.1, "reject" );
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
    array[0] = "zone_nml_18";
    array[1] = "zone_village_2";
    array[2] = "ug_bottom_zone";
    array[3] = "zone_air_stairs";
    array[4] = "zone_fire_stairs";
    array[5] = "zone_bolt_stairs";
    array[6] = "zone_ice_stairs";
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
    count = 0;

    if ( is_true( s.queue ) )
        return;
    else
    {
        s.queue = 1;

        while ( true )
        {
            if ( is_true( level.sndroundwait ) || is_true( s.isplaying ) )
            {
                wait 0.5;
                count++;

                if ( count >= 120 )
                    return;
            }
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
    level waittill_any( "end_of_round", "sndStingerForceStop" );
    wait 2;
    self stopsounds();
}

sndmusicegg()
{
    origins = [];
    origins[0] = ( 2682.23, 4456.15, -302.352 );
    origins[1] = ( 721.043, -87.7068, 285.986 );
    origins[2] = ( -674.048, 2536.67, -112.483 );
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
        level thread sndmuseggplay( temp_ent, "mus_zmb_secret_song", 310 );
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
    level notify( "sndStingerForceStop" );
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

sndplaystingerwithoverride( alias, length )
{
    shouldplay = sndwait();

    if ( !shouldplay )
        return;

    level.music_override = 1;
    level setclientfield( "mus_zmb_egg_snapshot_loop", 1 );
    level notify( "sndStingerForceStop" );
    ent = spawn( "script_origin", ( 0, 0, 0 ) );
    ent playsound( alias );
    wait( length );
    level setclientfield( "mus_zmb_egg_snapshot_loop", 0 );
    level.music_override = 0;
    wait 0.05;
    ent delete();
}

sndwait()
{
    counter = 0;

    while ( is_true( level.music_override ) )
    {
        wait 1;
        counter++;

        if ( counter >= 60 )
            return false;
    }

    return true;
}

snddoormusictrigs()
{
    trigs = getentarray( "sndMusicDoor", "script_noteworthy" );

    foreach ( trig in trigs )
        trig thread snddoormusic();
}

snddoormusic()
{
    self endon( "sndDoorMusic_Triggered" );

    while ( true )
    {
        self waittill( "trigger" );

        if ( is_true( level.music_override ) )
        {
            wait 0.1;
            continue;
        }
        else
            break;
    }

    if ( isdefined( self.target ) )
    {
        ent = getent( self.target, "targetname" );
        ent notify( "sndDoorMusic_Triggered" );
    }

    level thread sndplaystingerwithoverride( self.script_sound, self.script_int );
}

sndmaelstrom()
{
    trig = getent( "sndMaelstrom", "targetname" );

    if ( !isdefined( trig ) )
        return;

    while ( true )
    {
        trig waittill( "trigger", who );

        if ( isplayer( who ) && !is_true( who.sndmaelstrom ) )
        {
            who.sndmaelstrom = 1;
            level setclientfield( "sndMaelstromPlr" + who getentitynumber(), 1 );
        }

        who thread sndmaelstrom_timeout();
        wait 0.1;
    }
}

sndmaelstrom_timeout()
{
    self notify( "sndMaelstrom_Timeout" );
    self endon( "sndMaelstrom_Timeout" );
    wait 2;
    self.sndmaelstrom = 0;
    level setclientfield( "sndMaelstromPlr" + self getentitynumber(), 0 );
}

snd115egg()
{
    level.snd115count = 0;
    oneorigin = [];
    oneorigin[0] = ( 2168, 4617, -289 );
    oneorigin[1] = ( 2170, 4953, -289 );
    fiveorigin = [];
    fiveorigin[0] = ( -2459, 176, 243 );
    fiveorigin[1] = ( -2792, 175, 243 );

    foreach ( origin in oneorigin )
        level thread snd115egg_wait( origin, 0 );

    foreach ( origin in fiveorigin )
        level thread snd115egg_wait( origin, 1 );
}

snd115egg_wait( origin, shouldwait )
{
    level endon( "sndEnd115" );
    temp_ent = spawn( "script_origin", origin );
    temp_ent thread snddelete115ent();

    if ( shouldwait )
        temp_ent thread maps\mp\zombies\_zm_sidequests::fake_use( "main_music_egg_hit", ::snd115egg_5_override );
    else
        temp_ent thread maps\mp\zombies\_zm_sidequests::fake_use( "main_music_egg_hit", ::snd115egg_1_override );

    temp_ent waittill( "main_music_egg_hit", player );

    player playsound( "zmb_meteor_activate" );
    level.snd115count++;

    if ( level.snd115count == 3 )
    {
        temp_ent notify( "sndDeleting" );
        level thread sndmuseggplay( temp_ent, "mus_zmb_secret_song_aether", 135 );
        level notify( "sndEnd115" );
    }
    else
    {
        temp_ent notify( "sndDeleting" );
        temp_ent delete();
    }
}

snd115egg_1_override()
{
    stance = self getstance();

    if ( is_true( level.music_override ) || stance != "prone" )
        return false;

    return true;
}

snd115egg_5_override()
{
    stance = self getstance();

    if ( is_true( level.music_override ) || stance != "prone" || level.snd115count < 2 )
        return false;

    return true;
}

snddelete115ent()
{
    self endon( "sndDeleting" );

    level waittill( "sndEnd115" );

    self delete();
}
