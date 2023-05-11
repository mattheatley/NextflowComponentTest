
/* DOWNLOAD TAXON NCBI DATASETS GENOME SUMMARY */

    process AWS_CLI_Sync {

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
