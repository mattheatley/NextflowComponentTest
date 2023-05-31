
/* SUBWORKFLOWS IMPORT */

    subworkflowDir = "../../subworkflows"

    include { Inputs_Find   as FindInputs   } from "${subworkflowDir}/local/Inputs_Find"
    include { Inputs_Subset as SubsetInputs } from "${subworkflowDir}/local/Inputs_Subset"
    include { Counts_Match  as MatchCounts  } from "${subworkflowDir}/local/Counts_Match"


/* MODULES IMPORT */

    moduleDir = "../../modules"

    include { Process_Chunk as ProcessChunk } from "${moduleDir}/local/Chunk_Process"



/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        params.Target.LogDir = params.publishDir

        FindInputs( params.Target )
        // path Target -> [ file1, file2... ]

        params.Chunks.LogDir = params.publishDir
        
        SubsetInputs( 
            FindInputs.out.Contents,
            params.Chunks )         
        // [file1, file2...] -> [ [chunk1, [files...]],[chunk2, [files...]]... ]

        ProcessChunk( 
            SubsetInputs.out.Chunks,
            params.Chunks.MD5Sum
            )

        MatchCounts(
            SubsetInputs.out.Chunks,
            ProcessChunk.out.Chunks
            )

    }
