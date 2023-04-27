
/* MODULE DEFINITION */

    process RunContainer {

        container = 'mattheatley/lolcow:NoEntrypoint'
        
        publishDir path : params.publishDir,
                pattern : "*.txt",
                   mode : "copy",
              overwrite : true
                
        input:
            val(Input)

        output:
            path("*txt"), emit: Output

        script:
            """
            echo "Processing: ${Input}"
            cowsay "Processing ${Input}" > ${Input}.txt
            """
        }



/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        Inputs = Channel.fromList( ['A', 'B', 'C'] )

        RunContainer(Inputs)
        RunContainer.out.Output.view{ value -> "Output: ${value}"}
    }

