
/* DOWNLOAD TAXON NCBI DATASETS GENOME SUMMARY */

    process AWS_CLI_Sync_Commands {

        //container = 'staphb/ncbi-datasets:14.20.0'

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

        //container = 'staphb/ncbi-datasets:14.20.0'

        input:
            path(files)
            val(bucket)
            val(object)

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

                # extract directory/subdirectory components
                localSTEM=\$(dirname \$localTREE)
                # extract basename components
                localLEAF=\$(basename \$localTREE)

                # specify remote destination
                remoteDEST="${bucket}/${object}/\${localTREE}"

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

