
/* INFORMATION */

// https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/


/* MODULES IMPORT */

    include { DatasetSummary } from '../../modules/local/DatasetSummary'

    include { Jsonl2Table    } from '../../modules/local/Jsonl2Table'

    include { DatasetDownload } from '../../modules/local/DatasetDownload'


/* SUBWORKFLOW DEFINITION */

    workflow SUBWORKFLOW {
        
        println "\tDOWNLOADING NCBI GENOME INFO\n"
    
        /* process taxon parameter */

            // split comma delimited argument
            TaxonList = params.ncbi_taxons.split(',')

            // convert to lowercase
            TaxonList = TaxonList.collect{ it.toLowerCase() }

            // remove duplicates
            TaxonList = TaxonList.unique()


        /* query taxon genomes */

            DatasetSummary( Channel.fromList( TaxonList ) )


        /* group available/unavailable taxons */

            DatasetSummary.out.Sublist.branch{ taxon, json, count ->
                available:   !count.toInteger().equals(0)
                unavailable: true
                }.set{ DatasetSummaryGroups }

            DatasetSummaryGroups.available.view{ taxon, json, count ->
                "Taxon \"${taxon}\" records: ${count}" }

            DatasetSummaryGroups.unavailable.view{ taxon, json, count ->
                "Taxon \"${taxon}\" unavailable" }


        /* process available taxons */
           
            // convert summary to table
            Jsonl2Table( DatasetSummaryGroups.available )

            // extract accessions from table
            Jsonl2Table.out.Sublist.map{ taxon, table -> 

                accessions = table.splitCsv( 
                    header : true,
                      skip : 0,
                       sep : '\t' 
                    ).collect{ entry -> 
                        entry.accession }
                
                // return
                tuple(taxon, accessions)

                }.transpose().set{ AccessionsList }


        /* download available accessions */

            if( params.ncbi_download ) {
            
                DatasetDownload( AccessionsList )

                DatasetDownload.out.Sublist.collect{ taxon, accession, genome -> 
                    accession }
                }
        
        }
