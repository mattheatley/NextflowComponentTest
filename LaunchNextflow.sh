#!/usr/bin/env bash

# aim:
# individual launch directory avoids session .nextflow conflict on resume

# usage:
# bash LaunchNextflow.sh PROFILE PARAMETERS [PREVIOUS_LAUNCH_SUBDIRECTORY] 


####################
# DEPENDENCIES
####################

# activate user environment
# source $HOME/.bash_profile

# specify/activate nextflow conda environment
# CONDA_ENV="nf-core_v2.6_env"
# conda activate $CONDA_ENV

# UoN-specific singularity steps
if [[ "$1" == "augusta" ]]; then

    # alter permissions for newly created files (default: umask 0027)
    umask 0022

    # specify/load singularity environment module
    SINGULARITY_MOD="singularity/3.4.2"
    module load $SINGULARITY_MOD

fi

# remove singularity cache directory layers; ~/.singularity/cache
# singularity cache clean -f
# remove nextflow singularity cache images; cacheDir
# rm -r ./singularity


####################
# SETUP 
####################

printf "\nRunning Launch Script\n\n"

PIPEDIR="$(pwd)/pipeline"

WORKFLOW="$PIPEDIR/main.nf"

CONFIG="$PIPEDIR/nextflow.config"

PARAMDIR="$PIPEDIR/params"

PARAMTAG="$2"


# define basic command

COMMAND="nextflow -C $CONFIG run $WORKFLOW"

# define argument info

#       "KEY       ; FLAG         ; ARG"
ARRAY=( "System   ; -profile     ; $1"
        "Settings ; -params-file ; $2"
        "Mode     ; -resume      ; $3" )



####################
# PROCESS ARGUMENTS
####################

for IDX in "${!ARRAY[@]}" ; do # cycle array indicies...

    CURRENT=$(echo ${ARRAY[$IDX]} | tr -d " ") # extract element via 0-based index & delete whitespace

    let IDX+=1 # adjust 0-based index via arithmetic expression to 1-based count

    IFS=';' read -r -a INFO <<< "$CURRENT" # split entry into array by delimiter
    
    KEY="${INFO[0]}"; FLAG="${INFO[1]}"; ARG="${INFO[2]}" # extract entry info



    ####################
    # INITIAL ARGUMENTS
    ####################

    if [ "$IDX" -lt "${#ARRAY[@]}" ]; then # 1-based count less than array length
    
        echo "*** $KEY: $ARG ***"
    
        if [ -z $ARG ]; then # profile or parameters not parsed

            echo "!!! No $KEY Selected !!!"; exit 0 # raise error & exit
        
        else # profile or parameters parsed

            if [ "$IDX" -eq 2 ]; then # parameters parsed

                ARG=($(ls -1 $PARAMDIR/$ARG.{json,yaml} 2> /dev/null)) # list parameters found with error suppressed

                if [ -z $ARG ]; then # no parameters found

                    echo "!!! No Parameters Found !!!"; exit 0 # raise error & exit

                elif [ "${#ARG[@]}" -gt 1 ]; then # both json & yaml parameters found

                    echo "!!! Multiple Parameters Found !!!"; printf "%s\n" "${ARG[@]}"; exit 0 # raise error & exit
                    
                fi # input checks; SETTINGS

            fi # argument checks; SETTINGS

            COMMAND+=" $FLAG $ARG" # log parsed settings

        fi # argument checks; INITIAL

    

    ####################
    # FINAL ARGUMENT
    ####################

    else # 1-based count equals array length

        #NF_WORK_SUBDIR="work-$PARAMTAG"; COMMAND+=" -w $NF_WORK_SUBDIR" # specify work directory

        NF_RUN_DIR="$(pwd)"; NF_LAUNCH_SUBDIR="$NF_RUN_DIR/launch-$PARAMTAG"; NF_LAUNCH_PREVIOUS="$NF_RUN_DIR/$ARG" # specify launch directory

        if [ -z $ARG ]; then # previous launch directory not parsed

            echo "*** Starting New Run ***"
            
            NF_LAUNCH_SUBDIR+="_$(date '+%Y%m%d%H%M%S')" # label launch directory with datetime

        else # previous launch directory parsed

            echo "*** Resuming Old Run ***"

            if [ ! -d $NF_LAUNCH_PREVIOUS ]; then # parsed launch directory not found
                
                echo "!!! No \"$ARG\" Directory to Resume"; exit 0 # raise error & exit
            
            elif [ ! $NF_LAUNCH_PREVIOUS == $NF_LAUNCH_SUBDIR* ]; then # parsed launch directory format does not conform

                echo "!!! \"$ARG\" Incompatible With \"$(basename $NF_LAUNCH_SUBDIR)\" !!!"; exit 0 # raise error & exit
        
            else # parsed launch directory found & formatted correctly

                NF_LAUNCH_SUBDIR=$NF_LAUNCH_PREVIOUS; COMMAND+=" $FLAG" # specify launch directory branch

            fi # input checks; RESUME

        fi # mode type; START|RESUME

    fi # argument type; INITIAL|FINAL

done



####################
# LAUNCH PIPELINE
####################

# create & move to launch directory
printf "\n>>> Changing To: $NF_LAUNCH_SUBDIR\n"
mkdir -p $NF_LAUNCH_SUBDIR; cd $NF_LAUNCH_SUBDIR
printf "\n>>> Launching From: $(pwd)\n"

# execute nextflow command 
printf "\nEXECUTING: $COMMAND\n\n"
#eval $COMMAND



####################
# PLOT DAG
####################

DAG=$(ls -t logs/reports*/*.dot 2> /dev/null | head -n 1) # list latest dag with error suppressed

if [ -z $DAG ]; then # DAG not generated

    echo "!!! No DAG Found !!!"; exit 0 # raise error & exit

else # DAG generated

    # execute graphviz command
    COMMAND="dot -Tpdf $DAG -O"
    printf "\nEXECUTING: $COMMAND\n\n"
    eval $COMMAND

fi # argument checks; DAG
