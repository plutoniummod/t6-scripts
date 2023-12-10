// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_mirage_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_mirage_amb;

main()
{
    level.worldmapx = 0;
    level.worldmapy = 0;
    level.worldlat = 43.1974;
    level.worldlong = 110.923;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_mirage_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_mirage_amb::main();
    setsaveddvar( "sm_sunsamplesizenear", 0.39 );
    setsaveddvar( "sm_sunshadowsmall", 1 );
    waitforclient( 0 );
/#
    println( "*** Client : mp_mirage running..." );
#/
}
