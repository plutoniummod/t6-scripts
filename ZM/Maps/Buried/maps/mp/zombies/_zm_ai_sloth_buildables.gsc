// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_ai_sloth_utility;
#include maps\mp\zombies\_zm_ai_sloth;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zm_buried;
#include maps\mp\zm_buried_buildables;
#include maps\mp\zombies\_zm_unitrigger;

build_buildable_condition()
{
    if ( level.sloth_buildable_zones.size > 0 )
    {
        for ( i = 0; i < level.sloth_buildable_zones.size; i++ )
        {
            zone = level.sloth_buildable_zones[i];

            if ( is_true( zone.built ) )
            {
                remove_zone = zone;
                continue;
            }

            piece_remaining = 0;
            pieces = zone.pieces;

            for ( j = 0; j < pieces.size; j++ )
            {
                if ( isdefined( pieces[j].unitrigger ) && !is_true( pieces[j].built ) )
                {
                    piece_remaining = 1;
                    break;
                }
            }

            if ( !piece_remaining )
                continue;

            dist = distancesquared( zone.stub.origin, self.origin );

            if ( dist < 32400 )
            {
                self.buildable_zone = zone;
                return true;
            }
        }
    }

    if ( isdefined( remove_zone ) )
        arrayremovevalue( level.sloth_buildable_zones, remove_zone );

    return false;
}

common_move_to_table( stub, table, asd_name, check_pickup )
{
    if ( !isdefined( table ) )
    {
/#
        assertmsg( "Table not found for " + self.buildable_zone.buildable_name );
#/
        self.context_done = 1;
        return false;
    }

    anim_id = self getanimfromasd( asd_name, 0 );
    start_org = getstartorigin( table.origin, table.angles, anim_id );
    start_ang = getstartangles( table.origin, table.angles, anim_id );
    self setgoalpos( start_org );

    while ( true )
    {
        if ( is_true( check_pickup ) )
        {
            if ( self.candy_player is_player_equipment( stub.weaponname ) )
            {
/#
                sloth_print( stub.weaponname + " was picked up" );
#/
                self.context_done = 1;
                return false;
            }
        }

        if ( isdefined( self.buildable_zone ) && stub != self.buildable_zone.stub )
        {
/#
            sloth_print( "location change during pathing" );
#/
            stub = self.buildable_zone.stub;
            table = getent( stub.model.target, "targetname" );

            if ( !isdefined( table ) )
            {
/#
                assertmsg( "Table not found for " + self.buildable_zone.buildable_name );
#/
                self.context_done = 1;
                return false;
            }

            start_org = getstartorigin( table.origin, table.angles, anim_id );
            start_ang = getstartangles( table.origin, table.angles, anim_id );
            self setgoalpos( start_org );
        }

        dist = distancesquared( self.origin, start_org );

        if ( dist < 1024 )
            break;

        wait 0.1;
    }

    self setgoalpos( self.origin );
    self sloth_face_object( table, "angle", start_ang[1], 0.9 );
    return true;
}

build_buildable_action()
{
    self endon( "death" );
    self endon( "stop_action" );
    self maps\mp\zombies\_zm_ai_sloth::common_context_action();
    stub = self.buildable_zone.stub;
    table = getent( stub.model.target, "targetname" );

    if ( !self common_move_to_table( stub, table, "zm_make_buildable_intro" ) )
        return;

    self maps\mp\zombies\_zm_ai_sloth::action_animscripted( "zm_make_buildable_intro", "make_buildable_intro_anim", table.origin, table.angles );
/#
    sloth_print( "looking for " + self.buildable_zone.buildable_name + " pieces" );
#/
    store = getstruct( "sloth_general_store", "targetname" );
    self setgoalpos( store.origin );

    self waittill( "goal" );

    self.pieces = [];

    if ( isdefined( self.buildable_zone ) )
    {
        pieces = self.buildable_zone.pieces;

        if ( pieces.size == 0 )
        {
/#
            sloth_print( "no pieces available" );
#/
            self.context_done = 1;
            return;
        }

        for ( i = 0; i < pieces.size; i++ )
        {
            if ( isdefined( pieces[i].unitrigger ) && !is_true( pieces[i].built ) )
            {
/#
                if ( getdvarint( _hash_B6252E7C ) == 2 )
                    line( self.origin, pieces[i].start_origin, ( 1, 1, 1 ), 1, 0, 1000 );
#/
                self maps\mp\zombies\_zm_buildables::player_take_piece( pieces[i] );
                self.pieces[self.pieces.size] = pieces[i];
            }
        }
    }

    self animscripted( self.origin, self.angles, "zm_pickup_part" );
    maps\mp\animscripts\zm_shared::donotetracks( "pickup_part_anim" );
/#
    sloth_print( "took " + self.pieces.size + " pieces" );
#/
    if ( !self common_move_to_table( stub, table, "zm_make_buildable" ) )
        return;

    self.buildable_zone.stub.bound_to_buildable = self.buildable_zone.stub;

    if ( stub != self.buildable_zone.stub )
    {
        stub = self.buildable_zone.stub;
        table = getent( stub.model.target, "targetname" );
    }

    self thread build_buildable_fx( table );
    self animscripted( table.origin, table.angles, "zm_make_buildable" );
    wait 2.5;
    self notify( "stop_buildable_fx" );
    self maps\mp\zombies\_zm_buildables::player_build( self.buildable_zone, self.pieces );

    if ( isdefined( self.buildable_zone.stub.onuse ) )
        self.buildable_zone.stub [[ self.buildable_zone.stub.onuse ]]( self );

    self.pieces = undefined;
    self.context_done = 1;
}

build_buildable_fx( table )
{
    self endon( "death" );
    self notify( "stop_buildable_fx" );
    self endon( "stop_buildable_fx" );

    while ( true )
    {
        playfx( level._effect["fx_buried_sloth_building"], table.origin );
        wait 0.25;
    }
}

build_buildable_interrupt()
{
    if ( isdefined( self.pieces ) && self.pieces.size > 0 )
    {
        foreach ( piece in self.pieces )
            piece maps\mp\zombies\_zm_buildables::piece_spawn_at();
    }
}

fetch_buildable_condition()
{
    self.turbine = undefined;
    turbines = [];
    equipment = maps\mp\zombies\_zm_equipment::get_destructible_equipment_list();

    foreach ( item in equipment )
    {
        if ( !isdefined( item.equipname ) )
            continue;

        if ( item.equipname == "equip_turbine_zm" )
        {
/#
            self sloth_debug_context( item, sqrt( 32400 ) );
#/
            dist = distancesquared( item.origin, self.origin );

            if ( dist < 32400 )
            {
                self.power_stubs = get_power_stubs( self.candy_player );

                if ( self.power_stubs.size > 0 )
                {
                    self.turbine = item;
                    return true;
                }
                else
                {
                    localpower = item.owner.localpower;

                    if ( check_localpower_list( localpower.added_list ) || check_localpower_list( localpower.enabled_list ) )
                    {
                        self.turbine = item;
                        return true;
                    }
                }
            }

            turbines[turbines.size] = item;
        }
    }

    foreach ( item in equipment )
    {
        if ( !isdefined( item.equipname ) )
            continue;

        if ( item.equipname == "equip_turret_zm" || item.equipname == "equip_electrictrap_zm" || item.equipname == "equip_subwoofer_zm" )
        {
/#
            self sloth_debug_context( item, sqrt( 32400 ) );
#/
            dist = distancesquared( item.origin, self.origin );

            if ( dist < 32400 )
            {
                if ( is_true( item.power_on ) )
                {
                    foreach ( turbine in turbines )
                    {
                        if ( is_turbine_powering_item( turbine, item ) )
                        {
                            self.turbine = turbine;
                            return true;
                        }
                    }
                }
            }
        }
    }

    foreach ( item in equipment )
    {
        if ( !isdefined( item.equipname ) )
            continue;

        if ( item.equipname == "equip_turret_zm" || item.equipname == "equip_electrictrap_zm" || item.equipname == "equip_subwoofer_zm" )
        {
/#
            self sloth_debug_context( item, sqrt( 32400 ) );
#/
            dist = distancesquared( item.origin, self.origin );

            if ( dist < 32400 )
            {
                if ( is_true( level.turbine_zone.built ) )
                {
                    self.power_item = item;
                    return true;
                }
                else
                {
/#
                    sloth_print( "turbine not built" );
#/
                }
            }
        }
    }

    return false;
}

is_turbine_powering_item( turbine, item )
{
    localpower = turbine.owner.localpower;

    if ( isdefined( localpower.added_list ) )
    {
        foreach ( added in localpower.added_list )
        {
            if ( added == item )
                return true;
        }
    }

    if ( isdefined( localpower.enabled_list ) )
    {
        foreach ( enabled in localpower.enabled_list )
        {
            if ( enabled == item )
                return true;
        }
    }

    return false;
}

get_power_stubs( player )
{
    power_stubs = [];

    foreach ( zone in level.power_zones )
    {
        if ( is_true( zone.built ) )
        {
            if ( !player has_player_equipment( zone.stub.weaponname ) )
                power_stubs[power_stubs.size] = zone.stub;
        }
    }

    return power_stubs;
}

fetch_buildable_start()
{
/#
    sloth_print( self.context.name );
#/
    self.context_done = 0;
    self.pi_origin = undefined;

    if ( isdefined( self.turbine ) )
    {
        localpower = self.turbine.owner.localpower;

        if ( check_localpower_list( localpower.added_list ) || check_localpower_list( localpower.enabled_list ) )
        {
/#
            sloth_print( "has powered item, go get turbine" );
#/
            self thread fetch_buildable_action( "turbine" );
            return;
        }
/#
        sloth_print( "find a power item" );
#/
        self thread fetch_buildable_action( "power_item" );
    }
    else if ( isdefined( self.power_item ) )
    {
/#
        sloth_print( "power item needs turbine" );
#/
        self.pi_origin = self.power_item.origin;
        self thread fetch_buildable_action( "turbine" );
    }
}

check_localpower_list( list )
{
    if ( isdefined( list ) )
    {
        foreach ( item in list )
        {
            item_name = item.target.name;

            if ( !isdefined( item_name ) )
                continue;

            if ( item_name == "equip_turret_zm" || item_name == "equip_electrictrap_zm" || item_name == "equip_subwoofer_zm" )
                return true;
        }
    }

    return false;
}

fetch_buildable_action( item )
{
    self endon( "death" );
    self endon( "stop_action" );
    self maps\mp\zombies\_zm_ai_sloth::common_context_action();
    player = self.candy_player;

    if ( item == "turbine" )
    {
        if ( isdefined( self.turbine ) )
        {
            plant_origin = self.turbine.origin;
            plant_angles = self.turbine.angles;
        }

        stub = level.turbine_zone.stub;
    }
    else if ( item == "power_item" )
    {
        self.power_stubs = array_randomize( self.power_stubs );
        stub = self.power_stubs[0];
    }

    append_name = "equipment";
    pickup_asd = "zm_pickup_" + append_name;
    table = getent( stub.model.target, "targetname" );

    if ( !self common_move_to_table( stub, table, pickup_asd, 1 ) )
        return;

    self.buildable_item = item;
    self animscripted( table.origin, table.angles, pickup_asd );
    maps\mp\animscripts\zm_shared::donotetracks( "pickup_equipment_anim", ::pickup_notetracks, stub );

    if ( player is_player_equipment( stub.weaponname ) )
    {
/#
        sloth_print( "during anim player picked up " + stub.weaponname );
#/
        self.context_done = 1;
        return;
    }

    if ( !player has_deployed_equipment( stub.weaponname ) )
        player.deployed_equipment[player.deployed_equipment.size] = stub.weaponname;
/#
    sloth_print( "got " + stub.equipname );
#/
    if ( isdefined( self.turbine ) )
        ground_pos = self.turbine.origin;
    else if ( isdefined( self.power_item ) )
        ground_pos = self.power_item.origin;
    else
        ground_pos = self.pi_origin;

    run_asd = "run_holding_" + append_name;
    self.ignore_common_run = 1;
    self set_zombie_run_cycle( run_asd );
    self.locomotion = run_asd;
    self setgoalpos( ground_pos );
    range = 10000;

    if ( item == "power_item" || isdefined( self.power_item ) )
        range = 25600;

    while ( true )
    {
        if ( self sloth_is_traversing() )
        {
            wait 0.1;
            continue;
        }

        dist = distancesquared( self.origin, ground_pos );

        if ( dist < range )
            break;

        wait 0.1;
    }

    if ( item == "turbine" )
    {
        if ( isdefined( self.turbine ) )
        {
            self orientmode( "face point", self.turbine.origin );
            self animscripted( self.origin, flat_angle( vectortoangles( self.turbine.origin - self.origin ) ), "zm_kick_equipment" );
            maps\mp\animscripts\zm_shared::donotetracks( "kick_equipment_anim", ::destroy_item, self.turbine );
            self orientmode( "face default" );
            self animscripted( self.origin, self.angles, "zm_idle_equipment" );
            wait 3;
        }
    }

    if ( !isdefined( plant_origin ) )
    {
        plant_origin = self.origin;
        plant_angles = self.angles;
    }

    drop_asd = "zm_drop_" + append_name;
    self maps\mp\zombies\_zm_ai_sloth::action_animscripted( drop_asd, "drop_equipment_anim" );

    if ( player has_player_equipment( stub.weaponname ) )
        player equipment_take( stub.weaponname );

    player player_set_equipment_damage( stub.weaponname, 0 );

    if ( !player has_deployed_equipment( stub.weaponname ) )
        player.deployed_equipment[player.deployed_equipment.size] = stub.weaponname;

    if ( isdefined( self.buildable_model ) )
    {
        self.buildable_model unlink();
        self.buildable_model delete();
    }

    equipment = stub.weaponname;
    plant_origin = self gettagorigin( "tag_weapon_right" );
    plant_angles = self gettagangles( "tag_weapon_right" );
    replacement = player [[ level.zombie_equipment[equipment].place_fn ]]( plant_origin, plant_angles );

    if ( isdefined( replacement ) )
    {
        replacement.owner = player;
        replacement.original_owner = player;
        replacement.name = equipment;
        player notify( "equipment_placed", replacement, equipment );

        if ( isdefined( level.equipment_planted ) )
            player [[ level.equipment_planted ]]( replacement, equipment, self );
    }

    self.context_done = 1;
}

pickup_notetracks( note, stub )
{
    if ( note == "pickup" )
    {
        tag_name = "tag_stowed_back";
        twr_origin = self gettagorigin( tag_name );
        twr_angles = self gettagangles( tag_name );
        self.buildable_model = spawn( "script_model", twr_origin );
        self.buildable_model.angles = twr_angles;

        if ( self.buildable_item == "turbine" )
            self.buildable_model setmodel( level.small_turbine );
        else
            self.buildable_model setmodel( stub.model.model );

        self.buildable_model linkto( self, tag_name );
    }
}

destroy_item( note, item )
{
    if ( note == "kick" )
    {
        if ( isdefined( item ) )
        {
            if ( isdefined( item.owner ) )
                item.owner thread maps\mp\zombies\_zm_equipment::player_damage_equipment( item.equipname, 1001, item.origin );
            else
                item thread maps\mp\zombies\_zm_equipment::dropped_equipment_destroy( 1 );
        }
    }
}

fetch_buildable_interrupt()
{
    if ( isdefined( self.buildable_model ) )
    {
        self.buildable_model unlink();
        self.buildable_model delete();
    }
}

wallbuy_condition()
{
    if ( !wallbuy_get_stub_array().size )
        return false;

    if ( !wallbuy_get_piece_array().size )
        return false;

    if ( isdefined( level.gunshop_zone ) )
    {
        if ( self istouching( level.gunshop_zone ) )
        {
/#
            sloth_print( "using new gunshop zone" );
#/
            return true;
        }
    }
    else if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( "zone_gun_store" ) )
        return true;

    return false;
}

wallbuy_get_stub_array()
{
    stubs = [];

    for ( i = 0; i < level.sloth_wallbuy_stubs.size; i++ )
    {
        stub = level.sloth_wallbuy_stubs[i];

        if ( !isdefined( stub.in_zone ) )
        {
/#
            iprintln( "WALLBUY NOT IN VALID ZONE" );
#/
            continue;
        }

        if ( !level.zones[stub.in_zone].is_enabled )
            continue;

        if ( is_true( stub.built ) )
        {
            remove_stub = stub;
            continue;
        }

        if ( stub.in_zone == "zone_general_store" )
        {
            if ( !is_general_store_open() )
                continue;
        }

        if ( stub.in_zone == "zone_underground_courthouse2" )
        {
            if ( !maps\mp\zm_buried::is_courthouse_open() )
                continue;
        }

        if ( stub.in_zone == "zone_tunnels_center" )
        {
            if ( !maps\mp\zm_buried::is_tunnel_open() )
                continue;
        }

        stubs[stubs.size] = stub;
    }

    if ( isdefined( remove_stub ) )
        arrayremovevalue( level.sloth_wallbuy_stubs, remove_stub );

    return stubs;
}

wallbuy_get_piece_array()
{
    pieces = [];

    for ( i = 0; i < level.chalk_pieces.size; i++ )
    {
        piece = level.chalk_pieces[i];

        if ( isdefined( piece.unitrigger ) && !is_true( piece.built ) )
            pieces[pieces.size] = piece;
    }

    return pieces;
}

wallbuy_action()
{
    self endon( "death" );
    self endon( "stop_action" );
    self maps\mp\zombies\_zm_ai_sloth::common_context_action();
    wallbuy_struct = getstruct( "sloth_allign_gunshop", "targetname" );
    asd_name = "zm_wallbuy_remove";
    anim_id = self getanimfromasd( asd_name, 0 );
    start_org = getstartorigin( wallbuy_struct.origin, wallbuy_struct.angles, anim_id );
    start_ang = getstartangles( wallbuy_struct.origin, wallbuy_struct.angles, anim_id );
    self setgoalpos( start_org );

    self waittill( "goal" );

    self setgoalpos( self.origin );
    self sloth_face_object( undefined, "angle", start_ang[1], 0.9 );
    self animscripted( wallbuy_struct.origin, wallbuy_struct.angles, asd_name );
    maps\mp\animscripts\zm_shared::donotetracks( "wallbuy_remove_anim", ::wallbuy_grab_pieces );

    if ( !self.wallbuy_stubs.size || !self.wallbuy_pieces.size )
    {
        self.context_done = 1;
        return;
    }

    for ( i = 0; i < self.pieces_needed; i++ )
    {
        stub = self.wallbuy_stubs[i];
        vec_right = vectornormalize( anglestoright( stub.angles ) );
        org = stub.origin - vec_right * 60;
        org = groundpos( org );
        self setgoalpos( org );
        skip_piece = 0;

        while ( true )
        {
            if ( is_true( stub.built ) )
            {
/#
                sloth_print( "stub was built during pathing" );
#/
                skip_piece = 1;
                break;
            }

            dist = distancesquared( self.origin, org );

            if ( dist < 576 )
                break;

            wait 0.1;
        }

        if ( !skip_piece )
        {
            self setgoalpos( self.origin );
            chalk_angle = vectortoangles( vec_right );
            self sloth_face_object( stub, "angle", chalk_angle[1], 0.9 );

            if ( is_true( stub.built ) )
            {
/#
                sloth_print( "stub was built during facing" );
#/
                skip_piece = 1;
            }
        }

        self player_set_buildable_piece( self.wallbuy_pieces[i], 1 );
        current_piece = self player_get_buildable_piece( 1 );

        if ( skip_piece )
        {
            arrayremovevalue( self.wallbuy_pieces_taken, current_piece );
            current_piece maps\mp\zm_buried_buildables::ondrop_chalk( self );
            self orientmode( "face default" );
            continue;
        }

        self thread player_draw_chalk( stub );
        self maps\mp\zombies\_zm_ai_sloth::action_animscripted( "zm_wallbuy_add", "wallbuy_add_anim", org, chalk_angle );
        self notify( "end_chalk_dust" );
        playsoundatposition( "zmb_cha_ching_loud", stub.origin );

        if ( is_true( stub.built ) )
        {
            current_piece maps\mp\zm_buried_buildables::ondrop_chalk( self );
/#
            sloth_print( "stub was built during anim" );
#/
        }
        else
        {
            stub maps\mp\zm_buried_buildables::onuseplantobject_chalk( self );
            stub buildablestub_finish_build( self );
            stub buildablestub_remove();
            thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( stub );
/#
            sloth_print( "built " + self player_get_buildable_piece( 1 ).script_noteworthy );
#/
        }

        arrayremovevalue( self.wallbuy_pieces_taken, self player_get_buildable_piece( 1 ) );
        self orientmode( "face default" );
    }

    self.context_done = 1;
}

wallbuy_grab_pieces( note )
{
    if ( note == "pulled" )
    {
        self.wallbuy_stubs = wallbuy_get_stub_array();
        self.wallbuy_pieces = wallbuy_get_piece_array();
        self.pieces_needed = self.wallbuy_stubs.size;

        if ( self.pieces_needed > self.wallbuy_pieces.size )
            self.pieces_needed = self.wallbuy_pieces.size;

        self.wallbuy_pieces = array_randomize( self.wallbuy_pieces );
        self.wallbuy_pieces_taken = [];

        for ( i = 0; i < self.pieces_needed; i++ )
        {
            self.wallbuy_pieces_taken[i] = self.wallbuy_pieces[i];
            self.wallbuy_pieces[i] maps\mp\zombies\_zm_buildables::piece_unspawn();
        }
    }
}

wallbuy_interrupt()
{
    if ( isdefined( self.wallbuy_pieces_taken ) && self.wallbuy_pieces_taken.size > 0 )
    {
        foreach ( wallbuy in self.wallbuy_pieces_taken )
            wallbuy maps\mp\zm_buried_buildables::ondrop_chalk( self );
    }
}
