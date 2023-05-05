/* CONVERT DATASET JSON TO CSV */

    process Jsonl2Table {

        container = 'quay.io/biocontainers/pandas:1.4.3'

        publishDir path : "${params.publishDir}/table",
                pattern : "*.tsv",
                   mode : "copy",
              overwrite : true

        input:
            tuple val(taxon), path(jsonl), val(count)

        output:
            tuple val(taxon), path("*.tsv"), emit: Sublist

        script:
            """
            jsonl2table.py -i ${jsonl}
            """
    
        }
