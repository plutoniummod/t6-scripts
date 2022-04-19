// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_game_module_meat_utility;
#include maps\mp\zombies\_zm_game_module_meat;

init_item_meat()
{
    level.item_meat_name = "item_meat_zm";
    precacheitem( level.item_meat_name );
}

move_ring( ring )
{
    positions = getstructarray( ring.target, "targetname" );
    positions = array_randomize( positions );
    level endon( "end_game" );

    while ( true )
    {
        foreach ( position in positions )
        {
            self moveto( position.origin, randomintrange( 30, 45 ) );

            self waittill( "movedone" );
        }
    }
}

rotate_ring( forward )
{
    level endon( "end_game" );
    dir = -360;

    if ( forward )
        dir = 360;

    while ( true )
    {
        self rotateyaw( dir, 9 );
        wait 9;
    }
}
