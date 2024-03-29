// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool

init()
{
    registerclientfield( "scriptmover", "perk_bottle_cycle_state", 14000, 2, "int", ::start_bottle_cycling, 0 );
    registerclientfield( "scriptmover", "turn_active_perk_light_red", 14000, 1, "int", ::turn_on_active_light_red, 0 );
    registerclientfield( "scriptmover", "turn_active_perk_light_green", 14000, 1, "int", ::turn_on_active_light_green, 0 );
    registerclientfield( "scriptmover", "turn_on_location_indicator", 14000, 1, "int", ::turn_on_location_indicator, 0 );
    registerclientfield( "scriptmover", "turn_active_perk_ball_light", 14000, 1, "int", ::turn_on_active_ball_light, 0 );
    registerclientfield( "scriptmover", "zone_captured", 14000, 1, "int", ::zone_captured_cb, 0 );
    level._effect["perk_machine_light"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light" );
    level._effect["perk_machine_light_red"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light_red" );
    level._effect["perk_machine_light_green"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light_green" );
    level._effect["perk_machine_steam"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_steam" );
    level._effect["perk_machine_location"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_identify" );
    level._effect["perk_machine_activation_electric_loop"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_on" );
}

#using_animtree("zm_perk_random");

init_animtree()
{
    scriptmodelsuseanimtree( #animtree );
}

turn_on_location_indicator( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval == 1 )
        self thread fx_location_indicator( localclientnum );
    else
    {
        self notify( "ball_departed" );
        self thread fx_departure_steam( localclientnum );
    }
}

zone_captured_cb( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( !isdefined( self.mapped_const ) )
    {
        self mapshaderconstant( localclientnum, 1, "ScriptVector0" );
        self.mapped_const = 1;
    }

    if ( newval == 1 )
    {

    }
    else
    {
        self.artifact_glow_setting = 1;
        self.machinery_glow_setting = 0.0;
        self setshaderconstant( localclientnum, 1, self.artifact_glow_setting, 0, self.machinery_glow_setting, 0 );
    }
}

turn_on_active_light_red( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval == 1 )
    {
        self._active_glow_red = playfxontag( localclientnum, level._effect["perk_machine_light_red"], self, "tag_origin" );
        self.artifact_glow_setting = 1;
        self.machinery_glow_setting = 0.4;
        self setshaderconstant( localclientnum, 1, self.artifact_glow_setting, 0, self.machinery_glow_setting, 0 );
    }
    else
        stopfx( localclientnum, self._active_glow_red );
}

turn_on_active_light_green( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval == 1 )
    {
        self._active_glow_green = playfxontag( localclientnum, level._effect["perk_machine_light_green"], self, "tag_origin" );
        self.artifact_glow_setting = 1;
        self.machinery_glow_setting = 0.7;
        self setshaderconstant( localclientnum, 1, self.artifact_glow_setting, 0, self.machinery_glow_setting, 0 );
    }
    else
        stopfx( localclientnum, self._active_glow_green );
}

turn_on_active_ball_light( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval == 1 )
    {
        self._ball_glow = playfxontag( localclientnum, level._effect["perk_machine_light"], self, "j_ball" );
        self.artifact_glow_setting = 1;
        self.machinery_glow_setting = 1.0;
        self setshaderconstant( localclientnum, 1, self.artifact_glow_setting, 0, self.machinery_glow_setting, 0 );
    }
    else
        stopfx( localclientnum, self._ball_glow );
}

start_bottle_cycling( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( newval == 1 )
        self thread start_vortex_fx( localclientnum );
    else
        self thread stop_vortex_fx( localclientnum );
}

start_vortex_fx( localclientnum )
{
    self endon( "activation_electricity_finished" );
    self endon( "entityshutdown" );

    if ( !isdefined( self.glow_location ) )
    {
        self.glow_location = spawn( localclientnum, self.origin, "script_model" );
        self.glow_location.angles = self.angles;
        self.glow_location setmodel( "tag_origin" );
    }

    self thread fx_activation_electric_loop( localclientnum );
    self thread fx_artifact_pulse_thread( localclientnum );
    playsound( localclientnum, "zmb_rand_perk_vortex_sparks", self.origin );
    wait 0.5;
    self thread fx_bottle_cycling( localclientnum );
    soundloopemitter( "zmb_rand_perk_vortex", self.origin );
}

stop_vortex_fx( localclientnum )
{
    self endon( "entityshutdown" );
    self notify( "bottle_cycling_finished" );
    playsound( localclientnum, "zmb_rand_perk_vortex_sparks", self.origin );
    wait 0.5;
    soundstoploopemitter( "zmb_rand_perk_vortex", self.origin );

    if ( !isdefined( self ) )
        return;

    self notify( "activation_electricity_finished" );

    if ( isdefined( self.glow_location ) )
        self.glow_location delete();

    self.artifact_glow_setting = 1;
    self.machinery_glow_setting = 0.7;
    self setshaderconstant( localclientnum, 1, self.artifact_glow_setting, 0, self.machinery_glow_setting, 0 );
}

fx_artifact_pulse_thread( localclientnum )
{
    self endon( "activation_electricity_finished" );
    self endon( "entityshutdown" );

    while ( isdefined( self ) )
    {
        shader_amount = sin( getrealtime() * 0.2 );

        if ( shader_amount < 0 )
            shader_amount = shader_amount * -1;

        shader_amount = 0.75 - shader_amount * 0.75;
        self.artifact_glow_setting = shader_amount;
        self.machinery_glow_setting = 1.0;
        self setshaderconstant( localclientnum, 1, self.artifact_glow_setting, 0, self.machinery_glow_setting, 0 );
        wait 0.05;
    }
}

fx_activation_electric_loop( localclientnum )
{
    self endon( "activation_electricity_finished" );
    self endon( "entityshutdown" );

    while ( true )
    {
        if ( isdefined( self.glow_location ) )
            playfxontag( localclientnum, level._effect["perk_machine_activation_electric_loop"], self.glow_location, "tag_origin" );

        wait 0.1;
    }
}

fx_bottle_cycling( localclientnum )
{
    self endon( "bottle_cycling_finished" );

    while ( true )
    {
        if ( isdefined( self.glow_location ) )
            playfxontag( localclientnum, level._effect["bottle_glow"], self.glow_location, "tag_origin" );

        wait 0.1;
    }
}

fx_departure_steam( localclientnum )
{
    self endon( "departure_steam_finished" );
    n_end_time = getrealtime() + 5000;

    while ( isdefined( self ) && n_end_time > getrealtime() )
    {
        self._departure_steam = playfxontag( localclientnum, level._effect["perk_machine_steam"], self, "tag_origin" );
        wait 0.1;
    }
}

fx_location_indicator( localclientnum )
{
    self endon( "ball_departed" );
    self endon( "entityshutdown" );
    level endon( "demo_jump" );

    while ( isdefined( self ) )
    {
        if ( isdefined( self ) )
            self._location_indicator = playfx( localclientnum, level._effect["perk_machine_location"], self.origin );

        wait( randomfloatrange( 3.0, 4.0 ) );
    }
}
