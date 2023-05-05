
/* DOWNLOAD ACCESSION NCBI DATASETS GENOME */

    process DatasetDownload {

        container = 'staphb/ncbi-datasets:14.20.0'
        
        publishDir path : "${params.publishDir}/genome",
                pattern : "ncbi_dataset/data/*/*.fna",
                 saveAs : { path -> 
                    "${taxon_tag}/${accession}/${file(path).getName()}" },
                   mode : "copy",
              overwrite : true

        input:
            tuple val(taxon), val(accession)

        output:
            tuple val(taxon), val(accession), path("ncbi_dataset/data/*/*.fna"), emit: Sublist

        script:

            taxon_tag = taxon.replaceAll( "\\s", "_" )

            """
            # download genome zip archive

            datasets download genome \\
            --no-progressbar \\
            --filename ${taxon_tag}_${accession}.zip \\
            accession ${accession}


            # extract genome

            unzip *zip
            """
        
    /* 

    datasets version: 14.20.0

        Usage
            datasets download [command]

        Sample Commands
            datasets download genome accession GCF_000001405.40 --chromosomes X,Y --exclude-gff3 --exclude-rna
            datasets download genome taxon "bos taurus"
            datasets download gene gene-id 672
            datasets download gene symbol brca1 --taxon mouse
            datasets download gene accession NP_000483.3
            datasets download virus genome taxon sars-cov-2 --host dog
            datasets download virus protein S --host dog --filename SARS2-spike-dog.zip

        Available Commands
            gene        Download a gene data package
            genome      Download a genome data package
            virus       Download a virus data package

        Flags
            --filename string   Specify a custom file name for the downloaded data package (default "ncbi_dataset.zip")
            --no-progressbar    Hide progress bar


        Global Flags
            --api-key string   Specify an NCBI API key
            --debug            Emit debugging info
            --help             Print detailed help about a datasets command
            --version          Print version of datasets



    download directory structure
        .
        |-- README.md
        |-- ncbi_dataset
        |   `-- data
        |       |-- ACCESSION
        |       |   `-- GENOME.fna
        |       |-- assembly_data_report.jsonl
        |       `-- dataset_catalog.json
        `-- accession.zip

    */

        }
