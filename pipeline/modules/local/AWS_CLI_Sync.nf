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
            SOURCE=\$(readlink ${source})
            TRANSFERS=\$(du -Labc \$SOURCE | sort -k1 -n)

            chunk_size=0 ; chunk_num=0
            total_size=0 ; file_num=0

            size_limit=${params.chunk_size}

            while IFS=\$'\t' read -r SIZE PATH; do
                
                CHUNK="NA"

                if [ -f \$PATH ]; then

                    let file_num+=1
                    
                    # calculate updated chunk size
                    chunk_sum=\$((chunk_size + SIZE))
                    
                    # first file or chunk exceeds size limit
                    if [ \$file_num -eq 1 ] || [ \$chunk_sum -gt \$size_limit ]; then
                        # record new chunk
                        let chunk_num+=1
                        # reset chunk size
                        chunk_size=0
                    fi

                    # specify chunk file
                    chunk_file="chunk\${chunk_num}.txt"

                    # create empty chunk file as required
                    if [ ! -f \$chunk_file ]; then
                        > \$chunk_file
                    fi

                    let chunk_size+=\$SIZE
                    let total_size+=\$SIZE

                    # append file to current chunk file
                    echo \$PATH >> \$chunk_file

                    CHUNK=\$chunk_num

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

