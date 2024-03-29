// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\_audio;
#include clientscripts\mp\_filter;
#include clientscripts\mp\zombies\_zm_powerups;
#include clientscripts\mp\_visionset_mgr;

init()
{
    onplayerconnect_callback( ::init_filter_zombie_blood );
    level.vsmgr_filter_custom_enable["generic_filter_zombie_blood_b"] = ::vsmgr_enable_filter_zombie_blood;
    registerclientfield( "allplayers", "player_zombie_blood_fx", 14000, 1, "int", ::toggle_player_zombie_blood_fx, 0, 1 );
    level._effect["zombie_blood"] = loadfx( "maps/zombie_tomb/fx_tomb_pwr_up_zmb_blood" );
    level._effect["zombie_blood_1st"] = loadfx( "maps/zombie_tomb/fx_zm_blood_overlay_pclouds" );
    clientscripts\mp\zombies\_zm_powerups::add_zombie_powerup( "zombie_blood", "powerup_zombie_blood" );
    clientscripts\mp\_visionset_mgr::vsmgr_register_visionset_info( "zm_powerup_zombie_blood_visionset", 14000, 15, "zm_powerup_zombie_blood", "zm_powerup_zombie_blood" );
    clientscripts\mp\_visionset_mgr::vsmgr_register_overlay_info_style_filter( "zm_powerup_zombie_blood_overlay", 14000, 15, 1, 0, "generic_filter_zombie_blood_b" );
}

vsmgr_enable_filter_zombie_blood( curr_info )
{
    enable_filter_zombie_blood( self, curr_info.filter_index, 0.0 );
}

init_filter_zombie_blood( localclientnum )
{
    player = getlocalplayer( localclientnum );
    init_filter_indices();
    map_material_helper( player, "generic_filter_zombie_blood_b" );
}

set_filter_zombie_blood_overlay_amount( player, filterid, amount )
{
    player set_filter_pass_constant( filterid, 0, 0, amount );
}

enable_filter_zombie_blood( player, filterid, zombie_blood_warp_shift_enabled )
{
    player set_filter_pass_material( filterid, 0, level.filter_matid["generic_filter_zombie_blood_b"] );
    player set_filter_pass_enabled( filterid, 0, 1 );
    self thread zombie_blood_overlay_fade_in();
}

zombie_blood_overlay_fade_in()
{
    self endon( "entity_shutdown" );
    zombie_blood_overlay_lerp( 1.0, 0.2, 0.3 );
    wait 0.2;
    zombie_blood_overlay_lerp( 0.2, 0.8, 1.0 );
}

zombie_blood_overlay_lerp( n_fraction_start, n_fraction_end, n_trans_time )
{
    n_fraction_delta = n_fraction_end - n_fraction_start;
    set_filter_zombie_blood_overlay_amount( self, 1, n_fraction_start );

    for ( n_time = 0.0; n_time < n_trans_time; n_time = n_time + 0.0166667 )
    {
        n_fraction = n_fraction_start + n_fraction_delta * n_time / n_trans_time;
        set_filter_zombie_blood_overlay_amount( self, 1, n_fraction );
        wait 0.0166667;
    }

    set_filter_zombie_blood_overlay_amount( self, 1, n_fraction_end );
}

toggle_player_zombie_blood_fx( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if ( isspectating( localclientnum, 0 ) || isdemoplaying() )
        return;

    if ( newval == 1 )
    {
        if ( self islocalplayer() && self getlocalclientnumber() == localclientnum )
        {
            if ( !isdefined( self.zombie_blood_fx ) )
            {
                self.zombie_blood_fx = playviewmodelfx( localclientnum, level._effect["zombie_blood_1st"], "tag_camera" );
                playsound( localclientnum, "zmb_zombieblood_start", ( 0, 0, 0 ) );
                playloopat( "zmb_zombieblood_loop", ( 0, 0, 0 ) );
            }
        }
    }
    else if ( isdefined( self.zombie_blood_fx ) )
    {
        stopfx( localclientnum, self.zombie_blood_fx );
        playsound( localclientnum, "zmb_zombieblood_stop", ( 0, 0, 0 ) );
        stoploopat( "zmb_zombieblood_loop", ( 0, 0, 0 ) );
        self.zombie_blood_fx = undefined;
    }
}
