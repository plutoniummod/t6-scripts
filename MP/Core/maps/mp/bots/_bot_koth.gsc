// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\gametypes\koth;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bot;
#include maps\mp\bots\_bot_combat;

bot_koth_think()
{
    if ( !isdefined( level.zone.trig.goal_radius ) )
    {
        maxs = level.zone.trig getmaxs();
        maxs = level.zone.trig.origin + maxs;
        level.zone.trig.goal_radius = distance( level.zone.trig.origin, maxs );
/#
        println( "distance: " + level.zone.trig.goal_radius );
#/
        ground = bullettrace( level.zone.gameobject.curorigin, level.zone.gameobject.curorigin - vectorscale( ( 0, 0, 1 ), 1024.0 ), 0, undefined );
        level.zone.trig.goal = ground["position"] + vectorscale( ( 0, 0, 1 ), 8.0 );
    }

    if ( !bot_has_hill_goal() )
        self bot_move_to_hill();

    if ( self bot_is_at_hill() )
        self bot_capture_hill();

    bot_hill_tactical_insertion();
    bot_hill_grenade();
}

bot_has_hill_goal()
{
    origin = self getgoal( "koth_hill" );

    if ( isdefined( origin ) )
    {
        if ( distance2dsquared( level.zone.gameobject.curorigin, origin ) < level.zone.trig.goal_radius * level.zone.trig.goal_radius )
            return true;
    }

    return false;
}

bot_is_at_hill()
{
    return self atgoal( "koth_hill" );
}

bot_move_to_hill()
{
    if ( gettime() < self.bot.update_objective + 4000 )
        return;

    self clearlookat();
    self cancelgoal( "koth_hill" );

    if ( self getstance() == "prone" )
    {
        self setstance( "crouch" );
        wait 0.25;
    }

    if ( self getstance() == "crouch" )
    {
        self setstance( "stand" );
        wait 0.25;
    }

    nodes = getnodesinradiussorted( level.zone.trig.goal, level.zone.trig.goal_radius, 0, 128 );

    foreach ( node in nodes )
    {
        if ( self maps\mp\bots\_bot::bot_friend_goal_in_radius( "koth_hill", node.origin, 64 ) == 0 )
        {
            if ( findpath( self.origin, node.origin, self, 0, 1 ) )
            {
                self addgoal( node, 24, 3, "koth_hill" );
                self.bot.update_objective = gettime();
                return;
            }
        }
    }
}

bot_get_look_at()
{
    enemy = self maps\mp\bots\_bot::bot_get_closest_enemy( self.origin, 1 );

    if ( isdefined( enemy ) )
    {
        node = getvisiblenode( self.origin, enemy.origin );

        if ( isdefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
            return node.origin;
    }

    enemies = self maps\mp\bots\_bot::bot_get_enemies( 0 );

    if ( enemies.size )
        enemy = random( enemies );

    if ( isdefined( enemy ) )
    {
        node = getvisiblenode( self.origin, enemy.origin );

        if ( isdefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
            return node.origin;
    }

    spawn = random( level.spawnpoints );
    node = getvisiblenode( self.origin, spawn.origin );

    if ( isdefined( node ) && distancesquared( self.origin, node.origin ) > 1024 )
        return node.origin;

    return level.zone.gameobject.curorigin;
}

bot_capture_hill()
{
    self addgoal( self.origin, 24, 3, "koth_hill" );
    self setstance( "crouch" );

    if ( gettime() > self.bot.update_lookat )
    {
        origin = self bot_get_look_at();
        z = 20;

        if ( distancesquared( origin, self.origin ) > 262144 )
            z = randomintrange( 16, 60 );

        self lookat( origin + ( 0, 0, z ) );

        if ( distancesquared( origin, self.origin ) > 65536 )
        {
            dir = vectornormalize( self.origin - origin );
            dir = vectorscale( dir, 256 );
            origin += dir;
        }

        self maps\mp\bots\_bot_combat::bot_combat_throw_proximity( origin );

        if ( cointoss() && lengthsquared( self getvelocity() ) < 2 )
        {
            nodes = getnodesinradius( level.zone.trig.goal, level.zone.trig.goal_radius + 128, 0, 128 );

            for ( i = randomintrange( 0, nodes.size ); i < nodes.size; i++ )
            {
                node = nodes[i];

                if ( distancesquared( node.origin, self.origin ) > 1024 )
                {
                    if ( self maps\mp\bots\_bot::bot_friend_goal_in_radius( "koth_hill", node.origin, 128 ) == 0 )
                    {
                        if ( findpath( self.origin, node.origin, self, 0, 1 ) )
                        {
                            self addgoal( node, 24, 3, "koth_hill" );
                            self.bot.update_objective = gettime();
                            break;
                        }
                    }
                }
            }
        }

        self.bot.update_lookat = gettime() + randomintrange( 1500, 3000 );
    }
}

any_other_team_touching( skip_team )
{
    foreach ( team in level.teams )
    {
        if ( team == skip_team )
            continue;

        if ( level.zone.gameobject.numtouching[team] )
            return true;
    }

    return false;
}

is_hill_contested( skip_team )
{
    if ( any_other_team_touching( skip_team ) )
        return true;

    enemy = self maps\mp\bots\_bot::bot_get_closest_enemy( level.zone.gameobject.curorigin, 1 );

    if ( isdefined( enemy ) && distancesquared( enemy.origin, level.zone.gameobject.curorigin ) < 262144 )
        return true;

    return false;
}

bot_hill_grenade()
{
    enemies = bot_get_enemies();

    if ( !enemies.size )
        return;

    if ( self atgoal( "hill_patrol" ) || self atgoal( "koth_hill" ) )
    {
        if ( self getweaponammostock( "proximity_grenade_mp" ) > 0 )
        {
            origin = bot_get_look_at();

            if ( self maps\mp\bots\_bot_combat::bot_combat_throw_proximity( origin ) )
                return;
        }
    }

    if ( !is_hill_contested( self.team ) )
    {
        if ( !isdefined( level.next_smoke_time ) )
            level.next_smoke_time = 0;

        if ( gettime() > level.next_smoke_time )
        {
            if ( self maps\mp\bots\_bot_combat::bot_combat_throw_smoke( level.zone.gameobject.curorigin ) )
                level.next_smoke_time = gettime() + randomintrange( 60000, 120000 );
        }

        return;
    }

    enemy = self maps\mp\bots\_bot::bot_get_closest_enemy( level.zone.gameobject.curorigin, 0 );

    if ( isdefined( enemy ) )
        origin = enemy.origin;
    else
        origin = level.zone.gameobject.curorigin;

    dir = vectornormalize( self.origin - origin );
    dir = ( 0, dir[1], 0 );
    origin += vectorscale( dir, 128 );

    if ( maps\mp\bots\_bot::bot_get_difficulty() == "easy" )
    {
        if ( !isdefined( level.next_grenade_time ) )
            level.next_grenade_time = 0;

        if ( gettime() > level.next_grenade_time )
        {
            if ( !self maps\mp\bots\_bot_combat::bot_combat_throw_lethal( origin ) )
                self maps\mp\bots\_bot_combat::bot_combat_throw_tactical( origin );
            else
                level.next_grenade_time = gettime() + randomintrange( 60000, 120000 );
        }
    }
    else if ( !self maps\mp\bots\_bot_combat::bot_combat_throw_lethal( origin ) )
        self maps\mp\bots\_bot_combat::bot_combat_throw_tactical( origin );
}

bot_hill_tactical_insertion()
{
    if ( !self hasweapon( "tactical_insertion_mp" ) )
        return;

    dist = self getlookaheaddist();
    dir = self getlookaheaddir();

    if ( !isdefined( dist ) || !isdefined( dir ) )
        return;

    node = hill_nearest_node();
    mine = getnearestnode( self.origin );

    if ( isdefined( mine ) && !nodesvisible( mine, node ) )
    {
        origin = self.origin + vectorscale( dir, dist );
        next = getnearestnode( origin );

        if ( isdefined( next ) && nodesvisible( next, node ) )
            bot_combat_tactical_insertion( self.origin );
    }
}

hill_nearest_node()
{
    nodes = getnodesinradiussorted( level.zone.gameobject.curorigin, 256, 0 );
    assert( nodes.size );
    return nodes[0];
}
