// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

anim_get_dvar_int( dvar, def )
{
    return int( anim_get_dvar( dvar, def ) );
}

anim_get_dvar( dvar, def )
{
    if ( getdvar( dvar ) != "" )
        return getdvarfloat( dvar );
    else
    {
        setdvar( dvar, def );
        return def;
    }
}

set_orient_mode( mode, val1 )
{
/#
    if ( level.dog_debug_orient == self getentnum() )
    {
        if ( isdefined( val1 ) )
            println( "DOG:  Setting orient mode: " + mode + " " + val1 + " " + gettime() );
        else
            println( "DOG:  Setting orient mode: " + mode + " " + gettime() );
    }
#/
    if ( isdefined( val1 ) )
        self orientmode( mode, val1 );
    else
        self orientmode( mode );
}

debug_anim_print( text )
{
/#
    if ( level.dog_debug_anims )
        println( text + " " + gettime() );

    if ( level.dog_debug_anims_ent == self getentnum() )
        println( text + " " + gettime() );
#/
}

debug_turn_print( text, line )
{
/#
    if ( level.dog_debug_turns == self getentnum() )
    {
        duration = 200;
        currentyawcolor = ( 1, 1, 1 );
        lookaheadyawcolor = ( 1, 0, 0 );
        desiredyawcolor = ( 1, 1, 0 );
        currentyaw = angleclamp180( self.angles[1] );
        desiredyaw = angleclamp180( self.desiredangle );
        lookaheaddir = self.lookaheaddir;
        lookaheadangles = vectortoangles( lookaheaddir );
        lookaheadyaw = angleclamp180( lookaheadangles[1] );
        println( text + " " + gettime() + " cur: " + currentyaw + " look: " + lookaheadyaw + " desired: " + desiredyaw );
    }
#/
}

debug_allow_movement()
{
/#
    return anim_get_dvar_int( "debug_dog_allow_movement", "1" );
#/
    return 1;
}

debug_allow_combat()
{
/#
    return anim_get_dvar_int( "debug_dog_allow_combat", "1" );
#/
    return 1;
}

current_yaw_line_debug( duration )
{
/#
    currentyawcolor = [];
    currentyawcolor[0] = ( 0, 0, 1 );
    currentyawcolor[1] = ( 1, 0, 1 );
    current_color_index = 0;
    start_time = gettime();

    if ( !isdefined( level.lastdebugheight ) )
        level.lastdebugheight = 15;

    while ( gettime() - start_time < 1000 )
    {
        pos1 = ( self.origin[0], self.origin[1], self.origin[2] + level.lastdebugheight );
        pos2 = pos1 + vectorscale( anglestoforward( self.angles ), ( current_color_index + 1 ) * 10 );
        line( pos1, pos2, currentyawcolor[current_color_index], 0.3, 1, duration );
        current_color_index = ( current_color_index + 1 ) % currentyawcolor.size;
        wait 0.05;
    }

    if ( level.lastdebugheight == 15 )
        level.lastdebugheight = 30;
    else
        level.lastdebugheight = 15;
#/
}

getanimdirection( damageyaw )
{
    if ( damageyaw > 135 || damageyaw <= -135 )
        return "front";
    else if ( damageyaw > 45 && damageyaw <= 135 )
        return "right";
    else if ( damageyaw > -45 && damageyaw <= 45 )
        return "back";
    else
        return "left";

    return "front";
}

setfootstepeffect( name, fx )
{
/#
    assert( isdefined( name ), "Need to define the footstep surface type." );
#/
/#
    assert( isdefined( fx ), "Need to define the mud footstep effect." );
#/
    if ( !isdefined( anim.optionalstepeffects ) )
        anim.optionalstepeffects = [];

    anim.optionalstepeffects[anim.optionalstepeffects.size] = name;
    level._effect["step_" + name] = fx;
}
