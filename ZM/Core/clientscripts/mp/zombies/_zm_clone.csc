// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\_fx;
#include clientscripts\mp\zombies\_zm_utility;

init()
{
    init_mover_tree();
}

#using_animtree("zm_ally");

init_mover_tree()
{
    scriptmodelsuseanimtree( #animtree );
}
