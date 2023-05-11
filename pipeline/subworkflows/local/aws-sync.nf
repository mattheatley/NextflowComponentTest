
/* INFORMATION */

// https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html


/* MODULES IMPORT */

    moduleDir = "../../modules"

    include { 
        AWS_CLI_Sync_Commands as Sync_Commands; 
        AWS_CLI_Sync_Paths as Sync_Paths  
        } from "${moduleDir}/local/AWS_CLI_Sync"


/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW { 
                
        println "\tSYNCING VIA AWS\n"


        /* search source directory */

            // extract source path components
            SourcePath   = file(params.source_path)
            SourceTarget = SourcePath.getName()
            SourceParent = SourcePath.getParent()

            // get all directory contents
            FilesList = files("${params.source_path}/**")
        
            // convert directory contents to channel
            Channel.fromList( FilesList ).set{ SourceContents }


        /* group files by extension */

            SourceContents.branch{ source ->

                Chunks:
                    // extension matches that of target
                    source.getName().matches(".*\\.(${params.target_ext})\$")
                    return source
                
                Remaining: 
                    true
                    return source
            
                }.set{ Contents }


        /* group files into chunks */

            // group target files into multiple chunks
            Contents.Chunks.collate( 
                params.chunk_size, 
                ).set{ Chunks }

            // group remaining files into single chunk
            Contents.Remaining.collect(
                flat : false
                ).set{ Remaining }

            // merge channels
            Remaining.concat( 
                Chunks 
                ).set{ BatchPaths }


        /* specify transfer commands */

            // modulate command to comment if testing
            modulator = params.dry_run ? "#" : ""

            // create collective transfer commands per chunk  
            BatchPaths.map{ chunk ->

                chunk.collect{ source -> 

                    destination = "s3://${params.bucket_path}${source.toString().minus(SourceParent)}"

                    "\n${modulator}aws s3 --profile ${params.aws_profile} sync ${source} ${destination}" 
                    
                    }.join() 

                    }.set{ BatchCommands }


        /* execute transfer */

            Sync_Paths( BatchPaths )

            //Sync_Commands( BatchCommands )

            // shows commands executed
            //if (params.dry_run) {

            //    Sync.out.subscribe{ commands -> 
            //        println "\ntransfers executed: ${commands}" }
                
            //    }

        }
