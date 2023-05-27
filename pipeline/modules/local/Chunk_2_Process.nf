/* PROCESS CHUNK OF PATHS */

    process Process_Chunk {
        
        debug params.Verbose ?: false

        publishDir path : "${params.publishDir}/process",
                pattern : "*.{txt,md5}",
                 saveAs : { path -> 
                    subDir = path.endsWith(".md5") ? "md5" : "info"
                    "${subDir}/${file(path).getName()}" },
                   mode : "copy",
              overwrite : true

        input:
        
            tuple   val  (Chunk), 
                    path (Files, stageAs: "partition???/*" )
                    // N.B. partitions stage any duplicated basenames seperate
            val     MD5
        
        output:

            tuple   val  (Chunk), 
                    path (Files),            emit: Chunks
            path    "*.txt",                 emit: Info
            path    "*.md5", optional: true, emit: MD5s


        script:

            // stage single paths as lists
            Files  = Files instanceof List 
                ?   Files 
                : [ Files ]

            // stage paths neatly for array
            Staged = Files.collect{ file -> "\"${file}\""}.join('\n') 

            "STAGED=(\n${Staged}\n)"+"""

            CHUNK="chunk${Chunk}.txt"

            > \$CHUNK.md5
            if [ "${MD5 ?: ''}" ]; then
                > \$CHUNK.md5
            fi 

            for IDX in "\${!STAGED[@]}"; do 
                
                LINK="\${STAGED[\$IDX]}"
                READLINK="\$(readlink -f \$LINK)"

                echo "Chunk ${Chunk} File \$((\$IDX+1)) of \${#STAGED[@]}"
                echo "StagedAs: \$LINK"
                echo "ReadLink: \$(readlink -f \$LINK)"
                
                echo -e "\$LINK\t\$READLINK" >> \$CHUNK                
                if [ "${MD5 ?: ''}" ]; then
                    echo "\$(md5sum \$READLINK)" >> \$CHUNK.md5
                fi 

            done
            
            """.stripIndent()
    
        }
