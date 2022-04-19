// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_globallogic_score;

init()
{
    level thread achievement_highrise_sidequest();
    level thread achievement_mad_without_power();
    level.achievement_sound_func = ::achievement_sound_func;
    onplayerconnect_callback( ::onplayerconnect );
}

achievement_sound_func( achievement_name_lower )
{
    self thread do_player_general_vox( "general", "achievement" );
}

init_player_achievement_stats()
{
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc1_highrise_sidequest", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc1_vertigoner", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc1_slippery_when_undead", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc1_facing_the_dragon", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc1_im_my_own_best_friend", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc1_mad_without_power", 0 );
    self maps\mp\gametypes_zm\_globallogic_score::initpersstat( "zm_dlc1_shafted", 0 );
}

onplayerconnect()
{
    self thread achievement_vertigoner();
    self thread achievement_slippery_when_undead();
    self thread achievement_facing_the_dragon();
    self thread achievement_im_my_own_best_friend();
    self thread achievement_shafted();
}

achievement_highrise_sidequest()
{
    level endon( "end_game" );

    level waittill( "highrise_sidequest_achieved" );
/#
    iprintlnbold( "ZM_DLC1_HIGHRISE_SIDEQUEST achieved for the team" );
#/
    level giveachievement_wrapper( "ZM_DLC1_HIGHRISE_SIDEQUEST", 1 );
}

achievement_vertigoner()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    self.num_zombies_flung = 0;
    max_zombies_flung = 10;

    while ( self.num_zombies_flung < max_zombies_flung )
    {
        self waittill( "zombie_flung" );

        wait 0.1;
    }
/#

#/
    self giveachievement_wrapper( "ZM_DLC1_VERTIGONER" );
}

achievement_slippery_when_undead()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    self.num_sliquifier_kills = 0;
    max_kills_with_one_shot = 5;

    while ( self.num_sliquifier_kills < max_kills_with_one_shot )
    {
        self waittill( "sliquifier_kill" );

        wait 0.01;
    }
/#

#/
    self giveachievement_wrapper( "ZM_DLC1_SLIPPERY_WHEN_UNDEAD" );
}

achievement_facing_the_dragon()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    v_achievement_location = ( 2209, 693, 3200 );
    v_dragon_position = ( 971, 43, 3800 );
    is_touching_distance = 350;
    round_number_max = 2;

    while ( true )
    {
        if ( level.round_number >= round_number_max )
            return;

        dist = distance( self.origin, v_achievement_location );

        if ( dist <= is_touching_distance )
        {
            v_dir = vectornormalize( v_dragon_position - self.origin );
            v_forward = self getweaponforwarddir();
            dp = vectordot( v_dir, v_forward );

            if ( dp > 0.95 )
                break;
        }

        wait 0.01;
    }
/#

#/
    self giveachievement_wrapper( "ZM_DLC1_FACING_THE_DRAGON" );
}

achievement_im_my_own_best_friend()
{
    level endon( "end_game" );
    self endon( "disconnect" );

    self waittill( "whos_who_self_revive" );
/#

#/
    self giveachievement_wrapper( "ZM_DLC1_IM_MY_OWN_BEST_FRIEND" );
}

achievement_mad_without_power()
{
    level endon( "end_game" );
    round_number_max = 10;

    while ( level.round_number < round_number_max )
    {
        level waittill( "start_of_round" );

        if ( flag( "power_on" ) )
            return;
    }
/#

#/
    self giveachievement_wrapper( "ZM_DLC1_MAD_WITHOUT_POWER", 1 );
}

achievement_shafted()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    level.perk_bought_func = ::player_buys_perk_machine;
    max_unique_perk_machines = 6;

    while ( true )
    {
        self waittill_any( "player_buys_perk", "pap_used" );

        if ( isdefined( self.pap_used ) && self.pap_used == 1 )
        {
            if ( isdefined( self.perk_machines_bought ) && self.perk_machines_bought.size >= max_unique_perk_machines )
                break;
        }
    }
/#

#/
    self giveachievement_wrapper( "ZM_DLC1_SHAFTED" );
}

player_buys_perk_machine( perk )
{
    if ( !isdefined( self.perk_machines_bought ) )
        self.perk_machines_bought = [];

    found = 0;

    for ( i = 0; i < self.perk_machines_bought.size; i++ )
    {
        if ( perk == self.perk_machines_bought[i] )
        {
            found = 1;
            break;
        }
    }

    if ( !found )
    {
        self.perk_machines_bought[self.perk_machines_bought.size] = perk;
        self notify( "player_buys_perk" );
    }
}
