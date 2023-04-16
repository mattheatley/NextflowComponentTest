
/* WORKFLOW DEFINITION */

workflow MODULE_WORKFLOW {
    
    
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


    /* generate combinations */

        CartesianProducts = Software.combine(Samples)


    /* split branches */

        Branches1 = CartesianProducts.branch{ software, sample ->
            softwareA:  software.toString().equals(SoftwareA)
            softwareB:  software.toString()equals(SoftwareB)
            softwareC:  software.toString()equals(SoftwareC)
            //unassigned: true
            }


    /* process branches */

        Process1A = Branches1.softwareA.map{ software, sample -> 
            tuple( "ProcessA", software, sample ) }

        Process1B = Branches1.softwareB.map{ software, sample -> 
            tuple( "ProcessB", software, sample ) }

        Process1C = Branches1.softwareC.map{ software, sample -> 
            tuple( "ProcessC", software, sample ) }

        Process1 = Process1A.concat(Process1B, Process1C)


    /* split branches (again) */

        Branches2 = Process1.multiMap{ process, software, sample -> 
            softwareX: tuple( "${process}X", software, sample )
            softwareY: tuple( "${process}Y", software, sample )
            //unassigned: true
            }

    println "\tSEE DAG IN LOGS FOR BRANCHING INFO\n"

    }
    