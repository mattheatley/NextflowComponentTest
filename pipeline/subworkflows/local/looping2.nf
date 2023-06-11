
/* MODULE DEFINITION */
    
    process MODULE {

        tag "${task.index}"
        fair true
        input:
            tuple   val(values),
                    val(settings)

        script:

            println "V: ${values.v} ; S: ${settings.s1}-${settings.s2}"

            """
            echo \"processing ${values.v}...\"
            """

    }



/* SUBWORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        println "\nLooping via Process"

        values  = Channel.from( 
            [
             [v:1, l:[]],
             [v:2, l:[]],
             [v:3, l:[]]
            ])

        settings  = Channel.from( 
            [
             [s1:'A1',s2:'A2'],
             [s1:'B1',s2:'B2'],
             [s1:'C1',s2:'C2']
            ])

        extra = Channel.from('X','Y')

        // each of; channel or list
        values.combine(settings).combine(extra).set{before}

        before.map{ V, S, X ->

            def tag = "${V.v}-${S.s1}-${S.s2}"

            println "mod: ${tag}"
            assert !V.tag: "V tag exists; ${tag}"
            VN = V + [tag: tag]
            assert !S.tag: "S tag exists; ${tag}"
            //S = S + [tag:tag]
            S.putAt('extra',"${X}${V.v}")
            return [VN,S]
            }
        .set{ after }

        
        before.view{it-> "before ${it}"}
        after.view{it-> "after ${it}"}
        //MODULE( combo )

    }

