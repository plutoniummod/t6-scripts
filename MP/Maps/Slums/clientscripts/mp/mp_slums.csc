// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_slums_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_slums_amb;

main()
{
    level.worldmapx = 226;
    level.worldmapy = -736;
    level.worldlat = 8.9515;
    level.worldlong = -79.5355;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_slums_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_slums_amb::main();
    setsaveddvar( "compassmaxrange", "2100" );
    waitforclient( 0 );
/#
    println( "*** Client : mp_slums running..." );
#/
}
