// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\createfx\mp_raid_fx;
#include clientscripts\mp\_fx;

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_mp_light_dust_motes_md"] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
    level._effect["fx_mp_raid_mist"] = loadfx( "maps/mp_maps/fx_mp_raid_mist" );
    level._effect["fx_insects_swarm_lg_light"] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
    level._effect["fx_insects_butterfly_flutter"] = loadfx( "bio/insects/fx_insects_butterfly_flutter" );
    level._effect["fx_mp_fumes_vent_xsm_int"] = loadfx( "maps/mp_maps/fx_mp_fumes_vent_xsm_int" );
    level._effect["fx_mp_raid_mist_water"] = loadfx( "maps/mp_maps/fx_mp_raid_mist_water" );
    level._effect["fx_paper_interior_short"] = loadfx( "debris/fx_paper_interior_short" );
    level._effect["fx_mp_raid_vista_smoke01"] = loadfx( "maps/mp_maps/fx_mp_raid_vista_smoke01" );
    level._effect["fx_mp_raid_vista_fire01"] = loadfx( "maps/mp_maps/fx_mp_raid_vista_fire01" );
    level._effect["fx_mp_slums_dark_smoke_sm"] = loadfx( "maps/mp_maps/fx_mp_slums_dark_smoke_sm" );
    level._effect["fx_mp_slums_fire_sm"] = loadfx( "maps/mp_maps/fx_mp_slums_fire_sm" );
    level._effect["fx_mp_slums_fire_lg"] = loadfx( "maps/mp_maps/fx_mp_slums_fire_lg" );
    level._effect["fx_mp_slums_dark_smoke"] = loadfx( "maps/mp_maps/fx_mp_slums_dark_smoke" );
    level._effect["fx_mp_village_car_smoke"] = loadfx( "maps/mp_maps/fx_mp_village_car_smoke" );
    level._effect["fx_raid_hot_tub_sm"] = loadfx( "water/fx_raid_hot_tub_sm" );
    level._effect["fx_raid_hot_tub_lg"] = loadfx( "water/fx_raid_hot_tub_lg" );
    level._effect["fx_light_beacon_red_blink_fst"] = loadfx( "light/fx_light_beacon_red_blink_fst" );
    level._effect["fx_light_god_ray_mp_raid"] = loadfx( "env/light/fx_light_god_ray_mp_raid" );
    level._effect["fx_raid_spot_light"] = loadfx( "light/fx_raid_spot_light" );
    level._effect["fx_mp_nightclub_flr_glare"] = loadfx( "maps/mp_maps/fx_mp_nightclub_flr_glare" );
    level._effect["fx_raid_spot_light_picture"] = loadfx( "light/fx_raid_spot_light_picture" );
    level._effect["fx_light_recessed_cool_sm_soft"] = loadfx( "light/fx_light_recessed_cool_sm_soft" );
    level._effect["fx_lf_mp_raid_sun1"] = loadfx( "lens_flares/fx_lf_mp_raid_sun1" );
}

main()
{
    clientscripts\mp\createfx\mp_raid_fx::main();
    clientscripts\mp\_fx::reportnumeffects();
    precache_createfx_fx();
    precache_fxanim_props();
    disablefx = getdvarint( _hash_C9B177D6 );

    if ( !isdefined( disablefx ) || disablefx <= 0 )
        precache_scripted_fx();
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["umbrella"] = %fxanim_gp_umbrella_01_anim;
    level.scr_anim["fxanim_props"]["dryer_loop"] = %fxanim_gp_dryer_loop_anim;
}
