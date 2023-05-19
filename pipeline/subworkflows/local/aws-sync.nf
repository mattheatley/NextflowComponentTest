
/* INFORMATION */

// https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html


/* MODULES IMPORT */

    moduleDir = "../../modules"

    include { 
        Summarize_Disk_Usage as CalcDU;
        AWS_CLI_Sync_Paths    as Sync;
        //AWS_CLI_Sync_Commands as SyncCommands
        } from "${moduleDir}/local/AWS_CLI_Sync"


/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW { 
                
        println "\tSYNCING VIA AWS\n"


        /* setup */

            // check source exists
            assert file(params.source_path).exists(): "Error ~ Source not found; ${params.source_path}"

            // extract source path components
            localROOT = file(params.source_path).getParent()

            // prepare s3 parameters
            def s3Components = [ 
                params.bucket_path,
                params.object_path
                ]

            // strip leading/trailing slashes
            def (s3Bucket, s3Object) = s3Components.collect{ path ->                
                path.replaceAll( '^/+', '' ).replaceAll( '/+$', '' ) }




        /* search source directory */

            // calculate transfer size
            CalcDU(params.source_path)

            CalcDU.out.chunks.flatten().set{ ChunksSize }

            // read lines in chunk file
            ChunksSize.map{ chunk ->

                chunk.splitText( by: 1 ).collect{ line ->  file(line.trim()) }

                }.set{ sgeJobs }

            // show total transfer chunks
            sgeJobs.count().view{ total ->
                "total cluster jobs: ${total}"
                }


        /* execute transfer */

            Sync( 
                sgeJobs,
                Channel.value(s3Bucket),
                Channel.value(s3Object)
                )




        /* search source directory (alt) */

            // split file extensions & strip leading dots
            //FileExt = params.chunk_ext.split(',').collect{ ext -> 
            //    ext.replaceAll( '^\\.+', '' ) }

            // create file extension regex
            //FileRegex = FileExt.collect{ ext -> 
            //    ext.replace( '.', '\\.' ) }.join('|')

            //extension_regex = ~".*\\.(${FileRegex})\$"

            // get all directory contents
            //FilesList = files("${params.source_path}/**")
        
            // convert directory contents to channel
            //Channel.fromList( FilesList ).set{ LocalFiles }


        /* group files by extension */

            //LocalFiles.branch{ source ->

            //    ChunksFiles:
                    // extension matches that of target
            //        source.getName().matches(extension_regex)
            //        return source
                
            //    RemainingFiles: 
            //        true
            //        return source
            
            //    }.set{ Sorted }


        /* group files into chunks */

            // group target files into multiple chunks
            //Sorted.ChunksFiles.collate( 
            //    params.chunk_files, 
            //    ).set{ ChunksFiles }

            // group remaining files into single chunk
            //Sorted.RemainingFiles.collect(
            //    flat : false
            //    ).set{ RemainingFiles }

            // merge channels
            //RemainingFiles.concat( 
            //    ChunksFiles 
            //    ).set{ sgeJobsAlt }

            // show total transfer chunks
            //sgeJobsAlt.count().view{ total ->
            //    "total cluster jobs: ${total}"
            //    }
    

        /* execute transfer */


            /*

            Sync( 
                sgeJobsAlt,
                Channel.value(s3Bucket),
                Channel.value(s3Object)
                )
            */

        /* specify transfer commands */

            /*

            // modulate command to comment if testing
            modulator = params.dry_run ? "#" : ""

            // create collective transfer commands per chunk  
            sgeJobs.map{ chunk ->

                chunk.collect{ localPATH -> 

                    remoteDEST = "s3://${BUCKET}/${OBJECT}/${localPATH.toString().minus(localROOT)}"

                    "\n${modulator}aws s3 --profile ${params.aws_profile} sync ${localPATH} ${remoteDEST}" 
                    
                    }.join() 

                    }.set{ sgeAlt }


            SyncCommands( sgeAlt )

            // shows commands executed
            if (params.dry_run) {

                Sync.out.subscribe{ commands -> 
                    println "\ntransfers executed: ${commands}" }
                
                }

            */

        }
