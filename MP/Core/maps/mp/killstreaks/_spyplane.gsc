// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\killstreaks\_airsupport;
#include maps\mp\gametypes\_battlechatter_mp;
#include maps\mp\gametypes\_spawnlogic;
#include maps\mp\killstreaks\_radar;
#include maps\mp\gametypes\_hostmigration;
#include maps\mp\_challenges;
#include maps\mp\killstreaks\_killstreakrules;
#include maps\mp\_heatseekingmissile;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\gametypes\_globallogic_player;
#include maps\mp\gametypes\_damagefeedback;
#include maps\mp\_popups;
#include maps\mp\gametypes\_globallogic_audio;
#include maps\mp\_scoreevents;

init()
{
    level.spyplanemodel = "veh_t6_drone_uav";
    level.counteruavmodel = "veh_t6_drone_cuav";
    level.u2_maxhealth = 700;
    level.spyplane = [];
    level.spyplaneentrancetime = 5;
    level.spyplaneexittime = 10;
    level.counteruavweapon = "counteruav_mp";
    level.counteruavlength = 25.0;
    precachemodel( level.spyplanemodel );
    precachemodel( level.counteruavmodel );
    level.counteruavplaneentrancetime = 5;
    level.counteruavplaneexittime = 10;
    level.counteruavlight = loadfx( "vehicle/light/fx_cuav_lights_red" );
    level.uavlight = loadfx( "vehicle/light/fx_u2_lights_red" );
    level.fx_spyplane_afterburner = loadfx( "vehicle/exhaust/fx_exhaust_u2_spyplane_afterburner" );
    level.fx_spyplane_burner = loadfx( "vehicle/exhaust/fx_exhaust_u2_spyplane_burner" );
    level.fx_cuav_afterburner = loadfx( "vehicle/exhaust/fx_exhaust_cuav_afterburner" );
    level.fx_cuav_burner = loadfx( "vehicle/exhaust/fx_exhaust_cuav_burner" );
    level.satelliteheight = 10000;
    level.satelliteflydistance = 10000;
    level.fx_u2_damage_trail = loadfx( "trail/fx_trail_u2_plane_damage_mp" );
    level.fx_u2_explode = loadfx( "vehicle/vexplosion/fx_vexplode_u2_exp_mp" );
    minimaporigins = getentarray( "minimap_corner", "targetname" );

    if ( minimaporigins.size )
        uavorigin = maps\mp\gametypes\_spawnlogic::findboxcenter( minimaporigins[0].origin, minimaporigins[1].origin );
    else
        uavorigin = ( 0, 0, 0 );

    if ( level.script == "mp_hydro" )
        uavorigin += vectorscale( ( 0, 1, 0 ), 1200.0 );

    if ( level.teambased )
    {
        foreach ( team in level.teams )
        {
            level.activeuavs[team] = 0;
            level.activecounteruavs[team] = 0;
            level.activesatellites[team] = 0;
        }
    }
    else
    {
        level.activeuavs = [];
        level.activecounteruavs = [];
        level.activesatellites = [];
    }

    level.uavrig = spawn( "script_model", uavorigin + vectorscale( ( 0, 0, 1 ), 1100.0 ) );
    level.uavrig setmodel( "tag_origin" );
    level.uavrig.angles = vectorscale( ( 0, 1, 0 ), 115.0 );
    level.uavrig hide();
    level.uavrig thread rotateuavrig( 1 );
    level.uavrig thread swayuavrig();
    level.counteruavrig = spawn( "script_model", uavorigin + vectorscale( ( 0, 0, 1 ), 1500.0 ) );
    level.counteruavrig setmodel( "tag_origin" );
    level.counteruavrig.angles = vectorscale( ( 0, 1, 0 ), 115.0 );
    level.counteruavrig hide();
    level.counteruavrig thread rotateuavrig( 0 );
    level.counteruavrig thread swayuavrig();
    level thread uavtracker();
    level thread onplayerconnect();
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connected", player );

        player.entnum = player getentitynumber();
        level.activeuavs[player.entnum] = 0;
        level.activecounteruavs[player.entnum] = 0;
        level.activesatellites[player.entnum] = 0;

        if ( level.teambased == 0 || level.multiteam == 1 )
            player thread watchffaandmultiteamspawn();
    }
}

watchffaandmultiteamspawn()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        level notify( "uav_update" );
    }
}

rotateuavrig( clockwise )
{
    turn = 360;

    if ( clockwise )
        turn = -360;

    for (;;)
    {
        if ( !clockwise )
        {
            self rotateyaw( turn, 40 );
            wait 40;
            continue;
        }

        self rotateyaw( turn, 60 );
        wait 60;
    }
}

swayuavrig()
{
    centerorigin = self.origin;

    for (;;)
    {
        z = randomintrange( -200, -100 );
        time = randomintrange( 3, 6 );
        self moveto( centerorigin + ( 0, 0, z ), time, 1, 1 );
        wait( time );
        z = randomintrange( 100, 200 );
        time = randomintrange( 3, 6 );
        self moveto( centerorigin + ( 0, 0, z ), time, 1, 1 );
        wait( time );
    }
}

callcounteruav( type, displaymessage, killstreak_id )
{
    timeinair = self maps\mp\killstreaks\_radar::useradaritem( type, self.team, displaymessage );
    iscounter = 1;
    counteruavplane = generateplane( self, timeinair, iscounter );

    if ( !isdefined( counteruavplane ) )
        return false;

    counteruavplane thread counteruav_watchfor_gamerules_destruction( self );
    counteruavplane setclientflag( 11 );
    counteruavplane addactivecounteruav();
    self.counteruavtime = gettime();
    counteruavplane thread playcounterspyplanefx();
    counteruavplane thread counteruavplane_death_waiter();
    counteruavplane thread counteruavplane_timeout( timeinair, self );
    counteruavplane thread plane_damage_monitor( 0 );
    counteruavplane thread plane_health();
    counteruavplane.killstreak_id = killstreak_id;
    counteruavplane.iscounter = 1;
    counteruavplane playloopsound( "veh_uav_engine_loop", 1 );
    return true;
}

callspyplane( type, displaymessage, killstreak_id )
{
    timeinair = self maps\mp\killstreaks\_radar::useradaritem( type, self.team, displaymessage );
    iscounter = 0;
    spyplane = generateplane( self, timeinair, iscounter );

    if ( !isdefined( spyplane ) )
        return false;

    spyplane thread spyplane_watchfor_gamerules_destruction( self );
    spyplane addactiveuav();
    self.uavtime = gettime();
    spyplane.leaving = 0;
    spyplane thread playspyplanefx();
    spyplane thread spyplane_timeout( timeinair, self );
    spyplane thread spyplane_death_waiter();
    spyplane thread plane_damage_monitor( 1 );
    spyplane thread plane_health();
    spyplane.killstreak_id = killstreak_id;
    spyplane.iscounter = 0;
    spyplane playloopsound( "veh_uav_engine_loop", 1 );
    return true;
}

callsatellite( type, displaymessage, killstreak_id )
{
    timeinair = self maps\mp\killstreaks\_radar::useradaritem( type, self.team, displaymessage );
    satellite = spawn( "script_model", level.mapcenter + ( 0 - level.satelliteflydistance, 0, level.satelliteheight ) );
    satellite setmodel( "tag_origin" );
    satellite moveto( level.mapcenter + ( level.satelliteflydistance, 0, level.satelliteheight ), timeinair );
    satellite.owner = self;
    satellite.team = self.team;
    satellite setteam( self.team );
    satellite setowner( self );
    satellite.targetname = "satellite";
    satellite addactivesatellite();
    self.satellitetime = gettime();
    satellite thread satellite_timeout( timeinair, self );
    satellite thread satellite_watchfor_gamerules_destruction( self );
    satellite.iscounter = 0;

    if ( level.teambased )
        satellite thread updatevisibility();

    satellite.killstreak_id = killstreak_id;
    return 1;
}

spyplane_watchfor_gamerules_destruction( player )
{
    self endon( "death" );
    self endon( "crashing" );
    self endon( "delete" );
    player waittill_any( "joined_team", "disconnect", "joined_spectators" );
    self spyplane_death();
}

counteruav_watchfor_gamerules_destruction( player )
{
    self endon( "death" );
    self endon( "crashing" );
    self endon( "delete" );
    player waittill_any( "joined_team", "disconnect", "joined_spectators" );
    maps\mp\gametypes\_hostmigration::waittillhostmigrationdone();
    self counteruavplane_death();
}

satellite_watchfor_gamerules_destruction( player )
{
    self endon( "death" );
    self endon( "delete" );
    player waittill_any( "joined_team", "disconnect", "joined_spectators" );
    maps\mp\gametypes\_hostmigration::waittillhostmigrationdone();
    self removeactivesatellite();
    self delete();
}

addactivecounteruav()
{
    if ( level.teambased )
    {
        self.owner.activecounteruavs++;
        level.activecounteruavs[self.team]++;

        foreach ( team in level.teams )
        {
            if ( team == self.team )
                continue;

            if ( level.activesatellites[team] > 0 )
                self.owner maps\mp\_challenges::blockedsatellite();
        }
    }
    else
    {
/#
        assert( isdefined( self.owner.entnum ) );
#/
        if ( !isdefined( self.owner.entnum ) )
            self.owner.entnum = self.owner getentitynumber();

        level.activecounteruavs[self.owner.entnum]++;
        keys = getarraykeys( level.activecounteruavs );

        for ( i = 0; i < keys.size; i++ )
        {
            if ( keys[i] == self.owner.entnum )
                continue;

            if ( level.activecounteruavs[keys[i]] )
            {
                self.owner maps\mp\_challenges::blockedsatellite();
                break;
            }
        }
    }

    level notify( "uav_update" );
}

addactiveuav()
{
    if ( level.teambased )
    {
        self.owner.activeuavs++;
        level.activeuavs[self.team]++;
    }
    else
    {
/#
        assert( isdefined( self.owner.entnum ) );
#/
        if ( !isdefined( self.owner.entnum ) )
            self.owner.entnum = self.owner getentitynumber();

        level.activeuavs[self.owner.entnum]++;
    }

    level notify( "uav_update" );
}

addactivesatellite()
{
    if ( level.teambased )
    {
        self.owner.activesatellites++;
        level.activesatellites[self.team]++;
    }
    else
    {
/#
        assert( isdefined( self.owner.entnum ) );
#/
        if ( !isdefined( self.owner.entnum ) )
            self.owner.entnum = self.owner getentitynumber();

        level.activesatellites[self.owner.entnum]++;
    }

    level notify( "uav_update" );
}

removeactiveuav()
{
    if ( level.teambased )
    {
        if ( isdefined( self.owner ) && self.owner.spawntime < self.birthtime )
        {
            self.owner.activeuavs--;
/#
            assert( self.owner.activeuavs >= 0 );
#/
            if ( self.owner.activeuavs < 0 )
                self.owner.activeuavs = 0;
        }

        level.activeuavs[self.team]--;
/#
        assert( level.activeuavs[self.team] >= 0 );
#/
        if ( level.activeuavs[self.team] < 0 )
            level.activeuavs[self.team] = 0;
    }
    else if ( isdefined( self.owner ) )
    {
/#
        assert( isdefined( self.owner.entnum ) );
#/
        if ( !isdefined( self.owner.entnum ) )
            self.owner.entnum = self.owner getentitynumber();

        level.activeuavs[self.owner.entnum]--;
/#
        assert( level.activeuavs[self.owner.entnum] >= 0 );
#/
        if ( level.activeuavs[self.owner.entnum] < 0 )
            level.activeuavs[self.owner.entnum] = 0;
    }

    maps\mp\killstreaks\_killstreakrules::killstreakstop( "radar_mp", self.team, self.killstreak_id );
    level notify( "uav_update" );
}

removeactivecounteruav()
{
    if ( level.teambased )
    {
        if ( isdefined( self.owner ) && self.owner.spawntime < self.birthtime )
        {
            self.owner.activecounteruavs--;
/#
            assert( self.owner.activecounteruavs >= 0 );
#/
            if ( self.owner.activecounteruavs < 0 )
                self.owner.activecounteruavs = 0;
        }

        level.activecounteruavs[self.team]--;
/#
        assert( level.activecounteruavs[self.team] >= 0 );
#/
        if ( level.activecounteruavs[self.team] < 0 )
            level.activecounteruavs[self.team] = 0;
    }
    else if ( isdefined( self.owner ) )
    {
/#
        assert( isdefined( self.owner.entnum ) );
#/
        if ( !isdefined( self.owner.entnum ) )
            self.owner.entnum = self.owner getentitynumber();

        level.activecounteruavs[self.owner.entnum]--;
/#
        assert( level.activecounteruavs[self.owner.entnum] >= 0 );
#/
        if ( level.activecounteruavs[self.owner.entnum] < 0 )
            level.activecounteruavs[self.owner.entnum] = 0;
    }

    maps\mp\killstreaks\_killstreakrules::killstreakstop( "counteruav_mp", self.team, self.killstreak_id );
    level notify( "uav_update" );
}

removeactivesatellite()
{
    if ( level.teambased )
    {
        if ( self.owner.spawntime < self.birthtime && isdefined( self.owner ) )
        {
            self.owner.activesatellites--;
/#
            assert( self.owner.activesatellites >= 0 );
#/
            if ( self.owner.activesatellites < 0 )
                self.owner.activesatellites = 0;
        }

        level.activesatellites[self.team]--;
/#
        assert( level.activesatellites[self.team] >= 0 );
#/
        if ( level.activesatellites[self.team] < 0 )
            level.activesatellites[self.team] = 0;
    }
    else if ( isdefined( self.owner ) )
    {
/#
        assert( isdefined( self.owner.entnum ) );
#/
        if ( !isdefined( self.owner.entnum ) )
            self.owner.entnum = self.owner getentitynumber();

        level.activesatellites[self.owner.entnum]--;
/#
        assert( level.activesatellites[self.owner.entnum] >= 0 );
#/
        if ( level.activesatellites[self.owner.entnum] < 0 )
            level.activesatellites[self.owner.entnum] = 0;
    }

    maps\mp\killstreaks\_killstreakrules::killstreakstop( "radardirection_mp", self.team, self.killstreak_id );
    level notify( "uav_update" );
}

playspyplanefx()
{
    wait 0.1;
    playfxontag( level.fx_spyplane_burner, self, "tag_origin" );
}

playspyplaneafterburnerfx()
{
    self endon( "death" );
    wait 0.1;
    playfxontag( level.fx_spyplane_afterburner, self, "tag_origin" );
}

playcounterspyplanefx()
{
    wait 0.1;

    if ( isdefined( self ) )
        playfxontag( level.fx_cuav_burner, self, "tag_origin" );
}

playcounterspyplaneafterburnerfx()
{
    self endon( "death" );
    wait 0.1;
    playfxontag( level.fx_cuav_afterburner, self, "tag_origin" );
}

playuavpilotdialog( dialog, owner, delaytime )
{
    if ( isdefined( delaytime ) )
        wait( delaytime );

    self.pilotvoicenumber = owner.bcvoicenumber + 1;
    soundalias = level.teamprefix[owner.team] + self.pilotvoicenumber + "_" + dialog;

    if ( isdefined( owner.pilotisspeaking ) )
    {
        if ( owner.pilotisspeaking )
        {
            while ( owner.pilotisspeaking )
                wait 0.2;
        }
    }

    if ( isdefined( owner ) )
    {
        owner playlocalsound( soundalias );
        owner.pilotisspeaking = 1;
        owner thread waitplaybacktime( soundalias );
        owner waittill_any( soundalias, "death", "disconnect" );
        owner.pilotisspeaking = 0;
    }
}

generateplane( owner, timeinair, iscounter )
{
    uavrig = level.uavrig;
    attach_angle = -90;

    if ( iscounter )
    {
        uavrig = level.counteruavrig;
        attach_angle = 90;
    }

    plane = spawn( "script_model", uavrig gettagorigin( "tag_origin" ) );

    if ( iscounter )
    {
        plane setmodel( level.counteruavmodel );
        plane.targetname = "counteruav";
    }
    else
    {
        plane setmodel( level.spyplanemodel );
        plane.targetname = "uav";
    }

    plane setteam( owner.team );
    plane setowner( owner );
    target_set( plane );
    plane thread play_light_fx( iscounter );
    plane.owner = owner;
    plane.team = owner.team;
    plane thread updatevisibility();
    plane thread maps\mp\_heatseekingmissile::missiletarget_proximitydetonateincomingmissile( "crashing" );
    level.plane[self.team] = plane;
    plane.health_low = level.u2_maxhealth * 0.4;
    plane.maxhealth = level.u2_maxhealth;
    plane.health = 99999;
    plane.rocketdamageoneshot = level.u2_maxhealth + 1;
    plane.rocketdamagetwoshot = level.u2_maxhealth / 2 + 1;
    plane setdrawinfrared( 1 );
    zoffset = randomintrange( 4000, 5000 );
    angle = randomint( 360 );

    if ( iscounter )
        radiusoffset = randomint( 1000 ) + 3000;
    else
        radiusoffset = randomint( 1000 ) + 4000;

    xoffset = cos( angle ) * radiusoffset;
    yoffset = sin( angle ) * radiusoffset;
    anglevector = vectornormalize( ( xoffset, yoffset, zoffset ) );
    anglevector *= randomintrange( 4000, 5000 );

    if ( iscounter )
        plane linkto( uavrig, "tag_origin", anglevector, ( 0, angle + attach_angle, -10 ) );
    else
        plane linkto( uavrig, "tag_origin", anglevector, ( 0, angle + attach_angle, 0 ) );

    return plane;
}

play_light_fx( iscounter )
{
    self endon( "death" );
    wait 0.1;

    if ( iscounter )
        playfxontag( level.counteruavlight, self, "tag_origin" );
    else
        playfxontag( level.uavlight, self, "tag_origin" );
}

updatevisibility()
{
    self endon( "death" );

    for (;;)
    {
        if ( level.teambased )
            self setvisibletoallexceptteam( self.team );
        else
        {
            self setvisibletoall();
            self setinvisibletoplayer( self.owner );
        }

        level waittill( "joined_team" );
    }
}

debugline( frompoint, topoint, color, durationframes )
{
/#
    for ( i = 0; i < durationframes * 20; i++ )
    {
        line( frompoint, topoint, color );
        wait 0.05;
    }
#/
}

plane_damage_monitor( isspyplane )
{
    self endon( "death" );
    self endon( "crashing" );
    self endon( "delete" );
    self setcandamage( 1 );
    self.damagetaken = 0;

    for (;;)
    {
        self waittill( "damage", damage, attacker, direction, point, type, tagname, modelname, partname, weapon );

        if ( !isdefined( attacker ) || !isplayer( attacker ) )
            continue;

        friendlyfire = maps\mp\gametypes\_weaponobjects::friendlyfirecheck( self.owner, attacker );

        if ( !friendlyfire )
            continue;

        if ( isdefined( self.owner ) && attacker == self.owner )
            continue;

        isvalidattacker = 1;

        if ( level.teambased )
            isvalidattacker = isdefined( attacker.team ) && attacker.team != self.team;

        if ( !isvalidattacker )
            continue;

        if ( maps\mp\gametypes\_globallogic_player::dodamagefeedback( weapon, attacker ) )
            attacker thread maps\mp\gametypes\_damagefeedback::updatedamagefeedback( type );

        self.attacker = attacker;

        switch ( type )
        {
            case "MOD_RIFLE_BULLET":
            case "MOD_PISTOL_BULLET":
                if ( attacker hasperk( "specialty_armorpiercing" ) )
                    self.damagetaken += int( damage * level.cac_armorpiercing_data );
                else
                    self.damagetaken += damage;

                break;
            case "MOD_PROJECTILE":
                self.damagetaken += self.rocketdamageoneshot;
                break;
            default:
                self.damagetaken += damage;
                break;
        }

        self.health += damage;

        if ( self.damagetaken > self.maxhealth )
        {
            killstreakreference = "radar_mp";

            if ( !isspyplane )
                killstreakreference = "counteruav_mp";

            attacker notify( "destroyed_spyplane" );
            weaponstatname = "destroyed";

            switch ( weapon )
            {
                case "tow_turret_mp":
                case "tow_turret_drop_mp":
                case "auto_tow_mp":
                    weaponstatname = "kills";
                    break;
            }

            attacker addweaponstat( weapon, weaponstatname, 1 );
            level.globalkillstreaksdestroyed++;
            attacker addweaponstat( killstreakreference, "destroyed", 1 );
            maps\mp\_challenges::destroyedaircraft( attacker, weapon );

            if ( isspyplane )
            {
                level thread maps\mp\_popups::displayteammessagetoall( &"KILLSTREAK_DESTROYED_UAV", attacker );

                if ( isdefined( self.owner ) )
                    self.owner maps\mp\gametypes\_globallogic_audio::leaderdialogonplayer( "uav_destroyed", "item_destroyed" );

                if ( !isdefined( self.owner ) || self.owner isenemyplayer( attacker ) )
                {
                    thread maps\mp\_scoreevents::processscoreevent( "destroyed_uav", attacker, self.owner, weapon );
                    attacker maps\mp\_challenges::addflyswatterstat( weapon, self );
                }
                else
                {

                }

                spyplane_death();
            }
            else
            {
                level thread maps\mp\_popups::displayteammessagetoall( &"KILLSTREAK_DESTROYED_COUNTERUAV", attacker );

                if ( isdefined( self.owner ) )
                    self.owner maps\mp\gametypes\_globallogic_audio::leaderdialogonplayer( "cuav_destroyed", "item_destroyed" );

                if ( !isdefined( self.owner ) || self.owner isenemyplayer( attacker ) )
                {
                    thread maps\mp\_scoreevents::processscoreevent( "destroyed_counter_uav", attacker, self.owner, weapon );
                    attacker maps\mp\_challenges::addflyswatterstat( weapon, self );
                }
                else
                {

                }

                counteruavplane_death();
            }

            return;
        }
    }
}

plane_health()
{
    self endon( "death" );
    self endon( "crashing" );
    self.currentstate = "ok";
    self.laststate = "ok";

    while ( self.currentstate != "leaving" )
    {
        if ( self.damagetaken >= self.health_low )
            self.currentstate = "damaged";

        if ( self.currentstate == "damaged" && self.laststate != "damaged" )
        {
            self.laststate = self.currentstate;
            self thread playdamagefx();
        }
/#
        debug_print3d_simple( "Health: " + self.maxhealth - self.damagetaken, self, vectorscale( ( 0, 0, 1 ), 100.0 ), 20 );
#/
        wait 1;
    }
}

playdamagefx()
{
    self endon( "death" );
    self endon( "crashing" );
    playfxontag( level.fx_u2_damage_trail, self, "tag_body" );
}

u2_crash()
{
    self notify( "crashing" );
    playfxontag( level.fx_u2_explode, self, "tag_origin" );
    wait 0.1;
    self setmodel( "tag_origin" );
    wait 0.2;
    self notify( "delete" );
    self delete();
}

counteruavplane_death_waiter()
{
    self endon( "delete" );
    self endon( "leaving" );

    self waittill( "death" );

    counteruavplane_death();
}

spyplane_death_waiter()
{
    self endon( "delete" );
    self endon( "leaving" );

    self waittill( "death" );

    spyplane_death();
}

counteruavplane_death()
{
    self clearclientflag( 11 );
    self playsound( "evt_helicopter_midair_exp" );
    self removeactivecounteruav();
    target_remove( self );
    self thread u2_crash();
}

spyplane_death()
{
    self playsound( "evt_helicopter_midair_exp" );

    if ( !self.leaving )
        self removeactiveuav();

    target_remove( self );
    self thread u2_crash();
}

counteruavplane_timeout( timeinair, owner )
{
    self endon( "death" );
    self endon( "delete" );
    maps\mp\gametypes\_hostmigration::waittillhostmigrationdone();
    timeremaining = timeinair * 1000;
    self waittilltimeoutmigrationaware( timeremaining, owner );
    self clearclientflag( 11 );
    self plane_leave();
    wait( level.counteruavplaneexittime );
    self removeactivecounteruav();
    target_remove( self );
    self delete();
}

satellite_timeout( timeinair, owner )
{
    self endon( "death" );
    self endon( "delete" );
    maps\mp\gametypes\_hostmigration::waittillhostmigrationdone();
    timeremaining = timeinair * 1000;
    self waittilltimeoutmigrationaware( timeremaining, owner );
    self removeactivesatellite();
    self delete();
}

watchforemp()
{
    self endon( "death" );
    self endon( "delete" );

    self waittill( "emp_deployed", attacker );

    weapon = "emp_mp";
    maps\mp\_challenges::destroyedaircraft( attacker, weapon );
    thread maps\mp\_scoreevents::processscoreevent( "destroyed_satellite", attacker, self.owner, weapon );
    attacker maps\mp\_challenges::addflyswatterstat( weapon, self );
    self removeactivesatellite();
    self delete();
}

spyplane_timeout( timeinair, owner )
{
    self endon( "death" );
    self endon( "delete" );
    self endon( "crashing" );
    maps\mp\gametypes\_hostmigration::waittillhostmigrationdone();
    timeremaining = timeinair * 1000;
    self waittilltimeoutmigrationaware( timeremaining, owner );
    self plane_leave();
    self.leaving = 1;
    self removeactiveuav();
    wait( level.spyplaneexittime );
    target_remove( self );
    self delete();
}

waittilltimeoutmigrationaware( timeremaining, owner )
{
    owner endon( "disconnect" );

    for (;;)
    {
        self.endtime = gettime() + timeremaining;
        event = level waittill_any_timeout( timeremaining / 1000, "game_ended", "host_migration_begin" );

        if ( event != "host_migration_begin" )
            break;

        timeremaining = self.endtime - gettime();

        if ( timeremaining <= 0 )
            break;

        maps\mp\gametypes\_hostmigration::waittillhostmigrationdone();
    }
}

planestoploop( time )
{
    self endon( "death" );
    wait( time );
    self stoploopsound();
}

plane_leave()
{
    self unlink();

    if ( isdefined( self.iscounter ) && self.iscounter )
    {
        self thread playcounterspyplaneafterburnerfx();
        self playsound( "veh_kls_uav_afterburner" );
        self thread play_light_fx( 1 );
        self thread planestoploop( 1 );
    }
    else
    {
        self thread playspyplaneafterburnerfx();
        self playsound( "veh_kls_spy_afterburner" );
        self thread play_light_fx( 0 );
        self thread planestoploop( 1 );
    }

    self.currentstate = "leaving";

    if ( self.laststate == "damaged" )
        playfxontag( level.fx_u2_damage_trail, self, "tag_body" );

    mult = getdvarintdefault( "scr_spymult", 20000 );
    tries = 10;
    yaw = 0;

    while ( tries > 0 )
    {
        exitvector = anglestoforward( self.angles + ( 0, yaw, 0 ) ) * 20000;

        if ( isdefined( self.iscounter ) && self.iscounter )
        {
            self thread playcounterspyplanefx();
            exitvector *= 1.0;
        }

        exitpoint = ( self.origin[0] + exitvector[0], self.origin[1] + exitvector[1], self.origin[2] - 2500 );
        exitpoint = self.origin + exitvector;
        nfz = crossesnoflyzone( self.origin, exitpoint );

        if ( isdefined( nfz ) )
        {
            if ( tries != 1 )
            {
                if ( tries % 2 == 1 )
                    yaw *= -1;
                else
                {
                    yaw += 10;
                    yaw *= -1;
                }
            }

            tries--;
        }
        else
            tries = 0;
    }

    self thread flattenyaw( self.angles[1] + yaw );

    if ( self.angles[2] != 0 )
        self thread flattenroll();

    self moveto( exitpoint, level.spyplaneexittime, 0, 0 );
    self notify( "leaving" );
}

flattenroll()
{
    self endon( "death" );

    while ( self.angles[2] < 0 )
    {
        self.angles = ( self.angles[0], self.angles[1], self.angles[2] + 2.5 );
        wait 0.05;
    }
}

flattenyaw( goal )
{
    self endon( "death" );
    increment = 3;

    if ( self.angles[1] > goal )
        increment *= -1;

    while ( abs( self.angles[1] - goal ) > 3 )
    {
        self.angles = ( self.angles[0], self.angles[1] + increment, self.angles[2] );
        wait 0.05;
    }
}

uavtracker()
{
    level endon( "game_ended" );

    for (;;)
    {
        level waittill( "uav_update" );

        if ( level.teambased )
        {
            foreach ( team in level.teams )
                updateteamuavstatus( team );

            continue;
        }

        updateplayersuavstatus();
    }
}

updateteamuavstatus( team )
{
    activeuavs = level.activeuavs[team];
    activesatellites = level.activesatellites[team];
    radarmode = 1;

    if ( activesatellites > 0 )
    {
        maps\mp\killstreaks\_radar::setteamspyplanewrapper( team, 0 );
        maps\mp\killstreaks\_radar::setteamsatellitewrapper( team, 1 );
        return;
    }

    maps\mp\killstreaks\_radar::setteamsatellitewrapper( team, 0 );

    if ( !activeuavs )
    {
        maps\mp\killstreaks\_radar::setteamspyplanewrapper( team, 0 );
        return;
    }

    if ( activeuavs > 1 )
        radarmode = 2;

    maps\mp\killstreaks\_radar::setteamspyplanewrapper( team, radarmode );
}

updateplayersuavstatus()
{
    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];
/#
        assert( isdefined( player.entnum ) );
#/
        if ( !isdefined( player.entnum ) )
            player.entnum = player getentitynumber();

        activeuavs = level.activeuavs[player.entnum];
        activesatellites = level.activesatellites[player.entnum];

        if ( activesatellites > 0 )
        {
            player.hassatellite = 1;
            player.hasspyplane = 0;
            player setclientuivisibilityflag( "radar_client", 1 );
            continue;
        }

        player.hassatellite = 0;

        if ( activeuavs == 0 && !( isdefined( player.pers["hasRadar"] ) && player.pers["hasRadar"] ) )
        {
            player.hasspyplane = 0;
            player setclientuivisibilityflag( "radar_client", 0 );
            continue;
        }

        if ( activeuavs > 1 )
            spyplaneupdatespeed = 2;
        else
            spyplaneupdatespeed = 1;

        player setclientuivisibilityflag( "radar_client", 1 );
        player.hasspyplane = spyplaneupdatespeed;
    }
}
