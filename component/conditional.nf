
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

    values = [ 'CURRENT', null, false ]

    values.each{ value ->

        println "Current Value: ${value}"

        result = value ?: "DEFAULT"

        println "-> ${result}"

    }



/* Nested Conditionals */

    println "\nTesting Nested Operators"

    values = [ [true, "CURRENT"], [true, false], [false, false], [false, "CURRENT"] ]

    values.each{ valueA, valueB ->

        println "Current Values: ${valueA} / ${valueB}"

        result = valueA ? valueB ?: "DEFAULT" : "ELSE" 

        println "-> ${result}"

    }



/* Switch Statements */

    println "\nTesting Switch Statements"

    booleans = [ "RESTRICTED", "CASCADE" ]

    booleans.each{ mode ->

        println "\n${mode} MODE"

        restricted = ( mode == "RESTRICTED" )

        values = [ 1, 2, 3 ]

        values.each{ value ->

            println "Current Values: ${value}"

            switch(value) {

                case 1:
                    
                    if (restricted) {
                        println "-> IF"
                        break 
                    }

                    else { 
                        println "-> 1ST STEP" 
                    }
                        
                case 2:

                    if (restricted) {
                        println "-> ELIF"
                        break 
                    }
                    
                    else { 
                        println "-> 2ND STEP" 
                    }

                default:

                    if (restricted) {
                        println "-> DEFAULT"
                        break 
                    }

                    else { 
                        println "-> 3RD STEP" 
                    }
            }
        }
    }

}
