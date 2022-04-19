// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\animscripts\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\_utility;
#include maps\mp\animscripts\zm_shared;

main()
{
    debug_anim_print( "zm_death::main()" );
    self setaimanimweights( 0, 0 );
    self endon( "killanimscript" );

    if ( isdefined( self.deathfunction ) )
    {
        successful_death = self [[ self.deathfunction ]]();

        if ( !isdefined( successful_death ) || successful_death )
            return;
    }

    if ( isdefined( self.a.nodeath ) && self.a.nodeath == 1 )
    {
/#
        assert( self.a.nodeath, "Nodeath needs to be set to true or undefined." );
#/
        wait 3;
        return;
    }

    self unlink();

    if ( isdefined( self.anchor ) )
        self.anchor delete();

    if ( isdefined( self.enemy ) && isdefined( self.enemy.syncedmeleetarget ) && self.enemy.syncedmeleetarget == self )
        self.enemy.syncedmeleetarget = undefined;

    self thread do_gib();

    if ( isdefined( self.a.gib_ref ) && ( self.a.gib_ref == "no_legs" || self.a.gib_ref == "right_leg" || self.a.gib_ref == "left_leg" ) )
        self.has_legs = 0;

    if ( !isdefined( self.deathanim ) )
    {
        self.deathanim = "zm_death";
        self.deathanim_substate = undefined;
    }

    self.deathanim = append_missing_legs_suffix( self.deathanim );
    self animmode( "gravity" );
    self setanimstatefromasd( self.deathanim, self.deathanim_substate );

    if ( !self getanimhasnotetrackfromasd( "start_ragdoll" ) )
        self thread waitforragdoll( self getanimlengthfromasd() * 0.35 );

    if ( isdefined( self.skip_death_notetracks ) && self.skip_death_notetracks )
        self waittillmatch( "death_anim", "end" );
    else
        self maps\mp\animscripts\zm_shared::donotetracks( "death_anim", self.handle_death_notetracks );
}

waitforragdoll( time )
{
    wait( time );
    do_ragdoll = 1;

    if ( isdefined( self.nodeathragdoll ) && self.nodeathragdoll )
        do_ragdoll = 0;

    if ( isdefined( self ) && do_ragdoll )
        self startragdoll();
}

on_fire_timeout()
{
    self endon( "death" );
    wait 12;

    if ( isdefined( self ) && isalive( self ) )
    {
        self.is_on_fire = 0;
        self notify( "stop_flame_damage" );
    }
}

flame_death_fx()
{
    self endon( "death" );

    if ( isdefined( self.is_on_fire ) && self.is_on_fire )
        return;

    self.is_on_fire = 1;
    self thread on_fire_timeout();

    if ( isdefined( level._effect ) && isdefined( level._effect["character_fire_death_torso"] ) )
    {
        if ( !self.isdog )
            playfxontag( level._effect["character_fire_death_torso"], self, "J_SpineLower" );
    }
    else
    {
/#
        println( "^3ANIMSCRIPT WARNING: You are missing level._effect[\"character_fire_death_torso\"], please set it in your levelname_fx.gsc. Use \"env/fire/fx_fire_player_torso\"" );
#/
    }

    if ( isdefined( level._effect ) && isdefined( level._effect["character_fire_death_sm"] ) )
    {
        wait 1;
        tagarray = [];
        tagarray[0] = "J_Elbow_LE";
        tagarray[1] = "J_Elbow_RI";
        tagarray[2] = "J_Knee_RI";
        tagarray[3] = "J_Knee_LE";
        tagarray = randomize_array( tagarray );
        playfxontag( level._effect["character_fire_death_sm"], self, tagarray[0] );
        wait 1;
        tagarray[0] = "J_Wrist_RI";
        tagarray[1] = "J_Wrist_LE";

        if ( !isdefined( self.a ) || !isdefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" )
        {
            tagarray[2] = "J_Ankle_RI";
            tagarray[3] = "J_Ankle_LE";
        }

        tagarray = randomize_array( tagarray );
        playfxontag( level._effect["character_fire_death_sm"], self, tagarray[0] );
        playfxontag( level._effect["character_fire_death_sm"], self, tagarray[1] );
    }
    else
    {
/#
        println( "^3ANIMSCRIPT WARNING: You are missing level._effect[\"character_fire_death_sm\"], please set it in your levelname_fx.gsc. Use \"env/fire/fx_fire_zombie_md\"" );
#/
    }
}

randomize_array( array )
{
    for ( i = 0; i < array.size; i++ )
    {
        j = randomint( array.size );
        temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }

    return array;
}

get_tag_for_damage_location()
{
    tag = "J_SpineLower";

    if ( self.damagelocation == "helmet" )
        tag = "j_head";
    else if ( self.damagelocation == "head" )
        tag = "j_head";
    else if ( self.damagelocation == "neck" )
        tag = "j_neck";
    else if ( self.damagelocation == "torso_upper" )
        tag = "j_spineupper";
    else if ( self.damagelocation == "torso_lower" )
        tag = "j_spinelower";
    else if ( self.damagelocation == "right_arm_upper" )
        tag = "j_elbow_ri";
    else if ( self.damagelocation == "left_arm_upper" )
        tag = "j_elbow_le";
    else if ( self.damagelocation == "right_arm_lower" )
        tag = "j_wrist_ri";
    else if ( self.damagelocation == "left_arm_lower" )
        tag = "j_wrist_le";

    return tag;
}

set_last_gib_time()
{
    anim notify( "stop_last_gib_time" );
    anim endon( "stop_last_gib_time" );
    wait 0.05;
    anim.lastgibtime = gettime();
    anim.totalgibs = randomintrange( anim.mingibs, anim.maxgibs );
}

get_gib_ref( direction )
{
    if ( isdefined( self.a.gib_ref ) )
        return;

    if ( self.damagetaken < 165 )
        return;

    if ( gettime() > anim.lastgibtime + anim.gibdelay && anim.totalgibs > 0 )
    {
        anim.totalgibs--;
        anim thread set_last_gib_time();
        refs = [];

        switch ( direction )
        {
            case "right":
                refs[refs.size] = "left_arm";
                refs[refs.size] = "left_leg";
                gib_ref = get_random( refs );
                break;
            case "left":
                refs[refs.size] = "right_arm";
                refs[refs.size] = "right_leg";
                gib_ref = get_random( refs );
                break;
            case "forward":
                refs[refs.size] = "right_arm";
                refs[refs.size] = "left_arm";
                refs[refs.size] = "right_leg";
                refs[refs.size] = "left_leg";
                refs[refs.size] = "guts";
                refs[refs.size] = "no_legs";
                gib_ref = get_random( refs );
                break;
            case "back":
                refs[refs.size] = "right_arm";
                refs[refs.size] = "left_arm";
                refs[refs.size] = "right_leg";
                refs[refs.size] = "left_leg";
                refs[refs.size] = "no_legs";
                gib_ref = get_random( refs );
                break;
            default:
                refs[refs.size] = "right_arm";
                refs[refs.size] = "left_arm";
                refs[refs.size] = "right_leg";
                refs[refs.size] = "left_leg";
                refs[refs.size] = "no_legs";
                refs[refs.size] = "guts";
                gib_ref = get_random( refs );
                break;
        }

        self.a.gib_ref = gib_ref;
    }
    else
        self.a.gib_ref = undefined;
}

get_random( array )
{
    return array[randomint( array.size )];
}

do_gib()
{
    if ( !is_mature() )
        return;

    if ( !isdefined( self.a.gib_ref ) )
        return;

    if ( isdefined( self.is_on_fire ) && self.is_on_fire )
        return;

    if ( self is_zombie_gibbed() )
        return;

    self set_zombie_gibbed();
    gib_ref = self.a.gib_ref;
    limb_data = get_limb_data( gib_ref );

    if ( !isdefined( limb_data ) )
    {
/#
        println( "^3animscriptszm_death.gsc - limb_data is not setup for gib_ref on model: " + self.model + " and gib_ref of: " + self.a.gib_ref );
#/
        return;
    }

    if ( !( isdefined( self.dont_throw_gib ) && self.dont_throw_gib ) )
        self thread throw_gib( limb_data["spawn_tags_array"] );

    if ( gib_ref == "head" )
    {
        self.hat_gibbed = 1;
        self.head_gibbed = 1;
        size = self getattachsize();

        for ( i = 0; i < size; i++ )
        {
            model = self getattachmodelname( i );

            if ( issubstr( model, "head" ) )
            {
                if ( isdefined( self.hatmodel ) )
                    self detach( self.hatmodel, "" );

                self detach( model, "" );

                if ( isdefined( self.torsodmg5 ) )
                    self attach( self.torsodmg5, "", 1 );

                break;
            }
        }
    }
    else
    {
        self setmodel( limb_data["body_model"] );
        self attach( limb_data["legs_model"] );
    }
}

precache_gib_fx()
{
    anim._effect["animscript_gib_fx"] = loadfx( "weapon/bullet/fx_flesh_gib_fatal_01" );
    anim._effect["animscript_gibtrail_fx"] = loadfx( "trail/fx_trail_blood_streak" );
    anim._effect["death_neckgrab_spurt"] = loadfx( "impacts/fx_flesh_hit_neck_fatal" );
}

get_limb_data( gib_ref )
{
    temp_array = [];

    if ( "right_arm" == gib_ref && isdefined( self.torsodmg2 ) && isdefined( self.legdmg1 ) && isdefined( self.gibspawn1 ) && isdefined( self.gibspawntag1 ) )
    {
        temp_array["right_arm"]["body_model"] = self.torsodmg2;
        temp_array["right_arm"]["legs_model"] = self.legdmg1;
        temp_array["right_arm"]["spawn_tags_array"] = [];
        temp_array["right_arm"]["spawn_tags_array"][0] = level._zombie_gib_piece_index_right_arm;
    }

    if ( "left_arm" == gib_ref && isdefined( self.torsodmg3 ) && isdefined( self.legdmg1 ) && isdefined( self.gibspawn2 ) && isdefined( self.gibspawntag2 ) )
    {
        temp_array["left_arm"]["body_model"] = self.torsodmg3;
        temp_array["left_arm"]["legs_model"] = self.legdmg1;
        temp_array["left_arm"]["spawn_tags_array"] = [];
        temp_array["left_arm"]["spawn_tags_array"][0] = level._zombie_gib_piece_index_left_arm;
    }

    if ( "right_leg" == gib_ref && isdefined( self.torsodmg1 ) && isdefined( self.legdmg2 ) && isdefined( self.gibspawn3 ) && isdefined( self.gibspawntag3 ) )
    {
        temp_array["right_leg"]["body_model"] = self.torsodmg1;
        temp_array["right_leg"]["legs_model"] = self.legdmg2;
        temp_array["right_leg"]["spawn_tags_array"] = [];
        temp_array["right_leg"]["spawn_tags_array"][0] = level._zombie_gib_piece_index_right_leg;
    }

    if ( "left_leg" == gib_ref && isdefined( self.torsodmg1 ) && isdefined( self.legdmg3 ) && isdefined( self.gibspawn4 ) && isdefined( self.gibspawntag4 ) )
    {
        temp_array["left_leg"]["body_model"] = self.torsodmg1;
        temp_array["left_leg"]["legs_model"] = self.legdmg3;
        temp_array["left_leg"]["spawn_tags_array"] = [];
        temp_array["left_leg"]["spawn_tags_array"][0] = level._zombie_gib_piece_index_left_leg;
    }

    if ( "no_legs" == gib_ref && isdefined( self.torsodmg1 ) && isdefined( self.legdmg4 ) && isdefined( self.gibspawn4 ) && isdefined( self.gibspawn3 ) && isdefined( self.gibspawntag3 ) && isdefined( self.gibspawntag4 ) )
    {
        temp_array["no_legs"]["body_model"] = self.torsodmg1;
        temp_array["no_legs"]["legs_model"] = self.legdmg4;
        temp_array["no_legs"]["spawn_tags_array"] = [];
        temp_array["no_legs"]["spawn_tags_array"][0] = level._zombie_gib_piece_index_right_leg;
        temp_array["no_legs"]["spawn_tags_array"][1] = level._zombie_gib_piece_index_left_leg;
    }

    if ( "guts" == gib_ref && isdefined( self.torsodmg4 ) && isdefined( self.legdmg1 ) )
    {
        temp_array["guts"]["body_model"] = self.torsodmg4;
        temp_array["guts"]["legs_model"] = self.legdmg1;
        temp_array["guts"]["spawn_tags_array"] = [];
        temp_array["guts"]["spawn_tags_array"][0] = level._zombie_gib_piece_index_guts;

        if ( isdefined( self.gibspawn2 ) && isdefined( self.gibspawntag2 ) )
            temp_array["guts"]["spawn_tags_array"][1] = level._zombie_gib_piece_index_left_arm;
    }

    if ( "head" == gib_ref && isdefined( self.torsodmg5 ) && isdefined( self.legdmg1 ) )
    {
        temp_array["head"]["body_model"] = self.torsodmg5;
        temp_array["head"]["legs_model"] = self.legdmg1;
        temp_array["head"]["spawn_tags_array"] = [];
        temp_array["head"]["spawn_tags_array"][0] = level._zombie_gib_piece_index_head;

        if ( !( isdefined( self.hat_gibbed ) && self.hat_gibbed ) && isdefined( self.gibspawn5 ) && isdefined( self.gibspawntag5 ) )
            temp_array["head"]["spawn_tags_array"][1] = level._zombie_gib_piece_index_hat;
    }

    if ( isdefined( temp_array[gib_ref] ) )
        return temp_array[gib_ref];
    else
        return undefined;
}

throw_gib( limb_tags_array )
{
    if ( isdefined( limb_tags_array ) )
    {
        if ( isdefined( level.track_gibs ) )
            level [[ level.track_gibs ]]( self, limb_tags_array );

        if ( isdefined( self.launch_gib_up ) )
            self gib( "up", limb_tags_array );
        else
            self gib( "normal", limb_tags_array );
    }
}
