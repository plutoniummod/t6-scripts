// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\gametypes_zm\_weaponobjects;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_buildables;

init( pickupstring, howtostring )
{
    if ( !maps\mp\zombies\_zm_equipment::is_equipment_included( "equip_springpad_zm" ) )
        return;

    level.springpad_name = "equip_springpad_zm";
    init_animtree();
    maps\mp\zombies\_zm_equipment::register_equipment( "equip_springpad_zm", pickupstring, howtostring, "zom_hud_trample_steam_complete", "springpad", undefined, ::transferspringpad, ::dropspringpad, ::pickupspringpad, ::placespringpad );
    maps\mp\zombies\_zm_equipment::add_placeable_equipment( "equip_springpad_zm", "p6_anim_zm_buildable_view_tramplesteam" );
    level thread onplayerconnect();
    maps\mp\gametypes_zm\_weaponobjects::createretrievablehint( "equip_springpad", pickupstring );
    level._effect["springpade_on"] = loadfx( "maps/zombie_highrise/fx_highrise_trmpl_steam_os" );

    if ( !isdefined( level.springpad_trigger_radius ) )
        level.springpad_trigger_radius = 72;

    thread wait_init_damage();
}

wait_init_damage()
{
    while ( !isdefined( level.zombie_vars ) || !isdefined( level.zombie_vars["zombie_health_start"] ) )
        wait 1;

    level.springpad_damage = maps\mp\zombies\_zm::ai_zombie_health( 50 );
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );
    self thread setupwatchers();

    for (;;)
    {
        self waittill( "spawned_player" );

        self thread watchspringpaduse();
    }
}

setupwatchers()
{
    self waittill( "weapon_watchers_created" );

    watcher = maps\mp\gametypes_zm\_weaponobjects::getweaponobjectwatcher( "equip_springpad" );
    watcher.onspawnretrievetriggers = maps\mp\zombies\_zm_equipment::equipment_onspawnretrievableweaponobject;
}

watchspringpaduse()
{
    self notify( "watchSpringPadUse" );
    self endon( "watchSpringPadUse" );
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "equipment_placed", weapon, weapname );

        if ( weapname == level.springpad_name )
        {
            self cleanupoldspringpad();
            self.buildablespringpad = weapon;
            self thread startspringpaddeploy( weapon );
        }
    }
}

cleanupoldspringpad()
{
    if ( isdefined( self.buildablespringpad ) )
    {
        if ( isdefined( self.buildablespringpad.stub ) )
        {
            thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.buildablespringpad.stub );
            self.buildablespringpad.stub = undefined;
        }

        self.buildablespringpad delete();
        self.springpad_kills = undefined;
    }

    if ( isdefined( level.springpad_sound_ent ) )
    {
        level.springpad_sound_ent delete();
        level.springpad_sound_ent = undefined;
    }
}

watchforcleanup()
{
    self notify( "springpad_cleanup" );
    self endon( "springpad_cleanup" );
    self waittill_any( "death_or_disconnect", "equip_springpad_zm_taken", "equip_springpad_zm_pickup" );
    cleanupoldspringpad();
}

placespringpad( origin, angles )
{
    if ( isdefined( self.turret_placement ) && !self.turret_placement["result"] )
    {
        forward = anglestoforward( angles );
        origin -= -24 * forward;
    }

    item = self maps\mp\zombies\_zm_equipment::placed_equipment_think( "p6_anim_zm_buildable_tramplesteam", "equip_springpad_zm", origin, angles, level.springpad_trigger_radius, -24 );

    if ( isdefined( item ) )
    {
        item.springpad_kills = self.springpad_kills;
        item.requires_pickup = 1;
        item.zombie_attack_callback = ::springpad_fling_attacker;
    }

    self.springpad_kills = undefined;
    return item;
}

dropspringpad()
{
    item = self maps\mp\zombies\_zm_equipment::dropped_equipment_think( "p6_anim_zm_buildable_tramplesteam", "equip_springpad_zm", self.origin, self.angles, level.springpad_trigger_radius, -24 );

    if ( isdefined( item ) )
    {
        item.springpad_kills = self.springpad_kills;
        item.requires_pickup = 1;
    }

    self.springpad_kills = undefined;
    return item;
}

pickupspringpad( item )
{
    self.springpad_kills = item.springpad_kills;
    item.springpad_kills = undefined;
}

transferspringpad( fromplayer, toplayer )
{
    buildablespringpad = toplayer.buildablespringpad;
    toarmed = 0;

    if ( isdefined( buildablespringpad ) )
        toarmed = isdefined( buildablespringpad.is_armed ) && buildablespringpad.is_armed;

    springpad_kills = toplayer.springpad_kills;
    fromarmed = 0;

    if ( isdefined( fromplayer.buildablespringpad ) )
        fromarmed = isdefined( fromplayer.buildablespringpad.is_armed ) && fromplayer.buildablespringpad.is_armed;

    toplayer.buildablespringpad = fromplayer.buildablespringpad;
    toplayer.buildablespringpad.original_owner = toplayer;
    toplayer.buildablespringpad.owner = toplayer;
    toplayer notify( "equip_springpad_zm_taken" );
    toplayer.springpad_kills = fromplayer.springpad_kills;
    toplayer thread startspringpaddeploy( toplayer.buildablespringpad, fromarmed );
    fromplayer.buildablespringpad = buildablespringpad;
    fromplayer.springpad_kills = springpad_kills;
    fromplayer notify( "equip_springpad_zm_taken" );

    if ( isdefined( fromplayer.buildablespringpad ) )
    {
        fromplayer thread startspringpaddeploy( fromplayer.buildablespringpad, toarmed );
        fromplayer.buildablespringpad.original_owner = fromplayer;
        fromplayer.buildablespringpad.owner = fromplayer;
    }
    else
        fromplayer maps\mp\zombies\_zm_equipment::equipment_release( "equip_springpad_zm" );
}

springpad_in_range( delta, origin, radius )
{
    if ( distancesquared( self.target.origin, origin ) < radius * radius )
        return true;

    return false;
}

springpad_power_on( origin, radius )
{
/#
    println( "^1ZM POWER: trap on\\n" );
#/
    if ( !isdefined( self.target ) )
        return;

    self.target.power_on = 1;
    self.target.power_on_time = gettime();
}

springpad_power_off( origin, radius )
{
/#
    println( "^1ZM POWER: trap off\\n" );
#/
    if ( !isdefined( self.target ) )
        return;

    self.target.power_on = 0;
}

startspringpaddeploy( weapon, armed )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "equip_springpad_zm_taken" );
    self thread watchforcleanup();
    electricradius = 45;

    if ( isdefined( self.springpad_kills ) )
    {
        weapon.springpad_kills = self.springpad_kills;
        self.springpad_kills = undefined;
    }

    if ( !isdefined( weapon.springpad_kills ) )
        weapon.springpad_kills = 0;

    if ( isdefined( weapon ) )
    {
/#
        weapon thread debugspringpad( electricradius );
#/
        if ( isdefined( level.equipment_springpad_needs_power ) && level.equipment_springpad_needs_power )
        {
            weapon.power_on = 0;
            maps\mp\zombies\_zm_power::add_temp_powered_item( ::springpad_power_on, ::springpad_power_off, ::springpad_in_range, maps\mp\zombies\_zm_power::cost_high, 1, weapon.power_on, weapon );
        }
        else
            weapon.power_on = 1;

        if ( !weapon.power_on )
            self iprintlnbold( &"ZOMBIE_NEED_LOCAL_POWER" );

        self thread springpadthink( weapon, electricradius, armed );

        if ( !( isdefined( level.equipment_springpad_needs_power ) && level.equipment_springpad_needs_power ) )
        {

        }

        self thread maps\mp\zombies\_zm_buildables::delete_on_disconnect( weapon );

        weapon waittill( "death" );

        if ( isdefined( level.springpad_sound_ent ) )
        {
            level.springpad_sound_ent playsound( "wpn_zmb_electrap_stop" );
            level.springpad_sound_ent delete();
            level.springpad_sound_ent = undefined;
        }

        self notify( "springpad_cleanup" );
    }
}

#using_animtree("zombie_springpad");

init_animtree()
{
    scriptmodelsuseanimtree( #animtree );
}

springpad_animate( weapon, armed )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "equip_springpad_zm_taken" );
    weapon endon( "death" );
    weapon useanimtree( #animtree );
    f_animlength = getanimlength( %o_zombie_buildable_tramplesteam_reset_zombie );
    r_animlength = getanimlength( %o_zombie_buildable_tramplesteam_reset );
    l_animlength = getanimlength( %o_zombie_buildable_tramplesteam_launch );
    weapon thread springpad_audio();
    prearmed = 0;

    if ( isdefined( armed ) && armed )
        prearmed = 1;

    fast_reset = 0;

    while ( isdefined( weapon ) )
    {
        if ( !prearmed )
        {
            if ( fast_reset )
            {
                weapon setanim( %o_zombie_buildable_tramplesteam_reset_zombie );
                weapon thread playspringpadresetaudio( f_animlength );
                wait( f_animlength );
            }
            else
            {
                weapon setanim( %o_zombie_buildable_tramplesteam_reset );
                weapon thread playspringpadresetaudio( r_animlength );
                wait( r_animlength );
            }
        }
        else
            wait 0.05;

        prearmed = 0;
        weapon notify( "armed" );
        fast_reset = 0;

        if ( isdefined( weapon ) )
        {
            weapon setanim( %o_zombie_buildable_tramplesteam_compressed_idle );

            weapon waittill( "fling", fast );

            fast_reset = fast;
        }

        if ( isdefined( weapon ) )
        {
            weapon setanim( %o_zombie_buildable_tramplesteam_launch );
            wait( l_animlength );
        }
    }
}

playspringpadresetaudio( time )
{
    self endon( "springpadAudioCleanup" );
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
    self notify( "springpadAudioCleanup" );
    ent delete();
}

springpad_audio()
{
    loop_ent = spawn( "script_origin", self.origin );
    loop_ent playloopsound( "zmb_highrise_launcher_loop" );

    self waittill( "death" );

    loop_ent delete();
}

springpad_fx( weapon )
{
    weapon endon( "death" );
    self endon( "equip_springpad_zm_taken" );

    while ( isdefined( weapon ) )
    {
        playfxontag( level._effect["springpade_on"], weapon, "tag_origin" );
        wait 1;
    }
}

springpadthink( weapon, electricradius, armed )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "equip_springpad_zm_taken" );
    weapon endon( "death" );
    radiussquared = electricradius * electricradius;
    trigger = spawn( "trigger_box", weapon getcentroid(), 1, 48, 48, 32 );
    trigger.origin += anglestoforward( flat_angle( weapon.angles ) ) * -15;
    trigger.angles = weapon.angles;
    trigger enablelinkto();
    trigger linkto( weapon );
    weapon.trigger = trigger;
/#
    trigger.extent = ( 24.0, 24.0, 16.0 );
#/
    weapon thread springpadthinkcleanup( trigger );
    direction_forward = anglestoforward( flat_angle( weapon.angles ) + vectorscale( ( -1, 0, 0 ), 60.0 ) );
    direction_vector = vectorscale( direction_forward, 1024 );
    direction_origin = weapon.origin + direction_vector;
    home_angles = weapon.angles;
    weapon.is_armed = 0;
    self thread springpad_fx( weapon );
    self thread springpad_animate( weapon, armed );

    weapon waittill( "armed" );

    weapon.is_armed = 1;
    weapon.fling_targets = [];
    self thread targeting_thread( weapon, trigger );

    while ( isdefined( weapon ) )
    {
        wait_for_targets( weapon );

        if ( isdefined( weapon.fling_targets ) && weapon.fling_targets.size > 0 )
        {
            weapon notify( "fling", weapon.zombies_only );
            weapon.is_armed = 0;
            weapon.zombies_only = 1;

            foreach ( ent in weapon.fling_targets )
            {
                if ( isplayer( ent ) )
                {
                    ent thread player_fling( weapon.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), weapon.angles, direction_vector, weapon );
                    continue;
                }

                if ( isdefined( ent ) && isdefined( ent.custom_springpad_fling ) )
                {
                    if ( !isdefined( self.num_zombies_flung ) )
                        self.num_zombies_flung = 0;

                    self.num_zombies_flung++;
                    self notify( "zombie_flung" );
                    ent thread [[ ent.custom_springpad_fling ]]( weapon, self );
                    continue;
                }

                if ( isdefined( ent ) )
                {
                    if ( !isdefined( self.num_zombies_flung ) )
                        self.num_zombies_flung = 0;

                    self.num_zombies_flung++;
                    self notify( "zombie_flung" );

                    if ( !isdefined( weapon.fling_scaler ) )
                        weapon.fling_scaler = 1;

                    if ( isdefined( weapon.direction_vec_override ) )
                        direction_vector = weapon.direction_vec_override;

                    ent dodamage( ent.health + 666, ent.origin );
                    ent startragdoll();
                    ent launchragdoll( direction_vector / 4 * weapon.fling_scaler );
                    weapon.springpad_kills++;
                }
            }

            if ( weapon.springpad_kills >= 28 )
                self thread springpad_expired( weapon );

            weapon.fling_targets = [];

            weapon waittill( "armed" );

            weapon.is_armed = 1;
        }
        else
            wait 0.1;
    }
}

wait_for_targets( weapon )
{
    weapon endon( "hi_priority_target" );

    while ( isdefined( weapon ) )
    {
        if ( isdefined( weapon.fling_targets ) && weapon.fling_targets.size > 0 )
        {
            wait 0.15;
            return;
        }

        wait 0.05;
    }
}

targeting_thread( weapon, trigger )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "equip_springpad_zm_taken" );
    weapon endon( "death" );
    weapon.zombies_only = 1;

    while ( isdefined( weapon ) )
    {
        if ( weapon.is_armed )
        {
            zombies = getaiarray( level.zombie_team );

            foreach ( zombie in zombies )
            {
                if ( !isdefined( zombie ) || !isalive( zombie ) )
                    continue;

                if ( isdefined( zombie.ignore_spring_pad ) && zombie.ignore_spring_pad )
                    continue;

                if ( zombie istouching( trigger ) )
                    weapon springpad_add_fling_ent( zombie );
            }

            players = get_players();

            foreach ( player in players )
            {
                if ( is_player_valid( player ) && player istouching( trigger ) )
                {
                    weapon springpad_add_fling_ent( player );
                    weapon.zombies_only = 0;
                }
            }

            if ( !weapon.zombies_only )
                weapon notify( "hi_priority_target" );
        }

        wait 0.05;
    }
}

springpad_fling_attacker( ent )
{
    springpad_add_fling_ent( ent );

    if ( isdefined( level.springpad_attack_delay ) )
        wait( level.springpad_attack_delay );
}

springpad_add_fling_ent( ent )
{
    self.fling_targets = add_to_array( self.fling_targets, ent, 0 );
}

springpad_expired( weapon )
{
    weapon maps\mp\zombies\_zm_equipment::dropped_equipment_destroy( 1 );
    self maps\mp\zombies\_zm_equipment::equipment_release( "equip_springpad_zm" );
    self.springpad_kills = 0;
}

player_fling( origin, angles, velocity, weapon )
{
    torigin = ( self.origin[0], self.origin[1], origin[2] );
    aorigin = ( origin + torigin ) * 0.5;
    trace = physicstrace( origin, torigin, vectorscale( ( -1, -1, 0 ), 15.0 ), ( 15, 15, 30 ), self );

    if ( !isdefined( trace ) || !isdefined( trace["fraction"] ) || trace["fraction"] < 1.0 )
    {
        if ( !isdefined( weapon.springpad_kills ) )
            weapon.springpad_kills = 0;

        weapon.springpad_kills += 5;

        if ( weapon.springpad_kills >= 28 )
            weapon.owner thread springpad_expired( weapon );

        return;
    }

    self setorigin( aorigin );
    wait_network_frame();
    self setvelocity( velocity );
}

springpadthinkcleanup( trigger )
{
    self waittill( "death" );

    if ( isdefined( trigger ) )
        trigger delete();
}

debugspringpad( radius )
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

            if ( isdefined( self.springpad_kills ) )
                text = "" + self.springpad_kills + "";
            else if ( isdefined( self.owner.springpad_kills ) )
                text = "[" + self.owner.springpad_kills + "]";

            print3d( self.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), text, color, 1, 0.5, 1 );
        }

        wait 0.05;
    }
#/
}
