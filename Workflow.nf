
// enable dsl syntax extension (should be applied by default)
nextflow.enable.dsl = 2

// DEFINING & PRINTING VARIABLES
start_message = """
 ------------------------ 
      NEXTFLOW TESTING    
  WORKFLOW START MESSAGE  
 ------------------------ 
"""
println(start_message)





/* 

PARAMETER DEFAULTS

i) command line override:

run nextflow /path/to/worflow.nf --flagN argument


ii) workflow.nf format:

params.flagN = argument


iii) nextflow.config (-c) / params-file (-p) format:

params {
    flag1 = "argument"
    flag2 = 1
    flag3 = true
    flag4 = null
} 

*/


if( !params.mod ) { 
    println("\tNO MODULE PROVIDED\n")
    System.exit(0)
    } 



/* WORKFLOW INTROSPECTION */
INDENT = '   '
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

println("\n${INDENT}PROFILE:\n")
println("\tconfig profile:   ${workflow.profile}")
println("\tcontainer engine: ${workflow.containerEngine}")

println("\n${INDENT}TESTING:\n") 
println("\tcomponent: ${params.mod}")



/* COMPONENT IMPORT */

include { 
    //MODULE_PROCESS  as CURRENT_PROCESS;  // module component (if testing seperately)
    MODULE_WORKFLOW as CURRENT_WORKFLOW  // workflow component
    } from "./component/${params.mod}"   // .nf extension ignored for module



/* WORKFLOW RUN */

println("\n${INDENT}RUNNING WORKFLOW...\n")

workflow { CURRENT_WORKFLOW() }
