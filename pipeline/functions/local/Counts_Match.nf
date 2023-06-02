
/* FUNCTION DEFINITION */

    def Counts_Match( Label, Input, Output ) {

        // combine inputs & outputs
        Input.combine(
            Output, 
            by: 0 
            ).subscribe( 

                // check chunk sizes correspond
                onNext: { chunk, inputs, outputs ->

                    // stage single paths as lists
                    outputs = outputs instanceof List 
                        ?   outputs 
                        : [ outputs ]

                    assert inputs.size().equals(outputs.size()): 
                        "${Label} Chunk ${chunk}: Chunk sizes differ for inputs (${inputs.size()}) & outputs (${outputs.size()})"

                    },
                
                onComplete: { println "${Label}: Chunk sizes match for inputs & outputs." }
                
                )

        }
