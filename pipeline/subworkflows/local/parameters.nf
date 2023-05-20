def flatParams(params, sep) {    
    
    params.collect{ key, value -> 

        if (value instanceof Map) {

            // flatten nested map            
            nestedMap = value.collectEntries{ subkey, subvalue -> 
                [ ("${key}${sep}${subkey}"): subvalue ] }
            
            // recursively call function
            flatParams( nestedMap, sep )

            }

        else

            [ (key): value ]

        }.flatten().collectEntries()
    }



/* SUBWORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        println params

        println "first level parameter:  ${params.main1}"

        println "nested level parameter: ${params.sub1.A}"

        println "flattened nested parameters"
        flatParams(params, '.').each{ key,value ->
            println "${key}\t${value}"
        }

        
    }

