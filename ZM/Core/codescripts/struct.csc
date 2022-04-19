// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool

initstructs()
{
    level.struct = [];
}

createstruct()
{
    struct = spawnstruct();
    level.struct[level.struct.size] = struct;
    return struct;
}

findstruct( position )
{
    for ( i = 0; i < level.struct.size; i++ )
    {
        if ( distancesquared( level.struct[i].origin, position ) < 1 )
            return level.struct[i];
    }

    return undefined;
}
