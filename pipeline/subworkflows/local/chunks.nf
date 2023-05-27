
/* MODULES IMPORT */

    moduleDir = "../../subworkflows"

    include { Subset_Target as SubsetTarget } from "${moduleDir}/local/SubsetTarget"

/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        SubsetTarget( 
            params.Chunks,
            params.publishDir
            )

        SubsetTarget.out.Chunks

    }
