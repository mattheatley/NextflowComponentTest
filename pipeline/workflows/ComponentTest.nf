
/* SETUP */ 

    INDENT = '   '

    start_message = """
    ${INDENT}------------------------ 
    ${INDENT}        NEXTFLOW    
    ${INDENT}    COMPONENT TESTER      
    ${INDENT}------------------------ 
    """
    println(start_message)

    if( !params.component ) { 
        println("\tNO COMPONENT PROVIDED\n")
        System.exit(0)
        } 



/* WORKFLOW INTROSPECTION */

    println("\n${INDENT}WORKFLOW:\n")
    println("\tscipt name:   ${workflow.scriptName}")
    println("\trevision:     ${workflow.revision}")
    println("\texecuting:    ${workflow.commandLine}")
    println("\trun name:     ${workflow.runName}")
    println("\tsession id:   ${workflow.sessionId}")
    println("\tlaunch dir:   ${workflow.launchDir}")   // working directory (pwd)
    println("\tproject dir:  ${workflow.projectDir}")  // projectDIR/workflow.nf
    println("\twork dir:     ${workflow.workDir}")     // launchDIR/work (-w)
    println("\tconfig files: ${workflow.configFiles}")

    println("\n${INDENT}SYSTEM:\n")
    println("\tconfig profile:   ${workflow.profile}")
    println("\tcontainer engine: ${workflow.containerEngine}")

    println("\n${INDENT}SETTINGS:\n") 
    println("\tparameters: ${params.component}")



/* IMPORT SUBWORKFLOW */

    // "${workflow.projectDir}/subworkflows/local"
    subworkflowDir = "../subworkflows/local"

    include { 

        SUBWORKFLOW as Component

        } from "${subworkflowDir}/${params.component}"

        /* N.B. .nf extension ignored for component module & workflow files */



/* RUN SUBWORKFLOW */

    workflow IndividualWorkflow { 
        
        println("\n${INDENT}RUNNING WORKFLOW...\n")

        Component() 

        }
