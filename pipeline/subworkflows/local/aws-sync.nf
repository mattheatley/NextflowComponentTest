
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

            // split file extensions & strip leading dots
            FileExt = params.chunk_ext.split(',').collect{ ext -> 
                ext.replaceAll( '^\\.+', '' ) }

            // create file extension regex
            FileRegex = FileExt.collect{ ext -> 
                ext.replace( '.', '\\.' ) }.join('|')

            extension_regex = ~".*\\.(${FileRegex})\$"




        /* search source directory */

            // calculate transfer size
            CalcDU(params.source_path)

            CalcDU.out.summary.view{ "summary: ${it}"}
            CalcDU.out.chunks.view{ "chunk: ${it}"}


            // get all directory contents
            FilesList = files("${params.source_path}/**")
        
            // convert directory contents to channel
            Channel.fromList( FilesList ).set{ LocalFiles }


        /* group files by extension */

            LocalFiles.branch{ source ->

                Chunks:
                    // extension matches that of target
                    source.getName().matches(extension_regex)
                    return source
                
                Remaining: 
                    true
                    return source
            
                }.set{ Sorted }


        /* group files into chunks */

            // group target files into multiple chunks
            Sorted.Chunks.collate( 
                params.chunk_files, 
                ).set{ Chunks }

            // group remaining files into single chunk
            Sorted.Remaining.collect(
                flat : false
                ).set{ Remaining }

            // merge channels
            Remaining.concat( 
                Chunks 
                ).set{ sgeJobs }

            sgeJobs.count().view{ total ->
                "total cluster jobs: ${total}"
                }


        /* execute transfer */


            /*

            Sync( 
                sgeJobs,
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
