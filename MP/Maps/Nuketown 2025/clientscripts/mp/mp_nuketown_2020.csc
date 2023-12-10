// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_load;
#include clientscripts\mp\mp_nuketown_2020_fx;
#include clientscripts\mp\_audio;
#include clientscripts\mp\mp_nuketown_2020_amb;
#include clientscripts\mp\_fx;

main()
{
    level.worldmapx = 93;
    level.worldmapy = 265;
    level.worldlat = 39.8319;
    level.worldlong = -117.392;
    clientscripts\mp\_load::main();
    clientscripts\mp\mp_nuketown_2020_fx::main();
    thread clientscripts\mp\_audio::audio_init( 0 );
    thread clientscripts\mp\mp_nuketown_2020_amb::main();
    level.onplayerconnect = ::setupclientsideobjects;
    waitforclient( 0 );
}

setupclientsideobjects( localclientnum )
{
    while ( !clienthassnapshot( localclientnum ) )
        wait 0.1;

    level thread flag_think( localclientnum );
    level thread nuked_energy_sign_think( localclientnum );
    level thread nuked_car_flip( localclientnum );
}

#using_animtree("fxanim_props");

nuked_car_flip( localclientnum )
{
    level thread nuked_dome_explosion_think( localclientnum );
    car01 = getent( localclientnum, "nuke_animated_car01", "targetname" );
    car02 = getent( localclientnum, "nuke_animated_car02", "targetname" );
    displayglass = getent( localclientnum, "nuke_display_glass_client", "targetname" );
    assert( isdefined( car01 ) );
    assert( isdefined( car02 ) );
    assert( isdefined( displayglass ) );
    carmoveoffest = vectorscale( ( 0, 0, 1 ), 120.0 );
    car01.origin -= carmoveoffest;
    car02.origin -= carmoveoffest;
    car01 hide();
    car02 hide();
    displayglass hide();

    level waittill( "bomb_drop_pre" );

    setsaveddvar( "wind_global_vector", "-256 -256 -256" );
    car01.origin += carmoveoffest;
    car02.origin += carmoveoffest;
    car01 show();
    car02 show();
    displayglass show();

    level waittill( "nuke_car_flip" );

    car01 useanimtree( #animtree );
    car01 animflaggedscripted( "fx", level.scr_anim["fxanim_props"]["cardestroy1"], 1.0, 0.0, 1.0 );
    car01 thread waitfornotetrack( localclientnum );
    car02 useanimtree( #animtree );
    car02 animflaggedscripted( "fx", level.scr_anim["fxanim_props"]["cardestroy2"], 1.0, 0.0, 1.0 );
    car02 thread waitfornotetrack( localclientnum );
    displayglass useanimtree( #animtree );
    displayglass animflaggedscripted( "fx", level.scr_anim["fxanim_props"]["displayGlassDestroy"], 1.0, 0.0, 1.0 );
}

nuked_dome_explosion_think( localclientnum )
{
    level waittill( "bomb_drop" );

    level notify( "fxanim_dome_explode_start" );
}

flag_think( localclientnum )
{
    flags = getentarray( localclientnum, "ending_flag", "targetname" );
    array_thread( flags, ::rotate_flags );
}

rotate_flags()
{
    level waittill( "bomb_drop" );

    self rotateto( ( 0, randomintrange( 75, 105 ), 0 ), randomfloatrange( 0.5, 0.65 ) );
}

nuked_energy_sign_think( localclientnum )
{
    spin_a_model = getent( localclientnum, "nuketown_sign_topper", "targetname" );
    spin_a_model thread spinner_rotate( 1 );
}

spinner_rotate( multiplier )
{
    step = 180 * multiplier;
    self spinner_rotate_match( step );
}

spinner_rotate_match( step )
{
    self endon( "death" );
    self endon( "entityshutdown" );
    self endon( "delete" );

    for (;;)
    {
        self rotatevelocity( ( 0, step / 2, 0 ), 3600 );

        self waittill( "rotatedone" );
    }
}

waitfornotetrack( localclientnum )
{
    self endon( "entityshutdown" );

    for (;;)
    {
        self waittill( "fx", note );

        if ( note == "camera_goes_dark" )
        {
            visionsetnaked( localclientnum, "blackout", 0 );
            break;
        }

        if ( note == "glass_shatter" )
            clientscripts\mp\_fx::exploder( 1005 );
    }
}
