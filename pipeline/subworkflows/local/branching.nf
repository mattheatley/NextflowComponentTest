

/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW {
        
        println "\tSEE DAG FOR BRANCHING OVERVIEW\n"
    
        /* generate inputs */

            List SoftwareTags = [
                'A',
                'B',
                'C',
                '?'
                ].collect{ label -> "Software${label}" }

            def ( 
                String SoftwareA, 
                String SoftwareB, 
                String SoftwareC
                ) = SoftwareTags


        /* define channels */

            Software = Channel.fromList( SoftwareTags )

            Samples  = Channel.fromList( 1..3 )

            CartesianProducts = Software.combine(Samples)


        /* process branches */

            Branches1 = CartesianProducts.branch{ software, sample ->
                softwareA:  software.toString().equals(SoftwareA)
                softwareB:  software.toString()equals(SoftwareB)
                softwareC:  software.toString()equals(SoftwareC)
                //unassigned: true
                }

            Process1A = Branches1.softwareA.map{ software, sample -> 
                tuple( "ProcessA", software, sample ) }

            Process1B = Branches1.softwareB.map{ software, sample -> 
                tuple( "ProcessB", software, sample ) }

            Process1C = Branches1.softwareC.map{ software, sample -> 
                tuple( "ProcessC", software, sample ) }

            Outputs1 = Process1A.concat(Process1B, Process1C)


        /* split branches (again) */

            Branches2 = Outputs1.multiMap{ process1, software, sample -> 
                functionX: tuple( "FunctionX", process1, software, sample )
                functionY: tuple( "FunctionY", process1, software, sample )
                }

            Outputs2 = Branches2.functionX.concat(Branches2.functionY)

            Outputs2.view()

        }
        