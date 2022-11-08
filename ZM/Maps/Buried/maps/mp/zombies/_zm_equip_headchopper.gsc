// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\animscripts\zm_death;
#include maps\mp\animscripts\zm_run;
#include maps\mp\zombies\_zm_audio;

init( pickupstring, howtostring )
{
    if ( !maps\mp\zombies\_zm_equipment::is_equipment_included( "equip_headchopper_zm" ) )
        return;

    level.headchopper_name = "equip_headchopper_zm";
    init_animtree();
    maps\mp\zombies\_zm_equipment::register_equipment( level.headchopper_name, pickupstring, howtostring, "t6_wpn_zmb_chopper", "headchopper", undefined, ::transferheadchopper, ::dropheadchopper, ::pickupheadchopper, ::placeheadchopper );
    maps\mp\zombies\_zm_equipment::add_placeable_equipment( level.headchopper_name, "t6_wpn_zmb_chopper", undefined, "wallmount" );
    maps\mp\zombies\_zm_spawner::register_zombie_damage_callback( ::headchopper_zombie_damage_response );
    maps\mp\zombies\_zm_spawner::register_zombie_death_animscript_callback( ::headchopper_zombie_death_response );
    level thread onplayerconnect();
    maps\mp\gametypes_zm\_weaponobjects::createretrievablehint( "equip_headchopper", pickupstring );
    level._effect["headchoppere_on"] = loadfx( "maps/zombie_buried/fx_buried_headchopper_os" );
    thread init_anim_slice_times();
    thread wait_init_damage();
}

wait_init_damage()
{
    while ( !isdefined( level.zombie_vars ) || !isdefined( level.zombie_vars["zombie_health_start"] ) )
        wait 1;

    level.headchopper_damage = maps\mp\zombies\_zm::ai_zombie_health( 50 );
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread onplayerspawned();
        player thread player_hide_turrets_from_other_players();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );
    self thread setupwatchers();

    for (;;)
    {
        self waittill( "spawned_player" );

        self thread watchheadchopperuse();
    }
}

setupwatchers()
{
    self waittill( "weapon_watchers_created" );

    watcher = maps\mp\gametypes_zm\_weaponobjects::getweaponobjectwatcher( "equip_headchopper" );
    watcher.onspawnretrievetriggers = maps\mp\zombies\_zm_equipment::equipment_onspawnretrievableweaponobject;
}

watchheadchopperuse()
{
    self notify( "watchHeadChopperUse" );
    self endon( "watchHeadChopperUse" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "equipment_placed", weapon, weapname );

        if ( weapname == level.headchopper_name )
        {
            self cleanupoldheadchopper();
            self.buildableheadchopper = weapon;
            self thread startheadchopperdeploy( weapon );
        }
    }
}

cleanupoldheadchopper()
{
    if ( isdefined( self.buildableheadchopper ) )
    {
        if ( isdefined( self.buildableheadchopper.stub ) )
        {
            thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.buildableheadchopper.stub );
            self.buildableheadchopper.stub = undefined;
        }

        self.buildableheadchopper delete();
        self.headchopper_kills = undefined;
    }

    if ( isdefined( level.headchopper_sound_ent ) )
    {
        level.headchopper_sound_ent delete();
        level.headchopper_sound_ent = undefined;
    }
}

watchforcleanup()
{
    self notify( "headchopper_cleanup" );
    self endon( "headchopper_cleanup" );
    self waittill_any( "death_or_disconnect", "equip_headchopper_zm_taken", "equip_headchopper_zm_pickup" );
    cleanupoldheadchopper();
}

player_hide_turrets_from_other_players()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "create_equipment_turret", equipment, turret );

        if ( equipment == level.headchopper_name )
        {
            turret setinvisibletoall();
            turret setvisibletoplayer( self );
        }
    }
}

placeheadchopper( origin, angles )
{
    item = self maps\mp\zombies\_zm_equipment::placed_equipment_think( "t6_wpn_zmb_chopper", level.headchopper_name, origin, angles, 100, 0 );

    if ( isdefined( item ) )
    {
        item.headchopper_kills = self.headchopper_kills;
        item.requires_pickup = 1;
        item.zombie_attack_callback = ::headchopper_add_chop_ent;
    }

    self.headchopper_kills = undefined;
    return item;
}

dropheadchopper()
{
    item = self maps\mp\zombies\_zm_equipment::dropped_equipment_think( "t6_wpn_zmb_chopper", level.headchopper_name, self.origin, self.angles, 100, 0 );

    if ( isdefined( item ) )
    {
        item.headchopper_kills = self.headchopper_kills;
        item.requires_pickup = 1;
    }

    self.headchopper_kills = undefined;
    return item;
}

pickupheadchopper( item )
{
    self.headchopper_kills = item.headchopper_kills;
    item.headchopper_kills = undefined;
}

transferheadchopper( fromplayer, toplayer )
{
    buildableheadchopper = toplayer.buildableheadchopper;
    toarmed = 0;

    if ( isdefined( buildableheadchopper ) )
        toarmed = isdefined( buildableheadchopper.is_armed ) && buildableheadchopper.is_armed;

    headchopper_kills = toplayer.headchopper_kills;
    fromarmed = 0;

    if ( isdefined( fromplayer.buildableheadchopper ) )
        fromarmed = isdefined( fromplayer.buildableheadchopper.is_armed ) && fromplayer.buildableheadchopper.is_armed;

    toplayer.buildableheadchopper = fromplayer.buildableheadchopper;
    toplayer.buildableheadchopper.original_owner = toplayer;
    toplayer.buildableheadchopper.owner = toplayer;
    toplayer notify( "equip_headchopper_zm_taken" );
    toplayer.headchopper_kills = fromplayer.headchopper_kills;
    toplayer thread startheadchopperdeploy( toplayer.buildableheadchopper, fromarmed );
    fromplayer.buildableheadchopper = buildableheadchopper;
    fromplayer.headchopper_kills = headchopper_kills;
    fromplayer notify( "equip_headchopper_zm_taken" );

    if ( isdefined( fromplayer.buildableheadchopper ) )
    {
        fromplayer thread startheadchopperdeploy( fromplayer.buildableheadchopper, toarmed );
        fromplayer.buildableheadchopper.original_owner = fromplayer;
        fromplayer.buildableheadchopper.owner = fromplayer;
    }
    else
        fromplayer maps\mp\zombies\_zm_equipment::equipment_release( level.headchopper_name );
}

headchopper_in_range( delta, origin, radius )
{
    if ( distancesquared( self.target.origin, origin ) < radius * radius )
        return true;

    return false;
}

headchopper_power_on( origin, radius )
{
/#
    println( "^1ZM POWER: trap on\\n" );
#/
    if ( !isdefined( self.target ) )
        return;

    self.target.power_on = 1;
    self.target.power_on_time = gettime();
}

headchopper_power_off( origin, radius )
{
/#
    println( "^1ZM POWER: trap off\\n" );
#/
    if ( !isdefined( self.target ) )
        return;

    self.target.power_on = 0;
}

startheadchopperdeploy( weapon, armed )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "equip_headchopper_zm_taken" );
    self thread watchforcleanup();
    electricradius = 45;

    if ( isdefined( self.headchopper_kills ) )
    {
        weapon.headchopper_kills = self.headchopper_kills;
        self.headchopper_kills = undefined;
    }

    if ( !isdefined( weapon.headchopper_kills ) )
        weapon.headchopper_kills = 0;

    if ( isdefined( weapon ) )
    {
/#
        weapon thread debugheadchopper( electricradius );
#/
        fwdangles = anglestoup( weapon.angles );
        traceback = groundtrace( weapon.origin + fwdangles * 5, weapon.origin - fwdangles * 999999, 0, weapon );

        if ( isdefined( traceback ) && isdefined( traceback["entity"] ) )
        {
            weapon.planted_on_ent = traceback["entity"];

            if ( isdefined( traceback["entity"].targetname ) )
            {
                parententities = getentarray( traceback["entity"].targetname, "target" );

                if ( isdefined( parententities ) && parententities.size > 0 )
                {
                    parententity = parententities[0];

                    if ( isdefined( parententity.targetname ) )
                    {
                        if ( parententity.targetname == "zombie_debris" || parententity.targetname == "zombie_door" )
                            weapon thread destroyheadchopperonplantedblockeropen();
                    }
                }
            }

            weapon thread destroyheadchopperonplantedentitydeath();
        }

        weapon.deployed_time = gettime();

        if ( isdefined( level.equipment_headchopper_needs_power ) && level.equipment_headchopper_needs_power )
        {
            weapon.power_on = 0;
            maps\mp\zombies\_zm_power::add_temp_powered_item( ::headchopper_power_on, ::headchopper_power_off, ::headchopper_in_range, maps\mp\zombies\_zm_power::cost_high, 1, weapon.power_on, weapon );
        }
        else
            weapon.power_on = 1;

        if ( !weapon.power_on )
            self iprintlnbold( &"ZOMBIE_NEED_LOCAL_POWER" );

        self thread headchopperthink( weapon, electricradius, armed );

        if ( !( isdefined( level.equipment_headchopper_needs_power ) && level.equipment_headchopper_needs_power ) )
        {

        }

        self thread maps\mp\zombies\_zm_buildables::delete_on_disconnect( weapon );

        weapon waittill( "death" );

        if ( isdefined( level.headchopper_sound_ent ) )
        {
            level.headchopper_sound_ent playsound( "wpn_zmb_electrap_stop" );
            level.headchopper_sound_ent delete();
            level.headchopper_sound_ent = undefined;
        }

        self notify( "headchopper_cleanup" );
    }
}

headchopper_zombie_damage_response( mod, hit_location, hit_origin, player, amount )
{
    if ( isdefined( self.damageweapon ) && self.damageweapon == level.headchopper_name || isdefined( self.damageweapon_name ) && self.damageweapon_name == level.headchopper_name )
        player.planted_wallmount_on_a_zombie = 1;

    return 0;
}

headchopper_zombie_death_response( mod, hit_location, hit_origin, player, amount )
{
    if ( isdefined( self.damageweapon ) && self.damageweapon == level.headchopper_name && isdefined( self.damagemod ) && self.damagemod == "MOD_IMPACT" )
    {
        origin = self.origin;

        if ( isdefined( self.damagehit_origin ) )
            origin = self.damagehit_origin;

        players = get_players();
        choppers = [];

        foreach ( player in players )
        {
            if ( isdefined( player.buildableheadchopper ) )
                choppers[choppers.size] = player.buildableheadchopper;
        }

        chopper = getclosest( origin, choppers );
        level thread headchopper_zombie_death_remove_chopper( chopper );
    }

    return 0;
}

headchopper_zombie_death_remove_chopper( chopper )
{
    player = chopper.owner;
    thread maps\mp\zombies\_zm_equipment::equipment_disappear_fx( chopper.origin, undefined, chopper.angles );
    chopper dropped_equipment_destroy( 0 );

    if ( !player hasweapon( level.headchopper_name ) )
    {
        player giveweapon( level.headchopper_name );
        player setweaponammoclip( level.headchopper_name, 1 );
        player setactionslot( 1, "weapon", level.headchopper_name );
    }
}

#using_animtree("zombie_headchopper");

init_animtree()
{
    scriptmodelsuseanimtree( #animtree );
}

init_anim_slice_times()
{
    level.headchopper_slice_times = [];
    slice_times = getnotetracktimes( %o_zmb_chopper_slice_slow, "slice" );
    retract_times = getnotetracktimes( %o_zmb_chopper_slice_slow, "retract" );
    animlength = getanimlength( %o_zmb_chopper_slice_slow );

    foreach ( frac in slice_times )
        level.headchopper_slice_times[level.headchopper_slice_times.size] = animlength * frac;

    foreach ( frac in retract_times )
        level.headchopper_slice_times[level.headchopper_slice_times.size] = animlength * frac;
}

headchopper_animate( weapon, armed )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "equip_headchopper_zm_taken" );
    weapon endon( "death" );
    weapon useanimtree( #animtree );
    f_animlength = getanimlength( %o_zmb_chopper_slice_fast );
    s_animlength = getanimlength( %o_zmb_chopper_slice_slow );
    weapon thread headchopper_audio();
    prearmed = 0;

    if ( isdefined( armed ) && armed )
        prearmed = 1;

    zombies_only = 0;

    while ( isdefined( weapon ) )
    {
        if ( !prearmed )
            wait 0.1;
        else
            wait 0.05;

        prearmed = 0;
        weapon.is_armed = 1;

        weapon waittill( "chop", zombies_only );

        if ( isdefined( weapon ) )
        {
            weapon.is_slicing = 1;

            if ( isdefined( zombies_only ) && zombies_only )
            {
                weapon thread watch_notetracks_slicing();
                weapon playsound( "zmb_headchopper_swing" );
                weapon setanim( %o_zmb_chopper_slice_slow );
                wait( s_animlength );
                weapon clearanim( %o_zmb_chopper_slice_slow, 0.2 );
            }
            else
            {
                weapon setanim( %o_zmb_chopper_slice_fast );
                wait( f_animlength );
                weapon clearanim( %o_zmb_chopper_slice_fast, 0.2 );
            }

            weapon notify( "end" );
            weapon.is_slicing = 0;
        }
    }
}

watch_notetracks_slicing()
{
    self endon( "death" );

    foreach ( time in level.headchopper_slice_times )
        self thread watch_notetracks_slicing_times( time );
}

watch_notetracks_slicing_times( time )
{
    self endon( "death" );
    wait( time );
    self notify( "slicing" );
}

playheadchopperresetaudio( time )
{
    self endon( "headchopperAudioCleanup" );
    ent = spawn( "script_origin", self.origin );
    ent playloopsound( "zmb_highrise_launcher_reset_loop" );
    self thread deleteentwhensounddone( time, ent );

    self waittill( "death" );

    ent delete();
}

deleteentwhensounddone( time, ent )
{
    self endon( "death" );
    wait( time );
    self notify( "headchopperAudioCleanup" );
    ent delete();
}

headchopper_audio()
{
    loop_ent = spawn( "script_origin", self.origin );
    loop_ent playloopsound( "zmb_highrise_launcher_loop" );

    self waittill( "death" );

    loop_ent delete();
}

headchopper_fx( weapon )
{
    weapon endon( "death" );
    self endon( "equip_headchopper_zm_taken" );

    while ( isdefined( weapon ) )
    {
        playfxontag( level._effect["headchoppere_on"], weapon, "tag_origin" );
        wait 1;
    }
}

headchopperthink( weapon, electricradius, armed )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "equip_headchopper_zm_taken" );
    weapon endon( "death" );
    radiussquared = electricradius * electricradius;
    traceposition = weapon getcentroid() + anglestoforward( flat_angle( weapon.angles ) ) * -15;
    trace = bullettrace( traceposition, traceposition + vectorscale( ( 0, 0, -1 ), 48.0 ), 1, weapon );
    trigger_origin = weapon gettagorigin( "TAG_SAW" );
    trigger = spawn( "trigger_box", trigger_origin, 1, 8, 128, 64 );
    trigger.origin += anglestoup( weapon.angles ) * 32.0;
    trigger.angles = weapon.angles;
    trigger enablelinkto();
    trigger linkto( weapon );
    weapon.trigger = trigger;
/#
    trigger.extent = ( 4.0, 64.0, 32.0 );
#/
    weapon thread headchopperthinkcleanup( trigger );
    direction_forward = anglestoforward( flat_angle( weapon.angles ) + vectorscale( ( -1, 0, 0 ), 60.0 ) );
    direction_vector = vectorscale( direction_forward, 1024 );
    direction_origin = weapon.origin + direction_vector;
    home_angles = weapon.angles;
    weapon.is_armed = 0;
    self thread headchopper_fx( weapon );
    self thread headchopper_animate( weapon, armed );

    while ( !( isdefined( weapon.is_armed ) && weapon.is_armed ) )
        wait 0.5;

    weapon.chop_targets = [];
    self thread targeting_thread( weapon, trigger );

    while ( isdefined( weapon ) )
    {
        wait_for_targets( weapon );

        if ( isdefined( weapon.chop_targets ) && weapon.chop_targets.size > 0 )
        {
            is_slicing = 1;
            slice_count = 0;

            while ( isdefined( is_slicing ) && is_slicing )
            {
                weapon notify( "chop", weapon.zombies_only );
                weapon.is_armed = 0;
                weapon.zombies_only = 1;

                foreach ( ent in weapon.chop_targets )
                    self thread headchopperattack( weapon, ent );

                if ( weapon.headchopper_kills >= 42 )
                    self thread headchopper_expired( weapon );

                weapon.chop_targets = [];
                weapon waittill_any( "slicing", "end" );
                weapon notify( "slice_done" );
                slice_count++;
                is_slicing = weapon.is_slicing;
            }

            while ( !( isdefined( weapon.is_armed ) && weapon.is_armed ) )
                wait 0.5;
        }
        else
            wait 0.1;
    }
}

headchopperattack( weapon, ent )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "equip_headchopper_zm_taken" );
    weapon endon( "death" );

    if ( !isdefined( ent ) || !isalive( ent ) )
        return;

    eye_position = ent geteye();
    head_position = eye_position[2] + 13;
    foot_position = ent.origin[2];
    length_head_to_toe = abs( head_position - foot_position );
    length_head_to_toe_25_percent = length_head_to_toe * 0.25;
    is_headchop = weapon.origin[2] <= head_position && weapon.origin[2] >= head_position - length_head_to_toe_25_percent;
    is_torsochop = weapon.origin[2] <= head_position - length_head_to_toe_25_percent && weapon.origin[2] >= foot_position + length_head_to_toe_25_percent;
    is_footchop = abs( foot_position - weapon.origin[2] ) <= length_head_to_toe_25_percent;
    trace_point = undefined;

    if ( isdefined( is_headchop ) && is_headchop )
        trace_point = eye_position;
    else if ( isdefined( is_torsochop ) && is_torsochop )
        trace_point = ent.origin + ( 0, 0, length_head_to_toe_25_percent * 2 );
    else
        trace_point = ent.origin + ( 0, 0, length_head_to_toe_25_percent );

    fwdangles = anglestoup( weapon.angles );
    tracefwd = bullettrace( weapon.origin + fwdangles * 5, trace_point, 0, weapon, 1, 1 );

    if ( !isdefined( tracefwd ) || !isdefined( tracefwd["position"] ) || tracefwd["position"] != trace_point )
        return;

    if ( isplayer( ent ) )
    {
        if ( isdefined( weapon.deployed_time ) && gettime() - weapon.deployed_time <= 2000 )
            return;

        if ( isdefined( is_headchop ) && is_headchop && !ent hasperk( "specialty_armorvest" ) )
            ent dodamage( ent.health, weapon.origin );
        else if ( isdefined( is_torsochop ) && is_torsochop )
            ent dodamage( 50, weapon.origin );
        else if ( isdefined( is_footchop ) && is_footchop )
            ent dodamage( 25, weapon.origin );
        else
            ent dodamage( 10, weapon.origin );
    }
    else
    {
        if ( !( isdefined( is_headchop ) && is_headchop ) || !( isdefined( is_headchop ) && is_headchop ) && !( isdefined( ent.has_legs ) && ent.has_legs ) )
        {
            headchop_height = 25;

            if ( !( isdefined( ent.has_legs ) && ent.has_legs ) )
                headchop_height = 35;

            is_headchop = abs( eye_position[2] - weapon.origin[2] ) <= headchop_height;
        }

        if ( isdefined( is_headchop ) && is_headchop )
        {
            if ( !( isdefined( ent.no_gib ) && ent.no_gib ) )
                ent maps\mp\zombies\_zm_spawner::zombie_head_gib();

            ent dodamage( ent.health + 666, weapon.origin );
            ent.headchopper_last_damage_time = gettime();
            ent playsound( "zmb_exp_jib_headchopper_zombie" );
            weapon.headchopper_kills++;
            self thread headchopper_kill_vo( ent );
        }
        else if ( isdefined( is_torsochop ) && is_torsochop )
        {
            if ( ent.health <= 20 )
            {
                ent playsound( "zmb_exp_jib_headchopper_zombie" );
                weapon.headchopper_kills++;
                self thread headchopper_kill_vo( ent );
            }

            ent dodamage( 20, weapon.origin );
            ent.headchopper_last_damage_time = gettime();
        }
        else if ( isdefined( is_footchop ) && is_footchop )
        {
            if ( !( isdefined( ent.no_gib ) && ent.no_gib ) )
            {
                ent.a.gib_ref = "no_legs";
                ent thread maps\mp\animscripts\zm_death::do_gib();
                ent.has_legs = 0;
                ent allowedstances( "crouch" );
                ent setphysparams( 15, 0, 24 );
                ent allowpitchangle( 1 );
                ent setpitchorient();
                ent thread maps\mp\animscripts\zm_run::needsdelayedupdate();

                if ( isdefined( ent.crawl_anim_override ) )
                    ent [[ ent.crawl_anim_override ]]();
            }

            if ( ent.health <= 10 )
            {
                ent playsound( "zmb_exp_jib_headchopper_zombie" );
                weapon.headchopper_kills++;
                self thread headchopper_kill_vo( ent );
            }

            ent dodamage( 10, weapon.origin );
            ent.headchopper_last_damage_time = gettime();
        }
    }
}

headchopper_kill_vo( zombie )
{
    self endon( "disconnect" );

    if ( !isdefined( zombie ) )
        return;

    if ( distance2dsquared( self.origin, zombie.origin ) < 1000000 )
    {
        if ( self is_player_looking_at( zombie.origin, 0.25 ) )
            self thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "kill", "headchopper" );
    }
}

wait_for_targets( weapon )
{
    weapon endon( "hi_priority_target" );

    while ( isdefined( weapon ) )
    {
        if ( isdefined( weapon.chop_targets ) && weapon.chop_targets.size > 0 )
        {
            wait 0.075;
            return;
        }

        wait 0.05;
    }
}

targeting_thread( weapon, trigger )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "equip_headchopper_zm_taken" );
    weapon endon( "death" );
    weapon.zombies_only = 1;

    while ( isdefined( weapon ) )
    {
        if ( weapon.is_armed || isdefined( weapon.is_slicing ) && weapon.is_slicing )
        {
            if ( isdefined( weapon.is_slicing ) && weapon.is_slicing )
                weapon waittill( "slice_done" );

            zombies = getaiarray( level.zombie_team );

            foreach ( zombie in zombies )
            {
                if ( !isdefined( zombie ) || !isalive( zombie ) )
                    continue;

                if ( isdefined( zombie.ignore_headchopper ) && zombie.ignore_headchopper )
                    continue;

                if ( zombie istouching( trigger ) )
                    weapon headchopper_add_chop_ent( zombie );
            }

            players = get_players();

            foreach ( player in players )
            {
                if ( is_player_valid( player ) && player istouching( trigger ) )
                {
                    weapon headchopper_add_chop_ent( player );
                    weapon.zombies_only = 0;
                }
            }

            if ( !weapon.zombies_only )
                weapon notify( "hi_priority_target" );
        }

        wait 0.05;
    }
}

headchopper_add_chop_ent( ent )
{
    self.chop_targets = add_to_array( self.chop_targets, ent, 0 );
}

headchopper_expired( weapon, usedestroyfx = 1 )
{
    weapon maps\mp\zombies\_zm_equipment::dropped_equipment_destroy( usedestroyfx );
    self maps\mp\zombies\_zm_equipment::equipment_release( level.headchopper_name );
    self.headchopper_kills = 0;
}

headchopperthinkcleanup( trigger )
{
    self waittill( "death" );

    if ( isdefined( trigger ) )
        trigger delete();
}

destroyheadchopperonplantedblockeropen( trigger )
{
    self endon( "death" );
    home_origin = self.planted_on_ent.origin;
    home_angles = self.planted_on_ent.angles;

    while ( isdefined( self.planted_on_ent ) )
    {
        if ( self.planted_on_ent.origin != home_origin || self.planted_on_ent.angles != home_angles )
            break;

        wait 0.5;
    }

    self.owner thread headchopper_expired( self, 0 );
}

destroyheadchopperonplantedentitydeath()
{
    self endon( "death" );

    self.planted_on_ent waittill( "death" );

    self.owner thread headchopper_expired( self, 0 );
}

destroyheadchopperstouching( usedestroyfx )
{
    headchoppers = self getheadchopperstouching();

    foreach ( headchopper in headchoppers )
        headchopper.owner thread headchopper_expired( headchopper, usedestroyfx );
}

getheadchopperstouching()
{
    headchoppers = [];
    players = get_players();

    foreach ( player in players )
    {
        if ( isdefined( player.buildableheadchopper ) )
        {
            chopper = player.buildableheadchopper;

            if ( isdefined( chopper.planted_on_ent ) && chopper.planted_on_ent == self )
            {
                headchoppers[headchoppers.size] = chopper;
                continue;
            }

            if ( chopper istouching( self ) )
            {
                headchoppers[headchoppers.size] = chopper;
                continue;
            }

            if ( distance2dsquared( chopper.origin, self.origin ) > 16384 )
                continue;

            fwdangles = anglestoup( chopper.angles );
            traceback = groundtrace( chopper.origin + fwdangles * 5, chopper.origin - fwdangles * 999999, 0, chopper );

            if ( isdefined( traceback ) && isdefined( traceback["entity"] ) && traceback["entity"] == self )
                headchoppers[headchoppers.size] = chopper;
        }
    }

    return headchoppers;
}

getheadchoppersnear( source_origin, max_distance = 128 )
{
    headchoppers = [];
    players = get_players();

    foreach ( player in players )
    {
        if ( isdefined( player.buildableheadchopper ) )
        {
            chopper = player.buildableheadchopper;

            if ( distancesquared( chopper.origin, source_origin ) < max_distance * max_distance )
                headchoppers[headchoppers.size] = chopper;
        }
    }

    return headchoppers;
}

check_headchopper_in_bad_area( origin )
{
    if ( !isdefined( level.headchopper_bad_areas ) )
        level.headchopper_bad_areas = getentarray( "headchopper_bad_area", "targetname" );

    scr_org = spawn( "script_origin", origin );
    in_bad_area = 0;

    foreach ( area in level.headchopper_bad_areas )
    {
        if ( scr_org istouching( area ) )
        {
            in_bad_area = 1;
            break;
        }
    }

    scr_org delete();
    return in_bad_area;
}

debugheadchopper( radius )
{
/#
    color_armed = ( 0, 1, 0 );
    color_unarmed = vectorscale( ( 1, 1, 0 ), 0.65 );

    while ( isdefined( self ) )
    {
        if ( getdvarint( _hash_EB512CB7 ) )
        {
            if ( isdefined( self.trigger ) )
            {
                color = color_unarmed;

                if ( isdefined( self.is_armed ) && self.is_armed )
                    color = color_armed;

                vec = self.trigger.extent;
                box( self.trigger.origin, vec * -1, vec, self.trigger.angles[1], color, 1, 0, 1 );
            }

            color = ( 0, 1, 0 );
            text = "";

            if ( isdefined( self.headchopper_kills ) )
                text = "" + self.headchopper_kills + "";
            else if ( isdefined( self.owner.headchopper_kills ) )
                text = "[ " + self.owner.headchopper_kills + " ]";

            print3d( self.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), text, color, 1, 0.5, 1 );
        }

        wait 0.05;
    }
#/
}
