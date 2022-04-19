// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

main()
{
    self setmodel( "german_shepherd" );
    self.voice = "american";
    self.skeleton = "base";
}

precache()
{
    precachemodel( "german_shepherd" );
}
