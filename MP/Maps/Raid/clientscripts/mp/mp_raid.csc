// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_raid_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_raid_amb;

main()
{
    level.worldmapx = 2249;
    level.worldmapy = 4525;
    level.worldlat = 34.1195;
    level.worldlong = -118.35;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_raid_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_raid_amb::main();
    setsaveddvar( "compassmaxrange", "2100" );
    waitforclient( 0 );
/#
    println( "*** Client : mp_raid running..." );
#/
}
