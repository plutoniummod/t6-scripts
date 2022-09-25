// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\gametypes_zm\_weaponobjects;

init()
{
    if ( !isdefined( level.claymores_max_per_player ) )
        level.claymores_max_per_player = 12;

    trigs = getentarray( "claymore_purchase", "targetname" );

    for ( i = 0; i < trigs.size; i++ )
    {
        model = getent( trigs[i].target, "targetname" );

        if ( isdefined( model ) )
            model hide();
    }

    array_thread( trigs, ::buy_claymores );
    level thread give_claymores_after_rounds();
    level.claymores_on_damage = ::satchel_damage;
    level.pickup_claymores = ::pickup_claymores;
    level.pickup_claymores_trigger_listener = ::pickup_claymores_trigger_listener;
    level.claymore_detectiondot = cos( 70 );
    level.claymore_detectionmindist = 20;
    level._effect["claymore_laser"] = loadfx( "weapon/claymore/fx_claymore_laser" );
}

buy_claymores()
{
    self.zombie_cost = 1000;
    self sethintstring( &"ZOMBIE_CLAYMORE_PURCHASE" );
    self setcursorhint( "HINT_NOICON" );
    self endon( "kill_trigger" );

    if ( !isdefined( self.stub ) )
        return;

    if ( isdefined( self.stub ) && !isdefined( self.stub.claymores_triggered ) )
        self.stub.claymores_triggered = 0;

    self.claymores_triggered = self.stub.claymores_triggered;

    while ( true )
    {
        self waittill( "trigger", who );

        if ( who in_revive_trigger() )
            continue;

        if ( who has_powerup_weapon() )
        {
            wait 0.1;
            continue;
        }

        if ( is_player_valid( who ) )
        {
            if ( who.score >= self.zombie_cost )
            {
                if ( !who is_player_placeable_mine( "claymore_zm" ) )
                {
                    play_sound_at_pos( "purchase", self.origin );
                    who maps\mp\zombies\_zm_score::minus_to_player_score( self.zombie_cost );
                    who thread claymore_setup();
                    who thread show_claymore_hint( "claymore_purchased" );
                    who thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "weapon_pickup", "grenade" );

                    if ( isdefined( self.stub ) )
                        self.claymores_triggered = self.stub.claymores_triggered;

                    if ( self.claymores_triggered == 0 )
                    {
                        model = getent( self.target, "targetname" );

                        if ( isdefined( model ) )
                            model thread maps\mp\zombies\_zm_weapons::weapon_show( who );
                        else if ( isdefined( self.clientfieldname ) )
                            level setclientfield( self.clientfieldname, 1 );

                        self.claymores_triggered = 1;

                        if ( isdefined( self.stub ) )
                            self.stub.claymores_triggered = 1;
                    }

                    trigs = getentarray( "claymore_purchase", "targetname" );

                    for ( i = 0; i < trigs.size; i++ )
                        trigs[i] setinvisibletoplayer( who );
                }
                else
                    who thread show_claymore_hint( "already_purchased" );
            }
        }
    }
}

claymore_unitrigger_update_prompt( player )
{
    if ( player is_player_placeable_mine( "claymore_zm" ) )
        return false;

    return true;
}

set_claymore_visible()
{
    players = get_players();
    trigs = getentarray( "claymore_purchase", "targetname" );

    while ( true )
    {
        for ( j = 0; j < players.size; j++ )
        {
            if ( !players[j] is_player_placeable_mine( "claymore_zm" ) )
            {
                for ( i = 0; i < trigs.size; i++ )
                    trigs[i] setinvisibletoplayer( players[j], 0 );
            }
        }

        wait 1;
        players = get_players();
    }
}

claymore_safe_to_plant()
{
    if ( self.owner.claymores.size >= level.claymores_max_per_player )
        return 0;

    if ( isdefined( level.claymore_safe_to_plant ) )
        return self [[ level.claymore_safe_to_plant ]]();

    return 1;
}

claymore_wait_and_detonate()
{
    wait 0.1;
    self detonate( self.owner );
}

claymore_watch()
{
    self endon( "death" );

    while ( true )
    {
        self waittill( "grenade_fire", claymore, weapname );

        if ( weapname == "claymore_zm" )
        {
            claymore.owner = self;
            claymore.team = self.team;
            self notify( "zmb_enable_claymore_prompt" );

            if ( claymore claymore_safe_to_plant() )
            {
                if ( isdefined( level.claymore_planted ) )
                    self thread [[ level.claymore_planted ]]( claymore );

                claymore thread satchel_damage();
                claymore thread claymore_detonation();
                claymore thread play_claymore_effects();
                self maps\mp\zombies\_zm_stats::increment_client_stat( "claymores_planted" );
                self maps\mp\zombies\_zm_stats::increment_player_stat( "claymores_planted" );
            }
            else
                claymore thread claymore_wait_and_detonate();
        }
    }
}

claymore_setup()
{
    if ( !isdefined( self.claymores ) )
        self.claymores = [];

    self thread claymore_watch();
    self giveweapon( "claymore_zm" );
    self set_player_placeable_mine( "claymore_zm" );
    self setactionslot( 4, "weapon", "claymore_zm" );
    self setweaponammostock( "claymore_zm", 2 );
}

adjust_trigger_origin( origin )
{
    origin += vectorscale( ( 0, 0, 1 ), 20.0 );
    return origin;
}

on_spawn_retrieve_trigger( watcher, player )
{
    self maps\mp\gametypes_zm\_weaponobjects::onspawnretrievableweaponobject( watcher, player );

    if ( isdefined( self.pickuptrigger ) )
        self.pickuptrigger sethintlowpriority( 0 );
}

pickup_claymores()
{
    player = self.owner;

    if ( !player hasweapon( "claymore_zm" ) )
    {
        player thread claymore_watch();
        player giveweapon( "claymore_zm" );
        player set_player_placeable_mine( "claymore_zm" );
        player setactionslot( 4, "weapon", "claymore_zm" );
        player setweaponammoclip( "claymore_zm", 0 );
        player notify( "zmb_enable_claymore_prompt" );
    }
    else
    {
        clip_ammo = player getweaponammoclip( self.name );
        clip_max_ammo = weaponclipsize( self.name );

        if ( clip_ammo >= clip_max_ammo )
        {
            player notify( "zmb_disable_claymore_prompt" );
            return;
        }
    }

    self pick_up();
    clip_ammo = player getweaponammoclip( self.name );
    clip_max_ammo = weaponclipsize( self.name );

    if ( clip_ammo >= clip_max_ammo )
        player notify( "zmb_disable_claymore_prompt" );

    player maps\mp\zombies\_zm_stats::increment_client_stat( "claymores_pickedup" );
    player maps\mp\zombies\_zm_stats::increment_player_stat( "claymores_pickedup" );
}

pickup_claymores_trigger_listener( trigger, player )
{
    self thread pickup_claymores_trigger_listener_enable( trigger, player );
    self thread pickup_claymores_trigger_listener_disable( trigger, player );
}

pickup_claymores_trigger_listener_enable( trigger, player )
{
    self endon( "delete" );

    while ( true )
    {
        player waittill_any( "zmb_enable_claymore_prompt", "spawned_player" );

        if ( !isdefined( trigger ) )
            return;

        trigger trigger_on();
        trigger linkto( self );
    }
}

pickup_claymores_trigger_listener_disable( trigger, player )
{
    self endon( "delete" );

    while ( true )
    {
        player waittill( "zmb_disable_claymore_prompt" );

        if ( !isdefined( trigger ) )
            return;

        trigger unlink();
        trigger trigger_off();
    }
}

shouldaffectweaponobject( object )
{
    pos = self.origin + vectorscale( ( 0, 0, 1 ), 32.0 );
    dirtopos = pos - object.origin;
    objectforward = anglestoforward( object.angles );
    dist = vectordot( dirtopos, objectforward );

    if ( dist < level.claymore_detectionmindist )
        return 0;

    dirtopos = vectornormalize( dirtopos );
    dot = vectordot( dirtopos, objectforward );
    return dot > level.claymore_detectiondot;
}

claymore_detonation()
{
    self endon( "death" );
    self waittill_not_moving();
    detonateradius = 96;
    damagearea = spawn( "trigger_radius", self.origin + ( 0, 0, 0 - detonateradius ), 4, detonateradius, detonateradius * 2 );
    damagearea setexcludeteamfortrigger( self.team );
    damagearea enablelinkto();
    damagearea linkto( self );

    if ( is_true( self.isonbus ) )
        damagearea setmovingplatformenabled( 1 );

    self.damagearea = damagearea;
    self thread delete_claymores_on_death( self.owner, damagearea );
    self.owner.claymores[self.owner.claymores.size] = self;

    while ( true )
    {
        damagearea waittill( "trigger", ent );

        if ( isdefined( self.owner ) && ent == self.owner )
            continue;

        if ( isdefined( ent.pers ) && isdefined( ent.pers["team"] ) && ent.pers["team"] == self.team )
            continue;

        if ( !ent shouldaffectweaponobject( self ) )
            continue;

        if ( ent damageconetrace( self.origin, self ) > 0 )
        {
            self playsound( "wpn_claymore_alert" );
            wait 0.4;

            if ( isdefined( self.owner ) )
                self detonate( self.owner );
            else
                self detonate( undefined );

            return;
        }
    }
}

delete_claymores_on_death( player, ent )
{
    self waittill( "death" );

    if ( isdefined( player ) )
        arrayremovevalue( player.claymores, self );

    wait 0.05;

    if ( isdefined( ent ) )
        ent delete();
}

satchel_damage()
{
    self setcandamage( 1 );
    self.health = 100000;
    self.maxhealth = self.health;
    attacker = undefined;

    while ( true )
    {
        self waittill( "damage", amount, attacker );

        if ( !isdefined( self ) )
            return;

        self.health = self.maxhealth;

        if ( !isplayer( attacker ) )
            continue;

        if ( isdefined( self.owner ) && attacker == self.owner )
            continue;

        if ( isdefined( attacker.pers ) && isdefined( attacker.pers["team"] ) && attacker.pers["team"] != level.zombie_team )
            continue;

        break;
    }

    if ( level.satchelexplodethisframe )
        wait( 0.1 + randomfloat( 0.4 ) );
    else
        wait 0.05;

    if ( !isdefined( self ) )
        return;

    level.satchelexplodethisframe = 1;
    thread reset_satchel_explode_this_frame();
    self detonate( attacker );
}

reset_satchel_explode_this_frame()
{
    wait 0.05;
    level.satchelexplodethisframe = 0;
}

play_claymore_effects()
{
    self endon( "death" );
    self waittill_not_moving();
    playfxontag( level._effect["claymore_laser"], self, "tag_fx" );
}

give_claymores_after_rounds()
{
    while ( true )
    {
        level waittill( "between_round_over" );

        if ( !level flag_exists( "teleporter_used" ) || !flag( "teleporter_used" ) )
        {
            players = get_players();

            for ( i = 0; i < players.size; i++ )
            {
                if ( players[i] is_player_placeable_mine( "claymore_zm" ) )
                {
                    players[i] giveweapon( "claymore_zm" );
                    players[i] set_player_placeable_mine( "claymore_zm" );
                    players[i] setactionslot( 4, "weapon", "claymore_zm" );
                    players[i] setweaponammoclip( "claymore_zm", 2 );
                }
            }
        }
    }
}

init_hint_hudelem( x, y, alignx, aligny, fontscale, alpha )
{
    self.x = x;
    self.y = y;
    self.alignx = alignx;
    self.aligny = aligny;
    self.fontscale = fontscale;
    self.alpha = alpha;
    self.sort = 20;
}

setup_client_hintelem()
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( !isdefined( self.hintelem ) )
        self.hintelem = newclienthudelem( self );

    self.hintelem init_hint_hudelem( 320, 220, "center", "bottom", 1.6, 1.0 );
}

show_claymore_hint( string )
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( string == "claymore_purchased" )
        text = &"ZOMBIE_CLAYMORE_HOWTO";
    else
        text = &"ZOMBIE_CLAYMORE_ALREADY_PURCHASED";

    self setup_client_hintelem();
    self.hintelem settext( text );
    wait 3.5;
    self.hintelem settext( "" );
}
