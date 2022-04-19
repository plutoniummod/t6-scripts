// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_magicbox_lock;
#include maps\mp\zombies\_zm_unitrigger;

init()
{
    precachemodel( "p6_anim_zm_al_magic_box_lock_red" );
    level.locked_magic_box_cost = 2000;
    level.custom_magicbox_state_handler = maps\mp\zombies\_zm_magicbox_lock::set_locked_magicbox_state;
    add_zombie_hint( "locked_magic_box_cost", &"ZOMBIE_LOCKED_COST_2000" );
}

watch_for_lock()
{
    self endon( "user_grabbed_weapon" );
    self endon( "chest_accessed" );

    self waittill( "box_locked" );

    self notify( "kill_chest_think" );
    self.grab_weapon_hint = 0;
    self.chest_user = undefined;
    wait 0.1;
    self thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
    self.unitrigger_stub run_visibility_function_for_all_triggers();
    self thread treasure_chest_think();
}

clean_up_locked_box()
{
    self endon( "box_spin_done" );

    self.owner waittill( "box_locked" );

    if ( isdefined( self.weapon_model ) )
    {
        self.weapon_model delete();
        self.weapon_model = undefined;
    }

    if ( isdefined( self.weapon_model_dw ) )
    {
        self.weapon_model_dw delete();
        self.weapon_model_dw = undefined;
    }

    self hidezbarrierpiece( 3 );
    self hidezbarrierpiece( 4 );
    self setzbarrierpiecestate( 3, "closed" );
    self setzbarrierpiecestate( 4, "closed" );
}

magic_box_locks()
{
    self.owner.is_locked = 1;
    self.owner notify( "box_locked" );
    self playsound( "zmb_hellbox_lock" );
    self setclientfield( "magicbox_open_fx", 0 );
    self setclientfield( "magicbox_amb_fx", 2 );
    self setzbarrierpiecestate( 5, "closing" );

    while ( self getzbarrierpiecestate( 5 ) == "closing" )
        wait 0.5;

    self notify( "locked" );
}

magic_box_unlocks()
{
    maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.owner.unitrigger_stub );
    self playsound( "zmb_hellbox_unlock" );
    self setzbarrierpiecestate( 5, "opening" );

    while ( self getzbarrierpiecestate( 5 ) == "opening" )
        wait 0.5;

    self setzbarrierpiecestate( 2, "closed" );
    self showzbarrierpiece( 2 );
    self hidezbarrierpiece( 5 );
    self notify( "unlocked" );
    self.owner.is_locked = 0;
    maps\mp\zombies\_zm_unitrigger::register_unitrigger( self.owner.unitrigger_stub );
    self setclientfield( "magicbox_amb_fx", 1 );
}

set_locked_magicbox_state( state )
{
    switch ( state )
    {
        case "locking":
            self showzbarrierpiece( 5 );
            self thread magic_box_locks();
            self.state = "locking";
            break;
        case "unlocking":
            self showzbarrierpiece( 5 );
            self magic_box_unlocks();
            self.state = "close";
            break;
    }
}
