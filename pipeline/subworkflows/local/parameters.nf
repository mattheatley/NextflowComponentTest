
/* SUBWORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        println "\nparams object contents:\n"

        params.each{ param ->
            println " - ${param}" }

        println "\nfirst level parameter:  ${params.main1}"

        println "\nnested level parameter: ${params.sub1.A}\n"
        
    }

