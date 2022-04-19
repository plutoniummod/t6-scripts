// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_equip_hacker;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_audio;

box_hacks()
{
    boxes = getstructarray( "treasure_chest_use", "targetname" );

    for ( i = 0; i < boxes.size; i++ )
    {
        box = boxes[i];
        box.box_hacks["respin"] = ::init_box_respin;
        box.box_hacks["respin_respin"] = ::init_box_respin_respin;
        box.box_hacks["summon_box"] = ::init_summon_box;
        box.last_hacked_round = 0;
    }

    level._zombiemode_chest_joker_chance_override_func = ::check_for_free_locations;
    level._zombiemode_custom_box_move_logic = ::custom_box_move_logic;
    level._zombiemode_check_firesale_loc_valid_func = ::custom_check_firesale_loc_valid_func;
    init_summon_hacks();
}

custom_check_firesale_loc_valid_func()
{
    if ( isdefined( self.unitrigger_stub ) )
        box = self.unitrigger_stub.trigger_target;
    else if ( isdefined( self.stub ) )
        box = self.stub.trigger_target;

    if ( box.last_hacked_round >= level.round_number )
        return false;

    return true;
}

custom_box_move_logic()
{
    num_hacked_locs = 0;

    for ( i = 0; i < level.chests.size; i++ )
    {
        if ( level.chests[i].last_hacked_round >= level.round_number )
            num_hacked_locs++;
    }

    if ( num_hacked_locs == 0 )
    {
        maps\mp\zombies\_zm_magicbox::default_box_move_logic();
        return;
    }

    found_loc = 0;
    original_spot = level.chest_index;

    while ( !found_loc )
    {
        level.chest_index++;

        if ( original_spot == level.chest_index )
            level.chest_index++;

        level.chest_index %= level.chests.size;

        if ( level.chests[level.chest_index].last_hacked_round < level.round_number )
            found_loc = 1;
    }
}

check_for_free_locations( chance )
{
    boxes = level.chests;
    stored_chance = chance;
    chance = -1;

    for ( i = 0; i < boxes.size; i++ )
    {
        if ( i == level.chest_index )
            continue;

        if ( boxes[i].last_hacked_round < level.round_number )
        {
            chance = stored_chance;
            break;
        }
    }

    return chance;
}

init_box_respin( chest, player )
{
    self thread box_respin_think( chest, player );
}

box_respin_think( chest, player )
{
    respin_hack = spawnstruct();
    respin_hack.origin = self.origin + vectorscale( ( 0, 0, 1 ), 24.0 );
    respin_hack.radius = 48;
    respin_hack.height = 72;
    respin_hack.script_int = 600;
    respin_hack.script_float = 1.5;
    respin_hack.player = player;
    respin_hack.no_bullet_trace = 1;
    respin_hack.chest = chest;
    maps\mp\zombies\_zm_equip_hacker::register_pooled_hackable_struct( respin_hack, ::respin_box, ::hack_box_qualifier );
    self.weapon_model waittill_either( "death", "kill_respin_think_thread" );
    maps\mp\zombies\_zm_equip_hacker::deregister_hackable_struct( respin_hack );
}

respin_box_thread( hacker )
{
    if ( isdefined( self.chest.zbarrier.weapon_model ) )
        self.chest.zbarrier.weapon_model notify( "kill_respin_think_thread" );

    self.chest.no_fly_away = 1;
    self.chest.zbarrier notify( "box_hacked_respin" );
    self.chest disable_trigger();
    play_sound_at_pos( "open_chest", self.chest.zbarrier.origin );
    play_sound_at_pos( "music_chest", self.chest.zbarrier.origin );
    maps\mp\zombies\_zm_weapons::unacquire_weapon_toggle( self.chest.zbarrier.weapon_string );
    self.chest.zbarrier thread maps\mp\zombies\_zm_magicbox::treasure_chest_weapon_spawn( self.chest, hacker, 1 );

    self.chest.zbarrier waittill( "randomization_done" );

    self.chest.no_fly_away = undefined;

    if ( !flag( "moving_chest_now" ) )
    {
        self.chest enable_trigger();
        self.chest thread maps\mp\zombies\_zm_magicbox::treasure_chest_timeout();
    }
}

respin_box( hacker )
{
    self thread respin_box_thread( hacker );
}

hack_box_qualifier( player )
{
    if ( player == self.chest.chest_user && isdefined( self.chest.weapon_out ) )
        return true;

    return false;
}

init_box_respin_respin( chest, player )
{
    self thread box_respin_respin_think( chest, player );
}

box_respin_respin_think( chest, player )
{
    respin_hack = spawnstruct();
    respin_hack.origin = self.origin + vectorscale( ( 0, 0, 1 ), 24.0 );
    respin_hack.radius = 48;
    respin_hack.height = 72;
    respin_hack.script_int = -950;
    respin_hack.script_float = 1.5;
    respin_hack.player = player;
    respin_hack.no_bullet_trace = 1;
    respin_hack.chest = chest;
    maps\mp\zombies\_zm_equip_hacker::register_pooled_hackable_struct( respin_hack, ::respin_respin_box, ::hack_box_qualifier );
    self.weapon_model waittill_either( "death", "kill_respin_respin_think_thread" );
    maps\mp\zombies\_zm_equip_hacker::deregister_hackable_struct( respin_hack );
}

respin_respin_box( hacker )
{
    org = self.chest.zbarrier.origin;

    if ( isdefined( self.chest.zbarrier.weapon_model ) )
    {
        self.chest.zbarrier.weapon_model notify( "kill_respin_respin_think_thread" );
        self.chest.zbarrier.weapon_model notify( "kill_weapon_movement" );
        self.chest.zbarrier.weapon_model moveto( org + vectorscale( ( 0, 0, 1 ), 40.0 ), 0.5 );
    }

    if ( isdefined( self.chest.zbarrier.weapon_model_dw ) )
    {
        self.chest.zbarrier.weapon_model_dw notify( "kill_weapon_movement" );
        self.chest.zbarrier.weapon_model_dw moveto( org + vectorscale( ( 0, 0, 1 ), 40.0 ) - vectorscale( ( 1, 1, 1 ), 3.0 ), 0.5 );
    }

    self.chest.zbarrier notify( "box_hacked_rerespin" );
    self.chest.box_rerespun = 1;
    self thread fake_weapon_powerup_thread( self.chest.zbarrier.weapon_model, self.chest.zbarrier.weapon_model_dw );
}

fake_weapon_powerup_thread( weapon1, weapon2 )
{
    weapon1 endon( "death" );
    playfxontag( level._effect["powerup_on_solo"], weapon1, "tag_origin" );
    playsoundatposition( "zmb_spawn_powerup", weapon1.origin );
    weapon1 playloopsound( "zmb_spawn_powerup_loop" );
    self thread fake_weapon_powerup_timeout( weapon1, weapon2 );

    while ( isdefined( weapon1 ) )
    {
        waittime = randomfloatrange( 2.5, 5 );
        yaw = randomint( 360 );

        if ( yaw > 300 )
            yaw = 300;
        else if ( yaw < 60 )
            yaw = 60;

        yaw = weapon1.angles[1] + yaw;
        weapon1 rotateto( ( -60 + randomint( 120 ), yaw, -45 + randomint( 90 ) ), waittime, waittime * 0.5, waittime * 0.5 );

        if ( isdefined( weapon2 ) )
            weapon2 rotateto( ( -60 + randomint( 120 ), yaw, -45 + randomint( 90 ) ), waittime, waittime * 0.5, waittime * 0.5 );

        wait( randomfloat( waittime - 0.1 ) );
    }
}

fake_weapon_powerup_timeout( weapon1, weapon2 )
{
    weapon1 endon( "death" );
    wait 15;

    for ( i = 0; i < 40; i++ )
    {
        if ( i % 2 )
        {
            weapon1 hide();

            if ( isdefined( weapon2 ) )
                weapon2 hide();
        }
        else
        {
            weapon1 show();

            if ( isdefined( weapon2 ) )
                weapon2 hide();
        }

        if ( i < 15 )
        {
            wait 0.5;
            continue;
        }

        if ( i < 25 )
        {
            wait 0.25;
            continue;
        }

        wait 0.1;
    }

    self.chest notify( "trigger", level );

    if ( isdefined( weapon1 ) )
        weapon1 delete();

    if ( isdefined( weapon2 ) )
        weapon2 delete();
}

init_summon_hacks()
{
    chests = getstructarray( "treasure_chest_use", "targetname" );

    for ( i = 0; i < chests.size; i++ )
    {
        chest = chests[i];
        chest init_summon_box( chest.hidden );
    }
}

init_summon_box( create )
{
    if ( create )
    {
        if ( isdefined( self._summon_hack_struct ) )
        {
            maps\mp\zombies\_zm_equip_hacker::deregister_hackable_struct( self._summon_hack_struct );
            self._summon_hack_struct = undefined;
        }

        struct = spawnstruct();
        struct.origin = self.chest_box.origin + vectorscale( ( 0, 0, 1 ), 24.0 );
        struct.radius = 48;
        struct.height = 72;
        struct.script_int = 1200;
        struct.script_float = 5;
        struct.no_bullet_trace = 1;
        struct.chest = self;
        self._summon_hack_struct = struct;
        maps\mp\zombies\_zm_equip_hacker::register_pooled_hackable_struct( struct, ::summon_box, ::summon_box_qualifier );
    }
    else if ( isdefined( self._summon_hack_struct ) )
    {
        maps\mp\zombies\_zm_equip_hacker::deregister_hackable_struct( self._summon_hack_struct );
        self._summon_hack_struct = undefined;
    }
}

summon_box_thread( hacker )
{
    self.chest.last_hacked_round = level.round_number + randomintrange( 2, 5 );
    maps\mp\zombies\_zm_equip_hacker::deregister_hackable_struct( self );
    self.chest thread maps\mp\zombies\_zm_magicbox::show_chest();
    self.chest notify( "kill_chest_think" );
    self.chest.auto_open = 1;
    self.chest.no_charge = 1;
    self.chest.no_fly_away = 1;
    self.chest.forced_user = hacker;
    self.chest thread maps\mp\zombies\_zm_magicbox::treasure_chest_think();

    self.chest.zbarrier waittill( "closed" );

    self.chest.forced_user = undefined;
    self.chest.auto_open = undefined;
    self.chest.no_charge = undefined;
    self.chest.no_fly_away = undefined;
    self.chest thread maps\mp\zombies\_zm_magicbox::hide_chest();
}

summon_box( hacker )
{
    self thread summon_box_thread( hacker );

    if ( isdefined( hacker ) )
        hacker thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "hack_box" );
}

summon_box_qualifier( player )
{
    if ( self.chest.last_hacked_round > level.round_number )
        return false;

    if ( isdefined( self.chest.zbarrier.chest_moving ) && self.chest.zbarrier.chest_moving )
        return false;

    return true;
}
