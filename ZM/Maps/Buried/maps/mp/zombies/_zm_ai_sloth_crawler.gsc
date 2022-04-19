// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_ai_sloth_utility;
#include maps\mp\zombies\_zm_ai_sloth;
#include maps\mp\animscripts\zm_run;
#include maps\mp\animscripts\zm_shared;

crawler_condition()
{
    zombies = get_round_enemy_array();

    for ( i = 0; i < zombies.size; i++ )
    {
        zombie = zombies[i];

        if ( !is_true( zombie.has_legs ) )
        {
            dist = distancesquared( self.origin, zombie.origin );

            if ( dist < 32400 )
            {
                self.crawler = zombie;

                if ( isdefined( level.sloth.custom_crawler_pickup_func ) )
                    self.crawler thread [[ level.sloth.custom_crawler_pickup_func ]]();

                return true;
            }
        }
    }

    return false;
}

crawler_action()
{
    self endon( "death" );
    self endon( "stop_action" );
    self maps\mp\zombies\_zm_ai_sloth::common_context_action();
    self thread watch_sloth_on_exit_side();
    self thread watch_sloth_on_same_side();
    self thread crawler_watch_death();
    self.release_crawler = 0;
    anim_id = self getanimfromasd( "zm_sloth_pickup_crawler", 0 );
    sloth_goal = getstartorigin( self.crawler.origin, self.crawler.angles, anim_id );
    sloth_offset = distance( sloth_goal, self.crawler.origin );

    while ( true )
    {
        if ( self sloth_is_traversing() )
        {
            wait 0.1;
            continue;
        }

        vec_forward = vectornormalize( anglestoforward( self.crawler.angles ) );
        start_pos = self.crawler.origin - vec_forward * sloth_offset;
        raised_start_pos = ( start_pos[0], start_pos[1], start_pos[2] + sloth_offset );
        ground_pos = groundpos( raised_start_pos );
        height_check = abs( self.crawler.origin[2] - ground_pos[2] );

        if ( height_check > 8 )
            self setanimstatefromasd( "zm_player_idle" );
        else
        {
            self maps\mp\animscripts\zm_run::needsupdate();
            self setgoalpos( start_pos );
        }

        if ( !isdefined( self.crawler ) || self.crawler.health <= 0 )
        {
            self.context_done = 1;
            return;
        }

        dist = distancesquared( self.origin, start_pos );
        z_dist = abs( self.origin[2] - start_pos[2] );

        if ( dist < 1024 && z_dist < 12 )
            break;

        wait 0.1;
    }

    self orientmode( "face angle", self.crawler.angles[1] );
    wait 0.25;
    self.crawler.is_inert = 1;
    self.crawler.ignoreall = 1;
    self.crawler notify( "stop_find_flesh" );
    self.crawler notify( "zombie_acquire_enemy" );
    self.anchor.origin = self.crawler.origin;
    self.anchor.angles = self.crawler.angles;
    sloth_pickup = self append_hunched( "zm_sloth_pickup_crawler" );
    crawler_pickup = self append_hunched( "zm_crawler_pickup_by_sloth" );
    self animscripted( self.anchor.origin, self.anchor.angles, sloth_pickup );
    self.crawler animscripted( self.anchor.origin, self.anchor.angles, crawler_pickup );
    maps\mp\animscripts\zm_shared::donotetracks( "sloth_pickup_crawler_anim" );
    self.carrying_crawler = 1;
    self.crawler.guts_explosion = 1;
    self.pre_traverse = ::crawler_pre_traverse;
    self.post_traverse = ::crawler_post_traverse;
    self.crawler notsolid();
    self.crawler linkto( self, "tag_weapon_right" );
    self.ignore_common_run = 1;
    self set_zombie_run_cycle( "walk_crawlerhold" );
    self.locomotion = "walk_crawlerhold";
    self.setanimstatefromspeed = ::slothanimstatefromspeed;
    self.crawler_end = gettime() + 5000;
    self.crawler.actor_damage_func = ::crawler_damage_func;
    self.sloth_damage_func = ::crawler_damage_func;
    roam = array_randomize( level.roam_points );
    roam_index = 0;

    while ( true )
    {
        if ( is_true( self.release_crawler ) )
            break;

        if ( self sloth_is_traversing() )
        {
            wait 0.1;
            continue;
        }

        dist = distancesquared( self.origin, self.candy_player.origin );

        if ( dist < 25600 || is_true( self.candy_player.is_in_ghost_zone ) && is_true( self.on_exit_side ) )
        {
            self.check_turn = 1;
            self setgoalpos( self.origin );
            sloth_idle = self append_hunched( "zm_sloth_crawlerhold_idle" );
            crawler_idle = self append_hunched( "zm_crawler_crawlerhold_idle" );
            self animscripted( self.origin, self.angles, sloth_idle );
            self.crawler animscripted( self.origin, self.angles, crawler_idle );
        }
        else
        {
            self stopanimscripted();
            self.crawler stopanimscripted();

            if ( should_ignore_candybooze( self.candy_player ) )
            {
                dist = distancesquared( self.origin, roam[roam_index].origin );

                if ( dist < 1024 )
                {
                    roam_index++;

                    if ( roam_index >= roam.size )
                        roam_index = 0;
                }

                self maps\mp\zombies\_zm_ai_sloth::sloth_check_turn( roam[roam_index].origin );
                self setgoalpos( roam[roam_index].origin );
            }
            else if ( !self sloth_move_to_same_side() )
            {
                if ( is_true( self.check_turn ) )
                {
                    self.check_turn = 0;

                    if ( self sloth_is_same_zone( self.candy_player ) )
                        self maps\mp\zombies\_zm_ai_sloth::sloth_check_turn( self.candy_player.origin, -0.965 );
                }

                self setgoalpos( self.candy_player.origin );
            }

            self crawler_update_locomotion();
        }

        wait 0.1;
    }

    self.setanimstatefromspeed = undefined;
    self.crawler unlink();
    sloth_putdown = self append_hunched( "zm_sloth_putdown_crawler" );
    crawler_putdown = self append_hunched( "zm_crawler_putdown_by_sloth" );
    self animscripted( self.origin, self.angles, sloth_putdown );
    self.crawler animscripted( self.origin, self.angles, crawler_putdown );
    maps\mp\animscripts\zm_shared::donotetracks( "sloth_putdown_crawler_anim" );
    self.carrying_crawler = 0;
    self.crawler.deathfunction = ::crawler_death;
    sloth_kill = self append_hunched( "zm_sloth_kill_crawler_stomp" );
    crawler_kill = self append_hunched( "zm_crawler_slothkill_stomp" );
    self notify( "stop_crawler_watch" );
    self animscripted( self.origin, self.angles, sloth_kill );
    self.crawler animscripted( self.origin, self.angles, crawler_kill );
    maps\mp\animscripts\zm_shared::donotetracks( "sloth_kill_crawler_anim" );

    if ( isdefined( self.crawler ) )
    {
        self.crawler dodamage( self.crawler.health * 10, self.crawler.origin );
        self.crawler playsound( "zmb_ai_sloth_attack_impact" );
    }

    self.sloth_damage_func = undefined;
    self maps\mp\zombies\_zm_ai_sloth::sloth_set_traverse_funcs();
    self.crawler = undefined;
    self.context_done = 1;
}

watch_sloth_on_exit_side()
{
    self endon( "death" );

    while ( true )
    {
        if ( is_true( self.context_done ) )
            return;

        self.on_exit_side = 0;
        player = self.candy_player;

        if ( isdefined( player ) && is_true( player.is_in_ghost_zone ) )
        {
            name = player.current_ghost_room_name;

            if ( isdefined( name ) )
            {
                room = level.ghost_rooms[name];

                if ( is_true( room.to_maze ) )
                {
                    if ( self maps\mp\zombies\_zm_ai_sloth::sloth_behind_mansion() )
                        self.on_exit_side = 1;
                }
                else if ( is_true( room.from_maze ) )
                {
                    if ( !self maps\mp\zombies\_zm_ai_sloth::sloth_behind_mansion() )
                        self.on_exit_side = 1;
                }
            }
        }

        wait 0.25;
    }
}

watch_sloth_on_same_side()
{
    self endon( "death" );

    while ( true )
    {
        if ( is_true( self.context_done ) )
            return;

        self.on_same_side = 0;
        player = self.candy_player;

        if ( isdefined( player ) )
        {
            if ( self maps\mp\zombies\_zm_ai_sloth::sloth_behind_mansion() )
            {
                if ( player maps\mp\zombies\_zm_ai_sloth::behind_mansion_zone() )
                    self.on_same_side = 1;
            }
            else if ( !player maps\mp\zombies\_zm_ai_sloth::behind_mansion_zone() )
                self.on_same_side = 1;
        }

        wait 0.25;
    }
}

sloth_move_to_same_side()
{
    self endon( "death" );

    if ( isdefined( self.teleport_time ) )
    {
        if ( gettime() - self.teleport_time < 1000 )
            return false;
    }

    player = self.candy_player;

    if ( is_true( player.is_in_ghost_zone ) )
    {
        if ( is_true( self.on_exit_side ) )
            return false;
    }
    else if ( is_true( self.on_same_side ) )
        return false;

    if ( self maps\mp\zombies\_zm_ai_sloth::sloth_behind_mansion() )
        self maps\mp\zombies\_zm_ai_sloth::action_navigate_mansion( level.courtyard_depart, level.courtyard_arrive );
    else
        self maps\mp\zombies\_zm_ai_sloth::action_navigate_mansion( level.maze_depart, level.maze_arrive );

    return true;
}

sloth_is_same_zone( player )
{
    zone_sloth = self get_current_zone();
    zone_player = player get_current_zone();

    if ( !isdefined( zone_sloth ) || !isdefined( zone_player ) )
        return false;

    if ( zone_sloth == zone_player )
        return true;

    return false;
}

append_hunched( asd_name )
{
    if ( self.is_inside )
        return asd_name + "_hunched";

    return asd_name;
}

crawler_update_locomotion()
{
    if ( self.zombie_move_speed == "walk_crawlerhold" )
    {
        if ( self.is_inside )
        {
            self set_zombie_run_cycle( "walk_crawlerhold_hunched" );
            self.locomotion = "walk_crawlerhold_hunched";
        }
    }
    else if ( self.zombie_move_speed == "walk_crawlerhold_hunched" )
    {
        if ( !self.is_inside )
        {
            self set_zombie_run_cycle( "walk_crawlerhold" );
            self.locomotion = "walk_crawlerhold";
        }
    }
}

crawler_watch_death()
{
    self endon( "stop_crawler_watch" );

    self.crawler waittill( "death" );

    self stop_action();
/#
    sloth_print( "crawler died" );
#/
    if ( isdefined( self.crawler ) )
        self.crawler unlink();

    self.setanimstatefromspeed = undefined;
    self.sloth_damage_func = undefined;
    self maps\mp\zombies\_zm_ai_sloth::sloth_set_traverse_funcs();
    self.crawler = undefined;
    self.context_done = 1;
}

crawler_pre_traverse()
{
    sloth_sling = self append_hunched( "zm_sloth_crawlerhold_sling" );
    crawler_sling = self append_hunched( "zm_crawler_sloth_crawlerhold_sling" );
    self setanimstatefromasd( sloth_sling );
    self.crawler setanimstatefromasd( crawler_sling );
    self maps\mp\animscripts\zm_shared::donotetracks( "sloth_crawlerhold_sling_anim" );
    self.crawler thread crawler_traverse_idle();
}

crawler_traverse_idle()
{
    self endon( "death" );
    self endon( "stop_traverse_idle" );

    while ( true )
    {
        self setanimstatefromasd( "zm_crawler_sloth_crawlerhold_slung_idle" );
        wait 0.1;
    }
}

crawler_post_traverse()
{
    self.crawler notify( "stop_traverse_idle" );
    sloth_unsling = self append_hunched( "zm_sloth_crawlerhold_unsling" );
    crawler_unsling = self append_hunched( "zm_crawler_sloth_crawlerhold_unsling" );
    self setanimstatefromasd( sloth_unsling );
    self.crawler setanimstatefromasd( crawler_unsling );
    self maps\mp\animscripts\zm_shared::donotetracks( "sloth_crawlerhold_unsling_anim" );
}

crawler_death()
{
    return 1;
}

crawler_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    level.sloth.release_crawler = 1;
    return 0;
}

is_crawler_alive()
{
    if ( isdefined( self.crawler ) && self.crawler.health > 0 )
        return true;

    return false;
}

slothanimstatefromspeed( animstate, substate )
{
    if ( isdefined( self.crawler ) )
    {
        crawler_walk = "zm_crawler_crawlerhold_walk";

        if ( self.is_inside )
            crawler_walk += "_hunched";

        self.crawler setanimstatefromasd( crawler_walk );
    }
}
