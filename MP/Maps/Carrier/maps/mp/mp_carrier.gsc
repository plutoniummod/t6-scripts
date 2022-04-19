// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_carrier_fx;
#include maps\mp\_load;
#include maps\mp\mp_carrier_amb;
#include maps\mp\_compass;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    level.overrideplayerdeathwatchtimer = ::leveloverridetime;
    level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
    maps\mp\mp_carrier_fx::main();
    maps\mp\_load::main();
    maps\mp\mp_carrier_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_carrier" );
    game["strings"]["war_callsign_a"] = &"MPUI_CALLSIGN_MAPNAME_A";
    game["strings"]["war_callsign_b"] = &"MPUI_CALLSIGN_MAPNAME_B";
    game["strings"]["war_callsign_c"] = &"MPUI_CALLSIGN_MAPNAME_C";
    game["strings"]["war_callsign_d"] = &"MPUI_CALLSIGN_MAPNAME_D";
    game["strings"]["war_callsign_e"] = &"MPUI_CALLSIGN_MAPNAME_E";
    game["strings_menu"]["war_callsign_a"] = "@MPUI_CALLSIGN_MAPNAME_A";
    game["strings_menu"]["war_callsign_b"] = "@MPUI_CALLSIGN_MAPNAME_B";
    game["strings_menu"]["war_callsign_c"] = "@MPUI_CALLSIGN_MAPNAME_C";
    game["strings_menu"]["war_callsign_d"] = "@MPUI_CALLSIGN_MAPNAME_D";
    game["strings_menu"]["war_callsign_e"] = "@MPUI_CALLSIGN_MAPNAME_E";
    level thread water_trigger_init();
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2600", reset_dvars );
}

water_trigger_init()
{
    wait 3;
    triggers = getentarray( "trigger_hurt", "classname" );

    foreach ( trigger in triggers )
    {
        if ( trigger.origin[2] > level.mapcenter[2] )
            continue;

        trigger thread water_trigger_think();
    }
}

water_trigger_think()
{
    for (;;)
    {
        self waittill( "trigger", entity );

        if ( isplayer( entity ) )
        {
            trace = worldtrace( entity.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), entity.origin - vectorscale( ( 0, 0, 1 ), 256.0 ) );

            if ( trace["surfacetype"] == "none" )
            {
                entity playsound( "mpl_splash_death" );
                playfx( level._effect["water_splash"], entity.origin + vectorscale( ( 0, 0, 1 ), 40.0 ) );
            }
        }
    }
}

leveloverridetime( defaulttime )
{
    if ( self isinwater() )
        return 0.4;

    return defaulttime;
}

useintermissionpointsonwavespawn()
{
    return self isinwater();
}

isinwater()
{
    triggers = getentarray( "trigger_hurt", "classname" );

    foreach ( trigger in triggers )
    {
        if ( trigger.origin[2] > level.mapcenter[2] )
            continue;

        if ( self istouching( trigger ) )
        {
            trace = worldtrace( self.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), self.origin - vectorscale( ( 0, 0, 1 ), 256.0 ) );
            return trace["surfacetype"] == "none";
        }
    }

    return 0;
}
