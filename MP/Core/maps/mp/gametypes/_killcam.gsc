// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_globallogic;
#include maps\mp\_challenges;
#include maps\mp\_tacticalinsertion;
#include maps\mp\gametypes\_spectating;
#include maps\mp\gametypes\_globallogic_spawn;

init()
{
    precachestring( &"PLATFORM_PRESS_TO_SKIP" );
    precachestring( &"PLATFORM_PRESS_TO_RESPAWN" );
    precacheshader( "white" );
    level.killcam = getgametypesetting( "allowKillcam" );
    level.finalkillcam = getgametypesetting( "allowFinalKillcam" );
    initfinalkillcam();
}

initfinalkillcam()
{
    level.finalkillcamsettings = [];
    initfinalkillcamteam( "none" );

    foreach ( team in level.teams )
        initfinalkillcamteam( team );

    level.finalkillcam_winner = undefined;
}

initfinalkillcamteam( team )
{
    level.finalkillcamsettings[team] = spawnstruct();
    clearfinalkillcamteam( team );
}

clearfinalkillcamteam( team )
{
    level.finalkillcamsettings[team].spectatorclient = undefined;
    level.finalkillcamsettings[team].weapon = undefined;
    level.finalkillcamsettings[team].deathtime = undefined;
    level.finalkillcamsettings[team].deathtimeoffset = undefined;
    level.finalkillcamsettings[team].offsettime = undefined;
    level.finalkillcamsettings[team].entityindex = undefined;
    level.finalkillcamsettings[team].targetentityindex = undefined;
    level.finalkillcamsettings[team].entitystarttime = undefined;
    level.finalkillcamsettings[team].perks = undefined;
    level.finalkillcamsettings[team].killstreaks = undefined;
    level.finalkillcamsettings[team].attacker = undefined;
}

recordkillcamsettings( spectatorclient, targetentityindex, sweapon, deathtime, deathtimeoffset, offsettime, entityindex, entitystarttime, perks, killstreaks, attacker )
{
    if ( level.teambased && isdefined( attacker.team ) && isdefined( level.teams[attacker.team] ) )
    {
        team = attacker.team;
        level.finalkillcamsettings[team].spectatorclient = spectatorclient;
        level.finalkillcamsettings[team].weapon = sweapon;
        level.finalkillcamsettings[team].deathtime = deathtime;
        level.finalkillcamsettings[team].deathtimeoffset = deathtimeoffset;
        level.finalkillcamsettings[team].offsettime = offsettime;
        level.finalkillcamsettings[team].entityindex = entityindex;
        level.finalkillcamsettings[team].targetentityindex = targetentityindex;
        level.finalkillcamsettings[team].entitystarttime = entitystarttime;
        level.finalkillcamsettings[team].perks = perks;
        level.finalkillcamsettings[team].killstreaks = killstreaks;
        level.finalkillcamsettings[team].attacker = attacker;
    }

    level.finalkillcamsettings["none"].spectatorclient = spectatorclient;
    level.finalkillcamsettings["none"].weapon = sweapon;
    level.finalkillcamsettings["none"].deathtime = deathtime;
    level.finalkillcamsettings["none"].deathtimeoffset = deathtimeoffset;
    level.finalkillcamsettings["none"].offsettime = offsettime;
    level.finalkillcamsettings["none"].entityindex = entityindex;
    level.finalkillcamsettings["none"].targetentityindex = targetentityindex;
    level.finalkillcamsettings["none"].entitystarttime = entitystarttime;
    level.finalkillcamsettings["none"].perks = perks;
    level.finalkillcamsettings["none"].killstreaks = killstreaks;
    level.finalkillcamsettings["none"].attacker = attacker;
}

erasefinalkillcam()
{
    clearfinalkillcamteam( "none" );

    foreach ( team in level.teams )
        clearfinalkillcamteam( team );

    level.finalkillcam_winner = undefined;
}

finalkillcamwaiter()
{
    if ( !isdefined( level.finalkillcam_winner ) )
        return false;

    level waittill( "final_killcam_done" );

    return true;
}

postroundfinalkillcam()
{
    if ( isdefined( level.sidebet ) && level.sidebet )
        return;

    level notify( "play_final_killcam" );
    maps\mp\gametypes\_globallogic::resetoutcomeforallplayers();
    finalkillcamwaiter();
}

dofinalkillcam()
{
    level waittill( "play_final_killcam" );

    level.infinalkillcam = 1;
    winner = "none";

    if ( isdefined( level.finalkillcam_winner ) )
        winner = level.finalkillcam_winner;

    if ( !isdefined( level.finalkillcamsettings[winner].targetentityindex ) )
    {
        level.infinalkillcam = 0;
        level notify( "final_killcam_done" );
        return;
    }

    if ( isdefined( level.finalkillcamsettings[winner].attacker ) )
        maps\mp\_challenges::getfinalkill( level.finalkillcamsettings[winner].attacker );

    visionsetnaked( getdvar( "mapname" ), 0.0 );
    players = level.players;

    for ( index = 0; index < players.size; index++ )
    {
        player = players[index];
        player closemenu();
        player closeingamemenu();
        player thread finalkillcam( winner );
    }

    wait 0.1;

    while ( areanyplayerswatchingthekillcam() )
        wait 0.05;

    level notify( "final_killcam_done" );
    level.infinalkillcam = 0;
}

startlastkillcam()
{

}

areanyplayerswatchingthekillcam()
{
    players = level.players;

    for ( index = 0; index < players.size; index++ )
    {
        player = players[index];

        if ( isdefined( player.killcam ) )
            return true;
    }

    return false;
}

killcam( attackernum, targetnum, killcamentity, killcamentityindex, killcamentitystarttime, sweapon, deathtime, deathtimeoffset, offsettime, respawn, maxtime, perks, killstreaks, attacker )
{
    self endon( "disconnect" );
    self endon( "spawned" );
    level endon( "game_ended" );

    if ( attackernum < 0 )
        return;

    postdeathdelay = ( gettime() - deathtime ) / 1000;
    predelay = postdeathdelay + deathtimeoffset;
    camtime = calckillcamtime( sweapon, killcamentitystarttime, predelay, respawn, maxtime );
    postdelay = calcpostdelay();
    killcamlength = camtime + postdelay;

    if ( isdefined( maxtime ) && killcamlength > maxtime )
    {
        if ( maxtime < 2 )
            return;

        if ( maxtime - camtime >= 1 )
            postdelay = maxtime - camtime;
        else
        {
            postdelay = 1;
            camtime = maxtime - 1;
        }

        killcamlength = camtime + postdelay;
    }

    killcamoffset = camtime + predelay;
    self notify( "begin_killcam", gettime() );
    killcamstarttime = gettime() - killcamoffset * 1000;
    self.sessionstate = "spectator";
    self.spectatorclient = attackernum;
    self.killcamentity = -1;

    if ( killcamentityindex >= 0 )
        self thread setkillcamentity( killcamentityindex, killcamentitystarttime - killcamstarttime - 100 );

    self.killcamtargetentity = targetnum;
    self.archivetime = killcamoffset;
    self.killcamlength = killcamlength;
    self.psoffsettime = offsettime;
    recordkillcamsettings( attackernum, targetnum, sweapon, deathtime, deathtimeoffset, offsettime, killcamentityindex, killcamentitystarttime, perks, killstreaks, attacker );

    foreach ( team in level.teams )
        self allowspectateteam( team, 1 );

    self allowspectateteam( "freelook", 1 );
    self allowspectateteam( "none", 1 );
    self thread endedkillcamcleanup();
    wait 0.05;

    if ( self.archivetime <= predelay )
    {
        self.sessionstate = "dead";
        self.spectatorclient = -1;
        self.killcamentity = -1;
        self.archivetime = 0;
        self.psoffsettime = 0;
        self notify( "end_killcam" );
        return;
    }

    self thread checkforabruptkillcamend();
    self.killcam = 1;
    self addkillcamskiptext( respawn );

    if ( !self issplitscreen() && level.perksenabled == 1 )
    {
        self addkillcamtimer( camtime );
        self maps\mp\gametypes\_hud_util::showperks();
    }

    self thread spawnedkillcamcleanup();
    self thread waitskipkillcambutton();
    self thread waitteamchangeendkillcam();
    self thread waitkillcamtime();
    self thread maps\mp\_tacticalinsertion::cancel_button_think();

    self waittill( "end_killcam" );

    self endkillcam( 0 );
    self.sessionstate = "dead";
    self.spectatorclient = -1;
    self.killcamentity = -1;
    self.archivetime = 0;
    self.psoffsettime = 0;
}

setkillcamentity( killcamentityindex, delayms )
{
    self endon( "disconnect" );
    self endon( "end_killcam" );
    self endon( "spawned" );

    if ( delayms > 0 )
        wait( delayms / 1000 );

    self.killcamentity = killcamentityindex;
}

waitkillcamtime()
{
    self endon( "disconnect" );
    self endon( "end_killcam" );
    wait( self.killcamlength - 0.05 );
    self notify( "end_killcam" );
}

waitfinalkillcamslowdown( deathtime, starttime )
{
    self endon( "disconnect" );
    self endon( "end_killcam" );
    secondsuntildeath = ( deathtime - starttime ) / 1000;
    deathtime = gettime() + secondsuntildeath * 1000;
    waitbeforedeath = 2;
    maps\mp\_utility::setclientsysstate( "levelNotify", "fkcb" );
    wait( max( 0, secondsuntildeath - waitbeforedeath ) );
    setslowmotion( 1.0, 0.25, waitbeforedeath );
    wait( waitbeforedeath + 0.5 );
    setslowmotion( 0.25, 1, 1.0 );
    wait 0.5;
    maps\mp\_utility::setclientsysstate( "levelNotify", "fkce" );
}

waitskipkillcambutton()
{
    self endon( "disconnect" );
    self endon( "end_killcam" );

    while ( self usebuttonpressed() )
        wait 0.05;

    while ( !self usebuttonpressed() )
        wait 0.05;

    self notify( "end_killcam" );
    self clientnotify( "fkce" );
}

waitteamchangeendkillcam()
{
    self endon( "disconnect" );
    self endon( "end_killcam" );

    self waittill( "changed_class" );

    endkillcam( 0 );
}

waitskipkillcamsafespawnbutton()
{
    self endon( "disconnect" );
    self endon( "end_killcam" );

    while ( self fragbuttonpressed() )
        wait 0.05;

    while ( !self fragbuttonpressed() )
        wait 0.05;

    self.wantsafespawn = 1;
    self notify( "end_killcam" );
}

endkillcam( final )
{
    if ( isdefined( self.kc_skiptext ) )
        self.kc_skiptext.alpha = 0;

    if ( isdefined( self.kc_timer ) )
        self.kc_timer.alpha = 0;

    self.killcam = undefined;

    if ( !self issplitscreen() )
        self hideallperks();

    self thread maps\mp\gametypes\_spectating::setspectatepermissions();
}

checkforabruptkillcamend()
{
    self endon( "disconnect" );
    self endon( "end_killcam" );

    while ( true )
    {
        if ( self.archivetime <= 0 )
            break;

        wait 0.05;
    }

    self notify( "end_killcam" );
}

spawnedkillcamcleanup()
{
    self endon( "end_killcam" );
    self endon( "disconnect" );

    self waittill( "spawned" );

    self endkillcam( 0 );
}

spectatorkillcamcleanup( attacker )
{
    self endon( "end_killcam" );
    self endon( "disconnect" );
    attacker endon( "disconnect" );

    attacker waittill( "begin_killcam", attackerkcstarttime );

    waittime = max( 0, attackerkcstarttime - self.deathtime - 50 );
    wait( waittime );
    self endkillcam( 0 );
}

endedkillcamcleanup()
{
    self endon( "end_killcam" );
    self endon( "disconnect" );

    level waittill( "game_ended" );

    self endkillcam( 0 );
}

endedfinalkillcamcleanup()
{
    self endon( "end_killcam" );
    self endon( "disconnect" );

    level waittill( "game_ended" );

    self endkillcam( 1 );
}

cancelkillcamusebutton()
{
    return self usebuttonpressed();
}

cancelkillcamsafespawnbutton()
{
    return self fragbuttonpressed();
}

cancelkillcamcallback()
{
    self.cancelkillcam = 1;
}

cancelkillcamsafespawncallback()
{
    self.cancelkillcam = 1;
    self.wantsafespawn = 1;
}

cancelkillcamonuse()
{
    self thread cancelkillcamonuse_specificbutton( ::cancelkillcamusebutton, ::cancelkillcamcallback );
}

cancelkillcamonuse_specificbutton( pressingbuttonfunc, finishedfunc )
{
    self endon( "death_delay_finished" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        if ( !self [[ pressingbuttonfunc ]]() )
        {
            wait 0.05;
            continue;
        }

        buttontime = 0;

        while ( self [[ pressingbuttonfunc ]]() )
        {
            buttontime += 0.05;
            wait 0.05;
        }

        if ( buttontime >= 0.5 )
            continue;

        buttontime = 0;

        while ( !self [[ pressingbuttonfunc ]]() && buttontime < 0.5 )
        {
            buttontime += 0.05;
            wait 0.05;
        }

        if ( buttontime >= 0.5 )
            continue;

        self [[ finishedfunc ]]();
        return;
    }
}

finalkillcam( winner )
{
    self endon( "disconnect" );
    level endon( "game_ended" );

    if ( waslastround() )
    {
        setmatchflag( "final_killcam", 1 );
        setmatchflag( "round_end_killcam", 0 );
    }
    else
    {
        setmatchflag( "final_killcam", 0 );
        setmatchflag( "round_end_killcam", 1 );
    }
/#
    if ( getdvarint( "scr_force_finalkillcam" ) == 1 )
    {
        setmatchflag( "final_killcam", 1 );
        setmatchflag( "round_end_killcam", 0 );
    }
#/
    if ( level.console )
        self maps\mp\gametypes\_globallogic_spawn::setthirdperson( 0 );

    killcamsettings = level.finalkillcamsettings[winner];
    postdeathdelay = ( gettime() - killcamsettings.deathtime ) / 1000;
    predelay = postdeathdelay + killcamsettings.deathtimeoffset;
    camtime = calckillcamtime( killcamsettings.weapon, killcamsettings.entitystarttime, predelay, 0, undefined );
    postdelay = calcpostdelay();
    killcamoffset = camtime + predelay;
    killcamlength = camtime + postdelay - 0.05;
    killcamstarttime = gettime() - killcamoffset * 1000;
    self notify( "begin_killcam", gettime() );
    self.sessionstate = "spectator";
    self.spectatorclient = killcamsettings.spectatorclient;
    self.killcamentity = -1;

    if ( killcamsettings.entityindex >= 0 )
        self thread setkillcamentity( killcamsettings.entityindex, killcamsettings.entitystarttime - killcamstarttime - 100 );

    self.killcamtargetentity = killcamsettings.targetentityindex;
    self.archivetime = killcamoffset;
    self.killcamlength = killcamlength;
    self.psoffsettime = killcamsettings.offsettime;

    foreach ( team in level.teams )
        self allowspectateteam( team, 1 );

    self allowspectateteam( "freelook", 1 );
    self allowspectateteam( "none", 1 );
    self thread endedfinalkillcamcleanup();
    wait 0.05;

    if ( self.archivetime <= predelay )
    {
        self.sessionstate = "dead";
        self.spectatorclient = -1;
        self.killcamentity = -1;
        self.archivetime = 0;
        self.psoffsettime = 0;
        self notify( "end_killcam" );
        return;
    }

    self thread checkforabruptkillcamend();
    self.killcam = 1;

    if ( !self issplitscreen() )
        self addkillcamtimer( camtime );

    self thread waitkillcamtime();
    self thread waitfinalkillcamslowdown( level.finalkillcamsettings[winner].deathtime, killcamstarttime );

    self waittill( "end_killcam" );

    self endkillcam( 1 );
    setmatchflag( "final_killcam", 0 );
    setmatchflag( "round_end_killcam", 0 );
    self spawnendoffinalkillcam();
}

spawnendoffinalkillcam()
{
    [[ level.spawnspectator ]]();
    self freezecontrols( 1 );
}

iskillcamentityweapon( sweapon )
{
    if ( sweapon == "planemortar_mp" )
        return true;

    return false;
}

iskillcamgrenadeweapon( sweapon )
{
    if ( sweapon == "frag_grenade_mp" )
        return true;
    else if ( sweapon == "frag_grenade_short_mp" )
        return true;
    else if ( sweapon == "sticky_grenade_mp" )
        return true;
    else if ( sweapon == "tabun_gas_mp" )
        return true;

    return false;
}

calckillcamtime( sweapon, entitystarttime, predelay, respawn, maxtime )
{
    camtime = 0.0;

    if ( getdvar( _hash_C45D9077 ) == "" )
    {
        if ( iskillcamentityweapon( sweapon ) )
            camtime = ( gettime() - entitystarttime ) / 1000 - predelay - 0.1;
        else if ( !respawn )
            camtime = 5.0;
        else if ( iskillcamgrenadeweapon( sweapon ) )
            camtime = 4.25;
        else
            camtime = 2.5;
    }
    else
        camtime = getdvarfloat( _hash_C45D9077 );

    if ( isdefined( maxtime ) )
    {
        if ( camtime > maxtime )
            camtime = maxtime;

        if ( camtime < 0.05 )
            camtime = 0.05;
    }

    return camtime;
}

calcpostdelay()
{
    postdelay = 0;

    if ( getdvar( _hash_D34D95D ) == "" )
        postdelay = 2;
    else
    {
        postdelay = getdvarfloat( _hash_D34D95D );

        if ( postdelay < 0.05 )
            postdelay = 0.05;
    }

    return postdelay;
}

addkillcamskiptext( respawn )
{
    if ( !isdefined( self.kc_skiptext ) )
    {
        self.kc_skiptext = newclienthudelem( self );
        self.kc_skiptext.archived = 0;
        self.kc_skiptext.x = 0;
        self.kc_skiptext.alignx = "center";
        self.kc_skiptext.aligny = "middle";
        self.kc_skiptext.horzalign = "center";
        self.kc_skiptext.vertalign = "bottom";
        self.kc_skiptext.sort = 1;
        self.kc_skiptext.font = "objective";
    }

    if ( self issplitscreen() )
    {
        self.kc_skiptext.y = -100;
        self.kc_skiptext.fontscale = 1.4;
    }
    else
    {
        self.kc_skiptext.y = -120;
        self.kc_skiptext.fontscale = 2;
    }

    if ( respawn )
        self.kc_skiptext settext( &"PLATFORM_PRESS_TO_RESPAWN" );
    else
        self.kc_skiptext settext( &"PLATFORM_PRESS_TO_SKIP" );

    self.kc_skiptext.alpha = 1;
}

addkillcamtimer( camtime )
{

}

initkcelements()
{
    if ( !isdefined( self.kc_skiptext ) )
    {
        self.kc_skiptext = newclienthudelem( self );
        self.kc_skiptext.archived = 0;
        self.kc_skiptext.x = 0;
        self.kc_skiptext.alignx = "center";
        self.kc_skiptext.aligny = "top";
        self.kc_skiptext.horzalign = "center_adjustable";
        self.kc_skiptext.vertalign = "top_adjustable";
        self.kc_skiptext.sort = 1;
        self.kc_skiptext.font = "default";
        self.kc_skiptext.foreground = 1;
        self.kc_skiptext.hidewheninmenu = 1;

        if ( self issplitscreen() )
        {
            self.kc_skiptext.y = 20;
            self.kc_skiptext.fontscale = 1.2;
        }
        else
        {
            self.kc_skiptext.y = 32;
            self.kc_skiptext.fontscale = 1.8;
        }
    }

    if ( !isdefined( self.kc_othertext ) )
    {
        self.kc_othertext = newclienthudelem( self );
        self.kc_othertext.archived = 0;
        self.kc_othertext.y = 48;
        self.kc_othertext.alignx = "left";
        self.kc_othertext.aligny = "top";
        self.kc_othertext.horzalign = "center";
        self.kc_othertext.vertalign = "middle";
        self.kc_othertext.sort = 10;
        self.kc_othertext.font = "small";
        self.kc_othertext.foreground = 1;
        self.kc_othertext.hidewheninmenu = 1;

        if ( self issplitscreen() )
        {
            self.kc_othertext.x = 16;
            self.kc_othertext.fontscale = 1.2;
        }
        else
        {
            self.kc_othertext.x = 32;
            self.kc_othertext.fontscale = 1.6;
        }
    }

    if ( !isdefined( self.kc_icon ) )
    {
        self.kc_icon = newclienthudelem( self );
        self.kc_icon.archived = 0;
        self.kc_icon.x = 16;
        self.kc_icon.y = 16;
        self.kc_icon.alignx = "left";
        self.kc_icon.aligny = "top";
        self.kc_icon.horzalign = "center";
        self.kc_icon.vertalign = "middle";
        self.kc_icon.sort = 1;
        self.kc_icon.foreground = 1;
        self.kc_icon.hidewheninmenu = 1;
    }

    if ( !self issplitscreen() )
    {
        if ( !isdefined( self.kc_timer ) )
        {
            self.kc_timer = createfontstring( "hudbig", 1.0 );
            self.kc_timer.archived = 0;
            self.kc_timer.x = 0;
            self.kc_timer.alignx = "center";
            self.kc_timer.aligny = "middle";
            self.kc_timer.horzalign = "center_safearea";
            self.kc_timer.vertalign = "top_adjustable";
            self.kc_timer.y = 42;
            self.kc_timer.sort = 1;
            self.kc_timer.font = "hudbig";
            self.kc_timer.foreground = 1;
            self.kc_timer.color = vectorscale( ( 1, 1, 1 ), 0.85 );
            self.kc_timer.hidewheninmenu = 1;
        }
    }
}
