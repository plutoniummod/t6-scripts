// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zm_alcatraz_utility;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_perk_electric_cherry;
#include maps\mp\zombies\_zm_clone;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zm_alcatraz_travel;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\animscripts\shared;
#include maps\mp\zombies\_zm_ai_basic;

init()
{
    level.zombiemode_using_afterlife = 1;
    flag_init( "afterlife_start_over" );
    level.afterlife_revive_tool = "syrette_afterlife_zm";
    precacheitem( level.afterlife_revive_tool );
    precachemodel( "drone_collision" );
    maps\mp\_visionset_mgr::vsmgr_register_info( "visionset", "zm_afterlife", 9000, 120, 1, 1 );
    maps\mp\_visionset_mgr::vsmgr_register_info( "overlay", "zm_afterlife_filter", 9000, 120, 1, 1 );

    if ( isdefined( level.afterlife_player_damage_override ) )
        maps\mp\zombies\_zm::register_player_damage_callback( level.afterlife_player_damage_override );
    else
        maps\mp\zombies\_zm::register_player_damage_callback( ::afterlife_player_damage_callback );

    registerclientfield( "toplayer", "player_lives", 9000, 2, "int" );
    registerclientfield( "toplayer", "player_in_afterlife", 9000, 1, "int" );
    registerclientfield( "toplayer", "player_afterlife_mana", 9000, 5, "float" );
    registerclientfield( "allplayers", "player_afterlife_fx", 9000, 1, "int" );
    registerclientfield( "toplayer", "clientfield_afterlife_audio", 9000, 1, "int" );
    registerclientfield( "toplayer", "player_afterlife_refill", 9000, 1, "int" );
    registerclientfield( "scriptmover", "player_corpse_id", 9000, 3, "int" );
    afterlife_load_fx();
    level thread afterlife_hostmigration();
    precachemodel( "c_zom_ghost_viewhands" );
    precachemodel( "c_zom_hero_ghost_fb" );
    precacheitem( "lightning_hands_zm" );
    precachemodel( "p6_zm_al_shock_box_on" );
    precacheshader( "waypoint_revive_afterlife" );
    a_afterlife_interact = getentarray( "afterlife_interact", "targetname" );
    array_thread( a_afterlife_interact, ::afterlife_interact_object_think );
    level.zombie_spawners = getentarray( "zombie_spawner", "script_noteworthy" );
    array_thread( level.zombie_spawners, ::add_spawn_function, ::afterlife_zombie_damage );
    a_afterlife_triggers = getstructarray( "afterlife_trigger", "targetname" );

    foreach ( struct in a_afterlife_triggers )
        afterlife_trigger_create( struct );

    level.afterlife_interact_dist = 256;
    level.is_player_valid_override = ::is_player_valid_afterlife;
    level.can_revive = ::can_revive_override;
    level.round_prestart_func = ::afterlife_start_zombie_logic;
    level.custom_pap_validation = ::is_player_valid_afterlife;
    level.player_out_of_playable_area_monitor_callback = ::player_out_of_playable_area;
    level thread afterlife_gameover_cleanup();
    level.afterlife_get_spawnpoint = ::afterlife_get_spawnpoint;
    level.afterlife_zapped = ::afterlife_zapped;
    level.afterlife_give_loadout = ::afterlife_give_loadout;
    level.afterlife_save_loadout = ::afterlife_save_loadout;
}

afterlife_gameover_cleanup()
{
    level waittill( "end_game" );

    foreach ( player in getplayers() )
    {
        player.afterlife = 0;
        player clientnotify( "end_game" );
        player notify( "end_game" );

        if ( isdefined( player.client_hint ) )
            player.client_hint destroy();
    }

    wait 5;

    foreach ( player in getplayers() )
    {
        if ( isdefined( level.optimise_for_splitscreen ) && !level.optimise_for_splitscreen )
            maps\mp\_visionset_mgr::vsmgr_deactivate( "overlay", "zm_afterlife_filter", player );
    }
}

afterlife_load_fx()
{
    level._effect["afterlife_teleport"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_zmb_tport" );
    level._effect["teleport_ball"] = loadfx( "weapon/tomahawk/fx_tomahawk_trail_ug" );
    level._effect["afterlife_kill_point_fx"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_suicide_area" );
    level._effect["afterlife_enter"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_start" );
    level._effect["afterlife_leave"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_player_revive" );
    level._effect["afterlife_pixie_dust"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_pixies" );
    level._effect["afterlife_corpse"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_player_down" );
    level._effect["afterlife_damage"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_damage" );
    level._effect["afterlife_ghost_fx"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_body" );
    level._effect["afterlife_ghost_h_fx"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_head" );
    level._effect["afterlife_ghost_arm_fx"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_arm" );
    level._effect["afterlife_ghost_hand_fx"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_hand" );
    level._effect["afterlife_ghost_hand_r_fx"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_hand_r" );
    level._effect["afterlife_transition"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_afterlife_transition" );
    level._effect["fx_alcatraz_ghost_vm_wrist"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist" );
    level._effect["fx_alcatraz_ghost_vm_wrist_r"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_vm_wrist_r" );
    level._effect["fx_alcatraz_ghost_spectate"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_ghost_spec" );
}

afterlife_start_zombie_logic()
{
    flag_wait( "start_zombie_round_logic" );
    wait 0.5;
    b_everyone_alive = 0;

    while ( isdefined( b_everyone_alive ) && !b_everyone_alive )
    {
        b_everyone_alive = 1;
        a_players = getplayers();

        foreach ( player in a_players )
        {
            if ( isdefined( player.afterlife ) && player.afterlife )
            {
                b_everyone_alive = 0;
                wait 0.05;
                break;
            }
        }
    }

    wait 0.5;

    while ( level.intermission )
        wait 0.05;

    flag_set( "afterlife_start_over" );
    wait 2;
    array_func( getplayers(), ::afterlife_add );
}

is_player_valid_afterlife( player )
{
    if ( isdefined( player.afterlife ) && player.afterlife )
        return false;

    return true;
}

can_revive_override( revivee )
{
    if ( isdefined( self.afterlife ) && self.afterlife )
        return false;

    return true;
}

player_out_of_playable_area()
{
    if ( isdefined( self.afterlife ) && self.afterlife )
        return false;

    if ( isdefined( self.on_a_plane ) && self.on_a_plane )
        return false;

    if ( isdefined( level.gondola_kill_brush_override ) && level.gondola_kill_brush_override )
    {
        if ( self istouching( level.gondola_docks_landing_killbrush ) )
            return false;
    }

    return true;
}

init_player()
{
    flag_wait( "initial_players_connected" );

    if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
        self.lives = 3;
    else
        self.lives = 1;

    self setclientfieldtoplayer( "player_lives", self.lives );
    self.afterlife = 0;
    self.afterliferound = level.round_number;
    self.afterlifedeaths = 0;
    self thread afterlife_doors_close();
    self thread afterlife_player_refill_watch();
}

afterlife_remove( b_afterlife_death = 0 )
{
    if ( isdefined( b_afterlife_death ) && b_afterlife_death )
        self.lives = 0;
    else if ( self.lives > 0 )
        self.lives--;

    self notify( "sndLifeGone" );
    self setclientfieldtoplayer( "player_lives", self.lives );
}

afterlife_add()
{
    if ( isdefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
    {
        if ( self.lives < 3 )
        {
            self.lives++;
            self thread afterlife_add_fx();
        }
    }
    else if ( self.lives < 1 )
    {
        self.lives++;
        self thread afterlife_add_fx();
    }

    self playsoundtoplayer( "zmb_afterlife_add", self );
    self setclientfieldtoplayer( "player_lives", self.lives );
}

afterlife_add_fx()
{
    if ( isdefined( self.afterlife ) && !self.afterlife )
    {
        self setclientfieldtoplayer( "player_afterlife_refill", 1 );
        wait 3;

        if ( isdefined( self.afterlife ) && !self.afterlife )
            self setclientfieldtoplayer( "player_afterlife_refill", 0 );
    }
}

afterlife_player_refill_watch()
{
    self endon( "disconnect" );
    self endon( "_zombie_game_over" );
    level endon( "stage_final" );

    while ( true )
    {
        level waittill( "end_of_round" );

        wait 2;
        self afterlife_add();
        reset_all_afterlife_unitriggers();
    }
}

afterlife_player_damage_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
    if ( isdefined( eattacker ) )
    {
        if ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie )
        {
            if ( isdefined( eattacker.custom_damage_func ) )
                idamage = eattacker [[ eattacker.custom_damage_func ]]( self );
            else if ( isdefined( eattacker.meleedamage ) && smeansofdeath != "MOD_GRENADE_SPLASH" )
                idamage = eattacker.meleedamage;

            if ( isdefined( self.afterlife ) && self.afterlife )
            {
                self afterlife_reduce_mana( 10 );
                self clientnotify( "al_d" );
                return 0;
            }
        }
    }

    if ( isdefined( self.afterlife ) && self.afterlife )
        return 0;

    if ( isdefined( eattacker ) && ( isdefined( eattacker.is_zombie ) && eattacker.is_zombie || isplayer( eattacker ) ) )
    {
        if ( isdefined( self.hasriotshield ) && self.hasriotshield && isdefined( vdir ) )
        {
            item_dmg = 100;

            if ( isdefined( eattacker.custom_item_dmg ) )
                item_dmg = eattacker.custom_item_dmg;

            if ( isdefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped )
            {
                if ( self player_shield_facing_attacker( vdir, 0.2 ) && isdefined( self.player_shield_apply_damage ) )
                {
                    self [[ self.player_shield_apply_damage ]]( item_dmg, 0 );
                    return 0;
                }
            }
            else if ( !isdefined( self.riotshieldentity ) )
            {
                if ( !self player_shield_facing_attacker( vdir, -0.2 ) && isdefined( self.player_shield_apply_damage ) )
                {
                    self [[ self.player_shield_apply_damage ]]( item_dmg, 0 );
                    return 0;
                }
            }
        }
    }

    if ( sweapon == "tower_trap_zm" || sweapon == "tower_trap_upgraded_zm" || sweapon == "none" && shitloc == "riotshield" && !( isdefined( eattacker.is_zombie ) && eattacker.is_zombie ) )
    {
        self.use_adjusted_grenade_damage = 1;
        return 0;
    }

    if ( smeansofdeath == "MOD_PROJECTILE" || smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" )
    {
        if ( sweapon == "blundersplat_explosive_dart_zm" )
        {
            if ( self hasperk( "specialty_flakjacket" ) )
            {
                self.use_adjusted_grenade_damage = 1;
                idamage = 0;
            }

            if ( isalive( self ) && !( isdefined( self.is_zombie ) && self.is_zombie ) )
            {
                self.use_adjusted_grenade_damage = 1;
                idamage = 10;
            }
        }
        else
        {
            if ( self hasperk( "specialty_flakjacket" ) )
                return 0;

            if ( self.health > 75 && !( isdefined( self.is_zombie ) && self.is_zombie ) )
                idamage = 75;
        }
    }

    if ( idamage >= self.health && ( isdefined( level.intermission ) && !level.intermission ) )
    {
        if ( self.lives > 0 && ( isdefined( self.afterlife ) && !self.afterlife ) )
        {
            self playsoundtoplayer( "zmb_afterlife_death", self );
            self afterlife_remove();
            self.afterlife = 1;
            self thread afterlife_laststand();

            if ( self.health <= 1 )
                return 0;
            else
                idamage = self.health - 1;
        }
        else
            self thread last_stand_conscience_vo();
    }

    return idamage;
}

afterlife_enter()
{
    if ( !isdefined( self.afterlife_visionset ) || self.afterlife_visionset == 0 )
    {
        maps\mp\_visionset_mgr::vsmgr_activate( "visionset", "zm_afterlife", self );

        if ( isdefined( level.optimise_for_splitscreen ) && !level.optimise_for_splitscreen )
            maps\mp\_visionset_mgr::vsmgr_activate( "overlay", "zm_afterlife_filter", self );

        self.afterlife_visionset = 1;
    }

    self enableafterlife();
    self.str_living_model = self.model;
    self.str_living_view = self getviewmodel();
    self setmodel( "c_zom_hero_ghost_fb" );
    self setviewmodel( "c_zom_ghost_viewhands" );
    self thread afterlife_doors_open();
    self setclientfieldtoplayer( "player_in_afterlife", 1 );
    self setclientfield( "player_afterlife_fx", 1 );
    self afterlife_create_mana_bar( self.e_afterlife_corpse );

    if ( !isdefined( self.keep_perks ) && flag( "afterlife_start_over" ) )
        self increment_downed_stat();

    a_afterlife_triggers = getstructarray( "afterlife_trigger", "targetname" );

    foreach ( struct in a_afterlife_triggers )
        struct.unitrigger_stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();

    a_exterior_goals = getstructarray( "exterior_goal", "targetname" );

    foreach ( struct in a_exterior_goals )
    {
        if ( isdefined( struct.unitrigger_stub ) )
            struct.unitrigger_stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
    }
}

afterlife_leave( b_revived = 1 )
{
    while ( self ismantling() )
        wait 0.05;

    self clientnotify( "al_t" );

    if ( isdefined( self.afterlife_visionset ) && self.afterlife_visionset )
    {
        maps\mp\_visionset_mgr::vsmgr_deactivate( "visionset", "zm_afterlife", self );

        if ( isdefined( level.optimise_for_splitscreen ) && !level.optimise_for_splitscreen )
            maps\mp\_visionset_mgr::vsmgr_deactivate( "overlay", "zm_afterlife_filter", self );

        self.afterlife_visionset = 0;
    }

    self disableafterlife();
    self.dontspeak = 0;
    self thread afterlife_doors_close();
    self.health = self.maxhealth;
    self setclientfieldtoplayer( "player_in_afterlife", 0 );
    self setclientfield( "player_afterlife_fx", 0 );
    self setclientfieldtoplayer( "clientfield_afterlife_audio", 0 );
    self maps\mp\zombies\_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
    self allowstand( 1 );
    self allowcrouch( 1 );
    self allowprone( 1 );
    self setmodel( self.str_living_model );
    self setviewmodel( self.str_living_view );

    if ( self.e_afterlife_corpse.revivetrigger.origin != self.e_afterlife_corpse.origin )
        self setorigin( self.e_afterlife_corpse.revivetrigger.origin );
    else
        self setorigin( self.e_afterlife_corpse.origin );

    if ( isdefined( level.e_gondola ) )
    {
        a_gondola_doors_gates = get_gondola_doors_and_gates();

        for ( i = 0; i < a_gondola_doors_gates.size; i++ )
        {
            if ( self.e_afterlife_corpse istouching( a_gondola_doors_gates[i] ) )
            {
                if ( isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving )
                    str_location = level.e_gondola.destination;
                else
                    str_location = level.e_gondola.location;

                a_s_orgs = getstructarray( "gondola_dropped_parts_" + str_location, "targetname" );

                foreach ( struct in a_s_orgs )
                {
                    if ( !positionwouldtelefrag( struct.origin ) )
                    {
                        self setorigin( struct.origin );
                        break;
                    }
                }

                break;
            }
        }

        if ( self.e_afterlife_corpse islinkedto( level.e_gondola ) && ( isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving ) )
            self.is_on_gondola = 1;
    }

    self setplayerangles( self.e_afterlife_corpse.angles );
    self.afterlife = 0;
    self afterlife_laststand_cleanup( self.e_afterlife_corpse );

    if ( isdefined( b_revived ) && !b_revived )
    {
        self afterlife_remove( 1 );
        self dodamage( 1000, self.origin );
    }

    reset_all_afterlife_unitriggers();
}

afterlife_laststand( b_electric_chair = 0 )
{
    self endon( "disconnect" );
    self endon( "afterlife_bleedout" );
    level endon( "end_game" );

    if ( isdefined( level.afterlife_laststand_override ) )
    {
        self thread [[ level.afterlife_laststand_override ]]( b_electric_chair );
        return;
    }

    self.dontspeak = 1;
    self.health = 1000;
    b_has_electric_cherry = 0;

    if ( self hasperk( "specialty_grenadepulldeath" ) )
        b_has_electric_cherry = 1;

    self [[ level.afterlife_save_loadout ]]();
    self afterlife_fake_death();

    if ( isdefined( b_electric_chair ) && !b_electric_chair )
        wait 1;

    if ( isdefined( b_has_electric_cherry ) && b_has_electric_cherry && ( isdefined( b_electric_chair ) && !b_electric_chair ) )
    {
        self maps\mp\zombies\_zm_perk_electric_cherry::electric_cherry_laststand();
        wait 2;
    }

    self setclientfieldtoplayer( "clientfield_afterlife_audio", 1 );

    if ( flag( "afterlife_start_over" ) )
    {
        self clientnotify( "al_t" );
        wait 1;
        self thread fadetoblackforxsec( 0, 1, 0.5, 0.5, "white" );
        wait 0.5;
    }

    self ghost();
    self.e_afterlife_corpse = self afterlife_spawn_corpse();
    self thread afterlife_clean_up_on_disconnect();
    self notify( "player_fake_corpse_created" );
    self afterlife_fake_revive();
    self afterlife_enter();
    self.e_afterlife_corpse setclientfield( "player_corpse_id", self getentitynumber() + 1 );
    wait 0.5;
    self show();

    if ( !( isdefined( self.hostmigrationcontrolsfrozen ) && self.hostmigrationcontrolsfrozen ) )
        self freezecontrols( 0 );

    self disableinvulnerability();

    self.e_afterlife_corpse waittill( "player_revived", e_reviver );

    self notify( "player_revived" );
    self seteverhadweaponall( 1 );
    self enableinvulnerability();
    self.afterlife_revived = 1;
    playsoundatposition( "zmb_afterlife_spawn_leave", self.e_afterlife_corpse.origin );
    self afterlife_leave();
    self thread afterlife_revive_invincible();
    self playsound( "zmb_afterlife_revived_gasp" );
}

afterlife_clean_up_on_disconnect()
{
    e_corpse = self.e_afterlife_corpse;
    e_corpse endon( "death" );

    self waittill( "disconnect" );

    if ( isdefined( e_corpse.revivetrigger ) )
    {
        e_corpse notify( "stop_revive_trigger" );
        e_corpse.revivetrigger delete();
        e_corpse.revivetrigger = undefined;
    }

    e_corpse setclientfield( "player_corpse_id", 0 );
    e_corpse notify( "disconnect" );
    wait_network_frame();
    wait_network_frame();
    e_corpse delete();
}

afterlife_revive_invincible()
{
    self endon( "disconnect" );
    wait 2;
    self disableinvulnerability();
    self seteverhadweaponall( 0 );
    self.afterlife_revived = undefined;
}

afterlife_laststand_cleanup( corpse )
{
    self [[ level.afterlife_give_loadout ]]();
    self thread afterlife_corpse_cleanup( corpse );
}

afterlife_create_mana_bar( corpse )
{
    if ( self.afterliferound == level.round_number )
    {
        if ( !isdefined( self.keep_perks ) || self.afterlifedeaths == 0 )
            self.afterlifedeaths++;
    }
    else
    {
        self.afterliferound = level.round_number;
        self.afterlifedeaths = 1;
    }

    self.manacur = 200;
    self thread afterlife_mana_watch( corpse );
    self thread afterlife_lightning_watch( corpse );
    self thread afterlife_jump_watch( corpse );
}

afterlife_infinite_mana( b_infinite = 1 )
{
    if ( isdefined( b_infinite ) && b_infinite )
        self.infinite_mana = 1;
    else
        self.infinite_mana = 0;
}

afterlife_mana_watch( corpse )
{
    self endon( "disconnect" );
    corpse endon( "player_revived" );

    while ( self.manacur > 0 )
    {
        wait 0.05;
        self afterlife_reduce_mana( 0.05 * self.afterlifedeaths * 3 );

        if ( self.manacur < 0 )
            self.manacur = 0;

        n_mapped_mana = linear_map( self.manacur, 0, 200, 0, 1 );
        self setclientfieldtoplayer( "player_afterlife_mana", n_mapped_mana );
    }

    if ( isdefined( corpse.revivetrigger ) )
    {
        while ( corpse.revivetrigger.beingrevived )
            wait 0.05;
    }

    corpse notify( "stop_revive_trigger" );
    self thread fadetoblackforxsec( 0, 0.5, 0.5, 0.5, "black" );
    wait 0.5;
    self notify( "out_of_mana" );
    self afterlife_leave( 0 );
}

afterlife_doors_open()
{
    n_network_sent = 0;
    a_show = getentarray( "afterlife_show", "targetname" );
    a_show = arraycombine( a_show, getentarray( "afterlife_prop", "script_noteworthy" ), 0, 0 );

    foreach ( ent in a_show )
    {
        n_network_sent++;

        if ( n_network_sent > 10 )
        {
            n_network_sent = 0;
            wait_network_frame();
        }

        if ( isdefined( ent ) )
            ent setvisibletoplayer( self );
    }

    a_hide = getentarray( "afterlife_door", "targetname" );
    a_hide = arraycombine( a_hide, getentarray( "zombie_door", "targetname" ), 0, 0 );
    a_hide = arraycombine( a_hide, getentarray( "quest_trigger", "script_noteworthy" ), 0, 0 );
    a_hide = arraycombine( a_hide, getentarray( "trap_trigger", "script_noteworthy" ), 0, 0 );
    a_hide = arraycombine( a_hide, getentarray( "travel_trigger", "script_noteworthy" ), 0, 0 );

    foreach ( ent in a_hide )
    {
        n_network_sent++;

        if ( n_network_sent > 10 )
        {
            n_network_sent = 0;
            wait_network_frame();
        }

        if ( isdefined( ent ) )
            ent setinvisibletoplayer( self );
    }

    if ( isdefined( self.claymores ) )
    {
        foreach ( claymore in self.claymores )
        {
            if ( isdefined( claymore.pickuptrigger ) )
                claymore.pickuptrigger setinvisibletoplayer( self );
        }
    }
}

afterlife_doors_close()
{
    n_network_sent = 0;
    a_hide = getentarray( "afterlife_show", "targetname" );
    a_hide = arraycombine( a_hide, getentarray( "afterlife_prop", "script_noteworthy" ), 0, 0 );

    foreach ( ent in a_hide )
    {
        n_network_sent++;

        if ( n_network_sent > 10 )
        {
            n_network_sent = 0;
            wait_network_frame();
        }

        if ( isdefined( ent ) )
            ent setinvisibletoplayer( self );
    }

    a_show = getentarray( "afterlife_door", "targetname" );
    a_show = arraycombine( a_show, getentarray( "zombie_door", "targetname" ), 0, 0 );
    a_show = arraycombine( a_show, getentarray( "quest_trigger", "script_noteworthy" ), 0, 0 );
    a_show = arraycombine( a_show, getentarray( "trap_trigger", "script_noteworthy" ), 0, 0 );
    a_show = arraycombine( a_show, getentarray( "travel_trigger", "script_noteworthy" ), 0, 0 );

    foreach ( ent in a_show )
    {
        n_network_sent++;

        if ( n_network_sent > 10 )
        {
            n_network_sent = 0;
            wait_network_frame();
        }

        if ( isdefined( ent ) )
            ent setvisibletoplayer( self );
    }

    if ( isdefined( self.claymores ) )
    {
        foreach ( claymore in self.claymores )
        {
            if ( isdefined( claymore.pickuptrigger ) )
                claymore.pickuptrigger setvisibletoplayer( self );
        }
    }
}

afterlife_corpse_cleanup( corpse )
{
    playsoundatposition( "zmb_afterlife_revived", corpse.origin );

    if ( isdefined( corpse.revivetrigger ) )
    {
        corpse notify( "stop_revive_trigger" );
        corpse.revivetrigger delete();
        corpse.revivetrigger = undefined;
    }

    self.e_afterlife_corpse = undefined;
    corpse setclientfield( "player_corpse_id", 0 );
    corpse afterlife_corpse_remove_pois();
    corpse ghost();
    self.loadout = undefined;
    wait_network_frame();
    wait_network_frame();
    wait_network_frame();
    corpse delete();
}

is_weapon_available_in_afterlife_corpse( weapon, player_to_check )
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

            if ( isdefined( player.loadout ) && isdefined( player.loadout.weapons ) )
            {
                for ( i = 0; i < player.loadout.weapons.size; i++ )
                {
                    afterlife_weapon = player.loadout.weapons[i];

                    if ( isdefined( afterlife_weapon ) && ( afterlife_weapon == weapon || afterlife_weapon == upgradedweapon ) )
                        count++;
                }
            }
        }
    }

    return count;
}

afterlife_spawn_corpse()
{
    if ( isdefined( self.is_on_gondola ) && self.is_on_gondola && level.e_gondola.destination == "roof" )
        corpse = maps\mp\zombies\_zm_clone::spawn_player_clone( self, self.origin, undefined );
    else
    {
        trace_start = self.origin;
        trace_end = self.origin + vectorscale( ( 0, 0, -1 ), 500.0 );
        corpse_trace = playerphysicstrace( trace_start, trace_end );
        corpse = maps\mp\zombies\_zm_clone::spawn_player_clone( self, corpse_trace, undefined );
    }

    corpse.angles = self.angles;
    corpse.ignoreme = 1;
    corpse maps\mp\zombies\_zm_clone::clone_give_weapon( "m1911_zm" );
    corpse maps\mp\zombies\_zm_clone::clone_animate( "afterlife" );
    corpse.revive_hud = self afterlife_revive_hud_create();
    corpse thread afterlife_revive_trigger_spawn();

    if ( flag( "solo_game" ) )
        corpse thread afterlife_corpse_create_pois();

    return corpse;
}

afterlife_corpse_create_pois()
{
    n_attractors = ceil( get_current_zombie_count() / 3 );

    if ( n_attractors < 4 )
        n_attractors = 4;

    a_nodes = afterlife_corpse_get_array_poi_positions();
    self.pois = [];

    if ( isdefined( a_nodes ) && a_nodes.size > 3 )
    {
        for ( i = 0; i < 3; i++ )
        {
            self.pois[i] = afterlife_corpse_create_poi( a_nodes[i].origin, n_attractors );
            wait 0.05;
        }
    }
}

afterlife_corpse_create_poi( v_origin, n_attractors )
{
    e_poi = spawn( "script_origin", v_origin );
    e_poi create_zombie_point_of_interest( 10000, 24, 5000, 1 );
    e_poi thread create_zombie_point_of_interest_attractor_positions();
/#
    e_poi thread print3d_ent( "Corpse POI" );
#/
    return e_poi;
}

afterlife_corpse_remove_pois()
{
    if ( !isdefined( self.pois ) )
        return;

    for ( i = 0; i < self.pois.size; i++ )
    {
        remove_poi_attractor( self.pois[i] );
        self.pois[i] delete();
    }

    self.pois = undefined;
}

afterlife_corpse_get_array_poi_positions()
{
    n_ideal_dist_sq = 490000;
    a_nodes = getanynodearray( self.origin, 1200 );

    for ( i = 0; i < a_nodes.size; i++ )
    {
        if ( !a_nodes[i] is_valid_teleport_node() )
            a_nodes[i] = undefined;
    }

    a_nodes = remove_undefined_from_array( a_nodes );
    return array_randomize( a_nodes );
}

afterlife_revive_hud_create()
{
    self.revive_hud = newclienthudelem( self );
    self.revive_hud.alignx = "center";
    self.revive_hud.aligny = "middle";
    self.revive_hud.horzalign = "center";
    self.revive_hud.vertalign = "bottom";
    self.revive_hud.y = -160;
    self.revive_hud.foreground = 1;
    self.revive_hud.font = "default";
    self.revive_hud.fontscale = 1.5;
    self.revive_hud.alpha = 0;
    self.revive_hud.color = ( 1, 1, 1 );
    self.revive_hud.hidewheninmenu = 1;
    self.revive_hud settext( "" );
    return self.revive_hud;
}

afterlife_revive_trigger_spawn()
{
    radius = getdvarint( _hash_A17166B0 );
    self.revivetrigger = spawn( "trigger_radius", ( 0, 0, 0 ), 0, radius, radius );
    self.revivetrigger sethintstring( "" );
    self.revivetrigger setcursorhint( "HINT_NOICON" );
    self.revivetrigger setmovingplatformenabled( 1 );
    self.revivetrigger enablelinkto();
    self.revivetrigger.origin = self.origin;
    self.revivetrigger linkto( self );
    self.revivetrigger.beingrevived = 0;
    self.revivetrigger.createtime = gettime();
    self thread afterlife_revive_trigger_think();
}

afterlife_revive_trigger_think()
{
    self endon( "disconnect" );
    self endon( "stop_revive_trigger" );
    self endon( "death" );
    wait 1;

    while ( true )
    {
        wait 0.1;
        self.revivetrigger sethintstring( "" );
        players = get_players();

        for ( i = 0; i < players.size; i++ )
        {
            if ( players[i] afterlife_can_revive( self ) )
            {
                self.revivetrigger setrevivehintstring( &"GAME_BUTTON_TO_REVIVE_PLAYER", self.team );
                break;
            }
        }

        for ( i = 0; i < players.size; i++ )
        {
            reviver = players[i];

            if ( self == reviver || !reviver is_reviving_afterlife( self ) )
                continue;

            gun = reviver getcurrentweapon();
            assert( isdefined( gun ) );

            if ( gun == level.revive_tool || gun == level.afterlife_revive_tool )
                continue;

            if ( isdefined( reviver.afterlife ) && reviver.afterlife )
            {
                reviver giveweapon( level.afterlife_revive_tool );
                reviver switchtoweapon( level.afterlife_revive_tool );
                reviver setweaponammostock( level.afterlife_revive_tool, 1 );
            }
            else
            {
                reviver giveweapon( level.revive_tool );
                reviver switchtoweapon( level.revive_tool );
                reviver setweaponammostock( level.revive_tool, 1 );
            }

            revive_success = reviver afterlife_revive_do_revive( self, gun );
            reviver revive_give_back_weapons( gun );

            if ( isplayer( self ) )
                self allowjump( 1 );

            self.laststand = undefined;

            if ( revive_success )
            {
                self thread revive_success( reviver );
                self cleanup_suicide_hud();
                return;
            }
        }
    }
}

afterlife_can_revive( revivee )
{
    if ( isdefined( self.afterlife ) && self.afterlife && isdefined( self.e_afterlife_corpse ) && self.e_afterlife_corpse != revivee )
        return false;

    if ( !isdefined( revivee.revivetrigger ) )
        return false;

    if ( !isalive( self ) )
        return false;

    if ( self player_is_in_laststand() )
        return false;

    if ( self.team != revivee.team )
        return false;

    if ( self has_powerup_weapon() )
        return false;

    ignore_sight_checks = 0;
    ignore_touch_checks = 0;

    if ( isdefined( level.revive_trigger_should_ignore_sight_checks ) )
    {
        ignore_sight_checks = [[ level.revive_trigger_should_ignore_sight_checks ]]( self );

        if ( ignore_sight_checks && isdefined( revivee.revivetrigger.beingrevived ) && revivee.revivetrigger.beingrevived == 1 )
            ignore_touch_checks = 1;
    }

    if ( !ignore_touch_checks )
    {
        if ( !self istouching( revivee.revivetrigger ) )
            return false;
    }

    if ( !ignore_sight_checks )
    {
        if ( !self is_facing( revivee ) )
            return false;

        if ( !sighttracepassed( self.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), revivee.origin + vectorscale( ( 0, 0, 1 ), 30.0 ), 0, undefined ) )
            return false;
    }

    return true;
}

afterlife_revive_do_revive( playerbeingrevived, revivergun )
{
    assert( self is_reviving_afterlife( playerbeingrevived ) );
    revivetime = 3;
    playloop = 0;

    if ( isdefined( self.afterlife ) && self.afterlife )
    {
        playloop = 1;
        revivetime = 1;
    }

    timer = 0;
    revived = 0;
    playerbeingrevived.revivetrigger.beingrevived = 1;
    playerbeingrevived.revive_hud settext( &"GAME_PLAYER_IS_REVIVING_YOU", self );
    playerbeingrevived revive_hud_show_n_fade( 3.0 );
    playerbeingrevived.revivetrigger sethintstring( "" );

    if ( isplayer( playerbeingrevived ) )
        playerbeingrevived startrevive( self );

    if ( !isdefined( self.reviveprogressbar ) )
        self.reviveprogressbar = self createprimaryprogressbar();

    if ( !isdefined( self.revivetexthud ) )
        self.revivetexthud = newclienthudelem( self );

    self thread revive_clean_up_on_gameover();
    self thread laststand_clean_up_on_disconnect( playerbeingrevived, revivergun );

    if ( !isdefined( self.is_reviving_any ) )
        self.is_reviving_any = 0;

    self.is_reviving_any++;
    self thread laststand_clean_up_reviving_any( playerbeingrevived );
    self.reviveprogressbar updatebar( 0.01, 1 / revivetime );
    self.revivetexthud.alignx = "center";
    self.revivetexthud.aligny = "middle";
    self.revivetexthud.horzalign = "center";
    self.revivetexthud.vertalign = "bottom";
    self.revivetexthud.y = -113;

    if ( self issplitscreen() )
        self.revivetexthud.y = -347;

    self.revivetexthud.foreground = 1;
    self.revivetexthud.font = "default";
    self.revivetexthud.fontscale = 1.8;
    self.revivetexthud.alpha = 1;
    self.revivetexthud.color = ( 1, 1, 1 );
    self.revivetexthud.hidewheninmenu = 1;

    if ( self maps\mp\zombies\_zm_pers_upgrades_functions::pers_revive_active() )
        self.revivetexthud.color = ( 0.5, 0.5, 1.0 );

    self.revivetexthud settext( &"GAME_REVIVING" );
    self thread check_for_failed_revive( playerbeingrevived );
    e_fx = spawn( "script_model", playerbeingrevived.revivetrigger.origin );
    e_fx setmodel( "tag_origin" );
    e_fx thread revive_fx_clean_up_on_disconnect( playerbeingrevived );
    playfxontag( level._effect["afterlife_leave"], e_fx, "tag_origin" );

    if ( isdefined( playloop ) && playloop )
        e_fx playloopsound( "zmb_afterlife_reviving", 0.05 );

    while ( self is_reviving_afterlife( playerbeingrevived ) )
    {
        wait 0.05;
        timer += 0.05;

        if ( self player_is_in_laststand() )
            break;

        if ( isdefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
            break;

        if ( timer >= revivetime )
        {
            revived = 1;
            break;
        }
    }

    e_fx delete();

    if ( isdefined( self.reviveprogressbar ) )
        self.reviveprogressbar destroyelem();

    if ( isdefined( self.revivetexthud ) )
        self.revivetexthud destroy();

    if ( isdefined( playerbeingrevived.revivetrigger.auto_revive ) && playerbeingrevived.revivetrigger.auto_revive == 1 )
    {

    }
    else if ( !revived )
    {
        if ( isplayer( playerbeingrevived ) )
            playerbeingrevived stoprevive( self );
    }

    playerbeingrevived.revivetrigger sethintstring( &"GAME_BUTTON_TO_REVIVE_PLAYER" );
    playerbeingrevived.revivetrigger.beingrevived = 0;
    self notify( "do_revive_ended_normally" );
    self.is_reviving_any--;

    if ( !revived )
        playerbeingrevived thread checkforbleedout( self );

    return revived;
}

revive_fx_clean_up_on_disconnect( e_corpse )
{
    self endon( "death" );

    e_corpse waittill( "disconnect" );

    self delete();
}

revive_clean_up_on_gameover()
{
    self endon( "do_revive_ended_normally" );

    level waittill( "end_game" );

    if ( isdefined( self.reviveprogressbar ) )
        self.reviveprogressbar destroyelem();

    if ( isdefined( self.revivetexthud ) )
        self.revivetexthud destroy();
}

is_reviving_afterlife( revivee )
{
    return self usebuttonpressed() && afterlife_can_revive( revivee );
}

afterlife_save_loadout()
{
    primaries = self getweaponslistprimaries();
    currentweapon = self getcurrentweapon();
    self.loadout = spawnstruct();
    self.loadout.player = self;
    self.loadout.weapons = [];
    self.loadout.score = self.score;
    self.loadout.current_weapon = 0;

    foreach ( index, weapon in primaries )
    {
        self.loadout.weapons[index] = weapon;
        self.loadout.stockcount[index] = self getweaponammostock( weapon );
        self.loadout.clipcount[index] = self getweaponammoclip( weapon );

        if ( weaponisdualwield( weapon ) )
        {
            weapon_dw = weapondualwieldweaponname( weapon );
            self.loadout.clipcount2[index] = self getweaponammoclip( weapon_dw );
        }

        weapon_alt = weaponaltweaponname( weapon );

        if ( weapon_alt != "none" )
        {
            self.loadout.stockcountalt[index] = self getweaponammostock( weapon_alt );
            self.loadout.clipcountalt[index] = self getweaponammoclip( weapon_alt );
        }

        if ( weapon == currentweapon )
            self.loadout.current_weapon = index;
    }

    self.loadout.equipment = self get_player_equipment();

    if ( isdefined( self.loadout.equipment ) )
        self equipment_take( self.loadout.equipment );

    if ( self hasweapon( "claymore_zm" ) )
    {
        self.loadout.hasclaymore = 1;
        self.loadout.claymoreclip = self getweaponammoclip( "claymore_zm" );
    }

    if ( self hasweapon( "emp_grenade_zm" ) )
    {
        self.loadout.hasemp = 1;
        self.loadout.empclip = self getweaponammoclip( "emp_grenade_zm" );
    }

    if ( self hasweapon( "bouncing_tomahawk_zm" ) || self hasweapon( "upgraded_tomahawk_zm" ) )
    {
        self.loadout.hastomahawk = 1;
        self setclientfieldtoplayer( "tomahawk_in_use", 0 );
    }

    self.loadout.perks = afterlife_save_perks( self );
    lethal_grenade = self get_player_lethal_grenade();

    if ( self hasweapon( lethal_grenade ) )
        self.loadout.grenade = self getweaponammoclip( lethal_grenade );
    else
        self.loadout.grenade = 0;

    self.loadout.lethal_grenade = lethal_grenade;
    self set_player_lethal_grenade( undefined );
}

afterlife_give_loadout()
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

        if ( loadout.weapons[i] == "none" )
            continue;

        weapon = loadout.weapons[i];
        stock_amount = loadout.stockcount[i];
        clip_amount = loadout.clipcount[i];

        if ( !self hasweapon( weapon ) )
        {
            self giveweapon( weapon, 0, self maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
            self setweaponammostock( weapon, stock_amount );
            self setweaponammoclip( weapon, clip_amount );

            if ( weaponisdualwield( weapon ) )
            {
                weapon_dw = weapondualwieldweaponname( weapon );
                self setweaponammoclip( weapon_dw, loadout.clipcount2[i] );
            }

            weapon_alt = weaponaltweaponname( weapon );

            if ( weapon_alt != "none" )
            {
                self setweaponammostock( weapon_alt, loadout.stockcountalt[i] );
                self setweaponammoclip( weapon_alt, loadout.clipcountalt[i] );
            }
        }
    }

    self setspawnweapon( loadout.weapons[loadout.current_weapon] );
    self switchtoweaponimmediate( loadout.weapons[loadout.current_weapon] );

    if ( isdefined( self get_player_melee_weapon() ) )
        self giveweapon( self get_player_melee_weapon() );

    self maps\mp\zombies\_zm_equipment::equipment_give( self.loadout.equipment );

    if ( isdefined( loadout.hasclaymore ) && loadout.hasclaymore && !self hasweapon( "claymore_zm" ) )
    {
        self giveweapon( "claymore_zm" );
        self set_player_placeable_mine( "claymore_zm" );
        self setactionslot( 4, "weapon", "claymore_zm" );
        self setweaponammoclip( "claymore_zm", loadout.claymoreclip );
    }

    if ( isdefined( loadout.hasemp ) && loadout.hasemp )
    {
        self giveweapon( "emp_grenade_zm" );
        self setweaponammoclip( "emp_grenade_zm", loadout.empclip );
    }

    if ( isdefined( loadout.hastomahawk ) && loadout.hastomahawk )
    {
        self giveweapon( self.current_tomahawk_weapon );
        self set_player_tactical_grenade( self.current_tomahawk_weapon );
        self setclientfieldtoplayer( "tomahawk_in_use", 1 );
    }

    self.score = loadout.score;
    perk_array = maps\mp\zombies\_zm_perks::get_perk_array( 1 );

    for ( i = 0; i < perk_array.size; i++ )
    {
        perk = perk_array[i];
        self unsetperk( perk );
        self set_perk_clientfield( perk, 0 );
    }

    if ( isdefined( self.keep_perks ) && self.keep_perks && isdefined( loadout.perks ) && loadout.perks.size > 0 )
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

    self.keep_perks = undefined;
    self set_player_lethal_grenade( self.loadout.lethal_grenade );

    if ( loadout.grenade > 0 )
    {
        curgrenadecount = 0;

        if ( self hasweapon( self get_player_lethal_grenade() ) )
            self getweaponammoclip( self get_player_lethal_grenade() );
        else
            self giveweapon( self get_player_lethal_grenade() );

        self setweaponammoclip( self get_player_lethal_grenade(), loadout.grenade + curgrenadecount );
    }
}

afterlife_fake_death()
{
    level notify( "fake_death" );
    self notify( "fake_death" );
    self takeallweapons();
    self allowstand( 0 );
    self allowcrouch( 0 );
    self allowprone( 1 );
    self setstance( "prone" );

    if ( self is_jumping() )
    {
        while ( self is_jumping() )
            wait 0.05;
    }

    playfx( level._effect["afterlife_enter"], self.origin );
    self.ignoreme = 1;
    self enableinvulnerability();
    self freezecontrols( 1 );
}

afterlife_fake_revive()
{
    level notify( "fake_revive" );
    self notify( "fake_revive" );
    playsoundatposition( "zmb_afterlife_spawn_leave", self.origin );

    if ( flag( "afterlife_start_over" ) )
    {
        spawnpoint = [[ level.afterlife_get_spawnpoint ]]();
        trace_start = spawnpoint.origin;
        trace_end = spawnpoint.origin + vectorscale( ( 0, 0, -1 ), 200.0 );
        respawn_trace = playerphysicstrace( trace_start, trace_end );
        self setorigin( respawn_trace );
        self setplayerangles( spawnpoint.angles );
        playsoundatposition( "zmb_afterlife_spawn_enter", spawnpoint.origin );
    }
    else
        playsoundatposition( "zmb_afterlife_spawn_enter", self.origin );

    self allowstand( 1 );
    self allowcrouch( 0 );
    self allowprone( 0 );
    self.ignoreme = 0;
    self setstance( "stand" );
    self giveweapon( "lightning_hands_zm" );
    self switchtoweapon( "lightning_hands_zm" );
    self.score = 0;
    wait 1;
}

afterlife_get_spawnpoint()
{
    spawnpoint = check_for_valid_spawn_in_zone( self );

    if ( !isdefined( spawnpoint ) )
        spawnpoint = maps\mp\zombies\_zm::check_for_valid_spawn_near_position( self, self.origin, 1 );

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

check_for_valid_spawn_in_zone( player )
{
    a_spawn_points = maps\mp\gametypes_zm\_zm_gametype::get_player_spawns_for_gametype();

    if ( isdefined( level.e_gondola ) && ( isdefined( level.e_gondola.is_moving ) && level.e_gondola.is_moving ) )
    {
        if ( player maps\mp\zm_alcatraz_travel::is_player_on_gondola() )
        {
            if ( level.e_gondola.destination == "roof" )
                str_player_zone = "zone_cellblock_west_gondola";
            else if ( level.e_gondola.destination == "docks" )
                str_player_zone = "zone_dock";
        }
        else
            str_player_zone = player maps\mp\zombies\_zm_zonemgr::get_player_zone();
    }
    else
        str_player_zone = player maps\mp\zombies\_zm_zonemgr::get_player_zone();
/#
    println( "The player is not in a zone at origin " + player.origin );
#/
    foreach ( spawn_point in a_spawn_points )
    {
        if ( spawn_point.script_noteworthy == str_player_zone )
        {
            a_spawn_structs = getstructarray( spawn_point.target, "targetname" );
            a_spawn_structs = get_array_of_closest( player.origin, a_spawn_structs );

            foreach ( s_spawn in a_spawn_structs )
            {
                if ( !flag( "afterlife_start_over" ) )
                {
                    if ( isdefined( s_spawn.en_num ) && s_spawn.en_num != player.playernum )
                        continue;
                }

                if ( positionwouldtelefrag( s_spawn.origin ) || distancesquared( player.origin, s_spawn.origin ) < 250000 )
                    continue;
                else
                    return s_spawn;
            }

            a_spawn_structs = get_array_of_farthest( player.origin, a_spawn_structs, undefined, 250000 );

            foreach ( s_spawn in a_spawn_structs )
            {
                if ( positionwouldtelefrag( s_spawn.origin ) )
                    continue;
                else
                    return s_spawn;
            }
        }
    }

    return undefined;
}

afterlife_save_perks( ent )
{
    perk_array = ent get_perk_array( 1 );

    foreach ( perk in perk_array )
        ent unsetperk( perk );

    return perk_array;
}

afterlife_hostmigration()
{
    while ( true )
    {
        level waittill( "host_migration_end" );

        foreach ( player in getplayers() )
        {
            player setclientfieldtoplayer( "player_lives", player.lives );

            if ( isdefined( player.e_afterlife_corpse ) )
                player.e_afterlife_corpse setclientfield( "player_corpse_id", 0 );
        }

        wait_network_frame();
        wait_network_frame();

        foreach ( player in getplayers() )
        {
            if ( isdefined( player.e_afterlife_corpse ) )
                player.e_afterlife_corpse setclientfield( "player_corpse_id", player getentitynumber() + 1 );
        }
    }
}

afterlife_reduce_mana( n_mana )
{
    if ( isdefined( self.afterlife ) && !self.afterlife )
        return;

    if ( isdefined( level.hostmigrationtimer ) )
        return;

    if ( isdefined( self.infinite_mana ) && self.infinite_mana )
    {
        self.manacur = 200;
        return;
    }
/#
    if ( getdvarint( _hash_FA81816F ) >= 1 )
    {
        self.manacur = 200;
        return;
    }
#/
    if ( isdefined( self.e_afterlife_corpse ) && ( isdefined( self.e_afterlife_corpse.revivetrigger.beingrevived ) && self.e_afterlife_corpse.revivetrigger.beingrevived ) )
        return;

    self.manacur -= n_mana;
}

afterlife_lightning_watch( corpse )
{
    self endon( "disconnect" );
    corpse endon( "player_revived" );

    while ( true )
    {
        self waittill( "weapon_fired" );

        self afterlife_reduce_mana( 1 );
        wait 0.05;
    }
}

afterlife_jump_watch( corpse )
{
    self endon( "disconnect" );
    corpse endon( "player_revived" );

    while ( true )
    {
        if ( self is_jumping() )
        {
            self afterlife_reduce_mana( 0.3 );
            earthquake( 0.1, 0.05, self.origin, 200, self );
        }

        wait 0.05;
    }
}

afterlife_trigger_create( s_origin )
{
    s_origin.unitrigger_stub = spawnstruct();
    s_origin.unitrigger_stub.origin = s_origin.origin;
    s_origin.unitrigger_stub.radius = 36;
    s_origin.unitrigger_stub.height = 256;
    s_origin.unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
    s_origin.unitrigger_stub.hint_string = &"ZM_PRISON_AFTERLIFE_KILL";
    s_origin.unitrigger_stub.cursor_hint = "HINT_NOICON";
    s_origin.unitrigger_stub.require_look_at = 1;
    s_origin.unitrigger_stub.prompt_and_visibility_func = ::afterlife_trigger_visibility;
    maps\mp\zombies\_zm_unitrigger::unitrigger_force_per_player_triggers( s_origin.unitrigger_stub, 1 );
    maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( s_origin.unitrigger_stub, ::afterlife_trigger_think );
}

reset_all_afterlife_unitriggers()
{
    a_afterlife_triggers = getstructarray( "afterlife_trigger", "targetname" );

    foreach ( struct in a_afterlife_triggers )
    {
        maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( struct.unitrigger_stub );
        maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( struct.unitrigger_stub, ::afterlife_trigger_think );
    }
}

afterlife_trigger_visibility( player )
{
    b_is_invis = player.afterlife;
    self setinvisibletoplayer( player, b_is_invis );

    if ( player.lives == 0 )
        self sethintstring( &"ZM_PRISON_OUT_OF_LIVES" );
    else
    {
        self sethintstring( self.stub.hint_string );

        if ( !isdefined( player.has_played_afterlife_trigger_hint ) && player is_player_looking_at( self.stub.origin, 0.25 ) )
        {
            if ( !( isdefined( player.dontspeak ) && player.dontspeak ) )
            {
                player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "killswitch_clue" );
                player.has_played_afterlife_trigger_hint = 1;
            }
        }
    }

    return !b_is_invis;
}

afterlife_trigger_think()
{
    self endon( "kill_trigger" );
    flag_wait( "start_zombie_round_logic" );

    while ( true )
    {
        self waittill( "trigger", player );

        if ( player.lives <= 0 )
        {
            self playsound( "zmb_no_cha_ching" );
            continue;
        }

        if ( player is_reviving_any() || player player_is_in_laststand() )
        {
            wait 0.1;
            continue;
        }

        if ( isdefined( player.afterlife ) && !player.afterlife )
        {
            self setinvisibletoplayer( player, 1 );
            self playsound( "zmb_afterlife_trigger_activate" );
            player playsoundtoplayer( "zmb_afterlife_trigger_electrocute", player );
            player thread afterlife_trigger_used_vo();
            self sethintstring( "" );
            player.keep_perks = 1;
            player afterlife_remove();
            player.afterlife = 1;
            player thread afterlife_laststand();
            e_fx = spawn( "script_model", self.origin );
            e_fx setmodel( "tag_origin" );
            e_fx.angles = vectorscale( ( 1, 0, 0 ), 90.0 );
            playfxontag( level._effect["afterlife_kill_point_fx"], e_fx, "tag_origin" );
            wait 2;
            e_fx delete();
            self sethintstring( &"ZM_PRISON_AFTERLIFE_KILL" );
        }
    }
}

#using_animtree("fxanim_props");

afterlife_interact_object_think()
{
    self endon( "afterlife_interact_complete" );

    if ( isdefined( self.script_int ) && self.script_int > 0 )
        n_total_interact_count = self.script_int;
    else if ( !isdefined( self.script_int ) || isdefined( self.script_int ) && self.script_int <= 0 )
        n_total_interact_count = 0;

    n_count = 0;
    self.health = 5000;
    self setcandamage( 1 );
    self useanimtree( #animtree );
    self playloopsound( "zmb_afterlife_shockbox_off", 1 );

    if ( !isdefined( level.shockbox_anim ) )
    {
        level.shockbox_anim["on"] = %fxanim_zom_al_shock_box_on_anim;
        level.shockbox_anim["off"] = %fxanim_zom_al_shock_box_off_anim;
    }

    trig_spawn_offset = ( 0, 0, 0 );

    if ( self.model != "p6_anim_zm_al_nixie_tubes" )
    {
        if ( isdefined( self.script_string ) && self.script_string == "intro_powerup_activate" )
            self.t_bump = spawn( "trigger_radius", self.origin + vectorscale( ( 0, 1, 0 ), 28.0 ), 0, 28, 64 );
        else
        {
            if ( issubstr( self.model, "p6_zm_al_shock_box" ) )
            {
                trig_spawn_offset = ( 0, 11, 46 );
                str_hint = &"ZM_PRISON_AFTERLIFE_INTERACT";
            }
            else if ( issubstr( self.model, "p6_zm_al_power_station_panels" ) )
            {
                trig_spawn_offset = ( 32, 35, 58 );
                str_hint = &"ZM_PRISON_AFTERLIFE_OVERLOAD";
            }

            afterlife_interact_hint_trigger_create( self, trig_spawn_offset, str_hint );
        }
    }

    while ( true )
    {
        if ( isdefined( self.unitrigger_stub ) )
            self.unitrigger_stub.is_activated_in_afterlife = 0;
        else if ( isdefined( self.t_bump ) )
        {
            self.t_bump setcursorhint( "HINT_NOICON" );
            self.t_bump sethintstring( &"ZM_PRISON_AFTERLIFE_INTERACT" );
        }

        self waittill( "damage", amount, attacker );

        if ( attacker == level || isplayer( attacker ) && attacker getcurrentweapon() == "lightning_hands_zm" )
        {
            if ( isdefined( self.script_string ) )
            {
                if ( isdefined( level.afterlife_interact_dist ) )
                {
                    if ( attacker == level || distancesquared( attacker.origin, self.origin ) < level.afterlife_interact_dist * level.afterlife_interact_dist )
                    {
                        level notify( self.script_string );

                        if ( isdefined( self.unitrigger_stub ) )
                        {
                            self.unitrigger_stub.is_activated_in_afterlife = 1;
                            self.unitrigger_stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
                        }
                        else if ( isdefined( self.t_bump ) )
                            self.t_bump sethintstring( "" );

                        self playloopsound( "zmb_afterlife_shockbox_on", 1 );

                        if ( self.model == "p6_zm_al_shock_box_off" )
                        {
                            if ( !isdefined( self.playing_fx ) )
                            {
                                playfxontag( level._effect["box_activated"], self, "tag_origin" );
                                self.playing_fx = 1;
                                self thread afterlife_interact_object_fx_cooldown();
                                self playsound( "zmb_powerpanel_activate" );
                            }

                            self setmodel( "p6_zm_al_shock_box_on" );
                            self setanim( level.shockbox_anim["on"] );
                        }

                        n_count++;

                        if ( n_total_interact_count <= 0 || n_count < n_total_interact_count )
                        {
                            self waittill( "afterlife_interact_reset" );

                            self playloopsound( "zmb_afterlife_shockbox_off", 1 );

                            if ( self.model == "p6_zm_al_shock_box_on" )
                            {
                                self setmodel( "p6_zm_al_shock_box_off" );
                                self setanim( level.shockbox_anim["off"] );
                            }

                            if ( isdefined( self.unitrigger_stub ) )
                            {
                                self.unitrigger_stub.is_activated_in_afterlife = 0;
                                self.unitrigger_stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
                            }
                        }
                        else
                        {
                            if ( isdefined( self.t_bump ) )
                                self.t_bump delete();

                            break;
                        }
                    }
                }
            }
        }
    }
}

afterlife_interact_hint_trigger_create( m_interact, v_trig_offset, str_hint )
{
    m_interact.unitrigger_stub = spawnstruct();
    m_interact.unitrigger_stub.origin = m_interact.origin + anglestoforward( m_interact.angles ) * v_trig_offset[0] + anglestoright( m_interact.angles ) * v_trig_offset[1] + anglestoup( m_interact.angles ) * v_trig_offset[2];
    m_interact.unitrigger_stub.radius = 40;
    m_interact.unitrigger_stub.height = 64;
    m_interact.unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
    m_interact.unitrigger_stub.hint_string = str_hint;
    m_interact.unitrigger_stub.cursor_hint = "HINT_NOICON";
    m_interact.unitrigger_stub.require_look_at = 1;
    m_interact.unitrigger_stub.ignore_player_valid = 1;
    m_interact.unitrigger_stub.prompt_and_visibility_func = ::afterlife_trigger_visible_in_afterlife;
    maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( m_interact.unitrigger_stub, ::afterlife_interact_hint_trigger_think );
}

afterlife_trigger_visible_in_afterlife( player )
{
    b_is_invis = isdefined( self.stub.is_activated_in_afterlife ) && self.stub.is_activated_in_afterlife;
    self setinvisibletoplayer( player, b_is_invis );
    self sethintstring( self.stub.hint_string );

    if ( !b_is_invis )
    {
        if ( player is_player_looking_at( self.origin, 0.25 ) )
        {
            if ( cointoss() )
                player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "need_electricity" );
            else
                player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "electric_zap" );
        }
    }

    return !b_is_invis;
}

afterlife_interact_hint_trigger_think()
{
    self endon( "kill_trigger" );

    while ( true )
    {
        self waittill( "trigger" );

        wait 1000;
    }
}

afterlife_interact_object_fx_cooldown()
{
    wait 2;
    self.playing_fx = undefined;
}

afterlife_zombie_damage()
{
    self.actor_damage_func = ::afterlife_damage_func;
}

afterlife_damage_func( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    if ( sweapon == "lightning_hands_zm" )
    {
        if ( !isdefined( self.zapped ) )
        {
            a_zombies = get_array_of_closest( self.origin, getaiarray( "axis" ), undefined, 5, 80 );

            for ( i = 0; i < a_zombies.size; i++ )
            {
                if ( isalive( a_zombies[i] ) && !isdefined( a_zombies[i].zapped ) )
                {
                    a_zombies[i] notify( "zapped" );
                    a_zombies[i] thread [[ level.afterlife_zapped ]]();
                    wait 0.05;
                }
            }
        }

        return 0;
    }

    return idamage;
}

afterlife_zapped()
{
    self endon( "death" );
    self endon( "zapped" );

    if ( self.ai_state == "find_flesh" )
    {
        self.zapped = 1;
        n_ideal_dist_sq = 490000;
        n_min_dist_sq = 10000;
        a_nodes = getanynodearray( self.origin, 1200 );
        a_nodes = arraycombine( a_nodes, getanynodearray( self.origin + vectorscale( ( 0, 0, 1 ), 120.0 ), 1200 ), 0, 0 );
        a_nodes = arraycombine( a_nodes, getanynodearray( self.origin - vectorscale( ( 0, 0, 1 ), 120.0 ), 1200 ), 0, 0 );
        a_nodes = array_randomize( a_nodes );
        nd_target = undefined;

        for ( i = 0; i < a_nodes.size; i++ )
        {
            if ( distance2dsquared( a_nodes[i].origin, self.origin ) > n_ideal_dist_sq )
            {
                if ( a_nodes[i] is_valid_teleport_node() )
                {
                    nd_target = a_nodes[i];
                    break;
                }
            }
        }

        if ( !isdefined( nd_target ) )
        {
            for ( i = 0; i < a_nodes.size; i++ )
            {
                if ( distance2dsquared( a_nodes[i].origin, self.origin ) > n_min_dist_sq )
                {
                    if ( a_nodes[i] is_valid_teleport_node() )
                    {
                        nd_target = a_nodes[i];
                        break;
                    }
                }
            }
        }

        if ( isdefined( nd_target ) )
        {
            v_fx_offset = vectorscale( ( 0, 0, 1 ), 40.0 );
            playfx( level._effect["afterlife_teleport"], self.origin );
            playsoundatposition( "zmb_afterlife_zombie_warp_out", self.origin );
            self hide();
            linker = spawn( "script_model", self.origin + v_fx_offset );
            linker setmodel( "tag_origin" );
            playfxontag( level._effect["teleport_ball"], linker, "tag_origin" );
            linker thread linker_delete_watch( self );
            self linkto( linker );
            linker moveto( nd_target.origin + v_fx_offset, 1 );

            linker waittill( "movedone" );

            linker delete();
            playfx( level._effect["afterlife_teleport"], self.origin );
            playsoundatposition( "zmb_afterlife_zombie_warp_in", self.origin );
            self show();
        }
        else
        {
/#
            iprintln( "Could not teleport" );
#/
            playfx( level._effect["afterlife_teleport"], self.origin );
            playsoundatposition( "zmb_afterlife_zombie_warp_out", self.origin );
            level.zombie_total++;
            self delete();
            return;
        }

        self.zapped = undefined;
        self.ignoreall = 1;
        self notify( "stop_find_flesh" );
        self thread afterlife_zapped_fx();

        for ( i = 0; i < 3; i++ )
        {
            self animscripted( self.origin, self.angles, "zm_afterlife_stun" );
            self maps\mp\animscripts\shared::donotetracks( "stunned" );
        }

        self.ignoreall = 0;
        self thread maps\mp\zombies\_zm_ai_basic::find_flesh();
    }
}

is_valid_teleport_node()
{
    if ( !check_point_in_enabled_zone( self.origin ) )
        return false;

    if ( self.type != "Path" )
        return false;

    if ( isdefined( self.script_noteworthy ) && self.script_noteworthy == "no_teleport" )
        return false;

    if ( isdefined( self.no_teleport ) && self.no_teleport )
        return false;

    return true;
}

linker_delete_watch( ai_zombie )
{
    self endon( "death" );

    ai_zombie waittill( "death" );

    self delete();
}

afterlife_zapped_fx()
{
    self endon( "death" );
    playfxontag( level._effect["elec_torso"], self, "J_SpineLower" );
    self playsound( "zmb_elec_jib_zombie" );
    wait 1;
    tagarray = [];
    tagarray[0] = "J_Elbow_LE";
    tagarray[1] = "J_Elbow_RI";
    tagarray[2] = "J_Knee_RI";
    tagarray[3] = "J_Knee_LE";
    tagarray = array_randomize( tagarray );
    playfxontag( level._effect["elec_md"], self, tagarray[0] );
    self playsound( "zmb_elec_jib_zombie" );
    wait 1;
    self playsound( "zmb_elec_jib_zombie" );
    tagarray[0] = "J_Wrist_RI";
    tagarray[1] = "J_Wrist_LE";

    if ( !isdefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" )
    {
        tagarray[2] = "J_Ankle_RI";
        tagarray[3] = "J_Ankle_LE";
    }

    tagarray = array_randomize( tagarray );
    playfxontag( level._effect["elec_sm"], self, tagarray[0] );
    playfxontag( level._effect["elec_sm"], self, tagarray[1] );
}

enable_afterlife_prop()
{
    self show();
    self.script_noteworthy = "afterlife_prop";
    a_players = getplayers();

    foreach ( player in a_players )
    {
        if ( isdefined( player.afterlife ) && player.afterlife )
        {
            self setvisibletoplayer( player );
            continue;
        }

        self setinvisibletoplayer( player );
    }
}

disable_afterlife_prop()
{
    self.script_noteworthy = undefined;
    self setvisibletoall();
}

last_stand_conscience_vo()
{
    self endon( "player_revived" );
    self endon( "player_suicide" );
    self endon( "zombified" );
    self endon( "disconnect" );
    self endon( "end_game" );

    if ( !isdefined( self.conscience_vo_played ) )
        self.conscience_vo_played = 0;

    self.conscience_vo_played++;
    convo = [];
    convo = level.conscience_vo["conscience_" + self.character_name + "_convo_" + self.conscience_vo_played];

    if ( isdefined( convo ) )
    {
        wait 5;
        a_players = getplayers();

        if ( a_players.size > 1 )
        {
            foreach ( player in a_players )
            {
                if ( player != self )
                {
                    if ( distancesquared( self.origin, player.origin ) < 1000000 )
                        return;
                }
            }
        }

        self.dontspeak = 1;

        for ( i = 0; i < convo.size; i++ )
        {
            n_duration = soundgetplaybacktime( convo[i] );
            self playsoundtoplayer( convo[i], self );
            self thread conscience_vo_ended_early( convo[i] );
            wait( n_duration / 1000 );
            wait 0.5;
        }
    }

    self.dontspeak = 0;
}

conscience_vo_ended_early( str_alias )
{
    self notify( "conscience_VO_end_early" );
    self endon( "conscience_VO_end_early" );
    self waittill_any( "player_revived", "player_suicide", "zombified", "death", "end_game" );
    self.dontspeak = 0;
    self stoplocalsound( str_alias );
}

afterlife_trigger_used_vo()
{
    a_vo = level.exert_sounds[self.characterindex + 1]["hitlrg"];
    n_index = randomint( a_vo.size );
    self playsound( a_vo[n_index] );
}
