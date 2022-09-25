// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\killstreaks\_killstreak_weapons;
#include maps\mp\_scoreevents;

#using_animtree("mp_riotshield");

init()
{
    if ( !isdefined( level.riotshield_name ) )
    {
        level.riotshield_name = "riotshield_mp";

        if ( isdefined( level.is_zombie_level ) && level.is_zombie_level )
            level.riotshield_name = "riotshield_zm";
    }

    level.deployedshieldmodel = "t6_wpn_shield_carry_world";
    level.stowedshieldmodel = "t6_wpn_shield_stow_world";
    level.carriedshieldmodel = "t6_wpn_shield_carry_world";
    level.detectshieldmodel = "t6_wpn_shield_carry_world_detect";

    if ( isdefined( level.is_zombie_level ) && level.is_zombie_level )
    {
        level.deployedshieldmodel = "t6_wpn_zmb_shield_world";
        level.stowedshieldmodel = "t6_wpn_zmb_shield_stow";
        level.carriedshieldmodel = "t6_wpn_zmb_shield_world";
    }

    precachemodel( level.stowedshieldmodel );
    precachemodel( level.carriedshieldmodel );
    precachemodel( level.detectshieldmodel );
    level.riotshielddestroyanim = %o_riot_stand_destroyed;
    level.riotshielddeployanim = %o_riot_stand_deploy;
    level.riotshieldshotanimfront = %o_riot_stand_shot;
    level.riotshieldshotanimback = %o_riot_stand_shot_back;
    level.riotshieldmeleeanimfront = %o_riot_stand_melee_front;
    level.riotshieldmeleeanimback = %o_riot_stand_melee_back;
    loadfx( "weapon/riotshield/fx_riotshield_depoly_lights" );
    loadfx( "weapon/riotshield/fx_riotshield_depoly_dust" );
    level.riotshield_placement_zoffset = 26;
}

register()
{
    registerclientfield( "scriptmover", "riotshield_state", 1, 2, "int" );
}

watchpregameclasschange()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "track_riot_shield" );

    self waittill( "changed_class" );

    if ( level.ingraceperiod && !self.hasdonecombat )
    {
        self clearstowedweapon();
        self refreshshieldattachment();
        self thread trackriotshield();
    }
}

watchriotshieldpickup()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "track_riot_shield" );
    self notify( "watch_riotshield_pickup" );
    self endon( "watch_riotshield_pickup" );

    self waittill( "pickup_riotshield" );

    self endon( "weapon_change" );
/#
    println( "Picked up riotshield, expecting weapon_change notify..." );
#/
    wait 0.5;
/#
    println( "picked up shield but didn't change weapons, attach it!" );
#/
    self.hasriotshield = self hasweapon( level.riotshield_name );
    self.hasriotshieldequipped = self getcurrentweapon() == level.riotshield_name;
    self refreshshieldattachment();
}

trackriotshield()
{
    self endon( "death" );
    self endon( "disconnect" );
    self notify( "track_riot_shield" );
    self endon( "track_riot_shield" );
    self thread watchpregameclasschange();

    self waittill( "weapon_change", newweapon );

    self refreshshieldattachment();
    self.hasriotshield = self hasweapon( level.riotshield_name );
    self.hasriotshieldequipped = self getcurrentweapon() == level.riotshield_name;
    self.lastnonshieldweapon = "none";

    while ( true )
    {
        self thread watchriotshieldpickup();
        currentweapon = self getcurrentweapon();
        self.hasriotshield = self hasweapon( level.riotshield_name );
        self.hasriotshieldequipped = self getcurrentweapon() == level.riotshield_name;
        refresh_attach = 0;

        self waittill( "weapon_change", newweapon );

        if ( newweapon == level.riotshield_name )
        {
            refresh_attach = 1;

            if ( isdefined( self.riotshieldentity ) )
                self notify( "destroy_riotshield" );

            if ( self.hasriotshield )
            {
                if ( isdefined( self.riotshieldtakeweapon ) )
                {
                    self takeweapon( self.riotshieldtakeweapon );
                    self.riotshieldtakeweapon = undefined;
                }
            }

            if ( isvalidnonshieldweapon( currentweapon ) )
                self.lastnonshieldweapon = currentweapon;
        }

        if ( self.hasriotshield || refresh_attach == 1 )
            self refreshshieldattachment();
    }
}

isvalidnonshieldweapon( weapon )
{
    if ( maps\mp\killstreaks\_killstreaks::iskillstreakweapon( weapon ) )
        return false;

    if ( maps\mp\killstreaks\_killstreak_weapons::isheldkillstreakweapon( weapon ) )
        return false;

    if ( maps\mp\killstreaks\_killstreak_weapons::isgameplayweapon( weapon ) )
        return false;

    if ( weapon == "none" )
        return false;

    if ( isweaponequipment( weapon ) )
        return false;

    return true;
}

startriotshielddeploy()
{
    self notify( "start_riotshield_deploy" );
    self thread watchriotshielddeploy();
}

resetreconmodelvisibility( owner )
{
    if ( !isdefined( self ) )
        return;

    self setinvisibletoall();
    self setforcenocull();

    if ( !isdefined( owner ) )
        return;

    for ( i = 0; i < level.players.size; i++ )
    {
        if ( level.players[i] hasperk( "specialty_showenemyequipment" ) )
        {
            if ( level.players[i].team == "spectator" )
                continue;

            isenemy = 1;

            if ( level.teambased )
            {
                if ( level.players[i].team == owner.team )
                    isenemy = 0;
            }
            else if ( level.players[i] == owner )
                isenemy = 0;

            if ( isenemy )
                self setvisibletoplayer( level.players[i] );
        }
    }
}

resetreconmodelonevent( eventname, owner )
{
    self endon( "death" );

    for (;;)
    {
        level waittill( eventname, newowner );

        if ( isdefined( newowner ) )
            owner = newowner;

        self resetreconmodelvisibility( owner );
    }
}

attachreconmodel( modelname, owner )
{
    if ( !isdefined( self ) )
        return;

    reconmodel = spawn( "script_model", self.origin );
    reconmodel.angles = self.angles;
    reconmodel setmodel( modelname );
    reconmodel.model_name = modelname;
    reconmodel linkto( self );
    reconmodel setcontents( 0 );
    reconmodel resetreconmodelvisibility( owner );
    reconmodel thread resetreconmodelonevent( "joined_team", owner );
    reconmodel thread resetreconmodelonevent( "player_spawned", owner );
    self.reconmodel = reconmodel;
}

spawnriotshieldcover( origin, angles )
{
    shield_ent = spawn( "script_model", origin, 1 );
    shield_ent.targetname = "riotshield_mp";
    shield_ent.angles = angles;
    shield_ent setmodel( level.deployedshieldmodel );
    shield_ent setowner( self );
    shield_ent.owner = self;
    shield_ent.team = self.team;
    shield_ent setteam( self.team );
    shield_ent attachreconmodel( level.detectshieldmodel, self );
    shield_ent useanimtree( -1 );
    shield_ent setscriptmoverflag( 0 );
    shield_ent disconnectpaths();
    return shield_ent;
}

watchriotshielddeploy()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "start_riotshield_deploy" );

    self waittill( "deploy_riotshield", deploy_attempt );

    self setheldweaponmodel( 0 );
    self setplacementhint( 1 );
    placement_hint = 0;

    if ( deploy_attempt )
    {
        placement = self canplaceriotshield( "deploy_riotshield" );

        if ( placement["result"] )
        {
            self.hasdonecombat = 1;
            zoffset = level.riotshield_placement_zoffset;
            shield_ent = self spawnriotshieldcover( placement["origin"] + ( 0, 0, zoffset ), placement["angles"] );
            item_ent = deployriotshield( self, shield_ent );
            primaries = self getweaponslistprimaries();
/#
            assert( isdefined( item_ent ) );
            assert( !isdefined( self.riotshieldretrievetrigger ) );
            assert( !isdefined( self.riotshieldentity ) );

            if ( level.gametype != "shrp" )
                assert( primaries.size > 0 );
#/
            shield_ent setclientfield( "riotshield_state", 1 );
            shield_ent.reconmodel setclientfield( "riotshield_state", 1 );

            if ( level.gametype != "shrp" )
            {
                if ( self.lastnonshieldweapon != "none" && self hasweapon( self.lastnonshieldweapon ) )
                    self switchtoweapon( self.lastnonshieldweapon );
                else
                    self switchtoweapon( primaries[0] );
            }

            if ( !self hasweapon( "knife_held_mp" ) )
            {
                self giveweapon( "knife_held_mp" );
                self.riotshieldtakeweapon = "knife_held_mp";
            }

            self.riotshieldretrievetrigger = item_ent;
            self.riotshieldentity = shield_ent;
            self thread watchdeployedriotshieldents();
            self thread deleteshieldontriggerdeath( self.riotshieldretrievetrigger );
            self thread deleteshieldonplayerdeathordisconnect( shield_ent );
            self.riotshieldentity thread watchdeployedriotshielddamage();
            level notify( "riotshield_planted", self );
        }
        else
        {
            placement_hint = 1;
            clip_max_ammo = weaponclipsize( level.riotshield_name );
            self setweaponammoclip( level.riotshield_name, clip_max_ammo );
        }
    }
    else
        placement_hint = 1;

    if ( placement_hint )
        self setriotshieldfailhint();
}

riotshielddistancetest( origin )
{
    assert( isdefined( origin ) );
    min_dist_squared = getdvarfloat( "riotshield_deploy_limit_radius" );
    min_dist_squared *= min_dist_squared;

    for ( i = 0; i < level.players.size; i++ )
    {
        if ( isdefined( level.players[i].riotshieldentity ) )
        {
            dist_squared = distancesquared( level.players[i].riotshieldentity.origin, origin );

            if ( min_dist_squared > dist_squared )
            {
/#
                println( "Shield placement denied!  Failed distance check to other riotshields." );
#/
                return false;
            }
        }
    }

    return true;
}

watchdeployedriotshieldents()
{
/#
    assert( isdefined( self.riotshieldretrievetrigger ) );
    assert( isdefined( self.riotshieldentity ) );
#/
    self waittill( "destroy_riotshield" );

    if ( isdefined( self.riotshieldretrievetrigger ) )
        self.riotshieldretrievetrigger delete();

    if ( isdefined( self.riotshieldentity ) )
    {
        if ( isdefined( self.riotshieldentity.reconmodel ) )
            self.riotshieldentity.reconmodel delete();

        self.riotshieldentity connectpaths();
        self.riotshieldentity delete();
    }
}

watchdeployedriotshielddamage()
{
    self endon( "death" );
    damagemax = getdvarint( "riotshield_deployed_health" );
    self.damagetaken = 0;

    while ( true )
    {
        self.maxhealth = 100000;
        self.health = self.maxhealth;

        self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weaponname, idflags );

        if ( !isdefined( attacker ) )
            continue;

        assert( isdefined( self.owner ) && isdefined( self.owner.team ) );

        if ( isplayer( attacker ) )
        {
            if ( level.teambased && attacker.team == self.owner.team && attacker != self.owner )
                continue;
        }

        if ( type == "MOD_MELEE" )
            damage *= getdvarfloat( "riotshield_melee_damage_scale" );
        else if ( type == "MOD_PISTOL_BULLET" || type == "MOD_RIFLE_BULLET" )
            damage *= getdvarfloat( "riotshield_bullet_damage_scale" );
        else if ( type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH" || type == "MOD_EXPLOSIVE" || type == "MOD_EXPLOSIVE_SPLASH" || type == "MOD_PROJECTILE" || type == "MOD_PROJECTILE_SPLASH" )
            damage *= getdvarfloat( "riotshield_explosive_damage_scale" );
        else if ( type == "MOD_IMPACT" )
            damage *= getdvarfloat( "riotshield_projectile_damage_scale" );
        else if ( type == "MOD_CRUSH" )
            damage = damagemax;

        self.damagetaken += damage;

        if ( self.damagetaken >= damagemax )
        {
            self thread damagethendestroyriotshield( attacker, weaponname );
            break;
        }
    }
}

damagethendestroyriotshield( attacker, weaponname )
{
    self notify( "damageThenDestroyRiotshield" );
    self endon( "death" );

    if ( isdefined( self.owner.riotshieldretrievetrigger ) )
        self.owner.riotshieldretrievetrigger delete();

    if ( isdefined( self.reconmodel ) )
        self.reconmodel delete();

    self connectpaths();
    self.owner.riotshieldentity = undefined;
    self notsolid();
    self setclientfield( "riotshield_state", 2 );

    if ( isdefined( attacker ) && isdefined( weaponname ) && attacker != self.owner && isplayer( attacker ) )
        maps\mp\_scoreevents::processscoreevent( "destroyed_shield", attacker, self.owner, weaponname );

    wait( getdvarfloat( "riotshield_destroyed_cleanup_time" ) );
    self delete();
}

deleteshieldontriggerdeath( shield_trigger )
{
    shield_trigger waittill_any( "trigger", "death" );
    self notify( "destroy_riotshield" );
}

deleteshieldonplayerdeathordisconnect( shield_ent )
{
    shield_ent endon( "death" );
    shield_ent endon( "damageThenDestroyRiotshield" );
    self waittill_any( "death", "disconnect", "remove_planted_weapons" );
    shield_ent thread damagethendestroyriotshield();
}

watchriotshieldstuckentitydeath( grenade, owner )
{
    grenade endon( "death" );
    self waittill_any( "damageThenDestroyRiotshield", "death", "disconnect", "weapon_change", "deploy_riotshield" );
    grenade detonate( owner );
}
