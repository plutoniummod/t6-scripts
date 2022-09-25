// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_chugabud;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_clone;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm;
#include maps\mp\_visionset_mgr;

init()
{
    level.chugabud_laststand_func = ::chugabud_laststand;
    level thread chugabud_hostmigration();
    level._effect["chugabud_revive_fx"] = loadfx( "weapon/quantum_bomb/fx_player_position_effect" );
    level._effect["chugabud_bleedout_fx"] = loadfx( "weapon/quantum_bomb/fx_player_position_effect" );
    add_custom_limited_weapon_check( ::is_weapon_available_in_chugabud_corpse );
}

chugabug_precache()
{

}

chugabud_player_init()
{

}

chugabud_laststand()
{
    self endon( "player_suicide" );
    self endon( "disconnect" );
    self endon( "chugabud_bleedout" );
    self maps\mp\zombies\_zm_laststand::increment_downed_stat();
    self.ignore_insta_kill = 1;
    self.health = self.maxhealth;
    self maps\mp\zombies\_zm_chugabud::chugabud_save_loadout();
    self maps\mp\zombies\_zm_chugabud::chugabud_fake_death();
    wait 3;

    if ( isdefined( self.insta_killed ) && self.insta_killed || isdefined( self.disable_chugabud_corpse ) )
        create_corpse = 0;
    else
        create_corpse = 1;

    if ( create_corpse == 1 )
    {
        if ( isdefined( level._chugabug_reject_corpse_override_func ) )
        {
            reject_corpse = self [[ level._chugabug_reject_corpse_override_func ]]( self.origin );

            if ( reject_corpse )
                create_corpse = 0;
        }
    }

    if ( create_corpse == 1 )
    {
        self thread activate_chugabud_effects_and_audio();
        corpse = self chugabud_spawn_corpse();
        corpse thread chugabud_corpse_revive_icon( self );
        self.e_chugabud_corpse = corpse;
        corpse thread chugabud_corpse_cleanup_on_spectator( self );

        if ( isdefined( level.whos_who_client_setup ) )
            corpse setclientfield( "clientfield_whos_who_clone_glow_shader", 1 );
    }

    self chugabud_fake_revive();
    wait 0.1;
    self.ignore_insta_kill = undefined;
    self.disable_chugabud_corpse = undefined;

    if ( create_corpse == 0 )
    {
        self notify( "chugabud_effects_cleanup" );
        return;
    }

    bleedout_time = getdvarfloat( "player_lastStandBleedoutTime" );
    self thread chugabud_bleed_timeout( bleedout_time, corpse );
    self thread chugabud_handle_multiple_instances( corpse );

    corpse waittill( "player_revived", e_reviver );

    if ( isdefined( e_reviver ) && e_reviver == self )
        self notify( "whos_who_self_revive" );

    self perk_abort_drinking( 0.1 );
    self maps\mp\zombies\_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
    self setorigin( corpse.origin );
    self setplayerangles( corpse.angles );

    if ( self player_is_in_laststand() )
    {
        self thread chugabud_laststand_cleanup( corpse, "player_revived" );
        self enableweaponcycling();
        self enableoffhandweapons();
        self auto_revive( self, 1 );
        return;
    }

    self chugabud_laststand_cleanup( corpse, undefined );
}

chugabud_laststand_cleanup( corpse, str_notify )
{
    if ( isdefined( str_notify ) )
        self waittill( str_notify );

    self chugabud_give_loadout();
    self chugabud_corpse_cleanup( corpse, 1 );
}

chugabud_bleed_timeout( delay, corpse )
{
    self endon( "player_suicide" );
    self endon( "disconnect" );
    corpse endon( "death" );
    wait( delay );

    if ( isdefined( corpse.revivetrigger ) )
    {
        while ( corpse.revivetrigger.beingrevived )
            wait 0.01;
    }

    if ( isdefined( self.loadout.perks ) && flag( "solo_game" ) )
    {
        for ( i = 0; i < self.loadout.perks.size; i++ )
        {
            perk = self.loadout.perks[i];

            if ( perk == "specialty_quickrevive" )
            {
                arrayremovevalue( self.loadout.perks, self.loadout.perks[i] );
                corpse notify( "player_revived", self );
                return;
            }
        }
    }

    self chugabud_corpse_cleanup( corpse, 0 );
}

chugabud_corpse_cleanup( corpse, was_revived )
{
    self notify( "chugabud_effects_cleanup" );

    if ( was_revived )
    {
        playsoundatposition( "evt_ww_appear", corpse.origin );
        playfx( level._effect["chugabud_revive_fx"], corpse.origin );
    }
    else
    {
        playsoundatposition( "evt_ww_disappear", corpse.origin );
        playfx( level._effect["chugabud_bleedout_fx"], corpse.origin );
        self notify( "chugabud_bleedout" );
    }

    if ( isdefined( corpse.revivetrigger ) )
    {
        corpse notify( "stop_revive_trigger" );
        corpse.revivetrigger delete();
        corpse.revivetrigger = undefined;
    }

    if ( isdefined( corpse.revive_hud_elem ) )
    {
        corpse.revive_hud_elem destroy();
        corpse.revive_hud_elem = undefined;
    }

    self.loadout = undefined;
    wait 0.1;
    corpse delete();
    self.e_chugabud_corpse = undefined;
}

chugabud_handle_multiple_instances( corpse )
{
    corpse endon( "death" );

    self waittill( "perk_chugabud_activated" );

    self chugabud_corpse_cleanup( corpse, 0 );
}

chugabud_spawn_corpse()
{
    corpse = maps\mp\zombies\_zm_clone::spawn_player_clone( self, self.origin, undefined, self.whos_who_shader );
    corpse.angles = self.angles;
    corpse maps\mp\zombies\_zm_clone::clone_give_weapon( "m1911_zm" );
    corpse maps\mp\zombies\_zm_clone::clone_animate( "laststand" );
    corpse.revive_hud = self chugabud_revive_hud_create();
    corpse thread maps\mp\zombies\_zm_laststand::revive_trigger_spawn();
    return corpse;
}

chugabud_revive_hud_create()
{
    self.revive_hud = newclienthudelem( self );
    self.revive_hud.alignx = "center";
    self.revive_hud.aligny = "middle";
    self.revive_hud.horzalign = "center";
    self.revive_hud.vertalign = "bottom";
    self.revive_hud.y = -50;
    self.revive_hud.foreground = 1;
    self.revive_hud.font = "default";
    self.revive_hud.fontscale = 1.5;
    self.revive_hud.alpha = 0;
    self.revive_hud.color = ( 1, 1, 1 );
    self.revive_hud settext( "" );
    return self.revive_hud;
}

chugabud_save_loadout()
{
    primaries = self getweaponslistprimaries();
    currentweapon = self getcurrentweapon();
    self.loadout = spawnstruct();
    self.loadout.player = self;
    self.loadout.weapons = [];
    self.loadout.score = self.score;
    self.loadout.current_weapon = -1;

    foreach ( index, weapon in primaries )
    {
        self.loadout.weapons[index] = maps\mp\zombies\_zm_weapons::get_player_weapondata( self, weapon );

        if ( weapon == currentweapon || self.loadout.weapons[index]["alt_name"] == currentweapon )
            self.loadout.current_weapon = index;
    }

    self.loadout.equipment = self get_player_equipment();

    if ( isdefined( self.loadout.equipment ) )
        self equipment_take( self.loadout.equipment );

    self.loadout save_weapons_for_chugabud( self );

    if ( self hasweapon( "claymore_zm" ) )
    {
        self.loadout.hasclaymore = 1;
        self.loadout.claymoreclip = self getweaponammoclip( "claymore_zm" );
    }

    self.loadout.perks = chugabud_save_perks( self );
    self chugabud_save_grenades();

    if ( maps\mp\zombies\_zm_weap_cymbal_monkey::cymbal_monkey_exists() )
        self.loadout.zombie_cymbal_monkey_count = self getweaponammoclip( "cymbal_monkey_zm" );
}

chugabud_save_grenades()
{
    if ( self hasweapon( "emp_grenade_zm" ) )
    {
        self.loadout.hasemp = 1;
        self.loadout.empclip = self getweaponammoclip( "emp_grenade_zm" );
    }

    lethal_grenade = self get_player_lethal_grenade();

    if ( self hasweapon( lethal_grenade ) )
    {
        self.loadout.lethal_grenade = lethal_grenade;
        self.loadout.lethal_grenade_count = self getweaponammoclip( lethal_grenade );
    }
    else
        self.loadout.lethal_grenade = undefined;
}

chugabud_give_loadout()
{
    self takeallweapons();
    loadout = self.loadout;
    primaries = self getweaponslistprimaries();

    if ( loadout.weapons.size > 1 || primaries.size > 1 )
    {
        foreach ( weapon in primaries )
            self takeweapon( weapon );
    }

    for ( i = 0; i < loadout.weapons.size; i++ )
    {
        if ( !isdefined( loadout.weapons[i] ) )
            continue;

        if ( loadout.weapons[i]["name"] == "none" )
            continue;

        self maps\mp\zombies\_zm_weapons::weapondata_give( loadout.weapons[i] );
    }

    if ( loadout.current_weapon >= 0 && isdefined( loadout.weapons[loadout.current_weapon]["name"] ) )
        self switchtoweapon( loadout.weapons[loadout.current_weapon]["name"] );

    self giveweapon( "knife_zm" );
    self maps\mp\zombies\_zm_equipment::equipment_give( self.loadout.equipment );
    loadout restore_weapons_for_chugabud( self );
    self chugabud_restore_claymore();
    self.score = loadout.score;
    self.pers["score"] = loadout.score;
    perk_array = maps\mp\zombies\_zm_perks::get_perk_array( 1 );

    for ( i = 0; i < perk_array.size; i++ )
    {
        perk = perk_array[i];
        self unsetperk( perk );
        self.num_perks--;
        self set_perk_clientfield( perk, 0 );
    }

    if ( isdefined( loadout.perks ) && loadout.perks.size > 0 )
    {
        for ( i = 0; i < loadout.perks.size; i++ )
        {
            if ( self hasperk( loadout.perks[i] ) )
                continue;

            if ( loadout.perks[i] == "specialty_quickrevive" && flag( "solo_game" ) )
                level.solo_game_free_player_quickrevive = 1;

            if ( loadout.perks[i] == "specialty_finalstand" )
                continue;

            maps\mp\zombies\_zm_perks::give_perk( loadout.perks[i] );
        }
    }

    self chugabud_restore_grenades();

    if ( maps\mp\zombies\_zm_weap_cymbal_monkey::cymbal_monkey_exists() )
    {
        if ( loadout.zombie_cymbal_monkey_count )
        {
            self maps\mp\zombies\_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
            self setweaponammoclip( "cymbal_monkey_zm", loadout.zombie_cymbal_monkey_count );
        }
    }
}

chugabud_restore_grenades()
{
    if ( isdefined( self.loadout.hasemp ) && self.loadout.hasemp )
    {
        self giveweapon( "emp_grenade_zm" );
        self setweaponammoclip( "emp_grenade_zm", self.loadout.empclip );
    }

    if ( isdefined( self.loadout.lethal_grenade ) )
    {
        self giveweapon( self.loadout.lethal_grenade );
        self setweaponammoclip( self.loadout.lethal_grenade, self.loadout.lethal_grenade_count );
    }
}

chugabud_restore_claymore()
{
    if ( isdefined( self.loadout.hasclaymore ) && self.loadout.hasclaymore && !self hasweapon( "claymore_zm" ) )
    {
        self giveweapon( "claymore_zm" );
        self set_player_placeable_mine( "claymore_zm" );
        self setactionslot( 4, "weapon", "claymore_zm" );
        self setweaponammoclip( "claymore_zm", self.loadout.claymoreclip );
    }
}

chugabud_fake_death()
{
    level notify( "fake_death" );
    self notify( "fake_death" );
    self takeallweapons();
    self allowstand( 0 );
    self allowcrouch( 0 );
    self allowprone( 1 );
    self.ignoreme = 1;
    self enableinvulnerability();
    wait 0.1;
    self freezecontrols( 1 );
    wait 0.9;
}

chugabud_fake_revive()
{
    level notify( "fake_revive" );
    self notify( "fake_revive" );
    playsoundatposition( "evt_ww_disappear", self.origin );
    playfx( level._effect["chugabud_revive_fx"], self.origin );
    spawnpoint = chugabud_get_spawnpoint();

    if ( isdefined( level._chugabud_post_respawn_override_func ) )
        self [[ level._chugabud_post_respawn_override_func ]]( spawnpoint.origin );

    if ( isdefined( level.chugabud_force_corpse_position ) )
    {
        if ( isdefined( self.e_chugabud_corpse ) )
            self.e_chugabud_corpse forceteleport( level.chugabud_force_corpse_position );

        level.chugabud_force_corpse_position = undefined;
    }

    if ( isdefined( level.chugabud_force_player_position ) )
    {
        spawnpoint.origin = level.chugabud_force_player_position;
        level.chugabud_force_player_position = undefined;
    }

    self setorigin( spawnpoint.origin );
    self setplayerangles( spawnpoint.angles );
    playsoundatposition( "evt_ww_appear", spawnpoint.origin );
    playfx( level._effect["chugabud_revive_fx"], spawnpoint.origin );
    self allowstand( 1 );
    self allowcrouch( 1 );
    self allowprone( 1 );
    self.ignoreme = 0;
    self setstance( "stand" );
    self freezecontrols( 0 );
    self giveweapon( "knife_zm" );
    self give_start_weapon( 1 );
    self.score = self.loadout.score;
    self.pers["score"] = self.loadout.score;
    self giveweapon( "frag_grenade_zm" );
    self setweaponammoclip( "frag_grenade_zm", 2 );
    self chugabud_restore_claymore();
    wait 1;
    self disableinvulnerability();
}

chugabud_get_spawnpoint()
{
    spawnpoint = undefined;

    if ( get_chugabug_spawn_point_from_nodes( self.origin, 500, 700, 64, 1 ) )
        spawnpoint = level.chugabud_spawn_struct;

    if ( !isdefined( spawnpoint ) )
    {
        if ( get_chugabug_spawn_point_from_nodes( self.origin, 100, 400, 64, 1 ) )
            spawnpoint = level.chugabud_spawn_struct;
    }

    if ( !isdefined( spawnpoint ) )
    {
        if ( get_chugabug_spawn_point_from_nodes( self.origin, 50, 400, 256, 0 ) )
            spawnpoint = level.chugabud_spawn_struct;
    }

    if ( !isdefined( spawnpoint ) )
        spawnpoint = maps\mp\zombies\_zm::check_for_valid_spawn_near_team( self, 1 );

    if ( !isdefined( spawnpoint ) )
    {
        match_string = "";
        location = level.scr_zm_map_start_location;

        if ( ( location == "default" || location == "" ) && isdefined( level.default_start_location ) )
            location = level.default_start_location;

        match_string = level.scr_zm_ui_gametype + "_" + location;
        spawnpoints = [];
        structs = getstructarray( "initial_spawn", "script_noteworthy" );

        if ( isdefined( structs ) )
        {
            foreach ( struct in structs )
            {
                if ( isdefined( struct.script_string ) )
                {
                    tokens = strtok( struct.script_string, " " );

                    foreach ( token in tokens )
                    {
                        if ( token == match_string )
                            spawnpoints[spawnpoints.size] = struct;
                    }
                }
            }
        }

        if ( !isdefined( spawnpoints ) || spawnpoints.size == 0 )
            spawnpoints = getstructarray( "initial_spawn_points", "targetname" );

        assert( isdefined( spawnpoints ), "Could not find initial spawn points!" );
        spawnpoint = maps\mp\zombies\_zm::getfreespawnpoint( spawnpoints, self );
    }

    return spawnpoint;
}

get_chugabug_spawn_point_from_nodes( v_origin, min_radius, max_radius, max_height, ignore_targetted_nodes )
{
    if ( !isdefined( level.chugabud_spawn_struct ) )
        level.chugabud_spawn_struct = spawnstruct();

    found_node = undefined;
    a_nodes = getnodesinradiussorted( v_origin, max_radius, min_radius, max_height, "pathnodes" );

    if ( isdefined( a_nodes ) && a_nodes.size > 0 )
    {
        a_player_volumes = getentarray( "player_volume", "script_noteworthy" );
        index = a_nodes.size - 1;

        for ( i = index; i >= 0; i-- )
        {
            n_node = a_nodes[i];

            if ( ignore_targetted_nodes == 1 )
            {
                if ( isdefined( n_node.target ) )
                    continue;
            }

            if ( !positionwouldtelefrag( n_node.origin ) )
            {
                if ( maps\mp\zombies\_zm_utility::check_point_in_enabled_zone( n_node.origin, 1, a_player_volumes ) )
                {
                    v_start = ( n_node.origin[0], n_node.origin[1], n_node.origin[2] + 30 );
                    v_end = ( n_node.origin[0], n_node.origin[1], n_node.origin[2] - 30 );
                    trace = bullettrace( v_start, v_end, 0, undefined );

                    if ( trace["fraction"] < 1 )
                    {
                        override_abort = 0;

                        if ( isdefined( level._chugabud_reject_node_override_func ) )
                            override_abort = [[ level._chugabud_reject_node_override_func ]]( v_origin, n_node );

                        if ( !override_abort )
                        {
                            found_node = n_node;
                            break;
                        }
                    }
                }
            }
        }
    }

    if ( isdefined( found_node ) )
    {
        level.chugabud_spawn_struct.origin = found_node.origin;
        v_dir = vectornormalize( v_origin - level.chugabud_spawn_struct.origin );
        level.chugabud_spawn_struct.angles = vectortoangles( v_dir );
        return true;
    }

    return false;
}

force_corpse_respawn_position( forced_corpse_position )
{
    level.chugabud_force_corpse_position = forced_corpse_position;
}

force_player_respawn_position( forced_player_position )
{
    level.chugabud_force_player_position = forced_player_position;
}

save_weapons_for_chugabud( player )
{
    self.chugabud_melee_weapons = [];

    for ( i = 0; i < level._melee_weapons.size; i++ )
        self save_weapon_for_chugabud( player, level._melee_weapons[i].weapon_name );
}

save_weapon_for_chugabud( player, weapon_name )
{
    if ( player hasweapon( weapon_name ) )
        self.chugabud_melee_weapons[weapon_name] = 1;
}

restore_weapons_for_chugabud( player )
{
    for ( i = 0; i < level._melee_weapons.size; i++ )
        self restore_weapon_for_chugabud( player, level._melee_weapons[i].weapon_name );

    self.chugabud_melee_weapons = undefined;
}

restore_weapon_for_chugabud( player, weapon_name )
{
    if ( !isdefined( weapon_name ) || !isdefined( self.chugabud_melee_weapons ) || !isdefined( self.chugabud_melee_weapons[weapon_name] ) )
        return;

    if ( isdefined( self.chugabud_melee_weapons[weapon_name] ) && self.chugabud_melee_weapons[weapon_name] )
    {
        player giveweapon( weapon_name );
        player set_player_melee_weapon( weapon_name );
        self.chugabud_melee_weapons[weapon_name] = 0;
    }
}

chugabud_save_perks( ent )
{
    perk_array = ent get_perk_array( 1 );

    foreach ( perk in perk_array )
        ent unsetperk( perk );

    return perk_array;
}

playchugabudtimeraudio()
{
    self endon( "chugabud_grabbed" );
    self endon( "chugabud_timedout" );
    player = self.player;
    self thread playchugabudtimerout( player );

    while ( true )
    {
        player playsoundtoplayer( "zmb_chugabud_timer_count", player );
        wait 1;
    }
}

playchugabudtimerout( player )
{
    self endon( "chugabud_grabbed" );

    self waittill( "chugabud_timedout" );

    player playsoundtoplayer( "zmb_chugabud_timer_out", player );
}

chugabud_hostmigration()
{
    level endon( "end_game" );
    level notify( "chugabud_hostmigration" );
    level endon( "chugabud_hostmigration" );

    while ( true )
    {
        level waittill( "host_migration_end" );

        chugabuds = getentarray( "player_chugabud_model", "script_noteworthy" );

        foreach ( model in chugabuds )
            playfxontag( level._effect["powerup_on"], model, "tag_origin" );
    }
}

player_revived_cleanup_chugabud_corpse()
{

}

player_has_chugabud_corpse()
{
    if ( isdefined( self.e_chugabud_corpse ) )
        return true;

    return false;
}

is_weapon_available_in_chugabud_corpse( weapon, player_to_check )
{
    count = 0;
    upgradedweapon = weapon;

    if ( isdefined( level.zombie_weapons[weapon] ) && isdefined( level.zombie_weapons[weapon].upgrade_name ) )
        upgradedweapon = level.zombie_weapons[weapon].upgrade_name;

    players = getplayers();

    if ( isdefined( players ) )
    {
        for ( player_index = 0; player_index < players.size; player_index++ )
        {
            player = players[player_index];

            if ( isdefined( player_to_check ) && player != player_to_check )
                continue;

            if ( player player_has_chugabud_corpse() )
            {
                if ( isdefined( player.loadout ) && isdefined( player.loadout.weapons ) )
                {
                    for ( i = 0; i < player.loadout.weapons.size; i++ )
                    {
                        chugabud_weapon = player.loadout.weapons[i];

                        if ( isdefined( chugabud_weapon ) && ( chugabud_weapon["name"] == weapon || chugabud_weapon["name"] == upgradedweapon ) )
                            count++;
                    }
                }
            }
        }
    }

    return count;
}

chugabud_corpse_cleanup_on_spectator( player )
{
    self endon( "death" );
    player endon( "disconnect" );

    while ( true )
    {
        if ( player.sessionstate == "spectator" )
            break;

        wait 0.01;
    }

    player chugabud_corpse_cleanup( self, 0 );
}

chugabud_corpse_revive_icon( player )
{
    self endon( "death" );
    height_offset = 30;
    index = player.clientid;
    hud_elem = newhudelem();
    self.revive_hud_elem = hud_elem;
    hud_elem.x = self.origin[0];
    hud_elem.y = self.origin[1];
    hud_elem.z = self.origin[2] + height_offset;
    hud_elem.alpha = 1;
    hud_elem.archived = 1;
    hud_elem setshader( "waypoint_revive", 5, 5 );
    hud_elem setwaypoint( 1 );
    hud_elem.hidewheninmenu = 1;
    hud_elem.immunetodemogamehudsettings = 1;

    while ( true )
    {
        if ( !isdefined( self.revive_hud_elem ) )
            break;

        hud_elem.x = self.origin[0];
        hud_elem.y = self.origin[1];
        hud_elem.z = self.origin[2] + height_offset;
        wait 0.01;
    }
}

activate_chugabud_effects_and_audio()
{
    if ( isdefined( level.whos_who_client_setup ) )
    {
        if ( !isdefined( self.whos_who_effects_active ) )
        {
            if ( isdefined( level.chugabud_shellshock ) )
                self shellshock( "whoswho", 60 );

            if ( isdefined( level.vsmgr_prio_visionset_zm_whos_who ) )
                maps\mp\_visionset_mgr::vsmgr_activate( "visionset", "zm_whos_who", self );

            self setclientfieldtoplayer( "clientfield_whos_who_audio", 1 );
            self setclientfieldtoplayer( "clientfield_whos_who_filter", 1 );
            self.whos_who_effects_active = 1;
            self thread deactivate_chugabud_effects_and_audio();
        }
    }
}

deactivate_chugabud_effects_and_audio()
{
    self waittill_any( "death", "chugabud_effects_cleanup" );

    if ( isdefined( level.whos_who_client_setup ) )
    {
        if ( isdefined( self.whos_who_effects_active ) && self.whos_who_effects_active == 1 )
        {
            if ( isdefined( level.chugabud_shellshock ) )
                self stopshellshock();

            if ( isdefined( level.vsmgr_prio_visionset_zm_whos_who ) )
                maps\mp\_visionset_mgr::vsmgr_deactivate( "visionset", "zm_whos_who", self );

            self setclientfieldtoplayer( "clientfield_whos_who_audio", 0 );
            self setclientfieldtoplayer( "clientfield_whos_who_filter", 0 );
        }

        self.whos_who_effects_active = undefined;
    }
}
