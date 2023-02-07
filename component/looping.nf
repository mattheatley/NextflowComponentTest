
/* MODULE DEFINITION */

process MODULE_PROCESS {

  input:
  val value
  each letter
  each symbol

  exec:

  println "Current Value: ${value} (Combination ${letter} ${symbol})"

}



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

    println "\nLooping via Process"

    values  = Channel.from( 1,   2,   3 )

    // each of; channel or list
    letters = Channel.from('A', 'B', 'C')
    symbols = ['!', '?' ]

    MODULE_PROCESS(
        values, 
        letters, 
        symbols )

}

