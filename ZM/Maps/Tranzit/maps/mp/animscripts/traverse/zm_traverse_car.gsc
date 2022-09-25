// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\traverse\shared;
#include maps\mp\animscripts\traverse\zm_shared;

main()
{
    speed = "";

    if ( !isdefined( self.isdog ) || !self.isdog )
    {
        switch ( self.zombie_move_speed )
        {
            case "walk_slide":
            case "walk":
                speed = "";
                break;
            case "run_slide":
            case "run":
                speed = "_run";
                break;
            case "super_sprint":
            case "sprint_slide":
            case "sprint":
                speed = "_sprint";
                break;
            default:
        }
    }

    dosimpletraverse( "traverse_car" + speed, 1 );
}
