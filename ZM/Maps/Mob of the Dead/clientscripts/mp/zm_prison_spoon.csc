// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_filter;
#include clientscripts\mp\zombies\_zm_weapons;
#include clientscripts\mp\zombies\_zm_utility;

spoon_visual_callback( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval == 1 )
    {
        s_spoon_pos = getstruct( "struct_spoon_start", "targetname" );
        m_spoon = spawn( localclientnum, s_spoon_pos.origin, "script_model" );
        m_spoon setmodel( "t6_wpn_zmb_spoon_world" );
        m_spoon playsound( 0, "zmb_squest_spoon_in" );

        for ( i = 0; i < 20; i++ )
        {
            m_spoon rotateyaw( 90, 1 );
            wait 0.15;
        }

        m_spoon moveto( m_spoon.origin - vectorscale( ( 0, 0, 1 ), 36.0 ), 5 );
        m_spoon waittill( "movedone" );
        m_spoon delete();
    }
    else if ( newval == 2 )
    {
        s_spoon = getstruct( "s_rising_spork", "targetname" );
        s_arm = getstruct( "s_rising_arm", "targetname" );
        self.my_m_spoon = spawn( localclientnum, s_spoon.origin, "script_model" );
        self.my_m_spoon setmodel( "t6_wpn_zmb_spork_world" );
        self.my_m_spoon.angles = s_spoon.angles;
        m_arm = spawn( localclientnum, s_arm.origin, "script_model" );
        m_arm setmodel( "c_zom_inmate_g_rarmspawn" );
        m_arm.angles = s_arm.angles;
        m_arm playsound( 0, "zmb_squest_spork_out" );
        self.my_m_spoon linkto( m_arm );
        m_arm moveto( m_arm.origin + vectorscale( ( 0, 0, 1 ), 26.0 ), 5 );
    }
    else if ( newval == 3 )
        self.my_m_spoon delete();
}
