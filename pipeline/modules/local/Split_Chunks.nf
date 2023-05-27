
    process Split_Chunks {

        //container = ''

        publishDir path : "${params.publishDir}",
                pattern : "*.txt",
                 saveAs : { file -> 
                    if( file.equals("summary.txt") ){
                        "${file}" }
                    else{ 
                        "chunks/${file}" }
                    },
                   mode : "copy",
              overwrite : true

        input:
            path TargetPath
            val  SizeBytes
            val  FileExts

        output:
            path("summary.txt"), emit: Summary
            path("chunk*.txt"),  emit: Chunks

        script:
            """
            # ORIGINAL            
            # extract canonical symlink path
            SOURCE=\$(readlink -f ${TargetPath})

            # calculate disk usage & sort by file size
            TRANSFERS=\$(du -Labc \$SOURCE | sort -k1 -n)


            # NEW
            # extract canonical symlink path & find files with extensions
            CMD="find \$(readlink -f ${TargetPath})"
            
            if [ FILE EXTS]
            IFS=',' read -ra EXTS <<< "${FileExts}"
                for EXT in "\${EXTS[@]}"; do
                    CMD+="-name *.\$EXT -print0"
                done

            # calculate disk usage & sort by file size
            CMD="\$CMD | du -Labc --files0-from=- | sort -k1 -n"

            TRANSFERS=\$(eval \$CMD)

            # set counts
            chunk_size=0 ; chunk_num=0
            total_size=0 ; file_num=0

            size_limit=${SizeBytes}

            while IFS=\$'\t' read -r SIZE PATH; do
                
                # chunk for summary
                CHUNK="NA"

                if [ -f \$PATH ]; then

                    let file_num+=1
                    
                    # calculate updated chunk size
                    chunk_sum=\$((chunk_size + SIZE))
                    
                    # start new chunk; (i) initial file or (ii) current chunk would exceed size limit
                    if [ \$file_num -eq 1 ] || [ \$chunk_sum -gt \$size_limit ]; then
                        let chunk_num+=1
                        chunk_size=0
                    fi
                    
                    CHUNK=\$chunk_num

                    let chunk_size+=\$SIZE
                    let total_size+=\$SIZE

                    # specify current chunk file
                    chunk_file="chunk\${chunk_num}.txt"

                    # append file path to current chunk file
                    echo \$PATH >> \$chunk_file

                fi

                # append du info to summary file
                echo -e "\$SIZE\t\$CHUNK\t\$PATH">> ./summary.txt


            done <<< "\$TRANSFERS"

            """

        }