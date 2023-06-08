
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

            tuple   val(INPUT_VAL1), 
                    val(INPUT_VAL2)
            path    INPUT_PATH, stageAs: "blah/*"
        
        output:

            tuple   val(INPUT_VAL1), 
                    val(INPUT_VAL2),
                    val(task.index),
                    path("blah/*", includeInputs:true, followLinks:true),
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
            echo "${INPUT_VAL1}_${INPUT_VAL2}" > blah/${INPUT_VAL1}_${INPUT_VAL2}.txt
            """
            
        /* define test [ script | shell | exec ] (-stub-run / -stub) */

        //stub:

    } 



/* SUBWORKFLOW DEFINITION */

    workflow SUBWORKFLOW {
        
        Path2Repo = "/Users/matt.heatley/Desktop"
        Dir2Stage = "${Path2Repo}/NextflowComponentTest/additional/dir2stage"

        /* define channels */
        CHANNEL_VAL1 = Channel.fromList(  1..26   )
        CHANNEL_VAL2 = Channel.fromList( 'A'..'Z' )
        
        Content2Stage = files("${Dir2Stage}/*")
        Content2Stage.each{ file -> 
            println "> ${file}" }
        CHANNEL_PATH = Channel.value(Content2Stage)

        /* manipulate channels */
        CHANNEL_MERGED = CHANNEL_VAL1.merge(CHANNEL_VAL2)

        /* run process */
        MODULE( CHANNEL_MERGED, CHANNEL_PATH )

        /* extract process outputs */
        CHANNEL_PROCESS_INFO = MODULE.out.PROCESS_INFO
        CHANNEL_PROCESS_STD  = MODULE.out.PROCESS_STD

        /* view process outputs */
        CHANNEL_PROCESS_INFO.view( { val1, val2, idx, paths -> 
            "\nidx ${idx} ; ${val1}${val2}\n" } )



        }