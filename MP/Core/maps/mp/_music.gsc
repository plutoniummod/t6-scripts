// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;

music_init()
{
/#
    assert( level.clientscripts );
#/
    level.musicstate = "";
    registerclientsys( "musicCmd" );
}

setmusicstate( state, player )
{
    if ( isdefined( level.musicstate ) )
    {
        if ( isdefined( player ) )
        {
            setclientsysstate( "musicCmd", state, player );
            return;
        }
        else if ( level.musicstate != state )
            setclientsysstate( "musicCmd", state );
    }

    level.musicstate = state;
}
