
/* SUBWORKFLOWS IMPORT */

    subworkflowDir = "../../subworkflows"

    include { Subset_Target as SubsetTarget } from "${subworkflowDir}/local/Subset_Target"


/* MODULES IMPORT */

    moduleDir = "../../modules"

    include { Process_Chunk as ProcessChunk } from "${moduleDir}/local/Chunk_Process"



/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        SubsetTarget(
            params.Chunks,
            params.publishDir
            ) 
        // path Target -> [ [chunk, [files...]],... ]
        
        ProcessChunk( 
            SubsetTarget.out.Chunks,
            params.Chunks.MD5Sum
            )

        // check number of inputs & outputs correspond
        SubsetTarget.out.Chunks.combine(
            ProcessChunk.out.Chunks, 
            by: 0 ).subscribe( 

                onNext: { chunk, inputs, outputs ->

                    // stage single paths as lists
                    outputs = outputs instanceof List 
                        ?   outputs 
                        : [ outputs ]

                    assert inputs.size().equals(outputs.size()): 
                        "Chunk ${chunk}: Different number of outputs (${outputs.size()}) compared to inputs (${inputs.size()})"
                
                    },
                
                onComplete: { println "Number of inputs & outputs correspond." }
                )

    }
