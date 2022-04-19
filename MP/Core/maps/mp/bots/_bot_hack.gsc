// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\gametypes\ctf;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bot;

bot_hack_tank_get_goal_origin( tank )
{
    nodes = getnodesinradiussorted( tank.origin, 256, 0, 64, "Path" );

    foreach ( node in nodes )
    {
        dir = vectornormalize( node.origin - tank.origin );
        dir = vectorscale( dir, 32 );
        goal = tank.origin + dir;

        if ( findpath( self.origin, goal, 0 ) )
            return goal;
    }

    return undefined;
}

bot_hack_has_goal( tank )
{
    goal = self getgoal( "hack" );

    if ( isdefined( goal ) )
    {
        if ( distancesquared( goal, tank.origin ) < 16384 )
            return true;
    }

    return false;
}

bot_hack_at_goal()
{
    if ( self atgoal( "hack" ) )
        return true;

    goal = self getgoal( "hack" );

    if ( isdefined( goal ) )
    {
        tanks = getentarray( "talon", "targetname" );
        tanks = arraysort( tanks, self.origin );

        foreach ( tank in tanks )
        {
            if ( distancesquared( goal, tank.origin ) < 16384 )
            {
                if ( isdefined( tank.trigger ) && self istouching( tank.trigger ) )
                    return true;
            }
        }
    }

    return false;
}

bot_hack_goal_pregame( tanks )
{
    foreach ( tank in tanks )
    {
        if ( isdefined( tank.owner ) )
            continue;

        if ( isdefined( tank.team ) && tank.team == self.team )
            continue;

        goal = self bot_hack_tank_get_goal_origin( tank );

        if ( isdefined( goal ) )
        {
            if ( self addgoal( goal, 24, 2, "hack" ) )
            {
                self.goal_flag = tank;
                return;
            }
        }
    }
}

bot_hack_think()
{
    if ( bot_hack_at_goal() )
    {
        self setstance( "crouch" );
        wait 0.25;
        self addgoal( self.origin, 24, 4, "hack" );
        self pressusebutton( level.drone_hack_time + 1 );
        wait( level.drone_hack_time + 1 );
        self setstance( "stand" );
        self cancelgoal( "hack" );
    }

    tanks = getentarray( "talon", "targetname" );
    tanks = arraysort( tanks, self.origin );

    if ( !is_true( level.drones_spawned ) )
        self bot_hack_goal_pregame( tanks );
    else
    {
        foreach ( tank in tanks )
        {
            if ( isdefined( tank.owner ) && tank.owner == self )
                continue;

            if ( !isdefined( tank.owner ) )
            {
                if ( self bot_hack_has_goal( tank ) )
                    return;

                goal = self bot_hack_tank_get_goal_origin( tank );

                if ( isdefined( goal ) )
                {
                    self addgoal( goal, 24, 2, "hack" );
                    return;
                }
            }

            if ( tank.isstunned && distancesquared( self.origin, tank.origin ) < 262144 )
            {
                goal = self bot_hack_tank_get_goal_origin( tank );

                if ( isdefined( goal ) )
                {
                    self addgoal( goal, 24, 3, "hack" );
                    return;
                }
            }
        }

        if ( !maps\mp\bots\_bot::bot_vehicle_weapon_ammo( "emp_grenade_mp" ) )
        {
            ammo = getentarray( "weapon_scavenger_item_hack_mp", "classname" );
            ammo = arraysort( ammo, self.origin );

            foreach ( bag in ammo )
            {
                if ( findpath( self.origin, bag.origin, 0 ) )
                {
                    self addgoal( bag.origin, 24, 2, "hack" );
                    return;
                }
            }

            return;
        }

        foreach ( tank in tanks )
        {
            if ( isdefined( tank.owner ) && tank.owner == self )
                continue;

            if ( tank.isstunned )
                continue;

            if ( self throwgrenade( "emp_grenade_mp", tank.origin ) )
            {
                self waittill( "grenade_fire" );

                goal = self bot_hack_tank_get_goal_origin( tank );

                if ( isdefined( goal ) )
                {
                    self addgoal( goal, 24, 3, "hack" );
                    wait 0.5;
                    return;
                }
            }
        }
    }
}
