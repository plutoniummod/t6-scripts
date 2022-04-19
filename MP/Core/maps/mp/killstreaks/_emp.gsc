// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\killstreaks\_killstreakrules;
#include maps\mp\gametypes\_hostmigration;
#include maps\mp\gametypes\_weaponobjects;
#include maps\mp\_tacticalinsertion;
#include maps\mp\killstreaks\_emp;

init()
{
    level._effect["emp_flash"] = loadfx( "weapon/emp/fx_emp_explosion" );

    foreach ( team in level.teams )
        level.teamemping[team] = 0;

    level.empplayer = undefined;
    level.emptimeout = 40.0;
    level.empowners = [];

    if ( level.teambased )
        level thread emp_teamtracker();
    else
        level thread emp_playertracker();

    level thread onplayerconnect();
    registerkillstreak( "emp_mp", "emp_mp", "killstreak_emp", "emp_used", ::emp_use );
    registerkillstreakstrings( "emp_mp", &"KILLSTREAK_EARNED_EMP", &"KILLSTREAK_EMP_NOT_AVAILABLE", &"KILLSTREAK_EMP_INBOUND" );
    registerkillstreakdialog( "emp_mp", "mpl_killstreak_emp_activate", "kls_emp_used", "", "kls_emp_enemy", "", "kls_emp_ready" );
    registerkillstreakdevdvar( "emp_mp", "scr_giveemp" );
    maps\mp\killstreaks\_killstreaks::createkillstreaktimer( "emp_mp" );
/#
    set_dvar_float_if_unset( "scr_emp_timeout", 40.0 );
    set_dvar_int_if_unset( "scr_emp_damage_debug", 0 );
#/
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connected", player );

        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        if ( level.teambased && emp_isteamemped( self.team ) || !level.teambased && isdefined( level.empplayer ) && level.empplayer != self )
            self setempjammed( 1 );
    }
}

emp_isteamemped( check_team )
{
    foreach ( team in level.teams )
    {
        if ( team == check_team )
            continue;

        if ( level.teamemping[team] )
            return true;
    }

    return false;
}

emp_use( lifeid )
{
/#
    assert( isdefined( self ) );
#/
    killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart( "emp_mp", self.team, 0, 1 );

    if ( killstreak_id == -1 )
        return false;

    myteam = self.pers["team"];

    if ( level.teambased )
        self thread emp_jamotherteams( myteam, killstreak_id );
    else
        self thread emp_jamplayers( self, killstreak_id );

    self.emptime = gettime();
    self notify( "used_emp" );
    self playlocalsound( "mpl_killstreak_emp_activate" );
    self maps\mp\killstreaks\_killstreaks::playkillstreakstartdialog( "emp_mp", self.pers["team"] );
    level.globalkillstreakscalled++;
    self addweaponstat( "emp_mp", "used", 1 );
    return true;
}

emp_jamotherteams( teamname, killstreak_id )
{
    level endon( "game_ended" );
    overlays = [];
/#
    assert( isdefined( level.teams[teamname] ) );
#/
    level notify( "EMP_JamOtherTeams" + teamname );
    level endon( "EMP_JamOtherTeams" + teamname );
    level.empowners[teamname] = self;

    foreach ( player in level.players )
    {
        if ( player.team == teamname )
            continue;

        player playlocalsound( "mpl_killstreak_emp_blast_front" );
    }

    visionsetnaked( "flash_grenade", 1.5 );
    thread empeffects();
    wait 0.1;
    visionsetnaked( "flash_grenade", 0 );

    if ( isdefined( level.nukedetonated ) )
        visionsetnaked( level.nukevisionset, 5.0 );
    else
        visionsetnaked( getdvar( "mapname" ), 5.0 );

    level.teamemping[teamname] = 1;
    level notify( "emp_update" );
    level destroyotherteamsactivevehicles( self, teamname );
    level destroyotherteamsequipment( self, teamname );
/#
    level.emptimeout = getdvarfloat( "scr_emp_timeout" );
#/
    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpauseemp( level.emptimeout );
    level.teamemping[teamname] = 0;
    maps\mp\killstreaks\_killstreakrules::killstreakstop( "emp_mp", teamname, killstreak_id );
    level.empowners[teamname] = undefined;
    level notify( "emp_update" );
    level notify( "emp_end" + teamname );
}

emp_jamplayers( owner, killstreak_id )
{
    level notify( "EMP_JamPlayers" );
    level endon( "EMP_JamPlayers" );
    overlays = [];
/#
    assert( isdefined( owner ) );
#/
    foreach ( player in level.players )
    {
        if ( player == owner )
            continue;

        player playlocalsound( "mpl_killstreak_emp_blast_front" );
    }

    visionsetnaked( "flash_grenade", 1.5 );
    thread empeffects();
    wait 0.1;
    visionsetnaked( "flash_grenade", 0 );

    if ( isdefined( level.nukedetonated ) )
        visionsetnaked( level.nukevisionset, 5.0 );
    else
        visionsetnaked( getdvar( "mapname" ), 5.0 );

    level notify( "emp_update" );
    level.empplayer = owner;
    level.empplayer thread empplayerffadisconnect();
    level destroyactivevehicles( owner );
    level destroyequipment( owner );
    level notify( "emp_update" );
/#
    level.emptimeout = getdvarfloat( "scr_emp_timeout" );
#/
    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause( level.emptimeout );
    maps\mp\killstreaks\_killstreakrules::killstreakstop( "emp_mp", level.empplayer.team, killstreak_id );
    level.empplayer = undefined;
    level notify( "emp_update" );
    level notify( "emp_ended" );
}

empplayerffadisconnect()
{
    level endon( "EMP_JamPlayers" );
    level endon( "emp_ended" );

    self waittill( "disconnect" );

    level notify( "emp_update" );
}

empeffects()
{
    foreach ( player in level.players )
    {
        playerforward = anglestoforward( player.angles );
        playerforward = ( playerforward[0], playerforward[1], 0 );
        playerforward = vectornormalize( playerforward );
        empdistance = 20000;
        empent = spawn( "script_model", player.origin + vectorscale( ( 0, 0, 1 ), 8000.0 ) + playerforward * empdistance );
        empent setmodel( "tag_origin" );
        empent.angles += vectorscale( ( 1, 0, 0 ), 270.0 );
        empent thread empeffect( player );
    }
}

empeffect( player )
{
    player endon( "disconnect" );
    self setinvisibletoall();
    self setvisibletoplayer( player );
    wait 0.5;
    playfxontag( level._effect["emp_flash"], self, "tag_origin" );
    self playsound( "wpn_emp_bomb" );
    self deleteaftertime( 11 );
}

emp_teamtracker()
{
    level endon( "game_ended" );

    for (;;)
    {
        level waittill_either( "joined_team", "emp_update" );

        foreach ( player in level.players )
        {
            if ( player.team == "spectator" )
                continue;

            emped = emp_isteamemped( player.team );
            player setempjammed( emped );

            if ( emped )
                player notify( "emp_jammed" );
        }
    }
}

emp_playertracker()
{
    level endon( "game_ended" );

    for (;;)
    {
        level waittill_either( "joined_team", "emp_update" );

        foreach ( player in level.players )
        {
            if ( player.team == "spectator" )
                continue;

            if ( isdefined( level.empplayer ) && level.empplayer != player )
            {
                player setempjammed( 1 );
                player notify( "emp_jammed" );
                continue;
            }

            player setempjammed( 0 );
        }
    }
}

destroyotherteamsequipment( attacker, teamemping )
{
    foreach ( team in level.teams )
    {
        if ( team == teamemping )
            continue;

        destroyequipment( attacker, team );
        destroytacticalinsertions( attacker, team );
    }
}

destroyequipment( attacker, teamemped )
{
    for ( i = 0; i < level.missileentities.size; i++ )
    {
        item = level.missileentities[i];

        if ( !isdefined( item.name ) )
            continue;

        if ( !isdefined( item.owner ) )
            continue;

        if ( isdefined( teamemped ) && item.owner.team != teamemped )
            continue;
        else if ( item.owner == attacker )
            continue;

        if ( !isweaponequipment( item.name ) && item.name != "proximity_grenade_mp" )
            continue;

        watcher = item.owner getwatcherforweapon( item.name );

        if ( !isdefined( watcher ) )
            continue;

        watcher thread maps\mp\gametypes\_weaponobjects::waitanddetonate( item, 0.0, attacker, "emp_mp" );
    }
}

destroytacticalinsertions( attacker, victimteam )
{
    for ( i = 0; i < level.players.size; i++ )
    {
        player = level.players[i];

        if ( !isdefined( player.tacticalinsertion ) )
            continue;

        if ( level.teambased && player.team != victimteam )
            continue;

        if ( attacker == player )
            continue;

        player.tacticalinsertion thread maps\mp\_tacticalinsertion::fizzle();
    }
}

getwatcherforweapon( weapname )
{
    if ( !isdefined( self ) )
        return undefined;

    if ( !isplayer( self ) )
        return undefined;

    for ( i = 0; i < self.weaponobjectwatcherarray.size; i++ )
    {
        if ( self.weaponobjectwatcherarray[i].weapon != weapname )
            continue;

        return self.weaponobjectwatcherarray[i];
    }

    return undefined;
}

destroyotherteamsactivevehicles( attacker, teamemping )
{
    foreach ( team in level.teams )
    {
        if ( team == teamemping )
            continue;

        destroyactivevehicles( attacker, team );
    }
}

destroyactivevehicles( attacker, teamemped )
{
    turrets = getentarray( "auto_turret", "classname" );
    destroyentities( turrets, attacker, teamemped );
    targets = target_getarray();
    destroyentities( targets, attacker, teamemped );
    rcbombs = getentarray( "rcbomb", "targetname" );
    destroyentities( rcbombs, attacker, teamemped );
    remotemissiles = getentarray( "remote_missile", "targetname" );
    destroyentities( remotemissiles, attacker, teamemped );
    remotedrone = getentarray( "remote_drone", "targetname" );
    destroyentities( remotedrone, attacker, teamemped );
    planemortars = getentarray( "plane_mortar", "targetname" );

    foreach ( planemortar in planemortars )
    {
        if ( isdefined( teamemped ) && isdefined( planemortar.team ) )
        {
            if ( planemortar.team != teamemped )
                continue;
        }
        else if ( planemortar.owner == attacker )
            continue;

        planemortar notify( "emp_deployed", attacker );
    }

    satellites = getentarray( "satellite", "targetname" );

    foreach ( satellite in satellites )
    {
        if ( isdefined( teamemped ) && isdefined( satellite.team ) )
        {
            if ( satellite.team != teamemped )
                continue;
        }
        else if ( satellite.owner == attacker )
            continue;

        satellite notify( "emp_deployed", attacker );
    }

    if ( isdefined( level.missile_swarm_owner ) )
    {
        if ( level.missile_swarm_owner isenemyplayer( attacker ) )
            level.missile_swarm_owner notify( "emp_destroyed_missile_swarm", attacker );
    }
}

destroyentities( entities, attacker, team )
{
    meansofdeath = "MOD_EXPLOSIVE";
    weapon = "killstreak_emp_mp";
    damage = 5000;
    direction_vec = ( 0, 0, 0 );
    point = ( 0, 0, 0 );
    modelname = "";
    tagname = "";
    partname = "";

    foreach ( entity in entities )
    {
        if ( isdefined( team ) && isdefined( entity.team ) )
        {
            if ( entity.team != team )
                continue;
        }
        else if ( entity.owner == attacker )
            continue;

        entity notify( "damage", damage, attacker, direction_vec, point, meansofdeath, tagname, modelname, partname, weapon );
    }
}

drawempdamageorigin( pos, ang, radius )
{
/#
    while ( getdvarint( "scr_emp_damage_debug" ) )
    {
        line( pos, pos + anglestoforward( ang ) * radius, ( 1, 0, 0 ) );
        line( pos, pos + anglestoright( ang ) * radius, ( 0, 1, 0 ) );
        line( pos, pos + anglestoup( ang ) * radius, ( 0, 0, 1 ) );
        line( pos, pos - anglestoforward( ang ) * radius, ( 1, 0, 0 ) );
        line( pos, pos - anglestoright( ang ) * radius, ( 0, 1, 0 ) );
        line( pos, pos - anglestoup( ang ) * radius, ( 0, 0, 1 ) );
        wait 0.05;
    }
#/
}

isenemyempkillstreakactive()
{
    if ( level.teambased && maps\mp\killstreaks\_emp::emp_isteamemped( self.team ) || !level.teambased && isdefined( level.empplayer ) && level.empplayer != self )
        return true;

    return false;
}

isempweapon( weaponname )
{
    if ( isdefined( weaponname ) && ( weaponname == "emp_mp" || weaponname == "emp_grenade_mp" || weaponname == "emp_grenade_zm" ) )
        return true;

    return false;
}

isempkillstreakweapon( weaponname )
{
    if ( isdefined( weaponname ) && weaponname == "emp_mp" )
        return true;

    return false;
}
