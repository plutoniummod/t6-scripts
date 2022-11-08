// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

#using_animtree("zm_buried_props");

init_jail_animtree()
{
    scriptmodelsuseanimtree( #animtree );
}

init_jail_anims()
{
    level.jail_open = %o_zombie_sloth_idle_jail_2_cower_door;
    level.jail_open_jumpback = %o_zombie_sloth_idle_jail_2_cower_jumpback_door;
    level.jail_close_idle = %o_zombie_sloth_run_into_jail_2_idle_jail;
    level.jail_close_cower = %o_zombie_sloth_cower_2_close_door;
}

jailuseanimtree()
{
    self useanimtree( #animtree );
}

init_jail()
{
    init_jail_anims();
    level.cell_door = getent( "sloth_cell_door", "targetname" );
    level.cell_door.clip = getent( level.cell_door.target, "targetname" );
    level.cell_door jailuseanimtree();
    level.jail_open_door = ::jail_open_door;
    level.jail_close_door = ::jail_close_door;
}

jail_open_door( jumpback )
{
    level.cell_door playsound( "zmb_jail_door_open" );

    if ( is_true( jumpback ) )
        level.cell_door setanim( level.jail_open_jumpback, 1, 1, 1 );
    else
        level.cell_door setanim( level.jail_open, 1, 1, 1 );

    if ( isdefined( level.cell_door.clip ) )
    {
        level.cell_door.clip notsolid();
        level.cell_door.clip connectpaths();
    }
}

jail_close_door()
{
    level.cell_door playsound( "zmb_jail_door_close" );
    level.cell_door setanim( level.jail_close_cower, 1, 1, 1 );

    if ( isdefined( level.cell_door.clip ) )
    {
        level.cell_door.clip solid();
        level.cell_door.clip disconnectpaths();
    }
}
