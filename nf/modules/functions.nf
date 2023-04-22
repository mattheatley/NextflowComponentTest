/* FUNCTION DEFINITION */

    def TestFunction(Arg1, Arg2) {
        String1 = Arg1
        String2 = Arg2
        Output  = "${String1}-${String2}" 
        return Output
        }



/* WORKFLOW DEFINITION */

    workflow MODULE_WORKFLOW {

        FunctionOutput1 = TestFunction(
            "FirstWord",
            "SecondWord" )
        
        println "FunctionOutput1: ${FunctionOutput1}"

        FunctionOutput2 = TestFunction(
            "ThirdWord",
            "FourthWord" )

        println "FunctionOutput2: ${FunctionOutput2}"

        }
    