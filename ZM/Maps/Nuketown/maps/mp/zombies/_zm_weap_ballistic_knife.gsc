// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_stats;

init()
{
    if ( !isdefined( level.ballistic_knife_autorecover ) )
        level.ballistic_knife_autorecover = 1;

    if ( isdefined( level._uses_retrievable_ballisitic_knives ) && level._uses_retrievable_ballisitic_knives == 1 )
    {
        precachemodel( "t5_weapon_ballistic_knife_projectile" );
        precachemodel( "t5_weapon_ballistic_knife_blade_retrieve" );
    }
}

on_spawn( watcher, player )
{
    player endon( "death" );
    player endon( "disconnect" );
    player endon( "zmb_lost_knife" );
    level endon( "game_ended" );

    self waittill( "stationary", endpos, normal, angles, attacker, prey, bone );

    isfriendly = 0;

    if ( isdefined( endpos ) )
    {
        retrievable_model = spawn( "script_model", endpos );
        retrievable_model setmodel( "t5_weapon_ballistic_knife_blade_retrieve" );
        retrievable_model setowner( player );
        retrievable_model.owner = player;
        retrievable_model.angles = angles;
        retrievable_model.name = watcher.weapon;

        if ( isdefined( prey ) )
        {
            if ( isplayer( prey ) && player.team == prey.team )
                isfriendly = 1;
            else if ( isai( prey ) && player.team == prey.team )
                isfriendly = 1;

            if ( !isfriendly )
            {
                retrievable_model linkto( prey, bone );
                retrievable_model thread force_drop_knives_to_ground_on_death( player, prey );
            }
            else if ( isfriendly )
            {
                retrievable_model physicslaunch( normal, ( randomint( 10 ), randomint( 10 ), randomint( 10 ) ) );
                normal = ( 0, 0, 1 );
            }
        }

        watcher.objectarray[watcher.objectarray.size] = retrievable_model;

        if ( isfriendly )
            retrievable_model waittill( "stationary" );

        retrievable_model thread drop_knives_to_ground( player );

        if ( isfriendly )
            player notify( "ballistic_knife_stationary", retrievable_model, normal );
        else
            player notify( "ballistic_knife_stationary", retrievable_model, normal, prey );

        retrievable_model thread wait_to_show_glowing_model( prey );
    }
}

wait_to_show_glowing_model( prey )
{
    level endon( "game_ended" );
    self endon( "death" );
    wait 2;
    self setmodel( "t5_weapon_ballistic_knife_blade_retrieve" );
}

on_spawn_retrieve_trigger( watcher, player )
{
    player endon( "death" );
    player endon( "disconnect" );
    player endon( "zmb_lost_knife" );
    level endon( "game_ended" );

    player waittill( "ballistic_knife_stationary", retrievable_model, normal, prey );

    if ( !isdefined( retrievable_model ) )
        return;

    trigger_pos = [];

    if ( isdefined( prey ) && ( isplayer( prey ) || isai( prey ) ) )
    {
        trigger_pos[0] = prey.origin[0];
        trigger_pos[1] = prey.origin[1];
        trigger_pos[2] = prey.origin[2] + 10;
    }
    else
    {
        trigger_pos[0] = retrievable_model.origin[0] + 10 * normal[0];
        trigger_pos[1] = retrievable_model.origin[1] + 10 * normal[1];
        trigger_pos[2] = retrievable_model.origin[2] + 10 * normal[2];
    }

    if ( is_true( level.ballistic_knife_autorecover ) )
    {
        trigger_pos[2] -= 50.0;
        pickup_trigger = spawn( "trigger_radius", ( trigger_pos[0], trigger_pos[1], trigger_pos[2] ), 0, 50, 100 );
    }
    else
    {
        pickup_trigger = spawn( "trigger_radius_use", ( trigger_pos[0], trigger_pos[1], trigger_pos[2] ) );
        pickup_trigger setcursorhint( "HINT_NOICON" );
    }

    pickup_trigger.owner = player;
    retrievable_model.retrievabletrigger = pickup_trigger;
    hint_string = &"WEAPON_BALLISTIC_KNIFE_PICKUP";

    if ( isdefined( hint_string ) )
        pickup_trigger sethintstring( hint_string );
    else
        pickup_trigger sethintstring( &"GENERIC_PICKUP" );

    pickup_trigger setteamfortrigger( player.team );
    player clientclaimtrigger( pickup_trigger );
    pickup_trigger enablelinkto();

    if ( isdefined( prey ) )
        pickup_trigger linkto( prey );
    else
        pickup_trigger linkto( retrievable_model );

    if ( isdefined( level.knife_planted ) )
        [[ level.knife_planted ]]( retrievable_model, pickup_trigger, prey );

    retrievable_model thread watch_use_trigger( pickup_trigger, retrievable_model, ::pick_up, watcher.weapon, watcher.pickupsoundplayer, watcher.pickupsound );
    player thread watch_shutdown( pickup_trigger, retrievable_model );
}

debug_print( endpos )
{
/#
    self endon( "death" );

    while ( true )
    {
        print3d( endpos, "pickup_trigger" );
        wait 0.05;
    }
#/
}

watch_use_trigger( trigger, model, callback, weapon, playersoundonuse, npcsoundonuse )
{
    self endon( "death" );
    self endon( "delete" );
    level endon( "game_ended" );
    max_ammo = weaponmaxammo( weapon ) + 1;
    autorecover = is_true( level.ballistic_knife_autorecover );

    while ( true )
    {
        trigger waittill( "trigger", player );

        if ( !isalive( player ) )
            continue;

        if ( !player isonground() && !is_true( trigger.force_pickup ) )
            continue;

        if ( isdefined( trigger.triggerteam ) && player.team != trigger.triggerteam )
            continue;

        if ( isdefined( trigger.claimedby ) && player != trigger.claimedby )
            continue;

        ammo_stock = player getweaponammostock( weapon );
        ammo_clip = player getweaponammoclip( weapon );
        current_weapon = player getcurrentweapon();
        total_ammo = ammo_stock + ammo_clip;
        hasreloaded = 1;

        if ( total_ammo > 0 && ammo_stock == total_ammo && current_weapon == weapon )
            hasreloaded = 0;

        if ( total_ammo >= max_ammo || !hasreloaded )
            continue;

        if ( autorecover || player usebuttonpressed() && !player.throwinggrenade && !player meleebuttonpressed() || is_true( trigger.force_pickup ) )
        {
            if ( isdefined( playersoundonuse ) )
                player playlocalsound( playersoundonuse );

            if ( isdefined( npcsoundonuse ) )
                player playsound( npcsoundonuse );

            player thread [[ callback ]]( weapon, model, trigger );
            break;
        }
    }
}

pick_up( weapon, model, trigger )
{
    if ( self hasweapon( weapon ) )
    {
        current_weapon = self getcurrentweapon();

        if ( current_weapon != weapon )
        {
            clip_ammo = self getweaponammoclip( weapon );

            if ( !clip_ammo )
                self setweaponammoclip( weapon, 1 );
            else
            {
                new_ammo_stock = self getweaponammostock( weapon ) + 1;
                self setweaponammostock( weapon, new_ammo_stock );
            }
        }
        else
        {
            new_ammo_stock = self getweaponammostock( weapon ) + 1;
            self setweaponammostock( weapon, new_ammo_stock );
        }
    }

    self maps\mp\zombies\_zm_stats::increment_client_stat( "ballistic_knives_pickedup" );
    self maps\mp\zombies\_zm_stats::increment_player_stat( "ballistic_knives_pickedup" );
    model destroy_ent();
    trigger destroy_ent();
}

destroy_ent()
{
    if ( isdefined( self ) )
    {
        if ( isdefined( self.glowing_model ) )
            self.glowing_model delete();

        self delete();
    }
}

watch_shutdown( trigger, model )
{
    self waittill_any( "death_or_disconnect", "zmb_lost_knife" );
    trigger destroy_ent();
    model destroy_ent();
}

drop_knives_to_ground( player )
{
    player endon( "death" );
    player endon( "zmb_lost_knife" );

    for (;;)
    {
        level waittill( "drop_objects_to_ground", origin, radius );

        if ( distancesquared( origin, self.origin ) < radius * radius )
        {
            self physicslaunch( ( 0, 0, 1 ), vectorscale( ( 1, 1, 1 ), 5.0 ) );
            self thread update_retrieve_trigger( player );
        }
    }
}

force_drop_knives_to_ground_on_death( player, prey )
{
    self endon( "death" );
    player endon( "zmb_lost_knife" );

    prey waittill( "death" );

    self unlink();
    self physicslaunch( ( 0, 0, 1 ), vectorscale( ( 1, 1, 1 ), 5.0 ) );
    self thread update_retrieve_trigger( player );
}

update_retrieve_trigger( player )
{
    self endon( "death" );
    player endon( "zmb_lost_knife" );

    if ( isdefined( level.custom_update_retrieve_trigger ) )
    {
        self [[ level.custom_update_retrieve_trigger ]]( player );
        return;
    }

    self waittill( "stationary" );

    trigger = self.retrievabletrigger;
    trigger.origin = ( self.origin[0], self.origin[1], self.origin[2] + 10 );
    trigger linkto( self );
}
