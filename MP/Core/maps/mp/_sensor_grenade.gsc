// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\_hacker_tool;
#include maps\mp\killstreaks\_emp;
#include maps\mp\_challenges;
#include maps\mp\_scoreevents;
#include maps\mp\_utility;
#include maps\mp\gametypes\_globallogic_player;
#include maps\mp\gametypes\_damagefeedback;

init()
{
    level.isplayertrackedfunc = ::isplayertracked;
}

createsensorgrenadewatcher()
{
    watcher = self maps\mp\gametypes\_weaponobjects::createuseweaponobjectwatcher( "sensor_grenade", "sensor_grenade_mp", self.team );
    watcher.headicon = 0;
    watcher.onspawn = ::onspawnsensorgrenade;
    watcher.detonate = ::sensorgrenadedestroyed;
    watcher.stun = maps\mp\gametypes\_weaponobjects::weaponstun;
    watcher.stuntime = 0;
    watcher.reconmodel = "t6_wpn_motion_sensor_world_detect";
    watcher.ondamage = ::watchsensorgrenadedamage;
    watcher.enemydestroy = 1;
}

onspawnsensorgrenade( watcher, player )
{
    self endon( "death" );
    self thread maps\mp\gametypes\_weaponobjects::onspawnuseweaponobject( watcher, player );
    self setowner( player );
    self setteam( player.team );
    self.owner = player;
    self playloopsound( "fly_sensor_nade_lp" );
    self maps\mp\_hacker_tool::registerwithhackertool( level.equipmenthackertoolradius, level.equipmenthackertooltimems );
    player addweaponstat( "sensor_grenade_mp", "used", 1 );
    self thread watchforstationary( player );
    self thread watchforexplode( player );
}

watchforstationary( owner )
{
    self endon( "death" );
    self endon( "hacked" );
    self endon( "explode" );
    owner endon( "death" );
    owner endon( "disconnect" );

    self waittill( "stationary" );

    checkfortracking( self.origin );
}

watchforexplode( owner )
{
    self endon( "hacked" );
    self endon( "delete" );
    owner endon( "death" );
    owner endon( "disconnect" );

    self waittill( "explode", origin );

    checkfortracking( origin + ( 0, 0, 1 ) );
}

checkfortracking( origin )
{
    if ( isdefined( self.owner ) == 0 )
        return;

    players = level.players;

    foreach ( player in level.players )
    {
        if ( player isenemyplayer( self.owner ) )
        {
            if ( !player hasperk( "specialty_nomotionsensor" ) )
            {
                if ( distancesquared( player.origin, origin ) < 562500 )
                {
                    trace = bullettrace( origin, player.origin + vectorscale( ( 0, 0, 1 ), 12.0 ), 0, player );

                    if ( trace["fraction"] == 1 )
                        self.owner tracksensorgrenadevictim( player );
                }
            }
        }
    }
}

tracksensorgrenadevictim( victim )
{
    if ( !isdefined( self.sensorgrenadedata ) )
        self.sensorgrenadedata = [];

    if ( !isdefined( self.sensorgrenadedata[victim.clientid] ) )
        self.sensorgrenadedata[victim.clientid] = gettime();
}

isplayertracked( player, time )
{
    playertracked = 0;

    if ( isdefined( self.sensorgrenadedata ) && isdefined( self.sensorgrenadedata[player.clientid] ) )
    {
        if ( self.sensorgrenadedata[player.clientid] + 10000 > time )
            playertracked = 1;
    }

    return playertracked;
}

sensorgrenadedestroyed( attacker, weaponname )
{
    from_emp = maps\mp\killstreaks\_emp::isempweapon( weaponname );

    if ( !from_emp )
        playfx( level._equipment_explode_fx, self.origin );

    if ( isdefined( attacker ) )
    {
        if ( self.owner isenemyplayer( attacker ) )
        {
            attacker maps\mp\_challenges::destroyedequipment( weaponname );
            maps\mp\_scoreevents::processscoreevent( "destroyed_motion_sensor", attacker, self.owner, weaponname );
        }
    }

    playsoundatposition( "dst_equipment_destroy", self.origin );
    self delete();
}

watchsensorgrenadedamage( watcher )
{
    self endon( "death" );
    self endon( "hacked" );
    self setcandamage( 1 );
    damagemax = 1;

    if ( !self maps\mp\_utility::ishacked() )
        self.damagetaken = 0;

    while ( true )
    {
        self.maxhealth = 100000;
        self.health = self.maxhealth;

        self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname, idflags );

        if ( !isdefined( attacker ) || !isplayer( attacker ) )
            continue;

        if ( level.teambased && isplayer( attacker ) )
        {
            if ( !level.hardcoremode && self.owner.team == attacker.pers["team"] && self.owner != attacker )
                continue;
        }

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

        if ( type == "MOD_MELEE" )
            self.damagetaken = damagemax;
        else
            self.damagetaken += damage;

        if ( self.damagetaken >= damagemax )
        {
            watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( self, 0.0, attacker, weaponname );
            return;
        }
    }
}
