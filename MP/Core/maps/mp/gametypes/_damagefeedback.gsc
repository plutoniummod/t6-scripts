// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    precacheshader( "damage_feedback" );
    precacheshader( "damage_feedback_flak" );
    precacheshader( "damage_feedback_tac" );
    level thread onplayerconnect();
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player.hud_damagefeedback = newdamageindicatorhudelem( player );
        player.hud_damagefeedback.horzalign = "center";
        player.hud_damagefeedback.vertalign = "middle";
        player.hud_damagefeedback.x = -12;
        player.hud_damagefeedback.y = -12;
        player.hud_damagefeedback.alpha = 0;
        player.hud_damagefeedback.archived = 1;
        player.hud_damagefeedback setshader( "damage_feedback", 24, 48 );
        player.hitsoundtracker = 1;
    }
}

updatedamagefeedback( mod, inflictor, perkfeedback )
{
    if ( !isplayer( self ) || sessionmodeiszombiesgame() )
        return;

    if ( isdefined( mod ) && mod != "MOD_CRUSH" && mod != "MOD_GRENADE_SPLASH" && mod != "MOD_HIT_BY_OBJECT" )
    {
        if ( isdefined( inflictor ) && isdefined( inflictor.soundmod ) )
        {
            switch ( inflictor.soundmod )
            {
                case "player":
                    self playlocalsound( "mpl_hit_alert" );
                    break;
                case "heli":
                    self thread playhitsound( mod, "mpl_hit_alert_air" );
                    break;
                case "hpm":
                    self thread playhitsound( mod, "mpl_hit_alert_hpm" );
                    break;
                case "taser_spike":
                    self thread playhitsound( mod, "mpl_hit_alert_taser_spike" );
                    break;
                case "straferun":
                case "dog":
                    break;
                case "default_loud":
                    self thread playhitsound( mod, "mpl_hit_heli_gunner" );
                    break;
                default:
                    self thread playhitsound( mod, "mpl_hit_alert_low" );
                    break;
            }
        }
        else
            self playlocalsound( "mpl_hit_alert_low" );
    }

    if ( isdefined( perkfeedback ) )
    {
        switch ( perkfeedback )
        {
            case "flakjacket":
                self.hud_damagefeedback setshader( "damage_feedback_flak", 24, 48 );
                break;
            case "tacticalMask":
                self.hud_damagefeedback setshader( "damage_feedback_tac", 24, 48 );
                break;
        }
    }
    else
        self.hud_damagefeedback setshader( "damage_feedback", 24, 48 );

    self.hud_damagefeedback.alpha = 1;
    self.hud_damagefeedback fadeovertime( 1 );
    self.hud_damagefeedback.alpha = 0;
}

playhitsound( mod, alert )
{
    self endon( "disconnect" );

    if ( self.hitsoundtracker )
    {
        self.hitsoundtracker = 0;
        self playlocalsound( alert );
        wait 0.05;
        self.hitsoundtracker = 1;
    }
}

updatespecialdamagefeedback( hitent )
{
    if ( !isplayer( self ) )
        return;

    if ( !isdefined( hitent ) )
        return;

    if ( !isplayer( hitent ) )
        return;

    wait 0.05;

    if ( !isdefined( self.directionalhitarray ) )
    {
        self.directionalhitarray = [];
        hitentnum = hitent getentitynumber();
        self.directionalhitarray[hitentnum] = 1;
        self thread sendhitspecialeventatframeend( hitent );
    }
    else
    {
        hitentnum = hitent getentitynumber();
        self.directionalhitarray[hitentnum] = 1;
    }
}

sendhitspecialeventatframeend( hitent )
{
    self endon( "disconnect" );
    waittillframeend;
    enemyshit = 0;
    value = 1;
    entbitarray0 = 0;

    for ( i = 0; i < 32; i++ )
    {
        if ( isdefined( self.directionalhitarray[i] ) && self.directionalhitarray[i] != 0 )
        {
            entbitarray0 += value;
            enemyshit++;
        }

        value *= 2;
    }

    entbitarray1 = 0;

    for ( i = 33; i < 64; i++ )
    {
        if ( isdefined( self.directionalhitarray[i] ) && self.directionalhitarray[i] != 0 )
        {
            entbitarray1 += value;
            enemyshit++;
        }

        value *= 2;
    }

    if ( enemyshit )
        self directionalhitindicator( entbitarray0, entbitarray1 );

    self.directionalhitarray = undefined;
    entbitarray0 = 0;
    entbitarray1 = 0;
}
