// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\gametypes\_globallogic_utils;
#include maps\mp\killstreaks\_supplydrop;
#include maps\mp\killstreaks\_killstreakrules;
#include maps\mp\gametypes\_weapons;
#include maps\mp\_popups;
#include maps\mp\gametypes\_class;

init()
{
    precacheshader( "hud_ks_minigun" );
    precacheshader( "hud_ks_m32" );
    maps\mp\killstreaks\_killstreaks::registerkillstreak( "inventory_minigun_mp", "inventory_minigun_mp", "killstreak_minigun", "minigun_used", ::usecarriedkillstreakweapon, 0, 1, "MINIGUN_USED" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakstrings( "inventory_minigun_mp", &"KILLSTREAK_EARNED_MINIGUN", &"KILLSTREAK_MINIGUN_NOT_AVAILABLE", &"KILLSTREAK_MINIGUN_INBOUND" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakdialog( "inventory_minigun_mp", "mpl_killstreak_minigun", "kls_death_used", "", "kls_death_enemy", "", "kls_death_ready" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakdevdvar( "inventory_minigun_mp", "scr_giveminigun_drop" );
    maps\mp\killstreaks\_killstreaks::registerkillstreak( "minigun_mp", "minigun_mp", "killstreak_minigun", "minigun_used", ::usecarriedkillstreakweapon, 0, 1, "MINIGUN_USED" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakstrings( "minigun_mp", &"KILLSTREAK_EARNED_MINIGUN", &"KILLSTREAK_MINIGUN_NOT_AVAILABLE", &"KILLSTREAK_MINIGUN_INBOUND" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakdialog( "minigun_mp", "mpl_killstreak_minigun", "kls_death_used", "", "kls_death_enemy", "", "kls_death_ready" );
    maps\mp\killstreaks\_killstreaks::registerkillstreak( "inventory_m32_mp", "inventory_m32_mp", "killstreak_m32", "m32_used", ::usecarriedkillstreakweapon, 0, 1, "M32_USED" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakstrings( "inventory_m32_mp", &"KILLSTREAK_EARNED_M32", &"KILLSTREAK_M32_NOT_AVAILABLE", &"KILLSTREAK_M32_INBOUND" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakdialog( "inventory_m32_mp", "mpl_killstreak_m32", "kls_mgl_used", "", "kls_mgl_enemy", "", "kls_mgl_ready" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakdevdvar( "inventory_m32_mp", "scr_givem32_drop" );
    maps\mp\killstreaks\_killstreaks::overrideentitycameraindemo( "inventory_m32_mp", 1 );
    maps\mp\killstreaks\_killstreaks::registerkillstreak( "m32_mp", "m32_mp", "killstreak_m32", "m32_used", ::usecarriedkillstreakweapon, 0, 1, "M32_USED" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakstrings( "m32_mp", &"KILLSTREAK_EARNED_M32", &"KILLSTREAK_M32_NOT_AVAILABLE", &"KILLSTREAK_M32_INBOUND" );
    maps\mp\killstreaks\_killstreaks::registerkillstreakdialog( "m32_mp", "mpl_killstreak_m32", "kls_mgl_used", "", "kls_mgl_enemy", "", "kls_mgl_ready" );
    maps\mp\killstreaks\_killstreaks::overrideentitycameraindemo( "m32_mp", 1 );
    level.killstreakicons["killstreak_minigun"] = "hud_ks_minigun";
    level.killstreakicons["killstreak_m32"] = "hud_ks_m32";
    level.killstreakicons["killstreak_m202_flash_mp"] = "hud_ks_m202";
    level.killstreakicons["killstreak_m220_tow_drop_mp"] = "hud_ks_tv_guided_marker";
    level.killstreakicons["killstreak_m220_tow_mp"] = "hud_ks_tv_guided_missile";
    level thread onplayerconnect();
    setdvar( "scr_HeldKillstreak_Penalty", 0 );
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connecting", player );

        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        self.firedkillstreakweapon = 0;
        self.usingkillstreakheldweapon = undefined;

        if ( !isfirstround() && !isoneround() )
        {
            if ( level.roundstartkillstreakdelay > maps\mp\gametypes\_globallogic_utils::gettimepassed() / 1000 )
                self thread watchkillstreakweapondelay();
        }
    }
}

watchkillstreakweapondelay()
{
    self endon( "disconnect" );
    self endon( "death" );

    while ( true )
    {
        currentweapon = self getcurrentweapon();

        self waittill( "weapon_change", newweapon );

        if ( level.roundstartkillstreakdelay < maps\mp\gametypes\_globallogic_utils::gettimepassed() / 1000 )
            return;

        if ( !maps\mp\killstreaks\_killstreaks::iskillstreakweapon( newweapon ) )
        {
            wait 0.5;
            continue;
        }

        if ( maps\mp\killstreaks\_killstreaks::isdelayablekillstreak( newweapon ) && isheldkillstreakweapon( newweapon ) )
        {
            timeleft = int( level.roundstartkillstreakdelay - maps\mp\gametypes\_globallogic_utils::gettimepassed() / 1000 );

            if ( !timeleft )
                timeleft = 1;

            self iprintlnbold( &"MP_UNAVAILABLE_FOR_N", " " + timeleft + " ", &"EXE_SECONDS" );
            self switchtoweapon( currentweapon );
            wait 0.5;
        }
    }
}

usekillstreakweapondrop( hardpointtype )
{
    if ( self maps\mp\killstreaks\_supplydrop::issupplydropgrenadeallowed( hardpointtype ) == 0 )
        return 0;

    result = self maps\mp\killstreaks\_supplydrop::usesupplydropmarker();
    self notify( "supply_drop_marker_done" );

    if ( !isdefined( result ) || !result )
        return 0;

    return result;
}

usecarriedkillstreakweapon( hardpointtype )
{
    if ( self maps\mp\killstreaks\_killstreakrules::iskillstreakallowed( hardpointtype, self.team ) == 0 )
    {
        self switchtoweapon( self.lastdroppableweapon );
        return false;
    }

    if ( !isdefined( hardpointtype ) )
        return false;

    currentweapon = self getcurrentweapon();

    if ( hardpointtype == "none" )
        return false;

    level maps\mp\gametypes\_weapons::addlimitedweapon( hardpointtype, self, 3 );

    if ( issubstr( hardpointtype, "inventory" ) )
        isfrominventory = 1;
    else
        isfrominventory = 0;

    currentammo = self getammocount( hardpointtype );

    if ( ( hardpointtype == "minigun_mp" || hardpointtype == "inventory_minigun_mp" ) && ( !isdefined( self.minigunstart ) || self.minigunstart == 0 ) || ( hardpointtype == "m32_mp" || hardpointtype == "inventory_m32_mp" ) && ( !isdefined( self.m32start ) || self.m32start == 0 ) )
    {
        if ( hardpointtype == "minigun_mp" || hardpointtype == "inventory_minigun_mp" )
            self.minigunstart = 1;
        else
            self.m32start = 1;

        self maps\mp\killstreaks\_killstreaks::playkillstreakstartdialog( hardpointtype, self.team, 1 );
        level.globalkillstreakscalled++;
        self addweaponstat( hardpointtype, "used", 1 );
        level thread maps\mp\_popups::displayteammessagetoall( level.killstreaks[hardpointtype].inboundtext, self );
        self.pers["held_killstreak_clip_count"][hardpointtype] = weaponclipsize( hardpointtype ) > currentammo ? currentammo : weaponclipsize( hardpointtype );

        if ( isfrominventory == 0 )
        {
            if ( self.pers["killstreak_quantity"][hardpointtype] > 0 )
                ammopool = weaponmaxammo( hardpointtype );
            else
                ammopool = self.pers["held_killstreak_ammo_count"][hardpointtype];

            self setweaponammoclip( hardpointtype, self.pers["held_killstreak_clip_count"][hardpointtype] );
            self setweaponammostock( hardpointtype, ammopool - self.pers["held_killstreak_clip_count"][hardpointtype] );
        }
    }

    if ( hardpointtype == "minigun_mp" || hardpointtype == "inventory_minigun_mp" )
    {
        if ( !isdefined( self.minigunactive ) || !self.minigunactive )
        {
            killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart( hardpointtype, self.team, 0, 0 );

            if ( hardpointtype == "inventory_minigun_mp" )
                killstreak_id = self.pers["killstreak_unique_id"][self.pers["killstreak_unique_id"].size - 1];

            self.minigunid = killstreak_id;
            self.minigunactive = 1;
        }
        else
            killstreak_id = self.minigunid;
    }
    else if ( !isdefined( self.m32active ) || !self.m32active )
    {
        killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart( hardpointtype, self.team, 0, 0 );

        if ( hardpointtype == "inventory_m32_mp" )
            killstreak_id = self.pers["killstreak_unique_id"][self.pers["killstreak_unique_id"].size - 1];

        self.m32id = killstreak_id;
        self.m32active = 1;
    }
    else
        killstreak_id = self.m32id;

    assert( killstreak_id != -1 );
    self.firedkillstreakweapon = 0;
    self setblockweaponpickup( hardpointtype, 1 );

    if ( isfrominventory )
    {
        self setweaponammoclip( hardpointtype, self.pers["held_killstreak_clip_count"][hardpointtype] );
        self setweaponammostock( hardpointtype, self.pers["killstreak_ammo_count"][self.pers["killstreak_ammo_count"].size - 1] - self.pers["held_killstreak_clip_count"][hardpointtype] );
    }

    notifystring = "killstreakWeapon_" + hardpointtype;
    self notify( notifystring );
    self thread watchkillstreakweaponswitch( hardpointtype, killstreak_id, isfrominventory );
    self thread watchkillstreakweapondeath( hardpointtype, killstreak_id, isfrominventory );
    self thread watchkillstreakroundchange( isfrominventory, killstreak_id );
    self thread watchplayerdeath( hardpointtype );

    if ( isfrominventory )
        self thread watchkillstreakremoval( hardpointtype, killstreak_id );

    self.usingkillstreakheldweapon = 1;
    return false;
}

usekillstreakweaponfromcrate( hardpointtype )
{
    if ( !isdefined( hardpointtype ) )
        return false;

    if ( hardpointtype == "none" )
        return false;

    self.firedkillstreakweapon = 0;
    self setblockweaponpickup( hardpointtype, 1 );
    killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart( hardpointtype, self.team, 0, 0 );
    assert( killstreak_id != -1 );

    if ( issubstr( hardpointtype, "inventory" ) )
        isfrominventory = 1;
    else
        isfrominventory = 0;

    self thread watchkillstreakweaponswitch( hardpointtype, killstreak_id, isfrominventory );
    self thread watchkillstreakweapondeath( hardpointtype, killstreak_id, isfrominventory );

    if ( isfrominventory )
        self thread watchkillstreakremoval( hardpointtype, killstreak_id );

    self.usingkillstreakheldweapon = 1;
    return true;
}

watchkillstreakweaponswitch( killstreakweapon, killstreak_id, isfrominventory )
{
    self endon( "disconnect" );
    self endon( "death" );

    while ( true )
    {
        currentweapon = self getcurrentweapon();

        self waittill( "weapon_change", newweapon );

        if ( level.infinalkillcam )
            continue;

        if ( newweapon == "none" )
            continue;

        currentammo = self getammocount( killstreakweapon );
        currentammoinclip = self getweaponammoclip( killstreakweapon );

        if ( isfrominventory && currentammo > 0 )
        {
            killstreakindex = self maps\mp\killstreaks\_killstreaks::getkillstreakindexbyid( killstreak_id );

            if ( isdefined( killstreakindex ) )
            {
                self.pers["killstreak_ammo_count"][killstreakindex] = currentammo;
                self.pers["held_killstreak_clip_count"][killstreakweapon] = currentammoinclip;
            }
        }

        if ( maps\mp\killstreaks\_killstreaks::iskillstreakweapon( newweapon ) && !isheldkillstreakweapon( newweapon ) )
            continue;

        if ( isgameplayweapon( newweapon ) )
            continue;

        if ( isheldkillstreakweapon( newweapon ) && newweapon == self.lastnonkillstreakweapon )
            continue;

        killstreakid = maps\mp\killstreaks\_killstreaks::gettopkillstreakuniqueid();
        self.pers["held_killstreak_ammo_count"][killstreakweapon] = currentammo;
        self.pers["held_killstreak_clip_count"][killstreakweapon] = currentammoinclip;

        if ( killstreak_id != -1 )
            self notify( "killstreak_weapon_switch" );

        self.firedkillstreakweapon = 0;
        self.usingkillstreakheldweapon = undefined;
        waittillframeend;

        if ( currentammo == 0 || self.pers["killstreak_quantity"][killstreakweapon] > 0 || isfrominventory && isdefined( killstreakid ) && killstreakid != killstreak_id )
        {
            maps\mp\killstreaks\_killstreakrules::killstreakstop( killstreakweapon, self.team, killstreak_id );

            if ( killstreakweapon == "minigun_mp" || killstreakweapon == "inventory_minigun_mp" )
            {
                self.minigunstart = 0;
                self.minigunactive = 0;
            }
            else
            {
                self.m32start = 0;
                self.m32active = 0;
            }

            if ( self.pers["killstreak_quantity"][killstreakweapon] > 0 )
            {
                self.pers["held_killstreak_ammo_count"][killstreakweapon] = weaponmaxammo( killstreakweapon );
                self maps\mp\gametypes\_class::setweaponammooverall( killstreakweapon, self.pers["held_killstreak_ammo_count"][killstreakweapon] );
                self.pers["killstreak_quantity"][killstreakweapon]--;
            }
        }

        if ( isfrominventory && currentammo == 0 )
        {
            self takeweapon( killstreakweapon );
            self maps\mp\killstreaks\_killstreaks::removeusedkillstreak( killstreakweapon, killstreak_id );
            self maps\mp\killstreaks\_killstreaks::activatenextkillstreak();
        }

        break;
    }
}

watchkillstreakweapondeath( hardpointtype, killstreak_id, isfrominventory )
{
    self endon( "disconnect" );
    self endon( "killstreak_weapon_switch" );

    if ( killstreak_id == -1 )
        return;

    oldteam = self.team;

    self waittill( "death" );

    penalty = getdvarfloatdefault( "scr_HeldKillstreak_Penalty", 0.5 );
    maxammo = weaponmaxammo( hardpointtype );
    currentammo = self getammocount( hardpointtype );
    currentammoinclip = self getweaponammoclip( hardpointtype );

    if ( self.pers["killstreak_quantity"].size == 0 )
    {
        currentammo = 0;
        currentammoinclip = 0;
    }

    maxclipsize = weaponclipsize( hardpointtype );
    newammo = int( currentammo - maxammo * penalty );
    killstreakid = maps\mp\killstreaks\_killstreaks::gettopkillstreakuniqueid();

    if ( self.lastnonkillstreakweapon == hardpointtype )
    {
        if ( newammo < 0 )
        {
            self.pers["held_killstreak_ammo_count"][hardpointtype] = 0;
            self.pers["held_killstreak_clip_count"][hardpointtype] = 0;
        }
        else
        {
            self.pers["held_killstreak_ammo_count"][hardpointtype] = newammo;
            self.pers["held_killstreak_clip_count"][hardpointtype] = maxclipsize <= newammo ? maxclipsize : newammo;
        }
    }

    self.usingkillstreakheldweapon = 0;

    if ( newammo <= 0 || self.pers["killstreak_quantity"][hardpointtype] > 0 || isfrominventory && isdefined( killstreakid ) && killstreakid != killstreak_id )
    {
        maps\mp\killstreaks\_killstreakrules::killstreakstop( hardpointtype, oldteam, killstreak_id );

        if ( hardpointtype == "minigun_mp" || hardpointtype == "inventory_minigun_mp" )
        {
            self.minigunstart = 0;
            self.minigunactive = 0;
        }
        else
        {
            self.m32start = 0;
            self.m32active = 0;
        }

        if ( isdefined( self.pers["killstreak_quantity"][hardpointtype] ) && self.pers["killstreak_quantity"][hardpointtype] > 0 )
        {
            self.pers["held_killstreak_ammo_count"][hardpointtype] = maxammo;
            self.pers["held_killstreak_clip_count"][hardpointtype] = maxclipsize;
            self setweaponammoclip( hardpointtype, self.pers["held_killstreak_clip_count"][hardpointtype] );
            self setweaponammostock( hardpointtype, self.pers["held_killstreak_ammo_count"][hardpointtype] - self.pers["held_killstreak_clip_count"][hardpointtype] );
            self.pers["killstreak_quantity"][hardpointtype]--;
        }
    }

    if ( isfrominventory && newammo <= 0 )
    {
        self takeweapon( hardpointtype );
        self maps\mp\killstreaks\_killstreaks::removeusedkillstreak( hardpointtype, killstreak_id );
        self maps\mp\killstreaks\_killstreaks::activatenextkillstreak();
    }
    else if ( isfrominventory )
    {
        killstreakindex = self maps\mp\killstreaks\_killstreaks::getkillstreakindexbyid( killstreak_id );

        if ( isdefined( killstreakindex ) )
            self.pers["killstreak_ammo_count"][killstreakindex] = self.pers["held_killstreak_ammo_count"][hardpointtype];
    }
}

watchplayerdeath( killstreakweapon )
{
    self endon( "disconnect" );
    endonweaponstring = "killstreakWeapon_" + killstreakweapon;
    self endon( endonweaponstring );

    self waittill( "death" );

    currentammo = self getammocount( killstreakweapon );
    self.pers["held_killstreak_clip_count"][killstreakweapon] = weaponclipsize( killstreakweapon ) <= currentammo ? weaponclipsize( killstreakweapon ) : currentammo;
}

watchkillstreakremoval( killstreakweapon, killstreak_id )
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "killstreak_weapon_switch" );

    self waittill( "oldest_killstreak_removed", removedkillstreakweapon, removed_id );

    if ( killstreakweapon == removedkillstreakweapon && killstreak_id == removed_id )
    {
        if ( removedkillstreakweapon == "inventory_minigun_mp" )
        {
            self.minigunstart = 0;
            self.minigunactive = 0;
        }
        else
        {
            self.m32start = 0;
            self.m32active = 0;
        }
    }
}

watchkillstreakroundchange( isfrominventory, killstreak_id )
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "killstreak_weapon_switch" );

    self waittill( "round_ended" );

    currentweapon = self getcurrentweapon();

    if ( !isheldkillstreakweapon( currentweapon ) )
        return;

    currentammo = self getammocount( currentweapon );
    maxclipsize = weaponclipsize( currentweapon );

    if ( isfrominventory && currentammo > 0 )
    {
        killstreakindex = self maps\mp\killstreaks\_killstreaks::getkillstreakindexbyid( killstreak_id );

        if ( isdefined( killstreakindex ) )
        {
            self.pers["killstreak_ammo_count"][killstreakindex] = currentammo;
            self.pers["held_killstreak_clip_count"][currentweapon] = maxclipsize <= currentammo ? maxclipsize : currentammo;
        }
    }
    else
    {
        self.pers["held_killstreak_ammo_count"][currentweapon] = currentammo;
        self.pers["held_killstreak_clip_count"][currentweapon] = maxclipsize <= currentammo ? maxclipsize : currentammo;
    }
}

checkifswitchableweapon( currentweapon, newweapon, killstreakweapon, currentkillstreakid )
{
    switchableweapon = 1;
    topkillstreak = maps\mp\killstreaks\_killstreaks::gettopkillstreak();
    killstreakid = maps\mp\killstreaks\_killstreaks::gettopkillstreakuniqueid();

    if ( !isdefined( killstreakid ) )
        killstreakid = -1;

    if ( self hasweapon( killstreakweapon ) && !self getammocount( killstreakweapon ) )
        switchableweapon = 1;
    else if ( self.firedkillstreakweapon && newweapon == killstreakweapon && isheldkillstreakweapon( currentweapon ) )
        switchableweapon = 1;
    else if ( isweaponequipment( newweapon ) )
        switchableweapon = 1;
    else if ( isdefined( level.grenade_array[newweapon] ) )
        switchableweapon = 0;
    else if ( isheldkillstreakweapon( newweapon ) && isheldkillstreakweapon( currentweapon ) && ( !isdefined( currentkillstreakid ) || currentkillstreakid != killstreakid ) )
        switchableweapon = 1;
    else if ( maps\mp\killstreaks\_killstreaks::iskillstreakweapon( newweapon ) )
        switchableweapon = 0;
    else if ( isgameplayweapon( newweapon ) )
        switchableweapon = 0;
    else if ( self.firedkillstreakweapon )
        switchableweapon = 1;
    else if ( self.lastnonkillstreakweapon == killstreakweapon )
        switchableweapon = 0;
    else if ( isdefined( topkillstreak ) && topkillstreak == killstreakweapon && currentkillstreakid == killstreakid )
        switchableweapon = 0;

    return switchableweapon;
}

watchkillstreakweaponusage()
{
    self endon( "disconnect" );
    self endon( "death" );

    while ( true )
    {
        self waittill( "weapon_fired", killstreakweapon );

        if ( !isheldkillstreakweapon( killstreakweapon ) )
        {
            wait 0.1;
            continue;
        }

        if ( self.firedkillstreakweapon )
            continue;

        maps\mp\killstreaks\_killstreaks::removeusedkillstreak( killstreakweapon );
        self.firedkillstreakweapon = 1;
        self setactionslot( 4, "" );
        waittillframeend;
        maps\mp\killstreaks\_killstreaks::activatenextkillstreak();
    }
}

isheldkillstreakweapon( killstreaktype )
{
    switch ( killstreaktype )
    {
        case "minigun_mp":
        case "m32_mp":
        case "inventory_minigun_mp":
        case "inventory_m32_mp":
            return true;
    }

    return false;
}

isheldinventorykillstreakweapon( killstreaktype )
{
    switch ( killstreaktype )
    {
        case "inventory_minigun_mp":
        case "inventory_m32_mp":
            return true;
    }

    return false;
}

isgameplayweapon( weapon )
{
    switch ( weapon )
    {
        case "syrette_mp":
        case "briefcase_bomb_mp":
        case "briefcase_bomb_defuse_mp":
            return true;
        default:
            return false;
    }

    return false;
}
