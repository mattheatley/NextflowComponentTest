
/* MODULE DEFINITION */


    /* TARBALL */

        process tarProcess {
            
                tag "${InputPath.getName()}"
                publishDir path : params.tarDir,
                        pattern : "${OutputPath}",
                           mode : "copy",
                      overwrite : true
                debug params.DEBUG

            input:
                
                tuple   path(InputPath), 
                        val(OutputPath)
                
                tuple   val(Flags), 
                        val(Archive), 
                        val(Extract)

            output:
                // to publish
                path    OutputPath, 
                        emit: tarOutput
                // to move
                path    InputPath,  
                        emit: tarInput

            script:
                if( Archive.equals(true) ) {
                    """
                    tar -${Flags} \\
                    ${OutputPath} \\
                    ${InputPath}
                    """ }
                else if( Extract.equals(true) ) {
                    """
                    tar -${Flags} \\
                    ${InputPath}
                    """}
            } 


    /* MOVE */

        process mvProcess {

            input:
                path(InputPath)

            output:
                stdout emit: mvStdout

            script:
                """
                mv \\
                \$(readlink ${InputPath}) \\
                ${mvDir}/${InputPath}
                """
            } 



/* SUBWORKFLOW DEFINITION */

    workflow SUBWORKFLOW {


        /* tar setup */

            def ( ModeArchive, ModeExtract, _ ) = tarModes = [ "c", "x" ]
            assert tarModes.contains( params.tarMode )

            // follow symlinks
            drefMode = ( params.tarMode == ModeArchive ) 
                ? "h"
                : ""

            // compress archive
            gzipMode = ( params.tarMode == ModeArchive && params.tarZ )
                ? "z"
                : ""

            tarFlags = "${params.tarMode}${drefMode}${gzipMode}vf"

            processArchive = params.tarMode.equals(ModeArchive)

            processExtract = params.tarMode.equals(ModeExtract)

            tarOptions = channel.value( tuple( tarFlags, processArchive, processExtract ) )


        /* input setup */

            assert file(params.InputDir).exists()

            def (TypeFile, TypeDir, TypeAny) = InputTypes = [ "file", "dir", "any" ]
            assert InputTypes.contains( params.InputType )

            InputGlob  = ( params.tarMode.equals(ModeArchive) ) 
                ? params.InputGlob
                : "*{.tar,tar.gz}"

            InputFiles = files(
                "${params.InputDir}/${InputGlob}", 
                         glob : true,
                         type : params.InputType,
                       hidden : false,
                checkIfExists : true, )
            assert !InputFiles.isEmpty()


        /* output setup */

            tarSubDir = ( params.tarMode == ModeArchive ) 
                ? "Archived"
                : "Extracted"

            params.tarDir = "${params.InputDir}/${tarSubDir}"

            gzipExt = ( params.tarMode.equals(ModeArchive) && params.tarZ ) 
                ? ".gz"
                : ""

            OutputExt = ( params.tarMode.equals(ModeArchive) ) 
                ? ".tar${gzipExt}"
                : ""

            // modify file extensions
            tarChannel = Channel.fromList( InputFiles ).map(
                // avoids using getSimpleName(); trims file extensions too aggressively
                { PathObj -> 

                    InputBaseName = PathObj.getName()

                    if ( params.tarMode.equals(ModeArchive) ){
                        TrimIdx=0 }
                    else if ( params.tarMode.equals(ModeExtract) && InputBaseName.endsWith('.tar')    ){
                        TrimIdx=4 }
                    else if ( params.tarMode.equals(ModeExtract) && InputBaseName.endsWith('.tar.gz') ){
                        TrimIdx=7 }
                    // remove tar suffixes  (extract only)
                    OutputBaseName  = InputBaseName.substring(0, InputBaseName.length()-TrimIdx)
                    // include tar suffixes (archive only)
                    OutputBaseName += OutputExt
                    
                tuple(PathObj, OutputBaseName) })

            if (params.mvInputs){

                mvDir  = "${params.InputDir}/done"

                file(mvDir).mkdirs() }


        /* tarball inputs */

            tarProcess(
                tarChannel,
                tarOptions )


        /* move inputs */

            if (params.mvInputs){
                
                mvProcess(tarProcess.out.tarInput) }

    }
