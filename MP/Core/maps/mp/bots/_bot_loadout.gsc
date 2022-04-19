// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bot;
#include maps\mp\gametypes\_rank;

init()
{
    level endon( "game_ended" );
    level.bot_banned_killstreaks = array( "KILLSTREAK_RCBOMB", "KILLSTREAK_QRDRONE", "KILLSTREAK_REMOTE_MISSILE", "KILLSTREAK_REMOTE_MORTAR", "KILLSTREAK_HELICOPTER_GUNNER" );

    for (;;)
    {
        level waittill( "connected", player );

        if ( !player istestclient() )
            continue;

        player thread on_bot_connect();
    }
}

on_bot_connect()
{
    self endon( "disconnect" );

    if ( isdefined( self.pers["bot_loadout"] ) )
        return;

    wait 0.1;

    if ( self getentitynumber() % 2 == 0 )
        wait 0.05;

    self maps\mp\bots\_bot::bot_set_rank();

    if ( level.onlinegame && !sessionmodeisprivate() )
    {
        self botsetdefaultclass( 5, "class_assault" );
        self botsetdefaultclass( 6, "class_smg" );
        self botsetdefaultclass( 7, "class_lmg" );
        self botsetdefaultclass( 8, "class_cqb" );
        self botsetdefaultclass( 9, "class_sniper" );
    }
    else
    {
        self botsetdefaultclass( 5, "class_assault" );
        self botsetdefaultclass( 6, "class_smg" );
        self botsetdefaultclass( 7, "class_lmg" );
        self botsetdefaultclass( 8, "class_cqb" );
        self botsetdefaultclass( 9, "class_sniper" );
    }

    max_allocation = 10;

    for ( i = 1; i <= 3; i++ )
    {
        if ( self isitemlocked( maps\mp\gametypes\_rank::getitemindex( "feature_allocation_slot_" + i ) ) )
            max_allocation--;
    }

    self bot_construct_loadout( max_allocation );
    self.pers["bot_loadout"] = 1;
}

bot_construct_loadout( allocation_max )
{
    if ( self isitemlocked( maps\mp\gametypes\_rank::getitemindex( "feature_cac" ) ) )
        return;

    pixbeginevent( "bot_construct_loadout" );
    item_list = bot_build_item_list();
    bot_construct_class( 0, item_list, allocation_max );
    bot_construct_class( 1, item_list, allocation_max );
    bot_construct_class( 2, item_list, allocation_max );
    bot_construct_class( 3, item_list, allocation_max );
    bot_construct_class( 4, item_list, allocation_max );
    killstreaks = item_list["killstreak1"];

    if ( isdefined( item_list["killstreak2"] ) )
        killstreaks = arraycombine( killstreaks, item_list["killstreak2"], 1, 0 );

    if ( isdefined( item_list["killstreak3"] ) )
        killstreaks = arraycombine( killstreaks, item_list["killstreak3"], 1, 0 );

    if ( isdefined( killstreaks ) && killstreaks.size )
    {
        bot_choose_weapon( 0, killstreaks );
        bot_choose_weapon( 0, killstreaks );
        bot_choose_weapon( 0, killstreaks );
    }

    self.claimed_items = undefined;
    pixendevent();
}

bot_construct_class( class, items, allocation_max )
{
    allocation = 0;
    claimed_count = bot_build_claimed_list( items );
    self.claimed_items = [];

    while ( allocation < allocation_max )
    {
        secondary_chance = 40;
        remaining = allocation_max - allocation;

        if ( remaining >= 1 && bot_make_choice( 95, claimed_count["primary"], 1 ) )
        {
            weapon = bot_choose_weapon( class, items["primary"] );
            claimed_count["primary"]++;
            allocation++;
            bot_choose_weapon_option( class, "camo", 0 );
            bot_choose_weapon_option( class, "reticle", 0 );
            allocation += bot_choose_primary_attachments( class, weapon, allocation, allocation_max );
        }
        else if ( !claimed_count["primary"] )
            secondary_chance = 100;

        remaining = allocation_max - allocation;

        if ( remaining >= 1 && bot_make_choice( secondary_chance, claimed_count["secondary"], 1 ) )
        {
            if ( remaining >= 2 && randomint( 100 ) < 10 )
            {
                self botclassadditem( class, "BONUSCARD_OVERKILL" );
                weapon = bot_choose_weapon( class, items["primary"] );
                allocation++;
            }
            else
            {
                weapon = bot_choose_weapon( class, items["secondary"] );
                bot_choose_weapon_option( class, "camo", 1 );
            }

            allocation++;
            claimed_count["secondary"]++;
            allocation += bot_choose_secondary_attachments( class, weapon, allocation, allocation_max );
        }

        perks_chance = 50;
        lethal_chance = 30;
        tactical_chance = 20;

        if ( claimed_count["specialty1"] && claimed_count["specialty2"] && claimed_count["specialty3"] )
            perks_chance = 0;

        if ( claimed_count["primarygrenade"] )
            lethal_chance = 0;

        if ( claimed_count["specialgrenade"] )
            tactical_chance = 0;

        if ( perks_chance + lethal_chance + tactical_chance <= 0 )
            return;

        next_action = bot_chose_action( "perks", perks_chance, "lethal", lethal_chance, "tactical", tactical_chance, "none", 0 );

        if ( next_action == "perks" )
        {
            remaining = allocation_max - allocation;

            if ( remaining >= 3 && !claimed_count["specialty1"] && randomint( 100 ) < 25 )
            {
                self botclassadditem( class, "BONUSCARD_PERK_1_GREED" );
                bot_choose_weapon( class, items["specialty1"] );
                bot_choose_weapon( class, items["specialty1"] );
                claimed_count["specialty1"] = 2;
                allocation += 3;
            }

            remaining = allocation_max - allocation;

            if ( remaining >= 3 && !claimed_count["specialty2"] && randomint( 100 ) < 25 )
            {
                self botclassadditem( class, "BONUSCARD_PERK_2_GREED" );
                bot_choose_weapon( class, items["specialty2"] );
                bot_choose_weapon( class, items["specialty2"] );
                claimed_count["specialty2"] = 2;
                allocation += 3;
            }

            remaining = allocation_max - allocation;

            if ( remaining >= 3 && !claimed_count["specialty3"] && randomint( 100 ) < 25 )
            {
                self botclassadditem( class, "BONUSCARD_PERK_3_GREED" );
                bot_choose_weapon( class, items["specialty3"] );
                bot_choose_weapon( class, items["specialty3"] );
                claimed_count["specialty3"] = 2;
                allocation += 3;
            }

            remaining = allocation_max - allocation;

            for ( i = 0; i < 3; i++ )
            {
                perks = [];
                remaining = allocation_max - allocation;

                if ( remaining > 0 )
                {
                    if ( !claimed_count["specialty1"] )
                        perks[perks.size] = "specialty1";

                    if ( !claimed_count["specialty2"] )
                        perks[perks.size] = "specialty2";

                    if ( !claimed_count["specialty3"] )
                        perks[perks.size] = "specialty3";

                    if ( perks.size )
                    {
                        perk = random( perks );
                        bot_choose_weapon( class, items[perk] );
                        claimed_count[perk]++;
                        allocation++;
                        continue;
                    }

                    break;
                }
            }
        }
        else if ( next_action == "lethal" )
        {
            remaining = allocation_max - allocation;

            if ( remaining >= 2 && randomint( 100 ) < 50 )
            {
                if ( !claimed_count["primarygrenade"] )
                {
                    bot_choose_weapon( class, items["primarygrenade"] );
                    claimed_count["primarygrenade"]++;
                    allocation++;
                }

                self botclassadditem( class, "BONUSCARD_DANGER_CLOSE" );
                allocation++;
            }
            else if ( remaining >= 1 && !claimed_count["primarygrenade"] )
            {
                bot_choose_weapon( class, items["primarygrenade"] );
                claimed_count["primarygrenade"]++;
                allocation++;
            }
        }
        else if ( next_action == "tactical" )
        {
            remaining = allocation_max - allocation;

            if ( remaining >= 2 && !claimed_count["specialgrenade"] && randomint( 100 ) < 50 )
            {
                weapon = bot_choose_weapon( class, items["specialgrenade"] );

                if ( weapon == "WEAPON_TACTICAL_INSERTION" || weapon == "WEAPON_WILLY_PETE" )
                {
                    claimed_count["specialgrenade"] = 1;
                    allocation += 1;
                }
                else
                {
                    self botclassadditem( class, weapon );
                    claimed_count["specialgrenade"] = 2;
                    allocation += 2;
                }
            }
            else if ( remaining >= 1 && !claimed_count["specialgrenade"] )
            {
                bot_choose_weapon( class, items["specialgrenade"] );
                claimed_count["specialgrenade"]++;
                allocation++;
            }
        }
    }
}

bot_make_choice( chance, claimed, max_claim )
{
    return claimed < max_claim && randomint( 100 ) < chance;
}

bot_chose_action( action1, chance1, action2, chance2, action3, chance3, action4, chance4 )
{
    chance1 = int( chance1 / 10 );
    chance2 = int( chance2 / 10 );
    chance3 = int( chance3 / 10 );
    chance4 = int( chance4 / 10 );
    actions = [];

    for ( i = 0; i < chance1; i++ )
        actions[actions.size] = action1;

    for ( i = 0; i < chance2; i++ )
        actions[actions.size] = action2;

    for ( i = 0; i < chance3; i++ )
        actions[actions.size] = action3;

    for ( i = 0; i < chance4; i++ )
        actions[actions.size] = action4;

    return random( actions );
}

bot_item_is_claimed( item )
{
    foreach ( claim in self.claimed_items )
    {
        if ( claim == item )
            return true;
    }

    return false;
}

bot_choose_weapon( class, items )
{
    if ( !isdefined( items ) || !items.size )
        return undefined;

    start = randomint( items.size );

    for ( i = 0; i < items.size; i++ )
    {
        weapon = items[start];

        if ( !bot_item_is_claimed( weapon ) )
            break;

        start = ( start + 1 ) % items.size;
    }

    self.claimed_items[self.claimed_items.size] = weapon;
    self botclassadditem( class, weapon );
    return weapon;
}

bot_build_weapon_options_list( optiontype )
{
    level.botweaponoptionsid[optiontype] = [];
    level.botweaponoptionsprob[optiontype] = [];
    prob = 0;

    for ( row = 0; row < 255; row++ )
    {
        if ( tablelookupcolumnforrow( "mp/attachmentTable.csv", row, 1 ) == optiontype )
        {
            index = level.botweaponoptionsid[optiontype].size;
            level.botweaponoptionsid[optiontype][index] = int( tablelookupcolumnforrow( "mp/attachmentTable.csv", row, 0 ) );
            prob += int( tablelookupcolumnforrow( "mp/attachmentTable.csv", row, 15 ) );
            level.botweaponoptionsprob[optiontype][index] = prob;
        }
    }
}

bot_choose_weapon_option( class, optiontype, primary )
{
    if ( !isdefined( level.botweaponoptionsid ) )
    {
        level.botweaponoptionsid = [];
        level.botweaponoptionsprob = [];
        bot_build_weapon_options_list( "camo" );
        bot_build_weapon_options_list( "reticle" );
    }

    if ( !level.onlinegame && !level.systemlink )
        return;

    numoptions = level.botweaponoptionsprob[optiontype].size;
    maxprob = level.botweaponoptionsprob[optiontype][numoptions - 1];

    if ( !level.systemlink && self.pers["rank"] < 20 )
        maxprob += 4 * maxprob * ( 20 - self.pers["rank"] ) / 20;

    rnd = randomint( int( maxprob ) );

    for ( i = 0; i < numoptions; i++ )
    {
        if ( level.botweaponoptionsprob[optiontype][i] > rnd )
        {
            self botclasssetweaponoption( class, primary, optiontype, level.botweaponoptionsid[optiontype][i] );
            break;
        }
    }
}

bot_choose_primary_attachments( class, weapon, allocation, allocation_max )
{
    attachments = getweaponattachments( weapon );
    remaining = allocation_max - allocation;

    if ( !attachments.size || !remaining )
        return 0;

    attachment_action = bot_chose_action( "3_attachments", 25, "2_attachments", 35, "1_attachments", 35, "none", 5 );

    if ( remaining >= 4 && attachment_action == "3_attachments" )
    {
        a1 = random( attachments );
        self botclassaddattachment( class, weapon, a1, "primaryattachment1" );
        count = 1;
        attachments = getweaponattachments( weapon, a1 );

        if ( attachments.size )
        {
            a2 = random( attachments );
            self botclassaddattachment( class, weapon, a2, "primaryattachment2" );
            count++;
            attachments = getweaponattachments( weapon, a1, a2 );

            if ( attachments.size )
            {
                a3 = random( attachments );
                self botclassadditem( class, "BONUSCARD_PRIMARY_GUNFIGHTER" );
                self botclassaddattachment( class, weapon, a3, "primaryattachment3" );
                return 4;
            }
        }

        return count;
    }
    else if ( remaining >= 2 && attachment_action == "2_attachments" )
    {
        a1 = random( attachments );
        self botclassaddattachment( class, weapon, a1, "primaryattachment1" );
        attachments = getweaponattachments( weapon, a1 );

        if ( attachments.size )
        {
            a2 = random( attachments );
            self botclassaddattachment( class, weapon, a2, "primaryattachment2" );
            return 2;
        }

        return 1;
    }
    else if ( remaining >= 1 && attachment_action == "1_attachments" )
    {
        a = random( attachments );
        self botclassaddattachment( class, weapon, a, "primaryattachment1" );
        return 1;
    }

    return 0;
}

bot_choose_secondary_attachments( class, weapon, allocation, allocation_max )
{
    attachments = getweaponattachments( weapon );
    remaining = allocation_max - allocation;

    if ( !attachments.size || !remaining )
        return 0;

    attachment_action = bot_chose_action( "2_attachments", 10, "1_attachments", 40, "none", 50, "none", 0 );

    if ( remaining >= 3 && attachment_action == "2_attachments" )
    {
        a1 = random( attachments );
        self botclassaddattachment( class, weapon, a1, "secondaryattachment1" );
        attachments = getweaponattachments( weapon, a1 );

        if ( attachments.size )
        {
            a2 = random( attachments );
            self botclassadditem( class, "BONUSCARD_SECONDARY_GUNFIGHTER" );
            self botclassaddattachment( class, weapon, a2, "secondaryattachment2" );
            return 3;
        }

        return 1;
    }
    else if ( remaining >= 1 && attachment_action == "1_attachments" )
    {
        a = random( attachments );
        self botclassaddattachment( class, weapon, a, "secondaryattachment1" );
        return 1;
    }

    return 0;
}

bot_build_item_list()
{
    pixbeginevent( "bot_build_item_list" );
    items = [];

    for ( i = 0; i < 256; i++ )
    {
        row = tablelookuprownum( level.statstableid, 0, i );

        if ( row > -1 )
        {
            slot = tablelookupcolumnforrow( level.statstableid, row, 13 );

            if ( slot == "" )
                continue;

            number = int( tablelookupcolumnforrow( level.statstableid, row, 0 ) );

            if ( self isitemlocked( number ) )
                continue;

            allocation = int( tablelookupcolumnforrow( level.statstableid, row, 12 ) );

            if ( allocation < 0 )
                continue;

            name = tablelookupcolumnforrow( level.statstableid, row, 3 );

            if ( bot_item_is_banned( slot, name ) )
                continue;

            if ( !isdefined( items[slot] ) )
                items[slot] = [];

            items[slot][items[slot].size] = name;
        }
    }

    pixendevent();
    return items;
}

bot_item_is_banned( slot, item )
{
    if ( item == "WEAPON_KNIFE_BALLISTIC" )
        return true;

    if ( getdvarint( "tu6_enableDLCWeapons" ) == 0 && item == "WEAPON_PEACEKEEPER" )
        return true;

    if ( slot != "killstreak1" && slot != "killstreak2" && slot != "killstreak3" )
        return false;

    foreach ( banned in level.bot_banned_killstreaks )
    {
        if ( item == banned )
            return true;
    }

    return false;
}

bot_build_claimed_list( items )
{
    claimed = [];
    keys = getarraykeys( items );

    foreach ( key in keys )
        claimed[key] = 0;

    return claimed;
}
