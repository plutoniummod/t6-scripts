// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_audio;

init()
{
    registerclientfield( "toplayer", "tazer_flourish", 1, 1, "int" );
    register_melee_weapon_for_level( "tazer_knuckles_zm" );

    if ( isdefined( level.tazer_cost ) )
        cost = level.tazer_cost;
    else
        cost = 6000;

    maps\mp\zombies\_zm_melee_weapon::init( "tazer_knuckles_zm", "zombie_tazer_flourish", "knife_ballistic_no_melee_zm", "knife_ballistic_no_melee_upgraded_zm", cost, "tazer_upgrade", &"ZOMBIE_WEAPON_TAZER_BUY", "tazerknuckles", ::has_tazer, ::give_tazer, ::take_tazer, ::tazer_flourish_fx );
    maps\mp\zombies\_zm_weapons::add_retrievable_knife_init_name( "knife_ballistic_no_melee" );
    maps\mp\zombies\_zm_weapons::add_retrievable_knife_init_name( "knife_ballistic_no_melee_upgraded" );
    maps\mp\zombies\_zm_spawner::add_cusom_zombie_spawn_logic( ::watch_bodily_functions );
    level._effect["fx_zmb_taser_vomit"] = loadfx( "maps/zombie/fx_zmb_taser_vomit" );
    level._effect["fx_zmb_taser_flourish"] = loadfx( "weapon/taser/fx_taser_knuckles_anim_zmb" );
    level.tazer_flourish_delay = 0.5;
}

spectator_respawn()
{
    maps\mp\zombies\_zm_melee_weapon::spectator_respawn( "tazer_upgrade", ::take_tazer, ::has_tazer );
}

watch_bodily_functions()
{
    if ( isdefined( self.isscreecher ) && self.isscreecher || isdefined( self.is_avogadro ) && self.is_avogadro )
        return;

    while ( true )
    {
        self waittill( "damage", amount, attacker, direction_vec, point, type );

        if ( !isdefined( self ) )
            return;

        if ( !isdefined( attacker ) || !isplayer( attacker ) )
            continue;

        if ( type != "MOD_MELEE" )
            continue;

        if ( !attacker hasweapon( "tazer_knuckles_zm" ) || isdefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped )
            continue;

        ch = randomint( 100 );

        if ( ch < 4 )
            playfxontag( level._effect["fx_zmb_taser_vomit"], self, "j_neck" );
    }
}

onplayerconnect()
{
    self thread onplayerspawned();
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self thread watchtazerknucklemelee();
    }
}

watchtazerknucklemelee()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "weapon_melee", weapon );

        if ( weapon == "tazer_knuckles_zm" )
            self tazerknuckle_melee();
    }
}

tazerknuckle_melee()
{

}

has_tazer()
{
    if ( isdefined( level._allow_melee_weapon_switching ) && level._allow_melee_weapon_switching )
        return false;

    if ( isdefined( self._sickle_zm_equipped ) && self._sickle_zm_equipped || isdefined( self._bowie_zm_equipped ) && self._bowie_zm_equipped || isdefined( self._tazer_zm_equipped ) && self._tazer_zm_equipped )
        return true;

    return false;
}

give_tazer()
{
    self._tazer_zm_equipped = 1;
    self._bowie_zm_equipped = undefined;
    self._sickle_zm_equipped = undefined;
}

take_tazer()
{
    self._tazer_zm_equipped = undefined;
}

tazer_flourish_fx()
{
    self waittill( "weapon_change", newweapon );

    if ( newweapon == "zombie_tazer_flourish" )
    {
        self endon( "weapon_change" );
        wait( level.tazer_flourish_delay );
        self thread maps\mp\zombies\_zm_audio::playerexert( "hitmed" );
        self setclientfieldtoplayer( "tazer_flourish", 1 );
        wait_network_frame();
        self setclientfieldtoplayer( "tazer_flourish", 0 );
    }
}
