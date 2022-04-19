// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\killstreaks\_killstreaks;

isgrenadelauncherweapon( weapon )
{
    if ( getsubstr( weapon, 0, 3 ) == "gl_" )
        return true;

    switch ( weapon )
    {
        case "xm25_mp":
        case "china_lake_mp":
            return true;
        default:
            return false;
    }
}

isdumbrocketlauncherweapon( weapon )
{
    switch ( weapon )
    {
        case "rpg_mp":
        case "m220_tow_mp":
            return true;
        default:
            return false;
    }
}

isguidedrocketlauncherweapon( weapon )
{
    switch ( weapon )
    {
        case "smaw_mp":
        case "m72_law_mp":
        case "m202_flash_mp":
        case "javelin_mp":
        case "fhj18_mp":
            return true;
        default:
            return false;
    }
}

isrocketlauncherweapon( weapon )
{
    if ( isdumbrocketlauncherweapon( weapon ) )
        return true;

    if ( isguidedrocketlauncherweapon( weapon ) )
        return true;

    return false;
}

islauncherweapon( weapon )
{
    if ( isrocketlauncherweapon( weapon ) )
        return true;

    if ( isgrenadelauncherweapon( weapon ) )
        return true;

    return false;
}

ishackweapon( weapon )
{
    if ( maps\mp\killstreaks\_killstreaks::iskillstreakweapon( weapon ) )
        return true;

    if ( weapon == "briefcase_bomb_mp" )
        return true;

    return false;
}

ispistol( weapon )
{
    return isdefined( level.side_arm_array[weapon] );
}

isflashorstunweapon( weapon )
{
    if ( isdefined( weapon ) )
    {
        switch ( weapon )
        {
            case "proximity_grenade_mp":
            case "proximity_grenade_aoe_mp":
            case "flash_grenade_mp":
            case "concussion_grenade_mp":
                return true;
        }
    }

    return false;
}

isflashorstundamage( weapon, meansofdeath )
{
    return isflashorstunweapon( weapon ) && ( meansofdeath == "MOD_GRENADE_SPLASH" || meansofdeath == "MOD_GAS" );
}
