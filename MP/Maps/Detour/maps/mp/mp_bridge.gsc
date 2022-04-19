// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\mp_bridge_fx;
#include maps\mp\_load;
#include maps\mp\mp_bridge_amb;
#include maps\mp\_compass;
#include maps\mp\gametypes\_spawning;
#include maps\mp\gametypes\_deathicons;

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_bridge_fx::main();
    precachemodel( "collision_physics_128x128x10" );
    precachemodel( "collision_missile_128x128x10" );
    precachemodel( "collision_physics_64x64x10" );
    precachemodel( "collision_missile_32x32x128" );
    precachemodel( "collision_clip_32x32x10" );
    precachemodel( "p6_bri_construction_tarp" );
    maps\mp\_load::main();
    maps\mp\mp_bridge_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_bridge" );
    setdvar( "compassmaxrange", "2100" );
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
    spawncollision( "collision_physics_128x128x10", "collider", ( -1190, -876, -76 ), ( 342, 2.63, -90 ) );
    barricade1 = spawn( "script_model", ( 850.5, -812.5, 0 ) );
    barricade1.angles = vectorscale( ( 0, 1, 0 ), 90.0 );
    barricade1 setmodel( "p6_bri_construction_tarp" );
    spawncollision( "collision_missile_128x128x10", "collider", ( -2182, -185.5, -142 ), vectorscale( ( 0, 0, 1 ), 90.0 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -2310, -185.5, -142 ), vectorscale( ( 0, 0, 1 ), 90.0 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -2438, -185.5, -142 ), vectorscale( ( 0, 0, 1 ), 90.0 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -2182, -57.5, -142 ), vectorscale( ( 0, 0, 1 ), 90.0 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -2310, -57.5, -142 ), vectorscale( ( 0, 0, 1 ), 90.0 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -2438, -57.5, -142 ), vectorscale( ( 0, 0, 1 ), 90.0 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -2366.5, 91, -142 ), vectorscale( ( 0, 0, 1 ), 90.0 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1401.5, 759.5, -158.5 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1309, 726.5, -158.5 ), ( 2.4, 359.9, -91.7047 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1401.5, 634, -154.5 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1373.5, 634, -154.5 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1401.5, 559.5, -154.5 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1422, 375.5, -141.5 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1322.5, 438, -146 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1304.5, 438, -146 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1322.5, 378.5, -144 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1230, 396, -144 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1357, 248, -139 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1230, 285, -139 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -1230, 248, -139 ), vectorscale( ( 0, 0, -1 ), 92.4002 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( 1370, -697, -134 ), vectorscale( ( 0, 0, 1 ), 90.0 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( 2432, -44, 30.5 ), ( 0, 270, -90 ) );
    spawncollision( "collision_physics_64x64x10", "collider", ( 2113.5, -44, 30.5 ), ( 0, 270, -90 ) );
    spawncollision( "collision_missile_32x32x128", "collider", ( -2292, -174, -7.5 ), vectorscale( ( 0, 1, 0 ), 270.0 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -2219.5, -184.5, 37 ), vectorscale( ( 1, 0, 0 ), 2.9 ) );
    spawncollision( "collision_missile_128x128x10", "collider", ( -2197.5, -184.5, 33 ), vectorscale( ( 1, 0, 0 ), 23.9 ) );
    spawncollision( "collision_clip_32x32x10", "collider", ( 1923.5, 553.5, 43.5 ), ( 1.265, 43.3, -90 ) );
    maps\mp\gametypes\_spawning::level_use_unified_spawning( 1 );
    registerclientfield( "scriptmover", "police_car_lights", 1, 1, "int" );
    level thread destructible_lights();
    setdvar( "r_lightGridEnableTweaks", 1 );
    setdvar( "r_lightGridIntensity", 2.0 );
    setdvar( "r_lightGridContrast", 0.0 );
    level.ragdoll_override = ::ragdoll_override;
    level.overrideplayerdeathwatchtimer = ::leveloverridetime;
    level.useintermissionpointsonwavespawn = ::useintermissionpointsonwavespawn;
    level thread pathing_fix();
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "2400", reset_dvars );
    ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "1000", reset_dvars );
}

destructible_lights()
{
    wait 0.05;
    destructibles = getentarray( "destructible", "targetname" );

    foreach ( destructible in destructibles )
    {
        if ( destructible.destructibledef == "veh_t6_dlc_police_car_destructible" )
        {
            destructible thread destructible_think( "police_car_lights" );
            destructible setclientfield( "police_car_lights", 1 );
        }
    }
}

destructible_think( clientfield )
{
    self waittill_any( "death", "destructible_base_piece_death" );
    self setclientfield( clientfield, 0 );
}

ragdoll_override( idamage, smeansofdeath, sweapon, shitloc, vdir, vattackerorigin, deathanimduration, einflictor, ragdoll_jib, body )
{
    if ( smeansofdeath == "MOD_FALLING" )
    {
        deathanim = body getcorpseanim();
        startfrac = deathanimduration / 1000;

        if ( animhasnotetrack( deathanim, "start_ragdoll" ) )
        {
            times = getnotetracktimes( deathanim, "start_ragdoll" );

            if ( isdefined( times ) )
                startfrac = times[0];
        }

        self.body = body;

        if ( !isdefined( self.switching_teams ) )
            thread maps\mp\gametypes\_deathicons::adddeathicon( body, self, self.team, 5.0 );

        self thread water_spash();
        return true;
    }

    return false;
}

water_spash()
{
    self endon( "disconnect" );
    self endon( "spawned_player" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );
    trace = groundtrace( self.origin, self.origin - vectorscale( ( 0, 0, 1 ), 2048.0 ), 0, self.body );

    if ( trace["surfacetype"] == "water" )
    {
        while ( self.origin[2] > trace["position"][2] + 5 )
            wait 0.05;

        bone = self gettagorigin( "j_spinelower" );
        origin = ( bone[0], bone[1], trace["position"][2] + 2.5 );
        self playsound( "mpl_splash_death" );
        playfx( level._effect["water_splash"], origin );
    }
}

leveloverridetime( defaulttime )
{
    if ( self isinwater() )
        return 1;

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

pathing_fix()
{
    wait 1;
    nodes = getallnodes();
    disconnect_node( nodes[96] );
    disconnect_node( nodes[600] );
}

disconnect_node( node )
{
    ent = spawn( "script_model", node.origin, 1 );
    ent setmodel( level.deployedshieldmodel );
    ent hide();
    ent disconnectpaths();
    ent.origin -= vectorscale( ( 0, 0, 1 ), 64.0 );
}
