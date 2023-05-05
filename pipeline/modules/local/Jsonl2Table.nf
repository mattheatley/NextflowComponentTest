/* CONVERT DATASET JSON TO CSV */

    process Jsonl2Table {

        container = 'quay.io/biocontainers/pandas:1.4.3'

        publishDir path : "${params.publishDir}",
                pattern : "*.{jsonl,tsv}",
                 saveAs : { path -> 
                 subDir = path.endsWith(".jsonl") ? "jsonl" : "table"
                    "${subDir}/${file(path).getName()}" },
                   mode : "copy",
              overwrite : true

        input:
            tuple val(taxon), path(jsonl), val(count)

        output:
            path(jsonl),                     emit: Summary
            tuple val(taxon), path("*.tsv"), emit: Sublist

        script:
            """
            jsonl2table.py -i ${jsonl}
            """
    
        }
