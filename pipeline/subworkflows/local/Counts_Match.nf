
/* SUBWORKFLOW DEFINITION */

    workflow Counts_Match {
        
        take:

            Original
            Updated


        main:

            // check number of inputs & outputs correspond
            Original.combine(
                Updated, 
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

