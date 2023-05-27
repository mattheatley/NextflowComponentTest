
/* INFORMATION */

// https://github.com/DerrickWood/kraken2


/* MODULES IMPORT */

    moduleDir = "../../modules"

    include { 
        Kraken2_Sequential_AddToLibrary as Kraken2SequentialAddToLibrary;
        } from "${moduleDir}/local/Metagenomics_Build_DB"



/* WORKFLOW DEFINITION */

    workflow SUBWORKFLOW { 
                
        println "\tBUILDING TAXONOMIC DATABASES\n"
    
        /* setup */

            // check source exists
            assert file(params.genomes_path).exists(): "Error ~ Directory not found; ${params.genomes_path}"

            // get all directory contents
            RefList = files("${params.genomes_path}/**.{fna,fa,fasta}")

            // convert directory contents to channel
            Channel.fromList( RefList ).set{ RefPaths }
            
            // consolidate reference paths into single file
            RefPaths.collectFile(
                    name : "${params.publishDir}/references-available.txt",  
                    newLine : true 
                    ){ path -> "${path}" }.set{ RefFile }


        /* sequential builds */

            // provide file containing genomes paths
            RefFile.multiMap{ file ->
                Kraken2: Additional: file
                }.set{ BuildSequential }

            Kraken2SequentialAddToLibrary( 
                Channel.value(params.database_name),
                Channel.fromPath( params.taxons_path ),
                BuildSequential.Kraken2,
                )


        /* parallel builds */

            // provide genome paths
            RefPaths.multiMap{ paths ->
                Additional: paths
                }.set{ BuildParallel }

        }
