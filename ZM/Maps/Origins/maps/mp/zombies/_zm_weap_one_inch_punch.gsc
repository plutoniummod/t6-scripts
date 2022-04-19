// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_weap_staff_fire;
#include maps\mp\zombies\_zm_weap_staff_water;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_weap_staff_lightning;
#include maps\mp\animscripts\zm_shared;

one_inch_precache()
{
    precacheitem( "one_inch_punch_zm" );
    precacheitem( "one_inch_punch_fire_zm" );
    precacheitem( "one_inch_punch_air_zm" );
    precacheitem( "one_inch_punch_ice_zm" );
    precacheitem( "one_inch_punch_lightning_zm" );
    precacheitem( "one_inch_punch_upgraded_zm" );
    precacheitem( "zombie_one_inch_punch_flourish" );
    precacheitem( "zombie_one_inch_punch_upgrade_flourish" );
    level._effect["oneinch_impact"] = loadfx( "maps/zombie_tomb/fx_tomb_perk_one_inch_punch" );
    level._effect["punch_knockdown_ground"] = loadfx( "weapon/thunder_gun/fx_thundergun_knockback_ground" );
}

one_inch_punch_melee_attack()
{
    self endon( "disconnect" );
    self endon( "stop_one_inch_punch_attack" );

    if ( !( isdefined( self.one_inch_punch_flag_has_been_init ) && self.one_inch_punch_flag_has_been_init ) )
        self ent_flag_init( "melee_punch_cooldown" );

    self.one_inch_punch_flag_has_been_init = 1;
    current_melee_weapon = self get_player_melee_weapon();
    self takeweapon( current_melee_weapon );

    if ( isdefined( self.b_punch_upgraded ) && self.b_punch_upgraded )
    {
        str_weapon = self getcurrentweapon();
        self disable_player_move_states( 1 );
        self giveweapon( "zombie_one_inch_punch_upgrade_flourish" );
        self switchtoweapon( "zombie_one_inch_punch_upgrade_flourish" );
        self waittill_any( "player_downed", "weapon_change_complete" );
        self switchtoweapon( str_weapon );
        self enable_player_move_states();
        self takeweapon( "zombie_one_inch_punch_upgrade_flourish" );

        if ( self.str_punch_element == "air" )
        {
            self giveweapon( "one_inch_punch_air_zm" );
            self set_player_melee_weapon( "one_inch_punch_air_zm" );
        }
        else if ( self.str_punch_element == "fire" )
        {
            self giveweapon( "one_inch_punch_fire_zm" );
            self set_player_melee_weapon( "one_inch_punch_fire_zm" );
        }
        else if ( self.str_punch_element == "ice" )
        {
            self giveweapon( "one_inch_punch_ice_zm" );
            self set_player_melee_weapon( "one_inch_punch_ice_zm" );
        }
        else if ( self.str_punch_element == "lightning" )
        {
            self giveweapon( "one_inch_punch_lightning_zm" );
            self set_player_melee_weapon( "one_inch_punch_lightning_zm" );
        }
        else
        {
            self giveweapon( "one_inch_punch_upgraded_zm" );
            self set_player_melee_weapon( "one_inch_punch_upgraded_zm" );
        }
    }
    else
    {
        str_weapon = self getcurrentweapon();
        self disable_player_move_states( 1 );
        self giveweapon( "zombie_one_inch_punch_flourish" );
        self switchtoweapon( "zombie_one_inch_punch_flourish" );
        self waittill_any( "player_downed", "weapon_change_complete" );
        self switchtoweapon( str_weapon );
        self enable_player_move_states();
        self takeweapon( "zombie_one_inch_punch_flourish" );
        self giveweapon( "one_inch_punch_zm" );
        self set_player_melee_weapon( "one_inch_punch_zm" );
        self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "perk", "one_inch" );
    }

    self thread monitor_melee_swipe();
}

monitor_melee_swipe()
{
    self endon( "disconnect" );
    self notify( "stop_monitor_melee_swipe" );
    self endon( "stop_monitor_melee_swipe" );
    self endon( "bled_out" );

    while ( true )
    {
        while ( !self ismeleeing() )
            wait 0.05;

        if ( self getcurrentweapon() == level.riotshield_name )
        {
            wait 0.1;
            continue;
        }

        range_mod = 1;
        self setclientfield( "oneinchpunch_impact", 1 );
        wait_network_frame();
        self setclientfield( "oneinchpunch_impact", 0 );
        v_punch_effect_fwd = anglestoforward( self getplayerangles() );
        v_punch_yaw = get2dyaw( ( 0, 0, 0 ), v_punch_effect_fwd );

        if ( isdefined( self.b_punch_upgraded ) && self.b_punch_upgraded && isdefined( self.str_punch_element ) && self.str_punch_element == "air" )
            range_mod *= 2;

        a_zombies = getaispeciesarray( level.zombie_team, "all" );
        a_zombies = get_array_of_closest( self.origin, a_zombies, undefined, undefined, 100 );

        foreach ( zombie in a_zombies )
        {
            if ( self is_player_facing( zombie, v_punch_yaw ) && distancesquared( self.origin, zombie.origin ) <= 4096 * range_mod )
            {
                self thread zombie_punch_damage( zombie, 1 );
                continue;
            }

            if ( self is_player_facing( zombie, v_punch_yaw ) )
                self thread zombie_punch_damage( zombie, 0.5 );
        }

        while ( self ismeleeing() )
            wait 0.05;

        wait 0.05;
    }
}

is_player_facing( zombie, v_punch_yaw )
{
    v_player_to_zombie_yaw = get2dyaw( self.origin, zombie.origin );
    yaw_diff = v_player_to_zombie_yaw - v_punch_yaw;

    if ( yaw_diff < 0 )
        yaw_diff *= -1;

    if ( yaw_diff < 35 )
        return true;
    else
        return false;
}

is_oneinch_punch_damage()
{
    return isdefined( self.damageweapon ) && self.damageweapon == "one_inch_punch_zm";
}

gib_zombies_head( player )
{
    player endon( "disconnect" );
    self maps\mp\zombies\_zm_spawner::zombie_head_gib();
}

punch_cooldown()
{
    wait 1;
    self ent_flag_set( "melee_punch_cooldown" );
}

zombie_punch_damage( ai_zombie, n_mod )
{
    self endon( "disconnect" );
    ai_zombie.punch_handle_pain_notetracks = ::handle_punch_pain_notetracks;

    if ( isdefined( n_mod ) )
    {
        if ( isdefined( self.b_punch_upgraded ) && self.b_punch_upgraded )
            n_base_damage = 11275;
        else
            n_base_damage = 2250;

        n_damage = int( n_base_damage * n_mod );

        if ( !( isdefined( ai_zombie.is_mechz ) && ai_zombie.is_mechz ) )
        {
            if ( n_damage >= ai_zombie.health )
            {
                self thread zombie_punch_death( ai_zombie );
                self do_player_general_vox( "kill", "one_inch_punch" );

                if ( isdefined( self.b_punch_upgraded ) && self.b_punch_upgraded && isdefined( self.str_punch_element ) )
                {
                    switch ( self.str_punch_element )
                    {
                        case "fire":
                            ai_zombie thread maps\mp\zombies\_zm_weap_staff_fire::flame_damage_fx( self.current_melee_weapon, self, n_mod );
                            break;
                        case "ice":
                            ai_zombie thread maps\mp\zombies\_zm_weap_staff_water::ice_affect_zombie( self.current_melee_weapon, self, 0, n_mod );
                            break;
                        case "lightning":
                            if ( isdefined( ai_zombie.is_mechz ) && ai_zombie.is_mechz )
                                return;

                            if ( isdefined( ai_zombie.is_electrocuted ) && ai_zombie.is_electrocuted )
                                return;

                            tag = "J_SpineUpper";
                            network_safe_play_fx_on_tag( "lightning_impact", 2, level._effect["lightning_impact"], ai_zombie, tag );
                            ai_zombie thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "electrocute", ai_zombie.animname );
                            break;
                    }
                }
            }
            else
            {
                self maps\mp\zombies\_zm_score::player_add_points( "damage_light" );

                if ( isdefined( self.b_punch_upgraded ) && self.b_punch_upgraded && isdefined( self.str_punch_element ) )
                {
                    switch ( self.str_punch_element )
                    {
                        case "fire":
                            ai_zombie thread maps\mp\zombies\_zm_weap_staff_fire::flame_damage_fx( self.current_melee_weapon, self, n_mod );
                            break;
                        case "ice":
                            ai_zombie thread maps\mp\zombies\_zm_weap_staff_water::ice_affect_zombie( self.current_melee_weapon, self, 0, n_mod );
                            break;
                        case "lightning":
                            ai_zombie thread maps\mp\zombies\_zm_weap_staff_lightning::stun_zombie();
                            break;
                    }
                }
            }
        }

        ai_zombie dodamage( n_damage, ai_zombie.origin, self, self, 0, "MOD_MELEE", 0, self.current_melee_weapon );
    }
}

zombie_punch_death( ai_zombie )
{
    ai_zombie thread gib_zombies_head( self );

    if ( isdefined( level.ragdoll_limit_check ) && ![[ level.ragdoll_limit_check ]]() )
        return;

    if ( isdefined( ai_zombie ) )
    {
        ai_zombie startragdoll();
        ai_zombie setclientfield( "oneinchpunch_physics_launchragdoll", 1 );
    }

    wait_network_frame();

    if ( isdefined( ai_zombie ) )
        ai_zombie setclientfield( "oneinchpunch_physics_launchragdoll", 0 );
}

handle_punch_pain_notetracks( note )
{
    if ( note == "zombie_knockdown_ground_impact" )
        playfx( level._effect["punch_knockdown_ground"], self.origin, anglestoforward( self.angles ), anglestoup( self.angles ) );
}

knockdown_zombie_animate()
{
    self notify( "end_play_punch_pain_anim" );
    self endon( "killanimscript" );
    self endon( "death" );
    self endon( "end_play_punch_pain_anim" );

    if ( isdefined( self.marked_for_death ) && self.marked_for_death )
        return;

    self.allowpain = 0;
    animation_direction = undefined;
    animation_legs = "";
    animation_side = undefined;
    animation_duration = "_default";
    v_forward = vectordot( anglestoforward( self.angles ), vectornormalize( self.v_punched_from - self.origin ) );

    if ( v_forward > 0.6 )
    {
        animation_direction = "back";

        if ( !( isdefined( self.has_legs ) && self.has_legs ) )
            animation_legs = "_crawl";

        if ( randomint( 100 ) > 75 )
            animation_side = "belly";
        else
            animation_side = "back";
    }
    else if ( self.damageyaw > 75 && self.damageyaw < 135 )
    {
        animation_direction = "left";
        animation_side = "belly";
    }
    else if ( self.damageyaw > -135 && self.damageyaw < -75 )
    {
        animation_direction = "right";
        animation_side = "belly";
    }
    else
    {
        animation_direction = "front";
        animation_side = "belly";
    }

    self thread knockdown_zombie_animate_state();
    self setanimstatefromasd( "zm_punch_fall_" + animation_direction + animation_legs );
    self maps\mp\animscripts\zm_shared::donotetracks( "punch_fall_anim", self.punch_handle_pain_notetracks );

    if ( !( isdefined( self.has_legs ) && self.has_legs ) || isdefined( self.marked_for_death ) && self.marked_for_death )
        return;

    if ( isdefined( self.a.gib_ref ) )
    {
        if ( self.a.gib_ref == "no_legs" || self.a.gib_ref == "no_arms" || ( self.a.gib_ref == "left_leg" || self.a.gib_ref == "right_leg" ) && randomint( 100 ) > 25 || ( self.a.gib_ref == "left_arm" || self.a.gib_ref == "right_arm" ) && randomint( 100 ) > 75 )
            animation_duration = "_late";
        else if ( randomint( 100 ) > 75 )
            animation_duration = "_early";
    }
    else if ( randomint( 100 ) > 25 )
        animation_duration = "_early";

    self setanimstatefromasd( "zm_punch_getup_" + animation_side + animation_duration );
    self maps\mp\animscripts\zm_shared::donotetracks( "punch_getup_anim" );
    self.allowpain = 1;
    self notify( "back_up" );
}

knockdown_zombie_animate_state()
{
    self endon( "death" );
    self.is_knocked_down = 1;
    self waittill_any( "damage", "back_up" );
    self.is_knocked_down = 0;
}
