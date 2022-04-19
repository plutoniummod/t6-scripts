// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_audio;

main()
{
    if ( !isdefined( level.weapon_locker_map ) )
        level.weapon_locker_map = level.script;

    level.weapon_locker_online = sessionmodeisonlinegame();
    weapon_lockers = getstructarray( "weapons_locker", "targetname" );
    array_thread( weapon_lockers, ::triggerweaponslockerwatch );
}

wl_has_stored_weapondata()
{
    if ( level.weapon_locker_online )
        return self has_stored_weapondata( level.weapon_locker_map );
    else
        return isdefined( self.stored_weapon_data );
}

wl_get_stored_weapondata()
{
    if ( level.weapon_locker_online )
        return self get_stored_weapondata( level.weapon_locker_map );
    else
        return self.stored_weapon_data;
}

wl_clear_stored_weapondata()
{
    if ( level.weapon_locker_online )
        self clear_stored_weapondata( level.weapon_locker_map );
    else
        self.stored_weapon_data = undefined;
}

wl_set_stored_weapondata( weapondata )
{
    if ( level.weapon_locker_online )
        self set_stored_weapondata( weapondata, level.weapon_locker_map );
    else
        self.stored_weapon_data = weapondata;
}

triggerweaponslockerwatch()
{
    unitrigger_stub = spawnstruct();
    unitrigger_stub.origin = self.origin;

    if ( isdefined( self.script_angles ) )
        unitrigger_stub.angles = self.script_angles;
    else
        unitrigger_stub.angles = self.angles;

    unitrigger_stub.script_angles = unitrigger_stub.angles;

    if ( isdefined( self.script_length ) )
        unitrigger_stub.script_length = self.script_length;
    else
        unitrigger_stub.script_length = 16;

    if ( isdefined( self.script_width ) )
        unitrigger_stub.script_width = self.script_width;
    else
        unitrigger_stub.script_width = 32;

    if ( isdefined( self.script_height ) )
        unitrigger_stub.script_height = self.script_height;
    else
        unitrigger_stub.script_height = 64;

    unitrigger_stub.origin -= anglestoright( unitrigger_stub.angles ) * unitrigger_stub.script_length / 2;
    unitrigger_stub.targetname = "weapon_locker";
    unitrigger_stub.cursor_hint = "HINT_NOICON";
    unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
    unitrigger_stub.clientfieldname = "weapon_locker";
    maps\mp\zombies\_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
    unitrigger_stub.prompt_and_visibility_func = ::triggerweaponslockerthinkupdateprompt;
    maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::triggerweaponslockerthink );
}

triggerweaponslockerisvalidweapon( weaponname )
{
    weaponname = get_base_weapon_name( weaponname, 1 );

    if ( !is_weapon_included( weaponname ) )
        return false;

    if ( is_offhand_weapon( weaponname ) || is_limited_weapon( weaponname ) )
        return false;

    return true;
}

triggerweaponslockerisvalidweaponpromptupdate( player, weaponname )
{
    retrievingweapon = player wl_has_stored_weapondata();

    if ( !retrievingweapon )
    {
        weaponname = player get_nonalternate_weapon( weaponname );

        if ( !triggerweaponslockerisvalidweapon( weaponname ) )
            self sethintstring( &"ZOMBIE_WEAPON_LOCKER_DENY" );
        else
            self sethintstring( &"ZOMBIE_WEAPON_LOCKER_STORE" );
    }
    else
    {
        weapondata = player wl_get_stored_weapondata();

        if ( isdefined( level.remap_weapon_locker_weapons ) )
            weapondata = remap_weapon( weapondata, level.remap_weapon_locker_weapons );

        weapontogive = weapondata["name"];
        primaries = player getweaponslistprimaries();
        maxweapons = get_player_weapon_limit( player );
        weaponname = player get_nonalternate_weapon( weaponname );

        if ( isdefined( primaries ) && primaries.size >= maxweapons || weapontogive == weaponname )
        {
            if ( !triggerweaponslockerisvalidweapon( weaponname ) )
            {
                self sethintstring( &"ZOMBIE_WEAPON_LOCKER_DENY" );
                return;
            }
        }

        self sethintstring( &"ZOMBIE_WEAPON_LOCKER_GRAB" );
    }
}

triggerweaponslockerthinkupdateprompt( player )
{
    self triggerweaponslockerisvalidweaponpromptupdate( player, player getcurrentweapon() );
    return 1;
}

triggerweaponslockerthink()
{
    self.parent_player thread triggerweaponslockerweaponchangethink( self );

    while ( true )
    {
        self waittill( "trigger", player );

        retrievingweapon = player wl_has_stored_weapondata();

        if ( !retrievingweapon )
        {
            curweapon = player getcurrentweapon();
            curweapon = player maps\mp\zombies\_zm_weapons::switch_from_alt_weapon( curweapon );

            if ( !triggerweaponslockerisvalidweapon( curweapon ) )
                continue;

            weapondata = player maps\mp\zombies\_zm_weapons::get_player_weapondata( player );
            player wl_set_stored_weapondata( weapondata );
/#
            assert( curweapon == weapondata["name"], "weapon data does not match" );
#/
            player takeweapon( curweapon );
            primaries = player getweaponslistprimaries();

            if ( isdefined( primaries[0] ) )
                player switchtoweapon( primaries[0] );
            else
                player maps\mp\zombies\_zm_weapons::give_fallback_weapon();

            self triggerweaponslockerisvalidweaponpromptupdate( player, player getcurrentweapon() );
            player playsoundtoplayer( "evt_fridge_locker_close", player );
            player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "weapon_storage" );
        }
        else
        {
            curweapon = player getcurrentweapon();
            primaries = player getweaponslistprimaries();
            weapondata = player wl_get_stored_weapondata();

            if ( isdefined( level.remap_weapon_locker_weapons ) )
                weapondata = remap_weapon( weapondata, level.remap_weapon_locker_weapons );

            weapontogive = weapondata["name"];

            if ( !triggerweaponslockerisvalidweapon( weapontogive ) )
            {
                player playlocalsound( level.zmb_laugh_alias );
                player wl_clear_stored_weapondata();
                self triggerweaponslockerisvalidweaponpromptupdate( player, player getcurrentweapon() );
                continue;
            }

            curweap_base = maps\mp\zombies\_zm_weapons::get_base_weapon_name( curweapon, 1 );
            weap_base = maps\mp\zombies\_zm_weapons::get_base_weapon_name( weapontogive, 1 );

            if ( player has_weapon_or_upgrade( weap_base ) && weap_base != curweap_base )
            {
                self sethintstring( &"ZOMBIE_WEAPON_LOCKER_DENY" );
                wait 3;
                self triggerweaponslockerisvalidweaponpromptupdate( player, player getcurrentweapon() );
                continue;
            }

            maxweapons = get_player_weapon_limit( player );

            if ( isdefined( primaries ) && primaries.size >= maxweapons || weapontogive == curweapon )
            {
                curweapon = player maps\mp\zombies\_zm_weapons::switch_from_alt_weapon( curweapon );

                if ( !triggerweaponslockerisvalidweapon( curweapon ) )
                {
                    self sethintstring( &"ZOMBIE_WEAPON_LOCKER_DENY" );
                    wait 3;
                    self triggerweaponslockerisvalidweaponpromptupdate( player, player getcurrentweapon() );
                    continue;
                }

                curweapondata = player maps\mp\zombies\_zm_weapons::get_player_weapondata( player );
                player takeweapon( curweapondata["name"] );
                player maps\mp\zombies\_zm_weapons::weapondata_give( weapondata );
                player wl_clear_stored_weapondata();
                player wl_set_stored_weapondata( curweapondata );
                player switchtoweapon( weapondata["name"] );
                self triggerweaponslockerisvalidweaponpromptupdate( player, player getcurrentweapon() );
            }
            else
            {
                player thread maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "wall_withdrawl" );
                player wl_clear_stored_weapondata();
                player maps\mp\zombies\_zm_weapons::weapondata_give( weapondata );
                player switchtoweapon( weapondata["name"] );
                self triggerweaponslockerisvalidweaponpromptupdate( player, player getcurrentweapon() );
            }

            level notify( "weapon_locker_grab" );
            player playsoundtoplayer( "evt_fridge_locker_open", player );
        }

        wait 0.5;
    }
}

triggerweaponslockerweaponchangethink( trigger )
{
    self endon( "disconnect" );
    self endon( "death" );
    trigger endon( "kill_trigger" );

    while ( true )
    {
        self waittill( "weapon_change", newweapon );

        trigger triggerweaponslockerisvalidweaponpromptupdate( self, newweapon );
    }
}

add_weapon_locker_mapping( fromweapon, toweapon )
{
    if ( !isdefined( level.remap_weapon_locker_weapons ) )
        level.remap_weapon_locker_weapons = [];

    level.remap_weapon_locker_weapons[fromweapon] = toweapon;
}

remap_weapon( weapondata, maptable )
{
    name = get_base_name( weapondata["name"] );
    att = get_attachment_name( weapondata["name"] );

    if ( isdefined( maptable[name] ) )
    {
        weapondata["name"] = maptable[name];
        name = weapondata["name"];

        if ( is_weapon_upgraded( name ) )
        {
            if ( isdefined( att ) && weapon_supports_attachments( name ) )
            {
                base = get_base_weapon_name( name, 1 );

                if ( !weapon_supports_this_attachment( base, att ) )
                    att = random_attachment( base );

                weapondata["name"] = weapondata["name"] + "+" + att;
            }
            else if ( weapon_supports_default_attachment( name ) )
            {
                att = default_attachment( name );
                weapondata["name"] = weapondata["name"] + "+" + att;
            }
        }
    }
    else
        return weapondata;

    name = weapondata["name"];
    dw_name = weapondualwieldweaponname( name );
    alt_name = weaponaltweaponname( name );

    if ( name != "none" )
    {
        weapondata["clip"] = int( min( weapondata["clip"], weaponclipsize( name ) ) );
        weapondata["stock"] = int( min( weapondata["stock"], weaponmaxammo( name ) ) );
    }

    if ( dw_name != "none" )
        weapondata["lh_clip"] = int( min( weapondata["lh_clip"], weaponclipsize( dw_name ) ) );

    if ( alt_name != "none" )
    {
        weapondata["alt_clip"] = int( min( weapondata["alt_clip"], weaponclipsize( alt_name ) ) );
        weapondata["alt_stock"] = int( min( weapondata["alt_stock"], weaponmaxammo( alt_name ) ) );
    }

    weapondata["dw_name"] = dw_name;
    weapondata["alt_name"] = alt_name;
    return weapondata;
}
