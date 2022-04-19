// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;

init()
{

}

wait_until_first_player()
{
    players = get_players();

    if ( !isdefined( players[0] ) )
        level waittill( "first_player_ready" );

    players = get_players();

    for ( i = 0; i < players.size; i++ )
        players[i] thread monitor_player_sprint();
}

stand_think( trig )
{
    killtext = "kill_stand_think" + trig getentitynumber();
    self endon( "disconnect" );
    self endon( "death" );
    self endon( killtext );

    while ( true )
    {
        if ( self.player_is_moving )
            trig playsound( trig.script_label );

        wait 1;
    }
}

monitor_player_sprint()
{
    self endon( "disconnect" );
    self thread monitor_player_movement();

    for ( self._is_sprinting = 0; 1; self._is_sprinting = 0 )
    {
        self waittill( "sprint_begin" );

        self._is_sprinting = 1;

        self waittill( "sprint_end" );
    }
}

monitor_player_movement()
{
    self endon( "disconnect" );

    while ( true )
    {
        org_1 = self.origin;
        wait 1.0;
        org_2 = self.origin;
        distancemoved = distancesquared( org_1, org_2 );

        if ( distancemoved > 4096 )
            self.player_is_moving = 1;
        else
            self.player_is_moving = 0;
    }
}

thread_enter_exit_sound( trig )
{
    self endon( "death" );
    self endon( "disconnect" );
    trig.touchingplayers[self getentitynumber()] = 1;

    if ( isdefined( trig.script_sound ) && trig.script_activated && self._is_sprinting )
        self playsound( trig.script_sound );

    self thread stand_think( trig );

    while ( self istouching( trig ) )
        wait 0.1;

    self notify( "kill_stand_think" + trig getentitynumber() );
    self playsound( trig.script_noteworthy );
    trig.touchingplayers[self getentitynumber()] = 0;
}

thread_step_trigger()
{
    if ( !isdefined( self.script_activated ) )
        self.script_activated = 1;

    if ( !isdefined( self.touchingplayers ) )
    {
        self.touchingplayers = [];

        for ( i = 0; i < 4; i++ )
            self.touchingplayers[i] = 0;
    }

    while ( true )
    {
        self waittill( "trigger", who );

        if ( self.touchingplayers[who getentitynumber()] == 0 )
            who thread thread_enter_exit_sound( self );
    }
}

disable_bump_trigger( triggername )
{
    triggers = getentarray( "audio_bump_trigger", "targetname" );

    if ( isdefined( triggers ) )
    {
        for ( i = 0; i < triggers.size; i++ )
        {
            if ( isdefined( triggers[i].script_label ) && triggers[i].script_label == triggername )
                triggers[i].script_activated = 0;
        }
    }
}

get_player_index_number( player )
{
    players = get_players();

    for ( i = 0; i < players.size; i++ )
    {
        if ( players[i] == player )
            return i;
    }

    return 1;
}
