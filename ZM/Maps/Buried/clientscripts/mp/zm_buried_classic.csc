// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_weapons;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zombies\_zm_ai_ghost;
#include clientscripts\mp\zombies\_zm_ai_sloth;
#include clientscripts\mp\zm_buried_buildables;

precache()
{

}

premain()
{
    if ( is_gametype_active( "zclassic" ) )
    {
        level thread clientscripts\mp\zombies\_zm_ai_ghost::init();
        level thread clientscripts\mp\zombies\_zm_ai_sloth::init();
    }

    classicbuildables = array( "sq_common", "turbine", "springpad_zm", "subwoofer_zm", "headchopper_zm", "booze", "candy", "chalk", "sloth", "keys_zm", "buried_sq_oillamp", "buried_sq_tpo_switch", "buried_sq_ghost_lamp", "buried_sq_bt_m_tower", "buried_sq_bt_r_tower" );
    clientscripts\mp\zm_buried_buildables::include_buildables( classicbuildables );
    clientscripts\mp\zm_buried_buildables::init_buildables( classicbuildables );
    perk_vulture_custom_scripts();
    onplayerconnect_callback( ::teller_fx_setup );
}

main()
{

}

teller_fx_setup( clientnum )
{
    playfx( clientnum, level._effect["fx_buried_key_glint"], ( -300, -62, 55 ), ( 0, 0, 1 ) );
    playfx( clientnum, level._effect["fx_buried_key_glint"], ( -300, -314, 55 ), ( 0, 0, 1 ) );
}

#using_animtree("zm_buried_props");

init_jail_animtree()
{
    scriptmodelsuseanimtree( #animtree );
}

player_flashlight_test( localclientnum )
{

}

perk_vulture_custom_scripts()
{

}