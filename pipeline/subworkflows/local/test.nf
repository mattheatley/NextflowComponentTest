
/* MODULE DEFINITION */

process MODULE {


    /* DIRECTIVES (OPTIONAL) */

        /* print stdout */
        debug true

        /* control input order */
        fair true

        /* Submitted process > PROCESS_NAME (TAG) */
        tag "TAG-${INPUT_VAL1}${INPUT_VAL2}"


    /* DECLARATIONS (REQUIRED) */

        /* define process inputs & outputs */

        input:

            tuple val(INPUT_VAL1), val(INPUT_VAL2)
        
        output:

            tuple   val(INPUT_VAL1), 
                    val(INPUT_VAL2),
                    val(task.index),
                    emit: PROCESS_INFO
            
            stdout  emit: PROCESS_STD


        /* define [ script | shell | exec ] */

        /*
        script:         $var  (nextflow)   \$var (bash)
            template    $var  (nextflow)    $var (bash)    
        shell:         !{var} (nextflow)    $var (bash)
        exec:           $var  (nextflow)
        */

        //template ['template.sh'|'/path/to/template.sh']
        /* N.B. template.sh should be located in templates/ subdir */

        script:

            """
            echo "executing: ${task.process} TASK ${task.index}"
            echo "processing: ${INPUT_VAL1} ${INPUT_VAL2}"
            """
            
        /* define test [ script | shell | exec ] (-stub-run / -stub) */

        //stub:

    } 



/* SUBWORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        /* define channels */
        CHANNEL_VAL1 = Channel.fromList(  1..26   )
        CHANNEL_VAL2 = Channel.fromList( 'A'..'Z' )

        /* manipulate channels */
        CHANNEL_MERGED = CHANNEL_VAL1.merge(CHANNEL_VAL2)

        /* run process */
        MODULE( CHANNEL_MERGED )

        /* extract process outputs */
        CHANNEL_PROCESS_INFO = MODULE.out.PROCESS_INFO
        CHANNEL_PROCESS_STD  = MODULE.out.PROCESS_STD

        /* view process outputs */
        CHANNEL_PROCESS_INFO.view( { val1, val2, idx -> 
            "\nidx ${idx} ; ${val1}${val2}" } )

        }