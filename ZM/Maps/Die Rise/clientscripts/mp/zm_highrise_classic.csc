// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_weapons;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zm_highrise_buildables;

precache()
{

}

premain()
{
    clientscripts\mp\zm_highrise_buildables::include_buildables();
    clientscripts\mp\zm_highrise_buildables::init_buildables();
    onplayerconnect_callback( ::floor_indicators );
    onplayerconnect_callback( ::teller_fx_setup );
}

main()
{

}

teller_fx_setup( localclientnum )
{
    playfx( localclientnum, level._effect["elevator_glint"], ( 2232.68, 569.287, 1312 ), ( 0, 0, 1 ) );
    playfx( localclientnum, level._effect["elevator_glint"], ( 2264.36, 623.991, 1312 ), ( 0, 0, 1 ) );
}

#using_animtree("zombie_perk_elevator");

init_perk_elvators_animtree()
{
    scriptmodelsuseanimtree( #animtree );
}

floor_indicators( localclientnum )
{
    if ( getdvarint( #"splitscreen_playerCount" ) > 2 )
    {
        level thread floor_indicators_remove( localclientnum );
        return;
    }

    floors = array( "3d", "3b", "3", "3c", "1d", "1c", "1b" );

    foreach ( floor in floors )
    {
        indicators = getentarray( localclientnum, "elevator_bldg" + floor + "_indicator", "targetname" );

        if ( isdefined( indicators ) && indicators.size > 0 )
            level thread floor_indicator( localclientnum, indicators, floor );
    }
}

floor_indicators_remove( localclientnum )
{
    floors = array( "3d", "3b", "3", "3c", "1d", "1c", "1b" );

    foreach ( floor in floors )
    {
        indicators = getentarray( localclientnum, "elevator_bldg" + floor + "_indicator", "targetname" );
        level notify( "kill_floor_indicators_" + localclientnum );

        foreach ( indicator in indicators )
            indicator delete();
    }
}

floor_indicator( clientnum, indicators, floorname )
{
    level endon( "kill_floor_indicators_" + clientnum );
    indicators_list = [];

    while ( true )
    {
        event = level waittill_any_return( floorname + "_u", floorname + "_d" );
        new_indicators = [];
        floor_fx = level._effect["perk_elevator_indicator_down"];

        if ( event == floorname + "_u" )
            floor_fx = level._effect["perk_elevator_indicator_up"];

        foreach ( indicator in indicators )
        {
            if ( isdefined( indicator.arrow_fx ) )
                stopfx( clientnum, indicator.arrow_fx );

            indicator.arrow_fx = playfxontag( clientnum, floor_fx, indicator, "tag_origin" );
        }
    }
}

#using_animtree("zombie_escape_elevator");

init_escape_elevators_animtree()
{
    scriptmodelsuseanimtree( #animtree );
}

escape_pod_tell_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
/#
    println( "escape_pod_tell_fx called on local client " + localclientnum );
#/

    if ( newval == 1 )
        self.tell_fx = playfxontag( localclientnum, level._effect["elevator_tell"], self, "tag_origin" );
    else if ( isdefined( self.tell_fx ) )
        stopfx( localclientnum, self.tell_fx );
}

escape_pod_sparks_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
/#
    println( "escape_pod_sparks_fx called on local client " + localclientnum );
#/

    if ( newval == 1 )
        self.sparks_fx = playfxontag( localclientnum, level._effect["elevator_sparks"], self, "tag_origin" );
    else if ( isdefined( self.sparks_fx ) )
        stopfx( localclientnum, self.sparks_fx );
}

escape_pod_impact_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
/#
    println( "escape_pod_impact_fx called on local client " + localclientnum );
#/

    if ( newval == 1 )
        self.impact_fx = playfxontag( localclientnum, level._effect["elevator_impact"], self, "tag_origin" );
    else if ( isdefined( self.impact_fx ) )
        stopfx( localclientnum, self.impact_fx );
}

escape_pod_light_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
/#
    println( "escape_pod_light_fx called on local client " + localclientnum );
#/

    if ( newval == 1 )
        self.light_fx = playfxontag( localclientnum, level._effect["elevator_light"], self, "tag_animate" );
    else if ( isdefined( self.light_fx ) )
        stopfx( localclientnum, self.light_fx );
}
