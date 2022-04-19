// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\killstreaks\_airsupport;
#include maps\mp\killstreaks\_dogs;

init()
{
    level.willypetedamageradius = 300;
    level.willypetedamageheight = 128;
    level.sound_smoke_start = "wpn_smoke_hiss_start";
    level.sound_smoke_loop = "wpn_smoke_hiss_lp";
    level.sound_smoke_stop = "wpn_smoke_hiss_end";
    level.smokesoundduration = 8;
    level.fx_smokegrenade_single = "smoke_center_mp";
    precacheitem( level.fx_smokegrenade_single );
}

watchsmokegrenadedetonation( owner )
{
    owner addweaponstat( "willy_pete_mp", "used", 1 );

    self waittill( "explode", position, surface );

    if ( !isdefined( level.water_duds ) || level.water_duds == 1 )
    {
        if ( isdefined( surface ) && surface == "water" )
            return;
    }

    onefoot = vectorscale( ( 0, 0, 1 ), 12.0 );
    startpos = position + onefoot;
    ent = spawntimedfx( level.fx_smokegrenade_single, position, ( 0, 0, 1 ), 12 );
    ent thread blocksight();

    if ( isdefined( owner ) )
    {
        owner.smokegrenadetime = gettime();
        owner.smokegrenadeposition = position;
    }

    thread playsmokesound( position, level.smokesoundduration, level.sound_smoke_start, level.sound_smoke_stop, level.sound_smoke_loop );
    damageeffectarea( owner, startpos, level.willypetedamageradius, level.willypetedamageheight, undefined );
}

damageeffectarea( owner, position, radius, height, killcament )
{
    effectarea = spawn( "trigger_radius", position, 0, radius, height );
    owner thread maps\mp\killstreaks\_dogs::flash_dogs( effectarea );
    effectarea delete();
}

blocksight()
{
    self endon( "death" );
    radius = 64;
    fxblocksight( self, radius );

    for (;;)
    {
        wait 0.75;
        radius = clamp( radius * 1.5, 10, 150 );
        fxblocksight( self, radius );
    }
}
