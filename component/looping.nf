
/* WORKFLOW DEFINITION */

workflow MODULE_WORKFLOW {


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

}
