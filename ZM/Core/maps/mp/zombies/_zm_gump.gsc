// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

init()
{
    if ( !( isdefined( level.disable_blackscreen_clientfield ) && level.disable_blackscreen_clientfield ) )
        registerclientfield( "toplayer", "blackscreen", 1, 1, "int" );

    if ( !isdefined( level.uses_gumps ) )
        level.uses_gumps = 0;

    if ( isdefined( level.uses_gumps ) && level.uses_gumps )
        onplayerconnect_callback( ::player_connect_gump );
}

player_teleport_blackscreen_on()
{
    if ( isdefined( level.disable_blackscreen_clientfield ) && level.disable_blackscreen_clientfield )
        return;

    if ( isdefined( level.uses_gumps ) && level.uses_gumps )
    {
        self setclientfieldtoplayer( "blackscreen", 1 );
        wait 0.05;
        self setclientfieldtoplayer( "blackscreen", 0 );
    }
}

player_connect_gump()
{

}

player_watch_spectate_change()
{
    if ( isdefined( level.disable_blackscreen_clientfield ) && level.disable_blackscreen_clientfield )
        return;

    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "spectator_cycle" );

        self setclientfieldtoplayer( "blackscreen", 1 );
        wait 0.05;
        self setclientfieldtoplayer( "blackscreen", 0 );
    }
}

gump_test()
{
/#
    wait 10;
    pos1 = ( -4904, -7657, 4 );
    pos3 = ( 7918, -6506, 177 );
    pos2 = ( 1986, -73, 4 );
    players = get_players();

    if ( isdefined( players[0] ) )
        players[0] setorigin( pos1 );

    wait 0.05;

    if ( isdefined( players[1] ) )
        players[1] setorigin( pos2 );

    wait 0.05;

    if ( isdefined( players[2] ) )
        players[2] setorigin( pos3 );
#/
}
