
process MODULE {

        tag "TAG-${INPUT_VAL}"

        debug true

        fair false
        beforeScript """echo "BEFORESCRIPT COMMANDS" """

        memory 1.GB
        cpus 2
        errorStrategy 'retry'

        maxRetries 1


        input:

            val(INPUT_VAL)

        
        output:

            path('MISSING.txt'),
            
            emit: OUTPUT


        script:
            
            """
            echo "executing ${INPUT_VAL} (attempt ${task.attempt} of ${1+task.maxRetries})"
            echo "${INPUT_VAL}" > ${INPUT_VAL}.txt
            sleep 2
            if [[ "${INPUT_VAL}" != "E" ]]; then
                echo "info" > MISSING.txt
            fi
            """
            
    } 



    workflow SUBWORKFLOW {
        
        CHANNEL_VAL = Channel.fromList( ['B','A','D','C','E'] )
        MODULE( CHANNEL_VAL )

        }