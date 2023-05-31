
/* SUBWORKFLOW DEFINITION */

    workflow Inputs_Find {
        
        take:

            Settings


        main:

            assert file(Settings.Path).exists(): "Path not found; ${Settings.Path}"

            // prepare search pattern
            Glob = "**"
            
            if ( Settings.FileExt ){

                FileExt = Settings.FileExt.split(',').collect{ ext -> 
                    ext.replaceAll( '^\\.+', '' ) }
                
                Glob += FileExt.size() > 1 ? "{${FileExt.join(',')}}" : FileExt.join(',')

                }

            // import target files
            ContentsList = files(
                "${Settings.Path}/${Glob}", 
                type:        "file", 
                hidden:      true,
                followLinks: true
                )

            assert ContentsList.size() > 0: "Files not found; ${Settings.Path}"


            Channel.fromList( ContentsList ).set{ Contents }


            // store chunk info
            Contents.collectFile( 
                name:     "summary_inputs.txt",
                storeDir: "${Settings.LogDir}/inputs",
                sort:     true,
                newLine:  true 
                ){ file -> "${file}" }


        emit:

            Contents

    }

