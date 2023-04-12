
/* PROCESSES DEFINITION */

process MODULE_PROCESS {


    /* DIRECTIVES (OPTIONAL) */

    /* Submitted process > PROCESS_NAME (TAG) */
    tag "${INPUT_VAL1}${INPUT_VAL2}"

    /* print stdout */
    debug true


    /* DECLARATIONS (REQUIRED) */

    /* define process inputs & outputs */

    input:

    tuple val(INPUT_VAL1), val(INPUT_VAL2)
    
    output:

    tuple val(INPUT_VAL1), val(INPUT_VAL2), emit: PROCESS_INFO
    stdout                                  emit: PROCESS_STD


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
    echo "executing: ${task.process}"
    echo "processing: ${INPUT_VAL1} ${INPUT_VAL2}"
    """
    
    /* define test [ script | shell | exec ] (-stub-run / -stub) */

    //stub:

    } 


/* WORKFLOW DEFINITION */

workflow MODULE_WORKFLOW {

    /* define channels */
    CHANNEL_VAL1 = Channel.of(  1,   2,   3,  )
    CHANNEL_VAL2 = Channel.of( 'A', 'B', 'C', )

    /* manipulate channels */
    CHANNEL_MERGED = CHANNEL_VAL1.merge(CHANNEL_VAL2)

    /* run process */
    MODULE_PROCESS( CHANNEL_MERGED )

    /* extract process outputs */
    CHANNEL_PROCESS_INFO = MODULE_PROCESS.out.PROCESS_INFO
    CHANNEL_PROCESS_STD  = MODULE_PROCESS.out.PROCESS_STD

    /* view process outputs */
    CHANNEL_PROCESS_INFO.view( { val1, val2 -> "\ninputs: ${val1} ${val2}" } )

    }