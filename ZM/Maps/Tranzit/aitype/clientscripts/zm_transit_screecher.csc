// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include character\clientscripts\c_zom_screecher;

main()
{
    character\clientscripts\c_zom_screecher::main();
    self._aitype = "zm_transit_screecher";
}

#using_animtree("zm_transit_screecher");

precache( ai_index )
{
    character\clientscripts\c_zom_screecher::precache();
    usefootsteptable( ai_index, "default_ai" );
    precacheanimstatedef( ai_index, #animtree, "zm_transit_screecher" );
    setdemolockonvalues( ai_index, 100, 18, 0, 60, 8, 0, 60 );
}
