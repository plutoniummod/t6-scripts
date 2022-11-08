// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_perks;

init()
{
    level._random_zombie_perk_cost = 1500;
    level thread precache();
    level thread init_machines();
    registerclientfield( "scriptmover", "perk_bottle_cycle_state", 14000, 2, "int" );
    registerclientfield( "scriptmover", "turn_active_perk_light_red", 14000, 1, "int" );
    registerclientfield( "scriptmover", "turn_active_perk_light_green", 14000, 1, "int" );
    registerclientfield( "scriptmover", "turn_on_location_indicator", 14000, 1, "int" );
    registerclientfield( "scriptmover", "turn_active_perk_ball_light", 14000, 1, "int" );
    registerclientfield( "scriptmover", "zone_captured", 14000, 1, "int" );
    level._effect["perk_machine_light"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light" );
    level._effect["perk_machine_light_red"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light_red" );
    level._effect["perk_machine_light_green"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light_green" );
    level._effect["perk_machine_steam"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_steam" );
    level._effect["perk_machine_location"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_identify" );
    level._effect["perk_machine_activation_electric_loop"] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_on" );
    flag_init( "machine_can_reset" );
}

init_machines()
{
    machines = getentarray( "random_perk_machine", "targetname" );

    foreach ( machine in machines )
    {
        machine.artifact_glow_setting = 1;
        machine.machinery_glow_setting = 0.0;
        machine.is_current_ball_location = 0;
        machine.unitrigger_stub = spawnstruct();
        machine.unitrigger_stub.origin = machine.origin + anglestoright( machine.angles ) * 22.5;
        machine.unitrigger_stub.angles = machine.angles;
        machine.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
        machine.unitrigger_stub.script_width = 64;
        machine.unitrigger_stub.script_height = 64;
        machine.unitrigger_stub.script_length = 64;
        machine.unitrigger_stub.trigger_target = machine;
        unitrigger_force_per_player_triggers( machine.unitrigger_stub, 1 );
        machine.unitrigger_stub.prompt_and_visibility_func = ::wunderfizztrigger_update_prompt;
        level thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( machine.unitrigger_stub, ::wunderfizz_unitrigger_think );
    }
}

wunderfizztrigger_update_prompt( player )
{
    can_use = self wunderfizzstub_update_prompt( player );

    if ( isdefined( self.hint_string ) )
    {
        if ( isdefined( self.hint_parm1 ) )
            self sethintstring( self.hint_string, self.hint_parm1 );
        else
            self sethintstring( self.hint_string );
    }

    return can_use;
}

wunderfizzstub_update_prompt( player )
{
    self setcursorhint( "HINT_NOICON" );

    if ( !self trigger_visible_to_player( player ) )
        return false;

    self.hint_parm1 = undefined;

    if ( isdefined( self.stub.trigger_target.is_locked ) && self.stub.trigger_target.is_locked )
    {
        self.hint_string = &"ZM_TOMB_RPU";
        return false;
    }
    else if ( self.stub.trigger_target.is_current_ball_location )
    {
        if ( isdefined( self.stub.trigger_target.machine_user ) )
        {
            if ( isdefined( self.stub.trigger_target.grab_perk_hint ) && self.stub.trigger_target.grab_perk_hint )
            {
                n_purchase_limit = player get_player_perk_purchase_limit();

                if ( player.num_perks >= n_purchase_limit )
                {
                    self.hint_string = &"ZM_TOMB_RPT";
                    self.hint_parm1 = n_purchase_limit;
                    return false;
                }
                else
                {
                    self.hint_string = &"ZM_TOMB_RPP";
                    return true;
                }
            }
            else
                return false;
        }
        else
        {
            n_purchase_limit = player get_player_perk_purchase_limit();

            if ( player.num_perks >= n_purchase_limit )
            {
                self.hint_string = &"ZM_TOMB_RPT";
                self.hint_parm1 = n_purchase_limit;
                return false;
            }
            else
            {
                self.hint_string = &"ZM_TOMB_RPB";
                self.hint_parm1 = level._random_zombie_perk_cost;
                return true;
            }
        }
    }
    else
    {
        self.hint_string = &"ZM_TOMB_RPE";
        return false;
    }
}

trigger_visible_to_player( player )
{
    self setinvisibletoplayer( player );
    visible = 1;

    if ( isdefined( self.stub.trigger_target.machine_user ) )
    {
        if ( player != self.stub.trigger_target.machine_user || is_placeable_mine( self.stub.trigger_target.machine_user getcurrentweapon() ) )
            visible = 0;
    }
    else if ( !player can_buy_perk() )
        visible = 0;

    if ( !visible )
        return false;

    self setvisibletoplayer( player );
    return true;
}

can_buy_perk()
{
    if ( isdefined( self.is_drinking ) && self.is_drinking > 0 )
        return false;

    current_weapon = self getcurrentweapon();

    if ( is_placeable_mine( current_weapon ) || is_equipment_that_blocks_purchase( current_weapon ) )
        return false;

    if ( self in_revive_trigger() )
        return false;

    if ( current_weapon == "none" )
        return false;

    return true;
}

#using_animtree("zm_perk_random");

init_animtree()
{
    scriptmodelsuseanimtree( #animtree );
}

start_random_machine()
{
    level thread machines_setup();
    level thread machine_selector();
}

precache()
{
    precachemodel( "p6_zm_vending_diesel_magic" );
    precachemodel( "t6_wpn_zmb_perk_bottle_bear_world" );
}

machines_setup()
{
    wait 0.5;
    level.perk_bottle_weapon_array = arraycombine( level.machine_assets, level._custom_perks, 0, 1 );
    start_machines = getentarray( "start_machine", "script_noteworthy" );
    assert( isdefined( start_machines.size != 0 ), "missing start random perk machine" );

    if ( start_machines.size == 1 )
        level.random_perk_start_machine = start_machines[0];
    else
        level.random_perk_start_machine = start_machines[randomint( start_machines.size )];

    machines = getentarray( "random_perk_machine", "targetname" );

    foreach ( machine in machines )
    {
        spawn_location = spawn( "script_model", machine.origin );
        spawn_location setmodel( "tag_origin" );
        spawn_location.angles = machine.angles;
        forward_dir = anglestoright( machine.angles );
        spawn_location.origin += vectorscale( ( 0, 0, 1 ), 65.0 );
        machine.bottle_spawn_location = spawn_location;
        machine useanimtree( #animtree );
        machine thread machine_power_indicators();

        if ( machine != level.random_perk_start_machine )
        {
            machine hidepart( "j_ball" );
            machine.is_current_ball_location = 0;
        }
        else
        {
            level.wunderfizz_starting_machine = machine;
            level notify( "wunderfizz_setup" );
            machine thread machine_think();
        }

        wait_network_frame();
    }
}

machine_power_indicators()
{
    self setclientfield( "zone_captured", 1 );
    wait 1;
    self setclientfield( "zone_captured", 0 );

    while ( true )
    {
        self conditional_power_indicators();

        while ( isdefined( self.is_locked ) && self.is_locked )
            wait 1;

        self conditional_power_indicators();

        while ( !( isdefined( self.is_locked ) && self.is_locked ) )
            wait 1;
    }
}

conditional_power_indicators()
{
    if ( isdefined( self.is_locked ) && self.is_locked )
    {
        self setclientfield( "turn_active_perk_light_red", 0 );
        self setclientfield( "turn_active_perk_light_green", 0 );
        self setclientfield( "turn_active_perk_ball_light", 0 );
        self setclientfield( "zone_captured", 0 );
    }
    else if ( self.is_current_ball_location )
    {
        self setclientfield( "turn_active_perk_light_red", 0 );
        self setclientfield( "turn_active_perk_light_green", 1 );
        self setclientfield( "turn_active_perk_ball_light", 1 );
        self setclientfield( "zone_captured", 1 );
    }
    else
    {
        self setclientfield( "turn_active_perk_light_red", 1 );
        self setclientfield( "turn_active_perk_light_green", 0 );
        self setclientfield( "turn_active_perk_ball_light", 0 );
        self setclientfield( "zone_captured", 1 );
    }
}

wunderfizz_unitrigger_think( player )
{
    self endon( "kill_trigger" );

    while ( true )
    {
        self waittill( "trigger", player );

        self.stub.trigger_target notify( "trigger", player );
    }
}

machine_think()
{
    level notify( "machine_think" );
    level endon( "machine_think" );
    self thread machine_sounds();
    self show();
    self.num_time_used = 0;
    self.num_til_moved = randomintrange( 4, 7 );
    self.is_current_ball_location = 1;
    self setclientfield( "turn_on_location_indicator", 1 );
    self showpart( "j_ball" );
    self thread update_animation( "start" );

    while ( isdefined( self.is_locked ) && self.is_locked )
        wait 1;

    self conditional_power_indicators();

    while ( true )
    {
        self waittill( "trigger", player );

        flag_clear( "machine_can_reset" );
        level notify( "pmmove" );

        if ( player.score < level._random_zombie_perk_cost )
        {
            self playsound( "evt_perk_deny" );
            player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
            continue;
        }

        if ( self.num_time_used >= self.num_til_moved )
        {
            level notify( "pmmove" );
            self thread update_animation( "shut_down" );
            level notify( "random_perk_moving" );
            self setclientfield( "turn_on_location_indicator", 0 );
            self.is_current_ball_location = 0;
            self conditional_power_indicators();
            self hidepart( "j_ball" );
            break;
        }

        self.machine_user = player;
        self.num_time_used++;
        player maps\mp\zombies\_zm_stats::increment_client_stat( "use_perk_random" );
        player maps\mp\zombies\_zm_stats::increment_player_stat( "use_perk_random" );
        player maps\mp\zombies\_zm_score::minus_to_player_score( level._random_zombie_perk_cost );
        self thread update_animation( "in_use" );

        if ( isdefined( level.perk_random_vo_func_usemachine ) && isdefined( player ) )
            player thread [[ level.perk_random_vo_func_usemachine ]]();

        while ( true )
        {
            thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
            random_perk = get_weighted_random_perk( player );
            self setclientfield( "perk_bottle_cycle_state", 1 );
            level notify( "pmstrt" );
            wait 1.0;
            self thread start_perk_bottle_cycling();
            self thread perk_bottle_motion();
            model = get_perk_weapon_model( random_perk );
            wait 3.0;
            self notify( "done_cycling" );

            if ( self.num_time_used >= self.num_til_moved )
            {
                self.bottle_spawn_location setmodel( "t6_wpn_zmb_perk_bottle_bear_world" );
                level notify( "pmmove" );
                self thread update_animation( "shut_down" );
                wait 3;
                player maps\mp\zombies\_zm_score::add_to_player_score( level._random_zombie_perk_cost );
                self.bottle_spawn_location setmodel( "tag_origin" );
                level notify( "random_perk_moving" );
                self setclientfield( "perk_bottle_cycle_state", 0 );
                self setclientfield( "turn_on_location_indicator", 0 );
                self.is_current_ball_location = 0;
                self conditional_power_indicators();
                self hidepart( "j_ball" );
                self.machine_user = undefined;
                thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::wunderfizz_unitrigger_think );
                break;
            }
            else
                self.bottle_spawn_location setmodel( model );

            self.grab_perk_hint = 1;
            thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::wunderfizz_unitrigger_think );
            self thread grab_check( player, random_perk );
            self thread time_out_check();
            self waittill_either( "grab_check", "time_out_check" );
            self.grab_perk_hint = 0;
            thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
            thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::wunderfizz_unitrigger_think );
            level notify( "pmstop" );

            if ( player.num_perks >= player get_player_perk_purchase_limit() )
                player maps\mp\zombies\_zm_score::add_to_player_score( level._random_zombie_perk_cost );

            self setclientfield( "perk_bottle_cycle_state", 0 );
            self.machine_user = undefined;
            self.bottle_spawn_location setmodel( "tag_origin" );
            self thread update_animation( "idle" );
            break;
        }

        flag_wait( "machine_can_reset" );
    }
}

grab_check( player, random_perk )
{
    self endon( "time_out_check" );
    perk_is_bought = 0;

    while ( !perk_is_bought )
    {
        self waittill( "trigger", e_triggerer );

        if ( e_triggerer == player )
        {
            if ( isdefined( player.is_drinking ) && player.is_drinking > 0 )
            {
                wait 0.1;
                continue;
            }

            if ( player.num_perks < player get_player_perk_purchase_limit() )
                perk_is_bought = 1;
            else
            {
                self playsound( "evt_perk_deny" );
                player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "sigh" );
                self notify( "time_out_or_perk_grab" );
                return;
            }
        }
    }

    player maps\mp\zombies\_zm_stats::increment_client_stat( "grabbed_from_perk_random" );
    player maps\mp\zombies\_zm_stats::increment_player_stat( "grabbed_from_perk_random" );
    player thread monitor_when_player_acquires_perk();
    self notify( "grab_check" );
    self notify( "time_out_or_perk_grab" );
    gun = player maps\mp\zombies\_zm_perks::perk_give_bottle_begin( random_perk );
    evt = player waittill_any_return( "fake_death", "death", "player_downed", "weapon_change_complete" );

    if ( evt == "weapon_change_complete" )
        player thread maps\mp\zombies\_zm_perks::wait_give_perk( random_perk, 1 );

    player maps\mp\zombies\_zm_perks::perk_give_bottle_end( gun, random_perk );

    if ( !( isdefined( player.has_drunk_wunderfizz ) && player.has_drunk_wunderfizz ) )
    {
        player do_player_general_vox( "wunderfizz", "perk_wonder", undefined, 100 );
        player.has_drunk_wunderfizz = 1;
    }
}

monitor_when_player_acquires_perk()
{
    self waittill_any( "perk_acquired", "death_or_disconnect", "player_downed" );
    flag_set( "machine_can_reset" );
}

time_out_check()
{
    self endon( "grab_check" );
    wait 10.0;
    self notify( "time_out_check" );
    flag_set( "machine_can_reset" );
}

machine_selector()
{
    while ( true )
    {
        level waittill( "random_perk_moving" );

        machines = getentarray( "random_perk_machine", "targetname" );

        if ( machines.size == 1 )
        {
            new_machine = machines[0];
            new_machine thread machine_think();
            continue;
        }

        do
            new_machine = machines[randomint( machines.size )];
        while ( new_machine == level.random_perk_start_machine );

        level.random_perk_start_machine = new_machine;
        wait 10;
        new_machine thread machine_think();
    }
}

include_perk_in_random_rotation( perk )
{
    if ( !isdefined( level._random_perk_machine_perk_list ) )
        level._random_perk_machine_perk_list = [];

    level._random_perk_machine_perk_list = add_to_array( level._random_perk_machine_perk_list, perk );
}

get_weighted_random_perk( player )
{
    keys = array_randomize( getarraykeys( level._random_perk_machine_perk_list ) );

    if ( isdefined( level.custom_random_perk_weights ) )
        keys = player [[ level.custom_random_perk_weights ]]();
/#
    forced_perk = getdvar( _hash_B097C64C );

    if ( forced_perk != "" && isdefined( level._random_perk_machine_perk_list[forced_perk] ) )
        arrayinsert( keys, forced_perk, 0 );
#/
    for ( i = 0; i < keys.size; i++ )
    {
        if ( player hasperk( level._random_perk_machine_perk_list[keys[i]] ) )
            continue;
        else
            return level._random_perk_machine_perk_list[keys[i]];
    }

    return level._random_perk_machine_perk_list[keys[0]];
}

perk_bottle_motion()
{
    putouttime = 3;
    putbacktime = 10;
    v_float = anglestoforward( self.angles - ( 0, 90, 0 ) ) * 10;
    self.bottle_spawn_location.origin = self.origin + ( 0, 0, 53 );
    self.bottle_spawn_location.angles = self.angles;
    self.bottle_spawn_location.origin -= v_float;
    self.bottle_spawn_location moveto( self.bottle_spawn_location.origin + v_float, putouttime, putouttime * 0.5 );
    self.bottle_spawn_location.angles += ( 0, 0, 10 );
    self.bottle_spawn_location rotateyaw( 720, putouttime, putouttime * 0.5 );

    self waittill( "done_cycling" );

    self.bottle_spawn_location.angles = self.angles;
    self.bottle_spawn_location moveto( self.bottle_spawn_location.origin - v_float, putbacktime, putbacktime * 0.5 );
    self.bottle_spawn_location rotateyaw( 90, putbacktime, putbacktime * 0.5 );
}

start_perk_bottle_cycling()
{
    self endon( "done_cycling" );
    array_key = getarraykeys( level.perk_bottle_weapon_array );
    timer = 0;

    while ( true )
    {
        for ( i = 0; i < array_key.size; i++ )
        {
            if ( isdefined( level.perk_bottle_weapon_array[array_key[i]].weapon ) )
                model = getweaponmodel( level.perk_bottle_weapon_array[array_key[i]].weapon );
            else
                model = getweaponmodel( level.perk_bottle_weapon_array[array_key[i]].perk_bottle );

            self.bottle_spawn_location setmodel( model );
            wait 0.2;
        }
    }
}

get_perk_weapon_model( perk )
{
    switch ( perk )
    {
        case "specialty_armorvest":
        case " _upgrade":
            weapon = level.machine_assets["juggernog"].weapon;
            break;
        case "specialty_quickrevive_upgrade":
        case "specialty_quickrevive":
            weapon = level.machine_assets["revive"].weapon;
            break;
        case "specialty_fastreload_upgrade":
        case "specialty_fastreload":
            weapon = level.machine_assets["speedcola"].weapon;
            break;
        case "specialty_rof_upgrade":
        case "specialty_rof":
            weapon = level.machine_assets["doubletap"].weapon;
            break;
        case "specialty_longersprint_upgrade":
        case "specialty_longersprint":
            weapon = level.machine_assets["marathon"].weapon;
            break;
        case "specialty_flakjacket_upgrade":
        case "specialty_flakjacket":
            weapon = level.machine_assets["divetonuke"].weapon;
            break;
        case "specialty_deadshot_upgrade":
        case "specialty_deadshot":
            weapon = level.machine_assets["deadshot"].weapon;
            break;
        case "specialty_additionalprimaryweapon_upgrade":
        case "specialty_additionalprimaryweapon":
            weapon = level.machine_assets["additionalprimaryweapon"].weapon;
            break;
        case "specialty_scavenger_upgrade":
        case "specialty_scavenger":
            weapon = level.machine_assets["tombstone"].weapon;
            break;
        case "specialty_finalstand_upgrade":
        case "specialty_finalstand":
            weapon = level.machine_assets["whoswho"].weapon;
            break;
    }

    if ( isdefined( level._custom_perks[perk] ) && isdefined( level._custom_perks[perk].perk_bottle ) )
        weapon = level._custom_perks[perk].perk_bottle;

    return getweaponmodel( weapon );
}

update_animation( animation )
{
    switch ( animation )
    {
        case "start":
            self clearanim( %root, 0.2 );
            self setanim( %o_zombie_dlc4_vending_diesel_turn_on, 1, 0.2, 1 );
            break;
        case "shut_down":
            self clearanim( %root, 0.2 );
            self setanim( %o_zombie_dlc4_vending_diesel_turn_off, 1, 0.2, 1 );
            break;
        case "in_use":
            self clearanim( %root, 0.2 );
            self setanim( %o_zombie_dlc4_vending_diesel_ballspin_loop, 1, 0.2, 1 );
            break;
        case "idle":
            self clearanim( %root, 0.2 );
            self setanim( %o_zombie_dlc4_vending_diesel_on_idle, 1, 0.2, 1 );
            break;
        default:
            self clearanim( %root, 0.2 );
            self setanim( %o_zombie_dlc4_vending_diesel_on_idle, 1, 0.2, 1 );
            break;
    }
}

machine_sounds()
{
    level endon( "machine_think" );

    while ( true )
    {
        level waittill( "pmstrt" );

        rndprk_ent = spawn( "script_origin", self.origin );
        rndprk_ent stopsounds();
        rndprk_ent playsound( "zmb_rand_perk_start" );
        rndprk_ent playloopsound( "zmb_rand_perk_loop", 0.5 );
        state_switch = level waittill_any_return( "pmstop", "pmmove" );
        rndprk_ent stoploopsound( 1 );

        if ( state_switch == "pmstop" )
            rndprk_ent playsound( "zmb_rand_perk_stop" );
        else
            rndprk_ent playsound( "zmb_rand_perk_leave" );

        rndprk_ent delete();
    }
}
