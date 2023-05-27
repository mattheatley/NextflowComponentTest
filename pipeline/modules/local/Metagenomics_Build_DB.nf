/* BUILD KRAKEN2 DATABASE */

    process Kraken2_Sequential_AddToLibrary {

        //container = ''

        input:
            val(dbName)
            path(taxonsPath), stageAs: "taxonomy"
            path(genomeList)
        // N.B. not possible to stageAs within dbName when input; hence mv staged directory below
        
        output:
            //path("*.txt"),  emit: prep
            path(genomeList)
            env(ADDED)

        script:
            
            customLibrary = "${dbName}/library/added"

            """
            # create database directory & move staged taxonomy directory
            mkdir -p ${customLibrary}
            mv taxonomy ${dbName}/

            mkdir -p ${customLibrary}

            ADDED=0
            while IFS="" read -r FASTA; do
                
                let ADDED+=1
                echo "Adding genome \$ADDED: \$(basename \$FASTA)"
                
                # creates dbName/library/added/prelim_map_XXXXXXXXXX.txt temp file
                #kraken2-build --add-to-library \$FASTA --db ${dbName}
                # mimic prelim map creation
                echo "\$ADDED \$FASTA" > ${customLibrary}/prelim_map_XXXXXXXXXX.txt

                # extract input basename & remove final extension
                LABEL=\$(basename \$FASTA .\${FASTA##*.})

                # move & rename temp prelim map file
                mv ${customLibrary}/prelim_map_??????????.txt prelim_map_\${LABEL}.txt

            done < "${genomeList}"
            """

        }
