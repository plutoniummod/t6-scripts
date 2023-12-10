// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include character\clientscripts\c_zom_dlc0_zombie_hazmat_1;
#include character\clientscripts\c_zom_dlc0_zombie_hazmat_2;

main()
{
    switch ( self getcharacterindex() )
    {
        case 0:
            character\clientscripts\c_zom_dlc0_zombie_hazmat_1::main();
            break;
        case 1:
            character\clientscripts\c_zom_dlc0_zombie_hazmat_2::main();
            break;
    }

    self._aitype = "zm_nuked_basic_01";
}

#using_animtree("zm_nuked_basic");

precache( ai_index )
{
    character\clientscripts\c_zom_dlc0_zombie_hazmat_1::precache();
    character\clientscripts\c_zom_dlc0_zombie_hazmat_2::precache();
    usefootsteptable( ai_index, "default_ai" );
    precacheanimstatedef( ai_index, #animtree, "zm_nuked_basic" );
    setdemolockonvalues( ai_index, 100, 60, -15, 60, 30, -5, 60 );
}
