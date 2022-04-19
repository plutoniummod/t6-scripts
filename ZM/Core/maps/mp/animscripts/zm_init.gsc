// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\animscripts\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\animscripts\zm_init;
#include maps\mp\animscripts\zm_shared;

main()
{
    self.a = spawnstruct();
    self.team = level.zombie_team;
    firstinit();
    self.a.pose = "stand";
    self.a.movement = "stop";
    self.a.state = "stop";
    self.a.special = "none";
    self.a.combatendtime = gettime();
    self.a.script = "init";
    self.a.alertness = "casual";
    self.a.lastenemytime = gettime();
    self.a.forced_cover = "none";
    self.a.desired_script = "none";
    self.a.current_script = "none";
    self.a.lookangle = 0;
    self.a.paintime = 0;
    self.a.nextgrenadetrytime = 0;
    self.walk = 0;
    self.sprint = 0;
    self.a.runblendtime = 0.2;
    self.a.flamepaintime = 0;
    self.a.postscriptfunc = undefined;
    self.a.stance = "stand";
    self._animactive = 0;
    self thread deathnotify();
    self.baseaccuracy = self.accuracy;

    if ( !isdefined( self.script_accuracy ) )
        self.script_accuracy = 1;

    self.a.misstime = 0;
    self.a.yawtransition = "none";
    self.a.nodeath = 0;
    self.a.misstime = 0;
    self.a.misstimedebounce = 0;
    self.a.disablepain = 0;
    self.accuracystationarymod = 1;
    self.chatinitialized = 0;
    self.sightpostime = 0;
    self.sightposleft = 1;
    self.precombatrunenabled = 1;
    self.is_zombie = 1;
    self.a.crouchpain = 0;
    self.a.nextstandinghitdying = 0;

    if ( !isdefined( self.script_forcegrenade ) )
        self.script_forcegrenade = 0;
/#
    self.a.lastdebugprint = "";
#/
    self.lastenemysighttime = 0;
    self.combattime = 0;
    self.coveridleselecttime = -696969;
    self.old = spawnstruct();
    self.reacquire_state = 0;
    self.a.allow_shooting = 0;
}

donothing()
{

}

empty( one, two, three, whatever )
{

}

clearenemy()
{
    self notify( "stop waiting for enemy to die" );
    self endon( "stop waiting for enemy to die" );

    self.sightenemy waittill( "death" );

    self.sightpos = undefined;
    self.sighttime = 0;
    self.sightenemy = undefined;
}

deathnotify()
{
    self waittill( "death", other );

    self notify( anim.scriptchange );
}

firstinit()
{
    if ( isdefined( anim.notfirsttime ) )
        return;

    anim.notfirsttime = 1;
    anim.usefacialanims = 0;

    if ( !isdefined( anim.dog_health ) )
        anim.dog_health = 1;

    if ( !isdefined( anim.dog_presstime ) )
        anim.dog_presstime = 350;

    if ( !isdefined( anim.dog_hits_before_kill ) )
        anim.dog_hits_before_kill = 1;

    level.nextgrenadedrop = randomint( 3 );
    level.lastplayersighted = 100;
    anim.defaultexception = maps\mp\animscripts\zm_init::empty;
    setdvar( "scr_expDeathMayMoveCheck", "on" );
    anim.lastsidestepanim = 0;
    anim.meleerange = 64;
    anim.meleerangesq = anim.meleerange * anim.meleerange;
    anim.standrangesq = 262144;
    anim.chargerangesq = 40000;
    anim.chargelongrangesq = 262144;
    anim.aivsaimeleerangesq = 160000;
    anim.combatmemorytimeconst = 10000;
    anim.combatmemorytimerand = 6000;
    anim.scriptchange = "script_change";
    anim.lastgibtime = 0;
    anim.gibdelay = 3000;
    anim.mingibs = 2;
    anim.maxgibs = 4;
    anim.totalgibs = randomintrange( anim.mingibs, anim.maxgibs );
    anim.corner_straight_yaw_limit = 36;

    if ( !isdefined( anim.optionalstepeffectfunction ) )
    {
        anim.optionalstepeffects = [];
        anim.optionalstepeffectfunction = ::empty;
    }

    anim.notetracks = [];
    maps\mp\animscripts\zm_shared::registernotetracks();

    if ( !isdefined( level.flag ) )
    {
        level.flag = [];
        level.flags_lock = [];
    }

    level.painai = undefined;
    anim.maymovecheckenabled = 1;
    anim.badplaces = [];
    anim.badplaceint = 0;
    anim.covercrouchleanpitch = -55;
    anim.lastcarexplosiontime = -100000;
}

onplayerconnect()
{
    player = self;
    firstinit();
    player.invul = 0;
}
