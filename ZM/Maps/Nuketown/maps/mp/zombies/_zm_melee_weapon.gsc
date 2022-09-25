// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_audio;

init( weapon_name, flourish_weapon_name, ballistic_weapon_name, ballistic_upgraded_weapon_name, cost, wallbuy_targetname, hint_string, vo_dialog_id, has_weapon, give_weapon, take_weapon, flourish_fn )
{
    precacheitem( weapon_name );
    precacheitem( flourish_weapon_name );
    add_melee_weapon( weapon_name, flourish_weapon_name, ballistic_weapon_name, ballistic_upgraded_weapon_name, cost, wallbuy_targetname, hint_string, vo_dialog_id, has_weapon, give_weapon, take_weapon );
    melee_weapon_triggers = getentarray( wallbuy_targetname, "targetname" );

    for ( i = 0; i < melee_weapon_triggers.size; i++ )
    {
        knife_model = getent( melee_weapon_triggers[i].target, "targetname" );

        if ( isdefined( knife_model ) )
            knife_model hide();

        melee_weapon_triggers[i] thread melee_weapon_think( weapon_name, cost, has_weapon, give_weapon, flourish_fn, vo_dialog_id, flourish_weapon_name, ballistic_weapon_name, ballistic_upgraded_weapon_name );
        melee_weapon_triggers[i] sethintstring( hint_string, cost );
        melee_weapon_triggers[i] setcursorhint( "HINT_NOICON" );
        melee_weapon_triggers[i] usetriggerrequirelookat();
    }

    melee_weapon_structs = getstructarray( wallbuy_targetname, "targetname" );

    for ( i = 0; i < melee_weapon_structs.size; i++ )
    {
        if ( isdefined( melee_weapon_structs[i].trigger_stub ) )
        {
            melee_weapon_structs[i].trigger_stub.hint_string = hint_string;
            melee_weapon_structs[i].trigger_stub.cost = cost;
            melee_weapon_structs[i].trigger_stub.weapon_name = weapon_name;
            melee_weapon_structs[i].trigger_stub.has_weapon = has_weapon;
            melee_weapon_structs[i].trigger_stub.give_weapon = give_weapon;
            melee_weapon_structs[i].trigger_stub.vo_dialog_id = vo_dialog_id;
            melee_weapon_structs[i].trigger_stub.flourish_weapon_name = flourish_weapon_name;
            melee_weapon_structs[i].trigger_stub.ballistic_weapon_name = ballistic_weapon_name;
            melee_weapon_structs[i].trigger_stub.ballistic_upgraded_weapon_name = ballistic_upgraded_weapon_name;
            melee_weapon_structs[i].trigger_stub.trigger_func = ::melee_weapon_think;
            melee_weapon_structs[i].trigger_stub.flourish_fn = flourish_fn;
        }
    }

    register_melee_weapon_for_level( weapon_name );

    if ( !isdefined( level.ballistic_weapon_name ) )
        level.ballistic_weapon_name = [];

    level.ballistic_weapon_name[weapon_name] = ballistic_weapon_name;

    if ( !isdefined( level.ballistic_upgraded_weapon_name ) )
        level.ballistic_upgraded_weapon_name = [];

    level.ballistic_upgraded_weapon_name[weapon_name] = ballistic_upgraded_weapon_name;
}

add_melee_weapon( weapon_name, flourish_weapon_name, ballistic_weapon_name, ballistic_upgraded_weapon_name, cost, wallbuy_targetname, hint_string, vo_dialog_id, has_weapon, give_weapon, take_weapon, flourish_fn )
{
    melee_weapon = spawnstruct();
    melee_weapon.weapon_name = weapon_name;
    melee_weapon.flourish_weapon_name = flourish_weapon_name;
    melee_weapon.ballistic_weapon_name = ballistic_weapon_name;
    melee_weapon.ballistic_upgraded_weapon_name = ballistic_upgraded_weapon_name;
    melee_weapon.cost = cost;
    melee_weapon.wallbuy_targetname = wallbuy_targetname;
    melee_weapon.hint_string = hint_string;
    melee_weapon.vo_dialog_id = vo_dialog_id;
    melee_weapon.has_weapon = has_weapon;
    melee_weapon.give_weapon = give_weapon;
    melee_weapon.take_weapon = take_weapon;
    melee_weapon.flourish_fn = flourish_fn;

    if ( !isdefined( level._melee_weapons ) )
        level._melee_weapons = [];

    level._melee_weapons[level._melee_weapons.size] = melee_weapon;
}

spectator_respawn_all()
{
    for ( i = 0; i < level._melee_weapons.size; i++ )
        self [[ level._melee_weapons[i].take_weapon ]]();

    for ( i = 0; i < level._melee_weapons.size; i++ )
        self spectator_respawn( level._melee_weapons[i].wallbuy_targetname, level._melee_weapons[i].take_weapon, level._melee_weapons[i].has_weapon );
}

spectator_respawn( wallbuy_targetname, take_weapon, has_weapon )
{
    melee_triggers = getentarray( wallbuy_targetname, "targetname" );
    players = get_players();

    for ( i = 0; i < melee_triggers.size; i++ )
    {
        melee_triggers[i] setvisibletoall();

        if ( !( isdefined( level._allow_melee_weapon_switching ) && level._allow_melee_weapon_switching ) )
        {
            for ( j = 0; j < players.size; j++ )
            {
                if ( players[j] [[ has_weapon ]]() )
                    melee_triggers[i] setinvisibletoplayer( players[j] );
            }
        }
    }
}

trigger_hide_all()
{
    for ( i = 0; i < level._melee_weapons.size; i++ )
        self trigger_hide( level._melee_weapons[i].wallbuy_targetname );
}

trigger_hide( wallbuy_targetname )
{
    melee_triggers = getentarray( wallbuy_targetname, "targetname" );

    for ( i = 0; i < melee_triggers.size; i++ )
        melee_triggers[i] setinvisibletoplayer( self );
}

has_any_ballistic_knife()
{
    if ( self hasweapon( "knife_ballistic_zm" ) )
        return true;

    if ( self hasweapon( "knife_ballistic_upgraded_zm" ) )
        return true;

    for ( i = 0; i < level._melee_weapons.size; i++ )
    {
        if ( self hasweapon( level._melee_weapons[i].ballistic_weapon_name ) )
            return true;

        if ( self hasweapon( level._melee_weapons[i].ballistic_upgraded_weapon_name ) )
            return true;
    }

    return false;
}

has_upgraded_ballistic_knife()
{
    if ( self hasweapon( "knife_ballistic_upgraded_zm" ) )
        return true;

    for ( i = 0; i < level._melee_weapons.size; i++ )
    {
        if ( self hasweapon( level._melee_weapons[i].ballistic_upgraded_weapon_name ) )
            return true;
    }

    return false;
}

give_ballistic_knife( weapon_string, upgraded )
{
    current_melee_weapon = self get_player_melee_weapon();

    if ( isdefined( current_melee_weapon ) )
    {
        if ( upgraded && isdefined( level.ballistic_upgraded_weapon_name ) && isdefined( level.ballistic_upgraded_weapon_name[current_melee_weapon] ) )
            weapon_string = level.ballistic_upgraded_weapon_name[current_melee_weapon];

        if ( !upgraded && isdefined( level.ballistic_weapon_name ) && isdefined( level.ballistic_weapon_name[current_melee_weapon] ) )
            weapon_string = level.ballistic_weapon_name[current_melee_weapon];
    }

    return weapon_string;
}

change_melee_weapon( weapon_name, current_weapon )
{
    current_melee_weapon = self get_player_melee_weapon();

    if ( isdefined( current_melee_weapon ) )
    {
        self takeweapon( current_melee_weapon );
        unacquire_weapon_toggle( current_melee_weapon );
    }

    self set_player_melee_weapon( weapon_name );
    had_ballistic = 0;
    had_ballistic_upgraded = 0;
    ballistic_was_primary = 0;
    primaryweapons = self getweaponslistprimaries();

    for ( i = 0; i < primaryweapons.size; i++ )
    {
        primary_weapon = primaryweapons[i];

        if ( issubstr( primary_weapon, "knife_ballistic_" ) )
        {
            had_ballistic = 1;

            if ( primary_weapon == current_weapon )
                ballistic_was_primary = 1;

            self notify( "zmb_lost_knife" );
            self takeweapon( primary_weapon );
            unacquire_weapon_toggle( primary_weapon );

            if ( issubstr( primary_weapon, "upgraded" ) )
                had_ballistic_upgraded = 1;
        }
    }

    if ( had_ballistic )
    {
        if ( had_ballistic_upgraded )
        {
            new_ballistic = level.ballistic_upgraded_weapon_name[weapon_name];

            if ( ballistic_was_primary )
                current_weapon = new_ballistic;

            self giveweapon( new_ballistic, 0, self maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( new_ballistic ) );
        }
        else
        {
            new_ballistic = level.ballistic_weapon_name[weapon_name];

            if ( ballistic_was_primary )
                current_weapon = new_ballistic;

            self giveweapon( new_ballistic, 0 );
        }
    }

    return current_weapon;
}

melee_weapon_think( weapon_name, cost, has_weapon, give_weapon, flourish_fn, vo_dialog_id, flourish_weapon_name, ballistic_weapon_name, ballistic_upgraded_weapon_name )
{
    self.first_time_triggered = 0;

    if ( isdefined( self.stub ) )
    {
        self endon( "kill_trigger" );

        if ( isdefined( self.stub.first_time_triggered ) )
            self.first_time_triggered = self.stub.first_time_triggered;

        weapon_name = self.stub.weapon_name;
        cost = self.stub.cost;
        has_weapon = self.stub.has_weapon;
        give_weapon = self.stub.give_weapon;
        flourish_fn = self.stub.flourish_fn;
        vo_dialog_id = self.stub.vo_dialog_id;
        flourish_weapon_name = self.stub.flourish_weapon_name;
        ballistic_weapon_name = self.stub.ballistic_weapon_name;
        ballistic_upgraded_weapon_name = self.stub.ballistic_upgraded_weapon_name;
        players = getplayers();

        if ( !( isdefined( level._allow_melee_weapon_switching ) && level._allow_melee_weapon_switching ) )
        {
            for ( i = 0; i < players.size; i++ )
            {
                if ( players[i] [[ has_weapon ]]() )
                    self setinvisibletoplayer( players[i] );
            }
        }
    }

    for (;;)
    {
        self waittill( "trigger", player );

        if ( !is_player_valid( player ) )
        {
            player thread ignore_triggers( 0.5 );
            continue;
        }

        if ( player in_revive_trigger() )
        {
            wait 0.1;
            continue;
        }

        if ( player isthrowinggrenade() )
        {
            wait 0.1;
            continue;
        }

        if ( player.is_drinking > 0 )
        {
            wait 0.1;
            continue;
        }

        if ( player hasweapon( weapon_name ) || player has_powerup_weapon() )
        {
            wait 0.1;
            continue;
        }

        if ( player isswitchingweapons() )
        {
            wait 0.1;
            continue;
        }

        current_weapon = player getcurrentweapon();

        if ( is_placeable_mine( current_weapon ) || is_equipment( current_weapon ) || player has_powerup_weapon() )
        {
            wait 0.1;
            continue;
        }

        if ( player maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined( player.intermission ) && player.intermission )
        {
            wait 0.1;
            continue;
        }

        player_has_weapon = player [[ has_weapon ]]();

        if ( !player_has_weapon )
        {
            if ( player.score >= cost )
            {
                if ( self.first_time_triggered == 0 )
                {
                    model = getent( self.target, "targetname" );

                    if ( isdefined( model ) )
                        model thread melee_weapon_show( player );
                    else if ( isdefined( self.clientfieldname ) )
                        level setclientfield( self.clientfieldname, 1 );

                    self.first_time_triggered = 1;

                    if ( isdefined( self.stub ) )
                        self.stub.first_time_triggered = 1;
                }

                player maps\mp\zombies\_zm_score::minus_to_player_score( cost );
                bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", player.name, player.score, level.round_number, cost, weapon_name, self.origin, "weapon" );
                player thread give_melee_weapon( vo_dialog_id, flourish_weapon_name, weapon_name, ballistic_weapon_name, ballistic_upgraded_weapon_name, give_weapon, flourish_fn, self );
            }
            else
            {
                play_sound_on_ent( "no_purchase" );
                player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "no_money_weapon", undefined, 1 );
            }

            continue;
        }

        if ( !( isdefined( level._allow_melee_weapon_switching ) && level._allow_melee_weapon_switching ) )
            self setinvisibletoplayer( player );
    }
}

melee_weapon_show( player )
{
    player_angles = vectortoangles( player.origin - self.origin );
    player_yaw = player_angles[1];
    weapon_yaw = self.angles[1];
    yaw_diff = angleclamp180( player_yaw - weapon_yaw );

    if ( yaw_diff > 0 )
        yaw = weapon_yaw - 90;
    else
        yaw = weapon_yaw + 90;

    self.og_origin = self.origin;
    self.origin += anglestoforward( ( 0, yaw, 0 ) ) * 8;
    wait 0.05;
    self show();
    play_sound_at_pos( "weapon_show", self.origin, self );
    time = 1;
    self moveto( self.og_origin, time );
}

give_melee_weapon( vo_dialog_id, flourish_weapon_name, weapon_name, ballistic_weapon_name, ballistic_upgraded_weapon_name, give_weapon, flourish_fn, trigger )
{
    if ( isdefined( flourish_fn ) )
        self thread [[ flourish_fn ]]();

    gun = self do_melee_weapon_flourish_begin( flourish_weapon_name );
    self maps\mp\zombies\_zm_audio::create_and_play_dialog( "weapon_pickup", vo_dialog_id );
    self waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );
    self do_melee_weapon_flourish_end( gun, flourish_weapon_name, weapon_name, ballistic_weapon_name, ballistic_upgraded_weapon_name );

    if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined( self.intermission ) && self.intermission )
        return;

    self [[ give_weapon ]]();

    if ( !( isdefined( level._allow_melee_weapon_switching ) && level._allow_melee_weapon_switching ) )
    {
        trigger setinvisibletoplayer( self );
        self trigger_hide_all();
    }
}

do_melee_weapon_flourish_begin( flourish_weapon_name )
{
    self increment_is_drinking();
    self disable_player_move_states( 1 );
    gun = self getcurrentweapon();
    weapon = flourish_weapon_name;
    self giveweapon( weapon );
    self switchtoweapon( weapon );
    return gun;
}

do_melee_weapon_flourish_end( gun, flourish_weapon_name, weapon_name, ballistic_weapon_name, ballistic_upgraded_weapon_name )
{
    assert( gun != "zombie_perk_bottle_doubletap" );
    assert( gun != "zombie_perk_bottle_revive" );
    assert( gun != "zombie_perk_bottle_jugg" );
    assert( gun != "zombie_perk_bottle_sleight" );
    assert( gun != "zombie_perk_bottle_marathon" );
    assert( gun != "zombie_perk_bottle_nuke" );
    assert( gun != "zombie_perk_bottle_deadshot" );
    assert( gun != "zombie_perk_bottle_additionalprimaryweapon" );
    assert( gun != "zombie_perk_bottle_tombstone" );
    assert( gun != level.revive_tool );
    self enable_player_move_states();
    weapon = flourish_weapon_name;

    if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined( self.intermission ) && self.intermission )
    {
        self takeweapon( weapon );
        self.lastactiveweapon = "none";
        return;
    }

    self takeweapon( weapon );
    self giveweapon( weapon_name );
    gun = change_melee_weapon( weapon_name, gun );

    if ( self hasweapon( "knife_zm" ) )
        self takeweapon( "knife_zm" );

    if ( self is_multiple_drinking() )
    {
        self decrement_is_drinking();
        return;
    }
    else if ( gun == "knife_zm" )
    {
        self switchtoweapon( weapon_name );
        self decrement_is_drinking();
        return;
    }
    else if ( gun != "none" && !is_placeable_mine( gun ) && !is_equipment( gun ) )
        self switchtoweapon( gun );
    else
    {
        primaryweapons = self getweaponslistprimaries();

        if ( isdefined( primaryweapons ) && primaryweapons.size > 0 )
            self switchtoweapon( primaryweapons[0] );
    }

    self waittill( "weapon_change_complete" );

    if ( !self maps\mp\zombies\_zm_laststand::player_is_in_laststand() && !( isdefined( self.intermission ) && self.intermission ) )
        self decrement_is_drinking();
}
