// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_perks;

init()
{
    if ( !isdefined( level.script ) )
        level.script = tolower( getdvar( "mapname" ) );

    precacheshader( "overlay_low_health" );
    level.global_damage_func_ads = ::empty_kill_func;
    level.global_damage_func = ::empty_kill_func;
    level.difficultytype[0] = "easy";
    level.difficultytype[1] = "normal";
    level.difficultytype[2] = "hardened";
    level.difficultytype[3] = "veteran";
    level.difficultystring["easy"] = &"GAMESKILL_EASY";
    level.difficultystring["normal"] = &"GAMESKILL_NORMAL";
    level.difficultystring["hardened"] = &"GAMESKILL_HARDENED";
    level.difficultystring["veteran"] = &"GAMESKILL_VETERAN";
/#
    thread playerhealthdebug();
#/
    level.gameskill = 1;

    switch ( level.gameskill )
    {
        case 0:
            setdvar( "currentDifficulty", "easy" );
            break;
        case 1:
            setdvar( "currentDifficulty", "normal" );
            break;
        case 2:
            setdvar( "currentDifficulty", "hardened" );
            break;
        case 3:
            setdvar( "currentDifficulty", "veteran" );
            break;
    }

    logstring( "difficulty: " + level.gameskill );
    level.player_deathinvulnerabletime = 1700;
    level.longregentime = 5000;
    level.healthoverlaycutoff = 0.2;
    level.invultime_preshield = 0.35;
    level.invultime_onshield = 0.5;
    level.invultime_postshield = 0.3;
    level.playerhealth_regularregendelay = 2400;
    level.worthydamageratio = 0.1;
    setdvar( "player_meleeDamageMultiplier", 0.4 );
    onplayerconnect_callback( ::onplayerconnect );
}

onplayerconnect()
{
    self thread onplayerspawned();
}

onplayerspawned()
{
    for (;;)
    {
        self waittill( "spawned_player" );

        self maps\mp\zombies\_zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );

        if ( level.createfx_enabled )
            continue;

        self notify( "noHealthOverlay" );
        self thread playerhealthregen();
    }
}

playerhurtcheck()
{
    self endon( "noHealthOverlay" );
    self.hurtagain = 0;

    for (;;)
    {
        self waittill( "damage", amount, attacker, dir, point, mod );

        if ( isdefined( attacker ) && isplayer( attacker ) && attacker.team == self.team )
            continue;

        self.hurtagain = 1;
        self.damagepoint = point;
        self.damageattacker = attacker;
    }
}

playerhealthregen()
{
    self notify( "playerHealthRegen" );
    self endon( "playerHealthRegen" );
    self endon( "death" );
    self endon( "disconnect" );

    if ( !isdefined( self.flag ) )
    {
        self.flag = [];
        self.flags_lock = [];
    }

    if ( !isdefined( self.flag["player_has_red_flashing_overlay"] ) )
    {
        self player_flag_init( "player_has_red_flashing_overlay" );
        self player_flag_init( "player_is_invulnerable" );
    }

    self player_flag_clear( "player_has_red_flashing_overlay" );
    self player_flag_clear( "player_is_invulnerable" );
    self thread healthoverlay();
    oldratio = 1;
    health_add = 0;
    regenrate = 0.1;
    veryhurt = 0;
    playerjustgotredflashing = 0;
    invultime = 0;
    hurttime = 0;
    newhealth = 0;
    lastinvulratio = 1;
    self thread playerhurtcheck();

    if ( !isdefined( self.veryhurt ) )
        self.veryhurt = 0;

    self.bolthit = 0;

    if ( getdvar( _hash_FCECE67E ) == "" )
        setdvar( "scr_playerInvulTimeScale", 1.0 );

    playerinvultimescale = getdvarfloat( _hash_FCECE67E );

    for (;;)
    {
        wait 0.05;
        waittillframeend;

        if ( self.health == self.maxhealth )
        {
            if ( self player_flag( "player_has_red_flashing_overlay" ) )
                player_flag_clear( "player_has_red_flashing_overlay" );

            lastinvulratio = 1;
            playerjustgotredflashing = 0;
            veryhurt = 0;
            continue;
        }

        if ( self.health <= 0 )
        {
/#
            showhitlog();
#/
            return;
        }

        wasveryhurt = veryhurt;
        health_ratio = self.health / self.maxhealth;

        if ( health_ratio <= level.healthoverlaycutoff )
        {
            veryhurt = 1;

            if ( !wasveryhurt )
            {
                hurttime = gettime();
                self startfadingblur( 3.6, 2 );
                self player_flag_set( "player_has_red_flashing_overlay" );
                playerjustgotredflashing = 1;
            }
        }

        if ( self.hurtagain )
        {
            hurttime = gettime();
            self.hurtagain = 0;
        }

        if ( health_ratio >= oldratio )
        {
            if ( gettime() - hurttime < level.playerhealth_regularregendelay )
                continue;

            if ( veryhurt )
            {
                self.veryhurt = 1;
                newhealth = health_ratio;

                if ( gettime() > hurttime + level.longregentime )
                    newhealth += regenrate;
            }
            else
            {
                newhealth = 1;
                self.veryhurt = 0;
            }

            if ( newhealth > 1.0 )
                newhealth = 1.0;

            if ( newhealth <= 0 )
                return;
/#
            if ( newhealth > health_ratio )
                logregen( newhealth );
#/
            self setnormalhealth( newhealth );
            oldratio = self.health / self.maxhealth;
            continue;
        }

        invulworthyhealthdrop = lastinvulratio - health_ratio > level.worthydamageratio;

        if ( self.health <= 1 )
        {
            self setnormalhealth( 2 / self.maxhealth );
            invulworthyhealthdrop = 1;
/#
            if ( !isdefined( level.player_deathinvulnerabletimeout ) )
                level.player_deathinvulnerabletimeout = 0;

            if ( level.player_deathinvulnerabletimeout < gettime() )
                level.player_deathinvulnerabletimeout = gettime() + getdvarint( _hash_4E44E32D );
#/
        }

        oldratio = self.health / self.maxhealth;
        level notify( "hit_again" );
        health_add = 0;
        hurttime = gettime();
        self startfadingblur( 3, 0.8 );

        if ( !invulworthyhealthdrop || playerinvultimescale <= 0.0 )
        {
/#
            loghit( self.health, 0 );
#/
            continue;
        }

        if ( self player_flag( "player_is_invulnerable" ) )
            continue;

        self player_flag_set( "player_is_invulnerable" );
        level notify( "player_becoming_invulnerable" );

        if ( playerjustgotredflashing )
        {
            invultime = level.invultime_onshield;
            playerjustgotredflashing = 0;
        }
        else if ( veryhurt )
            invultime = level.invultime_postshield;
        else
            invultime = level.invultime_preshield;

        invultime *= playerinvultimescale;
/#
        loghit( self.health, invultime );
#/
        lastinvulratio = self.health / self.maxhealth;
        self thread playerinvul( invultime );
    }
}

playerinvul( timer )
{
    self endon( "death" );
    self endon( "disconnect" );

    if ( timer > 0 )
    {
/#
        level.playerinvultimeend = gettime() + timer * 1000;
#/
        wait( timer );
    }

    self player_flag_clear( "player_is_invulnerable" );
}

healthoverlay()
{
    self endon( "disconnect" );
    self endon( "noHealthOverlay" );

    if ( !isdefined( self._health_overlay ) )
    {
        self._health_overlay = newclienthudelem( self );
        self._health_overlay.x = 0;
        self._health_overlay.y = 0;
        self._health_overlay setshader( "overlay_low_health", 640, 480 );
        self._health_overlay.alignx = "left";
        self._health_overlay.aligny = "top";
        self._health_overlay.horzalign = "fullscreen";
        self._health_overlay.vertalign = "fullscreen";
        self._health_overlay.alpha = 0;
    }

    overlay = self._health_overlay;
    self thread healthoverlay_remove( overlay );
    self thread watchhideredflashingoverlay( overlay );
    pulsetime = 0.8;

    for (;;)
    {
        if ( overlay.alpha > 0 )
            overlay fadeovertime( 0.5 );

        overlay.alpha = 0;
        self player_flag_wait( "player_has_red_flashing_overlay" );
        self redflashingoverlay( overlay );
    }
}

fadefunc( overlay, severity, mult, hud_scaleonly )
{
    pulsetime = 0.8;
    scalemin = 0.5;
    fadeintime = pulsetime * 0.1;
    stayfulltime = pulsetime * ( 0.1 + severity * 0.2 );
    fadeouthalftime = pulsetime * ( 0.1 + severity * 0.1 );
    fadeoutfulltime = pulsetime * 0.3;
    remainingtime = pulsetime - fadeintime - stayfulltime - fadeouthalftime - fadeoutfulltime;
    assert( remainingtime >= -0.001 );

    if ( remainingtime < 0 )
        remainingtime = 0;

    halfalpha = 0.8 + severity * 0.1;
    leastalpha = 0.5 + severity * 0.3;
    overlay fadeovertime( fadeintime );
    overlay.alpha = mult * 1.0;
    wait( fadeintime + stayfulltime );
    overlay fadeovertime( fadeouthalftime );
    overlay.alpha = mult * halfalpha;
    wait( fadeouthalftime );
    overlay fadeovertime( fadeoutfulltime );
    overlay.alpha = mult * leastalpha;
    wait( fadeoutfulltime );
    wait( remainingtime );
}

watchhideredflashingoverlay( overlay )
{
    self endon( "death_or_disconnect" );

    while ( isdefined( overlay ) )
    {
        self waittill( "clear_red_flashing_overlay" );

        self player_flag_clear( "player_has_red_flashing_overlay" );
        overlay fadeovertime( 0.05 );
        overlay.alpha = 0;
        setclientsysstate( "levelNotify", "rfo3", self );
        self notify( "hit_again" );
    }
}

redflashingoverlay( overlay )
{
    self endon( "hit_again" );
    self endon( "damage" );
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "clear_red_flashing_overlay" );
    self.stopflashingbadlytime = gettime() + level.longregentime;

    if ( !( isdefined( self.is_in_process_of_zombify ) && self.is_in_process_of_zombify ) && !( isdefined( self.is_zombie ) && self.is_zombie ) )
    {
        fadefunc( overlay, 1, 1, 0 );

        while ( gettime() < self.stopflashingbadlytime && isalive( self ) && ( !( isdefined( self.is_in_process_of_zombify ) && self.is_in_process_of_zombify ) && !( isdefined( self.is_zombie ) && self.is_zombie ) ) )
            fadefunc( overlay, 0.9, 1, 0 );

        if ( !( isdefined( self.is_in_process_of_zombify ) && self.is_in_process_of_zombify ) && !( isdefined( self.is_zombie ) && self.is_zombie ) )
        {
            if ( isalive( self ) )
                fadefunc( overlay, 0.65, 0.8, 0 );

            fadefunc( overlay, 0, 0.6, 1 );
        }
    }

    overlay fadeovertime( 0.5 );
    overlay.alpha = 0;
    self player_flag_clear( "player_has_red_flashing_overlay" );
    setclientsysstate( "levelNotify", "rfo3", self );
    wait 0.5;
    self notify( "hit_again" );
}

healthoverlay_remove( overlay )
{
    self endon( "disconnect" );
    self waittill_any( "noHealthOverlay", "death" );
    overlay fadeovertime( 3.5 );
    overlay.alpha = 0;
}

empty_kill_func( type, loc, point, attacker, amount )
{

}

loghit( newhealth, invultime )
{
/#

#/
}

logregen( newhealth )
{
/#

#/
}

showhitlog()
{
/#

#/
}

playerhealthdebug()
{
/#
    if ( getdvar( "scr_health_debug" ) == "" )
        setdvar( "scr_health_debug", "0" );

    waittillframeend;

    while ( true )
    {
        while ( true )
        {
            if ( getdvar( "scr_health_debug" ) != "0" )
                break;

            wait 0.5;
        }

        thread printhealthdebug();

        while ( true )
        {
            if ( getdvar( "scr_health_debug" ) == "0" )
                break;

            wait 0.5;
        }

        level notify( "stop_printing_grenade_timers" );
        destroyhealthdebug();
    }
#/
}

printhealthdebug()
{
/#
    level notify( "stop_printing_health_bars" );
    level endon( "stop_printing_health_bars" );
    x = 40;
    y = 40;
    level.healthbarhudelems = [];
    level.healthbarkeys[0] = "Health";
    level.healthbarkeys[1] = "No Hit Time";
    level.healthbarkeys[2] = "No Die Time";

    if ( !isdefined( level.playerinvultimeend ) )
        level.playerinvultimeend = 0;

    if ( !isdefined( level.player_deathinvulnerabletimeout ) )
        level.player_deathinvulnerabletimeout = 0;

    for ( i = 0; i < level.healthbarkeys.size; i++ )
    {
        key = level.healthbarkeys[i];
        textelem = newhudelem();
        textelem.x = x;
        textelem.y = y;
        textelem.alignx = "left";
        textelem.aligny = "top";
        textelem.horzalign = "fullscreen";
        textelem.vertalign = "fullscreen";
        textelem settext( key );
        bgbar = newhudelem();
        bgbar.x = x + 79;
        bgbar.y = y + 1;
        bgbar.alignx = "left";
        bgbar.aligny = "top";
        bgbar.horzalign = "fullscreen";
        bgbar.vertalign = "fullscreen";
        bgbar.maxwidth = 3;
        bgbar setshader( "white", bgbar.maxwidth, 10 );
        bgbar.color = vectorscale( ( 1, 1, 1 ), 0.5 );
        bar = newhudelem();
        bar.x = x + 80;
        bar.y = y + 2;
        bar.alignx = "left";
        bar.aligny = "top";
        bar.horzalign = "fullscreen";
        bar.vertalign = "fullscreen";
        bar setshader( "black", 1, 8 );
        textelem.bar = bar;
        textelem.bgbar = bgbar;
        textelem.key = key;
        y += 10;
        level.healthbarhudelems[key] = textelem;
    }

    flag_wait( "start_zombie_round_logic" );

    while ( true )
    {
        wait 0.05;
        players = get_players();

        for ( i = 0; i < level.healthbarkeys.size && players.size > 0; i++ )
        {
            key = level.healthbarkeys[i];
            player = players[0];
            width = 0;

            if ( i == 0 )
                width = player.health / player.maxhealth * 300;
            else if ( i == 1 )
                width = ( level.playerinvultimeend - gettime() ) / 1000 * 40;
            else if ( i == 2 )
                width = ( level.player_deathinvulnerabletimeout - gettime() ) / 1000 * 40;

            width = int( max( width, 1 ) );
            width = int( min( width, 300 ) );
            bar = level.healthbarhudelems[key].bar;
            bar setshader( "black", width, 8 );
            bgbar = level.healthbarhudelems[key].bgbar;

            if ( width + 2 > bgbar.maxwidth )
            {
                bgbar.maxwidth = width + 2;
                bgbar setshader( "white", bgbar.maxwidth, 10 );
                bgbar.color = vectorscale( ( 1, 1, 1 ), 0.5 );
            }
        }
    }
#/
}

destroyhealthdebug()
{
/#
    if ( !isdefined( level.healthbarhudelems ) )
        return;

    for ( i = 0; i < level.healthbarkeys.size; i++ )
    {
        level.healthbarhudelems[level.healthbarkeys[i]].bgbar destroy();
        level.healthbarhudelems[level.healthbarkeys[i]].bar destroy();
        level.healthbarhudelems[level.healthbarkeys[i]] destroy();
    }
#/
}
