
/* WORKFLOW DEFINITION */

workflow MODULE_WORKFLOW {



/* If, Elif, Else Closures */

    println "\nTesting Conditional Closure"
    
    values = [ 1, 11, 10 ]

    values.each{ value ->

        println "Current Value: ${value}"

        // IF
        if( value < 10 ) {
            result = "IF"
        }
        
        // ELIF
        else if( value > 10 ) { 
            result = "ELIF"
        }

        // ELSE
        else {
            result = "ELSE"
        }

        println "-> ${result}"

    }



/* Ternary If Operator */

    println "\nTesting Ternary Conditional Operator"

    values = [ 1, 10 ]

    values.each{ value ->

        println "Current Value: ${value}"

        result = (value < 10) ?"IF" : "ELSE"

        println "-> ${result}"
        
    }



/* Ternary Elvis Operator */

    println "\nTesting Elvis Conditional Operator"

    values = [ 'IF', null, false ]

    values.each{ value ->

        println "Current Value: ${value}"

        result = value ?: "ELSE"

        println "-> ${result}"

    }

}
