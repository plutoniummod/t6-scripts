// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_face_utility_mp;
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_clientfaceanim_zm;

actor_flag_change_handler( localclientnum, flag, set, newent )
{
    if ( flag == 1 )
    {
        if ( set )
        {
            self.face_disable = 1;
            self notify( "face", "face_advance" );
        }
        else
        {
            self.face_disable = 0;
            self notify( "face", "face_advance" );
        }
    }
}

init_clientfaceanim()
{
    level._client_flag_callbacks["actor"] = clientscripts\mp\zombies\_clientfaceanim_zm::actor_flag_change_handler;

    if ( level.isdemoplaying || sessionmodeiszombiesgame() )
        level._faceanimcbfunc = clientscripts\mp\zombies\_clientfaceanim_zm::doface;

    buildface_player();
}

doface( localclientnum )
{
    if ( self isplayer() )
    {
        while ( true )
        {
            if ( self isplayer() )
            {
                self thread processfaceevents( localclientnum );
                self waittill( "respawn" );

                while ( !isdefined( self ) )
                    wait 0.05;

                self.face_death = 0;
                self.face_disable = 0;
            }
            else
                wait 0.05;
        }
    }
}

#using_animtree("zombie_player");

buildface_player()
{
    level.face_anim_tree = "zombie_player";
    self setfaceroot( %head );
    self buildfacestate( "face_casual", 1, -1, 0, "basestate", %pf_casual_idle );
    self buildfacestate( "face_alert", 1, -1, 0, "basestate", %pf_alert_idle );
    self buildfacestate( "face_shoot", 1, 1, 1, "eventstate", %pf_firing );
    self buildfacestate( "face_shoot_single", 1, 1, 1, "eventstate", %pf_firing );
    self buildfacestate( "face_melee", 1, 2, 1, "eventstate", %pf_melee );
    self buildfacestate( "face_pain", 0, -1, 2, "eventstate", %pf_pain );
    self buildfacestate( "face_death", 0, -1, 2, "exitstate", %pf_death );
    self buildfacestate( "face_advance", 0, -1, 3, "nullstate", undefined );
}

do_corpse_face_hack( localclientnum )
{
    if ( isdefined( self ) && isdefined( level.face_anim_tree ) && isdefined( level.facestates ) )
    {
        numanims = level.facestates["face_death"]["animation"].size;
        self waittill_dobj( localclientnum );

        if ( !isdefined( self ) )
            return;

        self setanimknob( level.facestates["face_death"]["animation"][randomint( numanims )], 1.0, 0.1, 1.0 );
    }
}
