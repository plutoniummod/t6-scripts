// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\traverse\shared;
#include maps\mp\animscripts\traverse\zm_shared;

main()
{
    traversestate = "zm_traverse_barrier";
    traversealias = "barrier_walk";

    if ( self.has_legs )
    {
        switch ( self.zombie_move_speed )
        {
            case "walk_slide":
            case "walk":
            case "low_gravity_walk":
                traversealias = "barrier_walk";
                break;
            case "run_slide":
            case "run":
            case "low_gravity_run":
                traversealias = "barrier_run";
                break;
            case "super_sprint":
            case "sprint_slide":
            case "sprint":
            case "low_gravity_sprint":
                traversealias = "barrier_sprint";
                break;
            default:
                if ( isdefined( level.zm_mantle_over_40_move_speed_override ) )
                    traversealias = self [[ level.zm_mantle_over_40_move_speed_override ]]();
                else
                {
/#
                    assertmsg( "Zombie '" + self.classname + "' move speed of '" + self.zombie_move_speed + "' is not supported for mantle_over_40." );
#/
                }
        }
    }
    else
    {
        traversestate = "zm_traverse_barrier_crawl";
        traversealias = "barrier_crawl";
    }

    self dotraverse( traversestate, traversealias );
}
