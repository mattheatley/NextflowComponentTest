
/* MODULE DEFINITION */

    process CreateMatrix {

        publishDir path : params.publishDir,
                pattern : "*.csv",
                   mode : "copy",
              overwrite : true

        input:
            tuple val(rows), val(cols), val(sep)

        output:
            path("*.csv"), emit: TestFile

        script:
            """
            matrix="matrix.csv"

            > \$matrix

            for row in \$(seq 1 $rows); do
                            
                entry=""

                for col in \$(seq 1 $cols); do

                        cell="row\${row}-col\${col}"
                
                        entry="\${entry}\${entry:+$sep}\$cell"
                
                done

                echo "\$entry" >> \$matrix

            done
            """
        }



/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW {

        /* specify matrix properties */
            def ( Rows, Columns, Delimiter ) = MatrixInfo = [ 5, 3, "," ]

            def ( Cell1, Cell2, Cell3 ) = Headers = ( 1..Columns ).collect{ i -> "cell${i}"}

        /* create matrix file */
            CreateMatrix( Channel.of(MatrixInfo) )

            CreateMatrix.out.TestFile.view{ path -> "TestFile: ${path}" }

        /* read matrix file */
            CreateMatrix.out.TestFile.splitCsv( 
                // header : true,    // 1st row header / original labels 
                //   skip : 0,       // 1st row header / original labels 
                // header : Headers, // 1st row header / custom labels
                //   skip : 1,       // 1st row header / custom labels
                header : Headers, // No header / custom labels
                  skip : 0,       // No header / custom labels
                   sep : Delimiter 
                ).set{ InputRows }

            InputRows.view{ entry -> 
                """
                entry: $entry
                cell1: ${entry[Cell1]}
                cell2: ${entry[Cell2]}
                cell3: ${entry[Cell3]}
                """ }
    }

