// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_dev_class;
#include maps\mp\gametypes\_globallogic_score;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\gametypes\_globallogic_utils;
#include maps\mp\gametypes\_globallogic;
#include maps\mp\gametypes\_rank;
#include maps\mp\gametypes\_hud_message;
#include maps\mp\gametypes\_killcam;
#include maps\mp\killstreaks\_helicopter;
#include maps\mp\killstreaks\_helicopter_gunner;
#include maps\mp\killstreaks\_radar;
#include maps\mp\killstreaks\_killstreakrules;
#include maps\mp\killstreaks\_supplydrop;
#include maps\mp\bots\_bot;

init()
{
/#
    if ( sessionmodeiszombiesgame() )
    {
        for (;;)
        {
            updatedevsettingszm();
            wait 0.5;
        }

        return;
    }

    if ( getdvar( "scr_showspawns" ) == "" )
        setdvar( "scr_showspawns", "0" );

    if ( getdvar( "scr_showstartspawns" ) == "" )
        setdvar( "scr_showstartspawns", "0" );

    if ( getdvar( "scr_botsHasPlayerWeapon" ) == "" )
        setdvar( "scr_botsHasPlayerWeapon", "0" );

    if ( getdvar( "scr_botsGrenadesOnly" ) == "" )
        setdvar( "scr_botsGrenadesOnly", "0" );

    if ( getdvar( "scr_botsSpecialGrenadesOnly" ) == "" )
        setdvar( "scr_botsSpecialGrenadesOnly", "0" );

    if ( getdvar( "scr_devHeliPathsDebugDraw" ) == "" )
        setdvar( "scr_devHeliPathsDebugDraw", "0" );

    if ( getdvar( "scr_devStrafeRunPathDebugDraw" ) == "" )
        setdvar( "scr_devStrafeRunPathDebugDraw", "0" );

    if ( getdvar( "scr_show_hq_spawns" ) == "" )
        setdvar( "scr_show_hq_spawns", "" );

    if ( getdvar( "scr_testScriptRuntimeError" ) == "" )
        setdvar( "scr_testScriptRuntimeError", "0" );

    precachemodel( "defaultactor" );
    precachestring( &"testPlayerScoreForTan" );
    thread testscriptruntimeerror();
    thread testdvars();
    thread addtestclients();
    thread addenemyheli();
    thread addenemyu2();
    thread addtestcarepackage();
    thread removetestclients();
    thread watch_botsdvars();
    thread devhelipathdebugdraw();
    thread devstraferunpathdebugdraw();
    thread maps\mp\gametypes\_dev_class::dev_cac_init();
    thread maps\mp\gametypes\_globallogic_score::setplayermomentumdebug();
    setdvar( "scr_giveperk", "" );
    setdvar( "scr_forceevent", "" );
    setdvar( "scr_draw_triggers", "0" );
    thread engagement_distance_debug_toggle();
    thread equipment_dev_gui();
    thread grenade_dev_gui();
    setdvar( "debug_dynamic_ai_spawning", "0" );
    level.bot_overlay = 0;
    level.bot_threat = 0;
    level.bot_path = 0;
    level.dem_spawns = [];

    if ( level.gametype == "dem" )
    {
        extra_spawns = [];
        extra_spawns[0] = "mp_dem_spawn_attacker_a";
        extra_spawns[1] = "mp_dem_spawn_attacker_b";
        extra_spawns[2] = "mp_dem_spawn_defender_a";
        extra_spawns[3] = "mp_dem_spawn_defender_b";

        for ( i = 0; i < extra_spawns.size; i++ )
        {
            points = getentarray( extra_spawns[i], "classname" );

            if ( isdefined( points ) && points.size > 0 )
                level.dem_spawns = arraycombine( level.dem_spawns, points, 1, 0 );
        }
    }

    thread onplayerconnect();

    for (;;)
    {
        updatedevsettings();
        wait 0.5;
    }
#/
}

onplayerconnect()
{
/#
    for (;;)
        level waittill( "connecting", player );
#/
}

updatehardpoints()
{
/#
    keys = getarraykeys( level.killstreaks );

    for ( i = 0; i < keys.size; i++ )
    {
        if ( !isdefined( level.killstreaks[keys[i]].devdvar ) )
            continue;

        dvar = level.killstreaks[keys[i]].devdvar;

        if ( getdvarint( dvar ) == 1 )
        {
            foreach ( player in level.players )
            {
                if ( isdefined( level.usingmomentum ) && level.usingmomentum && isdefined( level.usingscorestreaks ) && level.usingscorestreaks )
                {
                    player maps\mp\killstreaks\_killstreaks::givekillstreak( keys[i] );
                    continue;
                }

                if ( player is_bot() )
                {
                    player.bot["killstreaks"] = [];
                    player.bot["killstreaks"][0] = maps\mp\killstreaks\_killstreaks::getkillstreakmenuname( keys[i] );
                    killstreakweapon = maps\mp\killstreaks\_killstreaks::getkillstreakweapon( keys[i] );
                    player maps\mp\killstreaks\_killstreaks::givekillstreakweapon( killstreakweapon, 1 );
                    maps\mp\gametypes\_globallogic_score::_setplayermomentum( player, 2000 );
                    continue;
                }

                player maps\mp\killstreaks\_killstreaks::givekillstreak( keys[i] );
            }

            setdvar( dvar, "0" );
        }
    }
#/
}

warpalltohost( team )
{
/#
    host = gethostplayer();
    players = get_players();
    origin = host.origin;
    nodes = getnodesinradius( origin, 128, 32, 128, "Path" );
    angles = host getplayerangles();
    yaw = ( 0.0, angles[1], 0.0 );
    forward = anglestoforward( yaw );
    spawn_origin = origin + forward * 128 + vectorscale( ( 0, 0, 1 ), 16.0 );

    if ( !bullettracepassed( host geteye(), spawn_origin, 0, host ) )
        spawn_origin = undefined;

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] == host )
            continue;

        if ( isdefined( team ) )
        {
            if ( team == "enemies_host" && host.team == players[i].team )
                continue;

            if ( team == "friendlies_host" && host.team != players[i].team )
                continue;
        }

        if ( isdefined( spawn_origin ) )
        {
            players[i] setorigin( spawn_origin );
            continue;
        }

        if ( nodes.size > 0 )
        {
            node = random( nodes );
            players[i] setorigin( node.origin );
            continue;
        }

        players[i] setorigin( origin );
    }

    setdvar( "scr_playerwarp", "" );
#/
}

updatedevsettingszm()
{
/#
    if ( level.players.size > 0 )
    {
        if ( getdvar( "r_streamDumpDistance" ) == "3" )
        {
            if ( !isdefined( level.streamdumpteamindex ) )
                level.streamdumpteamindex = 0;
            else
                level.streamdumpteamindex++;

            numpoints = 0;
            spawnpoints = [];
            location = level.scr_zm_map_start_location;

            if ( ( location == "default" || location == "" ) && isdefined( level.default_start_location ) )
                location = level.default_start_location;

            match_string = level.scr_zm_ui_gametype + "_" + location;

            if ( level.streamdumpteamindex < level.teams.size )
            {
                structs = getstructarray( "initial_spawn", "script_noteworthy" );

                if ( isdefined( structs ) )
                {
                    foreach ( struct in structs )
                    {
                        if ( isdefined( struct.script_string ) )
                        {
                            tokens = strtok( struct.script_string, " " );

                            foreach ( token in tokens )
                            {
                                if ( token == match_string )
                                    spawnpoints[spawnpoints.size] = struct;
                            }
                        }
                    }
                }

                if ( !isdefined( spawnpoints ) || spawnpoints.size == 0 )
                    spawnpoints = getstructarray( "initial_spawn_points", "targetname" );

                if ( isdefined( spawnpoints ) )
                    numpoints = spawnpoints.size;
            }

            if ( numpoints == 0 )
            {
                setdvar( "r_streamDumpDistance", "0" );
                level.streamdumpteamindex = -1;
            }
            else
            {
                averageorigin = ( 0, 0, 0 );
                averageangles = ( 0, 0, 0 );

                foreach ( spawnpoint in spawnpoints )
                {
                    averageorigin += spawnpoint.origin / numpoints;
                    averageangles += spawnpoint.angles / numpoints;
                }

                level.players[0] setplayerangles( averageangles );
                level.players[0] setorigin( averageorigin );
                wait 0.05;
                setdvar( "r_streamDumpDistance", "2" );
            }
        }
    }
#/
}

updatedevsettings()
{
/#
    show_spawns = getdvarint( "scr_showspawns" );
    show_start_spawns = getdvarint( "scr_showstartspawns" );
    player = gethostplayer();

    if ( show_spawns >= 1 )
        show_spawns = 1;
    else
        show_spawns = 0;

    if ( show_start_spawns >= 1 )
        show_start_spawns = 1;
    else
        show_start_spawns = 0;

    if ( !isdefined( level.show_spawns ) || level.show_spawns != show_spawns )
    {
        level.show_spawns = show_spawns;
        setdvar( "scr_showspawns", level.show_spawns );

        if ( level.show_spawns )
            showspawnpoints();
        else
            hidespawnpoints();
    }

    if ( !isdefined( level.show_start_spawns ) || level.show_start_spawns != show_start_spawns )
    {
        level.show_start_spawns = show_start_spawns;
        setdvar( "scr_showstartspawns", level.show_start_spawns );

        if ( level.show_start_spawns )
            showstartspawnpoints();
        else
            hidestartspawnpoints();
    }

    updateminimapsetting();

    if ( level.players.size > 0 )
    {
        updatehardpoints();

        if ( getdvar( "scr_playerwarp" ) == "host" )
            warpalltohost();
        else if ( getdvar( "scr_playerwarp" ) == "enemies_host" )
            warpalltohost( getdvar( "scr_playerwarp" ) );
        else if ( getdvar( "scr_playerwarp" ) == "friendlies_host" )
            warpalltohost( getdvar( "scr_playerwarp" ) );
        else if ( getdvar( "scr_playerwarp" ) == "next_start_spawn" )
        {
            players = get_players();
            setdvar( "scr_playerwarp", "" );

            if ( !isdefined( level.devgui_start_spawn_index ) )
                level.devgui_start_spawn_index = 0;

            player = gethostplayer();
            spawns = level.spawn_start[player.pers["team"]];

            if ( !isdefined( spawns ) || spawns.size <= 0 )
                return;

            for ( i = 0; i < players.size; i++ )
            {
                players[i] setorigin( spawns[level.devgui_start_spawn_index].origin );
                players[i] setplayerangles( spawns[level.devgui_start_spawn_index].angles );
            }

            level.devgui_start_spawn_index++;

            if ( level.devgui_start_spawn_index >= spawns.size )
                level.devgui_start_spawn_index = 0;
        }
        else if ( getdvar( "scr_playerwarp" ) == "prev_start_spawn" )
        {
            players = get_players();
            setdvar( "scr_playerwarp", "" );

            if ( !isdefined( level.devgui_start_spawn_index ) )
                level.devgui_start_spawn_index = 0;

            player = gethostplayer();
            spawns = level.spawn_start[player.pers["team"]];

            if ( !isdefined( spawns ) || spawns.size <= 0 )
                return;

            for ( i = 0; i < players.size; i++ )
            {
                players[i] setorigin( spawns[level.devgui_start_spawn_index].origin );
                players[i] setplayerangles( spawns[level.devgui_start_spawn_index].angles );
            }

            level.devgui_start_spawn_index--;

            if ( level.devgui_start_spawn_index < 0 )
                level.devgui_start_spawn_index = spawns.size - 1;
        }
        else if ( getdvar( "scr_playerwarp" ) == "next_spawn" )
        {
            players = get_players();
            setdvar( "scr_playerwarp", "" );

            if ( !isdefined( level.devgui_spawn_index ) )
                level.devgui_spawn_index = 0;

            spawns = level.spawnpoints;
            spawns = arraycombine( spawns, level.dem_spawns, 1, 0 );

            if ( !isdefined( spawns ) || spawns.size <= 0 )
                return;

            for ( i = 0; i < players.size; i++ )
            {
                players[i] setorigin( spawns[level.devgui_spawn_index].origin );
                players[i] setplayerangles( spawns[level.devgui_spawn_index].angles );
            }

            level.devgui_spawn_index++;

            if ( level.devgui_spawn_index >= spawns.size )
                level.devgui_spawn_index = 0;
        }
        else if ( getdvar( "scr_playerwarp" ) == "prev_spawn" )
        {
            players = get_players();
            setdvar( "scr_playerwarp", "" );

            if ( !isdefined( level.devgui_spawn_index ) )
                level.devgui_spawn_index = 0;

            spawns = level.spawnpoints;
            spawns = arraycombine( spawns, level.dem_spawns, 1, 0 );

            if ( !isdefined( spawns ) || spawns.size <= 0 )
                return;

            for ( i = 0; i < players.size; i++ )
            {
                players[i] setorigin( spawns[level.devgui_spawn_index].origin );
                players[i] setplayerangles( spawns[level.devgui_spawn_index].angles );
            }

            level.devgui_spawn_index--;

            if ( level.devgui_spawn_index < 0 )
                level.devgui_spawn_index = spawns.size - 1;
        }
        else if ( getdvar( "scr_devgui_spawn" ) != "" )
        {
            player = gethostplayer();

            if ( !isdefined( player.devgui_spawn_active ) )
                player.devgui_spawn_active = 0;

            if ( !player.devgui_spawn_active )
            {
                iprintln( "Previous spawn bound to D-Pad Left" );
                iprintln( "Next spawn bound to D-Pad Right" );
                player.devgui_spawn_active = 1;
                player thread devgui_spawn_think();
            }
            else
            {
                player notify( "devgui_spawn_think" );
                player.devgui_spawn_active = 0;
                player setactionslot( 3, "altMode" );
                player setactionslot( 4, "nightvision" );
            }

            setdvar( "scr_devgui_spawn", "" );
        }
        else if ( getdvar( "scr_player_ammo" ) != "" )
        {
            players = get_players();

            if ( !isdefined( level.devgui_unlimited_ammo ) )
                level.devgui_unlimited_ammo = 1;
            else
                level.devgui_unlimited_ammo = !level.devgui_unlimited_ammo;

            if ( level.devgui_unlimited_ammo )
                iprintln( "Giving unlimited ammo to all players" );
            else
                iprintln( "Stopping unlimited ammo for all players" );

            for ( i = 0; i < players.size; i++ )
            {
                if ( level.devgui_unlimited_ammo )
                {
                    players[i] thread devgui_unlimited_ammo();
                    continue;
                }

                players[i] notify( "devgui_unlimited_ammo" );
            }

            setdvar( "scr_player_ammo", "" );
        }
        else if ( getdvar( "scr_player_momentum" ) != "" )
        {
            if ( !isdefined( level.devgui_unlimited_momentum ) )
                level.devgui_unlimited_momentum = 1;
            else
                level.devgui_unlimited_momentum = !level.devgui_unlimited_momentum;

            if ( level.devgui_unlimited_momentum )
            {
                iprintln( "Giving unlimited momentum to all players" );
                level thread devgui_unlimited_momentum();
            }
            else
            {
                iprintln( "Stopping unlimited momentum for all players" );
                level notify( "devgui_unlimited_momentum" );
            }

            setdvar( "scr_player_momentum", "" );
        }
        else if ( getdvar( "scr_give_player_score" ) != "" )
        {
            level thread devgui_increase_momentum( getdvarint( "scr_give_player_score" ) );
            setdvar( "scr_give_player_score", "" );
        }
        else if ( getdvar( "scr_player_zero_ammo" ) != "" )
        {
            players = get_players();

            for ( i = 0; i < players.size; i++ )
            {
                player = players[i];
                weapons = player getweaponslist();
                arrayremovevalue( weapons, "knife_mp" );

                for ( j = 0; j < weapons.size; j++ )
                {
                    if ( weapons[j] == "none" )
                        continue;

                    player setweaponammostock( weapons[j], 0 );
                    player setweaponammoclip( weapons[j], 0 );
                }
            }

            setdvar( "scr_player_zero_ammo", "" );
        }
        else if ( getdvar( "scr_emp_jammed" ) != "" )
        {
            players = get_players();

            for ( i = 0; i < players.size; i++ )
            {
                player = players[i];

                if ( getdvar( "scr_emp_jammed" ) == "0" )
                {
                    player setempjammed( 0 );
                    continue;
                }

                player setempjammed( 1 );
            }

            setdvar( "scr_emp_jammed", "" );
        }
        else if ( getdvar( "scr_round_pause" ) != "" )
        {
            if ( !level.timerstopped )
            {
                iprintln( "Pausing Round Timer" );
                maps\mp\gametypes\_globallogic_utils::pausetimer();
            }
            else
            {
                iprintln( "Resuming Round Timer" );
                maps\mp\gametypes\_globallogic_utils::resumetimer();
            }

            setdvar( "scr_round_pause", "" );
        }
        else if ( getdvar( "scr_round_end" ) != "" )
        {
            level maps\mp\gametypes\_globallogic::forceend();
            setdvar( "scr_round_end", "" );
        }
        else if ( getdvar( "scr_health_debug" ) != "" )
        {
            players = get_players();
            host = gethostplayer();

            if ( !isdefined( host.devgui_health_debug ) )
                host.devgui_health_debug = 0;

            if ( host.devgui_health_debug )
            {
                host.devgui_health_debug = 0;

                for ( i = 0; i < players.size; i++ )
                {
                    players[i] notify( "devgui_health_debug" );

                    if ( isdefined( players[i].debug_health_bar ) )
                    {
                        players[i].debug_health_bar destroy();
                        players[i].debug_health_text destroy();
                        players[i].debug_health_bar = undefined;
                        players[i].debug_health_text = undefined;
                    }
                }
            }
            else
            {
                host.devgui_health_debug = 1;

                for ( i = 0; i < players.size; i++ )
                    players[i] thread devgui_health_debug();
            }

            setdvar( "scr_health_debug", "" );
        }
        else if ( getdvar( "scr_show_hq_spawns" ) != "" )
        {
            if ( !isdefined( level.devgui_show_hq ) )
                level.devgui_show_hq = 0;

            if ( level.gametype == "koth" && isdefined( level.radios ) )
            {
                if ( !level.devgui_show_hq )
                {
                    for ( i = 0; i < level.radios.size; i++ )
                    {
                        color = ( 1, 0, 0 );
                        level showonespawnpoint( level.radios[i], color, "hide_hq_points", 32, "hq_spawn" );
                    }
                }
                else
                    level notify( "hide_hq_points" );

                level.devgui_show_hq = !level.devgui_show_hq;
            }

            setdvar( "scr_show_hq_spawns", "" );
        }

        if ( getdvar( "r_streamDumpDistance" ) == "3" )
        {
            if ( !isdefined( level.streamdumpteamindex ) )
                level.streamdumpteamindex = 0;
            else
                level.streamdumpteamindex++;

            numpoints = 0;

            if ( level.streamdumpteamindex < level.teams.size )
            {
                teamname = getarraykeys( level.teams )[level.streamdumpteamindex];

                if ( isdefined( level.spawn_start[teamname] ) )
                    numpoints = level.spawn_start[teamname].size;
            }

            if ( numpoints == 0 )
            {
                setdvar( "r_streamDumpDistance", "0" );
                level.streamdumpteamindex = -1;
            }
            else
            {
                averageorigin = ( 0, 0, 0 );
                averageangles = ( 0, 0, 0 );

                foreach ( spawnpoint in level.spawn_start[teamname] )
                {
                    averageorigin += spawnpoint.origin / numpoints;
                    averageangles += spawnpoint.angles / numpoints;
                }

                level.players[0] setplayerangles( averageangles );
                level.players[0] setorigin( averageorigin );
                wait 0.05;
                setdvar( "r_streamDumpDistance", "2" );
            }
        }
    }

    if ( getdvar( "scr_giveperk" ) == "0" )
    {
        players = get_players();
        iprintln( "Taking all perks from all players" );

        for ( i = 0; i < players.size; i++ )
            players[i] clearperks();

        setdvar( "scr_giveperk", "" );
    }

    if ( getdvar( "scr_giveperk" ) != "" )
    {
        perk = getdvar( "scr_giveperk" );
        specialties = strtok( perk, "|" );
        players = get_players();
        iprintln( "Giving all players perk: '" + perk + "'" );

        for ( i = 0; i < players.size; i++ )
        {
            for ( j = 0; j < specialties.size; j++ )
            {
                players[i] setperk( specialties[j] );
                players[i].extraperks[specialties[j]] = 1;
            }
        }

        setdvar( "scr_giveperk", "" );
    }

    if ( getdvar( "scr_forcegrenade" ) != "" )
    {
        force_grenade_throw( getdvar( "scr_forcegrenade" ) );
        setdvar( "scr_forcegrenade", "" );
    }

    if ( getdvar( "scr_forceevent" ) != "" )
    {
        event = getdvar( "scr_forceevent" );
        player = gethostplayer();
        forward = anglestoforward( player.angles );
        right = anglestoright( player.angles );

        if ( event == "painfront" )
            player dodamage( 1, player.origin + forward );
        else if ( event == "painback" )
            player dodamage( 1, player.origin - forward );
        else if ( event == "painleft" )
            player dodamage( 1, player.origin - right );
        else if ( event == "painright" )
            player dodamage( 1, player.origin + right );

        setdvar( "scr_forceevent", "" );
    }

    if ( getdvar( "scr_takeperk" ) != "" )
    {
        perk = getdvar( "scr_takeperk" );

        for ( i = 0; i < level.players.size; i++ )
        {
            level.players[i] unsetperk( perk );
            level.players[i].extraperks[perk] = undefined;
        }

        setdvar( "scr_takeperk", "" );
    }

    if ( getdvar( "scr_x_kills_y" ) != "" )
    {
        nametokens = strtok( getdvar( "scr_x_kills_y" ), " " );

        if ( nametokens.size > 1 )
            thread xkillsy( nametokens[0], nametokens[1] );

        setdvar( "scr_x_kills_y", "" );
    }

    if ( getdvar( "scr_usedogs" ) != "" )
    {
        ownername = getdvar( "scr_usedogs" );
        setdvar( "scr_usedogs", "" );
        owner = undefined;

        for ( index = 0; index < level.players.size; index++ )
        {
            if ( level.players[index].name == ownername )
                owner = level.players[index];
        }

        if ( isdefined( owner ) )
            owner maps\mp\killstreaks\_killstreaks::triggerkillstreak( "dogs_mp" );
    }

    if ( getdvar( "scr_set_level" ) != "" )
    {
        player.pers["rank"] = 0;
        player.pers["rankxp"] = 0;
        newrank = min( getdvarint( "scr_set_level" ), 54 );
        newrank = max( newrank, 1 );
        setdvar( "scr_set_level", "" );
        lastxp = 0;

        for ( index = 0; index <= newrank; index++ )
        {
            newxp = maps\mp\gametypes\_rank::getrankinfominxp( index );
            player thread maps\mp\gametypes\_rank::giverankxp( "kill", newxp - lastxp );
            lastxp = newxp;
            wait 0.25;
            self notify( "cancel_notify" );
        }
    }

    if ( getdvar( "scr_givexp" ) != "" )
    {
        player thread maps\mp\gametypes\_rank::giverankxp( "challenge", getdvarint( "scr_givexp" ), 1 );
        setdvar( "scr_givexp", "" );
    }

    if ( getdvar( "scr_do_notify" ) != "" )
    {
        for ( i = 0; i < level.players.size; i++ )
            level.players[i] maps\mp\gametypes\_hud_message::oldnotifymessage( getdvar( "scr_do_notify" ), getdvar( "scr_do_notify" ), game["icons"]["allies"] );

        announcement( getdvar( "scr_do_notify" ), 0 );
        setdvar( "scr_do_notify", "" );
    }

    if ( getdvar( _hash_4F1284FA ) != "" )
    {
        ents = getentarray();
        level.entarray = [];
        level.entcounts = [];
        level.entgroups = [];

        for ( index = 0; index < ents.size; index++ )
        {
            classname = ents[index].classname;

            if ( !issubstr( classname, "_spawn" ) )
            {
                curent = ents[index];
                level.entarray[level.entarray.size] = curent;

                if ( !isdefined( level.entcounts[classname] ) )
                    level.entcounts[classname] = 0;

                level.entcounts[classname]++;

                if ( !isdefined( level.entgroups[classname] ) )
                    level.entgroups[classname] = [];

                level.entgroups[classname][level.entgroups[classname].size] = curent;
            }
        }
    }

    if ( getdvar( "debug_dynamic_ai_spawning" ) == "1" && !isdefined( level.larry ) )
        thread larry_thread();
    else if ( getdvar( "debug_dynamic_ai_spawning" ) == "0" )
        level notify( "kill_larry" );

    if ( level.bot_overlay == 0 && getdvarint( _hash_1CBC4852 ) == 1 )
    {
        level thread bot_overlay_think();
        level.bot_overlay = 1;
    }
    else if ( level.bot_overlay == 1 && getdvarint( _hash_1CBC4852 ) == 0 )
    {
        level bot_overlay_stop();
        level.bot_overlay = 0;
    }

    if ( level.bot_threat == 0 && getdvarint( _hash_68A98D18 ) == 1 )
    {
        level thread bot_threat_think();
        level.bot_threat = 1;
    }
    else if ( level.bot_threat == 1 && getdvarint( _hash_68A98D18 ) == 0 )
    {
        level bot_threat_stop();
        level.bot_threat = 0;
    }

    if ( level.bot_path == 0 && getdvarint( _hash_D6F2CC5D ) == 1 )
    {
        level thread bot_path_think();
        level.bot_path = 1;
    }
    else if ( level.bot_path == 1 && getdvarint( _hash_D6F2CC5D ) == 0 )
    {
        level bot_path_stop();
        level.bot_path = 0;
    }

    if ( getdvarint( "scr_force_finalkillcam" ) == 1 )
    {
        level thread maps\mp\gametypes\_killcam::dofinalkillcam();
        level thread waitthennotifyfinalkillcam();
    }

    if ( getdvarint( "scr_force_roundkillcam" ) == 1 )
    {
        level thread maps\mp\gametypes\_killcam::dofinalkillcam();
        level thread waitthennotifyroundkillcam();
    }

    if ( !level.bot_overlay && !level.bot_threat && !level.bot_path )
        level notify( "bot_dpad_terminate" );
#/
}

waitthennotifyroundkillcam()
{
/#
    wait 0.05;
    level notify( "play_final_killcam" );
    setdvar( "scr_force_roundkillcam", 0 );
#/
}

waitthennotifyfinalkillcam()
{
/#
    wait 0.05;
    level notify( "play_final_killcam" );
    wait 0.05;
    setdvar( "scr_force_finalkillcam", 0 );
#/
}

devgui_spawn_think()
{
/#
    self notify( "devgui_spawn_think" );
    self endon( "devgui_spawn_think" );
    self endon( "disconnect" );
    dpad_left = 0;
    dpad_right = 0;

    for (;;)
    {
        self setactionslot( 3, "" );
        self setactionslot( 4, "" );

        if ( !dpad_left && self buttonpressed( "DPAD_LEFT" ) )
        {
            setdvar( "scr_playerwarp", "prev_spawn" );
            dpad_left = 1;
        }
        else if ( !self buttonpressed( "DPAD_LEFT" ) )
            dpad_left = 0;

        if ( !dpad_right && self buttonpressed( "DPAD_RIGHT" ) )
        {
            setdvar( "scr_playerwarp", "next_spawn" );
            dpad_right = 1;
        }
        else if ( !self buttonpressed( "DPAD_RIGHT" ) )
            dpad_right = 0;

        wait 0.05;
    }
#/
}

devgui_unlimited_ammo()
{
/#
    self notify( "devgui_unlimited_ammo" );
    self endon( "devgui_unlimited_ammo" );
    self endon( "disconnect" );

    for (;;)
    {
        wait 0.1;
        weapons = [];
        weapons[0] = self getcurrentweapon();
        weapons[1] = self getcurrentoffhand();

        for ( i = 0; i < weapons.size; i++ )
        {
            if ( weapons[i] == "none" )
                continue;

            if ( maps\mp\killstreaks\_killstreaks::iskillstreakweapon( weapons[i] ) )
                continue;

            self givemaxammo( weapons[i] );
        }
    }
#/
}

devgui_unlimited_momentum()
{
/#
    level notify( "devgui_unlimited_momentum" );
    level endon( "devgui_unlimited_momentum" );

    for (;;)
    {
        wait 1;
        players = get_players();

        foreach ( player in players )
        {
            if ( !isdefined( player ) )
                continue;

            if ( !isalive( player ) )
                continue;

            if ( player.sessionstate != "playing" )
                continue;

            maps\mp\gametypes\_globallogic_score::_setplayermomentum( player, 5000 );
        }
    }
#/
}

devgui_increase_momentum( score )
{
/#
    players = get_players();

    foreach ( player in players )
    {
        if ( !isdefined( player ) )
            continue;

        if ( !isalive( player ) )
            continue;

        if ( player.sessionstate != "playing" )
            continue;

        player maps\mp\gametypes\_globallogic_score::giveplayermomentumnotification( score, &"testPlayerScoreForTan", "PLAYER_SCORE", 0 );
    }
#/
}

devgui_health_debug()
{
/#
    self notify( "devgui_health_debug" );
    self endon( "devgui_health_debug" );
    self endon( "disconnect" );
    x = 80;
    y = 40;
    self.debug_health_bar = newclienthudelem( self );
    self.debug_health_bar.x = x + 80;
    self.debug_health_bar.y = y + 2;
    self.debug_health_bar.alignx = "left";
    self.debug_health_bar.aligny = "top";
    self.debug_health_bar.horzalign = "fullscreen";
    self.debug_health_bar.vertalign = "fullscreen";
    self.debug_health_bar.alpha = 1;
    self.debug_health_bar.foreground = 1;
    self.debug_health_bar setshader( "black", 1, 8 );
    self.debug_health_text = newclienthudelem( self );
    self.debug_health_text.x = x + 80;
    self.debug_health_text.y = y;
    self.debug_health_text.alignx = "left";
    self.debug_health_text.aligny = "top";
    self.debug_health_text.horzalign = "fullscreen";
    self.debug_health_text.vertalign = "fullscreen";
    self.debug_health_text.alpha = 1;
    self.debug_health_text.fontscale = 1;
    self.debug_health_text.foreground = 1;

    if ( !isdefined( self.maxhealth ) || self.maxhealth <= 0 )
        self.maxhealth = 100;

    for (;;)
    {
        wait 0.05;
        width = self.health / self.maxhealth * 300;
        width = int( max( width, 1 ) );
        self.debug_health_bar setshader( "black", width, 8 );
        self.debug_health_text setvalue( self.health );
    }
#/
}

giveextraperks()
{
/#
    if ( !isdefined( self.extraperks ) )
        return;

    perks = getarraykeys( self.extraperks );

    for ( i = 0; i < perks.size; i++ )
        self setperk( perks[i] );
#/
}

xkillsy( attackername, victimname )
{
/#
    attacker = undefined;
    victim = undefined;

    for ( index = 0; index < level.players.size; index++ )
    {
        if ( level.players[index].name == attackername )
        {
            attacker = level.players[index];
            continue;
        }

        if ( level.players[index].name == victimname )
            victim = level.players[index];
    }

    if ( !isalive( attacker ) || !isalive( victim ) )
        return;

    victim thread [[ level.callbackplayerdamage ]]( attacker, attacker, 1000, 0, "MOD_RIFLE_BULLET", "none", ( 0, 0, 0 ), ( 0, 0, 0 ), "none", 0, 0 );
#/
}

updateminimapsetting()
{
/#
    requiredmapaspectratio = getdvarfloat( "scr_RequiredMapAspectratio" );

    if ( !isdefined( level.minimapheight ) )
    {
        setdvar( "scr_minimap_height", "0" );
        level.minimapheight = 0;
    }

    minimapheight = getdvarfloat( "scr_minimap_height" );

    if ( minimapheight != level.minimapheight )
    {
        if ( minimapheight <= 0 )
        {
            gethostplayer() cameraactivate( 0 );
            level.minimapheight = minimapheight;
            level notify( "end_draw_map_bounds" );
        }

        if ( minimapheight > 0 )
        {
            level.minimapheight = minimapheight;
            players = get_players();

            if ( players.size > 0 )
            {
                player = gethostplayer();
                corners = getentarray( "minimap_corner", "targetname" );

                if ( corners.size == 2 )
                {
                    viewpos = corners[0].origin + corners[1].origin;
                    viewpos = ( viewpos[0] * 0.5, viewpos[1] * 0.5, viewpos[2] * 0.5 );
                    level thread minimapwarn( corners );
                    maxcorner = ( corners[0].origin[0], corners[0].origin[1], viewpos[2] );
                    mincorner = ( corners[0].origin[0], corners[0].origin[1], viewpos[2] );

                    if ( corners[1].origin[0] > corners[0].origin[0] )
                        maxcorner = ( corners[1].origin[0], maxcorner[1], maxcorner[2] );
                    else
                        mincorner = ( corners[1].origin[0], mincorner[1], mincorner[2] );

                    if ( corners[1].origin[1] > corners[0].origin[1] )
                        maxcorner = ( maxcorner[0], corners[1].origin[1], maxcorner[2] );
                    else
                        mincorner = ( mincorner[0], corners[1].origin[1], mincorner[2] );

                    viewpostocorner = maxcorner - viewpos;
                    viewpos = ( viewpos[0], viewpos[1], viewpos[2] + minimapheight );
                    northvector = ( cos( getnorthyaw() ), sin( getnorthyaw() ), 0 );
                    eastvector = ( northvector[1], 0 - northvector[0], 0 );
                    disttotop = vectordot( northvector, viewpostocorner );

                    if ( disttotop < 0 )
                        disttotop = 0 - disttotop;

                    disttoside = vectordot( eastvector, viewpostocorner );

                    if ( disttoside < 0 )
                        disttoside = 0 - disttoside;

                    if ( requiredmapaspectratio > 0 )
                    {
                        mapaspectratio = disttoside / disttotop;

                        if ( mapaspectratio < requiredmapaspectratio )
                        {
                            incr = requiredmapaspectratio / mapaspectratio;
                            disttoside *= incr;
                            addvec = vecscale( eastvector, vectordot( eastvector, maxcorner - viewpos ) * ( incr - 1 ) );
                            mincorner -= addvec;
                            maxcorner += addvec;
                        }
                        else
                        {
                            incr = mapaspectratio / requiredmapaspectratio;
                            disttotop *= incr;
                            addvec = vecscale( northvector, vectordot( northvector, maxcorner - viewpos ) * ( incr - 1 ) );
                            mincorner -= addvec;
                            maxcorner += addvec;
                        }
                    }

                    if ( level.console )
                    {
                        aspectratioguess = 1.77778;
                        angleside = 2 * atan( disttoside * 0.8 / minimapheight );
                        angletop = 2 * atan( disttotop * aspectratioguess * 0.8 / minimapheight );
                    }
                    else
                    {
                        aspectratioguess = 1.33333;
                        angleside = 2 * atan( disttoside / minimapheight );
                        angletop = 2 * atan( disttotop * aspectratioguess / minimapheight );
                    }

                    if ( angleside > angletop )
                        angle = angleside;
                    else
                        angle = angletop;

                    znear = minimapheight - 1000;

                    if ( znear < 16 )
                        znear = 16;

                    if ( znear > 10000 )
                        znear = 10000;

                    player camerasetposition( viewpos, ( 90, getnorthyaw(), 0 ) );
                    player cameraactivate( 1 );
                    player takeallweapons();
                    setdvar( "cg_drawGun", 0 );
                    setdvar( "cg_draw2D", 0 );
                    setdvar( "cg_drawFPS", 0 );
                    setdvar( "fx_enable", 0 );
                    setdvar( "r_fog", 0 );
                    setdvar( "r_highLodDist", 0 );
                    setdvar( "r_znear", znear );
                    setdvar( "r_lodscale", 0 );
                    setdvar( "r_lodScaleRigid", 0 );
                    setdvar( "cg_drawVersion", 0 );
                    setdvar( "sm_enable", 1 );
                    setdvar( "player_view_pitch_down", 90 );
                    setdvar( "player_view_pitch_up", 0 );
                    setdvar( "cg_fov", angle );
                    setdvar( "cg_fovMin", 1 );
                    setdvar( "debug_show_viewpos", "0" );

                    if ( isdefined( level.objpoints ) )
                    {
                        for ( i = 0; i < level.objpointnames.size; i++ )
                        {
                            if ( isdefined( level.objpoints[level.objpointnames[i]] ) )
                                level.objpoints[level.objpointnames[i]] destroy();
                        }

                        level.objpoints = [];
                        level.objpointnames = [];
                    }

                    thread drawminimapbounds( viewpos, mincorner, maxcorner );
                }
                else
                    println( "^1Error: There are not exactly 2 \"minimap_corner\" entities in the level." );
            }
            else
                setdvar( "scr_minimap_height", "0" );
        }
    }
#/
}

vecscale( vec, scalar )
{
/#
    return ( vec[0] * scalar, vec[1] * scalar, vec[2] * scalar );
#/
}

drawminimapbounds( viewpos, mincorner, maxcorner )
{
/#
    level notify( "end_draw_map_bounds" );
    level endon( "end_draw_map_bounds" );
    viewheight = viewpos[2] - maxcorner[2];
    north = ( cos( getnorthyaw() ), sin( getnorthyaw() ), 0 );
    diaglen = length( mincorner - maxcorner );
    mincorneroffset = mincorner - viewpos;
    mincorneroffset = vectornormalize( ( mincorneroffset[0], mincorneroffset[1], 0 ) );
    mincorner += vecscale( mincorneroffset, diaglen * 1 / 800 );
    maxcorneroffset = maxcorner - viewpos;
    maxcorneroffset = vectornormalize( ( maxcorneroffset[0], maxcorneroffset[1], 0 ) );
    maxcorner += vecscale( maxcorneroffset, diaglen * 1 / 800 );
    diagonal = maxcorner - mincorner;
    side = vecscale( north, vectordot( diagonal, north ) );
    sidenorth = vecscale( north, abs( vectordot( diagonal, north ) ) );
    corner0 = mincorner;
    corner1 = mincorner + side;
    corner2 = maxcorner;
    corner3 = maxcorner - side;
    toppos = vecscale( mincorner + maxcorner, 0.5 ) + vecscale( sidenorth, 0.51 );
    textscale = diaglen * 0.003;

    while ( true )
    {
        line( corner0, corner1 );
        line( corner1, corner2 );
        line( corner2, corner3 );
        line( corner3, corner0 );
        print3d( toppos, "This Side Up", ( 1, 1, 1 ), 1, textscale );
        wait 0.05;
    }
#/
}

minimapwarn( corners )
{
/#
    threshold = 10;
    width = abs( corners[0].origin[0] - corners[1].origin[0] );
    width = int( width );
    height = abs( corners[0].origin[1] - corners[1].origin[1] );
    height = int( height );

    if ( abs( width - height ) > threshold )
    {
        for (;;)
        {
            iprintln( "^1Warning: Minimap corners do not form a square (width: " + width + " height: " + height + ")\\n" );

            if ( height > width )
            {
                scale = height / width;
                iprintln( "^1Warning: The compass minimap might be scaled: " + scale + " units in height more than width\\n" );
            }
            else
            {
                scale = width / height;
                iprintln( "^1Warning: The compass minimap might be scaled: " + scale + " units in width more than height\\n" );
            }

            wait 10;
        }
    }
#/
}

testscriptruntimeerrorassert()
{
/#
    wait 1;
    assert( 0 );
#/
}

testscriptruntimeerror2()
{
/#
    myundefined = "test";

    if ( myundefined == 1 )
        println( "undefined in testScriptRuntimeError2\\n" );
#/
}

testscriptruntimeerror1()
{
/#
    testscriptruntimeerror2();
#/
}

testscriptruntimeerror()
{
/#
    wait 5;

    for (;;)
    {
        if ( getdvar( "scr_testScriptRuntimeError" ) != "0" )
            break;

        wait 1;
    }

    myerror = getdvar( "scr_testScriptRuntimeError" );
    setdvar( "scr_testScriptRuntimeError", "0" );

    if ( myerror == "assert" )
        testscriptruntimeerrorassert();
    else
        testscriptruntimeerror1();

    thread testscriptruntimeerror();
#/
}

testdvars()
{
/#
    wait 5;

    for (;;)
    {
        if ( getdvar( "scr_testdvar" ) != "" )
            break;

        wait 1;
    }

    tokens = strtok( getdvar( "scr_testdvar" ), " " );
    dvarname = tokens[0];
    dvarvalue = tokens[1];
    setdvar( dvarname, dvarvalue );
    setdvar( "scr_testdvar", "" );
    thread testdvars();
#/
}

addtestclients()
{
/#
    wait 5;

    for (;;)
    {
        if ( getdvarint( "scr_testclients" ) > 0 )
            break;

        wait 1;
    }

    playsoundonplayers( "vox_kls_dav_spawn" );
    testclients = getdvarint( "scr_testclients" );
    setdvar( "scr_testclients", 0 );

    for ( i = 0; i < testclients; i++ )
    {
        ent[i] = addtestclient();

        if ( !isdefined( ent[i] ) )
        {
            println( "Could not add test client" );
            wait 1;
            continue;
        }

        ent[i].pers["isBot"] = 1;
        ent[i] thread testclient( "autoassign" );
    }

    thread addtestclients();
#/
}

addenemyheli()
{
/#
    wait 5;

    for (;;)
    {
        if ( getdvarint( "scr_spawnenemyheli" ) > 0 )
            break;

        wait 1;
    }

    enemyheli = getdvarint( "scr_spawnenemyheli" );
    setdvar( "scr_spawnenemyheli", 0 );
    team = "autoassign";
    player = gethostplayer();

    if ( isdefined( player.pers["team"] ) )
        team = getotherteam( player.pers["team"] );

    ent = getormakebot( team );

    if ( !isdefined( ent ) )
    {
        println( "Could not add test client" );
        wait 1;
        thread addenemyheli();
        return;
    }

    switch ( enemyheli )
    {
        case 1:
            level.helilocation = ent.origin;
            ent thread maps\mp\killstreaks\_helicopter::usekillstreakhelicopter( "helicopter_comlink_mp" );
            wait 0.5;
            ent notify( "confirm_location", level.helilocation );
            break;
        case 2:
            ent thread maps\mp\killstreaks\_helicopter_gunner::heli_gunner_killstreak( "helicopter_player_gunner_mp" );
            break;
    }

    thread addenemyheli();
#/
}

getormakebot( team )
{
/#
    for ( i = 0; i < level.players.size; i++ )
    {
        if ( level.players[i].team == team )
        {
            if ( isdefined( level.players[i].pers["isBot"] ) && level.players[i].pers["isBot"] )
                return level.players[i];
        }
    }

    ent = addtestclient();

    if ( isdefined( ent ) )
    {
        playsoundonplayers( "vox_kls_dav_spawn" );
        ent.pers["isBot"] = 1;
        ent thread testclient( team );
        wait 1;
    }

    return ent;
#/
}

addenemyu2()
{
/#
    wait 5;

    for (;;)
    {
        if ( getdvarint( "scr_spawnenemyu2" ) > 0 )
            break;

        wait 1;
    }

    type = getdvarint( "scr_spawnenemyu2" );
    setdvar( "scr_spawnenemyu2", 0 );
    team = "autoassign";
    player = gethostplayer();

    if ( isdefined( player.team ) )
        team = getotherteam( player.team );

    ent = getormakebot( team );

    if ( !isdefined( ent ) )
    {
        println( "Could not add test client" );
        wait 1;
        thread addenemyu2();
        return;
    }

    if ( type == 3 )
        ent thread maps\mp\killstreaks\_radar::usekillstreaksatellite( "radardirection_mp" );
    else if ( type == 2 )
        ent thread maps\mp\killstreaks\_radar::usekillstreakcounteruav( "counteruav_mp" );
    else
        ent thread maps\mp\killstreaks\_radar::usekillstreakradar( "radar_mp" );

    thread addenemyu2();
#/
}

addtestcarepackage()
{
/#
    wait 5;

    for (;;)
    {
        if ( getdvarint( "scr_givetestsupplydrop" ) > 0 )
            break;

        wait 1;
    }

    supplydrop = getdvarint( "scr_givetestsupplydrop" );
    team = "autoassign";
    player = gethostplayer();

    if ( isdefined( player.pers["team"] ) )
    {
        switch ( supplydrop )
        {
            case 2:
                team = getotherteam( player.pers["team"] );
                break;
            case 1:
            default:
                team = player.pers["team"];
                break;
        }
    }

    setdvar( "scr_givetestsupplydrop", 0 );
    ent = getormakebot( team );

    if ( !isdefined( ent ) )
    {
        println( "Could not add test client" );
        wait 1;
        thread addtestcarepackage();
        return;
    }

    ent maps\mp\killstreaks\_killstreakrules::killstreakstart( "supply_drop_mp", team );
    ent thread maps\mp\killstreaks\_supplydrop::helidelivercrate( ent.origin, "supplydrop_mp", ent, team );
    thread addtestcarepackage();
#/
}

removetestclients()
{
/#
    wait 5;

    for (;;)
    {
        if ( getdvarint( "scr_testclientsremove" ) > 0 )
            break;

        wait 1;
    }

    playsoundonplayers( "vox_kls_dav_kill" );
    removetype = getdvarint( "scr_testclientsremove" );
    setdvar( "scr_testclientsremove", 0 );
    host = gethostplayer();
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        if ( isdefined( players[i].pers["isBot"] ) && players[i].pers["isBot"] == 1 )
        {
            if ( removetype == 2 && host.team != players[i].team )
                continue;

            if ( removetype == 3 && host.team == players[i].team )
                continue;

            kick( players[i] getentitynumber() );
        }
    }

    thread removetestclients();
#/
}

testclient( team )
{
/#
    self endon( "disconnect" );

    while ( !isdefined( self.pers["team"] ) )
        wait 0.05;

    if ( level.teambased )
    {
        self notify( "menuresponse", game["menu_team"], team );
        wait 0.5;
    }

    while ( true )
    {
        classes = maps\mp\bots\_bot::bot_build_classes();
        self notify( "menuresponse", "changeclass", random( classes ) );

        self waittill( "spawned_player" );

        wait 0.1;
    }
#/
}

showonespawnpoint( spawn_point, color, notification, height, print )
{
/#
    if ( !isdefined( height ) || height <= 0 )
        height = get_player_height();

    if ( !isdefined( print ) )
        print = spawn_point.classname;

    center = spawn_point.origin;
    forward = anglestoforward( spawn_point.angles );
    right = anglestoright( spawn_point.angles );
    forward = vectorscale( forward, 16 );
    right = vectorscale( right, 16 );
    a = center + forward - right;
    b = center + forward + right;
    c = center - forward + right;
    d = center - forward - right;
    thread lineuntilnotified( a, b, color, 0, notification );
    thread lineuntilnotified( b, c, color, 0, notification );
    thread lineuntilnotified( c, d, color, 0, notification );
    thread lineuntilnotified( d, a, color, 0, notification );
    thread lineuntilnotified( a, a + ( 0, 0, height ), color, 0, notification );
    thread lineuntilnotified( b, b + ( 0, 0, height ), color, 0, notification );
    thread lineuntilnotified( c, c + ( 0, 0, height ), color, 0, notification );
    thread lineuntilnotified( d, d + ( 0, 0, height ), color, 0, notification );
    a += ( 0, 0, height );
    b += ( 0, 0, height );
    c += ( 0, 0, height );
    d += ( 0, 0, height );
    thread lineuntilnotified( a, b, color, 0, notification );
    thread lineuntilnotified( b, c, color, 0, notification );
    thread lineuntilnotified( c, d, color, 0, notification );
    thread lineuntilnotified( d, a, color, 0, notification );
    center += ( 0, 0, height / 2 );
    arrow_forward = anglestoforward( spawn_point.angles );
    arrowhead_forward = anglestoforward( spawn_point.angles );
    arrowhead_right = anglestoright( spawn_point.angles );
    arrow_forward = vectorscale( arrow_forward, 32 );
    arrowhead_forward = vectorscale( arrowhead_forward, 24 );
    arrowhead_right = vectorscale( arrowhead_right, 8 );
    a = center + arrow_forward;
    b = center + arrowhead_forward - arrowhead_right;
    c = center + arrowhead_forward + arrowhead_right;
    thread lineuntilnotified( center, a, color, 0, notification );
    thread lineuntilnotified( a, b, color, 0, notification );
    thread lineuntilnotified( a, c, color, 0, notification );
    thread print3duntilnotified( spawn_point.origin + ( 0, 0, height ), print, color, 1, 1, notification );
    return;
#/
}

showspawnpoints()
{
/#
    if ( isdefined( level.spawnpoints ) )
    {
        color = ( 1, 1, 1 );

        for ( spawn_point_index = 0; spawn_point_index < level.spawnpoints.size; spawn_point_index++ )
            showonespawnpoint( level.spawnpoints[spawn_point_index], color, "hide_spawnpoints" );
    }

    for ( i = 0; i < level.dem_spawns.size; i++ )
    {
        color = ( 0, 1, 0 );
        showonespawnpoint( level.dem_spawns[i], color, "hide_spawnpoints" );
    }

    return;
#/
}

hidespawnpoints()
{
/#
    level notify( "hide_spawnpoints" );
    return;
#/
}

showstartspawnpoints()
{
/#
    if ( !level.teambased )
        return;

    if ( !isdefined( level.spawn_start ) )
        return;

    team_colors = [];
    team_colors["axis"] = ( 1, 0, 1 );
    team_colors["allies"] = ( 0, 1, 1 );
    team_colors["team3"] = ( 1, 1, 0 );
    team_colors["team4"] = ( 0, 1, 0 );
    team_colors["team5"] = ( 0, 0, 1 );
    team_colors["team6"] = ( 1, 0.7, 0 );
    team_colors["team7"] = ( 0.25, 0.25, 1.0 );
    team_colors["team8"] = ( 0.88, 0, 1 );

    foreach ( team in level.teams )
    {
        color = team_colors[team];

        foreach ( spawnpoint in level.spawn_start[team] )
            showonespawnpoint( spawnpoint, color, "hide_startspawnpoints" );
    }

    return;
#/
}

hidestartspawnpoints()
{
/#
    level notify( "hide_startspawnpoints" );
    return;
#/
}

print3duntilnotified( origin, text, color, alpha, scale, notification )
{
/#
    level endon( notification );

    for (;;)
    {
        print3d( origin, text, color, alpha, scale );
        wait 0.05;
    }
#/
}

lineuntilnotified( start, end, color, depthtest, notification )
{
/#
    level endon( notification );

    for (;;)
    {
        line( start, end, color, depthtest );
        wait 0.05;
    }
#/
}

engagement_distance_debug_toggle()
{
/#
    level endon( "kill_engage_dist_debug_toggle_watcher" );

    if ( !isdefined( getdvarint( "debug_engage_dists" ) ) )
        setdvar( "debug_engage_dists", "0" );

    laststate = getdvarint( "debug_engage_dists" );

    while ( true )
    {
        currentstate = getdvarint( "debug_engage_dists" );

        if ( dvar_turned_on( currentstate ) && !dvar_turned_on( laststate ) )
        {
            weapon_engage_dists_init();
            thread debug_realtime_engage_dist();
            laststate = currentstate;
        }
        else if ( !dvar_turned_on( currentstate ) && dvar_turned_on( laststate ) )
        {
            level notify( "kill_all_engage_dist_debug" );
            laststate = currentstate;
        }

        wait 0.3;
    }
#/
}

dvar_turned_on( val )
{
/#
    if ( val <= 0 )
        return false;
    else
        return true;
#/
}

engagement_distance_debug_init()
{
/#
    level.debug_xpos = -50;
    level.debug_ypos = 250;
    level.debug_yinc = 18;
    level.debug_fontscale = 1.5;
    level.white = ( 1, 1, 1 );
    level.green = ( 0, 1, 0 );
    level.yellow = ( 1, 1, 0 );
    level.red = ( 1, 0, 0 );
    level.realtimeengagedist = newhudelem();
    level.realtimeengagedist.alignx = "left";
    level.realtimeengagedist.fontscale = level.debug_fontscale;
    level.realtimeengagedist.x = level.debug_xpos;
    level.realtimeengagedist.y = level.debug_ypos;
    level.realtimeengagedist.color = level.white;
    level.realtimeengagedist settext( "Current Engagement Distance: " );
    xpos = level.debug_xpos + 207;
    level.realtimeengagedist_value = newhudelem();
    level.realtimeengagedist_value.alignx = "left";
    level.realtimeengagedist_value.fontscale = level.debug_fontscale;
    level.realtimeengagedist_value.x = xpos;
    level.realtimeengagedist_value.y = level.debug_ypos;
    level.realtimeengagedist_value.color = level.white;
    level.realtimeengagedist_value setvalue( 0 );
    xpos += 37;
    level.realtimeengagedist_middle = newhudelem();
    level.realtimeengagedist_middle.alignx = "left";
    level.realtimeengagedist_middle.fontscale = level.debug_fontscale;
    level.realtimeengagedist_middle.x = xpos;
    level.realtimeengagedist_middle.y = level.debug_ypos;
    level.realtimeengagedist_middle.color = level.white;
    level.realtimeengagedist_middle settext( " units, SHORT/LONG by " );
    xpos += 105;
    level.realtimeengagedist_offvalue = newhudelem();
    level.realtimeengagedist_offvalue.alignx = "left";
    level.realtimeengagedist_offvalue.fontscale = level.debug_fontscale;
    level.realtimeengagedist_offvalue.x = xpos;
    level.realtimeengagedist_offvalue.y = level.debug_ypos;
    level.realtimeengagedist_offvalue.color = level.white;
    level.realtimeengagedist_offvalue setvalue( 0 );
    hudobjarray = [];
    hudobjarray[0] = level.realtimeengagedist;
    hudobjarray[1] = level.realtimeengagedist_value;
    hudobjarray[2] = level.realtimeengagedist_middle;
    hudobjarray[3] = level.realtimeengagedist_offvalue;
    return hudobjarray;
#/
}

engage_dist_debug_hud_destroy( hudarray, killnotify )
{
/#
    level waittill( killnotify );

    for ( i = 0; i < hudarray.size; i++ )
        hudarray[i] destroy();
#/
}

weapon_engage_dists_init()
{
/#
    level.engagedists = [];
    genericpistol = spawnstruct();
    genericpistol.engagedistmin = 125;
    genericpistol.engagedistoptimal = 225;
    genericpistol.engagedistmulligan = 50;
    genericpistol.engagedistmax = 400;
    shotty = spawnstruct();
    shotty.engagedistmin = 50;
    shotty.engagedistoptimal = 200;
    shotty.engagedistmulligan = 75;
    shotty.engagedistmax = 350;
    genericsmg = spawnstruct();
    genericsmg.engagedistmin = 100;
    genericsmg.engagedistoptimal = 275;
    genericsmg.engagedistmulligan = 100;
    genericsmg.engagedistmax = 500;
    genericlmg = spawnstruct();
    genericlmg.engagedistmin = 325;
    genericlmg.engagedistoptimal = 550;
    genericlmg.engagedistmulligan = 150;
    genericlmg.engagedistmax = 850;
    genericriflesa = spawnstruct();
    genericriflesa.engagedistmin = 325;
    genericriflesa.engagedistoptimal = 550;
    genericriflesa.engagedistmulligan = 150;
    genericriflesa.engagedistmax = 850;
    genericriflebolt = spawnstruct();
    genericriflebolt.engagedistmin = 350;
    genericriflebolt.engagedistoptimal = 600;
    genericriflebolt.engagedistmulligan = 150;
    genericriflebolt.engagedistmax = 900;
    generichmg = spawnstruct();
    generichmg.engagedistmin = 390;
    generichmg.engagedistoptimal = 600;
    generichmg.engagedistmulligan = 100;
    generichmg.engagedistmax = 900;
    genericsniper = spawnstruct();
    genericsniper.engagedistmin = 950;
    genericsniper.engagedistoptimal = 1700;
    genericsniper.engagedistmulligan = 300;
    genericsniper.engagedistmax = 3000;
    engage_dists_add( "colt_mp", genericpistol );
    engage_dists_add( "nambu_mp", genericpistol );
    engage_dists_add( "tokarev_mp", genericpistol );
    engage_dists_add( "walther_mp", genericpistol );
    engage_dists_add( "thompson_mp", genericsmg );
    engage_dists_add( "type100_smg_mp", genericsmg );
    engage_dists_add( "ppsh_mp", genericsmg );
    engage_dists_add( "mp40_mp", genericsmg );
    engage_dists_add( "stg44_mp", genericsmg );
    engage_dists_add( "sten_mp", genericsmg );
    engage_dists_add( "sten_silenced_mp", genericsmg );
    engage_dists_add( "shotgun_mp", shotty );
    engage_dists_add( "bar_mp", genericlmg );
    engage_dists_add( "bar_bipod_mp", genericlmg );
    engage_dists_add( "type99_lmg_mp", genericlmg );
    engage_dists_add( "type99_lmg_bipod_mp", genericlmg );
    engage_dists_add( "dp28_mp", genericlmg );
    engage_dists_add( "dp28_bipod_mp", genericlmg );
    engage_dists_add( "fg42_mp", genericlmg );
    engage_dists_add( "fg42_bipod_mp", genericlmg );
    engage_dists_add( "bren_mp", genericlmg );
    engage_dists_add( "bren_bipod_mp", genericlmg );
    engage_dists_add( "m1garand_mp", genericriflesa );
    engage_dists_add( "m1garand_bayonet_mp", genericriflesa );
    engage_dists_add( "m1carbine_mp", genericriflesa );
    engage_dists_add( "m1carbine_bayonet_mp", genericriflesa );
    engage_dists_add( "svt40_mp", genericriflesa );
    engage_dists_add( "gewehr43_mp", genericriflesa );
    engage_dists_add( "springfield_mp", genericriflebolt );
    engage_dists_add( "springfield_bayonet_mp", genericriflebolt );
    engage_dists_add( "type99_rifle_mp", genericriflebolt );
    engage_dists_add( "type99_rifle_bayonet_mp", genericriflebolt );
    engage_dists_add( "mosin_rifle_mp", genericriflebolt );
    engage_dists_add( "mosin_rifle_bayonet_mp", genericriflebolt );
    engage_dists_add( "kar98k_mp", genericriflebolt );
    engage_dists_add( "kar98k_bayonet_mp", genericriflebolt );
    engage_dists_add( "lee_enfield_mp", genericriflebolt );
    engage_dists_add( "lee_enfield_bayonet_mp", genericriflebolt );
    engage_dists_add( "30cal_mp", generichmg );
    engage_dists_add( "30cal_bipod_mp", generichmg );
    engage_dists_add( "mg42_mp", generichmg );
    engage_dists_add( "mg42_bipod_mp", generichmg );
    engage_dists_add( "springfield_scoped_mp", genericsniper );
    engage_dists_add( "type99_rifle_scoped_mp", genericsniper );
    engage_dists_add( "mosin_rifle_scoped_mp", genericsniper );
    engage_dists_add( "kar98k_scoped_mp", genericsniper );
    engage_dists_add( "fg42_scoped_mp", genericsniper );
    engage_dists_add( "lee_enfield_scoped_mp", genericsniper );
    level thread engage_dists_watcher();
#/
}

engage_dists_add( weapontypestr, values )
{
/#
    level.engagedists[weapontypestr] = values;
#/
}

get_engage_dists( weapontypestr )
{
/#
    if ( isdefined( level.engagedists[weapontypestr] ) )
        return level.engagedists[weapontypestr];
    else
        return undefined;
#/
}

engage_dists_watcher()
{
/#
    level endon( "kill_all_engage_dist_debug" );
    level endon( "kill_engage_dists_watcher" );

    while ( true )
    {
        player = gethostplayer();
        playerweapon = player getcurrentweapon();

        if ( !isdefined( player.lastweapon ) )
            player.lastweapon = playerweapon;
        else if ( player.lastweapon == playerweapon )
        {
            wait 0.05;
            continue;
        }

        values = get_engage_dists( playerweapon );

        if ( isdefined( values ) )
            level.weaponengagedistvalues = values;
        else
            level.weaponengagedistvalues = undefined;

        player.lastweapon = playerweapon;
        wait 0.05;
    }
#/
}

debug_realtime_engage_dist()
{
/#
    level endon( "kill_all_engage_dist_debug" );
    level endon( "kill_realtime_engagement_distance_debug" );
    hudobjarray = engagement_distance_debug_init();
    level thread engage_dist_debug_hud_destroy( hudobjarray, "kill_all_engage_dist_debug" );
    level.debugrtengagedistcolor = level.green;
    player = gethostplayer();

    while ( true )
    {
        lasttracepos = ( 0, 0, 0 );
        direction = player getplayerangles();
        direction_vec = anglestoforward( direction );
        eye = player geteye();
        eye = ( eye[0], eye[1], eye[2] + 20 );
        trace = bullettrace( eye, eye + vectorscale( direction_vec, 10000 ), 1, player );
        tracepoint = trace["position"];
        tracenormal = trace["normal"];
        tracedist = int( distance( eye, tracepoint ) );

        if ( tracepoint != lasttracepos )
        {
            lasttracepos = tracepoint;

            if ( !isdefined( level.weaponengagedistvalues ) )
            {
                hudobj_changecolor( hudobjarray, level.white );
                hudobjarray engagedist_hud_changetext( "nodata", tracedist );
            }
            else
            {
                engagedistmin = level.weaponengagedistvalues.engagedistmin;
                engagedistoptimal = level.weaponengagedistvalues.engagedistoptimal;
                engagedistmulligan = level.weaponengagedistvalues.engagedistmulligan;
                engagedistmax = level.weaponengagedistvalues.engagedistmax;

                if ( tracedist >= engagedistmin && tracedist <= engagedistmax )
                {
                    if ( tracedist >= engagedistoptimal - engagedistmulligan && tracedist <= engagedistoptimal + engagedistmulligan )
                    {
                        hudobjarray engagedist_hud_changetext( "optimal", tracedist );
                        hudobj_changecolor( hudobjarray, level.green );
                    }
                    else
                    {
                        hudobjarray engagedist_hud_changetext( "ok", tracedist );
                        hudobj_changecolor( hudobjarray, level.yellow );
                    }
                }
                else if ( tracedist < engagedistmin )
                {
                    hudobj_changecolor( hudobjarray, level.red );
                    hudobjarray engagedist_hud_changetext( "short", tracedist );
                }
                else if ( tracedist > engagedistmax )
                {
                    hudobj_changecolor( hudobjarray, level.red );
                    hudobjarray engagedist_hud_changetext( "long", tracedist );
                }
            }
        }

        thread plot_circle_fortime( 1, 5, 0.05, level.debugrtengagedistcolor, tracepoint, tracenormal );
        thread plot_circle_fortime( 1, 1, 0.05, level.debugrtengagedistcolor, tracepoint, tracenormal );
        wait 0.05;
    }
#/
}

hudobj_changecolor( hudobjarray, newcolor )
{
/#
    for ( i = 0; i < hudobjarray.size; i++ )
    {
        hudobj = hudobjarray[i];

        if ( hudobj.color != newcolor )
        {
            hudobj.color = newcolor;
            level.debugrtengagedistcolor = newcolor;
        }
    }
#/
}

engagedist_hud_changetext( engagedisttype, units )
{
/#
    if ( !isdefined( level.lastdisttype ) )
        level.lastdisttype = "none";

    if ( engagedisttype == "optimal" )
    {
        self[1] setvalue( units );
        self[2] settext( "units: OPTIMAL!" );
        self[3].alpha = 0;
    }
    else if ( engagedisttype == "ok" )
    {
        self[1] setvalue( units );
        self[2] settext( "units: OK!" );
        self[3].alpha = 0;
    }
    else if ( engagedisttype == "short" )
    {
        amountunder = level.weaponengagedistvalues.engagedistmin - units;
        self[1] setvalue( units );
        self[3] setvalue( amountunder );
        self[3].alpha = 1;

        if ( level.lastdisttype != engagedisttype )
            self[2] settext( "units: SHORT by " );
    }
    else if ( engagedisttype == "long" )
    {
        amountover = units - level.weaponengagedistvalues.engagedistmax;
        self[1] setvalue( units );
        self[3] setvalue( amountover );
        self[3].alpha = 1;

        if ( level.lastdisttype != engagedisttype )
            self[2] settext( "units: LONG by " );
    }
    else if ( engagedisttype == "nodata" )
    {
        self[1] setvalue( units );
        self[2] settext( " units: (NO CURRENT WEAPON VALUES)" );
        self[3].alpha = 0;
    }

    level.lastdisttype = engagedisttype;
#/
}

plot_circle_fortime( radius1, radius2, time, color, origin, normal )
{
/#
    if ( !isdefined( color ) )
        color = ( 0, 1, 0 );

    hangtime = 0.05;
    circleres = 6;
    hemires = circleres / 2;
    circleinc = 360 / circleres;
    circleres++;
    plotpoints = [];
    rad = 0.0;
    timer = gettime() + time * 1000;
    radius = radius1;

    while ( gettime() < timer )
    {
        radius = radius2;
        angletoplayer = vectortoangles( normal );

        for ( i = 0; i < circleres; i++ )
        {
            plotpoints[plotpoints.size] = origin + vectorscale( anglestoforward( angletoplayer + ( rad, 90, 0 ) ), radius );
            rad += circleinc;
        }

        maps\mp\_utility::plot_points( plotpoints, color[0], color[1], color[2], hangtime );
        plotpoints = [];
        wait( hangtime );
    }
#/
}

larry_thread()
{
/#
    setdvar( "bot_AllowMovement", "0" );
    setdvar( "bot_PressAttackBtn", "0" );
    setdvar( "bot_PressMeleeBtn", "0" );
    level.larry = spawnstruct();
    player = gethostplayer();
    player thread larry_init( level.larry );

    level waittill( "kill_larry" );

    larry_hud_destroy( level.larry );

    if ( isdefined( level.larry.model ) )
        level.larry.model delete();

    if ( isdefined( level.larry.ai ) )
    {
        for ( i = 0; i < level.larry.ai.size; i++ )
            kick( level.larry.ai[i] getentitynumber() );
    }

    level.larry = undefined;
#/
}

larry_init( larry )
{
/#
    level endon( "kill_larry" );
    larry_hud_init( larry );
    larry.model = spawn( "script_model", ( 0, 0, 0 ) );
    larry.model setmodel( "defaultactor" );
    larry.ai = [];
    wait 0.1;

    for (;;)
    {
        wait 0.05;

        if ( larry.ai.size > 0 )
        {
            larry.model hide();
            continue;
        }

        direction = self getplayerangles();
        direction_vec = anglestoforward( direction );
        eye = self geteye();
        trace = bullettrace( eye, eye + vectorscale( direction_vec, 8000 ), 0, undefined );
        dist = distance( eye, trace["position"] );
        position = eye + vectorscale( direction_vec, dist - 64 );
        larry.model.origin = position;
        larry.model.angles = self.angles + vectorscale( ( 0, 1, 0 ), 180.0 );

        if ( self usebuttonpressed() )
        {
            self larry_ai( larry );

            while ( self usebuttonpressed() )
                wait 0.05;
        }
    }
#/
}

larry_ai( larry )
{
/#
    larry.ai[larry.ai.size] = addtestclient();
    i = larry.ai.size - 1;
    larry.ai[i].pers["isBot"] = 1;
    larry.ai[i] thread testclient( "autoassign" );
    larry.ai[i] thread larry_ai_thread( larry, larry.model.origin, larry.model.angles );
    larry.ai[i] thread larry_ai_damage( larry );
    larry.ai[i] thread larry_ai_health( larry );
#/
}

larry_ai_thread( larry, origin, angles )
{
/#
    level endon( "kill_larry" );

    for (;;)
    {
        self waittill( "spawned_player" );

        larry.menu[larry.menu_health] setvalue( self.health );
        larry.menu[larry.menu_damage] settext( "" );
        larry.menu[larry.menu_range] settext( "" );
        larry.menu[larry.menu_hitloc] settext( "" );
        larry.menu[larry.menu_weapon] settext( "" );
        larry.menu[larry.menu_perks] settext( "" );
        self setorigin( origin );
        self setplayerangles( angles );
        self clearperks();
    }
#/
}

larry_ai_damage( larry )
{
/#
    level endon( "kill_larry" );

    for (;;)
    {
        self waittill( "damage", damage, attacker, dir, point );

        if ( !isdefined( attacker ) )
            continue;

        player = gethostplayer();

        if ( !isdefined( player ) )
            continue;

        if ( attacker != player )
            continue;

        eye = player geteye();
        range = int( distance( eye, point ) );
        larry.menu[larry.menu_health] setvalue( self.health );
        larry.menu[larry.menu_damage] setvalue( damage );
        larry.menu[larry.menu_range] setvalue( range );

        if ( isdefined( self.cac_debug_location ) )
            larry.menu[larry.menu_hitloc] settext( self.cac_debug_location );
        else
            larry.menu[larry.menu_hitloc] settext( "<unknown>" );

        if ( isdefined( self.cac_debug_weapon ) )
        {
            larry.menu[larry.menu_weapon] settext( self.cac_debug_weapon );
            continue;
        }

        larry.menu[larry.menu_weapon] settext( "<unknown>" );
    }
#/
}

larry_ai_health( larry )
{
/#
    level endon( "kill_larry" );

    for (;;)
    {
        wait 0.05;
        larry.menu[larry.menu_health] setvalue( self.health );
    }
#/
}

larry_hud_init( larry )
{
/#
    x = -45;
    y = 275;
    menu_name = "larry_menu";
    larry.hud = new_hud( menu_name, undefined, x, y, 1 );
    larry.hud setshader( "white", 135, 65 );
    larry.hud.alignx = "left";
    larry.hud.aligny = "top";
    larry.hud.sort = 10;
    larry.hud.alpha = 0.6;
    larry.hud.color = vectorscale( ( 0, 0, 1 ), 0.5 );
    larry.menu[0] = new_hud( menu_name, "Larry Health:", x + 5, y + 10, 1 );
    larry.menu[1] = new_hud( menu_name, "Damage:", x + 5, y + 20, 1 );
    larry.menu[2] = new_hud( menu_name, "Range:", x + 5, y + 30, 1 );
    larry.menu[3] = new_hud( menu_name, "Hit Location:", x + 5, y + 40, 1 );
    larry.menu[4] = new_hud( menu_name, "Weapon:", x + 5, y + 50, 1 );
    larry.cleartextmarker = newdebughudelem();
    larry.cleartextmarker.alpha = 0;
    larry.cleartextmarker settext( "marker" );
    larry.menu_health = larry.menu.size;
    larry.menu_damage = larry.menu.size + 1;
    larry.menu_range = larry.menu.size + 2;
    larry.menu_hitloc = larry.menu.size + 3;
    larry.menu_weapon = larry.menu.size + 4;
    larry.menu_perks = larry.menu.size + 5;
    x_offset = 70;
    larry.menu[larry.menu_health] = new_hud( menu_name, "", x + x_offset, y + 10, 1 );
    larry.menu[larry.menu_damage] = new_hud( menu_name, "", x + x_offset, y + 20, 1 );
    larry.menu[larry.menu_range] = new_hud( menu_name, "", x + x_offset, y + 30, 1 );
    larry.menu[larry.menu_hitloc] = new_hud( menu_name, "", x + x_offset, y + 40, 1 );
    larry.menu[larry.menu_weapon] = new_hud( menu_name, "", x + x_offset, y + 50, 1 );
    larry.menu[larry.menu_perks] = new_hud( menu_name, "", x + x_offset, y + 60, 1 );
#/
}

larry_hud_destroy( larry )
{
/#
    if ( isdefined( larry.hud ) )
    {
        larry.hud destroy();

        for ( i = 0; i < larry.menu.size; i++ )
            larry.menu[i] destroy();

        larry.cleartextmarker destroy();
    }
#/
}

new_hud( hud_name, msg, x, y, scale )
{
/#
    if ( !isdefined( level.hud_array ) )
        level.hud_array = [];

    if ( !isdefined( level.hud_array[hud_name] ) )
        level.hud_array[hud_name] = [];

    hud = set_hudelem( msg, x, y, scale );
    level.hud_array[hud_name][level.hud_array[hud_name].size] = hud;
    return hud;
#/
}

set_hudelem( text, x, y, scale, alpha, sort, debug_hudelem )
{
/#
    if ( !isdefined( alpha ) )
        alpha = 1;

    if ( !isdefined( scale ) )
        scale = 1;

    if ( !isdefined( sort ) )
        sort = 20;

    hud = newdebughudelem();
    hud.debug_hudelem = 1;
    hud.location = 0;
    hud.alignx = "left";
    hud.aligny = "middle";
    hud.foreground = 1;
    hud.fontscale = scale;
    hud.sort = sort;
    hud.alpha = alpha;
    hud.x = x;
    hud.y = y;
    hud.og_scale = scale;

    if ( isdefined( text ) )
        hud settext( text );

    return hud;
#/
}

watch_botsdvars()
{
/#
    hasplayerweaponprev = getdvarint( "scr_botsHasPlayerWeapon" );
    grenadesonlyprev = getdvarint( "scr_botsGrenadesOnly" );
    secondarygrenadesonlyprev = getdvarint( "scr_botsSpecialGrenadesOnly" );

    while ( true )
    {
        if ( hasplayerweaponprev != getdvarint( "scr_botsHasPlayerWeapon" ) )
        {
            hasplayerweaponprev = getdvarint( "scr_botsHasPlayerWeapon" );

            if ( hasplayerweaponprev )
                iprintlnbold( "LARRY has player weapon: ON" );
            else
                iprintlnbold( "LARRY has player weapon: OFF" );
        }

        if ( grenadesonlyprev != getdvarint( "scr_botsGrenadesOnly" ) )
        {
            grenadesonlyprev = getdvarint( "scr_botsGrenadesOnly" );

            if ( grenadesonlyprev )
                iprintlnbold( "LARRY using grenades only: ON" );
            else
                iprintlnbold( "LARRY using grenades only: OFF" );
        }

        if ( secondarygrenadesonlyprev != getdvarint( "scr_botsSpecialGrenadesOnly" ) )
        {
            secondarygrenadesonlyprev = getdvarint( "scr_botsSpecialGrenadesOnly" );

            if ( secondarygrenadesonlyprev )
                iprintlnbold( "LARRY using secondary grenades only: ON" );
            else
                iprintlnbold( "LARRY using secondary grenades only: OFF" );
        }

        wait 1.0;
    }
#/
}

getattachmentchangemodifierbutton()
{
/#
    return "BUTTON_X";
#/
}

watchattachmentchange()
{
/#
    self endon( "disconnect" );
    clientnum = self getentitynumber();

    if ( clientnum != 0 )
        return;

    dpad_left = 0;
    dpad_right = 0;
    dpad_up = 0;
    dpad_down = 0;
    lstick_down = 0;
    dpad_modifier_button = getattachmentchangemodifierbutton();

    for (;;)
    {
        if ( self buttonpressed( dpad_modifier_button ) )
        {
            if ( !dpad_left && self buttonpressed( "DPAD_LEFT" ) )
            {
                self giveweaponnextattachment( "muzzle" );
                dpad_left = 1;
                self thread print_weapon_name();
            }

            if ( !dpad_right && self buttonpressed( "DPAD_RIGHT" ) )
            {
                self giveweaponnextattachment( "trigger" );
                dpad_right = 1;
                self thread print_weapon_name();
            }

            if ( !dpad_up && self buttonpressed( "DPAD_UP" ) )
            {
                self giveweaponnextattachment( "top" );
                dpad_up = 1;
                self thread print_weapon_name();
            }

            if ( !dpad_down && self buttonpressed( "DPAD_DOWN" ) )
            {
                self giveweaponnextattachment( "bottom" );
                dpad_down = 1;
                self thread print_weapon_name();
            }

            if ( !lstick_down && self buttonpressed( "BUTTON_LSTICK" ) )
            {
                self giveweaponnextattachment( "gunperk" );
                lstick_down = 1;
                self thread print_weapon_name();
            }
        }

        if ( !self buttonpressed( "DPAD_LEFT" ) )
            dpad_left = 0;

        if ( !self buttonpressed( "DPAD_RIGHT" ) )
            dpad_right = 0;

        if ( !self buttonpressed( "DPAD_UP" ) )
            dpad_up = 0;

        if ( !self buttonpressed( "DPAD_DOWN" ) )
            dpad_down = 0;

        if ( !self buttonpressed( "BUTTON_LSTICK" ) )
            lstick_down = 0;

        wait 0.05;
    }
#/
}

print_weapon_name()
{
/#
    self notify( "print_weapon_name" );
    self endon( "print_weapon_name" );
    wait 0.2;

    if ( self isswitchingweapons() )
    {
        self waittill( "weapon_change_complete", weapon_name );

        fail_safe = 0;

        while ( weapon_name == "none" )
        {
            self waittill( "weapon_change_complete", weapon_name );

            wait 0.05;
            fail_safe++;

            if ( fail_safe > 120 )
                break;
        }
    }
    else
        weapon_name = self getcurrentweapon();

    printweaponname = getdvarintdefault( "scr_print_weapon_name", 1 );

    if ( printweaponname )
        iprintlnbold( weapon_name );
#/
}

set_equipment_list()
{
/#
    if ( isdefined( level.dev_equipment ) )
        return;

    level.dev_equipment = [];
    level.dev_equipment[1] = "acoustic_sensor_mp";
    level.dev_equipment[2] = "camera_spike_mp";
    level.dev_equipment[3] = "claymore_mp";
    level.dev_equipment[4] = "satchel_charge_mp";
    level.dev_equipment[5] = "scrambler_mp";
    level.dev_equipment[6] = "tactical_insertion_mp";
    level.dev_equipment[7] = "bouncingbetty_mp";
    level.dev_equipment[8] = "trophy_system_mp";
    level.dev_equipment[9] = "pda_hack_mp";
#/
}

set_grenade_list()
{
/#
    if ( isdefined( level.dev_grenade ) )
        return;

    level.dev_grenade = [];
    level.dev_grenade[1] = "frag_grenade_mp";
    level.dev_grenade[2] = "sticky_grenade_mp";
    level.dev_grenade[3] = "hatchet_mp";
    level.dev_grenade[4] = "willy_pete_mp";
    level.dev_grenade[5] = "proximity_grenade_mp";
    level.dev_grenade[6] = "flash_grenade_mp";
    level.dev_grenade[7] = "concussion_grenade_mp";
    level.dev_grenade[8] = "nightingale_mp";
    level.dev_grenade[9] = "emp_grenade_mp";
    level.dev_grenade[10] = "sensor_grenade_mp";
#/
}

take_all_grenades_and_equipment( player )
{
/#
    for ( i = 0; i < level.dev_equipment.size; i++ )
        player takeweapon( level.dev_equipment[i + 1] );

    for ( i = 0; i < level.dev_grenade.size; i++ )
        player takeweapon( level.dev_grenade[i + 1] );
#/
}

equipment_dev_gui()
{
/#
    set_equipment_list();
    set_grenade_list();
    setdvar( "scr_give_equipment", "" );

    while ( true )
    {
        wait 0.5;
        devgui_int = getdvarint( "scr_give_equipment" );

        if ( devgui_int != 0 )
        {
            for ( i = 0; i < level.players.size; i++ )
            {
                take_all_grenades_and_equipment( level.players[i] );
                level.players[i] giveweapon( level.dev_equipment[devgui_int] );
            }

            setdvar( "scr_give_equipment", "0" );
        }
    }
#/
}

grenade_dev_gui()
{
/#
    set_equipment_list();
    set_grenade_list();
    setdvar( "scr_give_grenade", "" );

    while ( true )
    {
        wait 0.5;
        devgui_int = getdvarint( "scr_give_grenade" );

        if ( devgui_int != 0 )
        {
            for ( i = 0; i < level.players.size; i++ )
            {
                take_all_grenades_and_equipment( level.players[i] );
                level.players[i] giveweapon( level.dev_grenade[devgui_int] );
            }

            setdvar( "scr_give_grenade", "0" );
        }
    }
#/
}

force_grenade_throw( weapon )
{
/#
    setdvar( "bot_AllowMovement", "0" );
    setdvar( "bot_PressAttackBtn", "0" );
    setdvar( "bot_PressMeleeBtn", "0" );
    setdvar( "scr_botsAllowKillstreaks", "0" );
    host = gethostplayer();

    if ( !isdefined( host.team ) )
    {
        iprintln( "Unable to determine host player team" );
        return;
    }

    bot = getormakebot( getotherteam( host.team ) );

    if ( !isdefined( bot ) )
    {
        iprintln( "Could not add test client" );
        return;
    }

    angles = host getplayerangles();
    angles = ( 0, angles[1], 0 );
    dir = anglestoforward( angles );
    dir = vectornormalize( dir );
    origin = host geteye() + vectorscale( dir, 256 );
    velocity = vectorscale( dir, -1024 );
    grenade = bot magicgrenade( weapon, origin, velocity );
    grenade setteam( bot.team );
    grenade setowner( bot );
#/
}

bot_dpad_think()
{
/#
    level notify( "bot_dpad_stop" );
    level endon( "bot_dpad_stop" );
    level endon( "bot_dpad_terminate" );

    if ( !isdefined( level.bot_index ) )
        level.bot_index = 0;

    host = gethostplayer();

    while ( !isdefined( host ) )
    {
        wait 0.5;
        host = gethostplayer();
        level.bot_index = 0;
    }

    dpad_left = 0;
    dpad_right = 0;

    for (;;)
    {
        wait 0.05;
        host setactionslot( 3, "" );
        host setactionslot( 4, "" );
        players = get_players();
        max = players.size;

        if ( !dpad_left && host buttonpressed( "DPAD_LEFT" ) )
        {
            level.bot_index--;

            if ( level.bot_index < 0 )
                level.bot_index = max - 1;

            if ( !players[level.bot_index] is_bot() )
                continue;

            dpad_left = 1;
        }
        else if ( !host buttonpressed( "DPAD_LEFT" ) )
            dpad_left = 0;

        if ( !dpad_right && host buttonpressed( "DPAD_RIGHT" ) )
        {
            level.bot_index++;

            if ( level.bot_index >= max )
                level.bot_index = 0;

            if ( !players[level.bot_index] is_bot() )
                continue;

            dpad_right = 1;
        }
        else if ( !host buttonpressed( "DPAD_RIGHT" ) )
            dpad_right = 0;

        level notify( "bot_index_changed" );
    }
#/
}

bot_overlay_think()
{
/#
    level endon( "bot_overlay_stop" );
    level thread bot_dpad_think();
    iprintln( "Previous Bot bound to D-Pad Left" );
    iprintln( "Next Bot bound to D-Pad Right" );

    for (;;)
    {
        if ( getdvarint( "bot_Debug" ) != level.bot_index )
            setdvar( "bot_Debug", level.bot_index );

        level waittill( "bot_index_changed" );
    }
#/
}

bot_threat_think()
{
/#
    level endon( "bot_threat_stop" );
    level thread bot_dpad_think();
    iprintln( "Previous Bot bound to D-Pad Left" );
    iprintln( "Next Bot bound to D-Pad Right" );

    for (;;)
    {
        if ( getdvarint( "bot_DebugThreat" ) != level.bot_index )
            setdvar( "bot_DebugThreat", level.bot_index );

        level waittill( "bot_index_changed" );
    }
#/
}

bot_path_think()
{
/#
    level endon( "bot_path_stop" );
    level thread bot_dpad_think();
    iprintln( "Previous Bot bound to D-Pad Left" );
    iprintln( "Next Bot bound to D-Pad Right" );

    for (;;)
    {
        if ( getdvarint( "bot_DebugPaths" ) != level.bot_index )
            setdvar( "bot_DebugPaths", level.bot_index );

        level waittill( "bot_index_changed" );
    }
#/
}

bot_overlay_stop()
{
/#
    level notify( "bot_overlay_stop" );
    setdvar( "bot_Debug", "-1" );
#/
}

bot_path_stop()
{
/#
    level notify( "bot_path_stop" );
    setdvar( "bot_DebugPaths", "-1" );
#/
}

bot_threat_stop()
{
/#
    level notify( "bot_threat_stop" );
    setdvar( "bot_DebugThreat", "-1" );
#/
}

devstraferunpathdebugdraw()
{
/#
    white = ( 1, 1, 1 );
    red = ( 1, 0, 0 );
    green = ( 0, 1, 0 );
    blue = ( 0, 0, 1 );
    violet = ( 0.4, 0, 0.6 );
    maxdrawtime = 10;
    drawtime = maxdrawtime;
    origintextoffset = vectorscale( ( 0, 0, -1 ), 50.0 );
    endonmsg = "devStopStrafeRunPathDebugDraw";

    while ( true )
    {
        if ( getdvarint( "scr_devStrafeRunPathDebugDraw" ) > 0 )
        {
            nodes = [];
            end = 0;
            node = getvehiclenode( "warthog_start", "targetname" );

            if ( !isdefined( node ) )
            {
                println( "No strafe run path found" );
                setdvar( "scr_devStrafeRunPathDebugDraw", "0" );
                continue;
            }

            while ( isdefined( node.target ) )
            {
                new_node = getvehiclenode( node.target, "targetname" );

                foreach ( n in nodes )
                {
                    if ( n == new_node )
                        end = 1;
                }

                textscale = 30;

                if ( drawtime == maxdrawtime )
                    node thread drawpathsegment( new_node, violet, violet, 1, textscale, origintextoffset, drawtime, endonmsg );

                if ( isdefined( node.script_noteworthy ) )
                {
                    textscale = 10;

                    switch ( node.script_noteworthy )
                    {
                        case "strafe_start":
                            textcolor = green;
                            textalpha = 1;
                            break;
                        case "strafe_stop":
                            textcolor = red;
                            textalpha = 1;
                            break;
                        case "strafe_leave":
                            textcolor = white;
                            textalpha = 1;
                            break;
                    }

                    switch ( node.script_noteworthy )
                    {
                        case "strafe_stop":
                        case "strafe_start":
                        case "strafe_leave":
                            sides = 10;
                            radius = 100;

                            if ( drawtime == maxdrawtime )
                                sphere( node.origin, radius, textcolor, textalpha, 1, sides, drawtime * 1000 );

                            node draworiginlines();
                            node drawnoteworthytext( textcolor, textalpha, textscale );
                            break;
                    }
                }

                if ( end )
                    break;

                nodes[nodes.size] = new_node;
                node = new_node;
            }

            drawtime -= 0.05;

            if ( drawtime < 0 )
                drawtime = maxdrawtime;

            wait 0.05;
        }
        else
            wait 1;
    }
#/
}

devhelipathdebugdraw()
{
/#
    white = ( 1, 1, 1 );
    red = ( 1, 0, 0 );
    green = ( 0, 1, 0 );
    blue = ( 0, 0, 1 );
    textcolor = white;
    textalpha = 1;
    textscale = 1;
    maxdrawtime = 10;
    drawtime = maxdrawtime;
    origintextoffset = vectorscale( ( 0, 0, -1 ), 50.0 );
    endonmsg = "devStopHeliPathsDebugDraw";

    while ( true )
    {
        if ( getdvarint( "scr_devHeliPathsDebugDraw" ) > 0 )
        {
            script_origins = getentarray( "script_origin", "classname" );

            foreach ( ent in script_origins )
            {
                if ( isdefined( ent.targetname ) )
                {
                    switch ( ent.targetname )
                    {
                        case "heli_start":
                            textcolor = blue;
                            textalpha = 1;
                            textscale = 3;
                            break;
                        case "heli_loop_start":
                            textcolor = green;
                            textalpha = 1;
                            textscale = 3;
                            break;
                        case "heli_attack_area":
                            textcolor = red;
                            textalpha = 1;
                            textscale = 3;
                            break;
                        case "heli_leave":
                            textcolor = white;
                            textalpha = 1;
                            textscale = 3;
                            break;
                    }

                    switch ( ent.targetname )
                    {
                        case "heli_start":
                        case "heli_loop_start":
                        case "heli_leave":
                        case "heli_attack_area":
                            if ( drawtime == maxdrawtime )
                                ent thread drawpath( textcolor, white, textalpha, textscale, origintextoffset, drawtime, endonmsg );

                            ent draworiginlines();
                            ent drawtargetnametext( textcolor, textalpha, textscale );
                            ent draworigintext( textcolor, textalpha, textscale, origintextoffset );
                            break;
                    }
                }
            }

            drawtime -= 0.05;

            if ( drawtime < 0 )
                drawtime = maxdrawtime;
        }

        if ( getdvarint( "scr_devHeliPathsDebugDraw" ) == 0 )
        {
            level notify( endonmsg );
            drawtime = maxdrawtime;
            wait 1;
        }

        wait 0.05;
    }
#/
}

draworiginlines()
{
/#
    red = ( 1, 0, 0 );
    green = ( 0, 1, 0 );
    blue = ( 0, 0, 1 );
    line( self.origin, self.origin + anglestoforward( self.angles ) * 10, red );
    line( self.origin, self.origin + anglestoright( self.angles ) * 10, green );
    line( self.origin, self.origin + anglestoup( self.angles ) * 10, blue );
#/
}

drawtargetnametext( textcolor, textalpha, textscale, textoffset )
{
/#
    if ( !isdefined( textoffset ) )
        textoffset = ( 0, 0, 0 );

    print3d( self.origin + textoffset, self.targetname, textcolor, textalpha, textscale );
#/
}

drawnoteworthytext( textcolor, textalpha, textscale, textoffset )
{
/#
    if ( !isdefined( textoffset ) )
        textoffset = ( 0, 0, 0 );

    print3d( self.origin + textoffset, self.script_noteworthy, textcolor, textalpha, textscale );
#/
}

draworigintext( textcolor, textalpha, textscale, textoffset )
{
/#
    if ( !isdefined( textoffset ) )
        textoffset = ( 0, 0, 0 );

    originstring = "(" + self.origin[0] + ", " + self.origin[1] + ", " + self.origin[2] + ")";
    print3d( self.origin + textoffset, originstring, textcolor, textalpha, textscale );
#/
}

drawspeedacceltext( textcolor, textalpha, textscale, textoffset )
{
/#
    if ( isdefined( self.script_airspeed ) )
        print3d( self.origin + ( 0, 0, textoffset[2] * 2 ), "script_airspeed:" + self.script_airspeed, textcolor, textalpha, textscale );

    if ( isdefined( self.script_accel ) )
        print3d( self.origin + ( 0, 0, textoffset[2] * 3 ), "script_accel:" + self.script_accel, textcolor, textalpha, textscale );
#/
}

drawpath( linecolor, textcolor, textalpha, textscale, textoffset, drawtime, endonmsg )
{
/#
    level endon( endonmsg );
    ent = self;
    entfirsttarget = ent.targetname;

    while ( isdefined( ent.target ) )
    {
        enttarget = getent( ent.target, "targetname" );
        ent thread drawpathsegment( enttarget, linecolor, textcolor, textalpha, textscale, textoffset, drawtime, endonmsg );

        if ( ent.targetname == "heli_loop_start" )
            entfirsttarget = ent.target;
        else if ( ent.target == entfirsttarget )
            break;

        ent = enttarget;
        wait 0.05;
    }
#/
}

drawpathsegment( enttarget, linecolor, textcolor, textalpha, textscale, textoffset, drawtime, endonmsg )
{
/#
    level endon( endonmsg );

    while ( drawtime > 0 )
    {
        if ( isdefined( self.targetname ) && self.targetname == "warthog_start" )
            print3d( self.origin + textoffset, self.targetname, textcolor, textalpha, textscale );

        line( self.origin, enttarget.origin, linecolor );
        self drawspeedacceltext( textcolor, textalpha, textscale, textoffset );
        drawtime -= 0.05;
        wait 0.05;
    }
#/
}

get_lookat_origin( player )
{
/#
    angles = player getplayerangles();
    forward = anglestoforward( angles );
    dir = vectorscale( forward, 8000 );
    eye = player geteye();
    trace = bullettrace( eye, eye + dir, 0, undefined );
    return trace["position"];
#/
}

draw_pathnode( node, color )
{
/#
    if ( !isdefined( color ) )
        color = ( 1, 0, 1 );

    box( node.origin, vectorscale( ( -1, -1, 0 ), 16.0 ), vectorscale( ( 1, 1, 1 ), 16.0 ), 0, color, 1, 0, 1 );
#/
}

draw_pathnode_think( node, color )
{
/#
    level endon( "draw_pathnode_stop" );

    for (;;)
    {
        draw_pathnode( node, color );
        wait 0.05;
    }
#/
}

draw_pathnodes_stop()
{
/#
    wait 5;
    level notify( "draw_pathnode_stop" );
#/
}

node_get( player )
{
/#
    for (;;)
    {
        wait 0.05;
        origin = get_lookat_origin( player );
        node = getnearestnode( origin );

        if ( !isdefined( node ) )
            continue;

        if ( player buttonpressed( "BUTTON_A" ) )
            return node;
        else if ( player buttonpressed( "BUTTON_B" ) )
            return undefined;

        if ( node.type == "Path" )
        {
            draw_pathnode( node, ( 1, 0, 1 ) );
            continue;
        }

        draw_pathnode( node, ( 0.85, 0.85, 0.1 ) );
    }
#/
}

dev_get_node_pair()
{
/#
    player = gethostplayer();
    start = undefined;

    while ( !isdefined( start ) )
    {
        start = node_get( player );

        if ( player buttonpressed( "BUTTON_B" ) )
        {
            level notify( "draw_pathnode_stop" );
            return undefined;
        }
    }

    level thread draw_pathnode_think( start, ( 0, 1, 0 ) );

    while ( player buttonpressed( "BUTTON_A" ) )
        wait 0.05;

    end = undefined;

    while ( !isdefined( end ) )
    {
        end = node_get( player );

        if ( player buttonpressed( "BUTTON_B" ) )
        {
            level notify( "draw_pathnode_stop" );
            return undefined;
        }
    }

    level thread draw_pathnode_think( end, ( 0, 1, 0 ) );
    level thread draw_pathnodes_stop();
    array = [];
    array[0] = start;
    array[1] = end;
    return array;
#/
}
