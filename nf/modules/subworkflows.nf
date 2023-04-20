
/* PROCESS DEFINITION */

process PROCESS_1 {

    input:
        val(ProcessTag)
        val(ProcessInput)

    output:
        val(ProcessModification), emit: ProcessOutput

    exec:

        ProcessModification = "${ProcessTag}-${ProcessInput}"

    }


/* SUBWORKFLOW DEFINITION */

    GlobalInput = "ABC"

    workflow SUBWORKFLOW_A {

        take: 
            WorkflowInput
        // N.B. taken as provided? i.e. channel or type (i.e. string/int etc)
        // documentation implies type converted to value channel but behaviour not obvious

        main:

            println "SubWorkflowA Input Class: ${WorkflowInput.getClass()}"

            WorkflowInput = WorkflowInput ?: "DefaultA"

            WorkflowTag   = "TagA"

            PROCESS_1(
                WorkflowTag, 
                WorkflowInput )

        emit: // named output access

            WorkflowTag

            WorkflowOutput = PROCESS_1.out.ProcessOutput

        // N.B. emmited as channel (if not already)
    }

    workflow SUBWORKFLOW_B {

        take: 
            WorkflowInput

        main:

            println "SubWorkflowB Input Class: ${WorkflowInput.getClass()}"

            WorkflowInput = WorkflowInput ?: "DefaultB"

            WorkflowTag   = "TagB"

            PROCESS_1(
                WorkflowTag, 
                WorkflowInput )

        emit: // array element output access

            "TagB"

            PROCESS_1.out.ProcessOutput

    }



/* WORKFLOW DEFINITION */

    workflow MODULE_WORKFLOW {


        /* SUBWORKFLOW INVOCATION */

          SUBWORKFLOW_A(channel.value(GlobalInput))

          SUBWORKFLOW_B(GlobalInput)


          SUBWORKFLOW_A.out.WorkflowTag.view{ info -> 
              "SubWorkflowA Tag (named): ${info}"}
          SUBWORKFLOW_A.out.WorkflowOutput.view{ info -> 
              "SubWorkflowA Output (named): ${info}"}
        
         SUBWORKFLOW_B.out[0].view{ info -> 
             "SubWorkflowB Tag (array element): ${info}"}
         SUBWORKFLOW_B.out[1].view{ info -> 
             "SubWorkflowB Output (array element): ${info}"}

        }
        