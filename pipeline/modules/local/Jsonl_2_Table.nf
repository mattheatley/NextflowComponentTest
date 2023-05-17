/* CONVERT DATASET JSON TO CSV */

    process Jsonl_2_Table {

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
            tuple val(taxon), path(jsonl), path("*.tsv"), emit: Info

        script:
            """
            jsonl2table.py -i ${jsonl}
            """
    
        }
