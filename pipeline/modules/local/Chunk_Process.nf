/* PROCESS CHUNK OF PATHS */

    process Process_Chunk {
        
        tag "chunk${Chunk}"

        debug params.Verbose ?: false

        publishDir path : "${params.publishDir}/process",
                pattern : "*.{txt,md5}",
                 saveAs : { path -> 
                    subDir = path.endsWith(".md5") 
                        ? "md5" 
                        : "info"
                    "${subDir}/${file(path).getName()}" 
                    },
                   mode : "copy",
              overwrite : true

        input:
        
            tuple   val  (Chunk), 
                    path (Files, stageAs: "partition*/*" )
                    // N.B. partitions permit duplicated basenames by staging seperately
            val     MD5Sum
        
        output:

            tuple   val  (Chunk), 
                    path ("partition*/output_*"), emit: Chunks
            path    "chunk*.txt",                 emit: Info
            path    "chunk*.md5", optional: true, emit: MD5s


        script:

            // stage single paths as lists
            Files  = Files instanceof List 
                ?   Files 
                : [ Files ]

            // stage paths neatly for array
            Staged = Files.collect{ file -> "\"${file}\""}.join('\n') 

            "STAGED=(\n${Staged}\n)"+"""

            CHUNK="chunk${Chunk}"
            rm -f \$CHUNK*

            if [ "${MD5Sum == true ?: ''}" ]; then
                echo "*** Calculating MD5s ***"
            fi 

            # cycle inputs...
            for IDX in "\${!STAGED[@]}"; do 
                
                # extract info
                LINK="\${STAGED[\$IDX]}"
                READLINK="\$(readlink -f \$LINK)"

                # log current
                echo "Chunk ${Chunk} File \$((\$IDX+1)) of \${#STAGED[@]}"
                echo "StagedAs: \$LINK"
                echo "ReadLink: \$(readlink -f \$LINK)"                
                echo -e "\$LINK\t\$READLINK" >> \$CHUNK.txt

                # execute process...
                PARTITION="\$(dirname \$LINK)"
                INPUT="\$(basename \$LINK)"
                OUTPUT="output_\${CHUNK}\${PARTITION}"
                echo "PROCESSED \$LINK" > \$PARTITION/\$OUTPUT.txt

                # calculate md5 (as required)
                if [ "${MD5Sum == true ?: ''}" ]; then
                    echo "\$(md5sum \$READLINK)" >> \$CHUNK.md5
                fi 

            done
            
            """.stripIndent()
    
        }
