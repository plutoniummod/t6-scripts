// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_socotra_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_socotra_amb;

main()
{
    level.worldmapx = 1971;
    level.worldmapy = -531;
    level.worldlat = 12.5532;
    level.worldlong = 54.5316;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_socotra_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_socotra_amb::main();
    setsaveddvar( "compassmaxrange", "2100" );
    setsaveddvar( "sm_sunsamplesizenear", 0.39 );
    waitforclient( 0 );
/#
    println( "*** Client : mp_socotra running..." );
#/
}
