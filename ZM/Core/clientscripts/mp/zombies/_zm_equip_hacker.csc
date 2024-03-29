// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_fx;
#include clientscripts\mp\zombies\_zm_equipment;

init()
{
    if ( getdvar( #"createfx" ) == "on" )
        return;

    if ( !clientscripts\mp\zombies\_zm_equipment::is_equipment_included( "equip_hacker_zm" ) )
        return;

    level thread player_init();
}

player_init()
{
    waitforclient( 0 );
    players = getlocalplayers();

    for ( i = 0; i < players.size; i++ )
        player = players[i];
}
