
/* SUBWORKFLOW DEFINITION */

    workflow Inputs_Find {
        
        take:

            Settings


        main:

            // prepare search pattern
            
            Glob = "**"
            
            if ( Settings.FileExt ){

                FileExt = Settings.FileExt.split(',').collect{ ext -> 
                    ext.replaceAll( '^\\.+', '' ) }
                
                Glob += FileExt.size() > 1 ? "{${FileExt.join(',')}}" : FileExt.join(',')

                }


            // import target files

            assert file(Settings.Path).exists(): "Path not found; ${Settings.Path}"

            ContentsList = files(
                "${Settings.Path}/${Glob}", 
                type:        "file", 
                hidden:      true,
                followLinks: true
                )

            assert ContentsList.size() > 0: "Files not found; ${Settings.Path}"


            // stage as channel

            Channel.fromList( ContentsList ).set{ Contents }


            // record info
            
            Contents.collectFile( 
                name:     "summary_inputs.txt",
                storeDir: "${Settings.LogDir}/inputs",
                sort:     true,
                newLine:  true 
                ){ file -> "${file}" }


        emit:

            Contents

    }

