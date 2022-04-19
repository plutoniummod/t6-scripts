// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_globallogic_score;

init()
{
    if ( !is_gametype_active( "zclassic" ) )
        return;

    level thread achievement_buried_sidequest();
    level thread achievement_im_your_huckleberry();
    level.achievement_sound_func = ::achievement_sound_func;
    onplayerconnect_callback( ::onplayerconnect );
}

achievement_sound_func( achievement_name_lower )
{
    if ( !sessionmodeisonlinegame() )
        return;

    self thread do_player_general_vox( "general", "achievement" );
}

init_player_achievement_stats()
{
    if ( !is_gametype_active( "zclassic" ) )
        return;

    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc3_buried_sidequest", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc3_ectoplasmic_residue", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc3_im_your_huckleberry", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc3_death_from_below", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc3_candygram", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc3_awaken_the_gazebo", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc3_revisionist_historian", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc3_mazed_and_confused", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc3_fsirt_against_the_wall", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc3_when_the_revolution_comes", 0 );
}

onplayerconnect()
{
    self thread achievement_ectoplasmic_residue();
    self thread achievement_death_from_below();
    self thread achievement_candygram();
    self thread achievement_awaken_the_gazebo();
    self thread achievement_revisionist_historian();
    self thread achievement_mazed_and_confused();
    self thread achievement_fsirt_against_the_wall();
    self thread achievement_when_the_revolution_comes();
}

achievement_buried_sidequest()
{
    level endon( "end_game" );
    level waittill_any( "sq_richtofen_complete", "sq_maxis_complete" );
/#

#/
    level giveachievement_wrapper( "ZM_DLC3_BURIED_SIDEQUEST", 1 );
}

achievement_im_your_huckleberry()
{
    level endon( "end_game" );
    num_barriers_broken = 0;

    while ( true )
    {
        level waittill( "sloth_breaks_barrier" );

        num_barriers_broken++;

        if ( num_barriers_broken >= 8 )
            break;
    }
/#

#/
    level giveachievement_wrapper( "ZM_DLC3_IM_YOUR_HUCKLEBERRY", 1 );
}

achievement_ectoplasmic_residue()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    self waittill( "player_received_ghost_round_free_perk" );
/#

#/
    self giveachievement_wrapper( "ZM_DLC3_ECTOPLASMIC_RESIDUE" );
}

achievement_death_from_below()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    num_subwoofer_deaths = 0;

    while ( true )
    {
        self waittill( "zombie_subwoofer_kill" );

        num_subwoofer_deaths++;

        if ( num_subwoofer_deaths >= 10 )
            break;
    }
/#

#/
    self giveachievement_wrapper( "ZM_DLC3_DEATH_FROM_BELOW" );
}

achievement_candygram()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    self waittill( "player_gives_sloth_candy" );
/#

#/
    self giveachievement_wrapper( "ZM_DLC3_CANDYGRAM" );
}

achievement_awaken_the_gazebo()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    level endon( "bank_withdrawal" );
    level endon( "bank_teller_used" );
    level endon( "weapon_locker_grab" );

    self waittill( "pap_taken" );

    if ( level.round_number > 1 )
        return;
/#

#/
    self giveachievement_wrapper( "ZM_DLC3_AWAKEN_THE_GAZEBO" );
}

achievement_revisionist_historian()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    self waittill( "player_activates_timebomb" );
/#

#/
    self giveachievement_wrapper( "ZM_DLC3_REVISIONIST_HISTORIAN" );
}

achievement_mazed_and_confused()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    self waittill( "player_stayed_in_maze_for_entire_high_level_round" );
/#

#/
    self giveachievement_wrapper( "ZM_DLC3_MAZED_AND_CONFUSED" );
}

achievement_fsirt_against_the_wall()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    self waittill( "player_upgraded_lsat_from_wall" );
/#

#/
    self giveachievement_wrapper( "ZM_DLC3_FSIRT_AGAINST_THE_WALL" );
}

achievement_when_the_revolution_comes()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    self waittill( "player_used_fountain_teleporter" );
/#

#/
    self giveachievement_wrapper( "ZM_DLC3_WHEN_THE_REVOLUTION_COMES" );
}
