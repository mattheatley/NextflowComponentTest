
/* INFORMATION */

// https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/


/* MODULES IMPORT */

    moduleDir = "../../modules"

    include { NCBI_Datasets_Summary as Summary } from "${moduleDir}/local/NCBI_Datasets_Summary"

    include { Jsonl_2_Table as Tabulate  } from "${moduleDir}/local/Jsonl_2_Table"

    include { NCBI_Datasets_Download as DownloadGenomes } from "${moduleDir}/local/NCBI_Datasets_Download"

    include { NCBI_TaxonIDs_Download as DownloadTaxonIDs } from "${moduleDir}/local/NCBI_TaxonIDs_Download"



/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW { 
                
        println "\tDOWNLOADING NCBI GENOME INFO\n"
    
    
        /* process taxon parameter */

            // check taxons input format
            assert params.ncbi_taxons

            TaxonsFile = file(params.ncbi_taxons)

            TaxonsInput = TaxonsFile.exists() ? TaxonsFile : params.ncbi_taxons

            // process as file
            if (TaxonsInput !instanceof String){

                println "Taxons File Found"

                // read lines in file
                TaxonsList = TaxonsInput.splitText( 
                    by : 1
                    ).collect{ line -> line.trim() }
                }

            // process as string
            else{

                println "Taxons File Not Found"

                // split comma delimited string
                TaxonsList = params.ncbi_taxons.split(',')
                }

            // make lowercase
            TaxonsList = TaxonsList.collect{ taxon -> taxon.toLowerCase() }

            // remove duplicates
            TaxonsList = TaxonsList.unique()

            // remove empty
            TaxonsList.removeAll([""])

            // create channel
            Channel.fromList( TaxonsList ).set{ Taxons }


        /* query taxon genomes */

            // submit queries
            Summary( Taxons )


        /* group taxons by availability */

            Summary.out.Info.branch{ taxon, json, count ->

                Available:   
                    !count.toInteger().equals(0)
                    return tuple( taxon, json, count )
            
                Unavailable: 
                    true
                    return taxon
            
                }.set{ SummaryGroups }

            // log unavailable taxons
            SummaryGroups.Unavailable.collectFile(
                   name : "${params.publishDir}/taxons-unavailable.txt",  
                newLine : true 
                ){ taxon -> "${taxon}" }

            // log available taxons        
            SummaryGroups.Available.collectFile(
                name : "${params.publishDir}/taxons-available.txt",  
                newLine : true 
                ){ taxon, json, count -> "${taxon}:${count}" }


        /* process available taxons */

            // convert summary to table
            Tabulate( SummaryGroups.Available )


            // extract accessions from table
            Tabulate.out.Info.flatMap{ taxon, jsonl, table -> 

                accessions = table.splitCsv( 
                    header : true,
                      skip : 0,
                       sep : '\t' 
                    ).collect{ entry -> 
                        tuple( taxon, entry.accession ) }
                
                return accessions

                }.set{ Accessions }


        /* download available accessions */

            if( params.ncbi_download ) {
            
                // specify ncbi server
                def NCBI_FTP_Site = "https://ftp.ncbi.nlm.nih.gov"

                // specify taxonomy urls
                Channel.of(
                    // kraken2 specific
                    "${NCBI_FTP_Site}/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz",
                    "${NCBI_FTP_Site}/pub/taxonomy/accession2taxid/nucl_wgs.accession2taxid.gz",
                    "${NCBI_FTP_Site}/pub/taxonomy/taxdump.tar.gz"

                    // krona specific
                    "${NCBI_FTP_Site}/pub/taxonomy/accession2taxid/dead_nucl.accession2taxid"
                    "${NCBI_FTP_Site}/pub/taxonomy/accession2taxid/dead_wgs.accession2taxid"
                    //"${NCBI_FTP_Site}/pub/taxonomy/accession2taxid/dead_prot.accession2taxid"
                    //"${NCBI_FTP_Site}/pub/taxonomy/accession2taxid/prot.accession2taxid"


                    ).set{ Urls }

                // download taxonomy data
                DownloadTaxonIDs( Urls )

                // download genomes
                DownloadGenomes( Accessions ) 
                
                // log downloaded genomes
                DownloadGenomes.out.Info.collectFile(
                    name : "${params.publishDir}/accessions-available.txt",  
                    newLine : true 
                    ){ fasta_dir, download -> "${fasta_dir}/${download.getName()}" }

                }
        
        }
