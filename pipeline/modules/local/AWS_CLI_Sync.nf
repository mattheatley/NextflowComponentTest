
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

        output:
            path(files)

        script:
            modulator = params.dry_run ? "#" : ""
            parent = file(params.source_path).getParent()
            """
            # convert input to array
            FILES=( ${files.join(" ")} )

            echo "parent: ${parent}"

            # cycle through array
            for FILE in \${FILES[@]}; do

                echo

                # extract canonical symlink path
                LINK=\$(readlink -f \${FILE})

                # strip parent/ from path prefix
                DEST=\$(echo \${LINK} | sed 's+${parent}/++')
                STEM=\$(dirname \$DEST)
                echo "link: \$LINK"
                echo "stem: \$STEM"
                echo "dest: \$DEST"
                echo "${modulator}aws s3 --profile ${params.aws_profile} sync \${FILE} s3://<${params.bucket_path}>/<${params.object_path}>/\${DEST}"

            done
            """

        }

