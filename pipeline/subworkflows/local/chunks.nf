
/* SUBWORKFLOWS IMPORT */

    subworkflowDir = "../../subworkflows"

    include { Subset_Target as SubsetTarget } from "${subworkflowDir}/local/SubsetTarget"

/* MODULES IMPORT */

    moduleDir = "../../modules"

    include { Process_Chunk as ProcessChunk } from "${moduleDir}/local/Chunk_2_Process"



/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        SubsetTarget(
            params.Chunks,
            params.publishDir
            ) 
        // path Target -> [ [chunk, [files...]],... ]
        
        ProcessChunk( 
            SubsetTarget.out.Chunks,
            params.Chunks.MD5 
            )

    }
