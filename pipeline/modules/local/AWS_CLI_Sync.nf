/* LOCAL DU CHECK */

    process Summarize_Disk_Usage {

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
            path(source)

        output:
            path("summary.txt"), emit: summary
            path("chunk*.txt"),  emit: chunks

        script:
            """
            # extract canonical symlink path
            SOURCE=\$(readlink -f ${source})

            # calculate disk usage & sort by file size
            TRANSFERS=\$(du -Labc \$SOURCE | sort -k1 -n)

            chunk_size=0 ; chunk_num=0
            total_size=0 ; file_num=0

            size_limit=${params.chunk_size}

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


/* AWS S3 SYNC UPLOAD */

    process AWS_CLI_Sync_Commands {

        //container = ''

        input:
            val(commands)

        output:
            val(commands)

        script:
            """
            # transfer files
            ${commands}
            """

        }

    process AWS_CLI_Sync_Paths {

        //container = ''

        input:
            path(files)
            val(s3bucket)
            val(s3object)

        output:
            path(files)

        script:
            modulator = params.dry_run ? "#" : ""
            localROOT = file(params.source_path).getParent()
            """
            # convert input to array
            LINKS=( ${files.join(" ")} )

            echo "localROOT: ${localROOT}"

            # cycle through array
            for LINK in \${LINKS[@]}; do

                echo

                # extract canonical symlink path
                localPATH=\$(readlink -f \${LINK})

                # strip localROOT/ from localPATH prefix
                localTREE=\$(echo \${localPATH} | sed 's+${localROOT}/++')

                # extract directory[/subdirectory] components
                localSTEM=\$(dirname \$localTREE)

                # extract basename components
                localLEAF=\$(basename \$localTREE)

                # specify remote destination
                remoteDEST="${s3bucket}/${s3object}/\${localTREE}"

                # display transfer info
                echo "localPATH:  \$localPATH"
                echo "localTREE:  \$localTREE"
                echo "localSTEM:  \$localSTEM"
                echo "localLEAF:  \$localLEAF"
                echo "remoteDEST: \$remoteDEST"
                
                # specify transfer command
                CMD="${modulator}aws s3 --profile ${params.aws_profile} sync --follow-symlinks \${LINK} s3://\${remoteDEST}"
                echo \$CMD

            done
            """

        }

