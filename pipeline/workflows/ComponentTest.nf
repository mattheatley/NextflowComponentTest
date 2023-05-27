
/* SETUP */ 

    INDENT = '   '

    StartMessage = """
    ${INDENT}------------------------ 
    ${INDENT}        NEXTFLOW    
    ${INDENT}    COMPONENT TESTER      
    ${INDENT}------------------------ 
    """
    println(StartMessage)
    
    assert params.component: "No component provided"



/* IMPORT SUBWORKFLOW */

    // "${workflow.projectDir}/subworkflows/local"
    subworkflowDir = "../subworkflows/local"

    include { Display_Workflow as DisplayWorkflow } from "${subworkflowDir}/Setup"

    include { Display_Parameters as DisplayParameters } from "${subworkflowDir}/Setup"

    include { SUBWORKFLOW as TestComponent } from "${subworkflowDir}/${params.component}"

    /* N.B. .nf extension ignored for component module & workflow files */



/* RUN SUBWORKFLOW */

    workflow IndividualWorkflow { 

    
    /* WORKFLOW INTROSPECTION */

        DisplayWorkflow( workflow, INDENT )
        

    /* PARAMETER INTROSPECTION */

        DisplayParameters( params, INDENT )


    /* RUN TEST */

        println("\n\n${INDENT}TESTING ${params.component.toUpperCase()} COMPONENT...\n")

        TestComponent()

        }
