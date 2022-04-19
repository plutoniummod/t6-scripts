// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    if ( level.createfx_enabled || sessionmodeiszombiesgame() )
        return;

    if ( getdvar( "scr_drawfriend" ) == "" )
        setdvar( "scr_drawfriend", "0" );

    level.drawfriend = getdvarint( "scr_drawfriend" );
/#
    assert( isdefined( game["headicon_allies"] ), "Allied head icons are not defined.  Check the team set for the level." );
#/
/#
    assert( isdefined( game["headicon_axis"] ), "Axis head icons are not defined.  Check the team set for the level." );
#/
    precacheheadicon( game["headicon_allies"] );
    precacheheadicon( game["headicon_axis"] );
    level thread onplayerconnect();

    for (;;)
    {
        updatefriendiconsettings();
        wait 5;
    }
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread onplayerspawned();
        player thread onplayerkilled();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self thread showfriendicon();
    }
}

onplayerkilled()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "killed_player" );

        self.headicon = "";
    }
}

showfriendicon()
{
    if ( level.drawfriend )
    {
        team = self.pers["team"];
        self.headicon = game["headicon_" + team];
        self.headiconteam = team;
    }
}

updatefriendiconsettings()
{
    drawfriend = getdvarfloat( "scr_drawfriend" );

    if ( level.drawfriend != drawfriend )
    {
        level.drawfriend = drawfriend;
        updatefriendicons();
    }
}

updatefriendicons()
{
    players = level.players;

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];

        if ( isdefined( player.pers["team"] ) && player.pers["team"] != "spectator" && player.sessionstate == "playing" )
        {
            if ( level.drawfriend )
            {
                team = self.pers["team"];
                self.headicon = game["headicon_" + team];
                self.headiconteam = team;
                continue;
            }

            players = level.players;

            for ( i = 0; i < players.size; i++ )
            {
                player = players[i];

                if ( isdefined( player.pers["team"] ) && player.pers["team"] != "spectator" && player.sessionstate == "playing" )
                    player.headicon = "";
            }
        }
    }
}
