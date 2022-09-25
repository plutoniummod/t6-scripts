// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_tacticalinsertion;
#include maps\mp\killstreaks\_rcbomb;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\gametypes\ctf;
#include maps\mp\gametypes\_gameobjects;
#include maps\mp\killstreaks\_supplydrop;

init()
{
    precachemodel( "p6_dockside_container_lrg_white" );
    crane_dvar_init();
    level.crate_models = [];
    level.crate_models[0] = "p6_dockside_container_lrg_red";
    level.crate_models[1] = "p6_dockside_container_lrg_blue";
    level.crate_models[2] = "p6_dockside_container_lrg_white";
    level.crate_models[3] = "p6_dockside_container_lrg_orange";
    claw = getent( "claw_base", "targetname" );
    claw.z_upper = claw.origin[2];
    claw thread sound_wires_move();
    arms_y = getentarray( "claw_arm_y", "targetname" );
    arms_z = getentarray( "claw_arm_z", "targetname" );
    claw.arms = arraycombine( arms_y, arms_z, 1, 0 );

    foreach ( arm_z in arms_z )
    {
        arm_y = getclosest( arm_z.origin, arms_y );
        arm_z.parent = arm_y;
    }

    foreach ( arm_y in arms_y )
        arm_y.parent = claw;

    claw claw_link_arms( "claw_arm_y" );
    claw claw_link_arms( "claw_arm_z" );
    crates = getentarray( "crate", "targetname" );
    array_thread( crates, ::sound_pit_move );
    crate_data = [];

    for ( i = 0; i < crates.size; i++ )
    {
        crates[i] disconnectpaths();
        data = spawnstruct();
        data.origin = crates[i].origin;
        data.angles = crates[i].angles;
        crate_data[i] = data;
    }

    rail = getent( "crane_rail", "targetname" );
    rail thread sound_ring_move();
    rail.roller = getent( "crane_roller", "targetname" );
    rail.roller.wheel = getent( "crane_wheel", "targetname" );
    claw.wires = getentarray( "crane_wire", "targetname" );
    claw.z_wire_max = rail.roller.wheel.origin[2] - 50;

    foreach ( wire in claw.wires )
    {
        wire linkto( claw );

        if ( wire.origin[2] > claw.z_wire_max )
            wire ghost();
    }

    placements = getentarray( "crate_placement", "targetname" );

    foreach ( placement in placements )
    {
        placement.angles += vectorscale( ( 0, 1, 0 ), 90.0 );
        crates[crates.size] = spawn( "script_model", placement.origin );
    }

    triggers = getentarray( "crate_kill_trigger", "targetname" );

    foreach ( crate in crates )
    {
        crate.kill_trigger = getclosest( crate.origin, triggers );
        crate.kill_trigger.origin = crate.origin - vectorscale( ( 0, 0, 1 ), 5.0 );
        crate.kill_trigger enablelinkto();
        crate.kill_trigger linkto( crate );

        if ( crate.model != "" )
        {
            crate.kill_trigger.active = 1;
            continue;
        }

        crate.kill_trigger.active = 0;
    }

    trigger = getclosest( claw.origin, triggers );
    trigger enablelinkto();
    trigger linkto( claw );
    trigger.active = 1;
    placements = array_randomize( placements );
    level thread crane_think( claw, rail, crates, crate_data, placements );
}

crane_dvar_init()
{
    set_dvar_float_if_unset( "scr_crane_claw_move_time", "5" );
    set_dvar_float_if_unset( "scr_crane_crate_lower_time", "5" );
    set_dvar_float_if_unset( "scr_crane_crate_raise_time", "5" );
    set_dvar_float_if_unset( "scr_crane_arm_y_move_time", "3" );
    set_dvar_float_if_unset( "scr_crane_arm_z_move_time", "3" );
    set_dvar_float_if_unset( "scr_crane_claw_drop_speed", "25" );
    set_dvar_float_if_unset( "scr_crane_claw_drop_time_min", "5" );
}

wire_render()
{
    self endon( "movedone" );

    for (;;)
    {
        wait 0.05;

        foreach ( wire in self.wires )
        {
            if ( wire.origin[2] > self.z_wire_max )
            {
                wire ghost();
                continue;
            }

            wire show();
        }
    }
}

crane_think( claw, rail, crates, crate_data, placements )
{
    wait 1;
    claw arms_open();

    for (;;)
    {
        for ( i = 0; i < crates.size - placements.size; i++ )
        {
            crate = getclosest( crate_data[i].origin, crates );
            rail crane_move( claw, crate_data[i], -318 );
            level notify( "wires_move" );
            claw claw_crate_grab( crate, 318 );
            lower = 1;
            target = ( i + 1 ) % ( crates.size - placements.size );
            target_crate = getclosest( crate_data[target].origin, crates );

            if ( cointoss() )
            {
                for ( placement_index = 0; placement_index < placements.size; placement_index++ )
                {
                    placement = placements[placement_index];

                    if ( !isdefined( placement.crate ) )
                    {
                        lower = 0;
                        break;
                    }
                }
            }

            if ( !lower )
            {
                z_dist = crate.origin[2] - placement.origin[2] - 33;
                rail crane_move( claw, placement, z_dist * -1 );
                level notify( "wires_move" );
                placement.crate = crate;
            }
            else
            {
                rail crane_move( claw, crate_data[target], -181 );
                level notify( "wires_move" );
            }

            claw claw_crate_move( crate );

            if ( lower )
                crate crate_lower( target_crate, crate_data[target] );

            crate = target_crate;
            target = ( i + 2 ) % ( crates.size - placements.size );
            target_crate = getclosest( crate_data[target].origin, crates );

            if ( !lower )
            {
                crate = crates[3 + placement_index];
                crate.origin = target_crate.origin - vectorscale( ( 0, 0, 1 ), 137.0 );
                crate.angles = target_crate.angles;
                wait 0.25;

                claw waittill( "movedone" );
            }

            crate crate_raise( target_crate, crate_data[target] );
            rail crane_move( claw, crate_data[target], -181 );
            level notify( "wires_move" );
            claw claw_crate_grab( target_crate, 181 );
            crate = target_crate;
            target = ( i + 3 ) % ( crates.size - placements.size );
            rail crane_move( claw, crate_data[target], -318 );
            level notify( "wires_move" );
            claw claw_crate_drop( crate, crate_data[target] );
        }
    }
}

crane_move( claw, desired, z_dist )
{
    self.roller linkto( self );
    self.roller.wheel linkto( self.roller );
    claw linkto( self.roller.wheel );
    goal = ( desired.origin[0], desired.origin[1], self.origin[2] );
    dir = vectornormalize( goal - self.origin );
    angles = vectortoangles( dir );
    angles = ( self.angles[0], angles[1] + 90, self.angles[2] );
    yawdiff = absangleclamp360( self.angles[1] - angles[1] );
    time = yawdiff / 25;
    self rotateto( angles, time, time * 0.35, time * 0.45 );
    self thread physics_move();
    level notify( "wires_stop" );
    level notify( "ring_move" );

    self waittill( "rotatedone" );

    self.roller unlink();
    goal = ( desired.origin[0], desired.origin[1], self.roller.origin[2] );
    diff = distance2d( goal, self.roller.origin );
    speed = getdvarfloat( "scr_crane_claw_drop_speed" );
    time = diff / speed;

    if ( time < getdvarfloat( "scr_crane_claw_drop_time_min" ) )
        time = getdvarfloat( "scr_crane_claw_drop_time_min" );

    self.roller moveto( goal, time, time * 0.25, time * 0.25 );
    self.roller thread physics_move();
    goal = ( desired.origin[0], desired.origin[1], self.roller.wheel.origin[2] );
    self.roller.wheel unlink();
    self.roller.wheel moveto( goal, time, time * 0.25, time * 0.25 );
    self.roller.wheel rotateto( desired.angles + vectorscale( ( 0, 1, 0 ), 90.0 ), time, time * 0.25, time * 0.25 );
    claw.z_initial = claw.origin[2];
    claw unlink();
    claw rotateto( desired.angles, time, time * 0.25, time * 0.25 );
    claw.goal = ( goal[0], goal[1], claw.origin[2] + z_dist );
    claw.time = time;
    claw moveto( claw.goal, time, time * 0.25, time * 0.25 );
    level notify( "ring_stop" );
}

physics_move()
{
    self endon( "rotatedone" );
    self endon( "movedone" );

    for (;;)
    {
        wait 0.05;
        crates = getentarray( "care_package", "script_noteworthy" );

        foreach ( crate in crates )
        {
            if ( crate istouching( self ) )
                crate physicslaunch( crate.origin, ( 0, 0, 0 ) );
        }
    }
}

claw_crate_grab( crate, z_dist )
{
    self thread wire_render();

    self waittill( "movedone" );

    level notify( "wires_stop" );
    self playsound( "amb_crane_arms_b" );
    self claw_z_arms( -33 );
    self playsound( "amb_crane_arms" );
    self arms_close( crate );
    crate movez( 33, getdvarfloat( "scr_crane_arm_z_move_time" ) );
    self claw_z_arms( 33 );
    crate linkto( self );
    self movez( z_dist, getdvarfloat( "scr_crane_claw_move_time" ) );
    self thread wire_render();
    level notify( "wires_move" );

    self waittill( "movedone" );

    self playsound( "amb_crane_arms" );
}

sound_wires_move()
{
    while ( true )
    {
        level waittill( "wires_move" );

        self playsound( "amb_crane_wire_start" );
        self playloopsound( "amb_crane_wire_lp" );

        level waittill( "wires_stop" );

        self playsound( "amb_crane_wire_end" );
        wait 0.1;
        self stoploopsound( 0.2 );
    }
}

sound_ring_move()
{
    while ( true )
    {
        level waittill( "ring_move" );

        self playsound( "amb_crane_ring_start" );
        self playloopsound( "amb_crane_ring_lp" );

        level waittill( "ring_stop" );

        self playsound( "amb_crane_ring_end" );
        wait 0.1;
        self stoploopsound( 0.2 );
    }
}

sound_pit_move()
{
    while ( true )
    {
        level waittill( "pit_move" );

        self playsound( "amb_crane_pit_start" );
        self playloopsound( "amb_crane_pit_lp" );

        level waittill( "pit_stop" );

        self playsound( "amb_crane_pit_end" );
        self stoploopsound( 0.2 );
        wait 0.2;
    }
}

claw_crate_move( crate, claw )
{
    self thread wire_render();

    self waittill( "movedone" );

    crate unlink();
    self playsound( "amb_crane_arms_b" );
    level notify( "wires_stop" );
    crate movez( -33, getdvarfloat( "scr_crane_arm_z_move_time" ) );
    self claw_z_arms( -33 );
    self playsound( "amb_crane_arms_b" );
    playfxontag( level._effect["crane_dust"], crate, "tag_origin" );
    crate playsound( "amb_crate_drop" );
    self arms_open();
    level notify( "wires_move" );
    self claw_z_arms( 33 );
    z_dist = self.z_initial - self.origin[2];
    self movez( z_dist, getdvarfloat( "scr_crane_claw_move_time" ) );
    self thread wire_render();
}

claw_crate_drop( target, data )
{
    target thread crate_drop_think( self );
    self thread wire_render();

    self waittill( "claw_movedone" );

    target unlink();
    level notify( "wires_stop" );
    self playsound( "amb_crane_arms_b" );
    target movez( -33, getdvarfloat( "scr_crane_arm_z_move_time" ) );
    self claw_z_arms( -33 );
    playfxontag( level._effect["crane_dust"], target, "tag_origin" );
    self playsound( "amb_crate_drop" );
    target notify( "claw_done" );
    self playsound( "amb_crane_arms" );
    self arms_open();
    level notify( "wires_move" );
    target.origin = data.origin;
    self claw_z_arms( 33 );
    self playsound( "amb_crane_arms" );
    self movez( 318, getdvarfloat( "scr_crane_claw_move_time" ) );
    self thread wire_render();

    self waittill( "movedone" );
}

crate_lower( lower, data )
{
    z_dist = abs( self.origin[2] - lower.origin[2] );
    self movez( z_dist * -1, getdvarfloat( "scr_crane_crate_lower_time" ) );
    lower movez( z_dist * -1, getdvarfloat( "scr_crane_crate_lower_time" ) );
    level notify( "pit_move" );

    lower waittill( "movedone" );

    level notify( "pit_stop" );
    lower ghost();
    self.origin = data.origin;
    wait 0.25;
}

crate_raise( upper, data )
{
    self crate_set_random_model( upper );
    self.kill_trigger.active = 1;
    self.origin = ( data.origin[0], data.origin[1], self.origin[2] );
    self.angles = data.angles;
    wait 0.2;
    self show();
    z_dist = abs( upper.origin[2] - self.origin[2] );
    self movez( z_dist, getdvarfloat( "scr_crane_crate_raise_time" ) );
    upper movez( z_dist, getdvarfloat( "scr_crane_crate_raise_time" ) );
    level notify( "wires_stop" );
    level notify( "pit_move" );
    upper thread raise_think();
}

raise_think()
{
    self waittill( "movedone" );

    level notify( "pit_stop" );
}

crate_set_random_model( other )
{
    models = array_randomize( level.crate_models );

    foreach ( model in models )
    {
        if ( model == other.model )
            continue;

        self setmodel( model );
        return;
    }
}

arms_open()
{
    self claw_move_arms( -15 );
    self playsound( "amb_crane_arms" );
}

arms_close( crate )
{
    self claw_move_arms( 15, crate );
    self playsound( "amb_crane_arms" );
}

claw_link_arms( name )
{
    foreach ( arm in self.arms )
    {
        if ( arm.targetname == name )
            arm linkto( arm.parent );
    }
}

claw_unlink_arms( name )
{
    foreach ( arm in self.arms )
    {
        if ( arm.targetname == name )
            arm unlink();
    }
}

claw_move_arms( dist, crate )
{
    claw_unlink_arms( "claw_arm_y" );
    arms = [];

    foreach ( arm in self.arms )
    {
        forward = anglestoforward( arm.angles );
        arm.goal = arm.origin + vectorscale( forward, dist );

        if ( arm.targetname == "claw_arm_y" )
        {
            arms[arms.size] = arm;
            arm moveto( arm.goal, getdvarfloat( "scr_crane_arm_y_move_time" ) );
        }
    }

    if ( dist > 0 )
    {
        wait( getdvarfloat( "scr_crane_arm_y_move_time" ) / 2 );

        foreach ( arm in self.arms )
        {
            if ( arm.targetname == "claw_arm_y" )
            {
                arm moveto( arm.goal, 0.1 );
                self playsound( "amb_crane_arms_b" );
            }
        }

        wait 0.05;
        playfxontag( level._effect["crane_spark"], crate, "tag_origin" );
        self playsound( "amb_arms_latch" );
    }

    assert( arms.size == 4 );
    waittill_multiple_ents( arms[0], "movedone", arms[1], "movedone", arms[2], "movedone", arms[3], "movedone" );

    foreach ( arm in self.arms )
        arm.origin = arm.goal;

    self claw_link_arms( "claw_arm_y" );
}

claw_z_arms( z )
{
    claw_unlink_arms( "claw_arm_z" );
    arms = [];

    foreach ( arm in self.arms )
    {
        if ( arm.targetname == "claw_arm_z" )
        {
            arms[arms.size] = arm;
            arm movez( z, getdvarfloat( "scr_crane_arm_z_move_time" ) );
        }
    }

    assert( arms.size == 4 );
    waittill_multiple_ents( arms[0], "movedone", arms[1], "movedone", arms[2], "movedone", arms[3], "movedone" );
    self claw_link_arms( "claw_arm_z" );
}

crate_drop_think( claw )
{
    self endon( "claw_done" );
    self.disablefinalkillcam = 1;
    claw thread claw_drop_think();
    corpse_delay = 0;

    for (;;)
    {
        wait 0.2;
        entities = getdamageableentarray( self.origin, 200 );

        foreach ( entity in entities )
        {
            if ( !entity istouching( self.kill_trigger ) )
                continue;

            if ( isdefined( entity.model ) && entity.model == "t6_wpn_tac_insert_world" )
            {
                entity maps\mp\_tacticalinsertion::destroy_tactical_insertion();
                continue;
            }

            if ( !isalive( entity ) )
                continue;

            if ( isdefined( entity.targetname ) )
            {
                if ( entity.targetname == "talon" )
                {
                    entity notify( "death" );
                    continue;
                }
                else if ( entity.targetname == "rcbomb" )
                {
                    entity maps\mp\killstreaks\_rcbomb::rcbomb_force_explode();
                    continue;
                }
                else if ( entity.targetname == "riotshield_mp" )
                {
                    entity dodamage( 1, self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
                    continue;
                }
            }

            if ( isdefined( entity.helitype ) && entity.helitype == "qrdrone" )
            {
                watcher = entity.owner maps\mp\gametypes\_weaponobjects::getweaponobjectwatcher( "qrdrone" );
                watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( entity, 0.0, undefined );
                continue;
            }

            if ( entity.classname == "grenade" )
            {
                if ( !isdefined( entity.name ) )
                    continue;

                if ( !isdefined( entity.owner ) )
                    continue;

                if ( entity.name == "proximity_grenade_mp" )
                {
                    watcher = entity.owner getwatcherforweapon( entity.name );
                    watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( entity, 0.0, undefined, "script_mover_mp" );
                    continue;
                }

                if ( !isweaponequipment( entity.name ) )
                    continue;

                watcher = entity.owner getwatcherforweapon( entity.name );

                if ( !isdefined( watcher ) )
                    continue;

                watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( entity, 0.0, undefined, "script_mover_mp" );
                continue;
            }

            if ( entity.classname == "auto_turret" )
            {
                if ( !isdefined( entity.damagedtodeath ) || !entity.damagedtodeath )
                    entity domaxdamage( self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );

                continue;
            }

            entity dodamage( entity.health * 2, self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );

            if ( isplayer( entity ) )
            {
                claw thread claw_drop_pause();
                corpse_delay = gettime() + 3000;
            }
        }

        self destroy_supply_crates();

        if ( gettime() > corpse_delay )
            self destroy_corpses();

        if ( level.gametype == "ctf" )
        {
            foreach ( flag in level.flags )
            {
                if ( flag.visuals[0] istouching( self.kill_trigger ) )
                    flag maps\mp\gametypes\ctf::returnflag();
            }

            continue;
        }

        if ( level.gametype == "sd" && !level.multibomb )
        {
            if ( level.sdbomb.visuals[0] istouching( self.kill_trigger ) )
                level.sdbomb maps\mp\gametypes\_gameobjects::returnhome();
        }
    }
}

claw_drop_think()
{
    self endon( "claw_pause" );

    self waittill( "movedone" );

    self notify( "claw_movedone" );
}

claw_drop_pause()
{
    self notify( "claw_pause" );
    self endon( "claw_pause" );
    z_diff = abs( self.goal[2] - self.origin[2] );
    frac = z_diff / 318;
    time = self.time * frac;

    if ( time <= 0 )
        return;

    self moveto( self.origin, 0.01 );
    wait 3;
    self thread claw_drop_think();
    self moveto( self.goal, time );
}

destroy_supply_crates()
{
    crates = getentarray( "care_package", "script_noteworthy" );

    foreach ( crate in crates )
    {
        if ( distancesquared( crate.origin, self.origin ) < 40000 )
        {
            if ( crate istouching( self ) )
            {
                playfx( level._supply_drop_explosion_fx, crate.origin );
                playsoundatposition( "wpn_grenade_explode", crate.origin );
                wait 0.1;
                crate maps\mp\killstreaks\_supplydrop::cratedelete();
            }
        }
    }
}

destroy_corpses()
{
    corpses = getcorpsearray();

    for ( i = 0; i < corpses.size; i++ )
    {
        if ( distancesquared( corpses[i].origin, self.origin ) < 40000 )
            corpses[i] delete();
    }
}

getwatcherforweapon( weapname )
{
    if ( !isdefined( self ) )
        return undefined;

    if ( !isplayer( self ) )
        return undefined;

    for ( i = 0; i < self.weaponobjectwatcherarray.size; i++ )
    {
        if ( self.weaponobjectwatcherarray[i].weapon != weapname )
            continue;

        return self.weaponobjectwatcherarray[i];
    }

    return undefined;
}
