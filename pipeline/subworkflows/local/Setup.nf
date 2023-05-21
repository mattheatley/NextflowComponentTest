
/* FUNCTION DEFINITION */

    def flattenNested(params, sep, list) {    
        
        params.each{ key, value -> 

            // recursively flatten nested maps
            if (value instanceof Map) {
                
                nestedMap = value.collectEntries{ subkey, subvalue -> 
                    [ ("${key}${sep}${subkey}"): subvalue ] }
                
                flattenNested( nestedMap, sep, list )
                }

            // store key:value pair
            else
            
                list.add([ (key): value ])
            }

            return list.collectEntries()
        }



/* SUBWORKFLOW DEFINITION */

    workflow Display_Workflow {

        take:
            workflow // class nextflow.script.WorkflowMetadata
            indent

        main:

            toDisplay = [
                "WORKFLOW": [
                    "runName",
                    "sessionId",
                    "scriptName",
                    "revision",
                    "projectDir",  // projectDIR/workflow.nf
                    "launchDir",   // working directory (pwd)
                    "workDir",     // launchDIR/work (-w)
                    "configFiles"
                    ],
                "SYSTEM": [
                    "profile",
                    "containerEngine"
                    ]
                ]

            padNum = toDisplay.values().flatten{ key -> key.size() }.max()

            toDisplay.each{ category, keySet -> 
                
                println("\n${indent}${category}:\n")

                keySet.each{ key ->

                    subcategory="${key}:"
                    value = workflow[key]
                    value = value instanceof List ? value.join(',') : value
                    println "\t${subcategory.padRight(padNum+1)}\t${value}" }
                    
                }
                        
    }

    workflow Display_Parameters {
    
        take:
            params // class nextflow.ScriptBinding.ParamsMap
            indent

        main:

            println "\n${indent}SETTINGS:\n"

            flattenedMap = flattenNested(params, '.', [])

            padNum = flattenedMap.keySet().collect{ key -> key.size() }.max()

            flattenedMap.each{ key,value ->

                key+=":"
                println "\t${key.padRight(padNum+1)}\t${value}"
                
                }

        emit:

            paramsFlat = flattenedMap

    }
