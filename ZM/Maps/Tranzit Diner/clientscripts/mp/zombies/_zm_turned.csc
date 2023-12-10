// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_fx;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\_filter;
#include clientscripts\mp\_visionset_mgr;
#include clientscripts\mp\zombies\_zm;
#include clientscripts\mp\zombies\_face_utility_zm;

precache()
{
    if ( getdvar( #"createfx" ) == "on" )
        return;

    if ( is_true( level._zm_turned_precached ) )
        return;

    level._zm_turned_precached = 1;
    level.face_override_func = turned_face_override_func();
    clientscripts\mp\_visionset_mgr::vsmgr_register_visionset_info( "zm_turned", 3000, 1, "zm_turned", "zm_turned" );
    registerclientfield( "toplayer", "turned_ir", 3000, 1, "int", ::zombie_turned_ir, 0, 1 );
    registerclientfield( "allplayers", "player_has_eyes", 3000, 1, "int", clientscripts\mp\zombies\_zm::player_eyes_clientfield_cb, 0 );
    registerclientfield( "allplayers", "player_eyes_special", 5000, 1, "int", clientscripts\mp\zombies\_zm::player_eye_color_clientfield_cb, 0 );
    level._effect["player_eye_glow_blue"] = loadfx( "maps/zombie/fx_zombie_eye_returned_blue" );
    level._effect["player_eye_glow_orng"] = loadfx( "maps/zombie/fx_zombie_eye_returned_orng" );
    setdvar( "aim_target_player_enabled", 1 );
}

#using_animtree("zombie_player");

turned_face_override_func()
{
    level.face_anim_tree = "zombie_player";
    self clientscripts\mp\zombies\_face_utility_zm::setfaceroot( %head );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "face_casual", 1, -1, 0, "basestate", array( %pf_casual_idle ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "face_alert", 1, -1, 0, "basestate", array( %pf_alert_idle ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "face_shoot", 1, 1, 1, "eventstate", array( %pf_firing ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "face_shoot_single", 1, 1, 1, "eventstate", array( %pf_firing ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "face_melee", 1, 2, 1, "eventstate", array( %pf_melee ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "face_pain", 0, -1, 2, "eventstate", array( %pf_pain ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "face_death", 0, -1, 2, "exitstate", array( %pf_death ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "zombie_face_casual", 1, -1, 0, "basestate", array( %f_idle_zombie_v1, %f_idle_zombie_v2, %f_idle_zombie_v3, %f_idle_zombie_v4, %f_idle_zombie_v5 ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "zombie_face_alert", 1, -1, 0, "basestate", array( %f_locomotion_zombie_v1, %f_locomotion_zombie_v2, %f_locomotion_zombie_v3, %f_locomotion_zombie_v4, %f_locomotion_zombie_v5 ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "zombie_face_melee", 1, 2, 1, "eventstate", array( %f_attack_zombie_v1, %f_attack_zombie_v2, %f_attack_zombie_v3, %f_attack_zombie_v4, %f_attack_zombie_v5 ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "zombie_face_death", 0, -1, 2, "exitstate", array( %f_death_zombie_v1, %f_death_zombie_v2, %f_death_zombie_v3, %f_death_zombie_v4, %f_death_zombie_v5 ) );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "face_advance", 0, -1, 3, "nullstate", array() );
    self clientscripts\mp\zombies\_face_utility_zm::buildfacestate( "zombie_face_advance", 0, -1, 3, "nullstate", array() );
}

init()
{
    var = getdvar( #"ui_gametype" );

    if ( var == "zcleansed" )
        precache();
}

main()
{
    if ( getdvar( #"createfx" ) == "on" )
        return;

    setup_zombie_exerts();

    if ( isdemoplaying() )
        thread zombie_turned_demo_ir();
}

zombie_turned_set_ir( lcn, newval )
{
    if ( newval )
    {
        setlutscriptindex( lcn, 2 );
        enable_filter_zm_turned( self, 0, 0 );
        self setsonarattachmentenabled( 1 );
    }
    else
    {
        setlutscriptindex( lcn, 0 );
        disable_filter_zm_turned( self, 0, 0 );
        self setsonarattachmentenabled( 0 );
    }
}

zombie_turned_ir( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( !self islocalplayer() )
        return;

    if ( !isdefined( self getlocalclientnumber() ) )
        return;

    if ( self getlocalclientnumber() != localclientnum )
        return;

    self.is_player_zombie = newval;

    if ( isdemoplaying() && isspectating( localclientnum ) )
        newval = 0;

    zombie_turned_set_ir( localclientnum, newval );
}

zombie_turned_demo_ir()
{
    lcn = 0;

    while ( true )
    {
        assert( isdemoplaying() );

        if ( getlocalplayer( lcn ).is_player_zombie )
            getlocalplayer( lcn ) zombie_turned_set_ir( lcn, !isspectating( lcn ) );

        wait 0.05;
    }
}

setup_zombie_exerts()
{
    level.exert_sounds[1]["playerbreathinsound"] = "null";
    level.exert_sounds[1]["playerbreathoutsound"] = "null";
    level.exert_sounds[1]["playerbreathgaspsound"] = "null";
    level.exert_sounds[1]["falldamage"] = "null";
    level.exert_sounds[1]["mantlesoundplayer"] = "null";
    level.exert_sounds[1]["meleeswipesoundplayer"] = "vox_exert_generic_zombieswipe";
    level.exert_sounds[1]["dtplandsoundplayer"] = "null";
}