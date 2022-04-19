// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_events;
#include maps\mp\_tacticalinsertion;
#include maps\mp\killstreaks\_rcbomb;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\gametypes\ctf;
#include maps\mp\gametypes\_gameobjects;
#include maps\mp\killstreaks\_supplydrop;

init()
{
    precachevehicle( "express_train_engine_mp" );
    precachemodel( "p6_bullet_train_car_phys" );
    precachemodel( "p6_bullet_train_engine_rev" );
    precacheshader( "compass_train_carriage" );
    precachestring( &"traincar" );
    precachestring( &"trainengine" );
    gates = getentarray( "train_gate_rail", "targetname" );
    brushes = getentarray( "train_gate_rail_brush", "targetname" );
    triggers = getentarray( "train_gate_kill_trigger", "targetname" );
    traintriggers = getentarray( "train_kill_trigger", "targetname" );

    foreach ( brush in brushes )
        brush disconnectpaths();

    waittime = 0.05;

    foreach ( gate in gates )
    {
        gate.waittime = waittime;
        waittime += 0.05;
        gate.og_origin = gate.origin;
        brush = getclosest( gate.origin, brushes );
        brush linkto( gate );
        gate.kill_trigger = getclosest( gate.origin, triggers );

        if ( isdefined( gate.kill_trigger ) )
        {
            gate.kill_trigger enablelinkto();
            gate.kill_trigger linkto( gate );
        }
    }

    start = getvehiclenode( "train_start", "targetname" );
    endgates = getentarray( "train_gate_rail_end", "targetname" );
    entrygate = getclosest( start.origin, endgates );

    for ( i = 0; i < endgates.size; i++ )
    {
        if ( endgates[i] == entrygate )
            continue;

        exitgate = endgates[i];
        break;
    }

    cars = [];
    cars[0] = spawnvehicle( "p6_bullet_train_engine_phys", "train", "express_train_engine_mp", start.origin, ( 0, 0, 0 ) );
    cars[0] ghost();
    cars[0] setcheapflag( 1 );

    foreach ( traintrigger in traintriggers )
    {
        cars[0].trainkilltrigger = traintrigger;
        traintrigger.origin = start.origin;
        traintrigger enablelinkto();
        traintrigger linkto( cars[0] );
    }

    for ( i = 1; i < 20; i++ )
    {
        cars[i] = spawn( "script_model", start.origin );
        cars[i] setmodel( "p6_bullet_train_car_phys" );
        cars[i] ghost();
        cars[i] setcheapflag( 1 );
    }

    cars[20] = spawn( "script_model", start.origin );
    cars[20] setmodel( "p6_bullet_train_engine_rev" );
    cars[20] ghost();
    cars[20] setcheapflag( 1 );

    if ( level.timelimit )
    {
        seconds = level.timelimit * 60;
        add_timed_event( int( seconds * 0.25 ), "train_start" );
        add_timed_event( int( seconds * 0.75 ), "train_start" );
    }
    else if ( level.scorelimit )
    {
        add_score_event( int( level.scorelimit * 0.25 ), "train_start" );
        add_score_event( int( level.scorelimit * 0.75 ), "train_start" );
    }

    level thread train_think( gates, entrygate, exitgate, cars, start );
}

showaftertime( time )
{
    wait( time );
    self show();
}

train_think( gates, entrygate, exitgate, cars, start )
{
    level endon( "game_ended" );

    for (;;)
    {
        level waittill( "train_start" );

        entrygate gate_move( -172 );
        traintiming = getdvarfloatdefault( "scr_express_trainTiming", 4.0 );
        exitgate thread waitthenmove( traintiming, -172 );
        array_func( gates, ::gate_move, -172 );

        foreach ( gate in gates )
        {
            gate playloopsound( "amb_train_incomming_beep" );
            gate playsound( "amb_gate_move" );
        }

        gatedownwait = getdvarintdefault( "scr_express_gateDownWait", 2 );
        wait( gatedownwait );

        foreach ( gate in gates )
            gate stoploopsound( 2 );

        wait 2;
        cars[0] attachpath( start );

        if ( isdefined( cars[0].trainkilltrigger ) )
            cars[0] thread train_move_think( cars[0].trainkilltrigger );

        cars[0] startpath();
        cars[0] showaftertime( 0.2 );
        cars[0] thread record_positions();
        cars[0] thread watch_end();
        cars[0] playloopsound( "amb_train_lp" );
        cars[0] setclientfield( "train_moving", 1 );
        next = "_b";

        for ( i = 1; i < cars.size; i++ )
        {
            if ( i == 1 )
                wait 0.4;
            else
                wait 0.35;

            if ( i >= 3 && i % 3 == 0 )
            {
                cars[i] playloopsound( "amb_train_lp" + next );

                switch ( next )
                {
                    case "_b":
                        next = "_c";
                        break;
                    case "_c":
                        next = "_d";
                        break;
                    case "_d":
                        next = "";
                        break;
                    default:
                        next = "_b";
                        break;
                }
            }

            cars[i] thread watch_player_touch();

            if ( i == cars.size - 1 )
            {
                cars[i] thread car_move();
                continue;
            }

            cars[i] thread car_move();
        }

        traintiming = getdvarfloatdefault( "scr_express_trainTiming2", 2.0 );
        entrygate thread waitthenmove( traintiming );
        gateupwait = getdvarfloatdefault( "scr_express_gateUpWait", 6.5 );
        wait( gateupwait );
        exitgate gate_move();
        array_func( gates, ::gate_move );

        foreach ( gate in gates )
            gate playsound( "amb_gate_move" );

        wait 6;
    }
}

waitthenmove( time, distance )
{
    wait( time );
    self gate_move( distance );
}

record_positions()
{
    self endon( "reached_end_node" );

    if ( isdefined( level.train_positions ) )
        return;

    level.train_positions = [];
    level.train_angles = [];

    for (;;)
    {
        level.train_positions[level.train_positions.size] = self.origin;
        level.train_angles[level.train_angles.size] = self.angles;
        wait 0.05;
    }
}

watch_player_touch()
{
    self endon( "end_of_track" );
    self endon( "delete" );
    self endon( "death" );

    for (;;)
    {
        self waittill( "touch", entity );

        if ( isplayer( entity ) )
            entity dodamage( entity.health * 2, self.origin + ( 0, 0, 1 ), self, self, 0, "MOD_CRUSH" );
    }
}

watch_end()
{
    self waittill( "reached_end_node" );

    self ghost();
    self setclientfield( "train_moving", 0 );
    self stoploopsound( 0.2 );
    self playsound( "amb_train_end" );
}

car_move()
{
    self setclientfield( "train_moving", 1 );

    for ( i = 0; i < level.train_positions.size; i++ )
    {
        self.origin = level.train_positions[i];
        self.angles = level.train_angles[i];
        wait 0.05;

        if ( i == 4 )
            self show();
    }

    self notify( "end_of_track" );
    self ghost();
    self setclientfield( "train_moving", 0 );
    self stoploopsound( 0.2 );
    self playsound( "amb_train_end" );
}

gate_rotate( yaw )
{
    self rotateyaw( yaw, 5 );
}

gate_move( z_dist )
{
    if ( isdefined( self.kill_trigger ) )
        self thread gate_move_think( isdefined( z_dist ) );

    if ( !isdefined( z_dist ) )
        self moveto( self.og_origin, 5 );
    else
    {
        self.og_origin = self.origin;
        self movez( z_dist, 5 );
    }
}

train_move_think( kill_trigger )
{
    self endon( "movedone" );

    for (;;)
    {
        wait 0.05;
        pixbeginevent( "train_move_think" );
        entities = getdamageableentarray( self.origin, 200 );

        foreach ( entity in entities )
        {
            if ( isdefined( entity.targetname ) && entity.targetname == "train" )
                continue;

            if ( isplayer( entity ) )
                continue;

            if ( !entity istouching( kill_trigger ) )
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
        }

        self destroy_supply_crates();

        if ( level.gametype == "ctf" )
        {
            foreach ( flag in level.flags )
            {
                if ( flag.curorigin != flag.trigger.baseorigin && flag.visuals[0] istouching( kill_trigger ) )
                    flag maps\mp\gametypes\ctf::returnflag();
            }
        }
        else if ( level.gametype == "sd" && !level.multibomb )
        {
            if ( level.sdbomb.visuals[0] istouching( kill_trigger ) )
                level.sdbomb maps\mp\gametypes\_gameobjects::returnhome();
        }

        pixendevent();
    }
}

gate_move_think( ignoreplayers )
{
    self endon( "movedone" );
    corpse_delay = 0;

    if ( isdefined( self.waittime ) )
        wait( self.waittime );

    for (;;)
    {
        wait 0.4;
        pixbeginevent( "gate_move_think" );
        entities = getdamageableentarray( self.origin, 100 );

        foreach ( entity in entities )
        {
            if ( ignoreplayers == 1 && isplayer( entity ) )
                continue;

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
        }
        else if ( level.gametype == "sd" && !level.multibomb )
        {
            if ( level.sdbomb.visuals[0] istouching( self.kill_trigger ) )
                level.sdbomb maps\mp\gametypes\_gameobjects::returnhome();
        }

        pixendevent();
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

destroy_supply_crates()
{
    crates = getentarray( "care_package", "script_noteworthy" );

    foreach ( crate in crates )
    {
        if ( distancesquared( crate.origin, self.origin ) < 10000 )
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
        if ( distancesquared( corpses[i].origin, self.origin ) < 10000 )
            corpses[i] delete();
    }
}
