// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_overflow_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_overflow_amb;

main()
{
    level.worldmapx = -358;
    level.worldmapy = -17;
    level.worldlat = 33.9787;
    level.worldlong = 71.5975;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_overflow_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_overflow_amb::main();
    setsaveddvar( "compassmaxrange", "2100" );
    setsaveddvar( "sm_sunsamplesizenear", 0.2 );
    setsaveddvar( "sm_sunshadowsmall", 0 );
    waitforclient( 0 );
/#
    println( "*** Client : mp_overflow running..." );
#/
}
