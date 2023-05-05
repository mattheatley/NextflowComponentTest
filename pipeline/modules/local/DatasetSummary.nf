
/* DOWNLOAD TAXON NCBI DATASETS GENOME SUMMARY */

    process DatasetSummary {

        container = 'staphb/ncbi-datasets:14.20.0'
        
        publishDir path : "${params.publishDir}/summary",
                pattern : "*.jsonl",
                   mode : "copy",
              overwrite : true

        input:
            val(taxon)

        output:
            tuple val(taxon), path("*.jsonl"), env(count), emit: Sublist

        script:

            jsonl = params.ncbi_jsonl ? "--as-json-lines" : ""

            // i.e. assembly_info.atypical.warnings = "contaminated" or "unverified source organism"
            exclude_atypical = params.ncbi_exclude_atypical ? "--exclude-atypical" : ""

            // i.e. assembly_info.refseq_category = "representative genome"
            reference = params.ncbi_reference ? "--reference" : ""

            taxon_tag = taxon.replaceAll( "\\s", "_" )

            """
            # download summary in JSONL format

            datasets summary genome \\
            --assembly-level ${params.ncbi_assembly_levels} \\
            --assembly-source ${params.ncbi_assembly_source} \\
            --mag ${params.ncbi_mag} \\
            ${jsonl} \\
            ${exclude_atypical} \\
            ${reference} \\
            taxon "${taxon}" > ${taxon_tag}.jsonl
            
            
            # count JSONL lines (equivalent to JSON 'total_count')
            
            count=\$(wc -l ${taxon_tag}.jsonl | cut -d ' ' -f 1)
            """

    /* 

    datasets version: 14.20.0
        
        Usage
            datasets summary genome taxon [flags]

        Sample Commands
            datasets summary genome taxon human
            datasets summary genome taxon "mus musculus"
            datasets summary genome taxon 10116

        Flags
            --assembly-version string   Limit to 'latest' assembly accession version or include 'all' (latest + previous versions)
                                            (default "latest")


        Global Flags
            --annotated                Limit to annotated genomes
            --api-key string           Specify an NCBI API key
            --as-json-lines            Output results in JSON Lines format
            --assembly-level string    Limit to genomes at one or more assembly levels (comma-separated):
                                        * chromosome
                                        * complete
                                        * contig
                                        * scaffold
                                            (default "[]")
            --assembly-source string   Limit to 'RefSeq' (GCF_) or 'GenBank' (GCA_) genomes (default "all")
            --debug                    Emit debugging info
            --exclude-atypical         Exclude atypical assemblies
            --help                     Print detailed help about a datasets command
            --limit string             Limit the number of genome summaries returned
                                        * all:      returns all matching genome summaries
                                        * a number: returns the specified number of matching genome summaries
                                            (default "all")
            --mag string               Limit to metagenome assembled genomes (only) or remove them from the results (exclude) (default "all")
            --reference                Limit to reference genomes
            --released-after string    Limit to genomes released on or after a specified date (MM/DD/YYYY)
            --released-before string   Limit to genomes released on or before a specified date (MM/DD/YYYY)
            --report string            Choose the output type:
                                        * genome:   Retrieve the primary genome report
                                        * sequence: Retrieve the sequence report
                                        * ids_only: Retrieve only the genome identifiers
                                            (default "genome")
            --search strings           Limit results to genomes with specified text in the searchable fields:
                                        species and infraspecies, assembly name and submitter.
                                        To search multiple strings, use the flag multiple times.
            --version                  Print version of datasets

    */

        }
