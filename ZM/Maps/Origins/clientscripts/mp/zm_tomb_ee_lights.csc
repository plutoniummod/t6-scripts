// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_weapons;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\_filter;

main()
{
    registerclientfield( "world", "light_show", 14000, 2, "int", ::choose_light_show, 0 );
}

choose_light_show( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    switch ( newval )
    {
        case 1:
            level.light_on_color = vectorscale( ( 1, 1, 1 ), 2.0 );
            level.light_off_color = vectorscale( ( 1, 1, 1 ), 0.25 );
            break;
        case 2:
            level.light_on_color = ( 2.0, 0.1, 0.1 );
            level.light_off_color = ( 0.5, 0.1, 0.1 );
            break;
        case 3:
            level.light_on_color = ( 0.1, 2.0, 0.1 );
            level.light_off_color = ( 0.1, 0.5, 0.1 );
            break;
        default:
            level.light_on_color = undefined;
            level.light_off_color = undefined;
            break;
    }
}
