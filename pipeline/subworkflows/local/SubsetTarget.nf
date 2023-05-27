import java.nio.file.Files


/* SUBWORKFLOW DEFINITION */

    workflow Subset_Target {
        
        take:

            Input
            LogDir


        main:

            assert  (Input.ByteLimit || Input.FileLimit): "Neither Byte nor File size limits were specified"
            assert !(Input.ByteLimit && Input.FileLimit): "Both Byte & File size limits were specified"

            // prepare search pattern
            Glob = "**"
            
            if ( Input.FileExt ){

                FileExt = Input.FileExt.split(',').collect{ ext -> 
                    ext.replaceAll( '^\\.+', '' ) }
                
                Glob += FileExt.size() > 1 ? "{${FileExt.join(',')}}" : FileExt.join(',')

                }

            // import target files
            Contents = files(
                "${Input.TargetPath}/${Glob}", 
                type:        "file", 
                hidden:      true,
                followLinks: true
                )

            // calculate file sizes
            Contents = Contents.collect{ file ->
                
                long bytes = Files.size(file)

                return [ bytes, file ]

                // sort sublists by size; smallest -> largest
                }.sort{ first, second -> first[0] <=> second[0] }


            // subset files into chunks
            ChunkMap = [:]

            SizeLimit = Input.ByteLimit ?: Input.FileLimit

            chunk_size  = 0
            files_count = 0
            chunk_count = 0

            println "\nSubsetting..."

            Contents.each{ bytes, file ->

                files_count += 1

                // specify relevant size increment
                size_increment = Input.ByteLimit ? bytes : 1

                cumulative_size = chunk_size + size_increment

                // start new chunk & reset; (i) initial file or (ii) cumulative chunk size would exceed limit
                if ( files_count == 1 || cumulative_size > SizeLimit ){
                    chunk_count += 1
                    chunk_size   = 0
                    }
                // record chunk size increase
                chunk_size += size_increment

                // create list under relevant chunk as required
                ChunkMap.containsKey(chunk_count) ? null : ChunkMap.putAt( chunk_count, [] )

                // store file under relevant chunk
                ChunkMap[chunk_count].add(file)
                
                }

            println "Done."
            fileSummary  = "${files_count} ${files_count > 1 ? 'files'  : 'file'}"
            chunkSummary = "${chunk_count} ${chunk_count > 1 ? 'chunks' : 'chunk'}"
            println "\nSubset ${fileSummary} into ${chunkSummary}.\n"


            // stage chunks
            ChunkList = ChunkMap.collect{ key, values ->

                if ( params.Verbose ){

                    println "chunk ${key} (${values.size()} ${values.size() > 1 ? 'files' : 'file'}):"

                    values.each{ file ->
                        
                        println " - ${file.getName()}" } }
                        
                return [key, values] }

            Channel.fromList( ChunkList ).set{ Chunks }


            // store chunk info
            Chunks.collectFile( 
                name:     "summary.txt",
                storeDir: "${LogDir}/chunks",
                sort:     true,
                newLine:  true 
                ){ key, files ->

                    files.collect{ file -> 
                        "${key}\t${file}" }.join('\n') }

            Chunks.collectFile( 
                storeDir: "${LogDir}/chunks",
                sort:     true,
                newLine:  true 
                ){ key, files ->
                
                    [ "chunk${key}.txt", files.join('\n') ] }


        emit:

            Chunks

    }

