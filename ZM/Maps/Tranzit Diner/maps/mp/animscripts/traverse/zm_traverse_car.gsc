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
        }

        asm_endswitch( 8 case run loc_18A case run_slide loc_18A case sprint loc_194 case sprint_slide loc_194 case super_sprint loc_194 case walk loc_180 case walk_slide loc_180 default loc_19E );
    }

    dosimpletraverse( "traverse_car" + speed, 1 );
}
