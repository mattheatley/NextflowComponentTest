
/* flatten parameters */

def flatParams(params, sep, list) {    
    
    params.each{ key, value -> 

        // recursively flatten nested maps
        if (value instanceof Map) {

            nestedMap = value.collectEntries{ subkey, subvalue -> 
                [ ("${key}${sep}${subkey}"): subvalue ] }

            flatParams( nestedMap, sep, list )
           
            }

        // store key:value pair
        else

            list.add([ (key): value ])

        }

        return list.collectEntries()
    }



/* SUBWORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        println "${params}\n"

        println "first level parameter:  ${params.main1}"

        println "nested level parameter: ${params.sub1.A}\n"

        println "flattened nested parameters"
        println flatParams(params, '.', []).each{ key,value ->
            println "${key}\t${value}"
        }

        
    }

