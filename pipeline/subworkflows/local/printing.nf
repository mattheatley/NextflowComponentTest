
/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW {


        print "\nsPrinting via Print"

        println "\nPrinting via Println"


        values = Channel.from( 1, 2, 3 )

        println "\nPrinting via View"
        
        values.view{ value -> 

            "Current Value: ${value}"
        
        }

    }

