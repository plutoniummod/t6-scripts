// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zm_tomb_amb;

init()
{

}

spawned( localclientnum )
{
    self waittill_dobj( localclientnum );
    level thread clientscripts\mp\zm_tomb_amb::init();
    self thread clientscripts\mp\zm_tomb_amb::start_helicopter_sounds();
}
