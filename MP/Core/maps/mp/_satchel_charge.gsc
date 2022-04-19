// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\killstreaks\_emp;
#include maps\mp\_challenges;
#include maps\mp\_scoreevents;

init()
{
    level._effect["satchel_charge_enemy_light"] = loadfx( "weapon/c4/fx_c4_light_red" );
    level._effect["satchel_charge_friendly_light"] = loadfx( "weapon/c4/fx_c4_light_green" );
}

createsatchelwatcher()
{
    watcher = self maps\mp\gametypes\_weaponobjects::createuseweaponobjectwatcher( "satchel_charge", "satchel_charge_mp", self.team );
    watcher.altdetonate = 1;
    watcher.watchforfire = 1;
    watcher.hackable = 1;
    watcher.hackertoolradius = level.equipmenthackertoolradius;
    watcher.hackertooltimems = level.equipmenthackertooltimems;
    watcher.headicon = 1;
    watcher.detonate = ::satcheldetonate;
    watcher.stun = maps\mp\gametypes\_weaponobjects::weaponstun;
    watcher.stuntime = 1;
    watcher.altweapon = "satchel_charge_detonator_mp";
    watcher.reconmodel = "t6_wpn_c4_world_detect";
    watcher.ownergetsassist = 1;
}

satcheldetonate( attacker, weaponname )
{
    from_emp = maps\mp\killstreaks\_emp::isempkillstreakweapon( weaponname );

    if ( !isdefined( from_emp ) || !from_emp )
    {
        if ( isdefined( attacker ) )
        {
            if ( self.owner isenemyplayer( attacker ) )
            {
                attacker maps\mp\_challenges::destroyedexplosive( weaponname );
                maps\mp\_scoreevents::processscoreevent( "destroyed_c4", attacker, self.owner, weaponname );
            }
        }
    }

    maps\mp\gametypes\_weaponobjects::weapondetonate( attacker, weaponname );
}
