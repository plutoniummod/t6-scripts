// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_globallogic_ui;

initializeactionarray()
{
    level.gametypeactions = [];
    level.gametypeactions["GiveAmmo"] = ::dogiveammo;
    level.gametypeactions["RemoveAmmo"] = ::doremoveammo;
    level.gametypeactions["PlaySound"] = ::doplaysound;
    level.gametypeactions["EnableUAV"] = ::doenableuav;
    level.gametypeactions["GiveScore"] = ::dogivescore;
    level.gametypeactions["RemoveScore"] = ::doremovescore;
    level.gametypeactions["SetHeader"] = ::dosetheader;
    level.gametypeactions["SetSubHeader"] = ::dosetsubheader;
    level.gametypeactions["DisplayMessage"] = ::dodisplaymessage;
    level.gametypeactions["GiveHealth"] = ::dogivehealth;
    level.gametypeactions["RemoveHealth"] = ::doremovehealth;
    level.gametypeactions["SetHealthRegen"] = ::dosethealthregen;
    level.gametypeactions["ChangeClass"] = ::dochangeclass;
    level.gametypeactions["ChangeTeam"] = ::dochangeteam;
    level.gametypeactions["GivePerk"] = ::dogiveperk;
    level.gametypeactions["RemovePerk"] = ::doremoveperk;
    level.gametypeactions["GiveInvuln"] = ::dogiveinvuln;
    level.gametypeactions["RemoveInvuln"] = ::doremoveinvuln;
    level.gametypeactions["SetDamageModifier"] = ::dosetdamagemodifier;
    level.gametypeactions["GiveKillstreak"] = ::dogivekillstreak;
    level.gametypeactions["RemoveKillstreak"] = ::doremovekillstreak;
    level.gametypeactions["GiveLives"] = ::dogivelives;
    level.gametypeactions["RemoveLives"] = ::doremovelives;
    level.gametypeactions["ScaleMoveSpeed"] = ::doscalemovespeed;
    level.gametypeactions["ShowOnRadar"] = ::doshowonradar;
    level.conditionals = [];
    level.conditionals["Equals"] = ::equals;
    level.conditionals["=="] = ::equals;
    level.conditionals["!="] = ::notequals;
    level.conditionals["<"] = ::lessthan;
    level.conditionals["<="] = ::lessthanequals;
    level.conditionals[">"] = ::greaterthan;
    level.conditionals[">="] = ::greaterthanequals;
    level.conditionals["InPlace"] = ::inplace;
    level.conditionallefthandside = [];
    level.conditionallefthandside["PlayersLeft"] = ::playersleft;
    level.conditionallefthandside["RoundsPlayed"] = ::roundsplayed;
    level.conditionallefthandside["HitBy"] = ::hitby;
    level.conditionallefthandside["PlayersClass"] = ::playersclass;
    level.conditionallefthandside["VictimsClass"] = ::playersclass;
    level.conditionallefthandside["AttackersClass"] = ::attackersclass;
    level.conditionallefthandside["PlayersPlace"] = ::playersplace;
    level.conditionallefthandside["VictimsPlace"] = ::playersplace;
    level.conditionallefthandside["AttackersPlace"] = ::attackersplace;
    level.targets = [];
    level.targets["Everyone"] = ::gettargeteveryone;
    level.targets["PlayersLeft"] = ::gettargetplayersleft;
    level.targets["PlayersEliminated"] = ::gettargetplayerseliminated;
    level.targets["PlayersTeam"] = ::gettargetplayersteam;
    level.targets["VictimsTeam"] = ::gettargetplayersteam;
    level.targets["OtherTeam"] = ::gettargetotherteam;
    level.targets["AttackersTeam"] = ::gettargetotherteam;
    level.targets["PlayersLeftOnPlayersTeam"] = ::gettargetplayersleftonplayersteam;
    level.targets["PlayersLeftOnOtherTeam"] = ::gettargetplayersleftonotherteam;
    level.targets["PlayersLeftOnVictimsTeam"] = ::gettargetplayersleftonplayersteam;
    level.targets["PlayersLeftOnAttackersTeam"] = ::gettargetplayersleftonotherteam;
    level.targets["PlayersEliminatedOnPlayersTeam"] = ::gettargetplayerseliminatedonplayersteam;
    level.targets["PlayersEliminatedOnOtherTeam"] = ::gettargetplayerseliminatedonotherteam;
    level.targets["PlayersEliminatedOnVictimsTeam"] = ::gettargetplayerseliminatedonplayersteam;
    level.targets["PlayersEliminatedOnAttackersTeam"] = ::gettargetplayerseliminatedonotherteam;
    level.targets["AssistingPlayers"] = ::getassistingplayers;
}

equals( param1, param2 )
{
    return param1 == param2;
}

notequals( param1, param2 )
{
    return param1 != param2;
}

lessthan( param1, param2 )
{
    return param1 < param2;
}

lessthanequals( param1, param2 )
{
    return param1 <= param2;
}

greaterthan( param1, param2 )
{
    return param1 > param2;
}

greaterthanequals( param1, param2 )
{
    return param1 >= param2;
}

inplace( param1, param2 )
{
    if ( param1 == param2 )
        return true;

    if ( param2 == "top3" && param1 == "first" )
        return true;

    return false;
}

playersleft( rule )
{
    return 0;
}

roundsplayed( rule )
{
    return game["roundsplayed"] + 1;
}

hitby( rule )
{
    meansofdeath = rule.target["MeansOfDeath"];
    weapon = rule.target["Weapon"];

    if ( !isdefined( meansofdeath ) || !isdefined( weapon ) )
        return undefined;

    switch ( weapon )
    {
        case "knife_ballistic_mp":
            return "knife";
    }

    switch ( meansofdeath )
    {
        case "MOD_RIFLE_BULLET":
        case "MOD_PISTOL_BULLET":
            return "bullet";
        case "MOD_MELEE":
        case "MOD_BAYONET":
            return "knife";
        case "MOD_HEAD_SHOT":
            return "headshot";
        case "MOD_PROJECTILE_SPLASH":
        case "MOD_PROJECTILE":
        case "MOD_GRENADE_SPLASH":
        case "MOD_GRENADE":
        case "MOD_EXPLOSIVE":
            return "explosive";
    }

    return undefined;
}

getplayersclass( player )
{
    return player.pers["class"];
}

playersclass( rule )
{
    player = rule.target["Player"];
    return getplayersclass( player );
}

attackersclass( rule )
{
    player = rule.target["Attacker"];
    return getplayersclass( player );
}

getplayersplace( player )
{
    maps\mp\gametypes_zm\_globallogic::updateplacement();

    if ( !isdefined( level.placement["all"] ) )
        return;

    for ( place = 0; place < level.placement["all"].size; place++ )
    {
        if ( level.placement["all"][place] == player )
            break;
    }

    place++;

    if ( place == 1 )
        return "first";
    else if ( place <= 3 )
        return "top3";
    else if ( place == level.placement["all"].size )
        return "last";

    return "middle";
}

playersplace( rule )
{
    player = rule.target["Player"];
    return getplayersplace( player );
}

attackersplace( rule )
{
    player = rule.target["Attacker"];
    return getplayersplace( player );
}

gettargeteveryone( rule )
{
    return level.players;
}

gettargetplayersleft( rule )
{
    return 0;
}

gettargetplayerseliminated( rule )
{
    return 0;
}

gettargetplayersteam( rule )
{
    player = rule.target["Player"];

    if ( !isdefined( player ) )
        return [];

    return getplayersonteam( level.players, player.pers["team"] );
}

gettargetotherteam( rule )
{
    player = rule.target["Player"];

    if ( !isdefined( player ) )
        return [];

    return getplayersonteam( level.players, getotherteam( player.pers["team"] ) );
}

gettargetplayersleftonplayersteam( rule )
{
    return [];
}

gettargetplayersleftonotherteam( rule )
{
    return [];
}

gettargetplayerseliminatedonplayersteam( rule )
{
    return [];
}

gettargetplayerseliminatedonotherteam( rule )
{
    return [];
}

getassistingplayers( rule )
{
    assisters = [];
    attacker = rule.target["Attacker"];

    if ( !isdefined( rule.target["Assisters"] ) || !isdefined( attacker ) )
        return assisters;

    for ( j = 0; j < rule.target["Assisters"].size; j++ )
    {
        player = rule.target["Assisters"][j];

        if ( !isdefined( player ) )
            continue;

        if ( player == attacker )
            continue;

        assisters[assisters.size] = player;
    }

    return assisters;
}

executegametypeeventrule( rule )
{
    if ( !aregametypeeventruleconditionalsmet( rule ) )
        return;

    if ( !isdefined( level.gametypeactions[rule.action] ) )
    {
/#
        error( "GAMETYPE VARIANTS - unknown action:  " + rule.action + "!" );
#/
        return;
    }

    thread internalexecuterule( rule );
}

internalexecuterule( rule )
{

}

aregametypeeventruleconditionalsmet( rule )
{
    if ( !isdefined( rule.conditionals ) || rule.conditionals.size == 0 )
        return 1;

    combinedresult = 1;

    if ( rule.conditionaleval == "OR" )
        combinedresult = 0;

    for ( i = 0; i < rule.conditionals.size; i++ )
    {
        conditionalresult = evaluategametypeeventruleconditional( rule, rule.conditionals[i] );

        switch ( rule.conditionaleval )
        {
            case "AND":
                combinedresult = combinedresult && conditionalresult;
                break;
            case "OR":
                combinedresult = combinedresult || conditionalresult;
                break;
        }

        if ( rule.conditionaleval == "AND" && !combinedresult )
            break;

        if ( rule.conditionaleval == "OR" && combinedresult )
            break;
    }

    return combinedresult;
}

evaluategametypeeventruleconditional( rule, conditional )
{
    if ( !isdefined( conditional.lhs ) || !isdefined( conditional.operand ) || !isdefined( conditional.rhs ) )
        return 0;

    if ( !isdefined( level.conditionallefthandside[conditional.lhs] ) )
        return 0;

    lhsvalue = [[ level.conditionallefthandside[conditional.lhs] ]]( rule );

    if ( !isdefined( lhsvalue ) || !isdefined( level.conditionals[conditional.operand] ) )
        return 0;

    return [[ level.conditionals[conditional.operand] ]]( lhsvalue, conditional.rhs );
}

getplayersonteam( players, team )
{
    playersonteam = [];

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];

        if ( player.pers["team"] == team )
            playersonteam[playersonteam.size] = player;
    }

    return playersonteam;
}

gettargetsforgametypeeventrule( rule )
{
    targets = [];

    if ( !isdefined( rule.targetname ) )
        return targets;

    if ( isdefined( rule.target[rule.targetname] ) )
        targets[targets.size] = rule.target[rule.targetname];
    else if ( isdefined( level.targets[rule.targetname] ) )
        targets = [[ level.targets[rule.targetname] ]]( rule );

    return targets;
}

doesrulehavevalidparam( rule )
{
    return isdefined( rule.params ) && isarray( rule.params ) && rule.params.size > 0;
}

sortplayersbylivesdescending( players )
{
    if ( !isdefined( players ) )
        return undefined;

    swapped = 1;

    for ( n = players.size; swapped; n-- )
    {
        swapped = 0;

        for ( i = 0; i < n - 1; i++ )
        {
            if ( players[i].pers["lives"] < players[i + 1].pers["lives"] )
            {
                temp = players[i];
                players[i] = players[i + 1];
                players[i + 1] = temp;
                swapped = 1;
            }
        }
    }

    return players;
}

giveammo( players, amount )
{
    for ( i = 0; i < players.size; i++ )
    {
        wait 0.5;
        player = players[i];
        currentweapon = player getcurrentweapon();
        clipammo = player getweaponammoclip( currentweapon );
        player setweaponammoclip( currentweapon, clipammo + amount );
    }
}

dogiveammo( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    targets = gettargetsforgametypeeventrule( rule );
    giveammo( targets, rule.params[0] );
}

doremoveammo( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    targets = gettargetsforgametypeeventrule( rule );
    giveammo( targets, 0 - rule.params[0] );
}

doplaysound( rule )
{
    if ( doesrulehavevalidparam( rule ) )
        playsoundonplayers( rule.params[0] );
}

doenableuav( rule )
{
    targets = gettargetsforgametypeeventrule( rule );

    for ( targetindex = 0; targetindex < targets.size; targetindex++ )
    {
        targets[targetindex].pers["hasRadar"] = 1;
        targets[targetindex].hasspyplane = 1;
    }
}

givescore( players, amount )
{
    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];
        score = maps\mp\gametypes_zm\_globallogic_score::_getplayerscore( player );
        maps\mp\gametypes_zm\_globallogic_score::_setplayerscore( player, score + amount );
    }
}

dogivescore( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    targets = gettargetsforgametypeeventrule( rule );
    givescore( targets, rule.params[0] );
}

doremovescore( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    targets = gettargetsforgametypeeventrule( rule );
    givescore( targets, 0 - rule.params[0] );
}

dosetheader( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    targets = gettargetsforgametypeeventrule( rule );

    for ( targetindex = 0; targetindex < targets.size; targetindex++ )
    {
        target = targets[targetindex];
        displaytextonhudelem( target, target.customgametypeheader, rule.params[0], rule.params[1], "gv_header", rule.params[2] );
    }
}

dosetsubheader( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    targets = gettargetsforgametypeeventrule( rule );

    for ( targetindex = 0; targetindex < targets.size; targetindex++ )
    {
        target = targets[targetindex];
        displaytextonhudelem( target, target.customgametypesubheader, rule.params[0], rule.params[1], "gv_subheader", rule.params[2] );
    }
}

displaytextonhudelem( target, texthudelem, text, secondstodisplay, notifyname, valueparam )
{
    texthudelem.alpha = 1;

    if ( isdefined( valueparam ) )
        texthudelem settext( text, valueparam );
    else
        texthudelem settext( text );

    if ( !isdefined( secondstodisplay ) || secondstodisplay <= 0 )
    {
        target.doingnotify = 0;
        target notify( notifyname );
        return;
    }

    target thread fadecustomgametypehudelem( texthudelem, secondstodisplay, notifyname );
}

fadecustomgametypehudelem( hudelem, seconds, notifyname )
{
    self endon( "disconnect" );
    self notify( notifyname );
    self endon( notifyname );

    if ( seconds <= 0 )
        return;

    self.doingnotify = 1;
    wait( seconds );

    while ( hudelem.alpha > 0 )
    {
        hudelem.alpha -= 0.05;

        if ( hudelem.alpha < 0 )
            hudelem.alpha = 0;

        wait 0.05;
    }

    self.doingnotify = 0;
}

dodisplaymessage( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    targets = gettargetsforgametypeeventrule( rule );

    for ( targetindex = 0; targetindex < targets.size; targetindex++ )
        thread announcemessage( targets[targetindex], rule.params[0], 2.0 );
}

announcemessage( target, messagetext, time )
{
    target endon( "disconnect" );
    clientannouncement( target, messagetext, int( time * 1000 ) );

    if ( time == 0 )
        time = getdvarfloat( _hash_E8C4FC20 );

    target.doingnotify = 1;
    wait( time );
    target.doingnotify = 0;
}

givehealth( players, amount )
{
    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];
        player.health += amount;
    }
}

dogivehealth( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    givehealth( gettargetsforgametypeeventrule( rule ), rule.params[0] );
}

doremovehealth( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    givehealth( gettargetsforgametypeeventrule( rule ), 0 - rule.params[0] );
}

dosethealthregen( rule )
{
    targets = gettargetsforgametypeeventrule( rule );

    for ( targetindex = 0; targetindex < targets.size; targetindex++ )
    {
        player = targets[targetindex];
        player.regenrate = rule.params[0];
    }
}

dochangeclass( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;
}

dochangeteam( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    team = rule.params[0];
    teamkeys = getarraykeys( level.teams );
    targets = gettargetsforgametypeeventrule( rule );

    for ( targetindex = 0; targetindex < targets.size; targetindex++ )
    {
        target = targets[targetindex];

        if ( target.pers["team"] == team )
            continue;

        if ( team == "toggle" )
        {
            team = teamkeys[randomint( teamkeys.size )];

            for ( teamindex = 0; teamindex < teamkeys.size; teamindex++ )
            {
                if ( target.pers["team"] == teamkeys[teamindex] )
                {
                    team = teamkeys[( teamindex + 1 ) % teamkeys.size];
                    break;
                }
            }
        }

        target.pers["team"] = team;
        target.team = team;

        if ( level.teambased )
            target.sessionteam = team;
        else
            target.sessionteam = "none";

        target notify( "joined_team" );
        level notify( "joined_team" );
    }
}

displayperk( player, imagename )
{
    index = 0;

    if ( isdefined( player.perkicon ) )
    {
        index = -1;

        for ( i = 0; i < player.perkicon.size; i++ )
        {
            if ( player.perkicon[i].alpha == 0 )
            {
                index = i;
                break;
            }
        }

        if ( index == -1 )
            return;
    }

    player maps\mp\gametypes_zm\_hud_util::showperk( index, imagename, 10 );
    player thread maps\mp\gametypes_zm\_globallogic_ui::hideloadoutaftertime( 3.0 );
    player thread maps\mp\gametypes_zm\_globallogic_ui::hideloadoutondeath();
}

setorunsetperk( players, perks, shouldset )
{
    if ( level.perksenabled == 0 )
        return;

    if ( perks.size < 2 )
        return;

    hasperkalready = 0;
    imagename = perks[perks.size - 1];

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];

        for ( perkindex = 0; perkindex < perks.size - 1; perkindex++ )
        {
            perk = perks[perkindex];

            if ( player hasperk( perk ) )
                hasperkalready = 1;

            if ( shouldset )
            {
                player setperk( perk );
                continue;
            }

            player unsetperk( perk );
        }

        if ( shouldset && !hasperkalready && getdvarint( "scr_showperksonspawn" ) == 1 )
            displayperk( player, imagename );
    }
}

dogiveperk( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    setorunsetperk( gettargetsforgametypeeventrule( rule ), rule.params, 1 );
}

doremoveperk( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    setorunsetperk( gettargetsforgametypeeventrule( rule ), rule.params, 0 );
}

giveorremovekillstreak( rule, shouldgive )
{

}

dogivekillstreak( rule )
{
    giveorremovekillstreak( rule, 1 );
}

doremovekillstreak( rule )
{
    giveorremovekillstreak( rule, 0 );
}

givelives( players, amount )
{
    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];
        player.pers["lives"] += amount;

        if ( player.pers["lives"] < 0 )
            player.pers["lives"] = 0;
    }
}

dogivelives( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    givelives( gettargetsforgametypeeventrule( rule ), rule.params[0] );
}

doremovelives( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    givelives( gettargetsforgametypeeventrule( rule ), 0 - rule.params[0] );
}

giveorremoveinvuln( players, shouldgiveinvuln )
{
    for ( i = 0; i < players.size; i++ )
        player = players[i];
}

dogiveinvuln( rule )
{
    giveorremoveinvuln( gettargetsforgametypeeventrule( rule ), 1 );
}

doremoveinvuln( rule )
{
    giveorremoveinvuln( gettargetsforgametypeeventrule( rule ), 0 );
}

dosetdamagemodifier( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    players = gettargetsforgametypeeventrule( rule );

    for ( i = 0; i < players.size; i++ )
    {
        player = players[i];
        player.damagemodifier = rule.params[0];
    }
}

doscalemovespeed( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    movespeedscale = rule.params[0];
    targets = gettargetsforgametypeeventrule( rule );

    for ( targetindex = 0; targetindex < targets.size; targetindex++ )
    {
        target = targets[targetindex];
        target.movementspeedmodifier = movespeedscale * target getmovespeedscale();

        if ( target.movementspeedmodifier < 0.1 )
            target.movementspeedmodifier = 0.1;
        else if ( target.movementspeedmodifier > 4.0 )
            target.movementspeedmodifier = 4.0;

        target setmovespeedscale( target.movementspeedmodifier );
    }
}

doshowonradar( rule )
{
    if ( !doesrulehavevalidparam( rule ) )
        return;

    targets = gettargetsforgametypeeventrule( rule );

    for ( targetindex = 0; targetindex < targets.size; targetindex++ )
    {
        if ( rule.params[0] == "enable" )
        {
            targets[targetindex] setperk( "specialty_showonradar" );
            continue;
        }

        targets[targetindex] unsetperk( "specialty_showonradar" );
    }
}
