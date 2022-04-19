// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\mp_dockside_fx;
#include maps\mp\_load;
#include maps\mp\mp_dockside_amb;
#include maps\mp\_compass;
#include maps\mp\mp_dockside_crane;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_dockside_fx::main();
    maps\mp\_load::main();
    maps\mp\mp_dockside_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_dockside" );
    level.overrideplayerdeathwatchtimer = ::leveloverridetime;
    level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
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
    setdvar( "sm_sunsamplesizenear", 0.39 );
    setdvar( "sm_sunshadowsmall", 1 );

    if ( getgametypesetting( "allowMapScripting" ) )
        level maps\mp\mp_dockside_crane::init();
    else
    {
        crate_triggers = getentarray( "crate_kill_trigger", "targetname" );

        for ( i = 0; i < crate_triggers.size; i++ )
            crate_triggers[i] delete();
    }

    setheliheightpatchenabled( "war_mode_heli_height_lock", 0 );
    level thread water_trigger_init();
    rts_remove();
/#
    level thread devgui_dockside();
    execdevgui( "devgui_mp_dockside" );
#/
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2700", reset_dvars );
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
            entity playsound( "mpl_splash_death" );
            playfx( level._effect["water_splash"], entity.origin + vectorscale( ( 0, 0, 1 ), 40.0 ) );
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
            return true;
    }

    return false;
}

rts_remove()
{
    removes = getentarray( "rts_only", "targetname" );

    foreach ( remove in removes )
    {
        if ( isdefined( remove ) )
            remove delete();
    }
}

devgui_dockside()
{
/#
    setdvar( "devgui_notify", "" );

    for (;;)
    {
        wait 0.5;
        devgui_string = getdvar( "devgui_notify" );

        switch ( devgui_string )
        {
            case "":
                break;
            case "crane_print_dvars":
                crane_print_dvars();
                break;
            default:
                break;
        }

        if ( getdvar( "devgui_notify" ) != "" )
            setdvar( "devgui_notify", "" );
    }
#/
}

crane_print_dvars()
{
/#
    dvars = [];
    dvars[dvars.size] = "scr_crane_claw_move_time";
    dvars[dvars.size] = "scr_crane_crate_lower_time";
    dvars[dvars.size] = "scr_crane_crate_raise_time";
    dvars[dvars.size] = "scr_crane_arm_y_move_time";
    dvars[dvars.size] = "scr_crane_arm_z_move_time";
    dvars[dvars.size] = "scr_crane_claw_drop_speed";
    dvars[dvars.size] = "scr_crane_claw_drop_time_min";

    foreach ( dvar in dvars )
    {
        print( dvar + ": " );
        println( getdvar( dvar ) );
    }
#/
}
