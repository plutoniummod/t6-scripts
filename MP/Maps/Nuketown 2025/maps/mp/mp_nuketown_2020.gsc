// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_events;
#include maps\mp\mp_nuketown_2020_fx;
#include maps\mp\_load;
#include maps\mp\mp_nuketown_2020_amb;
#include maps\mp\_compass;
#include maps\mp\gametypes\_globallogic_defaults;
#include maps\mp\killstreaks\_killstreaks;

#using_animtree("fxanim_props");

main()
{
    level.levelspawndvars = ::levelspawndvars;
    maps\mp\mp_nuketown_2020_fx::main();
    maps\mp\_load::main();
    maps\mp\mp_nuketown_2020_amb::main();
    maps\mp\_compass::setupminimap( "compass_map_mp_nuketown_2020" );
    level.onspawnintermission = ::nuked_intermission;
    setdvar( "compassmaxrange", "2100" );
    precacheitem( "vcs_controller_mp" );
    precachemenu( "vcs" );
    precachemodel( "nt_sign_population" );
    precachemodel( "nt_sign_population_vcs" );
    precachestring( &"MPUI_USE_VCS_HINT" );
    level.const_fx_exploder_nuke = 1001;
    level.headless_mannequin_count = 0;
    level.destructible_callbacks["headless"] = ::mannequin_headless;
    level thread nuked_population_sign_think();
    level.disableoutrovisionset = 1;
    destructible_car_anims = [];
    destructible_car_anims["car1"] = %fxanim_mp_nuked2025_car01_anim;
    destructible_car_anims["car2"] = %fxanim_mp_nuked2025_car02_anim;
    destructible_car_anims["displayGlass"] = %fxanim_mp_nuked2025_display_glass_anim;
    level thread nuked_mannequin_init();
    level thread nuked_powerlevel_think();
    level thread nuked_bomb_drop_think();
}

levelspawndvars( reset_dvars )
{
    ss = level.spawnsystem;
    ss.enemy_influencer_radius = set_dvar_float_if_unset( "scr_spawn_enemy_influencer_radius", "1600", reset_dvars );
    ss.dead_friend_influencer_radius = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_radius", "1300", reset_dvars );
    ss.dead_friend_influencer_timeout_seconds = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_timeout_seconds", "8", reset_dvars );
    ss.dead_friend_influencer_count = set_dvar_float_if_unset( "scr_spawn_dead_friend_influencer_count", "7", reset_dvars );
    ss.hq_objective_influencer_inner_radius = set_dvar_float_if_unset( "scr_spawn_hq_objective_influencer_inner_radius", "1000", reset_dvars );
    ss.koth_objective_influencer_inner_radius = 1000;
}

move_spawn_point( targetname, start_point, new_point )
{
    spawn_points = getentarray( targetname, "classname" );

    for ( i = 0; i < spawn_points.size; i++ )
    {
        if ( distancesquared( spawn_points[i].origin, start_point ) < 1 )
        {
            spawn_points[i].origin = new_point;
            return;
        }
    }
}

nuked_mannequin_init()
{
    destructibles = getentarray( "destructible", "targetname" );
    mannequins = nuked_mannequin_filter( destructibles );
    level.mannequin_count = mannequins.size;

    if ( mannequins.size <= 0 )
        return;

    camerastart = getstruct( "endgame_camera_start", "targetname" );
    level.endgamemannequin = getclosest( camerastart.origin, mannequins );
    remove_count = mannequins.size - 25;
    remove_count = clamp( remove_count, 0, remove_count );
    mannequins = array_randomize( mannequins );

    for ( i = 0; i < remove_count; i++ )
    {
        assert( isdefined( mannequins[i].target ) );

        if ( level.endgamemannequin == mannequins[i] )
            continue;

        collision = getent( mannequins[i].target, "targetname" );
        assert( isdefined( collision ) );
        collision delete();
        mannequins[i] delete();
        level.mannequin_count--;
    }

    level waittill( "prematch_over" );

    level.mannequin_time = gettime();
}

nuked_mannequin_filter( destructibles )
{
    mannequins = [];

    for ( i = 0; i < destructibles.size; i++ )
    {
        destructible = destructibles[i];

        if ( issubstr( destructible.destructibledef, "male" ) )
            mannequins[mannequins.size] = destructible;
    }

    return mannequins;
}

mannequin_headless( notifytype, attacker )
{
    if ( gettime() < level.mannequin_time + getdvarintdefault( "vcs_timelimit", 120 ) * 1000 )
    {
        level.headless_mannequin_count++;

        if ( level.headless_mannequin_count == level.mannequin_count )
            level thread do_vcs();
    }
}

nuked_intermission()
{
    maps\mp\gametypes\_globallogic_defaults::default_onspawnintermission();

    if ( waslastround() )
    {
        level notify( "nuke_detonation" );
        level thread nuke_detonation();
    }
}

nuke_detonation()
{
    level notify( "bomb_drop_pre" );
    clientnotify( "bomb_drop_pre" );
    bomb_loc = getent( "bomb_loc", "targetname" );
    bomb_loc playsound( "amb_end_nuke_2d" );
    destructibles = getentarray( "destructible", "targetname" );

    for ( i = 0; i < destructibles.size; i++ )
    {
        if ( getsubstr( destructibles[i].destructibledef, 0, 4 ) == "veh_" )
            destructibles[i] hide();
    }

    displaysign = getent( "nuke_display_glass_server", "targetname" );
    assert( isdefined( displaysign ) );
    displaysign hide();
    bombwaitpretime = getdvarfloatdefault( "scr_nuke_car_pre", 0.5 );
    wait( bombwaitpretime );
    exploder( level.const_fx_exploder_nuke );
    bomb_loc = getent( "bomb_loc", "targetname" );
    bomb_loc playsound( "amb_end_nuke" );
    level notify( "bomb_drop" );
    clientnotify( "bomb_drop" );
    bombwaittime = getdvarfloatdefault( "scr_nuke_car_flip", 3.25 );
    wait( bombwaittime );
    clientnotify( "nuke_car_flip" );
    location = level.endgamemannequin.origin + ( 0, -20, 50 );
    radiusdamage( location, 128, 128, 128 );
    physicsexplosionsphere( location, 128, 128, 1 );
    mannequinwaittime = getdvarfloatdefault( "scr_nuke_mannequin_flip", 0.25 );
    wait( mannequinwaittime );
    level.endgamemannequin rotateto( level.endgamemannequin.angles + vectorscale( ( 0, 0, 1 ), 90.0 ), 0.7 );
    level.endgamemannequin moveto( level.endgamemannequin.origin + vectorscale( ( 0, 1, 0 ), 90.0 ), 1 );
}

nuked_bomb_drop_think()
{
    camerastart = getstruct( "endgame_camera_start", "targetname" );
    cameraend = getstruct( camerastart.target, "targetname" );
    bomb_loc = getent( "bomb_loc", "targetname" );
    cam_move_time = set_dvar_float_if_unset( "scr_cam_move_time", "4.0" );
    bomb_explode_delay = set_dvar_float_if_unset( "scr_bomb_explode_delay", "2.75" );
    env_destroy_delay = set_dvar_float_if_unset( "scr_env_destroy_delay", "0.5" );

    for (;;)
    {
        camera = spawn( "script_model", camerastart.origin );
        camera.angles = camerastart.angles;
        camera setmodel( "tag_origin" );

        level waittill( "bomb_drop_pre" );

        level notify( "fxanim_dome_explode_start" );

        for ( i = 0; i < get_players().size; i++ )
        {
            player = get_players()[i];
            player camerasetposition( camera );
            player camerasetlookat();
            player cameraactivate( 1 );
            player setdepthoffield( 0, 128, 7000, 10000, 6, 1.8 );
        }

        camera moveto( cameraend.origin, cam_move_time, 0, 0 );
        camera rotateto( cameraend.angles, cam_move_time, 0, 0 );
        bombwaittime = getdvarfloatdefault( "mp_nuketown_2020_bombwait", 3.0 );
        wait( bombwaittime );
        wait( env_destroy_delay );
        cameraforward = anglestoforward( cameraend.angles );
        physicsexplosionsphere( bomb_loc.origin, 128, 128, 1 );
        radiusdamage( bomb_loc.origin, 128, 128, 128 );
    }
}

nuked_population_sign_think()
{
    tens_model = getent( "counter_tens", "targetname" );
    ones_model = getent( "counter_ones", "targetname" );
    step = 36;
    ones = 0;
    tens = 0;
    tens_model rotateroll( step, 0.05 );
    ones_model rotateroll( step, 0.05 );

    for (;;)
    {
        wait 1;

        for (;;)
        {
            num_players = get_players().size;
            dial = ones + tens * 10;

            if ( num_players < dial )
            {
                ones--;
                time = set_dvar_float_if_unset( "scr_dial_rotate_time", "0.5" );

                if ( ones < 0 )
                {
                    ones = 9;
                    tens_model rotateroll( 0 - step, time );
                    tens--;
                }

                ones_model rotateroll( 0 - step, time );

                ones_model waittill( "rotatedone" );

                continue;
            }

            if ( num_players > dial )
            {
                ones++;
                time = set_dvar_float_if_unset( "scr_dial_rotate_time", "0.5" );

                if ( ones > 9 )
                {
                    ones = 0;
                    tens_model rotateroll( step, time );
                    tens++;
                }

                ones_model rotateroll( step, time );

                ones_model waittill( "rotatedone" );

                continue;
            }

            break;
        }
    }
}

do_vcs()
{
    if ( getdvarintdefault( "disable_vcs", 0 ) )
        return;

    if ( !getgametypesetting( "allowMapScripting" ) )
        return;

    if ( !level.onlinegame || !sessionmodeisprivate() )
        return;

    if ( level.wiiu )
        return;

    targettag = getent( "player_tv_position", "targetname" );
    level.vcs_trigger = spawn( "trigger_radius_use", targettag.origin, 0, 64, 64 );
    level.vcs_trigger setcursorhint( "HINT_NOICON" );
    level.vcs_trigger sethintstring( &"MPUI_USE_VCS_HINT" );
    level.vcs_trigger triggerignoreteam();
    screen = getent( "nuketown_tv", "targetname" );
    screen setmodel( "nt_sign_population_vcs" );

    while ( true )
    {
        level.vcs_trigger waittill( "trigger", player );

        if ( player isusingremote() || !isalive( player ) )
            continue;

        prevweapon = player getcurrentweapon();

        if ( prevweapon == "none" || maps\mp\killstreaks\_killstreaks::iskillstreakweapon( prevweapon ) )
            continue;

        level.vcs_trigger setinvisibletoall();
        player giveweapon( "vcs_controller_mp" );
        player switchtoweapon( "vcs_controller_mp" );
        player setstance( "stand" );
        placementtag = spawn( "script_model", player.origin );
        placementtag.angles = player.angles;
        player playerlinktoabsolute( placementtag );
        placementtag moveto( targettag.origin, 0.5, 0.05, 0.05 );
        placementtag rotateto( targettag.angles, 0.5, 0.05, 0.05 );
        player enableinvulnerability();
        player openmenu( "vcs" );
        player wait_till_done_playing_vcs();

        if ( !level.gameended )
        {
            if ( isdefined( player ) )
            {
                player disableinvulnerability();
                player unlink();
                player takeweapon( "vcs_controller_mp" );
                player switchtoweapon( prevweapon );
            }

            level.vcs_trigger setvisibletoall();
        }
    }
}

wait_till_done_playing_vcs()
{
    self endon( "disconnect" );

    while ( true )
    {
        self waittill( "menuresponse", menu, response );

        return;
    }
}

nuked_powerlevel_think()
{
    pin_model = getent( "nuketown_sign_needle", "targetname" );
    pin_model thread pin_think();
}

pin_think()
{
    self endon( "death" );
    self endon( "entityshutdown" );
    self endon( "delete" );
    startangle = 128;
    normalangle = 65 + randomfloatrange( -30, 15 );
    yellowangle = -35 + randomfloatrange( -5, 5 );
    redangle = -95 + randomfloatrange( -10, 10 );
    endangle = -138;
    self.angles = ( startangle, self.angles[1], self.angles[2] );
    waittillframeend;

    if ( islastround() || isoneround() )
    {
        if ( level.timelimit )
        {
            add_timed_event( 10, "near_end_game" );
            self pin_move( yellowangle, level.timelimit * 60 );
        }
        else if ( level.scorelimit )
        {
            add_score_event( int( level.scorelimit * 0.9 ), "near_end_game" );
            self pin_move( normalangle, 300 );
        }

        notifystr = level waittill_any_return( "near_end_game", "game_ended" );

        if ( notifystr == "near_end_game" )
        {
            self pin_check_rotation( 0, 3 );
            self pin_move( redangle, 10 );

            level waittill( "game_ended" );
        }

        self pin_check_rotation( 0, 2 );
        self pin_move( redangle, 2 );
    }
    else if ( level.timelimit )
        self pin_move( normalangle, level.timelimit * 60 );
    else
        self pin_move( normalangle, 300 );

    level waittill( "nuke_detonation" );

    self pin_check_rotation( 0, 0.05 );
    self pin_move( endangle, 0.1 );
}

pin_move( angle, time )
{
    angles = ( angle, self.angles[1], self.angles[2] );
    self rotateto( angles, time );
}

pin_check_rotation( angle, time )
{
    if ( self.angles[0] > angle )
    {
        self pin_move( angle, time );

        self waittill( "rotatedone" );
    }
}
