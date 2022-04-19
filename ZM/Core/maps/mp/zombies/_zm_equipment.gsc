// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_spawner;

init()
{
    init_equipment_upgrade();
    onplayerconnect_callback( ::equipment_placement_watcher );
    level._equipment_disappear_fx = loadfx( "maps/zombie/fx_zmb_tranzit_electrap_explo" );

    if ( !( isdefined( level.disable_fx_zmb_tranzit_shield_explo ) && level.disable_fx_zmb_tranzit_shield_explo ) )
        level._riotshield_dissapear_fx = loadfx( "maps/zombie/fx_zmb_tranzit_shield_explo" );

    level.placeable_equipment_destroy_fn = [];

    if ( !( isdefined( level._no_equipment_activated_clientfield ) && level._no_equipment_activated_clientfield ) )
        registerclientfield( "scriptmover", "equipment_activated", 12000, 4, "int" );
}

signal_equipment_activated( val )
{
    if ( !isdefined( val ) )
        val = 1;

    if ( isdefined( level._no_equipment_activated_clientfield ) && level._no_equipment_activated_clientfield )
        return;

    self endon( "death" );
    self setclientfield( "equipment_activated", val );

    for ( i = 0; i < 2; i++ )
        wait_network_frame();

    self setclientfield( "equipment_activated", 0 );
}

register_equipment( equipment_name, hint, howto_hint, hint_icon, equipmentvo, watcher_thread, transfer_fn, drop_fn, pickup_fn, place_fn )
{
    if ( !isdefined( level.zombie_include_equipment ) || !( isdefined( level.zombie_include_equipment[equipment_name] ) && level.zombie_include_equipment[equipment_name] ) )
        return;

    precachestring( hint );

    if ( isdefined( hint_icon ) )
        precacheshader( hint_icon );

    struct = spawnstruct();

    if ( !isdefined( level.zombie_equipment ) )
        level.zombie_equipment = [];

    struct.equipment_name = equipment_name;
    struct.hint = hint;
    struct.howto_hint = howto_hint;
    struct.hint_icon = hint_icon;
    struct.vox = equipmentvo;
    struct.triggers = [];
    struct.models = [];
    struct.watcher_thread = watcher_thread;
    struct.transfer_fn = transfer_fn;
    struct.drop_fn = drop_fn;
    struct.pickup_fn = pickup_fn;
    struct.place_fn = place_fn;
    level.zombie_equipment[equipment_name] = struct;
}

is_equipment_included( equipment_name )
{
    if ( !isdefined( level.zombie_include_equipment ) )
        return 0;

    return isdefined( level.zombie_include_equipment[equipment_name] );
}

include_zombie_equipment( equipment_name )
{
    if ( !isdefined( level.zombie_include_equipment ) )
        level.zombie_include_equipment = [];

    level.zombie_include_equipment[equipment_name] = 1;
    precacheitem( equipment_name );
}

limit_zombie_equipment( equipment_name, limited )
{
    if ( !isdefined( level._limited_equipment ) )
        level._limited_equipment = [];

    if ( limited )
        level._limited_equipment[level._limited_equipment.size] = equipment_name;
    else
        arrayremovevalue( level._limited_equipment, equipment_name, 0 );
}

init_equipment_upgrade()
{
    equipment_spawns = [];
    equipment_spawns = getentarray( "zombie_equipment_upgrade", "targetname" );

    for ( i = 0; i < equipment_spawns.size; i++ )
    {
        hint_string = get_equipment_hint( equipment_spawns[i].zombie_equipment_upgrade );
        equipment_spawns[i] sethintstring( hint_string );
        equipment_spawns[i] setcursorhint( "HINT_NOICON" );
        equipment_spawns[i] usetriggerrequirelookat();
        equipment_spawns[i] add_to_equipment_trigger_list( equipment_spawns[i].zombie_equipment_upgrade );
        equipment_spawns[i] thread equipment_spawn_think();
    }
}

get_equipment_hint( equipment_name )
{
/#
    assert( isdefined( level.zombie_equipment[equipment_name] ), equipment_name + " was not included or is not registered with the equipment system." );
#/
    return level.zombie_equipment[equipment_name].hint;
}

get_equipment_howto_hint( equipment_name )
{
/#
    assert( isdefined( level.zombie_equipment[equipment_name] ), equipment_name + " was not included or is not registered with the equipment system." );
#/
    return level.zombie_equipment[equipment_name].howto_hint;
}

get_equipment_icon( equipment_name )
{
/#
    assert( isdefined( level.zombie_equipment[equipment_name] ), equipment_name + " was not included or is not registered with the equipment system." );
#/
    return level.zombie_equipment[equipment_name].hint_icon;
}

add_to_equipment_trigger_list( equipment_name )
{
/#
    assert( isdefined( level.zombie_equipment[equipment_name] ), equipment_name + " was not included or is not registered with the equipment system." );
#/
    level.zombie_equipment[equipment_name].triggers[level.zombie_equipment[equipment_name].triggers.size] = self;
    level.zombie_equipment[equipment_name].models[level.zombie_equipment[equipment_name].models.size] = getent( self.target, "targetname" );
}

equipment_spawn_think()
{
    for (;;)
    {
        self waittill( "trigger", player );

        if ( player in_revive_trigger() || player.is_drinking > 0 )
        {
            wait 0.1;
            continue;
        }

        if ( is_limited_equipment( self.zombie_equipment_upgrade ) )
        {
            player setup_limited_equipment( self.zombie_equipment_upgrade );

            if ( isdefined( level.hacker_tool_positions ) )
            {
                new_pos = random( level.hacker_tool_positions );
                self.origin = new_pos.trigger_org;
                model = getent( self.target, "targetname" );
                model.origin = new_pos.model_org;
                model.angles = new_pos.model_ang;
            }
        }

        player equipment_give( self.zombie_equipment_upgrade );
    }
}

set_equipment_invisibility_to_player( equipment, invisible )
{
    triggers = level.zombie_equipment[equipment].triggers;

    for ( i = 0; i < triggers.size; i++ )
    {
        if ( isdefined( triggers[i] ) )
            triggers[i] setinvisibletoplayer( self, invisible );
    }

    models = level.zombie_equipment[equipment].models;

    for ( i = 0; i < models.size; i++ )
    {
        if ( isdefined( models[i] ) )
            models[i] setinvisibletoplayer( self, invisible );
    }
}

equipment_take( equipment )
{
    if ( !isdefined( equipment ) )
        equipment = self get_player_equipment();

    if ( !isdefined( equipment ) )
        return;

    if ( !self has_player_equipment( equipment ) )
        return;

    current = 0;
    current_weapon = 0;

    if ( isdefined( self get_player_equipment() ) && equipment == self get_player_equipment() )
        current = 1;

    if ( equipment == self getcurrentweapon() )
        current_weapon = 1;
/#
    println( "ZM EQUIPMENT: " + self.name + " lost " + equipment + "\\n" );
#/
    if ( isdefined( self.current_equipment_active[equipment] ) && self.current_equipment_active[equipment] )
    {
        self.current_equipment_active[equipment] = 0;
        self notify( equipment + "_deactivate" );
    }

    self notify( equipment + "_taken" );
    self takeweapon( equipment );

    if ( !is_limited_equipment( equipment ) || is_limited_equipment( equipment ) && !limited_equipment_in_use( equipment ) )
        self set_equipment_invisibility_to_player( equipment, 0 );

    if ( current )
    {
        self set_player_equipment( undefined );
        self setactionslot( 1, "" );
    }
    else
        arrayremovevalue( self.deployed_equipment, equipment );

    if ( current_weapon )
    {
        primaryweapons = self getweaponslistprimaries();

        if ( isdefined( primaryweapons ) && primaryweapons.size > 0 )
            self switchtoweapon( primaryweapons[0] );
    }
}

equipment_give( equipment )
{
    if ( !isdefined( equipment ) )
        return;

    if ( !isdefined( level.zombie_equipment[equipment] ) )
        return;

    if ( self has_player_equipment( equipment ) )
        return;
/#
    println( "ZM EQUIPMENT: " + self.name + " got " + equipment + "\\n" );
#/
    curr_weapon = self getcurrentweapon();
    curr_weapon_was_curr_equipment = self is_player_equipment( curr_weapon );
    self equipment_take();
    self set_player_equipment( equipment );
    self giveweapon( equipment );
    self setweaponammoclip( equipment, 1 );
    self thread show_equipment_hint( equipment );
    self notify( equipment + "_given" );
    self set_equipment_invisibility_to_player( equipment, 1 );
    self setactionslot( 1, "weapon", equipment );

    if ( isdefined( level.zombie_equipment[equipment].watcher_thread ) )
        self thread [[ level.zombie_equipment[equipment].watcher_thread ]]();

    self thread equipment_slot_watcher( equipment );
    self maps\mp\zombies\_zm_audio::create_and_play_dialog( "weapon_pickup", level.zombie_equipment[equipment].vox );
}

equipment_slot_watcher( equipment )
{
    self notify( "kill_equipment_slot_watcher" );
    self endon( "kill_equipment_slot_watcher" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "weapon_change", curr_weapon, prev_weapon );

        self.prev_weapon_before_equipment_change = undefined;

        if ( isdefined( prev_weapon ) && "none" != prev_weapon )
        {
            prev_weapon_type = weaponinventorytype( prev_weapon );

            if ( "primary" == prev_weapon_type || "altmode" == prev_weapon_type )
                self.prev_weapon_before_equipment_change = prev_weapon;
        }

        if ( isdefined( level.zombie_equipment[equipment].watcher_thread ) )
        {
            if ( curr_weapon == equipment )
            {
                if ( self.current_equipment_active[equipment] == 1 )
                {
                    self notify( equipment + "_deactivate" );
                    self.current_equipment_active[equipment] = 0;
                }
                else if ( self.current_equipment_active[equipment] == 0 )
                {
                    self notify( equipment + "_activate" );
                    self.current_equipment_active[equipment] = 1;
                }

                self waittill( "equipment_select_response_done" );
            }
        }
        else if ( curr_weapon == equipment && !self.current_equipment_active[equipment] )
        {
            self notify( equipment + "_activate" );
            self.current_equipment_active[equipment] = 1;
        }
        else if ( curr_weapon != equipment && self.current_equipment_active[equipment] )
        {
            self notify( equipment + "_deactivate" );
            self.current_equipment_active[equipment] = 0;
        }
    }
}

is_limited_equipment( equipment )
{
    if ( isdefined( level._limited_equipment ) )
    {
        for ( i = 0; i < level._limited_equipment.size; i++ )
        {
            if ( level._limited_equipment[i] == equipment )
                return true;
        }
    }

    return false;
}

limited_equipment_in_use( equipment )
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        current_equipment = players[i] get_player_equipment();

        if ( isdefined( current_equipment ) && current_equipment == equipment )
            return true;
    }

    if ( isdefined( level.dropped_equipment ) && isdefined( level.dropped_equipment[equipment] ) )
        return true;

    return false;
}

setup_limited_equipment( equipment )
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
        players[i] set_equipment_invisibility_to_player( equipment, 1 );

    self thread release_limited_equipment_on_disconnect( equipment );
    self thread release_limited_equipment_on_equipment_taken( equipment );
}

release_limited_equipment_on_equipment_taken( equipment )
{
    self endon( "disconnect" );
    self waittill_either( equipment + "_taken", "spawned_spectator" );
    players = get_players();

    for ( i = 0; i < players.size; i++ )
        players[i] set_equipment_invisibility_to_player( equipment, 0 );
}

release_limited_equipment_on_disconnect( equipment )
{
    self endon( equipment + "_taken" );

    self waittill( "disconnect" );

    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( isalive( players[i] ) )
            players[i] set_equipment_invisibility_to_player( equipment, 0 );
    }
}

is_equipment_active( equipment )
{
    if ( !isdefined( self.current_equipment_active ) || !isdefined( self.current_equipment_active[equipment] ) )
        return 0;

    return self.current_equipment_active[equipment];
}

init_equipment_hint_hudelem( x, y, alignx, aligny, fontscale, alpha )
{
    self.x = x;
    self.y = y;
    self.alignx = alignx;
    self.aligny = aligny;
    self.fontscale = fontscale;
    self.alpha = alpha;
    self.sort = 20;
}

setup_equipment_client_hintelem()
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( !isdefined( self.hintelem ) )
        self.hintelem = newclienthudelem( self );

    if ( level.splitscreen )
        self.hintelem init_equipment_hint_hudelem( 160, 90, "center", "middle", 1.6, 1.0 );
    else
        self.hintelem init_equipment_hint_hudelem( 320, 220, "center", "bottom", 1.6, 1.0 );
}

show_equipment_hint( equipment )
{
    self notify( "kill_previous_show_equipment_hint_thread" );
    self endon( "kill_previous_show_equipment_hint_thread" );
    self endon( "death" );
    self endon( "disconnect" );

    if ( isdefined( self.do_not_display_equipment_pickup_hint ) && self.do_not_display_equipment_pickup_hint )
        return;

    wait 0.5;
    text = get_equipment_howto_hint( equipment );
    self show_equipment_hint_text( text );
}

show_equipment_hint_text( text )
{
    self notify( "hide_equipment_hint_text" );
    wait 0.05;
    self setup_equipment_client_hintelem();
    self.hintelem settext( text );
    self.hintelem.alpha = 1;
    self.hintelem.font = "small";
    self.hintelem.fontscale = 1.25;
    self.hintelem.hidewheninmenu = 1;
    time = self waittill_notify_or_timeout( "hide_equipment_hint_text", 3.2 );

    if ( isdefined( time ) )
    {
        self.hintelem fadeovertime( 0.25 );
        self.hintelem.alpha = 0;
        self waittill_notify_or_timeout( "hide_equipment_hint_text", 0.25 );
    }

    self.hintelem settext( "" );
    self.hintelem destroy();
}

equipment_onspawnretrievableweaponobject( watcher, player )
{
    self.plant_parent = self;
    iswallmount = isdefined( level.placeable_equipment_type[self.name] ) && level.placeable_equipment_type[self.name] == "wallmount";

    if ( !isdefined( player.turret_placement ) || !player.turret_placement["result"] )
    {
        if ( iswallmount || !getdvarint( "tu11_zombie_turret_placement_ignores_bodies" ) )
        {
            self waittill( "stationary" );

            waittillframeend;

            if ( iswallmount )
            {
                if ( isdefined( player.planted_wallmount_on_a_zombie ) && player.planted_wallmount_on_a_zombie )
                {
                    equip_name = self.name;
                    thread equipment_disappear_fx( self.origin, undefined, self.angles );
                    self delete();

                    if ( player hasweapon( equip_name ) )
                        player setweaponammoclip( equip_name, 1 );

                    player.planted_wallmount_on_a_zombie = undefined;
                    return;
                }
            }
        }
        else
        {
            self.plant_parent = player;
            self.origin = player.origin;
            self.angles = player.angles;
            wait_network_frame();
        }
    }

    equipment = watcher.name + "_zm";
/#
    if ( !isdefined( player.current_equipment ) || player.current_equipment != equipment )
    {
/#
        assert( player has_deployed_equipment( equipment ) );
#/
/#
        assert( !isdefined( player.current_equipment ) );
#/
    }
#/
    if ( isdefined( player.current_equipment ) && player.current_equipment == equipment )
        player equipment_to_deployed( equipment );

    if ( isdefined( level.zombie_equipment[equipment].place_fn ) )
    {
        if ( isdefined( player.turret_placement ) && player.turret_placement["result"] )
        {
            plant_origin = player.turret_placement["origin"];
            plant_angles = player.turret_placement["angles"];
        }
        else if ( isdefined( level.placeable_equipment_type[self.name] ) && level.placeable_equipment_type[self.name] == "wallmount" )
        {
            plant_origin = self.origin;
            plant_angles = self.angles;
        }
        else
        {
            plant_origin = self.origin;
            plant_angles = self.angles;
        }

        if ( isdefined( level.check_force_deploy_origin ) )
        {
            if ( player [[ level.check_force_deploy_origin ]]( self, plant_origin, plant_angles ) )
            {
                plant_origin = player.origin;
                plant_angles = player.angles;
                self.plant_parent = player;
            }
        }
        else if ( isdefined( level.check_force_deploy_z ) )
        {
            if ( player [[ level.check_force_deploy_z ]]( self, plant_origin, plant_angles ) )
                plant_origin = ( plant_origin[0], plant_origin[1], player.origin[2] + 10 );
        }

        if ( isdefined( iswallmount ) && iswallmount )
            self ghost();

        replacement = player [[ level.zombie_equipment[equipment].place_fn ]]( plant_origin, plant_angles );

        if ( isdefined( replacement ) )
        {
            replacement.owner = player;
            replacement.original_owner = player;
            replacement.name = self.name;
            player notify( "equipment_placed", replacement, self.name );

            if ( isdefined( level.equipment_planted ) )
                player [[ level.equipment_planted ]]( replacement, equipment, self.plant_parent );

            player maps\mp\zombies\_zm_buildables::track_buildables_planted( self );
        }

        if ( isdefined( self ) )
            self delete();
    }
}

equipment_retrieve( player )
{
    if ( isdefined( self ) )
    {
        self stoploopsound();
        original_owner = self.original_owner;
        weaponname = self.name;

        if ( !isdefined( original_owner ) )
        {
            player equipment_give( weaponname );
            self.owner = player;
        }
        else
        {
            if ( player != original_owner )
            {
                equipment_transfer( weaponname, original_owner, player );
                self.owner = player;
            }

            player equipment_from_deployed( weaponname );
        }

        if ( isdefined( self.requires_pickup ) && self.requires_pickup )
        {
            if ( isdefined( level.zombie_equipment[weaponname].pickup_fn ) )
            {
                self.owner = player;

                if ( isdefined( self.damage ) )
                    player player_set_equipment_damage( weaponname, self.damage );

                player [[ level.zombie_equipment[weaponname].pickup_fn ]]( self );
            }
        }

        self.playdialog = 0;
        weaponname = self.name;
        self delete();

        if ( !player hasweapon( weaponname ) )
        {
            player giveweapon( weaponname );
            clip_ammo = player getweaponammoclip( weaponname );
            clip_max_ammo = weaponclipsize( weaponname );

            if ( clip_ammo < clip_max_ammo )
                clip_ammo++;

            player setweaponammoclip( weaponname, clip_ammo );
        }

        player maps\mp\zombies\_zm_buildables::track_planted_buildables_pickedup( weaponname );
    }
}

equipment_drop_to_planted( equipment, player )
{
/#
    if ( !isdefined( player.current_equipment ) || player.current_equipment != equipment )
    {
/#
        assert( player has_deployed_equipment( equipment ) );
#/
/#
        assert( !isdefined( player.current_equipment ) );
#/
    }
#/
    if ( isdefined( player.current_equipment ) && player.current_equipment == equipment )
        player equipment_to_deployed( equipment );

    if ( isdefined( level.zombie_equipment[equipment].place_fn ) )
    {
        replacement = player [[ level.zombie_equipment[equipment].place_fn ]]( player.origin, player.angles );

        if ( isdefined( replacement ) )
        {
            replacement.owner = player;
            replacement.original_owner = player;
            replacement.name = equipment;

            if ( isdefined( level.equipment_planted ) )
                player [[ level.equipment_planted ]]( replacement, equipment, player );

            player notify( "equipment_placed", replacement, equipment );
            player maps\mp\zombies\_zm_buildables::track_buildables_planted( replacement );
        }
    }
}

equipment_transfer( weaponname, fromplayer, toplayer )
{
    if ( is_limited_equipment( weaponname ) )
    {
/#
        println( "ZM EQUIPMENT: " + weaponname + " transferred from " + fromplayer.name + " to " + toplayer.name + "\\n" );
#/
        toplayer equipment_orphaned( weaponname );
        wait 0.05;
/#
        assert( !toplayer has_player_equipment( weaponname ) );
#/
/#
        assert( fromplayer has_player_equipment( weaponname ) );
#/
        toplayer equipment_give( weaponname );
        toplayer equipment_to_deployed( weaponname );

        if ( isdefined( level.zombie_equipment[weaponname].transfer_fn ) )
            [[ level.zombie_equipment[weaponname].transfer_fn ]]( fromplayer, toplayer );

        fromplayer equipment_release( weaponname );
/#
        assert( toplayer has_player_equipment( weaponname ) );
#/
/#
        assert( !fromplayer has_player_equipment( weaponname ) );
#/
        equipment_damage = 0;
        toplayer player_set_equipment_damage( weaponname, fromplayer player_get_equipment_damage( weaponname ) );
        fromplayer player_set_equipment_damage( equipment_damage );
    }
    else
    {
/#
        println( "ZM EQUIPMENT: " + weaponname + " swapped from " + fromplayer.name + " to " + toplayer.name + "\\n" );
#/
        toplayer equipment_give( weaponname );

        if ( isdefined( toplayer.current_equipment ) && toplayer.current_equipment == weaponname )
            toplayer equipment_to_deployed( weaponname );

        if ( isdefined( level.zombie_equipment[weaponname].transfer_fn ) )
            [[ level.zombie_equipment[weaponname].transfer_fn ]]( fromplayer, toplayer );

        equipment_damage = toplayer player_get_equipment_damage( weaponname );
        toplayer player_set_equipment_damage( weaponname, fromplayer player_get_equipment_damage( weaponname ) );
        fromplayer player_set_equipment_damage( weaponname, equipment_damage );
    }
}

equipment_release( equipment )
{
/#
    println( "ZM EQUIPMENT: " + self.name + " release " + equipment + "\\n" );
#/
    self equipment_take( equipment );
}

equipment_drop( equipment )
{
    if ( isdefined( level.zombie_equipment[equipment].place_fn ) )
    {
        equipment_drop_to_planted( equipment, self );
/#
        println( "ZM EQUIPMENT: " + self.name + " drop to planted " + equipment + "\\n" );
#/
    }
    else if ( isdefined( level.zombie_equipment[equipment].drop_fn ) )
    {
        if ( isdefined( self.current_equipment ) && self.current_equipment == equipment )
            self equipment_to_deployed( equipment );

        item = self [[ level.zombie_equipment[equipment].drop_fn ]]();

        if ( isdefined( item ) )
        {
            if ( isdefined( level.equipment_planted ) )
                self [[ level.equipment_planted ]]( item, equipment, self );

            item.owner = undefined;
            item.damage = self player_get_equipment_damage( equipment );
        }
/#
        println( "ZM EQUIPMENT: " + self.name + " dropped " + equipment + "\\n" );
#/
    }
    else
        self equipment_take();

    self notify( "equipment_dropped", equipment );
}

equipment_grab( equipment, item )
{
/#
    println( "ZM EQUIPMENT: " + self.name + " picked up " + equipment + "\\n" );
#/
    self equipment_give( equipment );

    if ( isdefined( level.zombie_equipment[equipment].pickup_fn ) )
    {
        item.owner = self;
        self player_set_equipment_damage( equipment, item.damage );
        self [[ level.zombie_equipment[equipment].pickup_fn ]]( item );
    }
}

equipment_orphaned( equipment )
{
/#
    println( "ZM EQUIPMENT: " + self.name + " orphaned " + equipment + "\\n" );
#/
    self equipment_take( equipment );
}

equipment_to_deployed( equipment )
{
/#
    println( "ZM EQUIPMENT: " + self.name + " deployed " + equipment + "\\n" );
#/
    if ( !isdefined( self.deployed_equipment ) )
        self.deployed_equipment = [];
/#
    assert( self.current_equipment == equipment );
#/
    self.deployed_equipment[self.deployed_equipment.size] = equipment;
    self.current_equipment = undefined;

    if ( !isdefined( level.riotshield_name ) || equipment != level.riotshield_name )
        self takeweapon( equipment );

    self setactionslot( 1, "" );
}

equipment_from_deployed( equipment )
{
    if ( !isdefined( equipment ) )
        equipment = "none";
/#
    println( "ZM EQUIPMENT: " + self.name + " retrieved " + equipment + "\\n" );
#/
    if ( isdefined( self.current_equipment ) && equipment != self.current_equipment )
        self equipment_drop( self.current_equipment );
/#
    assert( self has_deployed_equipment( equipment ) );
#/
    self.current_equipment = equipment;

    if ( isdefined( level.riotshield_name ) && equipment != level.riotshield_name )
        self giveweapon( equipment );

    if ( self hasweapon( equipment ) )
        self setweaponammoclip( equipment, 1 );

    self setactionslot( 1, "weapon", equipment );
    arrayremovevalue( self.deployed_equipment, equipment );
    self notify( equipment + "_pickup" );
}

eqstub_get_unitrigger_origin()
{
    if ( isdefined( self.origin_parent ) )
        return self.origin_parent.origin;

    tup = anglestoup( self.angles );
    eq_unitrigger_offset = 12 * tup;
    return self.origin + eq_unitrigger_offset;
}

eqstub_on_spawn_trigger( trigger )
{
    if ( isdefined( self.link_parent ) )
    {
        trigger enablelinkto();
        trigger linkto( self.link_parent );
        trigger setmovingplatformenabled( 1 );
    }
}

equipment_buy( equipment )
{
/#
    println( "ZM EQUIPMENT: " + self.name + " bought " + equipment + "\\n" );
#/
    if ( isdefined( self.current_equipment ) && equipment != self.current_equipment )
        self equipment_drop( self.current_equipment );

    if ( ( equipment == "riotshield_zm" || equipment == "alcatraz_shield_zm" ) && isdefined( self.player_shield_reset_health ) )
        self [[ self.player_shield_reset_health ]]();
    else
        self player_set_equipment_damage( equipment, 0 );

    self equipment_give( equipment );
}

generate_equipment_unitrigger( classname, origin, angles, flags, radius, script_height, hint, icon, think, moving )
{
    if ( !isdefined( radius ) )
        radius = 64;

    if ( !isdefined( script_height ) )
        script_height = 64;

    script_width = script_height;

    if ( !isdefined( script_width ) )
        script_width = 64;

    script_length = script_height;

    if ( !isdefined( script_length ) )
        script_length = 64;

    unitrigger_stub = spawnstruct();
    unitrigger_stub.origin = origin;

    if ( isdefined( angles ) )
        unitrigger_stub.angles = angles;

    if ( isdefined( script_length ) )
        unitrigger_stub.script_length = script_length;
    else
        unitrigger_stub.script_length = 13.5;

    if ( isdefined( script_width ) )
        unitrigger_stub.script_width = script_width;
    else
        unitrigger_stub.script_width = 27.5;

    if ( isdefined( script_height ) )
        unitrigger_stub.script_height = script_height;
    else
        unitrigger_stub.script_height = 24;

    unitrigger_stub.radius = radius;
    unitrigger_stub.cursor_hint = "HINT_NOICON";
    unitrigger_stub.hint_string = hint;

    if ( getdvarint( "tu12_zombies_allow_hint_weapon_from_script" ) )
    {
        unitrigger_stub.cursor_hint = "HINT_WEAPON";
        unitrigger_stub.cursor_hint_weapon = icon;
    }

    unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
    unitrigger_stub.require_look_at = 0;

    switch ( classname )
    {
        case "trigger_radius":
            unitrigger_stub.script_unitrigger_type = "unitrigger_radius";
            break;
        case "trigger_radius_use":
            unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
            break;
        case "trigger_box":
            unitrigger_stub.script_unitrigger_type = "unitrigger_box";
            break;
        case "trigger_box_use":
            unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
            break;
    }

    unitrigger_stub.originfunc = ::eqstub_get_unitrigger_origin;
    unitrigger_stub.onspawnfunc = ::eqstub_on_spawn_trigger;

    if ( isdefined( moving ) && moving )
        maps\mp\zombies\_zm_unitrigger::register_unitrigger( unitrigger_stub, think );
    else
        maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, think );

    return unitrigger_stub;
}

can_pick_up_equipment( equipment_name, equipment_trigger )
{
    if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || self in_revive_trigger() )
        return false;

    if ( self isthrowinggrenade() )
        return false;

    if ( isdefined( self.screecher_weapon ) )
        return false;

    if ( self is_jumping() )
        return false;

    if ( self is_player_equipment( equipment_name ) )
        return false;

    if ( isdefined( self.pickup_equipment ) && self.pickup_equipment )
        return false;

    if ( isdefined( level.equipment_team_pick_up ) && level.equipment_team_pick_up && !self same_team_placed_equipment( equipment_trigger ) )
        return false;

    return true;
}

same_team_placed_equipment( equipment_trigger )
{
    return isdefined( equipment_trigger ) && isdefined( equipment_trigger.stub ) && isdefined( equipment_trigger.stub.model ) && isdefined( equipment_trigger.stub.model.owner ) && equipment_trigger.stub.model.owner.pers["team"] == self.pers["team"];
}

placed_equipment_think( model, equipname, origin, angles, tradius, toffset )
{
    pickupmodel = spawn( "script_model", origin );

    if ( isdefined( angles ) )
        pickupmodel.angles = angles;

    pickupmodel setmodel( model );

    if ( isdefined( level.equipment_safe_to_drop ) )
    {
        if ( !self [[ level.equipment_safe_to_drop ]]( pickupmodel ) )
        {
            equipment_disappear_fx( pickupmodel.origin, undefined, pickupmodel.angles );
            pickupmodel delete();
            self equipment_take( equipname );
            return undefined;
        }
    }

    watchername = getsubstr( equipname, 0, equipname.size - 3 );

    if ( isdefined( level.retrievehints[watchername] ) )
        hint = level.retrievehints[watchername].hint;
    else
        hint = &"MP_GENERIC_PICKUP";

    icon = get_equipment_icon( equipname );

    if ( !isdefined( tradius ) )
        tradius = 32;

    torigin = origin;

    if ( isdefined( toffset ) )
    {
        tforward = anglestoforward( angles );
        torigin += toffset * tforward;
    }

    tup = anglestoup( angles );
    eq_unitrigger_offset = 12 * tup;
    pickupmodel.stub = generate_equipment_unitrigger( "trigger_radius_use", torigin + eq_unitrigger_offset, angles, 0, tradius, 64, hint, equipname, ::placed_equipment_unitrigger_think, isdefined( pickupmodel.canmove ) && pickupmodel.canmove );
    pickupmodel.stub.model = pickupmodel;
    pickupmodel.stub.equipname = equipname;
    pickupmodel.equipname = equipname;
    pickupmodel thread item_attract_zombies();
    pickupmodel thread item_watch_explosions();

    if ( is_limited_equipment( equipname ) )
    {
        if ( !isdefined( level.dropped_equipment ) )
            level.dropped_equipment = [];

        if ( isdefined( level.dropped_equipment[equipname] ) && isdefined( level.dropped_equipment[equipname].model ) )
            level.dropped_equipment[equipname].model dropped_equipment_destroy( 1 );

        level.dropped_equipment[equipname] = pickupmodel.stub;
    }

    destructible_equipment_list_add( pickupmodel );
    return pickupmodel;
}

watch_player_visibility( equipment )
{
    self endon( "kill_trigger" );
    self setinvisibletoall();

    while ( isdefined( self ) )
    {
        players = getplayers();

        foreach ( player in players )
        {
            if ( !isdefined( player ) )
                continue;

            invisible = !player can_pick_up_equipment( equipment, self );

            if ( isdefined( self ) )
                self setinvisibletoplayer( player, invisible );

            wait 0.05;
        }

        wait 1;
    }
}

placed_equipment_unitrigger_think()
{
    self endon( "kill_trigger" );
    self thread watch_player_visibility( self.stub.equipname );

    while ( true )
    {
        self waittill( "trigger", player );

        if ( !player can_pick_up_equipment( self.stub.equipname, self ) )
            continue;

        self thread pickup_placed_equipment( player );
        return;
    }
}

pickup_placed_equipment( player )
{
/#
    assert( !( isdefined( player.pickup_equipment ) && player.pickup_equipment ) );
#/
    player.pickup_equipment = 1;
    stub = self.stub;

    if ( isdefined( player.current_equipment ) && stub.equipname != player.current_equipment )
        player equipment_drop( player.current_equipment );

    if ( is_limited_equipment( stub.equipname ) )
    {
        if ( isdefined( level.dropped_equipment ) && isdefined( level.dropped_equipment[stub.equipname] ) && level.dropped_equipment[stub.equipname] == stub )
            level.dropped_equipment[stub.equipname] = undefined;
    }

    if ( isdefined( stub.model ) )
        stub.model equipment_retrieve( player );

    thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( stub );
    wait 3;
    player.pickup_equipment = 0;
}

dropped_equipment_think( model, equipname, origin, angles, tradius, toffset )
{
    pickupmodel = spawn( "script_model", origin );

    if ( isdefined( angles ) )
        pickupmodel.angles = angles;

    pickupmodel setmodel( model );

    if ( isdefined( level.equipment_safe_to_drop ) )
    {
        if ( !self [[ level.equipment_safe_to_drop ]]( pickupmodel ) )
        {
            equipment_disappear_fx( pickupmodel.origin, undefined, pickupmodel.angles );
            pickupmodel delete();
            self equipment_take( equipname );
            return;
        }
    }

    watchername = getsubstr( equipname, 0, equipname.size - 3 );

    if ( isdefined( level.retrievehints[watchername] ) )
        hint = level.retrievehints[watchername].hint;
    else
        hint = &"MP_GENERIC_PICKUP";

    icon = get_equipment_icon( equipname );

    if ( !isdefined( tradius ) )
        tradius = 32;

    torigin = origin;

    if ( isdefined( toffset ) )
    {
        offset = 64;
        tforward = anglestoforward( angles );
        torigin = torigin + toffset * tforward + vectorscale( ( 0, 0, 1 ), 8.0 );
    }

    pickupmodel.stub = generate_equipment_unitrigger( "trigger_radius_use", torigin, angles, 0, tradius, 64, hint, equipname, ::dropped_equipment_unitrigger_think, isdefined( pickupmodel.canmove ) && pickupmodel.canmove );
    pickupmodel.stub.model = pickupmodel;
    pickupmodel.stub.equipname = equipname;
    pickupmodel.equipname = equipname;

    if ( isdefined( level.equipment_planted ) )
        self [[ level.equipment_planted ]]( pickupmodel, equipname, self );

    if ( !isdefined( level.dropped_equipment ) )
        level.dropped_equipment = [];

    if ( isdefined( level.dropped_equipment[equipname] ) )
        level.dropped_equipment[equipname].model dropped_equipment_destroy( 1 );

    level.dropped_equipment[equipname] = pickupmodel.stub;
    destructible_equipment_list_add( pickupmodel );
    pickupmodel thread item_attract_zombies();
    return pickupmodel;
}

dropped_equipment_unitrigger_think()
{
    self endon( "kill_trigger" );
    self thread watch_player_visibility( self.stub.equipname );

    while ( true )
    {
        self waittill( "trigger", player );

        if ( !player can_pick_up_equipment( self.stub.equipname, self ) )
            continue;

        self thread pickup_dropped_equipment( player );
        return;
    }
}

pickup_dropped_equipment( player )
{
    player.pickup_equipment = 1;
    stub = self.stub;

    if ( isdefined( player.current_equipment ) && stub.equipname != player.current_equipment )
        player equipment_drop( player.current_equipment );

    player equipment_grab( stub.equipname, stub.model );
    stub.model dropped_equipment_destroy();
    wait 3;
    player.pickup_equipment = 0;
}

dropped_equipment_destroy( gusto )
{
    stub = self.stub;

    if ( isdefined( gusto ) && gusto )
        equipment_disappear_fx( self.origin, undefined, self.angles );

    if ( isdefined( level.dropped_equipment ) )
        level.dropped_equipment[stub.equipname] = undefined;

    if ( isdefined( stub.model ) )
        stub.model delete();

    if ( isdefined( self.original_owner ) && ( is_limited_equipment( stub.equipname ) || maps\mp\zombies\_zm_weapons::is_weapon_included( stub.equipname ) ) )
        self.original_owner equipment_take( stub.equipname );

    thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( stub );
}

add_placeable_equipment( equipment, modelname, destroy_fn, type )
{
    if ( !isdefined( level.placeable_equipment ) )
        level.placeable_equipment = [];

    level.placeable_equipment[equipment] = modelname;
    precachemodel( modelname );
    precacheitem( equipment + "_turret" );

    if ( !isdefined( level.placeable_equipment_destroy_fn ) )
        level.placeable_equipment_destroy_fn = [];

    level.placeable_equipment_destroy_fn[equipment] = destroy_fn;

    if ( !isdefined( level.placeable_equipment_type ) )
        level.placeable_equipment_type = [];

    level.placeable_equipment_type[equipment] = type;
}

is_placeable_equipment( equipment )
{
    if ( isdefined( level.placeable_equipment ) && isdefined( level.placeable_equipment[equipment] ) )
        return true;

    return false;
}

equipment_placement_watcher()
{
    self endon( "death_or_disconnect" );

    for (;;)
    {
        self waittill( "weapon_change", weapon );

        if ( self.sessionstate != "spectator" && is_placeable_equipment( weapon ) )
            self thread equipment_watch_placement( weapon );
    }
}

equipment_watch_placement( equipment )
{
    self.turret_placement = undefined;
    carry_offset = vectorscale( ( 1, 0, 0 ), 22.0 );
    carry_angles = ( 0, 0, 0 );
    placeturret = spawnturret( "auto_turret", self.origin, equipment + "_turret" );
    placeturret.angles = self.angles;
    placeturret setmodel( level.placeable_equipment[equipment] );
    placeturret setturretcarried( 1 );
    placeturret setturretowner( self );

    if ( isdefined( level.placeable_equipment_type[equipment] ) )
        placeturret setturrettype( level.placeable_equipment_type[equipment] );

    self carryturret( placeturret, carry_offset, carry_angles );

    if ( isdefined( level.use_swipe_protection ) )
        self thread watch_melee_swipes( equipment, placeturret );

    self notify( "create_equipment_turret", equipment, placeturret );
    ended = self waittill_any_return( "weapon_change", "grenade_fire", "death_or_disconnect" );

    if ( !( isdefined( level.use_legacy_equipment_placement ) && level.use_legacy_equipment_placement ) )
        self.turret_placement = self canplayerplaceturret( placeturret );

    if ( ended == "weapon_change" )
    {
        self.turret_placement = undefined;

        if ( self hasweapon( equipment ) )
            self setweaponammoclip( equipment, 1 );
    }

    self notify( "destroy_equipment_turret", equipment, placeturret );
    self stopcarryturret( placeturret );
    placeturret setturretcarried( 0 );
    placeturret delete();
}

watch_melee_swipes( equipment, turret )
{
    self endon( "weapon_change" );
    self endon( "grenade_fire" );
    self endon( "death" );
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "melee_swipe", zombie );

        if ( distancesquared( zombie.origin, self.origin ) > zombie.meleeattackdist * zombie.meleeattackdist )
            continue;

        tpos = turret.origin;
        tangles = turret.angles;
        self player_damage_equipment( equipment, 200, zombie.origin );

        if ( self.equipment_damage[equipment] >= 1500 )
        {
            thread equipment_disappear_fx( tpos, undefined, tangles );
            primaryweapons = self getweaponslistprimaries();

            if ( isdefined( primaryweapons[0] ) )
                self switchtoweapon( primaryweapons[0] );

            if ( isalive( self ) )
                self playlocalsound( level.zmb_laugh_alias );

            self maps\mp\zombies\_zm_stats::increment_client_stat( "cheat_total", 0 );
            self equipment_release( equipment );
            return;
        }
    }
}

player_get_equipment_damage( equipment )
{
    if ( isdefined( self.equipment_damage ) && isdefined( self.equipment_damage[equipment] ) )
        return self.equipment_damage[equipment];

    return 0;
}

player_set_equipment_damage( equipment, damage )
{
    if ( !isdefined( self.equipment_damage ) )
        self.equipment_damage = [];

    self.equipment_damage[equipment] = damage;
}

player_damage_equipment( equipment, damage, origin )
{
    if ( !isdefined( self.equipment_damage ) )
        self.equipment_damage = [];

    if ( !isdefined( self.equipment_damage[equipment] ) )
        self.equipment_damage[equipment] = 0;

    self.equipment_damage[equipment] += damage;

    if ( self.equipment_damage[equipment] > 1500 )
    {
        if ( isdefined( level.placeable_equipment_destroy_fn[equipment] ) )
            self [[ level.placeable_equipment_destroy_fn[equipment] ]]();
        else
            equipment_disappear_fx( origin );

        self equipment_release( equipment );
    }
}

item_damage( damage )
{
    if ( isdefined( self.isriotshield ) && self.isriotshield )
    {
        if ( isdefined( level.riotshield_damage_callback ) && isdefined( self.owner ) )
            self.owner [[ level.riotshield_damage_callback ]]( damage, 0 );
        else if ( isdefined( level.deployed_riotshield_damage_callback ) )
            self [[ level.deployed_riotshield_damage_callback ]]( damage );
    }
    else if ( isdefined( self.owner ) )
        self.owner player_damage_equipment( self.equipname, damage, self.origin );
    else
    {
        if ( !isdefined( self.damage ) )
            self.damage = 0;

        self.damage += damage;

        if ( self.damage > 1500 )
            self thread dropped_equipment_destroy( 1 );
    }
}

item_watch_damage()
{
    self endon( "death" );
    self setcandamage( 1 );
    self.health = 1500;

    while ( true )
    {
        self waittill( "damage", amount );

        self item_damage( amount );
    }
}

item_watch_explosions()
{
    self endon( "death" );

    while ( true )
    {
        level waittill( "grenade_exploded", position, radius, idamage, odamage );

        wait( randomfloatrange( 0.05, 0.3 ) );
        distsqrd = distancesquared( self.origin, position );

        if ( distsqrd < radius * radius )
        {
            dist = sqrt( distsqrd );
            dist /= radius;
            damage = odamage + ( idamage - odamage ) * ( 1 - dist );
            self item_damage( damage * 5 );
        }
    }
}

get_item_health()
{
/#
    damage = 0;

    if ( isdefined( self.isriotshield ) && self.isriotshield )
    {
        damagemax = level.zombie_vars["riotshield_hit_points"];

        if ( isdefined( self.owner ) )
            damage = self.owner.shielddamagetaken;
        else if ( isdefined( level.deployed_riotshield_damage_callback ) )
            damage = self.shielddamagetaken;
    }
    else if ( isdefined( self.owner ) )
    {
        damagemax = 1500;
        damage = self.owner player_get_equipment_damage( self.equipname );
    }
    else
    {
        damagemax = 1500;

        if ( isdefined( self.damage ) )
            damage = self.damage;
    }

    return ( damagemax - damage ) / damagemax;
#/
}

debughealth()
{
/#
    self endon( "death" );
    self endon( "stop_attracting_zombies" );

    while ( true )
    {
        if ( getdvarint( _hash_EB512CB7 ) )
        {
            health = self get_item_health();
            color = ( 1 - health, health, 0 );
            text = "" + health * 100 + "";
            print3d( self.origin, text, color, 1, 0.5, 1 );
        }

        wait 0.05;
    }
#/
}

item_choke()
{
    if ( !isdefined( level.item_choke_count ) )
        level.item_choke_count = 0;

    level.item_choke_count++;

    if ( !( level.item_choke_count >= 10 ) )
    {
        wait 0.05;
        level.item_choke_count = 0;
    }
}

is_equipment_ignored( equipname )
{
    if ( isdefined( level.equipment_ignored_by_zombies ) && isdefined( equipname ) && isdefined( level.equipment_ignored_by_zombies[equipname] ) )
        return true;

    return false;
}

enemies_ignore_equipment( equipname )
{
    if ( !isdefined( level.equipment_ignored_by_zombies ) )
        level.equipment_ignored_by_zombies = [];

    level.equipment_ignored_by_zombies[equipname] = equipname;
}

item_attract_zombies()
{
    self endon( "death" );
    self notify( "stop_attracting_zombies" );
    self endon( "stop_attracting_zombies" );
/#
    self thread debughealth();
#/
    if ( is_equipment_ignored( self.equipname ) )
        return;

    while ( true )
    {
        if ( isdefined( level.vert_equipment_attack_range ) )
            vdistmax = level.vert_equipment_attack_range;
        else
            vdistmax = 36;

        if ( isdefined( level.max_equipment_attack_range ) )
            distmax = level.max_equipment_attack_range * level.max_equipment_attack_range;
        else
            distmax = 4096;

        if ( isdefined( level.min_equipment_attack_range ) )
            distmin = level.min_equipment_attack_range * level.min_equipment_attack_range;
        else
            distmin = 2025;

        ai = getaiarray( level.zombie_team );

        for ( i = 0; i < ai.size; i++ )
        {
            if ( !isdefined( ai[i] ) )
                continue;

            if ( isdefined( ai[i].ignore_equipment ) && ai[i].ignore_equipment )
                continue;

            if ( isdefined( level.ignore_equipment ) )
            {
                if ( self [[ level.ignore_equipment ]]( ai[i] ) )
                    continue;
            }

            if ( isdefined( ai[i].is_inert ) && ai[i].is_inert )
                continue;

            if ( isdefined( ai[i].is_traversing ) && ai[i].is_traversing )
                continue;

            vdist = abs( ai[i].origin[2] - self.origin[2] );
            distsqrd = distance2dsquared( ai[i].origin, self.origin );

            if ( isdefined( self.equipname ) && ( self.equipname == "riotshield_zm" || self.equipname == "alcatraz_shield_zm" ) )
                vdistmax = 108;

            should_attack = 0;

            if ( isdefined( level.should_attack_equipment ) )
                should_attack = self [[ level.should_attack_equipment ]]( distsqrd );

            if ( distsqrd < distmax && distsqrd > distmin && vdist < vdistmax || should_attack )
            {
                if ( !( isdefined( ai[i].isscreecher ) && ai[i].isscreecher ) && !ai[i] is_quad() && !ai[i] is_leaper() )
                {
                    ai[i] thread attack_item( self );
                    item_choke();
                }
            }

            item_choke();
        }

        wait 0.1;
    }
}

attack_item( item )
{
    self endon( "death" );
    item endon( "death" );
    self endon( "start_inert" );

    if ( isdefined( self.doing_equipment_attack ) && self.doing_equipment_attack )
        return 0;

    if ( isdefined( self.not_interruptable ) && self.not_interruptable )
        return 0;

    self thread attack_item_stop( item );
    self thread attack_item_interrupt( item );

    if ( getdvar( _hash_FA9CEAA6 ) == "" )
        setdvar( "zombie_equipment_attack_freq", "15" );

    freq = getdvarint( _hash_FA9CEAA6 );
    self.doing_equipment_attack = 1;
    self maps\mp\zombies\_zm_spawner::zombie_history( "doing equipment attack 1 - " + gettime() );
    self.item = item;

    if ( !isdefined( self ) || !isalive( self ) )
        return;

    if ( isdefined( item.zombie_attack_callback ) )
        item [[ item.zombie_attack_callback ]]( self );

    self thread maps\mp\zombies\_zm_audio::do_zombies_playvocals( "attack", self.animname );

    if ( isdefined( level.attack_item ) )
        self [[ level.attack_item ]]();

    melee_anim = "zm_window_melee";

    if ( !self.has_legs )
    {
        melee_anim = "zm_walk_melee_crawl";

        if ( self.a.gib_ref == "no_legs" )
            melee_anim = "zm_stumpy_melee";
        else if ( self.zombie_move_speed == "run" || self.zombie_move_speed == "sprint" )
            melee_anim = "zm_run_melee_crawl";
    }

    self orientmode( "face point", item.origin );
    self animscripted( self.origin, flat_angle( vectortoangles( item.origin - self.origin ) ), melee_anim );
    self notify( "item_attack" );

    if ( isdefined( self.custom_item_dmg ) )
        item thread item_damage( self.custom_item_dmg );
    else
        item thread item_damage( 100 );

    item playsound( "fly_riotshield_zm_impact_flesh" );
    wait( randomint( 100 ) / 100.0 );
    self.doing_equipment_attack = 0;
    self maps\mp\zombies\_zm_spawner::zombie_history( "doing equipment attack 0 from wait - " + gettime() );
    self orientmode( "face default" );
}

attack_item_interrupt( item )
{
    if ( !( isdefined( self.has_legs ) && self.has_legs ) )
        return;

    self notify( "attack_item_interrupt" );
    self endon( "attack_item_interrupt" );
    self endon( "death" );

    while ( isdefined( self.has_legs ) && self.has_legs )
        self waittill( "damage" );

    self stopanimscripted();
    self.doing_equipment_attack = 0;
    self maps\mp\zombies\_zm_spawner::zombie_history( "doing equipment attack 0 from death - " + gettime() );
    self.item = undefined;
}

attack_item_stop( item )
{
    self notify( "attack_item_stop" );
    self endon( "attack_item_stop" );
    self endon( "death" );

    item waittill( "death" );

    self stopanimscripted();
    self.doing_equipment_attack = 0;
    self maps\mp\zombies\_zm_spawner::zombie_history( "doing equipment attack 0 from death - " + gettime() );
    self.item = undefined;

    if ( isdefined( level.attack_item_stop ) )
        self [[ level.attack_item_stop ]]();
}

window_notetracks( msg, equipment )
{
    self endon( "death" );
    equipment endon( "death" );

    while ( self.doing_equipment_attack )
    {
        self waittill( msg, notetrack );

        if ( notetrack == "end" )
            return;

        if ( notetrack == "fire" )
            equipment item_damage( 100 );
    }
}

destructible_equipment_list_check()
{
    if ( !isdefined( level.destructible_equipment ) )
        level.destructible_equipment = [];

    i = 0;

    while ( i < level.destructible_equipment.size )
    {
        if ( !isdefined( level.destructible_equipment[i] ) )
            arrayremoveindex( level.destructible_equipment, i );
        else
            i++;
    }
}

destructible_equipment_list_add( item )
{
    destructible_equipment_list_check();
    level.destructible_equipment[level.destructible_equipment.size] = item;
}

get_destructible_equipment_list()
{
    destructible_equipment_list_check();
    return level.destructible_equipment;
}

equipment_disappear_fx( origin, fx, angles )
{
    effect = level._equipment_disappear_fx;

    if ( isdefined( fx ) )
        effect = fx;

    if ( isdefined( angles ) )
        playfx( effect, origin, anglestoforward( angles ) );
    else
        playfx( effect, origin );

    wait 1.1;
}
