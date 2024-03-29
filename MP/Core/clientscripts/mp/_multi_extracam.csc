// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;

init( localclientnum )
{
    triggers = getentarray( localclientnum, "multicam_enable", "targetname" );
    array_thread( triggers, ::multicams_trigger_thread );

    for ( i = 1; i <= 4; i++ )
    {
        camerastruct = getstruct( "extracam" + i, "targetname" );

        if ( isdefined( camerastruct ) )
        {
            camera_ent = spawn( localclientnum, camerastruct.origin, "script_origin" );
            camera_ent.angles = camerastruct.angles;
            camera_ent isextracam( i - 1 );
        }
    }
}

multicams_trigger_thread()
{
    for (;;)
    {
        self waittill( "trigger", trigplayer );
        self thread trigger_thread( trigplayer, ::multicams_trigger_enter, ::multicams_trigger_leave );
    }
}

multicams_trigger_enter( trigplayer )
{
    trigplayer setmultiextracamactive( 1 );
}

multicams_trigger_leave( trigplayer )
{
    trigplayer setmultiextracamactive( 0 );
}
