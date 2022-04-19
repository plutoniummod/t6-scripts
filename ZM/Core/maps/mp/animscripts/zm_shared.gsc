// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include maps\mp\animscripts\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\zm_utility;

deleteatlimit()
{
    wait 30.0;
    self delete();
}

lookatentity( looktargetentity, lookduration, lookspeed, eyesonly, interruptothers )
{

}

lookatposition( looktargetpos, lookduration, lookspeed, eyesonly, interruptothers )
{
/#
    assert( isai( self ), "Can only call this function on an AI character" );
#/
/#
    assert( self.a.targetlookinitilized == 1, "LookAtPosition called on AI that lookThread was not called on" );
#/
/#
    assert( lookspeed == "casual" || lookspeed == "alert", "lookSpeed must be casual or alert" );
#/
    if ( !isdefined( interruptothers ) || interruptothers == "interrupt others" || gettime() > self.a.lookendtime )
    {
        self.a.looktargetpos = looktargetpos;
        self.a.lookendtime = gettime() + lookduration * 1000;

        if ( lookspeed == "casual" )
            self.a.looktargetspeed = 800;
        else
            self.a.looktargetspeed = 1600;

        if ( isdefined( eyesonly ) && eyesonly == "eyes only" )
            self notify( "eyes look now" );
        else
            self notify( "look now" );
    }
}

lookatanimations( leftanim, rightanim )
{
    self.a.lookanimationleft = leftanim;
    self.a.lookanimationright = rightanim;
}

handledogsoundnotetracks( note )
{
    if ( note == "sound_dogstep_run_default" || note == "dogstep_rf" || note == "dogstep_lf" )
    {
        self playsound( "fly_dog_step_run_default" );
        return true;
    }

    prefix = getsubstr( note, 0, 5 );

    if ( prefix != "sound" )
        return false;

    alias = "aml" + getsubstr( note, 5 );

    if ( isalive( self ) )
        self thread play_sound_on_tag_endon_death( alias, "tag_eye" );
    else
        self thread play_sound_in_space( alias, self gettagorigin( "tag_eye" ) );

    return true;
}

growling()
{
    return isdefined( self.script_growl );
}

registernotetracks()
{
    anim.notetracks["anim_pose = \"stand\""] = ::notetrackposestand;
    anim.notetracks["anim_pose = \"crouch\""] = ::notetrackposecrouch;
    anim.notetracks["anim_movement = \"stop\""] = ::notetrackmovementstop;
    anim.notetracks["anim_movement = \"walk\""] = ::notetrackmovementwalk;
    anim.notetracks["anim_movement = \"run\""] = ::notetrackmovementrun;
    anim.notetracks["anim_alertness = causal"] = ::notetrackalertnesscasual;
    anim.notetracks["anim_alertness = alert"] = ::notetrackalertnessalert;
    anim.notetracks["gravity on"] = ::notetrackgravity;
    anim.notetracks["gravity off"] = ::notetrackgravity;
    anim.notetracks["gravity code"] = ::notetrackgravity;
    anim.notetracks["bodyfall large"] = ::notetrackbodyfall;
    anim.notetracks["bodyfall small"] = ::notetrackbodyfall;
    anim.notetracks["footstep"] = ::notetrackfootstep;
    anim.notetracks["step"] = ::notetrackfootstep;
    anim.notetracks["footstep_right_large"] = ::notetrackfootstep;
    anim.notetracks["footstep_right_small"] = ::notetrackfootstep;
    anim.notetracks["footstep_left_large"] = ::notetrackfootstep;
    anim.notetracks["footstep_left_small"] = ::notetrackfootstep;
    anim.notetracks["footscrape"] = ::notetrackfootscrape;
    anim.notetracks["land"] = ::notetrackland;
    anim.notetracks["start_ragdoll"] = ::notetrackstartragdoll;
}

notetrackstopanim( note, flagname )
{

}

notetrackstartragdoll( note, flagname )
{
    if ( isdefined( self.noragdoll ) )
        return;

    self unlink();
    self startragdoll();
}

notetrackmovementstop( note, flagname )
{
    if ( issentient( self ) )
        self.a.movement = "stop";
}

notetrackmovementwalk( note, flagname )
{
    if ( issentient( self ) )
        self.a.movement = "walk";
}

notetrackmovementrun( note, flagname )
{
    if ( issentient( self ) )
        self.a.movement = "run";
}

notetrackalertnesscasual( note, flagname )
{
    if ( issentient( self ) )
        self.a.alertness = "casual";
}

notetrackalertnessalert( note, flagname )
{
    if ( issentient( self ) )
        self.a.alertness = "alert";
}

notetrackposestand( note, flagname )
{
    self.a.pose = "stand";
    self notify( "entered_pose" + "stand" );
}

notetrackposecrouch( note, flagname )
{
    self.a.pose = "crouch";
    self notify( "entered_pose" + "crouch" );

    if ( self.a.crouchpain )
    {
        self.a.crouchpain = 0;
        self.health = 150;
    }
}

notetrackgravity( note, flagname )
{
    if ( issubstr( note, "on" ) )
        self animmode( "gravity" );
    else if ( issubstr( note, "off" ) )
    {
        self animmode( "nogravity" );
        self.nogravity = 1;
    }
    else if ( issubstr( note, "code" ) )
    {
        self animmode( "none" );
        self.nogravity = undefined;
    }
}

notetrackbodyfall( note, flagname )
{
    if ( isdefined( self.groundtype ) )
        groundtype = self.groundtype;
    else
        groundtype = "dirt";

    if ( issubstr( note, "large" ) )
        self playsound( "fly_bodyfall_large_" + groundtype );
    else if ( issubstr( note, "small" ) )
        self playsound( "fly_bodyfall_small_" + groundtype );
}

notetrackfootstep( note, flagname )
{
    if ( issubstr( note, "left" ) )
        playfootstep( "J_Ball_LE" );
    else
        playfootstep( "J_BALL_RI" );

    if ( !level.clientscripts )
        self playsound( "fly_gear_run" );
}

notetrackfootscrape( note, flagname )
{
    if ( isdefined( self.groundtype ) )
        groundtype = self.groundtype;
    else
        groundtype = "dirt";

    self playsound( "fly_step_scrape_" + groundtype );
}

notetrackland( note, flagname )
{
    if ( isdefined( self.groundtype ) )
        groundtype = self.groundtype;
    else
        groundtype = "dirt";

    self playsound( "fly_land_npc_" + groundtype );
}

handlenotetrack( note, flagname, customfunction, var1 )
{
    if ( isai( self ) && self.isdog )
    {
        if ( handledogsoundnotetracks( note ) )
            return;
    }
    else
    {
        notetrackfunc = anim.notetracks[note];

        if ( isdefined( notetrackfunc ) )
            return [[ notetrackfunc ]]( note, flagname );
    }

    switch ( note )
    {
        case "undefined":
        case "finish":
        case "end":
            if ( isai( self ) && self.a.pose == "back" )
            {

            }

            return note;
        case "swish small":
            self thread play_sound_in_space( "fly_gear_enemy", self gettagorigin( "TAG_WEAPON_RIGHT" ) );
            break;
        case "swish large":
            self thread play_sound_in_space( "fly_gear_enemy_large", self gettagorigin( "TAG_WEAPON_RIGHT" ) );
            break;
        case "no death":
            self.a.nodeath = 1;
            break;
        case "no pain":
            self.allowpain = 0;
            break;
        case "allow pain":
            self.allowpain = 1;
            break;
        case "anim_melee = right":
        case "anim_melee = \"right\"":
            self.a.meleestate = "right";
            break;
        case "anim_melee = left":
        case "anim_melee = \"left\"":
            self.a.meleestate = "left";
            break;
        case "swap taghelmet to tagleft":
            if ( isdefined( self.hatmodel ) )
            {
                if ( isdefined( self.helmetsidemodel ) )
                {
                    self detach( self.helmetsidemodel, "TAG_HELMETSIDE" );
                    self.helmetsidemodel = undefined;
                }

                self detach( self.hatmodel, "" );
                self attach( self.hatmodel, "TAG_WEAPON_LEFT" );
                self.hatmodel = undefined;
            }

            break;
        default:
            if ( isdefined( customfunction ) )
            {
                if ( !isdefined( var1 ) )
                    return [[ customfunction ]]( note );
                else
                    return [[ customfunction ]]( note, var1 );
            }

            break;
    }
}

donotetracks( flagname, customfunction, var1 )
{
    for (;;)
    {
        self waittill( flagname, note );

        if ( !isdefined( note ) )
            note = "undefined";

        val = self handlenotetrack( note, flagname, customfunction, var1 );

        if ( isdefined( val ) )
            return val;
    }
}

donotetracksforeverproc( notetracksfunc, flagname, killstring, customfunction, var1 )
{
    if ( isdefined( killstring ) )
        self endon( killstring );

    self endon( "killanimscript" );

    for (;;)
    {
        time = gettime();
        returnednote = [[ notetracksfunc ]]( flagname, customfunction, var1 );
        timetaken = gettime() - time;

        if ( timetaken < 0.05 )
        {
            time = gettime();
            returnednote = [[ notetracksfunc ]]( flagname, customfunction, var1 );
            timetaken = gettime() - time;

            if ( timetaken < 0.05 )
            {
/#
                println( gettime() + " mapsmpanimscriptsshared::DoNoteTracksForever is trying to cause an infinite loop on anim " + flagname + ", returned " + returnednote + "." );
#/
                wait( 0.05 - timetaken );
            }
        }
    }
}

donotetracksforever( flagname, killstring, customfunction, var1 )
{
    donotetracksforeverproc( ::donotetracks, flagname, killstring, customfunction, var1 );
}

donotetracksfortimeproc( donotetracksforeverfunc, time, flagname, customfunction, ent, var1 )
{
    ent endon( "stop_notetracks" );
    [[ donotetracksforeverfunc ]]( flagname, undefined, customfunction, var1 );
}

donotetracksfortime( time, flagname, customfunction, var1 )
{
    ent = spawnstruct();
    ent thread donotetracksfortimeendnotify( time );
    donotetracksfortimeproc( ::donotetracksforever, time, flagname, customfunction, ent, var1 );
}

donotetracksfortimeendnotify( time )
{
    wait( time );
    self notify( "stop_notetracks" );
}

playfootstep( foot )
{
    if ( !level.clientscripts )
    {
        if ( !isai( self ) )
        {
            self playsound( "fly_step_run_dirt" );
            return;
        }
    }

    groundtype = undefined;

    if ( !isdefined( self.groundtype ) )
    {
        if ( !isdefined( self.lastgroundtype ) )
        {
            if ( !level.clientscripts )
                self playsound( "fly_step_run_dirt" );

            return;
        }

        groundtype = self.lastgroundtype;
    }
    else
    {
        groundtype = self.groundtype;
        self.lastgroundtype = self.groundtype;
    }

    if ( !level.clientscripts )
        self playsound( "fly_step_run_" + groundtype );

    [[ anim.optionalstepeffectfunction ]]( foot, groundtype );
}

playfootstepeffect( foot, groundtype )
{
    if ( level.clientscripts )
        return;

    for ( i = 0; i < anim.optionalstepeffects.size; i++ )
    {
        if ( isdefined( self.fire_footsteps ) && self.fire_footsteps )
            groundtype = "fire";

        if ( groundtype != anim.optionalstepeffects[i] )
            continue;

        org = self gettagorigin( foot );
        playfx( level._effect["step_" + anim.optionalstepeffects[i]], org, org + vectorscale( ( 0, 0, 1 ), 100.0 ) );
        return;
    }
}

movetooriginovertime( origin, time )
{
    self endon( "killanimscript" );

    if ( distancesquared( self.origin, origin ) > 256 && !self maymovetopoint( origin ) )
    {
/#
        println( "^1Warning: AI starting behavior for node at " + origin + " but could not move to that point." );
#/
        return;
    }

    self.keepclaimednodeingoal = 1;
    offset = self.origin - origin;
    frames = int( time * 20 );
    offsetreduction = vectorscale( offset, 1.0 / frames );

    for ( i = 0; i < frames; i++ )
    {
        offset -= offsetreduction;
        self teleport( origin + offset );
        wait 0.05;
    }

    self.keepclaimednodeingoal = 0;
}

returntrue()
{
    return 1;
}
