// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zm_transit_utility;
#include maps\mp\zm_transit_bus;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_powerups;

main()
{
    level.numroundssincelastambushround = 0;
    level.numbusstopssincelastambushround = 0;
    level.numambushrounds = 0;
    level.ambushpercentageperstop = 10;
    level.ambushpercentageperround = 25;
    flag_init( "ambush_round", 0 );
    flag_init( "ambush_safe_area_active", 0 );
    initambusheffects();
    thread ambushroundkeeper();
/#
    adddebugcommand( "devgui_cmd \"Zombies:1/Bus:14/Ambush Round:6/Always:1\" \"zombie_devgui ambush_round always\"\n" );
    adddebugcommand( "devgui_cmd \"Zombies:1/Bus:14/Ambush Round:6/Never:2\" \"zombie_devgui ambush_round never\"\n" );
#/
}

initambusheffects()
{
    level._effect["ambush_bus_fire"] = loadfx( "env/fire/fx_fire_md" );
}

shouldstartambushround()
{
/#
    if ( level.ambushpercentageperstop == 100 )
        return true;

    if ( getdvarint( _hash_FA81816F ) == 2 )
        return false;
#/
    if ( level.numbusstopssincelastambushround < 2 )
    {

    }

    randint = randomintrange( 0, 100 );
    percentchance = level.numbusstopssincelastambushround * level.ambushpercentageperstop;

    if ( randint < percentchance )
    {

    }

    percentchance = level.numroundssincelastambushround * level.ambushpercentageperround;

    if ( randint < percentchance )
    {

    }

    if ( maps\mp\zm_transit_bus::busgasempty() )
        return true;

    return false;
}

isambushroundactive()
{
    return flag_exists( "ambush_round" ) && flag( "ambush_round" );
}

is_ambush_round_spawning_active()
{
    return flag_exists( "ambush_safe_area_active" ) && flag( "ambush_safe_area_active" );
}

ambushstartround()
{
    flag_set( "ambush_round" );
    ambushroundthink();
}

ambushendround()
{
    level.the_bus.issafe = 1;
    maps\mp\zm_transit_bus::busgasadd( 60 );
    level.numbusstopssincelastambushround = 0;
    level.numroundssincelastambushround = 0;
    flag_clear( "ambush_round" );
}

cancelambushround()
{
    flag_clear( "ambush_round" );
    flag_clear( "ambush_safe_area_active" );
    maps\mp\zm_transit_utility::try_resume_zombie_spawning();
    bbprint( "zombie_events", "category %s type %s round %d", "DOG", "stop", level.round_number );
    level.the_bus notify( "ambush_round_fail_safe" );
}

ambushroundspawning()
{
    level.numambushrounds++;
    wait 6;
    level.the_bus.issafe = 0;
}

limitedambushspawn()
{
    if ( level.numambushrounds < 3 )
        dogcount = level.dog_targets.size * 6;
    else
        dogcount = level.dog_targets.size * 8;

    setupdogspawnlocs();
    level thread ambushroundspawnfailsafe( 20 );

    while ( get_current_zombie_count() > 0 )
        wait 1.0;

    level notify( "end_ambushWaitFunction" );
}

ambushroundthink()
{
    module = maps\mp\zombies\_zm_game_module::get_game_module( level.game_module_nml_index );

    if ( isdefined( module.hub_start_func ) )
    {
        level thread [[ module.hub_start_func ]]( "nml" );
        level notify( "game_mode_started" );
    }

    level thread ambushroundspawning();
    ambushwaitfunction();
    ambushendround();
}

ambushwaitfunction()
{

}

ambushpointfailsafe()
{
    level.the_bus endon( "ambush_point" );

    level.the_bus waittill( "reached_stop_point" );

    cancelambushround();
}

ambushroundspawnfailsafe( timer )
{
    ambushroundtimelimit = timer;

    for ( currentambushtime = 0; currentambushtime < ambushroundtimelimit; currentambushtime++ )
    {
        if ( !flag( "ambush_round" ) )
            return;

        wait 1.0;
    }

    level notify( "end_ambushWaitFunction" );
    wait 5;
    dogs = getaispeciesarray( "all", "zombie_dog" );

    for ( i = 0; i < dogs.size; i++ )
    {
        if ( isdefined( dogs[i].marked_for_death ) && dogs[i].marked_for_death )
            continue;

        if ( is_magic_bullet_shield_enabled( dogs[i] ) )
            continue;

        dogs[i] dodamage( dogs[i].health + 666, dogs[i].origin );
    }
}

ambushdoghealthincrease()
{
    switch ( level.numambushrounds )
    {
        case 1:
            level.dog_health = 400;
            break;
        case 2:
            level.dog_health = 900;
            break;
        case 3:
            level.dog_health = 1300;
            break;
        case 4:
            level.dog_health = 1600;
            break;
        default:
            level.dog_health = 1600;
            break;
    }
}

ambushroundaftermath()
{
    power_up_origin = level.the_bus gettagorigin( "tag_body" );

    if ( isdefined( power_up_origin ) )
        level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop( "full_ammo", power_up_origin );
}

ambushroundeffects()
{
    wait 2;
    level thread ambushlightningeffect( "tag_body" );
    wait 0.5;
    level thread ambushlightningeffect( "tag_wheel_back_left" );
    wait 0.5;
    level thread ambushlightningeffect( "tag_wheel_back_right" );
    wait 0.5;
    level thread ambushlightningeffect( "tag_wheel_front_left" );
    wait 0.5;
    level thread ambushlightningeffect( "tag_wheel_front_right" );
    wait 1.5;
    fxent0 = spawnandlinkfxtotag( level._effect["ambush_bus_fire"], level.the_bus, "tag_body" );
    fxent1 = spawnandlinkfxtotag( level._effect["ambush_bus_fire"], level.the_bus, "tag_wheel_back_left" );
    fxent2 = spawnandlinkfxtotag( level._effect["ambush_bus_fire"], level.the_bus, "tag_wheel_back_right" );
    fxent3 = spawnandlinkfxtotag( level._effect["ambush_bus_fire"], level.the_bus, "tag_wheel_front_left" );
    fxent4 = spawnandlinkfxtotag( level._effect["ambush_bus_fire"], level.the_bus, "tag_wheel_front_right" );

    level waittill( "end_ambushWaitFunction" );

    fxent0 delete();
    fxent1 delete();
    fxent2 delete();
    fxent3 delete();
    fxent4 delete();
}

ambushlightningeffect( tag )
{
    fxentlighting = spawnandlinkfxtotag( level._effect["lightning_dog_spawn"], level.the_bus, tag );
    wait 5;
    fxentlighting delete();
}

setupdogspawnlocs()
{
    level.enemy_dog_locations = [];
    currentzone = undefined;
    ambush_zones = getentarray( "ambush_volume", "script_noteworthy" );

    for ( i = 0; i < ambush_zones.size; i++ )
    {
        touching = 0;

        for ( b = 0; b < level.the_bus.bounds_origins.size && !touching; b++ )
        {
            bounds = level.the_bus.bounds_origins[b];
            touching = bounds istouching( ambush_zones[i] );
        }

        if ( touching )
        {
            currentzone = ambush_zones[i];
            break;
        }
    }

    assert( isdefined( currentzone ), "Bus needs to be in an ambush zone for an ambush round: " + level.the_bus.origin );
    level.enemy_dog_locations = getstructarray( currentzone.target, "targetname" );
}

ambushroundkeeper()
{
    while ( true )
    {
        level waittill( "between_round_over" );

        level.numroundssincelastambushround++;
    }
}
