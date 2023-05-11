
/* INFORMATION */

// https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html


/* MODULES IMPORT */

    moduleDir = "../../modules"

    include { AWS_CLI_Sync as Sync } from "${moduleDir}/local/AWS_CLI_Sync"


/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW { 
                
        println "\tSYNCING VIA AWS\n"


        /* search source directory */

            // extract source path components
            SourcePath = file(params.source_path)
            SourceBasename = SourcePath.getName()
            SourceParent   = SourcePath.getParent()

            // get all directory contents
            FilesList = files("${params.source_path}/**")
        
            // convert directory contents to channel
            Channel.fromList( FilesList ).set{ SourceContents }


        /* group files by extension */

            SourceContents.branch{ source ->

                Target:   
                    source.getName().matches(".*\\.(${params.target_ext})\$")
                    return source
                
                Other: 
                    true
                    return source
            
                }.set{ Contents }


        /* group files into chunks */

            // group target files into multiple chunks
            Contents.Target.collate( 
                params.chunk_size, 
                ).set{ TargetChunks }

            // group remaining files into single chunk
            Contents.Other.collect(
                flat : false
                ).set{ OtherChunks }

            // merge channels
            OtherChunks.concat( 
                TargetChunks 
                ).set{ TotalChunks }


        /* specify transfer commands */

            // modulate command to comment if testing
            modulator = params.test_run ? "#" : ""

            // create collective transfer commands per chunk  
            TotalChunks.map{ chunk ->

                chunk.collect{ source -> 

                    destination = "s3://${params.bucket_path}${source.toString().minus(SourceParent)}"

                    "\n${modulator}aws s3 --profile ${params.aws_profile} sync ${source} ${destination}" 
                    
                    }.join() 

                    }.set{ TransferCommands }


        /* execute transfer */

            Sync( TransferCommands )

            Sync.out.subscribe{ commands -> 
                "executed: ${commands}"}

        }
