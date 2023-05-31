
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
            ContentsList = files(
                "${Settings.Path}/${Glob}", 
                type:        "file", 
                hidden:      true,
                followLinks: true
                )

            Channel.fromList( ContentsList ).set{ Contents }


        emit:

            Contents

    }

