import java.nio.file.Files


/* SUBWORKFLOW DEFINITION */

    workflow Inputs_Subset {
        
        take:

            Contents
            Settings


        main:

            assert  (Settings.ByteLimit || Settings.FileLimit): "Neither Byte nor File size limits were specified"
            assert !(Settings.ByteLimit && Settings.FileLimit): "Both Byte & File size limits were specified"


            // calculate file sizes & sort; smallest -> largest

            Contents.map{ file ->
                
                long bytes = Files.size(file)

                return [ bytes, file ]

                }.toSortedList{ 
                    first, second -> first[0] <=> second[0] 
                    }.set{ Sorted }


            // subset files into chunks

            Sorted.flatMap{ contents ->

                println "\nSubsetting..."

                ChunksMap = [:]
                
                chunk_bytes = 0
                chunk_files = 0
                files_count = 0
                chunk_count = 0

                contents.each{ bytes, file ->

                    files_count += 1

                    // record expected chunk size
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
                    ChunksMap.containsKey(chunk_count) 
                        ? null 
                        : ChunksMap.putAt( chunk_count, [] )

                    // store file under relevant chunk
                    ChunksMap[chunk_count].add(file)
                
                    }

                println "Done."
                fileSummary  = "${files_count} file${files_count  > 1 ? 's' : ''}"
                chunkSummary = "${chunk_count} chunk${chunk_count > 1 ? 's' : ''}"
                println "\nSubset ${fileSummary} into ${chunkSummary}.\n"


                // stage as channel

                ChunksList = ChunksMap.collect{ key, values ->

                    if ( params.Verbose ){

                        println "chunk ${key} (${values.size()} file${values.size() > 1 ? 's' : ''}):"

                        values.each{ file ->
                            
                            println " - ${file.getName()}" } }
                            
                    return [key, values] }

                }.set{ Chunks }
                

            // record info

            Chunks.collectFile( 
                name:     "summary_chunks.txt",
                storeDir: "${Settings.LogDir}/inputs",
                sort:     true,
                newLine:  true 
                ){ key, files ->

                    files.collect{ file -> 
                        "${key}\t${file}" }.join('\n') }

            Chunks.collectFile( 
                storeDir: "${Settings.LogDir}/inputs/chunks",
                sort:     true,
                newLine:  true 
                ){ key, files ->
                
                    [ "chunk${key}.txt", files.join('\n') ] }


        emit:

            Chunks

    }

