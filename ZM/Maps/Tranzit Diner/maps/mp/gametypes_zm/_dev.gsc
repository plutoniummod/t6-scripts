// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
/#
    for (;;)
    {
        updatedevsettingszm();
        wait 0.5;
    }
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
