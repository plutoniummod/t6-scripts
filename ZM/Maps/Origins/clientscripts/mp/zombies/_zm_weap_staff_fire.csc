// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_fx;
#include clientscripts\mp\_music;

init()
{
    if ( getdvar( #"createfx" ) == "on" )
        return;

    level._effect["character_fire_death_sm"] = loadfx( "env/fire/fx_fire_zombie_md" );
    level._effect["character_fire_death_torso"] = loadfx( "env/fire/fx_fire_zombie_torso" );
    registerclientfield( "actor", "fire_char_fx", 14000, 1, "int", ::zombie_fire_fx );
    registerclientfield( "toplayer", "fire_muzzle_fx", 14000, 1, "int", ::fire_muzzle_fx );
}

fire_muzzle_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval == 1 )
    {
        playviewmodelfx( localclientnum, level._effect["fire_muzzle"], "tag_flash" );
        playsound( localclientnum, "wpn_firestaff_fire_plr" );
    }
}

zombie_fire_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    self endon( "entityshutdown" );
    rate = randomfloatrange( 0.01, 0.015 );

    if ( isdefined( self.torso_fire_fx ) )
    {
        stopfx( localclientnum, self.torso_fire_fx );
        self.torso_fire_fx = undefined;
    }

    if ( isdefined( self.head_fire_fx ) )
    {
        stopfx( localclientnum, self.head_fire_fx );
        self.head_fire_fx = undefined;
    }

    if ( isdefined( self.sndent ) )
    {
        self.sndent notify( "sndDeleting" );
        self.sndent delete();
        self.sndent = undefined;
    }

    if ( newval == 1 )
    {
        self.torso_fire_fx = playfxontag( localclientnum, level._effect["character_fire_death_torso"], self, "j_spinelower" );
        self.head_fire_fx = playfxontag( localclientnum, level._effect["character_fire_death_sm"], self, "j_head" );
        self.sndent = spawn( 0, self.origin, "script_origin" );
        self.sndent linkto( self );
        self.sndent playloopsound( "zmb_fire_loop", 0.5 );
        self.sndent thread snddeleteent( self );

        if ( !is_true( self.has_charred ) )
        {
            self mapshaderconstant( localclientnum, 2, "scriptVector3" );
            self.has_charred = 1;
        }

        max_charamount = 1;
        char_amount = 0.6;

        for ( i = 0; i < 2; i++ )
        {
            for ( f = 0.6; f <= 0.85; f = f + rate )
            {
                serverwait( localclientnum, 0.05 );
                self setshaderconstant( localclientnum, 2, f, 0, 0, 0 );
            }

            for ( f = 0.85; f >= 0.6; f = f - rate )
            {
                serverwait( localclientnum, 0.05 );
                self setshaderconstant( localclientnum, 2, f, 0, 0, 0 );
            }
        }

        for ( f = 0.6; f <= 1.0; f = f + rate )
        {
            serverwait( localclientnum, 0.05 );
            self setshaderconstant( localclientnum, 2, f, 0, 0, 0 );
        }
    }
}

snddeleteent( zomb )
{
    self endon( "sndDeleting" );
    zomb waittill( "entityshutdown" );
    self delete();
}
