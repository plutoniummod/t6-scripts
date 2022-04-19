// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\_ambientpackage;

main()
{
    array_thread( getentarray( "advertisement", "targetname" ), ::advertisements );
}

advertisements()
{
    self playloopsound( "amb_" + self.script_noteworthy + "_ad" );

    self waittill( "damage" );

    self stoploopsound();
    self playloopsound( "amb_" + self.script_noteworthy + "_damaged_ad" );
}
