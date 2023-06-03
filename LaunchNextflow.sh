#!/usr/bin/env bash


# SETUP 

# specify help message

showHelp() {
    
cat << EOF  

$1

Usage: $(basename $0) -s <system> -p <settings> [-r <directory> -e <conda_environment> -c]

-h     Display help.

-s     Specify nextflow config profile

-p     Specify nextflow params-file

-r     Specify previous directory to resume pipeline from

-e     Specify conda environment to activate

-c     Clean up cache and work directories

EOF
exit 0 
}


# specify defaults

SETTINGS="default"


# parse arguments

while getopts ':he:s:p:r:c' OPT; do

    case "$OPT" in

        h) showHelp "Launch script to run & resume nextflow pipelines" ;;

        e) CONDA_ENV="$OPTARG" ;;

        s) PROFILE="$OPTARG" ;;

        p) SETTINGS="$OPTARG" ;;

        r) DIR2RESUME="$OPTARG" ;;

        c) CLEAN=1 ;;

        ?) showHelp "Error ~ Incorrect arguments provided" ;;
    
    esac

done; shift "$(($OPTIND -1))"



# ENVIRONMENT ACTIVATE

if [ $CONDA_ENV ]; then

    source $HOME/.bash_profile # activate user environment

    eval "conda activate $CONDA_ENV" # activate nextflow conda environment

    # check status
    case "$?" in

        0)  # OK
            echo -e "\n>>> Activated \"$CONDA_DEFAULT_ENV\" environment" ;;

        ?)  # ERROR
            echo -e "\nError ~ Setup aborted with exit code $?.\n"
            exit 0 ;;

    esac

fi


# specify working directory & pipeline struture

WORKDIR="$(pwd)"

PIPEDIR="$WORKDIR/pipeline"

WORKFLOW="$PIPEDIR/main.nf"

CONFIG="$PIPEDIR/nextflow.config"

PARAMDIR="$PIPEDIR/params"


# RESUME SETTINGS

if [ $DIR2RESUME ]; then
    
    echo -e "\n>>> Inferring settings from directory label."

    IFS=_ read -r TAG PROFILE SETTINGS DATE TIME <<< "$DIR2RESUME"

fi


# SYSTEM CHECKS

if [ -z $PROFILE ]; then # no profile provided

    showHelp "Error ~ System not provided: Check config file for available profiles; $CONFIG"

fi


# SETTINGS CHECKS; TBC

PARAMETERS=($(ls -1 $PARAMDIR/$SETTINGS.{json,yml,yaml} 2> /dev/null)) # list parameters found; error suppressed

if [ -z $PARAMETERS ]; then # no parameters provided

    showHelp "Error ~ Settings not found: Check parameter directory for available files; $PARAMDIR"

elif [ "${#PARAMETERS[@]}" -gt 1 ]; then # multiple parameter formats found

    showHelp "Error ~ Multiple settings found: *** TBC *** ; $(printf "\n\n\t> %s" "${PARAMETERS[@]}")"

fi


# RESUME CHECKS

# specify launch directory
DIR2START="launch_${PROFILE}_${SETTINGS}"

NF_LAUNCH_DIR_NEW="$WORKDIR/$DIR2START"

NF_LAUNCH_DIR_OLD="$WORKDIR/$DIR2RESUME"

if [ -z $DIR2RESUME ]; then

    echo -e "\n*** Starting New Run ***"

    DATE_TIME=$(date '+%Y.%m.%d_%H.%M.%S') # get current datetime
    
    NF_LAUNCH_SUBDIR="${NF_LAUNCH_DIR_NEW}_${DATE_TIME}" # label launch directory

else

    echo -e "\n*** Resuming Old Run ***"

    if [ ! -d $NF_LAUNCH_DIR_OLD ]; then # previous launch directory not found

        showHelp "Error ~ Directory not found: Check working directory for available options; $WORKDIR"
            
    elif [[ ! "$NF_LAUNCH_DIR_OLD" == ${NF_LAUNCH_DIR_NEW}_* ]]; then # previous launch directory format unexpected

        showHelp "Error ~ Directory format unexpected: Check prefix matches \"$(basename $NF_LAUNCH_DIR_NEW)\"; $NF_LAUNCH_DIR_OLD"
        
    else
    
        NF_LAUNCH_SUBDIR=$NF_LAUNCH_DIR_OLD # specify relevant launch directory
    
        RESUME="-resume"

    fi # checks; RESUME

fi # mode; NEW|RESUME



# LAUNCH 

# create & move to launch directory as required
echo -e "\n>>> Changing To: $NF_LAUNCH_SUBDIR"
mkdir -p $NF_LAUNCH_SUBDIR; cd $NF_LAUNCH_SUBDIR
echo -e "\n>>> Launching From: $(pwd)"

# specify launch command
IFS='' read -r -d '' CMD << EOF
    nextflow \\
    -C $CONFIG \\
    run $WORKFLOW \\
    $RESUME \\
    -profile $PROFILE \\
    -params-file $PARAMETERS
EOF

echo -e "\nEXECUTING:\n\n$CMD\n"
eval "$CMD" # execute nextflow 

# check status
case "$?" in

    0)  # OK
        echo -e "\n>>> Workflow Complete." ;;

    ?)  # ERROR
        echo -e "\nError ~ Workflow aborted with exit code $?.\n"
        exit 0 ;; 

esac


# PLOT DAG

DOT=$(which dot) # check graphviz installed

DAG=$(ls -t logs/reports*/*.dot 2> /dev/null | head -n 1) # find latest dag; error suppressed

if [ -z $DOT ] || [ -z $DAG ]; then # DAG dependencies missing

    echo -e "\n*** Unable to plot DAG ***"

else # Graphiv installed & DAG found

    echo -e "\n>>> Generating DAG..."

    eval "dot -Tpdf $DAG -O" # execute graphviz
    
    eval "cp ${DAG}.pdf $WORKDIR/dag_latest.pdf" # publish latest dag

    echo -e ">>> Done."

fi # checks; plot


# CLEAN UP

if [ $CLEAN ]; then
    
    echo -e "\n>>> Cleaning up workflow directory..."

    eval "nextflow clean -force -keep-logs -quiet -but none" # execute clean

    echo -e ">>> Done."

    # remove singularity cache directory layers; ~/.singularity/cache
    # singularity cache clean -f

    # remove nextflow singularity cache images; cacheDir
    # rm -r ./singularity

fi # checks; clean

echo -e "\n>>> Finished.\n"
