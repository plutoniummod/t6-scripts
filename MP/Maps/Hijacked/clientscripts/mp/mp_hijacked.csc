// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_hijacked_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_hijacked_amb;

main()
{
    level.worldmapx = -239;
    level.worldmapy = -16;
    level.worldlat = -37.6447;
    level.worldlong = 77.8777;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_hijacked_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_hijacked_amb::main();
    setsaveddvar( "compassmaxrange", "2100" );
    waitforclient( 0 );
/#
    println( "*** Client : mp_hijacked running..." );
#/
}
