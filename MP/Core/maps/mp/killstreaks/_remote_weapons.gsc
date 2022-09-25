// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\killstreaks\_turret_killstreak;
#include maps\mp\killstreaks\_ai_tank;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\gametypes\_hud;

init()
{
    level.remoteweapons = [];
    level.remoteweapons["killstreak_remote_turret_mp"] = spawnstruct();
    level.remoteweapons["killstreak_remote_turret_mp"].hintstring = &"MP_REMOTE_USE_TURRET";
    level.remoteweapons["killstreak_remote_turret_mp"].usecallback = maps\mp\killstreaks\_turret_killstreak::startturretremotecontrol;
    level.remoteweapons["killstreak_remote_turret_mp"].endusecallback = maps\mp\killstreaks\_turret_killstreak::endremoteturret;
    level.remoteweapons["killstreak_ai_tank_mp"] = spawnstruct();
    level.remoteweapons["killstreak_ai_tank_mp"].hintstring = &"MP_REMOTE_USE_TANK";
    level.remoteweapons["killstreak_ai_tank_mp"].usecallback = maps\mp\killstreaks\_ai_tank::starttankremotecontrol;
    level.remoteweapons["killstreak_ai_tank_mp"].endusecallback = maps\mp\killstreaks\_ai_tank::endtankremotecontrol;
    level.remoteexithint = &"MP_REMOTE_EXIT";
    level thread onplayerconnect();
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

        if ( isdefined( self.remotecontroltrigger ) )
        {
            self.remotecontroltrigger.origin = self.origin;
            self.remotecontroltrigger linkto( self );
        }
    }
}

initremoteweapon( weapon, weaponname )
{
    weapon.inittime = gettime();
    weapon.remotename = weaponname;
    weapon thread watchfindremoteweapon( self );

    if ( isdefined( self.remoteweapon ) )
    {
        if ( !isusingremote() )
            self notify( "remove_remote_weapon", 1 );
    }
    else
        self thread setactiveremotecontrolledweapon( weapon );
}

setactiveremotecontrolledweapon( weapon )
{
    assert( !isdefined( self.remoteweapon ), "Trying to activate remote weapon without cleaning up the current one" );

    if ( isdefined( self.remoteweapon ) )
        return;

    while ( !isalive( self ) )
        wait 0.05;

    self notify( "set_active_remote_weapon" );
    self.remoteweapon = weapon;
    self thread watchremoveremotecontrolledweapon( weapon.remotename );
    self thread watchremotecontrolledweapondeath();
    self thread watchremoteweaponpings();
    self createremoteweapontrigger( weapon.remotename );
}

watchfindremoteweapon( player )
{
    self endon( "removed_on_death" );
    self endon( "death" );

    while ( true )
    {
        player waittill( "find_remote_weapon" );

        player notify( "remote_weapon_ping", self );
    }
}

watchremoteweaponpings()
{
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );
    self endon( "set_active_remote_weapon" );
    self.remoteweaponqueue = [];
    self thread collectweaponpings();

    while ( true )
    {
        self waittill( "remote_weapon_ping", weapon );

        if ( isdefined( weapon ) )
            self.remoteweaponqueue[self.remoteweaponqueue.size] = weapon;
    }
}

collectweaponpings()
{
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );

    self waittill( "remote_weapon_ping" );

    wait 0.1;

    while ( !isalive( self ) )
        wait 0.05;

    if ( isdefined( self ) )
    {
        assert( isdefined( self.remoteweaponqueue ) );
        best_weapon = undefined;

        foreach ( weapon in self.remoteweaponqueue )
        {
            if ( isdefined( weapon ) && isalive( weapon ) )
            {
                if ( !isdefined( best_weapon ) || best_weapon.inittime < weapon.inittime )
                    best_weapon = weapon;
            }
        }

        if ( isdefined( best_weapon ) )
            self thread setactiveremotecontrolledweapon( best_weapon );
    }
}

watchremotecontrolledweapondeath()
{
    self endon( "remove_remote_weapon" );
    assert( isdefined( self.remoteweapon ) );

    self.remoteweapon waittill( "death" );

    if ( isdefined( self ) )
        self notify( "remove_remote_weapon", 1 );
}

watchremoveremotecontrolledweapon( weaponname )
{
    self endon( "disconnect" );

    self waittill( "remove_remote_weapon", trytoreplace );

    self removeremotecontrolledweapon( weaponname );

    while ( isdefined( self.remoteweapon ) )
        wait 0.05;

    if ( trytoreplace == 1 )
        self notify( "find_remote_weapon" );
}

removeremotecontrolledweapon( weaponname )
{
    if ( self isusingremote() )
    {
        remoteweaponname = self getremotename();

        if ( remoteweaponname == weaponname )
            self baseendremotecontrolweaponuse( weaponname, 1 );
    }

    self destroyremotecontrolactionprompthud();
    self.remoteweapon = undefined;
    self.remotecontroltrigger delete();
}

createremoteweapontrigger( weaponname )
{
    trigger = spawn( "trigger_radius_use", self.origin, 32, 32 );
    trigger enablelinkto();
    trigger linkto( self );
    trigger sethintlowpriority( 1 );
    trigger setcursorhint( "HINT_NOICON" );
    trigger sethintstring( level.remoteweapons[weaponname].hintstring );

    if ( level.teambased )
    {
        trigger setteamfortrigger( self.team );
        trigger.triggerteam = self.team;
    }

    self clientclaimtrigger( trigger );
    trigger.claimedby = self;
    self.remotecontroltrigger = trigger;
    self thread watchremotetriggeruse( weaponname );
    self thread removeremotetriggerondisconnect( trigger );
}

removeremotetriggerondisconnect( trigger )
{
    self endon( "remove_remote_weapon" );
    trigger endon( "death" );

    self waittill( "disconnect" );

    trigger delete();
}

watchremotetriggeruse( weaponname )
{
    self endon( "remove_remote_weapon" );
    self endon( "disconnect" );

    if ( self is_bot() )
        return;

    while ( true )
    {
        self.remotecontroltrigger waittill( "trigger", player );

        if ( self isusingoffhand() )
            continue;

        if ( isdefined( self.remoteweapon ) && isdefined( self.remoteweapon.hackertrigger ) && isdefined( self.remoteweapon.hackertrigger.progressbar ) )
        {
            if ( weaponname == "killstreak_remote_turret_mp" )
                self iprintlnbold( &"KILLSTREAK_AUTO_TURRET_NOT_AVAILABLE" );

            continue;
        }

        if ( self usebuttonpressed() && !self.throwinggrenade && !self meleebuttonpressed() && !self isusingremote() )
            self useremotecontrolweapon( weaponname );
    }
}

useremotecontrolweapon( weaponname, allowexit )
{
    self disableoffhandweapons();
    self giveweapon( weaponname );
    self switchtoweapon( weaponname );

    if ( !isdefined( allowexit ) )
        allowexit = 1;

    self thread maps\mp\killstreaks\_killstreaks::watchforemoveremoteweapon();

    self waittill( "weapon_change", newweapon );

    self notify( "endWatchFoRemoveRemoteWeapon" );
    self setusingremote( weaponname );

    if ( !self isonground() )
    {
        self clearusingremote();
        return;
    }

    result = self maps\mp\killstreaks\_killstreaks::initridekillstreak( weaponname );

    if ( allowexit && result != "success" )
    {
        if ( result != "disconnect" )
            self clearusingremote();
    }
    else if ( allowexit && !self isonground() )
    {
        self clearusingremote();
        return;
    }
    else
    {
        self.remoteweapon.controlled = 1;
        self.remoteweapon.killcament = self;
        self.remoteweapon notify( "remote_start" );

        if ( !isdefined( allowexit ) || allowexit )
            self thread watchremotecontroldeactivate( weaponname );

        self thread [[ level.remoteweapons[weaponname].usecallback ]]( self.remoteweapon );
    }
}

createremotecontrolactionprompthud()
{
    if ( !isdefined( self.hud_prompt_exit ) )
        self.hud_prompt_exit = newclienthudelem( self );

    self.hud_prompt_exit.alignx = "left";
    self.hud_prompt_exit.aligny = "bottom";
    self.hud_prompt_exit.horzalign = "user_left";
    self.hud_prompt_exit.vertalign = "user_bottom";
    self.hud_prompt_exit.font = "small";
    self.hud_prompt_exit.fontscale = 1.25;
    self.hud_prompt_exit.hidewheninmenu = 1;
    self.hud_prompt_exit.archived = 0;
    self.hud_prompt_exit.x = 25;
    self.hud_prompt_exit.y = -10;
    self.hud_prompt_exit settext( level.remoteexithint );
}

destroyremotecontrolactionprompthud()
{
    if ( isdefined( self ) && isdefined( self.hud_prompt_exit ) )
        self.hud_prompt_exit destroy();
}

watchremotecontroldeactivate( weaponname )
{
    self endon( "remove_remote_weapon" );
    self endon( "disconnect" );
    self.remoteweapon endon( "remote_start" );
    wait 1;

    while ( true )
    {
        timeused = 0;

        while ( self usebuttonpressed() )
        {
            timeused += 0.05;

            if ( timeused > 0.25 )
            {
                self thread baseendremotecontrolweaponuse( weaponname, 0 );
                return;
            }

            wait 0.05;
        }

        wait 0.05;
    }
}

endremotecontrolweaponuse( weaponname )
{
    if ( isdefined( self.hud_prompt_exit ) )
        self.hud_prompt_exit settext( "" );

    self [[ level.remoteweapons[weaponname].endusecallback ]]( self.remoteweapon );
}

fadeouttoblack( isdead )
{
    self endon( "disconnect" );
    self endon( "early_death" );

    if ( isdead )
    {
        self sendkillstreakdamageevent( 600 );
        wait 0.75;
        self thread maps\mp\gametypes\_hud::fadetoblackforxsec( 0, 0.25, 0.1, 0.25 );
    }
    else
        self thread maps\mp\gametypes\_hud::fadetoblackforxsec( 0, 0.2, 0, 0.3 );
}

baseendremotecontrolweaponuse( weaponname, isdead )
{
    if ( isdefined( self ) )
    {
        if ( isdead && isdefined( self.remoteweapon ) && !isdefined( self.remoteweapon.skipfutz ) )
        {
            self thread fadeouttoblack( 1 );
            wait 1;
        }
        else
            self thread fadeouttoblack( 0 );

        self clearusingremote();
        self takeweapon( weaponname );
    }

    if ( isdefined( self.remoteweapon ) )
    {
        if ( isdead )
            self.remoteweapon.wascontrollednowdead = self.remoteweapon.controlled;

        self.remoteweapon.controlled = 0;
        self [[ level.remoteweapons[weaponname].endusecallback ]]( self.remoteweapon, isdead );
        self.remoteweapon.killcament = self.remoteweapon;
        self unlink();
        self.killstreak_waitamount = undefined;
        self destroyremotehud();
        self clientnotify( "nofutz" );

        if ( isdefined( level.gameended ) && level.gameended )
            self freezecontrolswrapper( 1 );
    }

    if ( isdefined( self.hud_prompt_exit ) )
        self.hud_prompt_exit settext( "" );

    self notify( "remove_remote_weapon", 1 );
}

destroyremotehud()
{
    self useservervisionset( 0 );
    self setinfraredvision( 0 );

    if ( isdefined( self.fullscreen_static ) )
        self.fullscreen_static destroy();

    if ( isdefined( self.remote_hud_reticle ) )
        self.remote_hud_reticle destroy();

    if ( isdefined( self.remote_hud_bracket_right ) )
        self.remote_hud_bracket_right destroy();

    if ( isdefined( self.remote_hud_bracket_left ) )
        self.remote_hud_bracket_left destroy();

    if ( isdefined( self.remote_hud_arrow_right ) )
        self.remote_hud_arrow_right destroy();

    if ( isdefined( self.remote_hud_arrow_left ) )
        self.remote_hud_arrow_left destroy();

    if ( isdefined( self.tank_rocket_1 ) )
        self.tank_rocket_1 destroy();

    if ( isdefined( self.tank_rocket_2 ) )
        self.tank_rocket_2 destroy();

    if ( isdefined( self.tank_rocket_3 ) )
        self.tank_rocket_3 destroy();

    if ( isdefined( self.tank_rocket_hint ) )
        self.tank_rocket_hint destroy();

    if ( isdefined( self.tank_mg_bar ) )
        self.tank_mg_bar destroy();

    if ( isdefined( self.tank_mg_arrow ) )
        self.tank_mg_arrow destroy();

    if ( isdefined( self.tank_mg_hint ) )
        self.tank_mg_hint destroy();

    if ( isdefined( self.tank_fullscreen_effect ) )
        self.tank_fullscreen_effect destroy();

    if ( isdefined( self.hud_prompt_exit ) )
        self.hud_prompt_exit destroy();
}

stunstaticfx( duration )
{
    self endon( "remove_remote_weapon" );
    self.fullscreen_static.alpha = 0.65;
    wait( duration - 0.5 );
    time = duration - 0.5;

    while ( time < duration )
    {
        wait 0.05;
        time += 0.05;
        self.fullscreen_static.alpha -= 0.05;
    }

    self.fullscreen_static.alpha = 0.15;
}
