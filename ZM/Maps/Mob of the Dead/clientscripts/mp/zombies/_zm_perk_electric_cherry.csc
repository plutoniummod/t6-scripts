// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\zombies\_zm_perks;

enable_electric_cherry_perk_for_level()
{
    clientscripts\mp\zombies\_zm_perks::register_perk_clientfields( "specialty_grenadepulldeath", ::electric_cherry_client_field_func, ::electric_cherry_code_callback_func );
    clientscripts\mp\zombies\_zm_perks::register_perk_init_thread( "specialty_grenadepulldeath", ::init_electric_cherry );
}

init_electric_cherry()
{
    registerclientfield( "allplayers", "electric_cherry_reload_fx", 9000, 2, "int", ::electric_cherry_reload_attack_fx, 0 );
    level._effect["electric_cherry_explode"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_electric_cherry_down" );
    level._effect["electric_cherry_reload_small"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_electric_cherry_sm" );
    level._effect["electric_cherry_reload_medium"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_electric_cherry_player" );
    level._effect["electric_cherry_reload_large"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_electric_cherry_lg" );
    level._effect["tesla_shock"] = loadfx( "maps/zombie/fx_zombie_tesla_shock" );
    level._effect["tesla_shock_secondary"] = loadfx( "maps/zombie/fx_zombie_tesla_shock_secondary" );
}

electric_cherry_client_field_func()
{
    registerclientfield( "toplayer", "perk_electric_cherry", 9000, 1, "int", undefined, 0, 1 );
}

electric_cherry_code_callback_func()
{
    setupclientfieldcodecallbacks( "toplayer", 1, "perk_electric_cherry" );
}

electric_cherry_reload_attack_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( isdefined( self.electric_cherry_reload_fx ) )
        stopfx( localclientnum, self.electric_cherry_reload_fx );

    if ( newval == 1 )
        self.electric_cherry_reload_fx = playfxontag( localclientnum, level._effect["electric_cherry_reload_small"], self, "tag_origin" );
    else if ( newval == 2 )
        self.electric_cherry_reload_fx = playfxontag( localclientnum, level._effect["electric_cherry_reload_medium"], self, "tag_origin" );
    else if ( newval == 3 )
        self.electric_cherry_reload_fx = playfxontag( localclientnum, level._effect["electric_cherry_reload_large"], self, "tag_origin" );
    else
    {
        if ( isdefined( self.electric_cherry_reload_fx ) )
            stopfx( localclientnum, self.electric_cherry_reload_fx );

        self.electric_cherry_reload_fx = undefined;
    }
}
