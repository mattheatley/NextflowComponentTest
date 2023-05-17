
/* DOWNLOAD TAXONOMY NCBI DATASETS GENOME */

    process NCBI_TaxonIDs_Download {

        container = 'staphb/ncbi-datasets:14.20.0'
        
        publishDir path : "${params.publishDir}/taxonomy",
                pattern : "*{accession2taxid,taxdump}*",
                 saveAs : { download -> 
                    "${file(download).getName()}" },
                   mode : "copy",
              overwrite : true

        input:
            val(sourceFile)

        output:
            path("*{accession2taxid,taxdump}*"), emit: Info

        script:

            localFile  = "${file(sourceFile).getName()}"
            localMD5   = "local.md5"
            sourceMD5  = "source.md5"

            """
            # download taxonomy data

            wget -q ${sourceFile}

            # check wget status
            case "\$?" in
                0) echo "Download: Complete" ;;
                ?) echo "Download: Error (\$?)" ;;
            esac

            # download source md5sum
            wget -q -O ${sourceMD5} ${sourceFile}.md5

            # calculate local md5sum
            md5sum ${localFile} > ${localMD5}

            # compare local & source md5sums
            cmp ${sourceMD5} ${localMD5}

            # check cmp status
            case "\$?" in
                0) echo "MD5: Match" ;;
                ?) echo "MD5: Differ (\$?)" ;;
            esac

            """

        }
