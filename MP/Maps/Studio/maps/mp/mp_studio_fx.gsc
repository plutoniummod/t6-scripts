// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\createfx\mp_studio_fx;

main()
{
    precache_fxanim_props();
    precache_fxanim_props_dlc();
    precache_scripted_fx();
    precache_createfx_fx();
    maps\mp\createfx\mp_studio_fx::main();
}

precache_scripted_fx()
{

}

precache_createfx_fx()
{
    level._effect["fx_mp_express_train_blow_dust"] = loadfx( "maps/mp_maps/fx_mp_express_train_blow_dust" );
    level._effect["fx_mp_village_grass"] = loadfx( "maps/mp_maps/fx_mp_village_grass" );
    level._effect["fx_insects_swarm_lg_light"] = loadfx( "bio/insects/fx_insects_swarm_lg_light" );
    level._effect["fx_mp_debris_papers"] = loadfx( "maps/mp_maps/fx_mp_debris_papers" );
    level._effect["fx_mp_studio_dust_ledge_runner"] = loadfx( "maps/mp_maps/fx_mp_studio_dust_ledge_runner" );
    level._effect["fx_sand_moving_in_air_pcloud"] = loadfx( "dirt/fx_sand_moving_in_air_pcloud" );
    level._effect["fx_mp_light_dust_motes_md"] = loadfx( "maps/mp_maps/fx_mp_light_dust_motes_md" );
    level._effect["fx_mp_studio_fog"] = loadfx( "maps/mp_maps/fx_mp_studio_fog" );
    level._effect["fx_mp_studio_fog_ground"] = loadfx( "maps/mp_maps/fx_mp_studio_fog_ground" );
    level._effect["fx_mp_studio_fog_background"] = loadfx( "maps/mp_maps/fx_mp_studio_fog_background" );
    level._effect["fx_mp_studio_rolling_fog"] = loadfx( "maps/mp_maps/fx_mp_studio_rolling_fog" );
    level._effect["fx_mp_studio_fog_machine"] = loadfx( "maps/mp_maps/fx_mp_studio_fog_machine" );
    level._effect["fx_mp_studio_fog_sm"] = loadfx( "maps/mp_maps/fx_mp_studio_fog_sm" );
    level._effect["fx_mp_slums_dark_smoke_sm"] = loadfx( "maps/mp_maps/fx_mp_slums_dark_smoke_sm" );
    level._effect["fx_smk_smolder_gray_slow_shrt"] = loadfx( "smoke/fx_smk_smolder_gray_slow_shrt" );
    level._effect["fx_smk_smolder_gray_slow_dark"] = loadfx( "smoke/fx_smk_smolder_gray_slow_dark" );
    level._effect["fx_mp_studio_ufo_fire"] = loadfx( "maps/mp_maps/fx_mp_studio_ufo_fire" );
    level._effect["fx_mp_studio_ufo_smoke"] = loadfx( "maps/mp_maps/fx_mp_studio_ufo_smoke" );
    level._effect["fx_mp_studio_fire_md"] = loadfx( "maps/mp_maps/fx_mp_studio_fire_md" );
    level._effect["fx_mp_studio_smoke_vista"] = loadfx( "maps/mp_maps/fx_mp_studio_smoke_vista" );
    level._effect["fx_mp_studio_smoke_ground"] = loadfx( "maps/mp_maps/fx_mp_studio_smoke_ground" );
    level._effect["fx_mp_studio_smoke_area"] = loadfx( "maps/mp_maps/fx_mp_studio_smoke_area" );
    level._effect["fx_mp_studio_smoke_area_sm"] = loadfx( "maps/mp_maps/fx_mp_studio_smoke_area_sm" );
    level._effect["fx_mp_studio_toy_fire"] = loadfx( "maps/mp_maps/fx_mp_studio_toy_fire" );
    level._effect["fx_mp_studio_torch"] = loadfx( "maps/mp_maps/fx_mp_studio_torch" );
    level._effect["fx_mp_studio_sci_fire_burst_runner"] = loadfx( "maps/mp_maps/fx_mp_studio_sci_fire_burst_runner" );
    level._effect["fx_mp_studio_muzzle_tank_sm"] = loadfx( "maps/mp_maps/fx_mp_studio_muzzle_tank_sm" );
    level._effect["fx_mp_studio_sci_fire"] = loadfx( "maps/mp_maps/fx_mp_studio_sci_fire" );
    level._effect["fx_mp_studio_ufo_electric_runner"] = loadfx( "maps/mp_maps/fx_mp_studio_ufo_electric_runner" );
    level._effect["fx_mp_studio_electric_fence"] = loadfx( "maps/mp_maps/fx_mp_studio_electric_fence" );
    level._effect["fx_mp_studio_spark_sm_runner"] = loadfx( "maps/mp_maps/fx_mp_studio_spark_sm_runner" );
    level._effect["fx_mp_studio_water_dock_splash"] = loadfx( "maps/mp_maps/fx_mp_studio_water_dock_splash" );
    level._effect["fx_mp_studio_water_splash_runner"] = loadfx( "maps/mp_maps/fx_mp_studio_water_splash_runner" );
    level._effect["fx_mp_studio_cannon_splash_runner"] = loadfx( "maps/mp_maps/fx_mp_studio_cannon_splash_runner" );
    level._effect["fx_mp_studio_robot_laser"] = loadfx( "maps/mp_maps/fx_mp_studio_robot_laser" );
    level._effect["fx_light_god_ray_mp_studio"] = loadfx( "env/light/fx_light_god_ray_mp_studio" );
    level._effect["fx_mp_studio_ufo_light_flash"] = loadfx( "maps/mp_maps/fx_mp_studio_ufo_light_flash" );
    level._effect["fx_mp_studio_ufo_light_flash_lg"] = loadfx( "maps/mp_maps/fx_mp_studio_ufo_light_flash_lg" );
    level._effect["fx_mp_studio_fence_god_ray"] = loadfx( "maps/mp_maps/fx_mp_studio_fence_god_ray" );
    level._effect["fx_mp_studio_sconce_glare"] = loadfx( "maps/mp_maps/fx_mp_studio_sconce_glare" );
    level._effect["fx_mp_studio_sconce_glare2"] = loadfx( "maps/mp_maps/fx_mp_studio_sconce_glare2" );
    level._effect["fx_mp_studio_lamp_glare"] = loadfx( "maps/mp_maps/fx_mp_studio_lamp_glare" );
    level._effect["fx_mp_studio_flood_light"] = loadfx( "maps/mp_maps/fx_mp_studio_flood_light" );
    level._effect["fx_mp_studio_tube_glare"] = loadfx( "maps/mp_maps/fx_mp_studio_tube_glare" );
    level._effect["fx_mp_studio_lantern_cave"] = loadfx( "maps/mp_maps/fx_mp_studio_lantern_cave" );
    level._effect["fx_mp_studio_red_blink"] = loadfx( "maps/mp_maps/fx_mp_studio_red_blink" );
    level._effect["fx_studio_sq_glare"] = loadfx( "light/fx_studio_sq_glare" );
    level._effect["fx_mp_village_single_glare"] = loadfx( "maps/mp_maps/fx_mp_village_single_glare" );
    level._effect["fx_mp_studio_gold_sparkle_runner"] = loadfx( "maps/mp_maps/fx_mp_studio_gold_sparkle_runner" );
    level._effect["fx_mp_studio_gold_glow"] = loadfx( "maps/mp_maps/fx_mp_studio_gold_glow" );
    level._effect["fx_mp_studio_ufo_engine_runner"] = loadfx( "maps/mp_maps/fx_mp_studio_ufo_engine_runner" );
    level._effect["fx_mp_studio_ufo_forcefield"] = loadfx( "maps/mp_maps/fx_mp_studio_ufo_forcefield" );
    level._effect["fx_mp_studio_saloon_glare"] = loadfx( "maps/mp_maps/fx_mp_studio_saloon_glare" );
    level._effect["fx_mp_studio_saloon_glare_sq"] = loadfx( "maps/mp_maps/fx_mp_studio_saloon_glare_sq" );
    level._effect["fx_lf_mp_studio_sun1"] = loadfx( "lens_flares/fx_lf_mp_studio_sun1" );
}

#using_animtree("fxanim_props");

precache_fxanim_props()
{
    level.scr_anim["fxanim_props"]["roofvent"] = %fxanim_gp_roofvent_anim;
    level.scr_anim["fxanim_props"]["roofvent_slow"] = %fxanim_gp_roofvent_slow_anim;
    level.scr_anim["fxanim_props"]["dino_eggs"] = %fxanim_mp_stu_dino_eggs_anim;
    level.scr_anim["fxanim_props"]["noose"] = %fxanim_mp_stu_noose_anim;
    level.scr_anim["fxanim_props"]["t_rex_barn"] = %fxanim_mp_stu_t_rex_barn_anim;
    level.scr_anim["fxanim_props"]["t_rex_fence_01"] = %fxanim_mp_stu_t_rex_fence_01_anim;
    level.scr_anim["fxanim_props"]["t_rex_fence_02"] = %fxanim_mp_stu_t_rex_fence_02_anim;
    level.scr_anim["fxanim_props"]["t_rex_fence_03"] = %fxanim_mp_stu_t_rex_fence_03_anim;
    level.scr_anim["fxanim_props"]["robot_spider_01"] = %fxanim_mp_stu_robot_01_anim;
    level.scr_anim["fxanim_props"]["robot_spider_02"] = %fxanim_mp_stu_robot_02_anim;
    level.scr_anim["fxanim_props"]["robot_spider_03"] = %fxanim_mp_stu_robot_03_anim;
    level.scr_anim["fxanim_props"]["shark_fins"] = %fxanim_mp_stu_shark_fins_anim;
    level.scr_anim["fxanim_props"]["pirate_boats"] = %fxanim_mp_stu_pirate_boats_anim;
    level.scr_anim["fxanim_props"]["brontosaurus_chew_anim"] = %fxanim_mp_stu_brontosaurus_chew_anim;
    level.scr_anim["fxanim_props"]["brontosaurus_look_around"] = %fxanim_mp_stu_brontosaurus_look_around_anim;
    level.scr_anim["fxanim_props"]["robot_scanning"] = %fxanim_mp_stu_robot_scanning;
    level.scr_anim["fxanim_props"]["t_rex_stand_01"] = %fxanim_mp_stu_t_rex_stand_01_anim;
    level.scr_anim["fxanim_props"]["t_rex_stand_02"] = %fxanim_mp_stu_t_rex_stand_02_anim;
    level.scr_anim["fxanim_props"]["t_rex_stand_03"] = %fxanim_mp_stu_t_rex_stand_03_anim;
    level.scr_anim["fxanim_props"]["captain_01"] = %fxanim_mp_stu_pirate_captain_01_anim;
    level.scr_anim["fxanim_props"]["captain_02"] = %fxanim_mp_stu_pirate_captain_02_anim;
    level.scr_anim["fxanim_props"]["oarsmen_01"] = %fxanim_mp_stu_pirate_oarsmen_01_anim;
    level.scr_anim["fxanim_props"]["oarsmen_02"] = %fxanim_mp_stu_pirate_oarsmen_02_anim;
    level.scr_anim["fxanim_props"]["captain_jailed"] = %fxanim_mp_stu_pirate_jailed_captain_anim;
    level.scr_anim["fxanim_props"]["oarsmen_jailed"] = %fxanim_mp_stu_pirate_jailed_oarsmen_anim;
}

precache_fxanim_props_dlc()
{

}
