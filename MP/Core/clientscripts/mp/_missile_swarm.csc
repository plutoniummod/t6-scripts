// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool

main()
{
    level._effect["swarm_tail"] = loadfx( "weapon/harpy_swarm/fx_hrpy_swrm_exhaust_trail_close" );
    registerclientfield( "world", "missile_swarm", 1, 2, "int", ::swarm_start, 0 );
}

swarm_start( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    player = getlocalplayer( localclientnum );

    if ( !isdefined( player ) )
        return;

    if ( player getinkillcam( localclientnum ) )
        return;

    if ( isdemoplaying() )
        return;

    if ( newval && newval != oldval && newval != 2 )
        player thread swarm_think( localclientnum, self.origin );
    else if ( !newval )
        level notify( "missile_swarm_stop" );
    else if ( newval == 2 )
    {
        level notify( "missile_emp_death" );
        level notify( "missile_swarm_stop" );
    }
}

swarm_think( localclientnum, sound_origin )
{
    level endon( "missile_swarm_stop" );
    self endon( "entityshutdown" );
    self.missile_swarm_count = 0;
    self.missile_swarm_max = 12;
    level thread swarm_sound( localclientnum, sound_origin );

    for (;;)
    {
        if ( self.missile_swarm_count < 0 )
            self.missile_swarm_count = 0;

        if ( self.missile_swarm_count > self.missile_swarm_max )
        {
            wait 0.5;
            continue;
        }

        count = randomintrange( 1, 3 );
        self.missile_swarm_count = self.missile_swarm_count + count;

        for ( i = 0; i < count; i++ )
            self projectile_spawn( localclientnum );

        wait( self.missile_swarm_count / self.missile_swarm_max );
    }
}

#using_animtree("mp_missile_drone");

projectile_spawn( localclientnum )
{
    dist = 10000;
    upvector = ( 0, 0, randomintrange( 1000, 1300 ) );
    yaw = randomintrange( 0, 360 );
    angles = ( 0, yaw, 0 );
    forward = anglestoforward( angles );
    origin = self.origin + upvector + forward * dist * -1;
    end = self.origin + upvector + forward * dist;
    rocket = spawn( localclientnum, origin, "script_model" );
    rocket setmodel( "veh_t6_drone_hunterkiller_viewmodel" );
    rocket useanimtree( #animtree );
    rocket setanim( %o_drone_hunter_launch, 1.0, 0.0, 1.0 );
    rocket thread projectile_move_think( localclientnum, self, origin, end );
    rocket thread projectile_delete_think( localclientnum );
}

projectile_move_think( localclientnum, player, start, end )
{
    level endon( "missile_emp_death" );
    wait( randomfloatrange( 0.5, 1 ) );
    playfxontag( localclientnum, level._effect["swarm_tail"], self, "tag_origin" );
    direction = end - self.origin;
    self rotateto( vectorangles( direction ), 0.05 );
    self waittill( "rotatedone" );
    self moveto( end, randomfloatrange( 12, 18 ) );
    self waittill( "movedone" );

    if ( isdefined( player ) )
        player.missile_swarm_count--;

    self delete();
}

swarm_sound( localclientnum, origin )
{
    level endon( "missile_swarm_stop" );
    entity = spawn( localclientnum, origin, "script_model" );
    entity thread deleteonmissileswarmstop();
    wait 2;
    entity playloopsound( "veh_harpy_drone_swarm_close__lp", 1 );
}

deleteonmissileswarmstop()
{
    level waittill( "missile_swarm_stop" );
    self stoploopsound( 1 );
    wait 1;
    self delete();
}

projectile_delete_think( localclientnum )
{
    self endon( "death" );
    level waittill( "missile_emp_death" );

    if ( isdefined( self ) )
        self delete();
}
