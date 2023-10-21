
process MODULE {

        tag "TAG-${INPUT_VAL}"
        shell '/bin/bash', '-ue' //,'+e'
        debug true

        fair false
        beforeScript """echo "BEFORESCRIPT COMMANDS" """

        memory 1.GB
        cpus 2
        errorStrategy 'ignore'

        maxRetries 1


        input:

            val(INPUT_VAL)

        
        output:

            path('MISSING.txt'),
            
            emit: OUTPUT


        script:

            """

            echo "executing ${INPUT_VAL} (attempt ${task.attempt} of ${1+task.maxRetries})"

            sleep 2
            if [[ "${INPUT_VAL}" != "E" ]]; then
                echo "info" > MISSING.txt
            fi

            echo "${INPUT_VAL}" > ${INPUT_VAL}.txt
            
            > test.sh

            ls *shh
            ERROR=\$?            
            echo "exit: \$ERROR"

            if [ \$ERROR -eq 0 ]; then 
                echo "SUCCESS!!!"
            fi
            if ! [ \$ERROR -eq 0 ]; then 
                echo "ERROR!!!"

            fi

            echo "MORE STUFF..."

            """
            
    } 



    workflow SUBWORKFLOW {
        
     // CHANNEL_VAL = Channel.fromList( ['B','A','D','C','E'] )
        CHANNEL_VAL = Channel.fromList( ['B','A','D','C'] )
        MODULE( CHANNEL_VAL )

        }