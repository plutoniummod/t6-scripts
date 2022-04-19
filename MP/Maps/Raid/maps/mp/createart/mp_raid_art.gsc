// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    level.tweakfile = 1;
    setdvar( "scr_fog_exp_halfplane", "3759.28" );
    setdvar( "scr_fog_exp_halfheight", "243.735" );
    setdvar( "scr_fog_nearplane", "601.593" );
    setdvar( "scr_fog_red", "0.806694" );
    setdvar( "scr_fog_green", "0.962521" );
    setdvar( "scr_fog_blue", "0.9624" );
    setdvar( "scr_fog_baseheight", "-475.268" );
    setdvar( "visionstore_glowTweakEnable", "0" );
    setdvar( "visionstore_glowTweakRadius0", "5" );
    setdvar( "visionstore_glowTweakRadius1", "" );
    setdvar( "visionstore_glowTweakBloomCutoff", "0.5" );
    setdvar( "visionstore_glowTweakBloomDesaturation", "0" );
    setdvar( "visionstore_glowTweakBloomIntensity0", "1" );
    setdvar( "visionstore_glowTweakBloomIntensity1", "" );
    setdvar( "visionstore_glowTweakSkyBleedIntensity0", "" );
    setdvar( "visionstore_glowTweakSkyBleedIntensity1", "" );
    visionsetnaked( "mp_raid", 1 );
    setdvar( "r_lightGridEnableTweaks", 1 );
    setdvar( "r_lightGridIntensity", 1.0 );
    setdvar( "r_lightGridContrast", 0 );
}
