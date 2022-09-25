// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\gametypes\dom;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bot_combat;
#include maps\mp\bots\_bot;

bot_dom_think()
{
    time = gettime();

    if ( time < self.bot.update_objective )
        return;

    self.bot.update_objective = time + randomintrange( 500, 1500 );

    if ( self bot_is_capturing_flag() )
    {
        flag = self dom_get_closest_flag();
        self bot_capture_flag( flag );
        return;
    }

    flag = self dom_get_closest_flag();

    if ( flag getflagteam() != self.team && distance2dsquared( self.origin, flag.origin ) < 147456 && !bot_has_flag_goal( flag ) )
    {
        self bot_move_to_flag( flag );
        return;
    }

    flag = dom_get_weighted_flag( "neutral" );

    if ( !isdefined( flag ) )
        flag = dom_get_best_flag( self.team );

    if ( dom_has_two_flags( self.team ) )
        flag = dom_get_best_flag( self.team );

    if ( !isdefined( flag ) )
        return;

    if ( !bot_has_flag_goal( flag ) && !self bot_goal_is_enemy_flag() )
        self bot_move_to_flag( flag );
    else
    {
        if ( !dom_is_game_start() )
            self bot_flag_grenade( flag );

        if ( distancesquared( self.origin, flag.origin ) < flag.radius * flag.radius && self istouching( flag.useobj.trigger ) )
            self bot_capture_flag( flag );
    }
}

bot_move_to_flag( flag )
{
    if ( level.script == "mp_frostbite" )
        nodes = getnodesinradius( flag.origin, flag.radius, 0, 32 );
    else
        nodes = getnodesinradius( flag.origin, flag.radius, 0 );

    assert( nodes.size );
    node = random( nodes );
    self addgoal( node, 24, 3, "dom_flag" );
}

bot_is_capturing_flag()
{
    return self atgoal( "dom_flag" );
}

bot_has_flag_goal( flag )
{
    origin = self getgoal( "dom_flag" );

    if ( isdefined( origin ) )
    {
        if ( distancesquared( flag.origin, origin ) < flag.radius * flag.radius )
            return true;
    }

    return false;
}

bot_has_no_goal()
{
    origin = self getgoal( "dom_flag" );

    if ( isdefined( origin ) )
        return false;

    return true;
}

bot_goal_is_enemy_flag()
{
    origin = self getgoal( "dom_flag" );

    if ( isdefined( origin ) )
    {
        foreach ( flag in level.flags )
        {
            if ( distancesquared( flag.origin, origin ) < flag.radius * flag.radius )
            {
                if ( flag getflagteam() != self.team || dom_is_flag_contested( flag ) )
                    return true;
            }
        }
    }

    return false;
}

bot_flag_grenade( flag )
{
    if ( flag getflagteam() != self.team )
    {
        if ( bot_tactical_insertion( flag ) )
            return;

        self maps\mp\bots\_bot_combat::bot_combat_throw_smoke( flag.origin );
    }

    if ( !dom_is_flag_contested( flag ) )
        return;

    if ( !self maps\mp\bots\_bot_combat::bot_combat_throw_lethal( flag.origin ) )
    {
        if ( !self maps\mp\bots\_bot_combat::bot_combat_throw_tactical( flag.origin ) )
            self maps\mp\bots\_bot_combat::bot_combat_throw_proximity( flag.origin );
    }
}

bot_get_look_at( flag )
{
    enemy = self maps\mp\bots\_bot::bot_get_closest_enemy( self.origin, 0 );

    if ( isdefined( enemy ) )
    {
        node = getvisiblenode( self.origin, enemy.origin );

        if ( isdefined( node ) && distancesquared( self.origin, node.origin ) > 16384 )
            return node.origin;
    }

    spawn = random( level.spawn_all );
    node = getvisiblenode( self.origin, spawn.origin );

    if ( isdefined( node ) && distancesquared( self.origin, node.origin ) > 16384 )
        return node.origin;

    return flag.origin;
}

bot_capture_flag( flag )
{
    time = gettime();

    if ( flag getflagteam() != self.team )
    {
        if ( self getstance() == "prone" )
            self addgoal( self.origin, 24, 4, "dom_flag" );
        else
            self addgoal( self.origin, 24, 3, "dom_flag" );

        if ( time > self.bot.update_lookat )
        {
            origin = self bot_get_look_at( flag );
            z = 20;

            if ( distancesquared( origin, self.origin ) > 262144 )
                z = randomintrange( 16, 60 );

            self lookat( origin + ( 0, 0, z ) );
            self.bot.update_lookat = time + randomintrange( 1500, 3000 );

            if ( distancesquared( origin, self.origin ) > 65536 )
            {
                dir = vectornormalize( self.origin - origin );
                dir = vectorscale( dir, 256 );
                origin += dir;
            }

            self maps\mp\bots\_bot_combat::bot_combat_throw_proximity( origin );
            self maps\mp\bots\_bot_combat::bot_combat_toss_frag( self.origin );
            self maps\mp\bots\_bot_combat::bot_combat_toss_flash( self.origin );

            if ( !dom_is_game_start() )
            {
                weapon = self getcurrentweapon();

                if ( weapon == "riotshield_mp" || weapon == "minigun_mp" )
                {
                    if ( cointoss() )
                    {
                        self addgoal( self.origin, 24, 4, "dom_flag" );
                        self setstance( "crouch" );
                    }
                }
                else if ( cointoss() && !bot_friend_in_radius( self.origin, 384 ) )
                {
                    self addgoal( self.origin, 24, 4, "dom_flag" );
                    wait( randomfloatrange( 0.5, 1 ) );
                    self setstance( "prone" );
                    self.bot.update_lookat += 5000;
                }
            }
        }
        else if ( !dom_is_game_start() )
        {
            if ( self getstance() == "stand" )
            {
                wait( randomfloatrange( 0.5, 1 ) );
                self setstance( "crouch" );
            }
        }
    }
    else
    {
        self clearlookat();
        self cancelgoal( "dom_flag" );

        if ( self getstance() == "crouch" )
        {
            self setstance( "stand" );
            wait 0.25;
        }
        else if ( self getstance() == "prone" )
        {
            self setstance( "crouch" );
            wait 0.25;
            self setstance( "stand" );
            wait 0.25;
        }
    }
}

dom_is_game_start()
{
    assert( isdefined( level.flags ) );

    foreach ( flag in level.flags )
    {
        if ( flag getflagteam() != "neutral" )
            return false;
    }

    return true;
}

dom_get_closest_flag()
{
    flags = arraysort( level.flags, self.origin );
    return flags[0];
}

dom_get_weighted_flag( owner )
{
    assert( isdefined( level.flags ) );
    best = undefined;
    distsq = 9999999;

    foreach ( flag in level.flags )
    {
        if ( isdefined( owner ) && flag getflagteam() != owner )
            continue;

        d = distancesquared( self.origin, flag.origin );

        if ( distsq == 9999999 || d < distsq && randomint( 100 ) < 70 || randomint( 100 ) > 70 )
        {
            best = flag;
            distsq = d;
        }
    }

    return best;
}

dom_get_weighted_enemy_flag( team )
{
    assert( isdefined( level.flags ) );
    best = undefined;
    distsq = 9999999;

    foreach ( flag in level.flags )
    {
        if ( flag getflagteam() == team )
            continue;

        d = distancesquared( self.origin, flag.origin );

        if ( distsq == 9999999 || d < distsq && randomint( 100 ) < 80 || randomint( 100 ) > 80 )
        {
            best = flag;
            distsq = d;
        }
    }

    return best;
}

dom_is_flag_contested( flag )
{
    enemy = self maps\mp\bots\_bot::bot_get_closest_enemy( flag.origin, 0 );
    return isdefined( enemy ) && distancesquared( enemy.origin, flag.origin ) < 147456;
}

dom_has_two_flags( team )
{
    count = 0;

    foreach ( flag in level.flags )
    {
        if ( dom_is_flag_contested( flag ) )
            continue;

        if ( flag getflagteam() == team )
            count++;
    }

    return count >= 2;
}

dom_get_weighted_contested_flag( team )
{
    assert( isdefined( level.flags ) );
    best = undefined;
    distsq = 9999999;

    foreach ( flag in level.flags )
    {
        if ( !dom_is_flag_contested( flag ) )
            continue;

        d = distancesquared( self.origin, flag.origin );

        if ( distsq == 9999999 || d < distsq && randomint( 100 ) < 80 || randomint( 100 ) > 80 )
        {
            best = flag;
            distsq = d;
        }
    }

    return best;
}

dom_get_random_flag( owner )
{
    assert( isdefined( level.flags ) );
    flagindex = randomintrange( 0, level.flags.size );

    if ( !isdefined( owner ) )
        return level.flags[flagindex];

    for ( i = 0; i < level.flags.size; i++ )
    {
        if ( level.flags[flagindex] getflagteam() == owner )
            return level.flags[flagindex];

        flagindex = ( flagindex + 1 ) % level.flags.size;
    }

    return undefined;
}

dom_get_best_flag( team )
{
    flag1 = dom_get_weighted_enemy_flag( team );
    flag2 = dom_get_weighted_contested_flag( team );

    if ( !isdefined( flag1 ) )
        return flag2;

    if ( !isdefined( flag2 ) )
        return flag1;

    offchance = randomint( 100 ) > 80;

    if ( distancesquared( self.origin, flag1.origin ) < distancesquared( self.origin, flag2.origin ) )
    {
        if ( !offchance )
            return flag1;
        else
            return flag2;
    }

    if ( !offchance )
        return flag2;
    else
        return flag1;
}

bot_tactical_insertion( flag )
{
    if ( self getweaponammostock( "tactical_insertion_mp" ) <= 0 )
        return 0;

    dist = self getlookaheaddist();
    dir = self getlookaheaddir();

    if ( !isdefined( dist ) || !isdefined( dir ) )
        return 0;

    node = bot_nearest_node( flag.origin );
    mine = bot_nearest_node( self.origin );

    if ( isdefined( mine ) && !nodesvisible( mine, node ) )
    {
        origin = self.origin + vectorscale( dir, dist );
        next = bot_nearest_node( origin );

        if ( next isdangerous( self.team ) )
            return 0;

        if ( isdefined( next ) && nodesvisible( next, node ) )
            return bot_combat_tactical_insertion( self.origin );
    }

    return 0;
}
