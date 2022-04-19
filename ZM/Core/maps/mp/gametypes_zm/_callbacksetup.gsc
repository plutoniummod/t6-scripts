// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\_audio;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\gametypes_zm\_globallogic_player;
#include maps\mp\gametypes_zm\_globallogic_actor;
#include maps\mp\gametypes_zm\_hostmigration;

codecallback_startgametype()
{
    if ( !isdefined( level.gametypestarted ) || !level.gametypestarted )
    {
        [[ level.callbackstartgametype ]]();
        level.gametypestarted = 1;
    }
}

codecallback_finalizeinitialization()
{
    maps\mp\_utility::callback( "on_finalize_initialization" );
}

codecallback_playerconnect()
{
    self endon( "disconnect" );
    self thread maps\mp\_audio::monitor_player_sprint();
    [[ level.callbackplayerconnect ]]();
}

codecallback_playerdisconnect()
{
    self notify( "disconnect" );
    client_num = self getentitynumber();
    [[ level.callbackplayerdisconnect ]]();
}

codecallback_hostmigration()
{
/#
    println( "****CodeCallback_HostMigration****" );
#/
    [[ level.callbackhostmigration ]]();
}

codecallback_hostmigrationsave()
{
/#
    println( "****CodeCallback_HostMigrationSave****" );
#/
    [[ level.callbackhostmigrationsave ]]();
}

codecallback_prehostmigrationsave()
{
/#
    println( "****CodeCallback_PreHostMigrationSave****" );
#/
    [[ level.callbackprehostmigrationsave ]]();
}

codecallback_playermigrated()
{
/#
    println( "****CodeCallback_PlayerMigrated****" );
#/
    [[ level.callbackplayermigrated ]]();
}

codecallback_playerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex )
{
    self endon( "disconnect" );
    [[ level.callbackplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex );
}

codecallback_playerkilled( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset, deathanimduration )
{
    self endon( "disconnect" );
    [[ level.callbackplayerkilled ]]( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset, deathanimduration );
}

codecallback_playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset, deathanimduration )
{
    self endon( "disconnect" );
    [[ level.callbackplayerlaststand ]]( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset, deathanimduration );
}

codecallback_playermelee( eattacker, idamage, sweapon, vorigin, vdir, boneindex, shieldhit )
{
    self endon( "disconnect" );
    [[ level.callbackplayermelee ]]( eattacker, idamage, sweapon, vorigin, vdir, boneindex, shieldhit );
}

codecallback_actordamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex )
{
    [[ level.callbackactordamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex );
}

codecallback_actorkilled( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset )
{
    [[ level.callbackactorkilled ]]( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, timeoffset );
}

codecallback_vehicledamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, damagefromunderneath, modelindex, partname )
{
    [[ level.callbackvehicledamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, damagefromunderneath, modelindex, partname );
}

codecallback_vehicleradiusdamage( einflictor, eattacker, idamage, finnerdamage, fouterdamage, idflags, smeansofdeath, sweapon, vpoint, fradius, fconeanglecos, vconedir, timeoffset )
{

}

codecallback_faceeventnotify( notify_msg, ent )
{
    if ( isdefined( ent ) && isdefined( ent.do_face_anims ) && ent.do_face_anims )
    {
        if ( isdefined( level.face_event_handler ) && isdefined( level.face_event_handler.events[notify_msg] ) )
            ent sendfaceevent( level.face_event_handler.events[notify_msg] );
    }
}

codecallback_menuresponse( action, arg )
{
    if ( !isdefined( level.menuresponsequeue ) )
    {
        level.menuresponsequeue = [];
        level thread menuresponsequeuepump();
    }

    index = level.menuresponsequeue.size;
    level.menuresponsequeue[index] = spawnstruct();
    level.menuresponsequeue[index].action = action;
    level.menuresponsequeue[index].arg = arg;
    level.menuresponsequeue[index].ent = self;
    level notify( "menuresponse_queue" );
}

menuresponsequeuepump()
{
    while ( true )
    {
        level waittill( "menuresponse_queue" );

        do
        {
            level.menuresponsequeue[0].ent notify( "menuresponse", level.menuresponsequeue[0].action, level.menuresponsequeue[0].arg );
            arrayremoveindex( level.menuresponsequeue, 0, 0 );
            wait 0.05;
        }
        while ( level.menuresponsequeue.size > 0 );
    }
}

setupcallbacks()
{
    setdefaultcallbacks();
    level.idflags_radius = 1;
    level.idflags_no_armor = 2;
    level.idflags_no_knockback = 4;
    level.idflags_penetration = 8;
    level.idflags_destructible_entity = 16;
    level.idflags_shield_explosive_impact = 32;
    level.idflags_shield_explosive_impact_huge = 64;
    level.idflags_shield_explosive_splash = 128;
    level.idflags_no_team_protection = 256;
    level.idflags_no_protection = 512;
    level.idflags_passthru = 1024;
}

setdefaultcallbacks()
{
    level.callbackstartgametype = maps\mp\gametypes_zm\_globallogic::callback_startgametype;
    level.callbackplayerconnect = maps\mp\gametypes_zm\_globallogic_player::callback_playerconnect;
    level.callbackplayerdisconnect = maps\mp\gametypes_zm\_globallogic_player::callback_playerdisconnect;
    level.callbackplayerdamage = maps\mp\gametypes_zm\_globallogic_player::callback_playerdamage;
    level.callbackplayerkilled = maps\mp\gametypes_zm\_globallogic_player::callback_playerkilled;
    level.callbackplayermelee = maps\mp\gametypes_zm\_globallogic_player::callback_playermelee;
    level.callbackplayerlaststand = maps\mp\gametypes_zm\_globallogic_player::callback_playerlaststand;
    level.callbackactordamage = maps\mp\gametypes_zm\_globallogic_actor::callback_actordamage;
    level.callbackactorkilled = maps\mp\gametypes_zm\_globallogic_actor::callback_actorkilled;
    level.callbackplayermigrated = maps\mp\gametypes_zm\_globallogic_player::callback_playermigrated;
    level.callbackhostmigration = maps\mp\gametypes_zm\_hostmigration::callback_hostmigration;
    level.callbackhostmigrationsave = maps\mp\gametypes_zm\_hostmigration::callback_hostmigrationsave;
    level.callbackprehostmigrationsave = maps\mp\gametypes_zm\_hostmigration::callback_prehostmigrationsave;
}

abortlevel()
{
/#
    println( "ERROR: Aborting level - gametype is not supported" );
#/
    level.callbackstartgametype = ::callbackvoid;
    level.callbackplayerconnect = ::callbackvoid;
    level.callbackplayerdisconnect = ::callbackvoid;
    level.callbackplayerdamage = ::callbackvoid;
    level.callbackplayerkilled = ::callbackvoid;
    level.callbackplayermelee = ::callbackvoid;
    level.callbackplayerlaststand = ::callbackvoid;
    level.callbackactordamage = ::callbackvoid;
    level.callbackactorkilled = ::callbackvoid;
    level.callbackvehicledamage = ::callbackvoid;
    setdvar( "g_gametype", "dm" );
    exitlevel( 0 );
}

codecallback_glasssmash( pos, dir )
{
    level notify( "glass_smash", pos, dir );
}

callbackvoid()
{

}
