// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    level.tweakfile = 1;
    setdvar( "scr_fog_exp_halfplane", "639.219" );
    setdvar( "scr_fog_exp_halfheight", "18691.3" );
    setdvar( "scr_fog_nearplane", "138.679" );
    setdvar( "scr_fog_red", "0.806694" );
    setdvar( "scr_fog_green", "0.962521" );
    setdvar( "scr_fog_blue", "0.9624" );
    setdvar( "scr_fog_baseheight", "1145.21" );
    setdvar( "visionstore_glowTweakEnable", "0" );
    setdvar( "visionstore_glowTweakRadius0", "5" );
    setdvar( "visionstore_glowTweakRadius1", "" );
    setdvar( "visionstore_glowTweakBloomCutoff", "0.5" );
    setdvar( "visionstore_glowTweakBloomDesaturation", "0" );
    setdvar( "visionstore_glowTweakBloomIntensity0", "1" );
    setdvar( "visionstore_glowTweakBloomIntensity1", "" );
    setdvar( "visionstore_glowTweakSkyBleedIntensity0", "" );
    setdvar( "visionstore_glowTweakSkyBleedIntensity1", "" );
    start_dist = 138.679;
    half_dist = 1011.62;
    half_height = 10834.5;
    base_height = 1145.21;
    fog_r = 0.501961;
    fog_g = 0.501961;
    fog_b = 0.501961;
    fog_scale = 7.5834;
    sun_col_r = 0.501961;
    sun_col_g = 0.501961;
    sun_col_b = 0.501961;
    sun_dir_x = -0.99;
    sun_dir_y = 0.06;
    sun_dir_z = -0.11;
    sun_start_ang = 0;
    sun_stop_ang = 0;
    time = 0;
    max_fog_opacity = 0.8546;
    setvolfog( start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale, sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang, sun_stop_ang, time, max_fog_opacity );
    visionsetnaked( "zm_transit", 0 );
    setdvar( "r_lightGridEnableTweaks", 1 );
    setdvar( "r_lightGridIntensity", 1.4 );
    setdvar( "r_lightGridContrast", 0.2 );
}
