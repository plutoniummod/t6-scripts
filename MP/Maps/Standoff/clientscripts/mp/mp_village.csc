// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_village_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_village_amb;

main()
{
    level.worldmapx = -631;
    level.worldmapy = 312;
    level.worldlat = 41.1178;
    level.worldlong = 76.6909;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_village_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_village_amb::main();
    setsaveddvar( "compassmaxrange", "2100" );
    waitforclient( 0 );
/#
    println( "*** Client : mp_village running..." );
#/
}
