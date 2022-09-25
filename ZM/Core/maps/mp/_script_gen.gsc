// T6 GSC SOURCE
// Decompiled by https://github.com/xensik/gsc-tool
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\_script_gen;

script_gen_dump_checksaved()
{
    signatures = getarraykeys( level.script_gen_dump );

    for ( i = 0; i < signatures.size; i++ )
    {
        if ( !isdefined( level.script_gen_dump2[signatures[i]] ) )
        {
            level.script_gen_dump[signatures[i]] = undefined;
            level.script_gen_dump_reasons[level.script_gen_dump_reasons.size] = "Signature unmatched( removed feature ): " + signatures[i];
        }
    }
}

script_gen_dump()
{
/#
    script_gen_dump_checksaved();

    if ( !level.script_gen_dump_reasons.size )
    {
        flag_set( "scriptgen_done" );
        return;
    }

    firstrun = 0;

    if ( level.bscriptgened )
    {
        println( " " );
        println( " " );
        println( " " );
        println( "^2 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
        println( "^3Dumping scriptgen dump for these reasons" );
        println( "^2 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );

        for ( i = 0; i < level.script_gen_dump_reasons.size; i++ )
        {
            if ( issubstr( level.script_gen_dump_reasons[i], "nowrite" ) )
            {
                substr = getsubstr( level.script_gen_dump_reasons[i], 15 );
                println( i + ". ) " + substr );
            }
            else
                println( i + ". ) " + level.script_gen_dump_reasons[i] );

            if ( level.script_gen_dump_reasons[i] == "First run" )
                firstrun = 1;
        }

        println( "^2 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
        println( " " );

        if ( firstrun )
        {
            println( "for First Run make sure you delete all of the vehicle precache script calls, createart calls, createfx calls( most commonly placed in maps\\" + level.script + "_fx.gsc ) " );
            println( " " );
            println( "replace:" );
            println( "maps\\_load::main( 1 );" );
            println( " " );
            println( "with( don't forget to add this file to P4 ):" );
            println( "maps\\scriptgen\\" + level.script + "_scriptgen::main();" );
            println( " " );
        }

        println( "^2 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
        println( " " );
        println( "^2 / \\ / \\ / \\" );
        println( "^2scroll up" );
        println( "^2 / \\ / \\ / \\" );
        println( " " );
    }
    else
        return;

    filename = "scriptgen/" + level.script + "_scriptgen.gsc";
    csvfilename = "zone_source/" + level.script + ".csv";

    if ( level.bscriptgened )
        file = openfile( filename, "write" );
    else
        file = 0;

    assert( file != -1, "File not writeable( check it and and restart the map ): " + filename );
    script_gen_dumpprintln( file, "// script generated script do not write your own script here it will go away if you do." );
    script_gen_dumpprintln( file, "main()" );
    script_gen_dumpprintln( file, "{" );
    script_gen_dumpprintln( file, "" );
    script_gen_dumpprintln( file, "\\tlevel.script_gen_dump = [];" );
    script_gen_dumpprintln( file, "" );
    signatures = getarraykeys( level.script_gen_dump );

    for ( i = 0; i < signatures.size; i++ )
    {
        if ( !issubstr( level.script_gen_dump[signatures[i]], "nowrite" ) )
            script_gen_dumpprintln( file, "\\t" + level.script_gen_dump[signatures[i]] );
    }

    for ( i = 0; i < signatures.size; i++ )
    {
        if ( !issubstr( level.script_gen_dump[signatures[i]], "nowrite" ) )
        {
            script_gen_dumpprintln( file, "\\tlevel.script_gen_dump[ " + "\"" + signatures[i] + "\"" + " ] = " + "\"" + signatures[i] + "\"" + ";" );
            continue;
        }

        script_gen_dumpprintln( file, "\\tlevel.script_gen_dump[ " + "\"" + signatures[i] + "\"" + " ] = " + "\"nowrite\"" + ";" );
    }

    script_gen_dumpprintln( file, "" );
    keys1 = undefined;
    keys2 = undefined;

    if ( isdefined( level.sg_precacheanims ) )
        keys1 = getarraykeys( level.sg_precacheanims );

    if ( isdefined( keys1 ) )
    {
        for ( i = 0; i < keys1.size; i++ )
            script_gen_dumpprintln( file, "\\tanim_precach_" + keys1[i] + "();" );
    }

    script_gen_dumpprintln( file, "\\tmaps\\_load::main( 1, " + level.bcsvgened + ", 1 );" );
    script_gen_dumpprintln( file, "}" );
    script_gen_dumpprintln( file, "" );

    if ( isdefined( level.sg_precacheanims ) )
        keys1 = getarraykeys( level.sg_precacheanims );

    if ( isdefined( keys1 ) )
    {
        for ( i = 0; i < keys1.size; i++ )
        {
            script_gen_dumpprintln( file, "#using_animtree( \"" + keys1[i] + "\" );" );
            script_gen_dumpprintln( file, "anim_precach_" + keys1[i] + "()" );
            script_gen_dumpprintln( file, "{" );
            script_gen_dumpprintln( file, "\\tlevel.sg_animtree[ \"" + keys1[i] + "\" ] = #animtree;" );
            keys2 = getarraykeys( level.sg_precacheanims[keys1[i]] );

            if ( isdefined( keys2 ) )
            {
                for ( j = 0; j < keys2.size; j++ )
                    script_gen_dumpprintln( file, "\\tlevel.sg_anim[ \"" + keys2[j] + "\" ] = %" + keys2[j] + ";" );
            }

            script_gen_dumpprintln( file, "}" );
            script_gen_dumpprintln( file, "" );
        }
    }

    if ( level.bscriptgened )
        saved = closefile( file );
    else
        saved = 1;

    if ( level.bcsvgened )
        csvfile = openfile( csvfilename, "write" );
    else
        csvfile = 0;

    assert( csvfile != -1, "File not writeable( check it and and restart the map ): " + csvfilename );
    signatures = getarraykeys( level.script_gen_dump );

    for ( i = 0; i < signatures.size; i++ )
        script_gen_csvdumpprintln( csvfile, signatures[i] );

    if ( level.bcsvgened )
        csvfilesaved = closefile( csvfile );
    else
        csvfilesaved = 1;

    assert( csvfilesaved == 1, "csv not saved( see above message? ): " + csvfilename );
    assert( saved == 1, "map not saved( see above message? ): " + filename );
#/
    assert( !level.bscriptgened, "SCRIPTGEN generated: follow instructions listed above this error in the console" );

    if ( level.bscriptgened )
    {
/#
        assertmsg( "SCRIPTGEN updated: Rebuild fast file and run map again" );
#/
    }

    flag_set( "scriptgen_done" );
}

script_gen_csvdumpprintln( file, signature )
{
    prefix = undefined;
    writtenprefix = undefined;
    path = "";
    extension = "";

    if ( issubstr( signature, "ignore" ) )
        prefix = "ignore";
    else if ( issubstr( signature, "col_map_sp" ) )
        prefix = "col_map_sp";
    else if ( issubstr( signature, "gfx_map" ) )
        prefix = "gfx_map";
    else if ( issubstr( signature, "rawfile" ) )
        prefix = "rawfile";
    else if ( issubstr( signature, "sound" ) )
        prefix = "sound";
    else if ( issubstr( signature, "xmodel" ) )
        prefix = "xmodel";
    else if ( issubstr( signature, "xanim" ) )
        prefix = "xanim";
    else if ( issubstr( signature, "item" ) )
    {
        prefix = "item";
        writtenprefix = "weapon";
        path = "sp/";
    }
    else if ( issubstr( signature, "fx" ) )
        prefix = "fx";
    else if ( issubstr( signature, "menu" ) )
    {
        prefix = "menu";
        writtenprefix = "menufile";
        path = "ui / scriptmenus/";
        extension = ".menu";
    }
    else if ( issubstr( signature, "rumble" ) )
    {
        prefix = "rumble";
        writtenprefix = "rawfile";
        path = "rumble/";
    }
    else if ( issubstr( signature, "shader" ) )
    {
        prefix = "shader";
        writtenprefix = "material";
    }
    else if ( issubstr( signature, "shock" ) )
    {
        prefix = "shock";
        writtenprefix = "rawfile";
        extension = ".shock";
        path = "shock/";
    }
    else if ( issubstr( signature, "string" ) )
    {
        prefix = "string";
/#
        assertmsg( "string not yet supported by scriptgen" );
#/
    }
    else if ( issubstr( signature, "turret" ) )
    {
        prefix = "turret";
        writtenprefix = "weapon";
        path = "sp/";
    }
    else if ( issubstr( signature, "vehicle" ) )
    {
        prefix = "vehicle";
        writtenprefix = "rawfile";
        path = "vehicles/";
    }

    if ( !isdefined( prefix ) )
        return;

    if ( !isdefined( writtenprefix ) )
        string = prefix + ", " + getsubstr( signature, prefix.size + 1, signature.size );
    else
        string = writtenprefix + ", " + path + getsubstr( signature, prefix.size + 1, signature.size ) + extension;
/#
    if ( file == -1 || !level.bcsvgened )
        println( string );
    else
        fprintln( file, string );
#/
}

script_gen_dumpprintln( file, string )
{
/#
    if ( file == -1 || !level.bscriptgened )
        println( string );
    else
        fprintln( file, string );
#/
}
