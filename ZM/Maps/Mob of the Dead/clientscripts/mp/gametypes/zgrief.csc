// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool

main()
{
    level._zombie_gamemodeprecache = ::onprecachegametype;
    level._zombie_gamemodepremain = ::premain;
    level._zombie_gamemodemain = ::onstartgametype;
}

onprecachegametype()
{
    setteamreviveicon( "allies", "waypoint_revive_cdc_zm" );
    setteamreviveicon( "axis", "waypoint_revive_cia_zm" );
    level._effect["meat_stink_camera"] = loadfx( "maps/zombie/fx_zmb_meat_stink_camera" );
    level._effect["meat_stink_torso"] = loadfx( "maps/zombie/fx_zmb_meat_stink_torso" );
}

premain()
{
    registerclientfield( "toplayer", "meat_stink", 1, 1, "int", ::meat_stink_cb, 0, 1 );
}

onstartgametype()
{

}

meat_stink_cb( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval )
        self.meatstink_fx = playfxontag( localclientnum, level._effect["meat_stink_camera"], self, "J_SpineLower" );
    else if ( isdefined( self.meatstink_fx ) )
    {
        stopfx( localclientnum, self.meatstink_fx );
        self.meatstink_fx = undefined;
    }
}
