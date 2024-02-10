// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\zombies\_clientfaceanim_zm;
#include clientscripts\mp\zombies\_callbacks;
#include clientscripts\mp\_utility_code;
#include clientscripts\mp\_global_fx;
#include clientscripts\mp\_music;
#include clientscripts\mp\_footsteps;
#include clientscripts\mp\_sticky_grenade;
#include clientscripts\_radiant_live_update;
#include clientscripts\mp\_ambient;

levelnotifyhandler( clientnum, state, oldstate )
{
    if ( state != "" )
        level notify( state, clientnum );
}

default_flag_change_handler( localclientnum, flag, set, newent )
{
    action = "SET";

    if ( !set )
        action = "CLEAR";

    clientscripts\mp\zombies\_callbacks::client_flag_debug( "*** DEFAULT client_flag_callback to " + action + "  flag " + flag + " - for ent " + self getentitynumber() + "[" + self.type + "]" );
}

setup_default_client_flag_callbacks()
{
    level._client_flag_callbacks = [];
    level._client_flag_callbacks["vehicle"] = [];
    level._client_flag_callbacks["player"] = [];
    level._client_flag_callbacks["actor"] = [];
    level._client_flag_callbacks["NA"] = ::default_flag_change_handler;
    level._client_flag_callbacks["general"] = ::default_flag_change_handler;
    level._client_flag_callbacks["missile"] = [];
    level._client_flag_callbacks["scriptmover"] = [];
    level._client_flag_callbacks["helicopter"] = [];
    level._client_flag_callbacks["turret"] = [];
    level._client_flag_callbacks["plane"] = [];
    level._client_flag_callbacks["missile"][9] = clientscripts\mp\zombies\_callbacks::stunned_callback;
    level._client_flag_callbacks["missile"][15] = clientscripts\mp\zombies\_callbacks::emp_callback;
    level._client_flag_callbacks["missile"][4] = clientscripts\mp\zombies\_callbacks::proximity_callback;
    level._client_flag_callbacks["scriptmover"][9] = clientscripts\mp\zombies\_callbacks::stunned_callback;
    level._client_flag_callbacks["scriptmover"][15] = clientscripts\mp\zombies\_callbacks::emp_callback;
}

warnmissilelocking( localclientnum, set )
{

}

warnmissilelocked( localclientnum, set )
{

}

warnmissilefired( localclientnum, set )
{

}

main()
{
    level thread clientscripts\mp\_utility::servertime();
    level thread clientscripts\mp\_utility::initutility();
    clientscripts\mp\_utility_code::struct_class_init();
    clientscripts\mp\_utility::registersystem( "levelNotify", ::levelnotifyhandler );
    level.createfx_enabled = getdvar( #"createfx" ) != "";
    level.createfx_disable_fx = getdvarint( #"disable_fx" ) == 1;
    clientscripts\mp\_global_fx::main();
    level thread clientscripts\mp\_ambientpackage::init();
    level thread clientscripts\mp\_music::music_init();
    level thread clientscripts\mp\_footsteps::init();

    if ( !is_false( level._uses_sticky_grenades ) )
        level thread clientscripts\mp\_sticky_grenade::main();

    level thread clientscripts\mp\zombies\_clientfaceanim_zm::init_clientfaceanim();
/#
    level thread clientscripts\_radiant_live_update::main();
#/
    level thread parse_structs();

    if ( getdvar( #"r_reflectionProbeGenerate" ) == "1" )
        return;

    if ( !isps3() )
        setdvar( "cg_enableHelicopterNoCullLodOut", 1 );
}

parse_structs()
{
    for ( i = 0; i < level.struct.size; i++ )
    {
        if ( isdefined( level.struct[i].targetname ) )
        {
            if ( level.struct[i].targetname == "flak_fire_fx" )
            {
                fx_id = "flak20_fire_fx";
                level._effect["flak20_fire_fx"] = loadfx( "weapon/tracer/fx_tracer_flak_single_noExp" );
                level._effect["flak38_fire_fx"] = loadfx( "weapon/tracer/fx_tracer_quad_20mm_Flak38_noExp" );
                level._effect["flak_cloudflash_night"] = loadfx( "weapon/flak/fx_flak_cloudflash_night" );
                level._effect["flak_burst_single"] = loadfx( "weapon/flak/fx_flak_single_day_dist" );
                level thread clientscripts\mp\_ambient::setup_point_fx( level.struct[i], fx_id );
            }

            if ( level.struct[i].targetname == "fake_fire_fx" )
            {
                fx_id = "distant_muzzleflash";
                level._effect["distant_muzzleflash"] = loadfx( "weapon/muzzleflashes/heavy" );
                level thread clientscripts\mp\_ambient::setup_point_fx( level.struct[i], fx_id );
            }

            if ( level.struct[i].targetname == "dog_bark_fx" )
            {
                fx_id = undefined;
                level thread clientscripts\mp\_ambient::setup_point_fx( level.struct[i], fx_id );
            }

            if ( level.struct[i].targetname == "spotlight_fx" )
            {
                fx_id = "spotlight_beam";
                level._effect["spotlight_beam"] = loadfx( "env/light/fx_ray_spotlight_md" );
                level thread clientscripts\mp\_ambient::setup_point_fx( level.struct[i], fx_id );
            }
        }
    }
}
