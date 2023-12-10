// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\createfx\mp_hijacked_fx;
#include clientscripts\mp\_fx;

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_fire_candle"] = loadfx( "fire/fx_fire_candle" );
    level._effect["fx_mp_hijacked_jacuzzi_surface"] = loadfx( "maps/mp_maps/fx_mp_hijacked_jacuzzi_surface" );
    level._effect["fx_mp_hijacked_jacuzzi_steam"] = loadfx( "maps/mp_maps/fx_mp_hijacked_jacuzzi_steam" );
    level._effect["fx_raid_hot_tub_sm"] = loadfx( "water/fx_raid_hot_tub_sm" );
    level._effect["fx_mp_vent_heat_distort"] = loadfx( "maps/mp_maps/fx_mp_vent_heat_distort" );
    level._effect["fx_mp_vent_steam_sm"] = loadfx( "maps/mp_maps/fx_mp_vent_steam_sm" );
    level._effect["fx_water_shower_dribble_splsh"] = loadfx( "water/fx_water_shower_dribble_splsh" );
    level._effect["fx_water_shower_dribble"] = loadfx( "water/fx_water_shower_dribble" );
    level._effect["fx_light_beacon_red_blink_fst_sm"] = loadfx( "light/fx_light_beacon_red_blink_fst_sm" );
    level._effect["fx_light_flour_glow_v_shape_cool"] = loadfx( "light/fx_light_flour_glow_v_shape_cool" );
    level._effect["fx_light_flour_glow_v_shape_cool_sm"] = loadfx( "light/fx_light_flour_glow_v_shape_cool_sm" );
    level._effect["fx_light_recessed_cool_sm"] = loadfx( "light/fx_light_recessed_cool_sm" );
    level._effect["fx_light_recessed_cool_sm_soft"] = loadfx( "light/fx_light_recessed_cool_sm_soft" );
    level._effect["fx_lf_mp_hijacked_sun1"] = loadfx( "lens_flares/fx_lf_mp_hijacked_sun1" );
    level._effect["fx_paper_interior_short"] = loadfx( "debris/fx_paper_interior_short" );
    level._effect["fx_mp_fog_thin_sm"] = loadfx( "maps/mp_maps/fx_mp_fog_thin_sm" );
    level._effect["fx_mp_fog_thin_xsm"] = loadfx( "maps/mp_maps/fx_mp_fog_thin_xsm" );
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["dryer"] = %fxanim_gp_dryer_loop_anim;
    level.scr_anim["fxanim_props"]["seagull_circle_01"] = %fxanim_gp_seagull_circle_01_anim;
    level.scr_anim["fxanim_props"]["seagull_circle_02"] = %fxanim_gp_seagull_circle_02_anim;
    level.scr_anim["fxanim_props"]["seagull_circle_03"] = %fxanim_gp_seagull_circle_03_anim;
    level.scr_anim["fxanim_props"]["umbrella_01"] = %fxanim_gp_umbrella_01_anim;
}

main()
{
    clientscripts\mp\createfx\mp_hijacked_fx::main();
    clientscripts\mp\_fx::reportnumeffects();
    precache_createfx_fx();
    precache_fxanim_props();
    disablefx = getdvarint( _hash_C9B177D6 );

    if ( !isdefined( disablefx ) || disablefx <= 0 )
        precache_scripted_fx();
}
