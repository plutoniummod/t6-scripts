// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include character\clientscripts\character_sp_zombie_dog;

main()
{
    switch ( self getcharacterindex() )
    {
        case 0:
            character\clientscripts\character_sp_zombie_dog::main();
            break;
        case 1:
            character\clientscripts\character_sp_zombie_dog::main();
            break;
    }

    self._aitype = "zm_nuked_dog";
}

#using_animtree("zm_nuked_dog");

precache( ai_index )
{
    character\clientscripts\character_sp_zombie_dog::precache();
    character\clientscripts\character_sp_zombie_dog::precache();
    usefootsteptable( ai_index, "default_ai" );
    precacheanimstatedef( ai_index, #animtree, "zm_nuked_dog" );
    setdemolockonvalues( ai_index, 100, 8, 0, 60, 8, 0, 60 );
}
