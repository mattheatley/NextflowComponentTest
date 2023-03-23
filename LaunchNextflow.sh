#!/usr/bin/env bash

# aim:
# individual launch directory avoids session .nextflow conflict on resume

# usage:
# bash Launch.sh PROFILE MODULE [PREVIOUS_LAUNCH_DIRECTORY] 



####################
# SETUP 
####################

# define pipeline files
PIPEDIR="$(pwd)/nf"
WORKFLOW="$PIPEDIR/Workflow.nf"
CONFIG="$PIPEDIR/Settings.config"

# define basic command
COMMAND="nextflow run $WORKFLOW -c $CONFIG"

# define array
#       "KEY    ; FLAG     ; ARG"
ARRAY=( "System ; -profile ; $1"
        "Module ; --mod    ; $2"
        "Mode   ; -resume  ; $3" )

# specify session tag 
SESSION_TAG="$2"



####################
# PROCESS ARGUMENTS
####################

printf "\nSETTINGS:\n\n"

for IDX in "${!ARRAY[@]}" ; do # cycle array indicies...

    CURRENT=$(echo ${ARRAY[$IDX]} | tr -d " ") # extract element via index & delete whitespace

    IFS=';' read -r -a INFO <<< "$CURRENT" # split entry into array by delimiter
    
    KEY="${INFO[0]}"; FLAG="${INFO[1]}"; ARG="${INFO[2]}" # extract entry info

    let IDX+=1 # adjust 0-based index via arithmetic expression to 1-based count



    ####################
    # INITIAL ARGUMENTS
    ####################

    if [ "$IDX" -lt "${#ARRAY[@]}" ]; then # 1-based count less than array length
    
        if [ -z $ARG ]; then # profile or module not parsed

            echo "!!! No $KEY Selected !!!"; exit 0 # raise error & exit
        
        else # profile or module parsed
        
            echo "*** $KEY: $ARG ***"; COMMAND+=" $FLAG $ARG" # log parsed settings

        fi # argument checks; INITIAL



    ####################
    # FINAL ARGUMENT
    ####################

    else # 1-based count equals array length
    
        NF_WORK_SUBDIR="work-$SESSION_TAG"; COMMAND+=" -w $NF_WORK_SUBDIR" # specify work directory

        NF_RUN_DIR="$(pwd)"; NF_LAUNCH_SUBDIR="$NF_RUN_DIR/launch-$SESSION_TAG"; NF_LAUNCH_PREVIOUS="$NF_RUN_DIR/$ARG" # specify launch directory

        if [ -z $ARG ]; then # previous launch directory not parsed

            echo "*** Starting New Run ***"
            
            NF_LAUNCH_SUBDIR+="_$(date '+%Y%m%d-%H%M%S')" # label launch directory with datetime

        else # previous launch directory parsed

            echo "*** Resuming Old Run ***"

            if [ ! -d $NF_LAUNCH_PREVIOUS ]; then # parsed launch directory not found
                
                echo "!!! No \"$ARG\" Directory to Resume"; exit 0 # raise error & exit
            
            elif [ ! $NF_LAUNCH_PREVIOUS == $NF_LAUNCH_SUBDIR* ]; then # parsed launch directory format does not conform

                echo "!!! \"$ARG\" Incompatible With \"$(basename $NF_LAUNCH_SUBDIR)\" !!!"; exit 0 # raise error & exit
        
            else # parsed launch directory found & formatted correctly

                NF_LAUNCH_SUBDIR=$NF_LAUNCH_PREVIOUS; COMMAND+=" $FLAG" # specify launch directory branch

            fi # mode checks; RESUME

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

# execute command
printf "\nEXECUTING: $COMMAND\n\n"
eval $COMMAND

