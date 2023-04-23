
/* MODULE DEFINITION */

    process MODULE {

        input:
            val(ProcessTag)
            val(ProcessInput)

        output:
            val(ProcessModification), emit: ProcessOutput

        exec:

            ProcessModification = "${ProcessTag}-${ProcessInput}"

        }



/* ADDITIONAL SUBWORKFLOW DEFINITION */

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

            MODULE(
                WorkflowTag, 
                WorkflowInput )

        emit: // named output access

            WorkflowTag

            WorkflowOutput = MODULE.out.ProcessOutput

        // N.B. emmited as channel (if not already)
    }

    workflow SUBWORKFLOW_B {

        take: 
            WorkflowInput

        main:

            println "SubWorkflowB Input Class: ${WorkflowInput.getClass()}"

            WorkflowInput = WorkflowInput ?: "DefaultB"

            WorkflowTag   = "TagB"

            MODULE(
                WorkflowTag, 
                WorkflowInput )

        emit: // array element output access

            "TagB"

            MODULE.out.ProcessOutput

    }



/* SUBWORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        /* ADDITIONAL SUBWORKFLOW INVOCATION */

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
        