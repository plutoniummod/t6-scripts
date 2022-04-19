// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_weap_tomahawk;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_audio;

init()
{
    if ( isdefined( level.gamedifficulty ) && level.gamedifficulty == 0 )
    {
        spoon_easy_cleanup();
        return;
    }

    precachemodel( "t6_wpn_zmb_spoon_world" );
    precachemodel( "c_zom_inmate_g_rarmspawn" );
    level thread wait_for_initial_conditions();
    array_thread( level.zombie_spawners, ::add_spawn_function, ::zombie_spoon_func );
    level thread bucket_init();
    spork_portal = getent( "afterlife_show_spork", "targetname" );
    spork_portal setinvisibletoall();
    level.b_spoon_in_tub = 0;
    level.n_spoon_kill_count = 0;
    flag_init( "spoon_obtained" );
    flag_init( "charged_spoon" );
/#
    level thread debug_prison_spoon_quest();
#/
}

spoon_easy_cleanup()
{
    spork_portal = getent( "afterlife_show_spork", "targetname" );
    spork_portal delete();
    m_spoon_pickup = getent( "pickup_spoon", "targetname" );
    m_spoon_pickup delete();
    m_spoon = getent( "zap_spoon", "targetname" );
    m_spoon delete();
}

extra_death_func_to_check_for_splat_death()
{
    self thread maps\mp\zombies\_zm_spawner::zombie_death_animscript();

    if ( self.damagemod == "MOD_GRENADE" || self.damagemod == "MOD_GRENADE_SPLASH" )
    {
        if ( self.damageweapon == "blundersplat_explosive_dart_zm" )
        {
            if ( isplayer( self.attacker ) )
                self notify( "killed_by_a_blundersplat", self.attacker );
        }
        else if ( self.damageweapon == "bouncing_tomahawk_zm" )
        {
            if ( isplayer( self.attacker ) )
                self.attacker notify( "got_a_tomahawk_kill" );
        }
    }

    if ( isdefined( self.attacker.killed_with_only_tomahawk ) )
    {
        if ( self.damageweapon != "bouncing_tomahawk_zm" && self.damageweapon != "none" )
            self.attacker.killed_with_only_tomahawk = 0;
    }

    if ( isdefined( self.attacker.killed_something_thq ) )
        self.attacker.killed_something_thq = 1;

    return 0;
}

zombie_spoon_func()
{
    self.deathfunction = ::extra_death_func_to_check_for_splat_death;

    self waittill( "killed_by_a_blundersplat", player );

    if ( flag( "charged_spoon" ) || !level.b_spoon_in_tub )
        return;

    if ( self maps\mp\zombies\_zm_zonemgr::entity_in_zone( "cellblock_shower" ) )
        level.n_spoon_kill_count++;
    else
        return;

    if ( level.n_spoon_kill_count >= 50 )
    {
/#
        iprintlnbold( "Spoon Charged" );
#/
        flag_set( "charged_spoon" );
    }
}

wait_for_initial_conditions()
{
    m_spoon_pickup = getent( "pickup_spoon", "targetname" );
    m_spoon_pickup ghost();
    m_spoon_pickup ghostindemo();

    while ( !isdefined( level.characters_in_nml ) || level.characters_in_nml.size == 0 )
        wait 1;

    flag_wait( "soul_catchers_charged" );
    m_poster = getent( "poster", "targetname" );
    m_poster.health = 5000;
    m_poster setcandamage( 1 );
    b_poster_knocked_down = 0;

    while ( !b_poster_knocked_down )
    {
        m_poster waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );

        if ( weaponname == "frag_grenade_zm" || weaponname == "bouncing_tomahawk_zm" || weaponname == "upgraded_tomahawk_zm" )
        {
            b_poster_knocked_down = 1;
            playsoundatposition( "zmb_squest_spoon_poster", m_poster.origin );
            m_poster delete();

            if ( isdefined( attacker ) && isplayer( attacker ) )
                attacker do_player_general_vox( "quest", "secret_poster", undefined, 100 );

            wait 1.0;
            attacker thread do_player_general_vox( "quest", "pick_up_easter_egg" );
        }
    }

    spork_door = getent( "spork_door", "targetname" );
    spork_door.targetname = "afterlife_door";
    spork_portal = getent( "afterlife_show_spork", "targetname" );
    spork_portal.targetname = "afterlife_show";
    m_spoon = getent( "zap_spoon", "targetname" );
    m_spoon ghostindemo();
    m_spoon.health = 50000;
    m_spoon setcandamage( 1 );
    b_spoon_shocked = 0;

    while ( !b_spoon_shocked )
    {
        m_spoon waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname );

        m_spoon.health += damage;

        if ( weaponname == "lightning_hands_zm" )
        {
            b_spoon_shocked = 1;
            m_spoon delete();
            attacker playsound( "zmb_easteregg_laugh" );
        }
    }

    m_spoon_pickup show();
    m_spoon_pickup.health = 10000;
    m_spoon_pickup setcandamage( 1 );
    level.a_tomahawk_pickup_funcs[level.a_tomahawk_pickup_funcs.size] = ::tomahawk_the_spoon;
}

tomahawk_the_spoon( grenade, n_grenade_charge_power )
{
    if ( self hasweapon( "spoon_zm_alcatraz" ) || self hasweapon( "spork_zm_alcatraz" ) )
        return false;

    m_spoon = getent( "pickup_spoon", "targetname" );

    if ( distancesquared( m_spoon.origin, grenade.origin ) < 40000 )
    {
        m_tomahawk = maps\mp\zombies\_zm_weap_tomahawk::tomahawk_spawn( grenade.origin );
        m_tomahawk.n_grenade_charge_power = n_grenade_charge_power;
        m_player_spoon = spawn( "script_model", grenade.origin );
        m_player_spoon setmodel( "t6_wpn_zmb_spoon_world" );
        m_player_spoon linkto( m_tomahawk );
        self maps\mp\zombies\_zm_stats::increment_client_stat( "prison_ee_spoon_acquired", 0 );
        self thread maps\mp\zombies\_zm_weap_tomahawk::tomahawk_return_player( m_tomahawk );
        self thread give_player_spoon_upon_receipt( m_tomahawk, m_player_spoon );
        self thread dip_the_spoon();
        flag_set( "spoon_obtained" );
        self playsoundtoplayer( "vox_brutus_easter_egg_101_0", self );
        return true;
    }

    return false;
}

give_player_spoon_upon_receipt( m_tomahawk, m_player_spoon )
{
    while ( isdefined( m_tomahawk ) )
        wait 0.05;

    m_player_spoon delete();

    if ( !self hasweapon( "spoon_zm_alcatraz" ) && !self hasweapon( "spork_zm_alcatraz" ) && !( isdefined( self.spoon_in_tub ) && self.spoon_in_tub ) )
    {
        self giveweapon( "spoon_zm_alcatraz" );
        self set_player_melee_weapon( "spoon_zm_alcatraz" );
        level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "spoon", self );
        weapons = self getweaponslist();

        for ( i = 0; i < weapons.size; i++ )
        {
            if ( issubstr( weapons[i], "knife" ) )
                self takeweapon( weapons[i] );
        }
    }

    weapons = self getweaponslist();
    wait 1.0;
    self thread do_player_general_vox( "quest", "pick_up_easter_egg" );
}

bucket_init()
{
    s_bathtub = getstruct( "tub_trigger_struct", "targetname" );
    level.t_bathtub = spawn( "trigger_radius_use", s_bathtub.origin, 0, 40, 150 );
    level.t_bathtub usetriggerrequirelookat();
    level.t_bathtub triggerignoreteam();
    level.t_bathtub sethintstring( "" );
    level.t_bathtub setcursorhint( "HINT_NOICON" );
}

wait_for_bucket_activated( player )
{
    if ( isdefined( player ) )
    {
        while ( true )
        {
            level.t_bathtub waittill( "trigger", who );

            if ( who == player )
                return;
        }
    }
    else
        level.t_bathtub waittill( "trigger", who );
}

dip_the_spoon()
{
    self endon( "disconnect" );
    wait_for_bucket_activated( self );
    self takeweapon( "spoon_zm_alcatraz" );
    self giveweapon( "knife_zm_alcatraz" );
    self set_player_melee_weapon( "knife_zm_alcatraz" );
    self.spoon_in_tub = 1;
    self setclientfieldtoplayer( "spoon_visual_state", 1 );
    wait 5;
    level.b_spoon_in_tub = 1;
    flag_wait( "charged_spoon" );
    wait 1.0;
    level.t_bathtub playsound( "zmb_easteregg_laugh" );
    self thread thrust_the_spork();
}

thrust_the_spork()
{
    self endon( "disconnect" );
    wait_for_bucket_activated( self );
    self setclientfieldtoplayer( "spoon_visual_state", 2 );
    wait 5;
    wait_for_bucket_activated( self );
    self takeweapon( "knife_zm_alcatraz" );
    self giveweapon( "spork_zm_alcatraz" );
    self set_player_melee_weapon( "spork_zm_alcatraz" );
    level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "spork", self );
    self.spoon_in_tub = undefined;
    self setclientfieldtoplayer( "spoon_visual_state", 3 );
    wait 1.0;
    self thread do_player_general_vox( "quest", "pick_up_easter_egg" );
}

debug_prison_spoon_quest()
{
/#
    while ( true )
    {
        a_players = getplayers();

        foreach ( player in a_players )
        {
            if ( player hasweapon( "bouncing_tomahawk_zm" ) )
            {
                flag_set( "soul_catchers_charged" );
                break;
            }
        }

        wait 1.0;
    }
#/
}
