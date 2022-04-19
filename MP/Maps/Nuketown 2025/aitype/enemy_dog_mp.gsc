// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include character\character_mp_german_shepherd;

main()
{
    self.accuracy = 1;
    self.animstatedef = "";
    self.animtree = "dog.atr";
    self.csvinclude = "";
    self.demolockonhighlightdistance = 100;
    self.demolockonviewheightoffset1 = 8;
    self.demolockonviewheightoffset2 = 8;
    self.demolockonviewpitchmax1 = 60;
    self.demolockonviewpitchmax2 = 60;
    self.demolockonviewpitchmin1 = 0;
    self.demolockonviewpitchmin2 = 0;
    self.footstepfxtable = "";
    self.footstepprepend = "";
    self.footstepscriptcallback = 0;
    self.grenadeammo = 0;
    self.grenadeweapon = "";
    self.health = 200;
    self.precachescript = "";
    self.secondaryweapon = "";
    self.sidearm = "";
    self.subclass = "regular";
    self.team = "axis";
    self.type = "dog";
    self.weapon = "";
    self setengagementmindist( 0.0, 0.0 );
    self setengagementmaxdist( 100.0, 300.0 );
    character\character_mp_german_shepherd::main();
    self setcharacterindex( 0 );
}

spawner()
{
    self setspawnerteam( "axis" );
}

precache( ai_index )
{
    character\character_mp_german_shepherd::precache();
}
