// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\zombies\_zm_weapons;

init()
{
    if ( isdefined( level.bowie_cost ) )
        cost = level.bowie_cost;
    else
        cost = 3000;

    maps\mp\zombies\_zm_melee_weapon::init( "bowie_knife_zm", "zombie_bowie_flourish", "knife_ballistic_bowie_zm", "knife_ballistic_bowie_upgraded_zm", cost, "bowie_upgrade", &"ZOMBIE_WEAPON_BOWIE_BUY", "bowie", ::has_bowie, ::give_bowie, ::take_bowie, ::bowie_flourish );
    maps\mp\zombies\_zm_weapons::add_retrievable_knife_init_name( "knife_ballistic_bowie" );
    maps\mp\zombies\_zm_weapons::add_retrievable_knife_init_name( "knife_ballistic_bowie_upgraded" );
}

spectator_respawn()
{
    maps\mp\zombies\_zm_melee_weapon::spectator_respawn( "bowie_upgrade", ::take_bowie, ::has_bowie );
}

has_bowie()
{
    if ( is_true( level._allow_melee_weapon_switching ) )
        return false;

    if ( is_true( self._sickle_zm_equipped ) || is_true( self._bowie_zm_equipped ) || is_true( self._tazer_zm_equipped ) )
        return true;

    return false;
}

give_bowie()
{
    self._bowie_zm_equipped = 1;
    self._sickle_zm_equipped = undefined;
    self._tazer_zm_equipped = undefined;
}

take_bowie()
{
    self._bowie_zm_equipped = undefined;
}

bowie_flourish()
{

}
