// T6 GSC SOURCE
// Generated by https://github.com/xensik/gsc-tool
#include clientscripts\mp\_utility;

initflamefx()
{

}

corpseflamefx( localclientnum )
{
    self waittill_dobj( localclientnum );

    if ( !isdefined( level._effect["character_fire_death_torso"] ) )
        initflamefx();

    tagarray = [];
    tagarray[tagarray.size] = "J_Wrist_RI";
    tagarray[tagarray.size] = "J_Wrist_LE";
    tagarray[tagarray.size] = "J_Elbow_LE";
    tagarray[tagarray.size] = "J_Elbow_RI";
    tagarray[tagarray.size] = "J_Knee_RI";
    tagarray[tagarray.size] = "J_Knee_LE";
    tagarray[tagarray.size] = "J_Ankle_RI";
    tagarray[tagarray.size] = "J_Ankle_LE";

    if ( isdefined( level._effect["character_fire_death_sm"] ) )
    {
        for ( arrayindex = 0; arrayindex < tagarray.size; arrayindex++ )
            playfxontag( localclientnum, level._effect["character_fire_death_sm"], self, tagarray[arrayindex] );
    }

    playfxontag( localclientnum, level._effect["character_fire_death_torso"], self, "J_SpineLower" );
}
