/* PROCESS CHUNK OF PATHS */

    process Process_Chunk {
        
        debug true

        input:
        
            tuple   val  (Chunk), 
                    path (Files, stageAs: "partition???/*" )
                    // N.B. seperate partitions stage duplicated basenames
        
        output:

            tuple   val  (Chunk), 
                    path (Files)


        script:

            // stage single paths as lists
            Files  = Files instanceof List 
                ?   Files 
                : [ Files ]

            // stage paths neatly for array
            Staged = Files.collect{ file -> "\"${file}\""}.join('\n') 

            "STAGED=(\n${Staged}\n)"+"""

            CHUNK="chunk${Chunk}.txt"

            echo "Chunk: ${Chunk}"; touch \$CHUNK

            for LINK in "\${STAGED[@]}"; do 

                echo "StagedAs: \$LINK"
                echo "ReadLink: \$(readlink -f \$LINK)"
                echo -e "\$LINK\t\$(readlink -f \$LINK)" >> \$CHUNK
                echo


            done
            
            """.stripIndent()
    
        }
