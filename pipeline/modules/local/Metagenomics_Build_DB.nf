/* BUILD KRAKEN2 DATABASE */

    process Kraken2_Sequential_Build {

        //container = ''

        input:
            val(dbName)
            path(taxonsPath), stageAs: "taxonomy"
            path(genomeList)
        // N.B. not possible to stageAs within dbName; hence mv staged directory below
        
        output:
            //path("*.txt"),  emit: prep
            path(genomeList)

        script:
            
            customLibrary = "${dbName}/library/added"

            """
            # create database directory
            mkdir -p ${dbName}

            # move staged taxonomy directory
            mv taxonomy ${dbName}
            
            du -La ${dbName}
            count=0

            while IFS="" read -r PATH; do
                
                let count+=1
                echo ${customLibrary}/\$count

            done < "${genomeList}"
            """

        }
