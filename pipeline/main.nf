
/* SETUP */ 

// enable dsl syntax extension (should be applied by default)
nextflow.enable.dsl = 2

INDENT = '   '

start_message = """
${INDENT}------------------------ 
${INDENT}     NEXTFLOW TESTING    
${INDENT}      WORKFLOW START  
${INDENT}------------------------ 
"""
println(start_message)

if( !params.component ) { 
    println("\tNO COMPONENT PROVIDED\n")
    System.exit(0)
    } 



/* WORKFLOW INTROSPECTION */

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

println("\n${INDENT}RUNNING:\n") 
println("\tcomponent: ${params.component}")



/* IMPORT COMPONENTS */

moduleDir = "${workflow.projectDir}/modules"

include { 
    MODULE_WORKFLOW as CURRENT_WORKFLOW
    } from "${moduleDir}/${params.component}"
    /* N.B. .nf extension ignored for component module & workflow files */



/* RUN WORKFLOW */

println("\n${INDENT}RUNNING WORKFLOW...\n")

workflow { CURRENT_WORKFLOW() }
