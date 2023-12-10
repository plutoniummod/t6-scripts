// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;

init()
{
/#
    thread dog_dvar_updater();
#/
    level.movementstatesound = [];
    level.maxstatesounddistance = 99999999;
    level.movementstatesound["normal"] = spawnstruct();
    level.movementstatesound["normal"].sound = "aml_dog_bark";
    level.movementstatesound["normal"].waitmax = 4;
    level.movementstatesound["normal"].waitmin = 1;
    level.movementstatesound["normal"].enemyrange = level.maxstatesounddistance;
    level.movementstatesound["normal"].localenemyonly = 0;
    level.movementstatesound["attack_mid_everyone"] = spawnstruct();
    level.movementstatesound["attack_mid_everyone"].sound = "aml_dog_bark_mid";
    level.movementstatesound["attack_mid_everyone"].waitmax = 2;
    level.movementstatesound["attack_mid_everyone"].waitmin = 0.5;
    level.movementstatesound["attack_mid_everyone"].enemyrange = 1500;
    level.movementstatesound["attack_mid_everyone"].localenemyonly = 0;
    level.movementstatesound["attack_mid_enemy"] = spawnstruct();
    level.movementstatesound["attack_mid_enemy"].sound = "aml_dog_bark_mid";
    level.movementstatesound["attack_mid_enemy"].waitmax = 0.5;
    level.movementstatesound["attack_mid_enemy"].waitmin = 0.01;
    level.movementstatesound["attack_mid_enemy"].enemyrange = 1500;
    level.movementstatesound["attack_mid_enemy"].localenemyonly = 1;
    level.movementstatesound["attack_close_enemy"] = spawnstruct();
    level.movementstatesound["attack_close_enemy"].sound = "aml_dog_bark_close";
    level.movementstatesound["attack_close_enemy"].waitmax = 0.1;
    level.movementstatesound["attack_close_enemy"].waitmin = 0.01;
    level.movementstatesound["attack_close_enemy"].enemyrange = 1000;
    level.movementstatesound["attack_close_enemy"].localenemyonly = 1;
}

dog_dvar_updater()
{
/#
    while ( true )
    {
        level.dog_debug_sound = dog_get_dvar_int( "debug_dog_sound", "0" );
        level.dog_debug = dog_get_dvar_int( "debug_dogs", "0" );
        wait 1;
    }
#/
}

spawned( localclientnum )
{
    self endon( "entityshutdown" );
    self thread animcategorywatcher( localclientnum );
    self thread enemywatcher( localclientnum );
/#
    self thread shutdownwatcher( localclientnum );
#/
}

shutdownwatcher( localclientnum )
{
/#
    if ( !isdefined( level.dog_debug ) )
        return;

    if ( !level.dog_debug )
        return;

    number = self getentnum();
    println( "_+_+_+_+_+_+_+_+_+_+_  NEWLY SPAWNED DOG" + number );
    self waittill( "entityshutdown" );
    println( "_+_+_+_+_+_+_+_+_+_+_  DOG SHUTDOWN" + number );
#/
}

animcategorychanged( localclientnum, animcategory )
{
    self.animcategory = animcategory;
    self notify( "killanimscripts" );
    dog_print( "anim category changed " + animcategory );

    switch ( animcategory )
    {
        case "move":
            self thread playmovementsounds( localclientnum );
            break;
        case "pain":
            self thread playpainsounds( localclientnum );
            break;
        case "death":
            self thread playdeathsounds( localclientnum );
            break;
    }
}

animcategorywatcher( localclientnum )
{
    self endon( "entityshutdown" );

    if ( !isdefined( self.animcategory ) )
        animcategorychanged( localclientnum, self getanimstatecategory() );

    while ( true )
    {
        animcategory = self getanimstatecategory();

        if ( isdefined( animcategory ) && self.animcategory != animcategory && animcategory != "traverse" )
            animcategorychanged( localclientnum, animcategory );

        wait 0.05;
    }
}

enemywatcher( localclientnum )
{
    self endon( "entityshutdown" );

    while ( true )
    {
        self waittill( "enemy" );
/#
        if ( isdefined( self.enemy ) )
        {
            dog_print( "NEW ENEMY " + self.enemy getentnum() );

            if ( islocalplayerenemy( self.enemy ) )
                self thread playlockonsounds( localclientnum );
        }
        else
            dog_print( "NEW ENEMY CLEARED" );
#/
    }
}

getotherteam( team )
{
    if ( team == "allies" )
        return "axis";
    else if ( team == "axis" )
        return "allies";
    else if ( team == "free" )
        return "free";

/#
    assertmsg( "getOtherTeam: invalid team " + team );
#/
}

islocalplayerenemy( enemy )
{
    if ( !isdefined( enemy ) )
        return false;

    players = level.localplayers;

    if ( isdefined( players ) )
    {
        for ( i = 0; i < players.size; i++ )
        {
            if ( players[i] == enemy )
                return true;
        }
    }

    return false;
}

hasenemychanged( last_enemy )
{
    if ( !isdefined( last_enemy ) && isdefined( self.enemy ) )
        return true;

    if ( isdefined( last_enemy ) && !isdefined( self.enemy ) )
        return true;

    if ( last_enemy != self.enemy )
        return true;

    return false;
}

getmovementsoundstate()
{
    localplayer = islocalplayerenemy( self.enemy );
    closest_dist = level.maxstatesounddistance * level.maxstatesounddistance;
    closest_key = "normal";
    has_enemy = isdefined( self.enemy );

    if ( has_enemy )
        enemy_distance = distancesquared( self.origin, self.enemy.origin );
    else
        return "normal";

    statearray = getarraykeys( level.movementstatesound );

    for ( i = 0; i < statearray.size; i++ )
    {
        if ( level.movementstatesound[statearray[i]].localenemyonly && !localplayer )
            continue;

        state_dist = level.movementstatesound[statearray[i]].enemyrange;
        state_dist = state_dist * state_dist;

        if ( state_dist < enemy_distance )
            continue;

        if ( state_dist < closest_dist )
        {
            closest_dist = state_dist;
            closest_key = statearray[i];
        }
    }

    return closest_key;
}

playmovementsounds( localclientnum )
{
    self endon( "entityshutdown" );
    self endon( "killanimscripts" );
    last_state = "normal";
    last_time = 0;
    wait_time = 0;

    while ( true )
    {
        state = getmovementsoundstate();
        next_sound = 0;

        if ( state != last_state && level.movementstatesound[state].waitmax < wait_time )
        {
            dog_sound_print( "New State forcing next sound" );
            next_sound = 1;
        }

        if ( next_sound || last_time + wait_time < getrealtime() )
        {
            if ( isdefined( self.enemy ) )
                dog_sound_print( "enemy distance: " + distance( self.origin, self.enemy.origin ) );

            soundid = self play_dog_sound( localclientnum, level.movementstatesound[state].sound );
            last_state = state;

            if ( soundid >= 0 )
            {
                while ( soundplaying( soundid ) )
                    wait 0.05;

                last_time = getrealtime();
                wait_time = 1000 * randomfloatrange( level.movementstatesound[state].waitmin, level.movementstatesound[state].waitmax );
                dog_sound_print( "wait_time: " + wait_time );
            }
            else
                wait 0.5;
        }

        wait 0.05;
    }
}

playpainsounds( localclientnum )
{
    self endon( "entityshutdown" );
    self endon( "killanimscripts" );
    soundid = self play_dog_sound( localclientnum, "aml_dog_pain" );
}

playdeathsounds( localclientnum )
{
    self endon( "entityshutdown" );
    self endon( "killanimscripts" );
    soundid = self play_dog_sound( localclientnum, "aml_dog_death" );
}

playlockonsounds( localclientnum )
{
    self endon( "entityshutdown" );
    soundid = self play_dog_sound( localclientnum, "aml_dog_lock" );
}

soundnotify( client_num, entity, note )
{
    if ( note == "sound_dogstep_run_default" )
    {
        entity playsound( client_num, "fly_dog_step_run_default" );
        return true;
    }

    alias = "aml" + getsubstr( note, 5 );
    entity play_dog_sound( client_num, alias );
}

dog_get_dvar_int( dvar, def )
{
    return int( dog_get_dvar( dvar, def ) );
}

dog_get_dvar( dvar, def )
{
    if ( getdvar( dvar ) != "" )
        return getdvarflaot( dvar );
    else
        return def;
}

dog_sound_print( message )
{
/#
    if ( !isdefined( level.dog_debug_sound ) )
        return;

    if ( !level.dog_debug_sound )
        return;

    println( "CLIENT DOG SOUND(" + self getentnum() + "," + getrealtime() + "): " + message );
#/
}

dog_print( message )
{
/#
    if ( !isdefined( level.dog_debug ) )
        return;

    if ( !level.dog_debug )
        return;

    println( "CLIENT DOG DEBUG(" + self getentnum() + "): " + message );
#/
}

play_dog_sound( localclientnum, sound, position )
{
    dog_sound_print( "SOUND " + sound );

    if ( isdefined( position ) )
        return self playsound( localclientnum, sound, position );

    return self playsound( localclientnum, sound );
}
