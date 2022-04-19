// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zm_buried;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm;

main_start()
{
    level thread spawned_collision_ffotd();
    level thread ghost_round_override_init();
    level thread init_push_triggers();
    level thread init_dtp_triggers();
    level thread spawned_slide_push_trigger();
    level thread spawned_slide_prone_trigger();
    level thread spawned_life_triggers();
    onplayerconnect_callback( ::ffotd_player_threads );
    level thread reset_vulture_dvars_post_migrate();
}

main_end()
{
    if ( is_gametype_active( "zgrief" ) )
    {
        level thread zgrief_mode_fix();
        level.check_for_valid_spawn_near_team_callback = ::zgrief_respawn_override;
    }

    level.zombie_init_done = ::ffotd_zombie_init_done;
    level thread bar_spawner_fix();
    level thread maze_blocker_fix();
    level thread door_clip_fix();
    level thread player_respawn_fix();
}

reset_vulture_dvars_post_migrate()
{
    while ( true )
    {
        level waittill( "host_migration_end" );

        setdvarint( "zombies_perk_vulture_pickup_time", 12 );
        setdvarint( "zombies_perk_vulture_pickup_time_stink", 16 );
        setdvarint( "zombies_perk_vulture_drop_chance", 65 );
        setdvarint( "zombies_perk_vulture_ammo_chance", 33 );
        setdvarint( "zombies_perk_vulture_points_chance", 33 );
        setdvarint( "zombies_perk_vulture_stink_chance", 33 );
        setdvarint( "zombies_perk_vulture_drops_max", 20 );
        setdvarint( "zombies_perk_vulture_network_drops_max", 5 );
        setdvarint( "zombies_perk_vulture_network_time_frame", 250 );
        setdvarint( "zombies_perk_vulture_spawn_stink_zombie_cooldown", 12 );
        setdvarint( "zombies_perk_vulture_max_stink_zombies", 4 );
    }
}

ffotd_zombie_init_done()
{
    self maps\mp\zm_buried::zombie_init_done();
    self thread jail_traversal_fix();
}

jail_traversal_fix()
{
    self endon( "death" );
    window_pos = ( -837, 496, 8 );
    fix_dist = 64;

    while ( true )
    {
        dist = distancesquared( self.origin, window_pos );

        if ( dist < fix_dist )
        {
            node = self getnegotiationstartnode();

            if ( isdefined( node ) )
            {
                if ( node.animscript == "zm_jump_down_48" && node.type == "Begin" )
                {
                    self setphysparams( 25, 0, 72 );
                    wait 1;

                    if ( is_true( self.has_legs ) )
                        self setphysparams( 15, 0, 72 );
                    else
                        self setphysparams( 15, 0, 24 );
                }
            }
        }

        wait 0.25;
    }
}

ghost_round_override_init()
{
    origin = ( 2593, 562, 290 );
    length = 512;
    width = 91;
    height = 290;
    trig1 = spawn( "trigger_box", origin, 0, length, width, height );
    trig1.angles = vectorscale( ( 0, 1, 0 ), 69.0 );
    trig1.script_noteworthy = "ghost_round_override";
}

zgrief_mode_fix()
{
    speed_trigger = getentarray( "specialty_fastreload", "script_noteworthy" );

    foreach ( trig in speed_trigger )
    {
        if ( trig.origin == ( -170.5, -328.25, 174 ) )
        {
            trig.origin += vectorscale( ( 0, -1, 0 ), 32.0 );

            if ( isdefined( trig.clip ) )
                trig.clip.origin += vectorscale( ( 0, -1, 0 ), 32.0 );

            if ( isdefined( trig.machine ) )
                trig.machine.origin += vectorscale( ( 0, -1, 0 ), 32.0 );
        }
    }
}

zgrief_respawn_override( revivee, return_struct )
{
    players = get_players();
    spawn_points = maps\mp\gametypes_zm\_zm_gametype::get_player_spawns_for_gametype();
    grief_initial = getstructarray( "street_standard_player_spawns", "targetname" );

    foreach ( struct in grief_initial )
    {
        if ( isdefined( struct.script_int ) && struct.script_int == 2000 )
        {
            spawn_points[spawn_points.size] = struct;
            initial_point = struct;
            initial_point.locked = 0;
        }
    }

    closest_group = undefined;
    closest_distance = 100000000;
    backup_group = undefined;
    backup_distance = 100000000;

    if ( spawn_points.size == 0 )
        return undefined;

    for ( i = 0; i < players.size; i++ )
    {
        if ( is_player_valid( players[i], undefined, 1 ) && players[i] != self )
        {
            for ( j = 0; j < spawn_points.size; j++ )
            {
                if ( isdefined( spawn_points[j].script_int ) )
                    ideal_distance = spawn_points[j].script_int;
                else
                    ideal_distance = 1000;

                if ( spawn_points[j].locked == 0 )
                {
                    plyr_dist = distancesquared( players[i].origin, spawn_points[j].origin );

                    if ( plyr_dist < ideal_distance * ideal_distance )
                    {
                        if ( plyr_dist < closest_distance )
                        {
                            closest_distance = plyr_dist;
                            closest_group = j;
                        }

                        continue;
                    }

                    if ( plyr_dist < backup_distance )
                    {
                        backup_group = j;
                        backup_distance = plyr_dist;
                    }
                }
            }
        }

        if ( !isdefined( closest_group ) )
            closest_group = backup_group;

        if ( isdefined( closest_group ) )
        {
            spawn_location = maps\mp\zombies\_zm::get_valid_spawn_location( revivee, spawn_points, closest_group, return_struct );

            if ( isdefined( spawn_location ) && !positionwouldtelefrag( spawn_location.origin ) )
            {
                if ( isdefined( spawn_location.plyr ) && spawn_location.plyr != revivee getentitynumber() )
                    continue;

                return spawn_location;
            }
        }
    }

    if ( isdefined( initial_point ) )
    {
        for ( k = 0; k < spawn_points.size; k++ )
        {
            if ( spawn_points[k] == initial_point )
            {
                closest_group = k;
                spawn_location = maps\mp\zombies\_zm::get_valid_spawn_location( revivee, spawn_points, closest_group, return_struct );
                return spawn_location;
            }
        }
    }

    return undefined;
}

spawned_slide_prone_trigger()
{
    origin = ( -2820, -412, 1438 );
    length = 216;
    width = 216;
    height = 108;
    trig1 = spawn( "trigger_box", origin, 0, length, width, height );
    trig1.angles = ( 0, 0, 0 );
    trig1.targetname = "force_from_prone";
}

spawned_slide_push_trigger()
{
    origin = ( -1416.5, -324, 428.5 );
    length = 111;
    width = 394;
    height = 189;
    trig1 = spawn( "trigger_box", origin, 0, length, width, height );
    trig1.angles = ( 0, 0, 0 );
    trig1.targetname = "push_from_prone";
    trig1.push_player_towards_point = ( -1336, -320, 360 );

    while ( true )
    {
        trig1 waittill( "trigger", who );

        if ( who getstance() == "prone" && isplayer( who ) )
            who setstance( "crouch" );

        trig1 thread slide_push_think( who );
        wait 0.1;
    }
}

slide_push_think( who )
{
    whopos = ( 0, 0, 0 );

    while ( who istouching( self ) )
    {
        if ( who.origin == whopos )
            who setvelocity( self get_push_vector() );

        whopos = who.origin;
        wait 2.0;
    }
}

slide_push_in_trigger( player )
{
    if ( !player is_player_using_thumbstick() )
        player setvelocity( self get_push_vector() );
}

spawned_life_triggers()
{
    origin = ( 6637, 516, -580 );
    length = 1110;
    width = 982;
    height = 824;
    trig1 = spawn( "trigger_box", origin, 0, length, width, height );
    trig1.angles = ( 0, 0, 0 );
    trig1.script_noteworthy = "life_brush";
}

spawned_collision_ffotd()
{
    precachemodel( "collision_geo_64x64x10_slick" );
    precachemodel( "collision_geo_64x64x128_slick" );
    precachemodel( "collision_geo_128x128x10_slick" );
    precachemodel( "collision_geo_64x64x10_standard" );
    precachemodel( "collision_geo_64x64x64_standard" );
    precachemodel( "collision_geo_128x128x10_standard" );
    precachemodel( "collision_geo_128x128x128_standard" );
    precachemodel( "collision_geo_256x256x10_standard" );
    precachemodel( "collision_geo_256x256x256_standard" );
    precachemodel( "p6_zm_bu_rock_strata_column_01" );
    precachemodel( "p6_zm_bu_rock_strata_01" );
    precachemodel( "p6_zm_bu_rock_strata_04" );
    precachemodel( "p6_zm_bu_wood_planks_106x171" );
    flag_wait( "start_zombie_round_logic" );

    if ( !( isdefined( level.optimise_for_splitscreen ) && level.optimise_for_splitscreen ) )
    {
        collision1 = spawn( "script_model", ( 3731.5, 736, 6.5 ) );
        collision1 setmodel( "collision_geo_64x64x128_slick" );
        collision1.angles = ( 4.54625, 313.41, -4.78954 );
        collision1 ghost();
        collision2 = spawn( "script_model", ( 34, -1691, 375 ) );
        collision2 setmodel( "collision_geo_256x256x10_standard" );
        collision2.angles = vectorscale( ( 0, 0, -1 ), 3.80002 );
        collision2 ghost();
        collision3 = spawn( "script_model", ( 641, 545, -1.21359 ) );
        collision3 setmodel( "collision_geo_64x64x128_slick" );
        collision3.angles = ( 1.27355, 320.806, -5.38137 );
        collision3 ghost();
        saloon1 = spawn( "script_model", ( 1032.22, -1744.09, 309 ) );
        saloon1 setmodel( "collision_geo_64x64x64_standard" );
        saloon1.angles = vectorscale( ( 0, 1, 0 ), 40.8 );
        saloon1 ghost();
        saloon2 = spawn( "script_model", ( 1005.78, -1766.91, 309 ) );
        saloon2 setmodel( "collision_geo_64x64x64_standard" );
        saloon2.angles = vectorscale( ( 0, 1, 0 ), 40.8 );
        saloon2 ghost();
        gs1 = spawn( "script_model", ( 118.001, -537.037, 236 ) );
        gs1 setmodel( "collision_geo_64x64x64_standard" );
        gs1.angles = vectorscale( ( 0, 1, 0 ), 90.0 );
        gs1 ghost();
        gs1 thread delete_upon_flag( "general_store_porch_door1" );
        gs2 = spawn( "script_model", ( 117.999, -571.963, 236 ) );
        gs2 setmodel( "collision_geo_64x64x64_standard" );
        gs2.angles = vectorscale( ( 0, 1, 0 ), 90.0 );
        gs2 ghost();
        gs2 thread delete_upon_flag( "general_store_porch_door1" );
        collision4 = spawn( "script_model", ( 1672, 692, 99 ) );
        collision4 setmodel( "collision_geo_128x128x10_slick" );
        collision4.angles = ( 280.6, 270, 86.6 );
        collision4 ghost();
        cw1 = spawn( "script_model", ( 320, -1988, 116 ) );
        cw1 setmodel( "collision_geo_128x128x128_standard" );
        cw1.angles = ( 0, 0, 0 );
        cw1 ghost();
        rock1 = spawn( "script_model", ( 311, -1945, 104 ) );
        rock1 setmodel( "p6_zm_bu_rock_strata_column_01" );
        rock1.angles = vectorscale( ( 0, 0, 1 ), 90.0 );
        st1 = spawn( "script_model", ( -736, -2, 25 ) );
        st1 setmodel( "collision_geo_128x128x10_standard" );
        st1.angles = ( 270, 45, 0 );
        st1 ghost();
        ml1 = spawn( "script_model", ( 2831, 440, 405 ) );
        ml1 setmodel( "collision_geo_128x128x128_standard" );
        ml1.angles = ( 0, 0, 0 );
        ml1 ghost();
        ml2 = spawn( "script_model", ( 2831, 680, 420 ) );
        ml2 setmodel( "collision_geo_128x128x128_standard" );
        ml2.angles = ( 0, 0, 0 );
        ml2 ghost();
        mr1 = spawn( "script_model", ( 2380, 1123, 350 ) );
        mr1 setmodel( "collision_geo_256x256x10_standard" );
        mr1.angles = ( 0, 13.8, -90 );
        mr1 ghost();
        th1 = spawn( "script_model", ( 2072, 1168, 360 ) );
        th1 setmodel( "collision_geo_128x128x128_standard" );
        th1.angles = ( 0, 0, 0 );
        th1 ghost();
        th1a = spawn( "script_model", ( 2296, 1088, 400 ) );
        th1a setmodel( "collision_geo_128x128x128_standard" );
        th1a.angles = ( 0, 0, 0 );
        th1a ghost();
        th2 = spawn( "script_model", ( -544, 510, 286 ) );
        th2 setmodel( "collision_geo_256x256x10_standard" );
        th2.angles = ( 0, 7.2, -7.8 );
        th2 ghost();
        th2a = spawn( "script_model", ( -296.95, 537.996, 312.557 ) );
        th2a setmodel( "collision_geo_256x256x10_standard" );
        th2a.angles = ( 347.355, 6.47392, -7.41809 );
        th2a ghost();
        th3 = spawn( "script_model", ( 864, 872, 420 ) );
        th3 setmodel( "collision_geo_256x256x256_standard" );
        th3.angles = ( 0, 0, 0 );
        th3 ghost();
        th4 = spawn( "script_model", ( 2361, 1056, 398 ) );
        th4 setmodel( "collision_geo_256x256x10_standard" );
        th4.angles = vectorscale( ( 1, 0, 0 ), 270.0 );
        th4 ghost();
        ch1 = spawn( "script_model", ( 1954, 1996, 222 ) );
        ch1 setmodel( "collision_geo_256x256x10_standard" );
        ch1.angles = ( 270, 340, 0.32 );
        ch1 ghost();
        ch2 = spawn( "script_model", ( 1945, 1972, 222 ) );
        ch2 setmodel( "collision_geo_256x256x10_standard" );
        ch2.angles = ( 270, 340, 0.32 );
        ch2 ghost();
        rock1 = spawn( "script_model", ( 3259.54, -189.38, 146.23 ) );
        rock1 setmodel( "p6_zm_bu_rock_strata_column_01" );
        rock1.angles = ( 7.87264, 94.015, 4.57899 );
        rock2 = spawn( "script_model", ( 3351.97, -254.58, 95 ) );
        rock2 setmodel( "p6_zm_bu_rock_strata_01" );
        rock2.angles = vectorscale( ( 0, 1, 0 ), 169.1 );
        yt1 = spawn( "script_model", ( 671, -1412, 214 ) );
        yt1 setmodel( "collision_geo_64x64x10_slick" );
        yt1.angles = ( 62.8, 315, 0 );
        yt1 ghost();
        yt2 = spawn( "script_model", ( 676, -1407, 214 ) );
        yt2 setmodel( "collision_geo_64x64x10_slick" );
        yt2.angles = ( 62.8, 315, 0 );
        yt2 ghost();
        stb1 = spawn( "script_model", ( -807, 59, 127 ) );
        stb1 setmodel( "collision_geo_64x64x10_standard" );
        stb1.angles = vectorscale( ( 0, 0, -1 ), 90.0 );
        stb1 ghost();
        stb2 = spawn( "script_model", ( -807, 59, 191 ) );
        stb2 setmodel( "collision_geo_64x64x10_standard" );
        stb2.angles = vectorscale( ( 0, 0, -1 ), 90.0 );
        stb2 ghost();
        stb3 = spawn( "script_model", ( -861, 59, 31 ) );
        stb3 setmodel( "collision_geo_128x128x10_standard" );
        stb3.angles = vectorscale( ( 0, 0, -1 ), 90.0 );
        stb3 ghost();
        j162 = spawn( "script_model", ( 912, -936, 214 ) );
        j162 setmodel( "collision_geo_128x128x10_standard" );
        j162.angles = ( 0, 0, 0 );
        j162 ghost();
        j156 = spawn( "script_model", ( 434, 1213, 184 ) );
        j156 setmodel( "collision_geo_128x128x10_standard" );
        j156.angles = vectorscale( ( 1, 0, 0 ), 273.0 );
        j156 ghost();
        j163_1 = spawn( "script_model", ( 1663, 68, 29 ) );
        j163_1 setmodel( "collision_geo_128x128x10_slick" );
        j163_1.angles = vectorscale( ( 1, 0, 0 ), 270.0 );
        j163_1 ghost();
        j163_2 = spawn( "script_model", ( 1663, 259, 29 ) );
        j163_2 setmodel( "collision_geo_128x128x10_slick" );
        j163_2.angles = vectorscale( ( 1, 0, 0 ), 270.0 );
        j163_2 ghost();
        j125_1 = spawn( "script_model", ( 2443.65, 1013.54, 236.213 ) );
        j125_1 setmodel( "p6_zm_bu_rock_strata_04" );
        j125_1.angles = ( 13.345, 103.42, -13.4657 );
        j125_3 = spawn( "script_model", ( 2448.7, 852.791, 272.051 ) );
        j125_3 setmodel( "p6_zm_bu_wood_planks_106x171" );
        j125_3.angles = ( 0, 270, 19.4 );
        j125_4 = spawn( "script_model", ( 2313.21, 872.54, 241.01 ) );
        j125_4 setmodel( "p6_zm_bu_wood_planks_106x171" );
        j125_4.angles = ( 0, 0, 0 );
        e72913 = spawn( "script_model", ( -862, -764, 207 ) );
        e72913 setmodel( "collision_geo_256x256x10_standard" );
        e72913.angles = ( 6.2, 0, -90 );
        e72913 ghost();
        e2157 = spawn( "script_model", ( 432, 648, 247 ) );
        e2157 setmodel( "collision_geo_128x128x10_standard" );
        e2157.angles = vectorscale( ( 1, 0, 0 ), 270.0 );
        e2157 ghost();
    }
}

delete_upon_flag( flag_notify )
{
    level flag_wait( flag_notify );
    self delete();
}

init_push_triggers()
{
    ghost_mansion_to_maze_push_trigger_left();
    ghost_mansion_to_maze_push_trigger_right();
    ghost_mansion_from_maze_push_trigger();
    a_push_triggers = getentarray( "push_trigger", "script_noteworthy" );
    array_thread( a_push_triggers, ::push_players_standing_in_trigger_volumes );
}

ghost_mansion_to_maze_push_trigger_left()
{
    origin = ( 2656, 689, 183 );
    length = 128;
    width = 8;
    height = 64;
    trig1 = spawn( "trigger_box", origin, 0, width, length, height );
    trig1.angles = vectorscale( ( 0, 1, 0 ), 325.6 );
    trig1.script_noteworthy = "push_trigger";
    trig1.push_player_towards_point = ( 2666, 685, 183 );
}

ghost_mansion_to_maze_push_trigger_right()
{
    origin = ( 2592, 453, 183 );
    length = 32;
    width = 16;
    height = 64;
    trig1 = spawn( "trigger_box", origin, 0, width, length, height );
    trig1.angles = vectorscale( ( 0, 1, 0 ), 325.6 );
    trig1.script_noteworthy = "push_trigger";
    trig1.push_player_towards_point = ( 2686, 440, 174 );
}

ghost_mansion_from_maze_push_trigger()
{
    origin = ( 3425, 1067, 53 );
    length = 128;
    width = 16;
    height = 64;
    trig1 = spawn( "trigger_box", origin, 0, width, length, height );
    trig1.angles = ( 0, 0, 0 );
    trig1.script_noteworthy = "push_trigger";
    trig1.push_player_towards_point = ( 3337, 1067, 90 );
}

push_players_standing_in_trigger_volumes()
{
/#
    assert( isdefined( self.push_player_towards_point ), "push_player_towards_point field is undefined on push_trigger! This is required for the push functionality to work" );
#/
    while ( true )
    {
        self waittill( "trigger", player );

        if ( !player is_player_using_thumbstick() )
            player setvelocity( self get_push_vector() );
    }
}

is_player_using_thumbstick()
{
    b_using_thumbstick = 1;
    v_thumbstick = self getnormalizedmovement();

    if ( length( v_thumbstick ) < 0.3 )
        b_using_thumbstick = 0;

    return b_using_thumbstick;
}

get_push_vector()
{
    return vectornormalize( self.push_player_towards_point - self.origin ) * 100;
}

bar_spawner_fix()
{
    bad_pos = ( 459.5, -1984, 84 );
    dist_fix = 64;
    bar_spawners = getstructarray( "zone_bar_spawners", "targetname" );

    foreach ( spawner in bar_spawners )
    {
        if ( isdefined( spawner.script_string ) && spawner.script_string == "bar2" )
        {
            dist = distancesquared( spawner.origin, bad_pos );

            if ( dist < dist_fix )
                spawner.origin = ( 459.5, -2020, 84 );
        }
    }
}

player_respawn_fix()
{
    maze_spawners = getstructarray( "maze_spawn_points", "targetname" );

    foreach ( spawner in maze_spawners )
    {
        if ( spawner.origin == ( 3469, 1026, 20 ) )
            spawner.origin = ( 3509, 1032, 76 );
    }
}

door_clip_fix()
{
    bank1 = getentarray( "pf728_auto2510", "targetname" );

    for ( i = 0; i < bank1.size; i++ )
    {
        if ( isdefined( bank1[i].script_noteworthy ) && bank1[i].script_noteworthy == "clip" )
            bank1[i] delete();
    }

    bank2 = getentarray( "pf728_auto2507", "targetname" );

    for ( i = 0; i < bank2.size; i++ )
    {
        if ( isdefined( bank2[i].script_noteworthy ) && bank2[i].script_noteworthy == "clip" )
            bank2[i] delete();
    }
}

maze_blocker_fix()
{
    node_org = ( 4732, 960, 32 );
    node_target_org = ( 4734, 1198, 32 );
    blocker_node = getnearestnode( node_org );
    blocker_node_target = getnearestnode( node_target_org );

    while ( true )
    {
        level waittill( "zm_buried_maze_changed" );

        found = 0;
        perm_list = level._maze._perms[level._maze._cur_perm];

        foreach ( blocker in perm_list )
        {
            if ( blocker == "blocker_10" )
            {
                found = 1;

                if ( isdefined( blocker_node ) && isdefined( blocker_node_target ) )
                {
                    unlink_nodes( blocker_node, blocker_node_target, 0 );
                    unlink_nodes( blocker_node_target, blocker_node, 0 );
                }
            }
        }

        if ( !found )
        {
            if ( isdefined( blocker_node ) && isdefined( blocker_node_target ) )
            {
                link_nodes( blocker_node, blocker_node_target, 1 );
                link_nodes( blocker_node_target, blocker_node, 1 );
            }
        }
    }
}

time_bomb_takeaway()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "new_tactical_grenade", new_weapon );

        if ( ( !isdefined( new_weapon ) || new_weapon != "time_bomb_zm" ) && self hasweapon( "time_bomb_detonator_zm" ) )
            self takeweapon( "time_bomb_detonator_zm" );
    }
}

ffotd_player_threads()
{
    self thread time_bomb_takeaway();
}

init_dtp_triggers()
{
    barn_hay_push_trigger();
    barn_rail_push_trigger();
    church_fence_push_trigger();
    a_push_triggers = getentarray( "push_from_dtp", "script_noteworthy" );
    array_thread( a_push_triggers, ::dtp_push );
}

barn_hay_push_trigger()
{
    origin = ( -1137, -190, 188 );
    length = 48;
    width = 64;
    height = 64;
    trig1 = spawn( "trigger_box", origin, 0, width, length, height );
    trig1.angles = ( 0, 0, 0 );
    trig1.script_noteworthy = "push_from_dtp";
    trig1.push_player_towards_point = ( -1137, -264, 200 );
}

barn_rail_push_trigger()
{
    origin = ( -1137, -211, 188 );
    length = 32;
    width = 128;
    height = 64;
    trig1 = spawn( "trigger_box", origin, 0, width, length, height );
    trig1.angles = ( 0, 0, 0 );
    trig1.script_noteworthy = "push_from_dtp";
    trig1.push_player_towards_point = ( -1137, -285, 200 );
}

church_fence_push_trigger()
{
    origin = ( 900, 1000, 54 );
    length = 64;
    width = 192;
    height = 64;
    trig1 = spawn( "trigger_box", origin, 0, width, length, height );
    trig1.angles = ( 0, 0, 0 );
    trig1.script_noteworthy = "push_from_dtp";
    trig1.push_player_towards_point = ( 929, 943, 64 );
}

dtp_push()
{
    pos = ( 0, 0, 0 );

    while ( true )
    {
        self waittill( "trigger", player );

        if ( pos == player.origin )
        {
            if ( player getstance() == "prone" )
                player setstance( "crouch" );

            player setvelocity( self get_push_vector() );
        }

        pos = player.origin;
        wait 0.5;
    }
}
