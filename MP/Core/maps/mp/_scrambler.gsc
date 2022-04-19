// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\killstreaks\_emp;
#include maps\mp\_challenges;
#include maps\mp\gametypes\_globallogic_player;
#include maps\mp\gametypes\_damagefeedback;

init()
{
    level._effect["scrambler_enemy_light"] = loadfx( "misc/fx_equip_light_red" );
    level._effect["scrambler_friendly_light"] = loadfx( "misc/fx_equip_light_green" );
    level.scramblerweapon = "scrambler_mp";
    level.scramblerlength = 30.0;
    level.scramblerouterradiussq = 1000000;
    level.scramblerinnerradiussq = 360000;
}

createscramblerwatcher()
{
    watcher = self maps\mp\gametypes\_weaponobjects::createuseweaponobjectwatcher( "scrambler", "scrambler_mp", self.team );
    watcher.onspawn = ::onspawnscrambler;
    watcher.detonate = ::scramblerdetonate;
    watcher.stun = maps\mp\gametypes\_weaponobjects::weaponstun;
    watcher.stuntime = 5;
    watcher.reconmodel = "t5_weapon_scrambler_world_detect";
    watcher.hackable = 1;
    watcher.ondamage = ::watchscramblerdamage;
}

onspawnscrambler( watcher, player )
{
    player endon( "disconnect" );
    self endon( "death" );
    self thread maps\mp\gametypes\_weaponobjects::onspawnuseweaponobject( watcher, player );
    player.scrambler = self;
    self setowner( player );
    self setteam( player.team );
    self.owner = player;
    self setclientflag( 3 );

    if ( !self maps\mp\_utility::ishacked() )
        player addweaponstat( "scrambler_mp", "used", 1 );

    self thread watchshutdown( player );
    level notify( "scrambler_spawn" );
}

scramblerdetonate( attacker, weaponname )
{
    from_emp = maps\mp\killstreaks\_emp::isempweapon( weaponname );

    if ( !from_emp )
        playfx( level._equipment_explode_fx, self.origin );

    if ( self.owner isenemyplayer( attacker ) )
        attacker maps\mp\_challenges::destroyedequipment( weaponname );

    playsoundatposition( "dst_equipment_destroy", self.origin );
    self delete();
}

watchshutdown( player )
{
    self waittill_any( "death", "hacked" );
    level notify( "scrambler_death" );

    if ( isdefined( player ) )
        player.scrambler = undefined;
}

destroyent()
{
    self delete();
}

watchscramblerdamage( watcher )
{
    self endon( "death" );
    self endon( "hacked" );
    self setcandamage( 1 );
    damagemax = 100;

    if ( !self maps\mp\_utility::ishacked() )
        self.damagetaken = 0;

    while ( true )
    {
        self.maxhealth = 100000;
        self.health = self.maxhealth;

        self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname, idflags );

        if ( !isdefined( attacker ) || !isplayer( attacker ) )
            continue;

        if ( level.teambased && attacker.team == self.owner.team && attacker != self.owner )
            continue;

        if ( isdefined( weaponname ) )
        {
            switch ( weaponname )
            {
                case "flash_grenade_mp":
                case "concussion_grenade_mp":
                    if ( watcher.stuntime > 0 )
                        self thread maps\mp\gametypes\_weaponobjects::stunstart( watcher, watcher.stuntime );

                    if ( level.teambased && self.owner.team != attacker.team )
                    {
                        if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
                            attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();
                    }
                    else if ( !level.teambased && self.owner != attacker )
                    {
                        if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
                            attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();
                    }

                    continue;
                case "emp_grenade_mp":
                    damage = damagemax;
                default:
                    if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weaponname, attacker ) )
                        attacker maps\mp\gametypes\_damagefeedback::updatedamagefeedback();

                    break;
            }
        }
        else
            weaponname = "";

        if ( isplayer( attacker ) && level.teambased && isdefined( attacker.team ) && self.owner.team == attacker.team && attacker != self.owner )
            continue;

        if ( type == "MOD_MELEE" )
            self.damagetaken = damagemax;
        else
            self.damagetaken += damage;

        if ( self.damagetaken >= damagemax )
            watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0.0, attacker, weaponname );
    }
}

ownersameteam( owner1, owner2 )
{
    if ( !level.teambased )
        return 0;

    if ( !isdefined( owner1 ) || !isdefined( owner2 ) )
        return 0;

    if ( !isdefined( owner1.team ) || !isdefined( owner2.team ) )
        return 0;

    return owner1.team == owner2.team;
}

checkscramblerstun()
{
    scramblers = getentarray( "grenade", "classname" );

    if ( isdefined( self.name ) && self.name == "scrambler_mp" )
        return false;

    for ( i = 0; i < scramblers.size; i++ )
    {
        scrambler = scramblers[i];

        if ( !isalive( scrambler ) )
            continue;

        if ( !isdefined( scrambler.name ) )
            continue;

        if ( scrambler.name != "scrambler_mp" )
            continue;

        if ( ownersameteam( self.owner, scrambler.owner ) )
            continue;

        flattenedselforigin = ( self.origin[0], self.origin[1], 0 );
        flattenedscramblerorigin = ( scrambler.origin[0], scrambler.origin[1], 0 );

        if ( distancesquared( flattenedselforigin, flattenedscramblerorigin ) < level.scramblerouterradiussq )
            return true;
    }

    return false;
}
