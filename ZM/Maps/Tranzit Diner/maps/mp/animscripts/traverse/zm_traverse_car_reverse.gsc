// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\traverse\shared;
#include maps\mp\animscripts\traverse\zm_shared;

main()
{
    speed = "";

    if ( !self.has_legs )
    {
        switch ( self.zombie_move_speed )
        {
            case "super_sprint":
            case "sprint_slide":
            case "sprint":
                speed = "_sprint";
                break;
            default:
        }
    }

    dosimpletraverse( "traverse_car_reverse" + speed, 1 );
}
