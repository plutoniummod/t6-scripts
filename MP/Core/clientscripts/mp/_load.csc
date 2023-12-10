// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_ambientpackage;
#include clientscripts\mp\_clientfaceanim_mp;
#include clientscripts\mp\_callbacks;
#include clientscripts\mp\_helicopter_sounds;
#include clientscripts\mp\_utility_code;
#include clientscripts\mp\_global_fx;
#include clientscripts\mp\_busing;
#include clientscripts\mp\_music;
#include clientscripts\mp\_dogs;
#include clientscripts\mp\_ctf;
#include clientscripts\mp\_claymore;
#include clientscripts\mp\_bouncingbetty;
#include clientscripts\mp\_trophy_system;
#include clientscripts\mp\_counteruav;
#include clientscripts\mp\_tacticalinsertion;
#include clientscripts\mp\_riotshield;
#include clientscripts\mp\_satchel_charge;
#include clientscripts\mp\_missile_drone;
#include clientscripts\mp\_explosive_bolt;
#include clientscripts\mp\_sticky_grenade;
#include clientscripts\mp\_proximity_grenade;
#include clientscripts\mp\_explode;
#include clientscripts\mp\_rewindobjects;
#include clientscripts\mp\_fxanim;
#include clientscripts\mp\_helicopter;
#include clientscripts\mp\_footsteps;
#include clientscripts\mp\_turret;
#include clientscripts\mp\_remotemissile;
#include clientscripts\mp\_planemortar;
#include clientscripts\mp\_destructible;
#include clientscripts\_radiant_live_update;
#include clientscripts\mp\_vehicle;
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

    clientscripts\mp\_callbacks::client_flag_debug( "*** DEFAULT client_flag_callback to " + action + "  flag " + flag + " - for ent " + self getentitynumber() + "[" + self.type + "]" );
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
    level._client_flag_callbacks["missile"][9] = clientscripts\mp\_callbacks::stunned_callback;
    level._client_flag_callbacks["missile"][15] = clientscripts\mp\_callbacks::emp_callback;
    level._client_flag_callbacks["missile"][4] = clientscripts\mp\_callbacks::proximity_callback;
    level._client_flag_callbacks["scriptmover"][9] = clientscripts\mp\_callbacks::stunned_callback;
    level._client_flag_callbacks["scriptmover"][15] = clientscripts\mp\_callbacks::emp_callback;
}

warnmissilelocking( localclientnum, set )
{
    if ( set && !self islocalplayerviewlinked( localclientnum ) )
        return;

    clientscripts\mp\_helicopter_sounds::play_targeted_sound( set );
}

warnmissilelocked( localclientnum, set )
{
    if ( set && !self islocalplayerviewlinked( localclientnum ) )
        return;

    clientscripts\mp\_helicopter_sounds::play_locked_sound( set );
}

warnmissilefired( localclientnum, set )
{
    if ( set && !self islocalplayerviewlinked( localclientnum ) )
        return;

    clientscripts\mp\_helicopter_sounds::play_fired_sound( set );
}

main()
{
    level thread clientscripts\mp\_utility::servertime();
    level thread clientscripts\mp\_utility::initutility();
    clientscripts\mp\_utility_code::struct_class_init();
    clientscripts\mp\_utility::registersystem( "levelNotify", ::levelnotifyhandler );
    level.createfx_enabled = getdvar( #"createfx" ) != "";
    level.createfx_disable_fx = getdvarint( #"_id_C9B177D6" ) == 1;
    setdvar( "tu6_player_shallowWaterHeight", "0.0" );
    setdvar( "tu7_cg_deathCamAboveWater", "0" );
    setdvar( "tu12_cg_vehicleCamAboveWater", "0" );
    setdvar( "bg_plantInWaterDepth", "5" );

    if ( !sessionmodeiszombiesgame() )
    {
        setup_default_client_flag_callbacks();
        setdvar( "r_exposureTweak", "0" );
        setsaveddvar( "sm_sunsamplesizenear", 0.5 );
        setsaveddvar( "sm_sunshadowsmall", 0 );
        setsaveddvar( "r_lightGridEnableTweaks", 0 );
        setsaveddvar( "r_lightGridIntensity", 1 );
        setsaveddvar( "r_lightGridContrast", 0 );
        setsaveddvar( "compassmaxrange", "2500" );
    }

    clientscripts\mp\_global_fx::main();

    if ( !sessionmodeiszombiesgame() )
    {
        level thread clientscripts\mp\_ambientpackage::init();
        level thread clientscripts\mp\_busing::businit();
        level thread clientscripts\mp\_music::music_init();
        level thread clientscripts\mp\_dogs::init();
        level thread clientscripts\mp\_ctf::init();
        level thread clientscripts\mp\_claymore::init();
        level thread clientscripts\mp\_bouncingbetty::init();
        level thread clientscripts\mp\_trophy_system::init();
        level thread clientscripts\mp\_counteruav::init();
        level thread clientscripts\mp\_tacticalinsertion::init();
        level thread clientscripts\mp\_riotshield::init();
        level thread clientscripts\mp\_satchel_charge::init();
        level thread clientscripts\mp\_missile_drone::init();
        level thread clientscripts\mp\_explosive_bolt::main();
        level thread clientscripts\mp\_sticky_grenade::main();
        level thread clientscripts\mp\_proximity_grenade::main();
        level thread clientscripts\mp\_explode::main();
        level thread clientscripts\mp\_rewindobjects::init_rewind();
        level thread clientscripts\mp\_fxanim::init();
        level thread clientscripts\mp\_helicopter::init();
        level thread clientscripts\mp\_helicopter_sounds::init();
        level thread clientscripts\mp\_footsteps::init();
        level thread clientscripts\mp\_turret::init();
        level thread clientscripts\mp\_remotemissile::init();
        level thread clientscripts\mp\_planemortar::init();
    }
    else
    {
        level thread clientscripts\mp\_ambientpackage::init();
        level thread clientscripts\mp\_music::music_init();
        level thread clientscripts\mp\_footsteps::init();
        level thread clientscripts\mp\_sticky_grenade::main();
        level thread clientscripts\mp\_clientfaceanim_mp::init_clientfaceanim();
    }

    level thread clientscripts\mp\_destructible::init();
/#
    level thread clientscripts\_radiant_live_update::main();
#/
    level thread parse_structs();

    if ( getdvar( #"r_reflectionProbeGenerate" ) == "1" )
        return;

    if ( !sessionmodeiszombiesgame() )
        clientscripts\mp\_vehicle::init_vehicles();

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
