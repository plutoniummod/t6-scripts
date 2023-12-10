// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_helicopter_sounds;

init()
{
    level.chopper_fx["damage"]["light_smoke"] = loadfx( "trail/fx_trail_heli_killstreak_engine_smoke_33" );
    level.chopper_fx["damage"]["heavy_smoke"] = loadfx( "trail/fx_trail_heli_killstreak_engine_smoke_66" );
    level._effect["qrdrone_prop"] = loadfx( "weapon/qr_drone/fx_qr_wash_3p" );
    level._effect["heli_guard_light"]["friendly"] = loadfx( "light/fx_vlight_mp_escort_eye_grn" );
    level._effect["heli_guard_light"]["enemy"] = loadfx( "light/fx_vlight_mp_escort_eye_red" );
    level._effect["heli_comlink_light"]["friendly"] = loadfx( "light/fx_vlight_mp_attack_heli_grn" );
    level._effect["heli_comlink_light"]["enemy"] = loadfx( "light/fx_vlight_mp_attack_heli_red" );
    level._effect["heli_gunner_light"]["friendly"] = loadfx( "light/fx_vlight_mp_vtol_grn" );
    level._effect["heli_gunner_light"]["enemy"] = loadfx( "light/fx_vlight_mp_vtol_red" );
    level._effect["heli_gunner"]["vtol_fx"] = loadfx( "vehicle/exhaust/fx_exhaust_vtol_mp" );
    level._effect["heli_gunner"]["vtol_fx_ft"] = loadfx( "vehicle/exhaust/fx_exhaust_vtol_rt_mp" );
    registerclientfield( "helicopter", "supplydrop_care_package_state", 1, 1, "int", ::supplydrop_care_package_state, 0 );
    registerclientfield( "helicopter", "supplydrop_ai_tank_state", 1, 1, "int", ::supplydrop_ai_tank_state, 0 );
    registerclientfield( "helicopter", "heli_comlink_bootup_anim", 1, 1, "int", ::heli_comlink_bootup_anim, 0 );
}

#using_animtree("mp_vehicles");

heli_gunner_vtol_state( localclientnum )
{
    self endon( "entityshutdown" );
    self endon( "death" );
    self useanimtree( #animtree );
    left_anim = %veh_anim_v78_vtol_engine_left;
    right_anim = %veh_anim_v78_vtol_engine_right;
    self setanim( left_anim, 1, 0, 0 );
    self setanim( right_anim, 1, 0, 0 );
    prev_yaw = self.angles[1];
    delta_yaw = 0;

    while ( true )
    {
        speed = self getspeed();
        anim_time = 0.5;

        if ( speed > 0 )
            anim_time = anim_time - speed / 1200 * 0.5;
        else
            anim_time = anim_time + speed * -1 / 1200 * 0.5;

        frame_delta_yaw = angleclamp180( self.angles[1] - prev_yaw ) / 3;
        frame_delta_yaw = frame_delta_yaw < 0.1 ? 0 : frame_delta_yaw;
        delta_yaw = angleclamp180( delta_yaw + ( frame_delta_yaw - delta_yaw ) * 0.1 );
        delta_yaw = clamp( delta_yaw, -0.1, 0.1 );
        prev_yaw = self.angles[1];
        left_anim_time = clamp( anim_time + delta_yaw, 0, 1 );
        right_anim_time = clamp( anim_time - delta_yaw, 0, 1 );
        self setanimtime( left_anim, left_anim_time );
        self setanimtime( right_anim, right_anim_time );
        wait 0.01;
    }
}

heli_comlink_bootup_anim( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    self endon( "entityshutdown" );
    self endon( "death" );
    self useanimtree( #animtree );
    self setanim( %veh_anim_future_heli_gearup_bay_open, 1.0, 0.0, 1.0 );
}

supplydrop_care_package_state( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    self endon( "entityshutdown" );
    self endon( "death" );
    self useanimtree( #animtree );

    if ( newval == 1 )
        self setanim( %o_drone_supply_care_idle, 1.0, 0.0, 1.0 );
    else
        self setanim( %o_drone_supply_care_drop, 1.0, 0.0, 0.3 );
}

supplydrop_ai_tank_state( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    self endon( "entityshutdown" );
    self endon( "death" );
    self useanimtree( #animtree );

    if ( newval == 1 )
        self setanim( %o_drone_supply_agr_idle, 1.0, 0.0, 1.0 );
    else
        self setanim( %o_drone_supply_agr_drop, 1.0, 0.0, 0.3 );
}

warnmissilelocking( localclientnum, set )
{
    if ( set && !self islocalclientdriver( localclientnum ) )
        return;

    clientscripts\mp\_helicopter_sounds::play_targeted_sound( set );
}

warnmissilelocked( localclientnum, set )
{
    if ( set && !self islocalclientdriver( localclientnum ) )
        return;

    clientscripts\mp\_helicopter_sounds::play_locked_sound( set );
}

warnmissilefired( localclientnum, set )
{
    if ( set && !self islocalclientdriver( localclientnum ) )
        return;

    clientscripts\mp\_helicopter_sounds::play_fired_sound( set );
}

heli_deletefx( localclientnum )
{
    if ( isdefined( self.exhaustleftfxhandle ) )
    {
        deletefx( localclientnum, self.exhaustleftfxhandle );
        self.exhaustleftfxhandle = undefined;
    }

    if ( isdefined( self.exhaustrightfxhandlee ) )
    {
        deletefx( localclientnum, self.exhaustrightfxhandle );
        self.exhaustrightfxhandle = undefined;
    }

    if ( isdefined( self.lightfxid ) )
    {
        deletefx( localclientnum, self.lightfxid );
        self.lightfxid = undefined;
    }

    if ( isdefined( self.propfxid ) )
    {
        deletefx( localclientnum, self.propfxid );
        self.propfxid = undefined;
    }

    if ( isdefined( self.vtolleftfxid ) )
    {
        deletefx( localclientnum, self.vtolleftfxid );
        self.vtolleftfxid = undefined;
    }

    if ( isdefined( self.vtolrightfxid ) )
    {
        deletefx( localclientnum, self.vtolrightfxid );
        self.vtolrightfxid = undefined;
    }
}

startfx( localclientnum )
{
    self endon( "entityshutdown" );

    if ( isdefined( self.vehicletype ) )
    {
        if ( self.vehicletype == "remote_mortar_vehicle_mp" )
            return;

        if ( self.vehicletype == "vehicle_straferun_mp" )
            return;
    }

    if ( isdefined( self.exhaustfxname ) && self.exhaustfxname != "" )
        self.exhaustfx = loadfx( self.exhaustfxname );

    if ( isdefined( self.exhaustfx ) )
    {
        self.exhaustleftfxhandle = playfxontag( localclientnum, self.exhaustfx, self, "tag_engine_left" );

        if ( !self.oneexhaust )
            self.exhaustrightfxhandle = playfxontag( localclientnum, self.exhaustfx, self, "tag_engine_right" );
    }
    else
    {
/#
        println( "Client: _helicopter.csc - startfx() - exhaust rotor fx is not loaded" );
#/
    }

    if ( isdefined( self.vehicletype ) )
    {
        light_fx = undefined;
        prop_fx = undefined;

        switch ( self.vehicletype )
        {
            case "heli_ai_mp":
                light_fx = "heli_comlink_light";
                break;
            case "heli_player_gunner_mp":
                self.vtolleftfxid = playfxontag( localclientnum, level._effect["heli_gunner"]["vtol_fx"], self, "tag_engine_left" );
                self.vtolrightfxid = playfxontag( localclientnum, level._effect["heli_gunner"]["vtol_fx_ft"], self, "tag_engine_right" );
                self thread heli_gunner_vtol_state( localclientnum );
                light_fx = "heli_gunner_light";
                break;
            case "heli_guard_mp":
                light_fx = "heli_guard_light";
                break;
            case "qrdrone_mp":
                prop_fx = "qrdrone_prop";
                break;
        }

        if ( isdefined( light_fx ) )
        {
            if ( self friendnotfoe( localclientnum ) )
                self.lightfxid = playfxontag( localclientnum, level._effect[light_fx]["friendly"], self, "tag_origin" );
            else
                self.lightfxid = playfxontag( localclientnum, level._effect[light_fx]["enemy"], self, "tag_origin" );
        }

        if ( isdefined( prop_fx ) && !self islocalclientdriver( localclientnum ) )
            self.propfxid = playfxontag( localclientnum, level._effect[prop_fx], self, "tag_origin" );
    }

    self thread damage_fx_stages( localclientnum );
}

startfx_loop( localclientnum )
{
    self endon( "entityshutdown" );
    self thread clientscripts\mp\_helicopter_sounds::aircraft_dustkick( localclientnum );
    waittillsnapprocessed( localclientnum );
    startfx( localclientnum );
    self notify( "teamBased_fx_reinitialized" );
    level thread watchforplayerrespawnforteambasedfx( localclientnum, self, ::startfx_loop, self.lightfxid );
    servertime = getservertime( 0 );
    lastservertime = servertime;

    while ( isdefined( self ) )
    {
        if ( servertime < lastservertime )
        {
            heli_deletefx( localclientnum );
            startfx( localclientnum );
        }

        wait 0.05;
        lastservertime = servertime;
        servertime = getservertime( 0 );
    }
}

damage_fx_stages( localclientnum )
{
    self endon( "entityshutdown" );
    last_damage_state = self gethelidamagestate();
    fx = undefined;

    for (;;)
    {
        if ( last_damage_state != self gethelidamagestate() )
        {
            if ( self gethelidamagestate() == 2 )
            {
                if ( isdefined( fx ) )
                    stopfx( localclientnum, fx );

                fx = trail_fx( localclientnum, level.chopper_fx["damage"]["light_smoke"], "tag_engine_left" );
            }
            else if ( self gethelidamagestate() == 1 )
            {
                if ( isdefined( fx ) )
                    stopfx( localclientnum, fx );

                fx = trail_fx( localclientnum, level.chopper_fx["damage"]["heavy_smoke"], "tag_engine_left" );
            }
            else
            {
                if ( isdefined( fx ) )
                    stopfx( localclientnum, fx );

                self notify( "stop trail" );
            }

            last_damage_state = self gethelidamagestate();
        }

        wait 0.25;
    }
}

trail_fx( localclientnum, trail_fx, trail_tag )
{
    id = playfxontag( localclientnum, trail_fx, self, trail_tag );
    return id;
}