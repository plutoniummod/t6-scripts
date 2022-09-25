// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes\_weapons;
#include common_scripts\utility;
#include maps\mp\killstreaks\_killstreaks;
#include maps\mp\killstreaks\_supplydrop;
#include maps\mp\killstreaks\_airsupport;
#include maps\mp\gametypes\_spawnlogic;
#include maps\mp\killstreaks\_killstreakrules;
#include maps\mp\killstreaks\_emp;
#include maps\mp\_entityheadicons;
#include maps\mp\gametypes\_spawning;
#include maps\mp\killstreaks\_remote_weapons;
#include maps\mp\_challenges;
#include maps\mp\_scoreevents;
#include maps\mp\killstreaks\_dogs;
#include maps\mp\killstreaks\_radar;
#include maps\mp\gametypes\_hud;
#include maps\mp\gametypes\_dev;

#using_animtree("mp_vehicles");

init()
{
    precachevehicle( "ai_tank_drone_mp" );
    precachemodel( "veh_t6_drone_tank" );
    precachemodel( "veh_t6_drone_tank_alt" );
    precacheitem( "ai_tank_drone_rocket_mp" );
    precacheitem( "killstreak_ai_tank_mp" );
    precacheshader( "mech_check_line" );
    precacheshader( "mech_check_fill" );
    precacheshader( "mech_flame_bar" );
    precacheshader( "mech_flame_arrow_flipped" );
    loadfx( "vehicle/treadfx/fx_treadfx_talon_dirt" );
    loadfx( "vehicle/treadfx/fx_treadfx_talon_concrete" );
    loadfx( "light/fx_vlight_talon_eye_grn" );
    loadfx( "light/fx_vlight_talon_eye_red" );
    loadfx( "weapon/talon/fx_talon_emp_stun" );
    level.ai_tank_minigun_flash_3p = loadfx( "weapon/talon/fx_muz_talon_rocket_flash_1p" );
    registerkillstreak( "inventory_ai_tank_drop_mp", "inventory_ai_tank_drop_mp", "killstreak_ai_tank_drop", "ai_tank_drop_used", ::usekillstreakaitankdrop );
    registerkillstreakaltweapon( "inventory_ai_tank_drop_mp", "ai_tank_drone_gun_mp" );
    registerkillstreakaltweapon( "inventory_ai_tank_drop_mp", "ai_tank_drone_rocket_mp" );
    registerkillstreakremoteoverrideweapon( "inventory_ai_tank_drop_mp", "killstreak_ai_tank_mp" );
    registerkillstreakstrings( "inventory_ai_tank_drop_mp", &"KILLSTREAK_EARNED_AI_TANK_DROP", &"KILLSTREAK_AI_TANK_NOT_AVAILABLE", &"KILLSTREAK_AI_TANK_INBOUND" );
    registerkillstreakdialog( "inventory_ai_tank_drop_mp", "mpl_killstreak_ai_tank", "kls_aitank_used", "", "kls_aitank_enemy", "", "kls_aitank_ready" );
    registerkillstreakdevdvar( "inventory_ai_tank_drop_mp", "scr_giveaitankdrop" );
    registerkillstreak( "ai_tank_drop_mp", "ai_tank_drop_mp", "killstreak_ai_tank_drop", "ai_tank_drop_used", ::usekillstreakaitankdrop );
    registerkillstreakaltweapon( "ai_tank_drop_mp", "ai_tank_drone_gun_mp" );
    registerkillstreakaltweapon( "ai_tank_drop_mp", "ai_tank_drone_rocket_mp" );
    registerkillstreakremoteoverrideweapon( "ai_tank_drop_mp", "killstreak_ai_tank_mp" );
    registerkillstreakstrings( "ai_tank_drop_mp", &"KILLSTREAK_EARNED_AI_TANK_DROP", &"KILLSTREAK_AI_TANK_NOT_AVAILABLE", &"KILLSTREAK_AI_TANK_INBOUND" );
    registerkillstreakdialog( "ai_tank_drop_mp", "mpl_killstreak_ai_tank", "kls_aitank_used", "", "kls_aitank_enemy", "", "kls_aitank_ready" );
    level.ai_tank_fov = cos( 160 );
    level.ai_tank_turret_fire_rate = weaponfiretime( "ai_tank_drone_gun_mp" );
    level.ai_tank_valid_locations = [];
    spawns = maps\mp\gametypes\_spawnlogic::getspawnpointarray( "mp_tdm_spawn" );
    level.ai_tank_damage_fx = loadfx( "weapon/talon/fx_talon_damage_state" );
    level.ai_tank_explode_fx = loadfx( "weapon/talon/fx_talon_exp" );
    level.ai_tank_crate_explode_fx = loadfx( "weapon/talon/fx_talon_drop_box" );

    foreach ( spawn in spawns )
        level.ai_tank_valid_locations[level.ai_tank_valid_locations.size] = spawn.origin;

    anims = [];
    anims[anims.size] = %o_drone_tank_missile1_fire;
    anims[anims.size] = %o_drone_tank_missile2_fire;
    anims[anims.size] = %o_drone_tank_missile3_fire;
    anims[anims.size] = %o_drone_tank_missile_full_reload;
    setdvar( "scr_ai_tank_no_timeout", 0 );
/#
    level thread tank_devgui_think();
#/
}

register()
{
    registerclientfield( "vehicle", "ai_tank_death", 1, 1, "int" );
    registerclientfield( "vehicle", "ai_tank_hack_spawned", 1, 1, "int" );
    registerclientfield( "vehicle", "ai_tank_hack_rebooting", 1, 1, "int" );
    registerclientfield( "vehicle", "ai_tank_missile_fire", 1, 3, "int" );
}

usekillstreakaitankdrop( hardpointtype )
{
    team = self.team;

    if ( !self maps\mp\killstreaks\_supplydrop::issupplydropgrenadeallowed( hardpointtype ) )
        return 0;

    killstreak_id = self maps\mp\killstreaks\_killstreakrules::killstreakstart( hardpointtype, team, 0, 0 );

    if ( killstreak_id == -1 )
        return 0;

    result = self maps\mp\killstreaks\_supplydrop::usesupplydropmarker( killstreak_id );
    self notify( "supply_drop_marker_done" );

    if ( !isdefined( result ) || !result )
    {
        maps\mp\killstreaks\_killstreakrules::killstreakstop( hardpointtype, team, killstreak_id );
        return 0;
    }

    return result;
}

crateland( crate, weaponname, owner, team )
{
    if ( !crate valid_location() || !isdefined( owner ) || team != owner.team || owner maps\mp\killstreaks\_emp::isenemyempkillstreakactive() )
    {
        maps\mp\killstreaks\_killstreakrules::killstreakstop( weaponname, team, crate.package_contents_id );
        wait 10;
        crate delete();
        return;
    }

    origin = crate.origin;
    cratebottom = bullettrace( origin, origin + vectorscale( ( 0, 0, -1 ), 50.0 ), 0, crate );

    if ( isdefined( cratebottom ) )
        origin = cratebottom["position"] + ( 0, 0, 1 );

    playfx( level.ai_tank_crate_explode_fx, origin, ( 1, 0, 0 ), ( 0, 0, 1 ) );
    playsoundatposition( "veh_talon_crate_exp", crate.origin );
    level thread ai_tank_killstreak_start( owner, origin, crate.package_contents_id, weaponname );
    crate delete();
}

valid_location()
{
    node = getnearestnode( self.origin );

    if ( !isdefined( node ) )
        return false;

    start = self getcentroid();
    end = node.origin + vectorscale( ( 0, 0, 1 ), 8.0 );
    trace = physicstrace( start, end, ( 0, 0, 0 ), ( 0, 0, 0 ), self, level.physicstracecontentsvehicleclip );

    if ( trace["fraction"] < 1 )
        return false;

    origin = self.origin + vectorscale( ( 0, 0, 1 ), 32.0 );
    level.ai_tank_valid_locations = array_randomize( level.ai_tank_valid_locations );
    count = min( level.ai_tank_valid_locations.size, 5 );

    for ( i = 0; i < count; i++ )
    {
        if ( findpath( origin, level.ai_tank_valid_locations[i], self, 0, 1 ) )
            return true;
    }

    return false;
}

ai_tank_killstreak_start( owner, origin, killstreak_id, weaponname )
{
    waittillframeend;
    drone = spawnvehicle( "veh_t6_drone_tank", "talon", "ai_tank_drone_mp", origin, ( 0, 0, 0 ) );
    drone setenemymodel( "veh_t6_drone_tank_alt" );
    drone playloopsound( "veh_talon_idle_npc", 0.2 );
    drone setvehicleavoidance( 1 );
    drone setclientfield( "ai_tank_missile_fire", 4 );
    drone setowner( owner );
    drone.owner = owner;
    drone.team = owner.team;
    drone.aiteam = owner.team;
    drone.killstreak_id = killstreak_id;
    drone.type = "tank_drone";

    if ( level.teambased )
        drone setteam( owner.team );
    else
        drone setteam( "free" );

    drone maps\mp\_entityheadicons::setentityheadicon( drone.team, drone, vectorscale( ( 0, 0, 1 ), 52.0 ) );
    drone maps\mp\gametypes\_spawning::create_aitank_influencers( drone.team );
    drone.controlled = 0;
    drone makevehicleunusable();
    drone.numberrockets = 3;
    drone.warningshots = 3;
    drone setdrawinfrared( 1 );

    if ( !isdefined( drone.owner.numtankdrones ) )
        drone.owner.numtankdrones = 1;
    else
        drone.owner.numtankdrones++;

    drone.ownernumber = drone.owner.numtankdrones;
    target_set( drone, vectorscale( ( 0, 0, 1 ), 20.0 ) );
    target_setturretaquire( drone, 0 );
    drone thread tank_move_think();
    drone thread tank_aim_think();
    drone thread tank_combat_think();
    drone thread tank_death_think( weaponname );
    drone thread tank_damage_think();
    drone thread tank_abort_think();
    drone thread tank_team_kill();
    drone thread tank_ground_abort_think();
    drone thread tank_riotshield_think();
    drone thread tank_rocket_think();
    owner maps\mp\killstreaks\_remote_weapons::initremoteweapon( drone, "killstreak_ai_tank_mp" );
    drone thread deleteonkillbrush( drone.owner );
    level thread tank_game_end_think( drone );
/#

#/
}

tank_team_kill()
{
    self endon( "death" );

    self.owner waittill( "teamKillKicked" );

    self notify( "death" );
}

tank_abort_think()
{
    self endon( "death" );
    self.owner wait_endon( 120, "disconnect", "joined_team", "joined_spectators", "emp_jammed" );
    shouldtimeout = getdvar( "scr_ai_tank_no_timeout" );

    if ( shouldtimeout == "1" )
        return;

    self notify( "death" );
}

tank_game_end_think( drone )
{
    drone endon( "death" );

    level waittill( "game_ended" );

    drone notify( "death" );
}

stop_remote()
{
    if ( !isdefined( self ) )
        return;

    self clearusingremote();
    self.killstreak_waitamount = undefined;
    self destroy_remote_hud();
    self clientnotify( "nofutz" );
}

tank_damage_think()
{
    self endon( "death" );
    self.maxhealth = 999999;
    self.health = self.maxhealth;
    self.isstunned = 0;
    low_health = 0;
    damage_taken = 0;

    for (;;)
    {
        self waittill( "damage", damage, attacker, dir, point, mod, model, tag, part, weapon, flags );

        self.maxhealth = 999999;
        self.health = self.maxhealth;
/#
        self.damage_debug = damage + " (" + weapon + ")";
#/
        if ( weapon == "emp_grenade_mp" && mod == "MOD_GRENADE_SPLASH" )
        {
            damage_taken += 400.0;
            damage = 0;

            if ( !self.isstunned )
            {
                maps\mp\_challenges::stunnedtankwithempgrenade( attacker );
                self thread tank_stun( 4 );
                self.isstunned = 1;
            }
        }

        if ( !self.isstunned )
        {
            if ( ( weapon == "proximity_grenade_mp" || weapon == "proximity_grenade_aoe_mp" ) && ( mod == "MOD_GRENADE_SPLASH" || mod == "MOD_GAS" ) )
            {
                self thread tank_stun( 1.5 );
                self.isstunned = 1;
            }
        }

        if ( mod == "MOD_RIFLE_BULLET" || mod == "MOD_PISTOL_BULLET" || weapon == "hatchet_mp" || mod == "MOD_PROJECTILE_SPLASH" && isexplosivebulletweapon( weapon ) )
        {
            if ( isplayer( attacker ) )
            {
                if ( attacker hasperk( "specialty_armorpiercing" ) )
                    damage += int( damage * level.cac_armorpiercing_data );
            }

            if ( weaponclass( weapon ) == "spread" )
                damage *= 4.5;

            damage *= 0.3;
        }

        if ( ( mod == "MOD_PROJECTILE" || mod == "MOD_GRENADE_SPLASH" || mod == "MOD_PROJECTILE_SPLASH" ) && damage != 0 && weapon != "emp_grenade_mp" && !isexplosivebulletweapon( weapon ) )
            damage *= 1.5;

        if ( self.controlled )
            self.owner sendkillstreakdamageevent( int( damage ) );

        damage_taken += damage;

        if ( damage_taken >= 800 )
        {
            self notify( "death", attacker, mod, weapon );
            return;
        }

        if ( !low_health && damage_taken > 444.444 )
        {
            self thread tank_low_health_fx();
            low_health = 1;
        }

        if ( isdefined( attacker ) && isplayer( attacker ) && self tank_is_idle() && !self.isstunned )
        {
            self.aim_entity.origin = attacker getcentroid();
            self.aim_entity.delay = 8;
            self notify( "aim_updated" );
        }
    }
}

tank_low_health_fx()
{
    self endon( "death" );
    self.damage_fx = spawn( "script_model", self gettagorigin( "tag_origin" ) + vectorscale( ( 0, 0, -1 ), 14.0 ) );
    self.damage_fx setmodel( "tag_origin" );
    self.damage_fx linkto( self, "tag_turret", vectorscale( ( 0, 0, -1 ), 14.0 ), ( 0, 0, 0 ) );
    wait 0.1;
    playfxontag( level.ai_tank_damage_fx, self.damage_fx, "tag_origin" );
}

deleteonkillbrush( player )
{
    player endon( "disconnect" );
    self endon( "death" );
    killbrushes = getentarray( "trigger_hurt", "classname" );

    while ( true )
    {
        for ( i = 0; i < killbrushes.size; i++ )
        {
            if ( self istouching( killbrushes[i] ) )
            {
                if ( isdefined( self ) )
                    self notify( "death", self.owner );

                return;
            }
        }

        wait 0.1;
    }
}

tank_stun( duration )
{
    self endon( "death" );
    self notify( "stunned" );
    self clearvehgoalpos();
    forward = anglestoforward( self.angles );
    forward = self.origin + forward * 128;
    forward -= vectorscale( ( 0, 0, 1 ), 64.0 );
    self setturrettargetvec( forward );
    self disablegunnerfiring( 0, 1 );
    self laseroff();

    if ( self.controlled )
    {
        self.owner freezecontrols( 1 );
        self.owner sendkillstreakdamageevent( 400 );
    }

    if ( isdefined( self.owner.fullscreen_static ) )
        self.owner thread maps\mp\killstreaks\_remote_weapons::stunstaticfx( duration );

    self setclientflag( 3 );
    wait( duration );
    self clearclientflag( 3 );

    if ( self.controlled )
        self.owner freezecontrols( 0 );

    if ( self.controlled == 0 )
    {
        self thread tank_move_think();
        self thread tank_aim_think();
        self thread tank_combat_think();
    }

    self disablegunnerfiring( 0, 0 );
    self.isstunned = 0;
}

emp_crazy_death()
{
    self setclientflag( 3 );
    wait 1;
    self notify( "death" );
    time = 0;
    randomangle = randomint( 360 );

    while ( time < 1.45 )
    {
        self setturrettargetvec( self.origin + anglestoforward( ( randomintrange( 305, 315 ), int( randomangle + time * 180 ), 0 ) ) * 100 );

        if ( time > 0.2 )
        {
            self fireweapon();

            if ( randomint( 100 ) > 85 )
            {
                rocket = self firegunnerweapon( 0 );

                if ( isdefined( rocket ) )
                    rocket.from_ai = 1;
            }
        }

        time += 0.05;
        wait 0.05;
    }

    self setclientfield( "ai_tank_death", 1 );
    playfx( level.ai_tank_explode_fx, self.origin, ( 0, 0, 1 ) );
    playsoundatposition( "wpn_agr_explode", self.origin );
    wait 0.05;
    self hide();
}

tank_death_think( hardpointname )
{
    team = self.team;

    self waittill( "death", attacker, type, weapon );

    self.dead = 1;
    self laseroff();
    self clearvehgoalpos();

    if ( self.controlled == 1 && isdefined( self.owner ) )
    {
        self.owner sendkillstreakdamageevent( 600 );
        self.owner destroy_remote_hud();
    }

    if ( self.isstunned )
    {
        stunned = 1;
        self thread emp_crazy_death();
        wait 1.55;
    }
    else
    {
        self setclientfield( "ai_tank_death", 1 );
        stunned = 0;
        playfx( level.ai_tank_explode_fx, self.origin, ( 0, 0, 1 ) );
        playsoundatposition( "wpn_agr_explode", self.origin );
        wait 0.05;
        self hide();

        if ( isdefined( self.damage_fx ) )
            self.damage_fx delete();
    }

    if ( isdefined( attacker ) && isplayer( attacker ) && isdefined( self.owner ) && attacker != self.owner )
    {
        if ( self.owner isenemyplayer( attacker ) )
        {
            maps\mp\_scoreevents::processscoreevent( "destroyed_aitank", attacker, self.owner, weapon );
            attacker addweaponstat( weapon, "destroyed_aitank", 1 );

            if ( isdefined( self.wascontrollednowdead ) && self.wascontrollednowdead )
                attacker addweaponstat( weapon, "destroyed_controlled_killstreak", 1 );
        }
        else
        {

        }
    }

    wait 2;
    maps\mp\killstreaks\_killstreakrules::killstreakstop( hardpointname, team, self.killstreak_id );
    self.aim_entity delete();
    self delete();
}

tank_move_think()
{
    self endon( "death" );
    self endon( "stunned" );
    self endon( "remote_start" );
    level endon( "game_ended" );
/#
    self endon( "debug_patrol" );
#/
    do_wait = 1;

    for (;;)
    {
        if ( do_wait )
            wait( randomfloatrange( 1, 4 ) );

        do_wait = 1;

        if ( !tank_is_idle() )
        {
            enemy = tank_get_target();

            if ( valid_target( enemy, self.team, self.owner ) )
            {
                if ( distancesquared( self.origin, enemy.origin ) < 65536 )
                {
                    self clearvehgoalpos();
                    wait 1;
                }
                else if ( findpath( self.origin, enemy.origin, self, 0 ) )
                {
                    self setvehgoalpos( enemy.origin, 1, 2 );
                    self wait_endon( 3, "reached_end_node" );
                }
                else
                {
                    self clearvehgoalpos();
                    wait 1;
                }

                if ( valid_target( enemy, self.team, self.owner ) )
                    do_wait = 0;

                continue;
            }
        }

        avg_position = tank_compute_enemy_position();

        if ( isdefined( avg_position ) )
            nodes = getnodesinradiussorted( avg_position, 256, 0 );
        else
            nodes = getnodesinradiussorted( self.owner.origin, 1024, 256, 128 );

        if ( nodes.size > 0 )
            node = nodes[0];
        else
            continue;

        if ( self setvehgoalpos( node.origin, 1, 2 ) )
        {
            event = self waittill_any_timeout( 45, "reached_end_node", "force_movement_wake" );

            if ( event != "reached_end_node" )
                do_wait = 0;

            continue;
        }

        self clearvehgoalpos();
    }
}

tank_riotshield_think()
{
    self endon( "death" );
    self endon( "remote_start" );

    for (;;)
    {
        level waittill( "riotshield_planted", owner );

        if ( owner == self.owner || owner.team == self.team )
        {
            if ( distancesquared( owner.riotshieldentity.origin, self.origin ) < 262144 )
                self clearvehgoalpos();

            self notify( "force_movement_wake" );
        }
    }
}

tank_ground_abort_think()
{
    self endon( "death" );
    ground_trace_fail = 0;

    for (;;)
    {
        wait 1;
        nodes = getnodesinradius( self.origin, 256, 0, 128, "Path" );

        if ( nodes.size <= 0 )
            ground_trace_fail++;
        else
            ground_trace_fail = 0;

        if ( ground_trace_fail >= 4 )
            self notify( "death" );
    }
}

tank_aim_think()
{
    self endon( "death" );
    self endon( "stunned" );
    self endon( "remote_start" );

    if ( !isdefined( self.aim_entity ) )
        self.aim_entity = spawn( "script_model", ( 0, 0, 0 ) );

    self.aim_entity.delay = 0;
    self tank_idle();

    for (;;)
    {
        self wait_endon( randomfloatrange( 1, 3 ), "aim_updated" );

        if ( self.aim_entity.delay > 0 )
        {
            wait( self.aim_entity.delay );
            self.aim_entity.delay = 0;
            continue;
        }

        if ( !tank_is_idle() )
            continue;

        if ( self getspeed() <= 1 )
        {
            enemies = tank_get_player_enemies( 0 );

            if ( enemies.size )
            {
                enemy = enemies[0];
                node = getvisiblenode( self.origin, enemy.origin, self );

                if ( isdefined( node ) )
                {
                    self.aim_entity.origin = node.origin + vectorscale( ( 0, 0, 1 ), 16.0 );
                    continue;
                }
            }
        }

        yaw = ( 0, self.angles[1] + randomintrange( -75, 75 ), 0 );
        forward = anglestoforward( yaw );
        origin = self.origin + forward * 1024;
        self.aim_entity.origin = ( origin[0], origin[1], origin[2] + 20 );
    }
}

tank_combat_think()
{
    self endon( "death" );
    self endon( "stunned" );
    self endon( "remote_start" );
    level endon( "game_ended" );

    for (;;)
    {
        wait 0.5;
        self laseroff();
        origin = self.origin + vectorscale( ( 0, 0, 1 ), 32.0 );
        forward = vectornormalize( self.target_entity.origin - self.origin );
        players = tank_get_player_enemies( 0 );
        self tank_target_evaluate( players, origin, forward );

        if ( level.gametype != "hack" )
        {
            dogs = maps\mp\killstreaks\_dogs::dog_manager_get_dogs();
            self tank_target_evaluate( dogs, origin, forward );
            tanks = getentarray( "talon", "targetname" );
            self tank_target_evaluate( tanks, origin, forward );
            rcbombs = getentarray( "rcbomb", "targetname" );
            self tank_target_evaluate( rcbombs, origin, forward );
            turrets = getentarray( "auto_turret", "classname" );
            self tank_target_evaluate( turrets, origin, forward );
            shields = getentarray( "riotshield_mp", "targetname" );
            self tank_target_evaluate( shields, origin, forward );
        }
    }
}

tank_target_evaluate( targets, origin, forward )
{
    foreach ( target in targets )
    {
        if ( !valid_target( target, self.team, self.owner ) )
            continue;

        delta = target.origin - origin;
        delta = vectornormalize( delta );
        dot = vectordot( forward, delta );

        if ( dot < level.ai_tank_fov )
            continue;

        if ( !bullettracepassed( origin, target getcentroid(), 0, target ) )
            continue;

        self tank_engage( target );
        break;
    }

    self tank_idle();
}

tank_engage( enemy )
{
    do_fire_delay = 1;
    warning_shots = self.warningshots;
    self laseron();

    for (;;)
    {
        if ( !valid_target( enemy, self.team, self.owner ) )
            return;

        fire_rocket = warning_shots <= 2 && self tank_should_fire_rocket( enemy );
        self tank_set_target( enemy, fire_rocket );

        if ( fire_rocket )
            self clearvehgoalpos();

        event = self waittill_any_return( "turret_on_vistarget", "turret_no_vis" );

        if ( !valid_target( enemy, self.team, self.owner ) )
            return;

        self.aim_entity.origin = enemy getcentroid();
        distsq = distancesquared( self.origin, enemy.origin );

        if ( distsq > 4096 && event == "turret_no_vis" )
        {
            self tank_target_lost();

            if ( self tank_is_idle() )
                return;

            continue;
        }
        else
            self notify( "force_movement_wake" );

        if ( event == "turret_no_vis" )
            warning_shots = self.warningshots;

        if ( do_fire_delay )
        {
            self playsound( "wpn_metalstorm_lock_on" );
            wait( randomfloatrange( 0.4, 0.8 ) );
            do_fire_delay = 0;

            if ( !valid_target( enemy, self.team, self.owner ) )
                return;
        }

        if ( fire_rocket )
        {
            rocket = self firegunnerweapon( 0, self.owner );
            self notify( "missile_fire" );

            if ( isdefined( rocket ) )
            {
                rocket.from_ai = 1;
                rocket.killcament = self;
                rocket wait_endon( randomfloatrange( 0.5, 1 ), "death" );
                continue;
            }
        }

        self fireweapon();
        warning_shots--;
        wait( level.ai_tank_turret_fire_rate );

        if ( isdefined( enemy ) && !isalive( enemy ) )
        {
            bullets = randomintrange( 8, 15 );

            for ( i = 0; i < bullets; i++ )
            {
                self fireweapon();
                wait( level.ai_tank_turret_fire_rate );
            }
        }
    }
}

tank_target_lost()
{
    self endon( "turret_on_vistarget" );
    wait 5;
    self tank_idle();
}

tank_should_fire_rocket( enemy )
{
    if ( self.numberrockets <= 0 )
        return false;

    if ( distancesquared( self.origin, enemy.origin ) < 147456 )
        return false;

    origin = self gettagorigin( "tag_flash_gunner1" );

    if ( !bullettracepassed( origin, enemy.origin + vectorscale( ( 0, 0, 1 ), 10.0 ), 0, enemy ) )
        return false;

    return true;
}

tank_rocket_think()
{
    self endon( "death" );
    self endon( "remote_start" );

    if ( self.numberrockets <= 0 )
    {
        self disablegunnerfiring( 0, 1 );
        wait 2;
        self setclientfield( "ai_tank_missile_fire", 4 );
        self.numberrockets = 3;
        wait 0.4;

        if ( !self.isstunned )
            self disablegunnerfiring( 0, 0 );
    }

    while ( true )
    {
        self waittill( "missile_fire" );

        self.numberrockets--;
        self setclientfield( "ai_tank_missile_fire", self.numberrockets );
        angles = self gettagangles( "tag_flash_gunner1" );
        dir = anglestoforward( angles );
        self launchvehicle( dir * -30, self.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), 0 );
        earthquake( 0.4, 0.5, self.origin, 200 );

        if ( self.numberrockets <= 0 )
        {
            self disablegunnerfiring( 0, 1 );
            wait 2;
            self setclientfield( "ai_tank_missile_fire", 4 );
            self.numberrockets = 3;
            wait 0.4;

            if ( !self.isstunned )
                self disablegunnerfiring( 0, 0 );
        }
    }
}

tank_set_target( entity, use_rocket )
{
    if ( !isdefined( use_rocket ) )
        use_rocket = 0;

    self.target_entity = entity;

    if ( use_rocket )
    {
        angles = self gettagangles( "tag_barrel" );
        right = anglestoright( angles );
        offset = vectorscale( right, 8 );
        velocity = entity getvelocity();
        speed = length( velocity );
        forward = anglestoforward( entity.angles );
        origin = offset + vectorscale( forward, speed );
        self setturrettargetent( entity, origin );
    }
    else
        self setturrettargetent( entity );
}

tank_get_target()
{
    return self.target_entity;
}

tank_idle()
{
    tank_set_target( self.aim_entity );
}

tank_is_idle()
{
    return tank_get_target() == self.aim_entity;
}

tank_has_radar()
{
    if ( level.teambased )
        return maps\mp\killstreaks\_radar::teamhasspyplane( self.team ) || maps\mp\killstreaks\_radar::teamhassatellite( self.team );

    return isdefined( self.owner.hasspyplane ) && self.owner.hasspyplane || isdefined( self.owner.hassatellite ) && self.owner.hassatellite;
}

tank_get_player_enemies( on_radar )
{
    enemies = [];

    if ( !isdefined( on_radar ) )
        on_radar = 0;

    if ( on_radar )
        time = gettime();

    foreach ( teamkey, team in level.aliveplayers )
    {
        if ( level.teambased && teamkey == self.team )
            continue;

        foreach ( player in team )
        {
            if ( !valid_target( player, self.team, self.owner ) )
                continue;

            if ( on_radar )
            {
                if ( time - player.lastfiretime > 3000 && !tank_has_radar() )
                    continue;
            }

            enemies[enemies.size] = player;
        }
    }

    return enemies;
}

tank_compute_enemy_position()
{
    enemies = tank_get_player_enemies( 0 );
    position = undefined;

    if ( enemies.size )
    {
        x = 0;
        y = 0;
        z = 0;

        foreach ( enemy in enemies )
        {
            x += enemy.origin[0];
            y += enemy.origin[1];
            z += enemy.origin[2];
        }

        x /= enemies.size;
        y /= enemies.size;
        z /= enemies.size;
        position = ( x, y, z );
    }

    return position;
}

valid_target( target, team, owner )
{
    if ( !isdefined( target ) )
        return false;

    if ( !isalive( target ) )
        return false;

    if ( target == owner )
        return false;

    if ( isplayer( target ) )
    {
        if ( target.sessionstate != "playing" )
            return false;

        if ( isdefined( target.lastspawntime ) && gettime() - target.lastspawntime < 3000 )
            return false;
/#
        if ( target isinmovemode( "ufo", "noclip" ) )
            return false;
#/
    }

    if ( level.teambased )
    {
        if ( isdefined( target.team ) && team == target.team )
            return false;

        if ( isdefined( target.aiteam ) && team == target.aiteam )
            return false;
    }

    if ( isdefined( target.owner ) && target.owner == owner )
        return false;

    if ( isdefined( target.script_owner ) && target.script_owner == owner )
        return false;

    if ( isdefined( target.dead ) && target.dead )
        return false;

    if ( isdefined( target.targetname ) && target.targetname == "riotshield_mp" )
    {
        if ( isdefined( target.damagetaken ) && target.damagetaken >= getdvarint( "riotshield_deployed_health" ) )
            return false;
    }

    return true;
}

starttankremotecontrol( drone )
{
    self.killstreak_waitamount = 120000;
    drone makevehicleusable();
    drone clearvehgoalpos();
    drone clearturrettarget();
    drone laseroff();
    drone usevehicle( self, 0 );
    drone makevehicleunusable();
    drone setbrake( 0 );
    self create_weapon_hud();
    drone update_weapon_hud( self );
    self thread tank_fire_watch( drone );
    drone thread tank_rocket_watch( self );
}

endtankremotecontrol( drone, isdead )
{
    drone makevehicleunusable();

    if ( !isdead )
    {
        drone thread tank_move_think();
        drone thread tank_riotshield_think();
        drone thread tank_aim_think();
        drone thread tank_combat_think();
        drone thread tank_rocket_think();
    }
}

end_remote_control_ai_tank( drone )
{
    if ( !isdefined( drone.dead ) || !drone.dead )
    {
        self thread maps\mp\gametypes\_hud::fadetoblackforxsec( 0, 0.25, 0.1, 0.25 );
        wait 0.3;
    }
    else
    {
        wait 0.75;
        self thread maps\mp\gametypes\_hud::fadetoblackforxsec( 0, 0.25, 0.1, 0.25 );
        wait 0.3;
    }

    drone makevehicleusable();
    drone.controlled = 0;
    drone notify( "remote_stop" );
    self unlink();
    drone makevehicleunusable();
    self stop_remote();
    drone showpart( "tag_pov_hide" );

    if ( isdefined( self.hud_prompt_control ) && ( !isdefined( drone.dead ) || !drone.dead ) )
    {
        self.hud_prompt_control settext( "HOLD [{+activate}] TO CONTROL A.G.R." );
        self.hud_prompt_exit settext( "" );
    }

    self switchtolastnonkillstreakweapon();
    wait 0.5;
    self takeweapon( "killstreak_ai_tank_mp" );

    if ( !isdefined( drone.dead ) || !drone.dead )
    {
        drone thread tank_move_think();
        drone thread tank_riotshield_think();
        drone thread tank_aim_think();
        drone thread tank_combat_think();
    }
}

tank_fire_watch( drone )
{
    self endon( "disconnect" );
    self endon( "stopped_using_remote" );
    drone endon( "death" );
    level endon( "game_ended" );

    while ( true )
    {
        drone waittill( "turret_fire" );

        if ( drone.isstunned )
            continue;

        drone fireweapon();
        earthquake( 0.2, 0.2, drone.origin, 200 );
        angles = drone gettagangles( "tag_barrel" );
        dir = anglestoforward( angles );
        drone launchvehicle( dir * -5, drone.origin + vectorscale( ( 0, 0, 1 ), 10.0 ), 0 );
        wait( level.ai_tank_turret_fire_rate );
    }
}

tank_rocket_watch( player )
{
    self endon( "death" );
    player endon( "stopped_using_remote" );

    if ( self.numberrockets <= 0 )
    {
        self disablegunnerfiring( 0, 1 );
        wait 2;
        self setclientfield( "ai_tank_missile_fire", 4 );
        self.numberrockets = 3;
        wait 0.4;

        if ( !self.isstunned )
            self disablegunnerfiring( 0, 0 );

        self update_weapon_hud( player );
    }

    if ( !self.isstunned )
        self disablegunnerfiring( 0, 0 );

    while ( true )
    {
        player waittill( "missile_fire" );

        self.numberrockets--;
        self setclientfield( "ai_tank_missile_fire", self.numberrockets );
        angles = self gettagangles( "tag_flash_gunner1" );
        dir = anglestoforward( angles );

        if ( !self.controlled )
            self launchvehicle( dir * -30, self.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), 0 );
        else
        {
            self launchvehicle( dir * -30, self.origin + vectorscale( ( 0, 0, 1 ), 50.0 ), 0 );
            player playrumbleonentity( "sniper_fire" );
        }

        earthquake( 0.4, 0.5, self.origin, 200 );
        self update_weapon_hud( player );

        if ( self.numberrockets <= 0 )
        {
            self disablegunnerfiring( 0, 1 );
            wait 2;
            self setclientfield( "ai_tank_missile_fire", 4 );
            self.numberrockets = 3;
            wait 0.4;

            if ( !self.isstunned )
                self disablegunnerfiring( 0, 0 );

            self update_weapon_hud( player );
        }
    }
}

create_weapon_hud()
{
    self.tank_rocket_1 = newclienthudelem( self );
    self.tank_rocket_1.alignx = "right";
    self.tank_rocket_1.aligny = "bottom";
    self.tank_rocket_1.horzalign = "user_center";
    self.tank_rocket_1.vertalign = "user_bottom";
    self.tank_rocket_1.font = "small";
    self.tank_rocket_1 setshader( "mech_check_fill", 32, 16 );
    self.tank_rocket_1.hidewheninmenu = 0;
    self.tank_rocket_1.immunetodemogamehudsettings = 1;
    self.tank_rocket_1.x = -250;
    self.tank_rocket_1.y = -75;
    self.tank_rocket_1.fontscale = 1.25;
    self.tank_rocket_2 = newclienthudelem( self );
    self.tank_rocket_2.alignx = "right";
    self.tank_rocket_2.aligny = "bottom";
    self.tank_rocket_2.horzalign = "user_center";
    self.tank_rocket_2.vertalign = "user_bottom";
    self.tank_rocket_2.font = "small";
    self.tank_rocket_2 setshader( "mech_check_fill", 32, 16 );
    self.tank_rocket_2.hidewheninmenu = 0;
    self.tank_rocket_2.immunetodemogamehudsettings = 1;
    self.tank_rocket_2.x = -250;
    self.tank_rocket_2.y = -65;
    self.tank_rocket_2.fontscale = 1.25;
    self.tank_rocket_3 = newclienthudelem( self );
    self.tank_rocket_3.alignx = "right";
    self.tank_rocket_3.aligny = "bottom";
    self.tank_rocket_3.horzalign = "user_center";
    self.tank_rocket_3.vertalign = "user_bottom";
    self.tank_rocket_3.font = "small";
    self.tank_rocket_3 setshader( "mech_check_fill", 32, 16 );
    self.tank_rocket_3.hidewheninmenu = 0;
    self.tank_rocket_3.immunetodemogamehudsettings = 1;
    self.tank_rocket_3.x = -250;
    self.tank_rocket_3.y = -55;
    self.tank_rocket_3.fontscale = 1.25;
    self thread fade_out_weapon_hud();
}

fade_out_weapon_hud()
{
    self endon( "death" );
    wait 8;
    time = 0;

    while ( time < 2 )
    {
        if ( !isdefined( self.tank_rocket_hint ) )
            return;

        self.tank_rocket_hint.alpha -= 0.025;
        self.tank_mg_hint.alpha -= 0.025;
        time += 0.05;
        wait 0.05;
    }

    self.tank_rocket_hint.alpha = 0;
    self.tank_mg_hint.alpha = 0;
}

update_weapon_hud( player )
{
    if ( isdefined( player.tank_rocket_3 ) )
    {
        player.tank_rocket_3 setshader( "mech_check_fill", 32, 16 );
        player.tank_rocket_2 setshader( "mech_check_fill", 32, 16 );
        player.tank_rocket_1 setshader( "mech_check_fill", 32, 16 );

        switch ( self.numberrockets )
        {
            case 0:
                player.tank_rocket_3 setshader( "mech_check_line", 32, 16 );
            case 1:
                player.tank_rocket_2 setshader( "mech_check_line", 32, 16 );
            case 2:
                player.tank_rocket_1 setshader( "mech_check_line", 32, 16 );
                break;
        }
    }
}

destroy_remote_hud()
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
}

tank_devgui_think()
{
/#
    setdvar( "devgui_tank", "" );

    for (;;)
    {
        wait 0.25;
        level.ai_tank_turret_fire_rate = weaponfiretime( "ai_tank_drone_gun_mp" );

        if ( getdvar( "devgui_tank" ) == "routes" )
        {
            devgui_debug_route();
            setdvar( "devgui_tank", "" );
        }
    }
#/
}

tank_debug_patrol( node1, node2 )
{
/#
    self endon( "death" );
    self endon( "debug_patrol" );

    for (;;)
    {
        self setvehgoalpos( node1.origin, 1, 2 );

        self waittill( "reached_end_node" );

        wait 1;
        self setvehgoalpos( node2.origin, 1, 2 );

        self waittill( "reached_end_node" );

        wait 1;
    }
#/
}

devgui_debug_route()
{
/#
    iprintln( "Choose nodes with 'A' or press 'B' to cancel" );
    nodes = maps\mp\gametypes\_dev::dev_get_node_pair();

    if ( !isdefined( nodes ) )
    {
        iprintln( "Route Debug Cancelled" );
        return;
    }

    iprintln( "Sending talons to chosen nodes" );
    tanks = getentarray( "talon", "targetname" );

    foreach ( tank in tanks )
    {
        tank notify( "debug_patrol" );
        tank thread tank_debug_patrol( nodes[0], nodes[1] );
    }
#/
}

tank_debug_hud_init()
{
/#
    for ( host = gethostplayer(); !isdefined( host ); host = gethostplayer() )
        wait 0.25;

    x = 80;
    y = 40;
    level.ai_tank_bar = newclienthudelem( host );
    level.ai_tank_bar.x = x + 80;
    level.ai_tank_bar.y = y + 2;
    level.ai_tank_bar.alignx = "left";
    level.ai_tank_bar.aligny = "top";
    level.ai_tank_bar.horzalign = "fullscreen";
    level.ai_tank_bar.vertalign = "fullscreen";
    level.ai_tank_bar.alpha = 0;
    level.ai_tank_bar.foreground = 0;
    level.ai_tank_bar setshader( "black", 1, 8 );
    level.ai_tank_text = newclienthudelem( host );
    level.ai_tank_text.x = x + 80;
    level.ai_tank_text.y = y;
    level.ai_tank_text.alignx = "left";
    level.ai_tank_text.aligny = "top";
    level.ai_tank_text.horzalign = "fullscreen";
    level.ai_tank_text.vertalign = "fullscreen";
    level.ai_tank_text.alpha = 0;
    level.ai_tank_text.fontscale = 1;
    level.ai_tank_text.foreground = 1;
#/
}

tank_debug_health()
{
/#
    self.damage_debug = "";
    level.ai_tank_bar.alpha = 1;
    level.ai_tank_text.alpha = 1;

    for (;;)
    {
        wait 0.05;

        if ( !isdefined( self ) || !isalive( self ) )
        {
            level.ai_tank_bar.alpha = 0;
            level.ai_tank_text.alpha = 0;
            return;
        }

        width = self.health / self.maxhealth * 300;
        width = int( max( width, 1 ) );
        level.ai_tank_bar setshader( "black", width, 8 );
        str = self.health + "  Last Damage: " + self.damage_debug;
        level.ai_tank_text settext( str );
    }
#/
}
