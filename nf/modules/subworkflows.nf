
/* PROCESS DEFINITION */

process PROCESS_1 {

    input:
        val(ProcessTag)
        val(ProcessInput)

    output:
        val(ProcessOutput)

    exec:

        ProcessOutput = "${ProcessTag}-${ProcessInput}"

    }


/* SUBWORKFLOW DEFINITION */

    GlobalInput = "ABC"

    workflow SUBWORKFLOW_A {

        take: // as input? i.e. channel or string/int etc
            WorkflowInput
              // N.B. documentation implies converted to channel

        main:
            println "SubWorkflowA Input Class: ${WorkflowInput.getClass()}"
            WorkflowInput  = WorkflowInput ?: "DefaultA"
            WorkkflowTag   = "TagA"
            WorkflowOutput = PROCESS_1(WorkkflowTag, WorkflowInput)

        emit: // as channel (if not already)
            WorkflowOutput
    }

    workflow SUBWORKFLOW_B {

        take: 
            WorkflowInput

        main:
            println "SubWorkflowB Input Class: ${WorkflowInput.getClass()}"
            WorkflowInput  = WorkflowInput ?: "DefaultB"
            WorkkflowTag   = "TagB"
            WorkflowOutput = PROCESS_1(WorkkflowTag, WorkflowInput)

        emit:
            WorkflowOutput
    }


/* WORKFLOW DEFINITION */

    workflow MODULE_WORKFLOW {

        SUBWORKFLOW_A(channel.value(GlobalInput))
        SUBWORKFLOW_A.out.WorkflowOutput.view{ info -> 
            "SubWorkflowA: ${info}"}

        SUBWORKFLOW_B(GlobalInput)
        SUBWORKFLOW_B.out.WorkflowOutput.view{ info -> 
            "SubWorkflowB: ${info}"}

        }
        