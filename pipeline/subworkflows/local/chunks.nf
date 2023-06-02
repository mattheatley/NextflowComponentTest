
/* SUBWORKFLOWS IMPORT */

    subworkflowDir   = "../../subworkflows"
    subworkflowLocal = "${subworkflowDir}/local"

    include { Inputs_Find   as FindInputs   } from "${subworkflowLocal}/Inputs_Find"
    include { Inputs_Subset as SubsetInputs } from "${subworkflowLocal}/Inputs_Subset"


/* MODULES IMPORT */

    moduleDir   = "../../modules"
    moduleLocal = "${moduleDir}/local"
    
    include { Process_Chunk as ProcessChunk } from "${moduleLocal}/Chunk_Process"


/* FUNCTIONS IMPORT */

    functionDir   = "../../functions"
    functionLocal = "${functionDir}/local"

    include { Counts_Match  as MatchCounts  } from "${functionLocal}/Counts_Match"


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
            "CHUNK PROCESS",
            SubsetInputs.out.Chunks,
            ProcessChunk.out.Chunks
            )

    }
