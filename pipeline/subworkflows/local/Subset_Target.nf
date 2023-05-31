import java.nio.file.Files


/* SUBWORKFLOW DEFINITION */

    workflow Subset_Target {
        
        take:

            Settings
            LogDir


        main:

            assert  (Settings.ByteLimit || Settings.FileLimit): "Neither Byte nor File size limits were specified"
            assert !(Settings.ByteLimit && Settings.FileLimit): "Both Byte & File size limits were specified"

            // prepare search pattern
            Glob = "**"
            
            if ( Settings.FileExt ){

                FileExt = Settings.FileExt.split(',').collect{ ext -> 
                    ext.replaceAll( '^\\.+', '' ) }
                
                Glob += FileExt.size() > 1 ? "{${FileExt.join(',')}}" : FileExt.join(',')

                }

            // import target files
            Contents = files(
                "${Settings.TargetPath}/${Glob}", 
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
            
            chunk_bytes = 0
            chunk_files = 0
            files_count = 0
            chunk_count = 0

            println "\nSubsetting..."

            Contents.each{ bytes, file ->

                files_count += 1

                // calculate cumulative chunk sizes
                cumulative_bytes = chunk_bytes + bytes
                cumulative_files = chunk_files + 1

                // start new chunk &/or reset
                if ( 
                    // initial file 
                    files_count == 1 || 
                    // cumulative chunk bytes exceeds byte limit (bytes limit only)
                    ( Settings.ByteLimit && cumulative_bytes > Settings.ByteLimit) ||
                    // cumulative chunk files exceeds file limit (files limit only)
                    ( Settings.FileLimit && cumulative_files > Settings.FileLimit) ||
                    // cumulative chunk files exceeds max files  (bytes limit only)
                    ( Settings.ByteLimit && cumulative_files > Settings.FilesMax ) ){
                    chunk_count += 1
                    chunk_bytes  = 0
                    chunk_files  = 0
                    }
                
                // record chunk size increase
                chunk_bytes += bytes
                chunk_files += 1

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

                    unit = values.size() > 1 ? 'files' : 'file'

                    println "chunk ${key} (${values.size()} ${unit}):"

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

