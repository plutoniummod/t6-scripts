// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_meltdown_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_meltdown_amb;

main()
{
    level.worldmapx = 2334;
    level.worldmapy = 1722;
    level.worldlat = 25.2388;
    level.worldlong = 64.4056;
    clientscripts\mp\_load::main();
    thread clientscripts\mp\mp_meltdown_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_meltdown_amb::main();
    setsaveddvar( "compassmaxrange", "2100" );
    setsaveddvar( "r_waterwavespeed", ".1246294 .250611 .369935 .131685" );
    setsaveddvar( "r_waterwaveamplitude", "7.89653 9.83175 9.22 7.62334" );
    setsaveddvar( "r_waterwavewavelength", "228.62 537.375 436.002 303.18" );
    setsaveddvar( "r_waterwavesteepness", "1 1 1 1" );
    setsaveddvar( "r_waterwaveangle", "156.581 191.305 133.964 165.722" );
    setsaveddvar( "r_waterwavephase", "3.69 2.53 1.16 1.94" );
    thread waitforclient( 0 );
/#
    println( "*** Client : mp_meltdown running..." );
#/
}
