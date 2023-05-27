
/* MODULE DEFINITION */

    process MODULE {

    input:
        val value
        each letter
        each symbols

    script:
        (symbol1, symbol2) = symbols
        combination = "${letter} ${symbol1}/${symbol2})"
        println "Current Value: ${value} (Combination ${combination})"
        """
        echo \"${combination}\" > ${letter}-${symbol1}-${symbol2}.txt
        """

    }



/* SUBWORKFLOW DEFINITION */

    workflow SUBWORKFLOW {


        println "\nLooping (Classic)"

        for (value = 1; value < 4 ; value++) { 
        
            println "Current Value: ${value}"
        
        }



        values = [ 1, 2, 3 ]



        println "\nLooping via Each"
        
        values.each{ def value ->

            println "Current Value: ${value}"

        }



        println "\nLooping via For"

        for ( def value : values ) {

            println "Current Value: ${value}"

        }



        println "\nLooping via For/In"

        for ( def value in values ) {

            println "Current Value: ${value}"

        }

        println "\nLooping via Process"

        values  = Channel.from( 1,   2,   3 )

        // each of; channel or list
        letters = Channel.from('A', 'B', 'C')
        symbols = [ ['x','y'], ['q','w' ] ]

        MODULE(
            values, 
            letters, 
            symbols )

    }

