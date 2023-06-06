/* FUNCTION DEFINITION */

    def TestFunction(Arg1, Arg2) {
        String1 = Arg1
        String2 = Arg2
        Output  = "${String1}-${String2}" 
        return Output
        }


    def BytesUnit( bytes ) {
        
        bytes = Long.valueOf(bytes)

        switch(bytes) {            

            case { 1000000000000 <= bytes }: 
                relevant = [ 1000000000000, "TB" ]
                break;
            case { 1000000000 <= bytes && bytes <= 1000000000000 }: 
                relevant = [ 1000000000, "GB" ]
                break; 
            case { 1000000 <= bytes && bytes <= 1000000000 }:
                relevant = [ 1000000, "MB" ]
                break; 
            case { 1000 <= bytes && bytes <= 1000000 }:
                relevant = [ 1000, "KB" ]
                break; 
            default:
                relevant = [ 1, "B" ]
                break;             
            }
        
        (factor, unit) = relevant

        return "${bytes / factor}${unit}"
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

            println BytesUnit(10000000000000)
            println BytesUnit(1000000000000)
            println BytesUnit(100000000000)
            println BytesUnit(10000000000)
            println BytesUnit(1000000000)
            println BytesUnit(100000000)
            println BytesUnit(10000000)
            println BytesUnit(1000000)
            println BytesUnit(100000)
            println BytesUnit(10000)
            println BytesUnit(1000)
            println BytesUnit(100)
        }
    