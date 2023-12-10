// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_weapons;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zombies\_zm;
#include clientscripts\mp\zombies\_zm_game_mode_objects;

precache()
{

}

main()
{
    level thread clientscripts\mp\zombies\_zm::init_perk_machines_fx();
    clientscripts\mp\zombies\_zm_game_mode_objects::gamemode_common_setup( "standard", "town", "zm_transit_town_ext", 1 );
    level thread dog_start_monitor();
    level thread dog_stop_monitor();
}

dog_start_monitor()
{
    while ( true )
    {
        level waittill( "dog_start" );
        players = getlocalplayers();

        for ( i = 0; i < players.size; i++ )
            setworldfogactivebank( i, 2 );
    }
}

dog_stop_monitor()
{
    while ( true )
    {
        level waittill( "dog_stop" );

        if ( !isdefined( level.current_fog ) )
            level.current_fog = 8;

        players = getlocalplayers();

        for ( i = 0; i < players.size; i++ )
            setworldfogactivebank( i, level.current_fog );
    }
}
