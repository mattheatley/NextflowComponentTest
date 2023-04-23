/* FUNCTION DEFINITION */

    def TestFunction(Arg1, Arg2) {
        String1 = Arg1
        String2 = Arg2
        Output  = "${String1}-${String2}" 
        return Output
        }



/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        /* FUNCTION INVOCATION */

            FunctionOutput1 = TestFunction(
                "Input1",
                "Input2" )
            
            println "FunctionOutput1: ${FunctionOutput1}"

            FunctionOutput2 = TestFunction(
                "InputA",
                "InputB" )

            println "FunctionOutput2: ${FunctionOutput2}"

        }
    