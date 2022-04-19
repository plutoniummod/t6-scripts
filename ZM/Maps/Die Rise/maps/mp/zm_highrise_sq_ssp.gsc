// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zm_highrise_sq;

init_1()
{
    flag_init( "ssp1_ball0_complete" );
    flag_init( "ssp1_ball1_complete" );
    flag_init( "ssp1_complete" );
    declare_sidequest_stage( "sq_1", "ssp_1", ::init_stage_1, ::stage_logic_1, ::exit_stage_1 );
}

init_2()
{
    flag_init( "ssp2_maxis_keep_going_said" );
    flag_init( "ssp2_maxis_reincarnate_said" );
    flag_init( "ssp2_corpses_in_place" );
    flag_init( "ssp2_resurrection_done" );
    flag_init( "ssp2_statue_complete" );
    maps\mp\zombies\_zm_spawner::add_custom_zombie_spawn_logic( ::ssp_2_zombie_death_check );
    declare_sidequest_stage( "sq_2", "ssp_2", ::init_stage_2, ::stage_logic_2, ::exit_stage_2 );
}

init_stage_1()
{
    clientnotify( "ssp_1" );
    level thread vo_richtofen_instructions();
}

init_stage_2()
{
    clientnotify( "ssp_2" );
    level thread vo_maxis_start_ssp();
}

stage_logic_1()
{
/#
    iprintlnbold( "SSP1 Started" );
#/
    ssp1_sliquify_balls();
    stage_completed( "sq_1", "ssp_1" );
}

ssp1_sliquify_balls()
{
    a_balls = getentarray( "sq_sliquify_ball", "targetname" );
    level thread vo_sliquify_fail_watch();
    level thread ssp1_advance_dragon();
    level thread vo_richtofen_sliquify_confirm();
    level thread vo_maxis_sliquify_fail();

    for ( i = 0; i < a_balls.size; i++ )
        a_balls[i] thread ssp1_watch_ball( "ssp1_ball" + i + "_complete" );

    while ( !flag( "ssp1_ball0_complete" ) || !flag( "ssp1_ball1_complete" ) )
    {
        flag_wait_any( "ssp1_ball0_complete", "ssp1_ball1_complete" );
        wait 0.5;
    }

    maps\mp\zm_highrise_sq::light_dragon_fireworks( "r", 2 );
}

ssp1_watch_ball( str_complete_flag )
{
    self watch_model_sliquification( 20, str_complete_flag );
    self thread ssp1_rotate_ball();
    self playloopsound( "zmb_sq_ball_rotate_loop", 0.25 );
}

ssp1_rotate_ball()
{
    while ( isdefined( self ) )
    {
        self rotateyaw( 360, 1 );
        wait 0.9;
    }
}

ssp1_advance_dragon()
{
    flag_wait_any( "ssp1_ball0_complete", "ssp1_ball1_complete" );
    maps\mp\zm_highrise_sq::light_dragon_fireworks( "r", 2 );
}

stage_logic_2()
{
/#
    iprintlnbold( "SSP2 Started" );
#/
    level thread ssp2_advance_dragon();
    corpse_room_watcher();
    stage_completed( "sq_2", "ssp_2" );
}

corpse_room_watcher()
{
    t_corpse_room = getent( "corpse_room_trigger", "targetname" );
    n_count = 0;

    while ( !flag( "ssp2_resurrection_done" ) )
    {
        level waittill( "ssp2_corpse_made", is_in_room );

        if ( is_in_room )
            n_count++;
        else
            n_count = 0;

        if ( n_count == 1 && !flag( "ssp2_maxis_keep_going_said" ) )
        {
            flag_set( "ssp2_maxis_keep_going_said" );
            level thread maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_reincar_zombie_0" );
        }
        else if ( n_count >= 15 )
        {
/#
            iprintlnbold( "Corpse Count Reached" );
#/
            level thread vo_maxis_ssp_reincarnate();
            flag_set( "ssp2_corpses_in_place" );
            corpse_room_revive_watcher();
            level notify( "end_revive_watcher" );
        }
    }
}

ssp_2_zombie_death_check()
{
    self waittill( "death" );

    if ( !isdefined( self ) )
        return;

    t_corpse_room = getent( "corpse_room_trigger", "targetname" );

    if ( self istouching( t_corpse_room ) )
        level notify( "ssp2_corpse_made", 1 );
    else
        level notify( "ssp2_corpse_made", 0 );
}

corpse_room_cleanup_watcher()
{
    level endon( "ssp2_resurrection_done" );
    t_corpse_room = getent( "corpse_room_trigger", "targetname" );

    while ( true )
    {
        wait 1;
        a_corpses = getcorpsearray();

        if ( a_corpses.size < 15 )
        {
            level thread vo_maxis_ssp_fail();
            level notify( "end_revive_watcher" );
            return;
        }

        n_count = 0;

        foreach ( m_corpse in a_corpses )
        {
            if ( m_corpse istouching( t_corpse_room ) )
                n_count++;
        }

        if ( n_count < 15 )
        {
            level thread vo_maxis_ssp_fail();
            level notify( "end_revive_watcher" );
            return;
        }
    }
}

corpse_room_revive_watcher()
{
    level endon( "end_revive_watcher" );
    weaponname = "none";
    str_type = "none";
    t_corpse_room_dmg = getent( "corpse_room_trigger", "targetname" );

    while ( weaponname != "knife_ballistic_upgraded_zm" || str_type != "MOD_IMPACT" )
    {
        t_corpse_room_dmg waittill( "damage", amount, inflictor, direction, point, type );

        if ( isplayer( inflictor ) )
        {
            weaponname = inflictor.currentweapon;
            str_type = type;
        }
    }
/#
    iprintlnbold( "Revive Complete" );
#/
    vo_maxis_ssp_complete();
    flag_set( "ssp2_resurrection_done" );
}

ssp2_advance_dragon()
{
    flag_wait( "ssp2_corpses_in_place" );
    maps\mp\zm_highrise_sq::light_dragon_fireworks( "m", 1 );
    flag_wait( "ssp2_resurrection_done" );
    maps\mp\zm_highrise_sq::light_dragon_fireworks( "m", 2 );
}

exit_stage_1( success )
{
    flag_set( "ssp1_complete" );
}

exit_stage_2( success )
{

}

watch_model_sliquification( n_end_limit, str_complete_flag )
{
    n_count = 0;
    self setcandamage( 1 );

    while ( !flag( str_complete_flag ) )
    {
        self waittill( "damage", amount, attacker, direction, point, mod, tagname, modelname, partname, weaponname );

        if ( issubstr( weaponname, "slipgun" ) && !flag( "sq_ball_picked_up" ) )
        {
            n_count++;

            if ( n_count >= n_end_limit )
            {
/#
                iprintlnbold( "MODEL COMPLETE: " + str_complete_flag );
#/
                self notify( "sq_sliquified" );

                if ( isdefined( self.t_pickup ) )
                    self.t_pickup delete();

                flag_set( str_complete_flag );
            }
            else if ( n_count == 1 )
                level notify( "ssp1_ball_first_sliquified" );
            else if ( n_count == 10 )
                level notify( "ssp1_ball_sliquified_2" );
        }
    }
}

vo_richtofen_instructions()
{
    maps\mp\zm_highrise_sq::richtofensay( "vox_zmba_sidequest_sliquif_balls_0" );
    wait 10;
    maps\mp\zm_highrise_sq::richtofensay( "vox_zmba_sidequest_sliquif_balls_1" );
}

vo_sliquify_fail_watch()
{
    flag_wait( "sq_ball_picked_up" );
    maps\mp\zm_highrise_sq::richtofensay( "vox_zmba_sidequest_fail_1" );
}

vo_richtofen_sliquify_confirm()
{
    level waittill( "ssp1_ball_first_sliquified" );

    maps\mp\zm_highrise_sq::richtofensay( "vox_zmba_sidequest_sliquif_balls_2" );

    level waittill( "ssp1_ball_sliquified_2" );

    maps\mp\zm_highrise_sq::richtofensay( "vox_zmba_sidequest_sliquif_balls_3" );
    flag_wait( "ssp1_complete" );
    maps\mp\zm_highrise_sq::richtofensay( "vox_zmba_sidequest_sliquif_balls_4" );
    wait 10;
    maps\mp\zm_highrise_sq::richtofensay( "vox_zmba_sidequest_sliquif_balls_5" );
}

vo_maxis_sliquify_fail()
{
    flag_wait_any( "ssp1_ball0_complete", "ssp1_ball1_complete" );
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_fail_3" );
}

vo_maxis_start_ssp()
{
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_lion_balls_3" );
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_lion_balls_4" );
}

vo_maxis_ssp_reincarnate()
{
    if ( !flag( "ssp2_maxis_reincarnate_said" ) )
    {
        flag_set( "ssp2_maxis_reincarnate_said" );
        maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_reincar_zombie_1" );
    }
    else
        flag_clear( "ssp2_maxis_reincarnate_said" );
}

vo_maxis_ssp_fail()
{
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_reincar_zombie_5" );
}

vo_maxis_ssp_complete()
{
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_reincar_zombie_3" );
    maps\mp\zm_highrise_sq::maxissay( "vox_maxi_sidequest_reincar_zombie_6" );
}
