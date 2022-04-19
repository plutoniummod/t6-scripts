// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;

businit()
{
/#
    assert( level.clientscripts );
#/
    level.busstate = "";
    registerclientsys( "busCmd" );
}

setbusstate( state )
{
    if ( level.busstate != state )
        setclientsysstate( "busCmd", state );

    level.busstate = state;
}
