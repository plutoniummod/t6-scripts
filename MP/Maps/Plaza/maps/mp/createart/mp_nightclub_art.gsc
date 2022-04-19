// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    level.tweakfile = 1;
    setdvar( "visionstore_glowTweakEnable", "0" );
    setdvar( "visionstore_glowTweakRadius0", "5" );
    setdvar( "visionstore_glowTweakRadius1", "" );
    setdvar( "visionstore_glowTweakBloomCutoff", "0.5" );
    setdvar( "visionstore_glowTweakBloomDesaturation", "0" );
    setdvar( "visionstore_glowTweakBloomIntensity0", "1" );
    setdvar( "visionstore_glowTweakBloomIntensity1", "" );
    setdvar( "visionstore_glowTweakSkyBleedIntensity0", "" );
    setdvar( "visionstore_glowTweakSkyBleedIntensity1", "" );
    visionsetnaked( "mp_nightclub", 1 );
    setdvar( "r_lightGridEnableTweaks", 1 );
    setdvar( "r_lightGridIntensity", 1.4 );
    setdvar( "r_lightGridContrast", 0 );
}
