// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes\_globallogic_utils;

add_timed_event( seconds, notify_string, client_notify_string )
{
    assert( seconds >= 0 );

    if ( level.timelimit > 0 )
        level thread timed_event_monitor( seconds, notify_string, client_notify_string );
}

timed_event_monitor( seconds, notify_string, client_notify_string )
{
    for (;;)
    {
        wait 0.5;

        if ( !isdefined( level.starttime ) )
            continue;

        millisecs_remaining = maps\mp\gametypes\_globallogic_utils::gettimeremaining();
        seconds_remaining = millisecs_remaining / 1000;

        if ( seconds_remaining <= seconds )
        {
            event_notify( notify_string, client_notify_string );
            return;
        }
    }
}

add_score_event( score, notify_string, client_notify_string )
{
    assert( score >= 0 );

    if ( level.scorelimit > 0 )
    {
        if ( level.teambased )
            level thread score_team_event_monitor( score, notify_string, client_notify_string );
        else
            level thread score_event_monitor( score, notify_string, client_notify_string );
    }
}

any_team_reach_score( score )
{
    foreach ( team in level.teams )
    {
        if ( game["teamScores"][team] >= score )
            return true;
    }

    return false;
}

score_team_event_monitor( score, notify_string, client_notify_string )
{
    for (;;)
    {
        wait 0.5;

        if ( any_team_reach_score( score ) )
        {
            event_notify( notify_string, client_notify_string );
            return;
        }
    }
}

score_event_monitor( score, notify_string, client_notify_string )
{
    for (;;)
    {
        wait 0.5;
        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            if ( isdefined( players[i].score ) && players[i].score >= score )
            {
                event_notify( notify_string, client_notify_string );
                return;
            }
        }
    }
}

event_notify( notify_string, client_notify_string )
{
    if ( isdefined( notify_string ) )
        level notify( notify_string );

    if ( isdefined( client_notify_string ) )
        clientnotify( client_notify_string );
}
