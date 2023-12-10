// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_nightclub_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_nightclub_amb;

main()
{
    level.worldmapx = -17513;
    level.worldmapy = 2252;
    level.worldlat = -22.106;
    level.worldlong = 86.4368;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_nightclub_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_nightclub_amb::main();
    setsaveddvar( "compassmaxrange", "2100" );
    setsaveddvar( "sm_sunsamplesizenear", 0.39 );
    waitforclient( 0 );
/#
    println( "*** Client : mp_nightclub running..." );
#/
}
