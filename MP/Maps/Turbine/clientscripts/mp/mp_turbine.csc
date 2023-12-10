// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_turbine_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_turbine_amb;

main()
{
    level.worldmapx = -1697;
    level.worldmapy = 1808;
    level.worldlat = 18.2522;
    level.worldlong = 42.3391;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_turbine_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_turbine_amb::main();
    setsaveddvar( "compassmaxrange", "2100" );
    setsaveddvar( "sm_sunsamplesizenear", 0.39 );
    setsaveddvar( "sm_sunshadowsmall", 1 );
    waitforclient( 0 );
/#
    println( "*** Client : mp_turbine running..." );
#/
}
