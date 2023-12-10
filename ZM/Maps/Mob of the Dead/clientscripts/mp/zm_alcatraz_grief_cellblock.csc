// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_weapons;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zombies\_zm_game_mode_objects;
#include clientscripts\mp\zombies\_zm;

precache()
{

}

main()
{
    level thread init_perk_machines_fx();
    clientscripts\mp\zombies\_zm_game_mode_objects::gamemode_common_setup( "zgrief", "cellblock", "default", 1 );
    setteamreviveicon( "allies", "waypoint_revive_guards" );
    setteamreviveicon( "axis", "waypoint_revive_inmates" );
    level notify( "zgrief_cellblock", 0 );
    a_players = getlocalplayers();

    for ( i = 0; i < a_players.size; i++ )
    {
        m_master_key_attachment = getent( i, "master_key_attachment", "targetname" );
        m_master_key_attachment delete();
        m_dryer = getent( i, "dryer_model", "targetname" );
        m_dryer delete();
    }
}

init_perk_machines_fx()
{
    if ( !level.enable_magic )
        return;

    wait 0.1;
    level._effect["sleight_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
    level._effect["doubletap_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
    level._effect["jugger_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
    level._effect["additionalprimaryweapon_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
    level._effect["divetonuke_light"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
    level thread clientscripts\mp\zombies\_zm::perk_start_up();
}
