
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



/* WORKFLOW INTROSPECTION */

    workflow Display_Workflow {

        take:
            WorkflowMeta // class nextflow.script.WorkflowMetadata
            Indent

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

            seperator = ":"
                
            padSep = seperator.size()

            toDisplay.each{ category, keySet -> 
                
                println("\n${Indent}${category}:\n")

                keySet.each{ key ->

                    subcategory="${key}${seperator}"
                    
                    value = WorkflowMeta[key]
                    
                    value = value instanceof List 
                        ? value.join(',') 
                        : value

                    println "\t${subcategory.padRight(padNum+padSep)}\t${value}" }
                    
                }
                        
    }



/* PARAMETER INTROSPECTION */

    workflow Display_Parameters {
    
        take:
            ParameterMeta // class nextflow.ScriptBinding.ParamsMap
            Indent

        main:

            println "\n${Indent}SETTINGS:\n"

            flattenedMap = flattenNested(ParameterMeta, '.', [])

            padNum = flattenedMap.keySet().collect{ key -> key.size() }.max()
            
            seperator = ":"
            
            padSep = seperator.size()

            flattenedMap.each{ key,value ->

                key+=seperator
                
                println "\t${key.padRight(padNum+padSep)}\t${value}"
                
                }

        emit:

            ParameterMap = flattenedMap

    }
