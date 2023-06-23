#!/usr/bin/env bash

# SETUP 

# specify help message
showHelp() {
    
cat << EOF  

$1

Usage: $(basename $LAUNCHER) -s <system> -p <settings> [-r <directory> -e <conda_environment> -c -t -q]

-h     Display help.

-s     Specify nextflow config profile

-p     Specify nextflow params-file

-r     Specify previous directory to resume pipeline from

-e     Specify conda environment to activate

-c     Clean up cache and work directories

-t     Test run

-q     Launch nextflow via qsub

EOF

exit 0 

}

exec() {

eval "$1"

case "$?" in

    0)  ;;

    ?)  # ERROR
        echo -e "\n>>> ResumeDir: $(basename $NF_LAUNCH_SUBDIR)"

        echo -e "\nError ~ Execution aborted with exit code $?.\n"

        exit 0 ;; 

esac

}

# parse arguments

OPTARGS="$@"
SETTINGS="default"

while getopts ':he:s:p:r:ctq' OPT; do

    case "$OPT" in

        h) showHelp "Launch script to run & resume nextflow pipelines" ;;

        e) CONDA_ENV="$OPTARG" ;;

        s) PROFILE="$OPTARG" ;;

        p) SETTINGS="$OPTARG" ;;

        r) DIR2RESUME="$OPTARG" ;;

        c) CLEAN=1 ;;

        t) TEST=1 ;;

        q) QSUB=1 ;;

        ?) showHelp "Error ~ Incorrect arguments provided" ;;
    
    esac

done; shift "$(($OPTIND -1))"


# RESUME SETTINGS

if [ -z "$DIR2RESUME" ]; then

    echo -e "\n*** Starting New Run ***"

else
    
    echo -e "\n*** Resuming Old Run ***"

    IFS=_ read -r TAG PROFILE SETTINGS DATE TIME <<< "$DIR2RESUME"

    echo -e "\n*** Previous Settings Inferred ***"

fi


# SPECIFY PIPELINE STRUCTURE

LAUNCHER=$(readlink -f $0)

WORKDIR=$(dirname $LAUNCHER)

PIPEDIR="$WORKDIR/pipeline"

WORKFLOW="$PIPEDIR/main.nf"

CONFIG="$PIPEDIR/nextflow.config"

PARAMDIR="$PIPEDIR/params"


# ACTIVATE ENVIRONMENT

if [ $CONDA_ENV ]; then

    echo -e "\n>>> Running setup..."

    exec "source $HOME/.bash_profile" # activate user environment

    exec "conda activate $CONDA_ENV" # activate nextflow conda environment
    
    echo -e "\n*** Activated \"$CONDA_DEFAULT_ENV\" Environment ***"

fi


# CHECK SYSTEM

if [ -z $PROFILE ]; then # no profile provided

    showHelp "Error ~ System not provided: Check config file for available profiles; $CONFIG"

fi


# CHECK SETTINGS; TBC

PARAMETERS=($(ls -1 $PARAMDIR/$SETTINGS.{json,yml,yaml} 2> /dev/null)) # list parameters found; error suppressed

if [ -z $PARAMETERS ]; then # no parameters provided

    showHelp "Error ~ Settings not found: Check parameter directory for available files; $PARAMDIR"

elif [ "${#PARAMETERS[@]}" -gt 1 ]; then # multiple parameter formats found

    showHelp "Error ~ Multiple settings found: *** TBC *** ; $(printf "\n\n\t> %s" "${PARAMETERS[@]}")"

fi


# TEST MODE

if [ $TEST ]; then

    DRYRUN=".DRYRUN"
    STUB="-stub"

fi


# CHECK PREVIOUS LAUNCH

# specify launch directory
DIR2START="launch_${PROFILE}_${SETTINGS}"

NF_LAUNCH_DIR_NEW="$WORKDIR/$DIR2START"

NF_LAUNCH_DIR_OLD="$WORKDIR/$DIR2RESUME"

if [ -z $DIR2RESUME ]; then

    DATE_TIME=$(date '+%Y.%m.%d_%H.%M.%S') # get current datetime
    
    NF_LAUNCH_SUBDIR="${NF_LAUNCH_DIR_NEW}_${DATE_TIME}${DRYRUN}" # label launch directory

else

    if [ ! -d $NF_LAUNCH_DIR_OLD ]; then # previous launch directory not found

        showHelp "Error ~ Directory not found: Check working directory for available options; $WORKDIR"
            
    elif [[ ! "$NF_LAUNCH_DIR_OLD" == ${NF_LAUNCH_DIR_NEW}_* ]]; then # previous launch directory format unexpected

        showHelp "Error ~ Directory format unexpected: Check prefix matches \"$(basename $NF_LAUNCH_DIR_NEW)\"; $NF_LAUNCH_DIR_OLD"
        
    else
    
        NF_LAUNCH_SUBDIR=$NF_LAUNCH_DIR_OLD # specify relevant launch directory
    
        RESUME="-resume"

    fi # checks; RESUME

fi # mode; NEW|RESUME



# PREPARE LAUNCH

# create launch directory
exec "mkdir -p $NF_LAUNCH_SUBDIR"

# specify pipeline execution command
IFS='' read -r -d '' LAUNCH_COMMAND << EOF
    nextflow \\
        -C $CONFIG \\
        run $WORKFLOW \\
        $RESUME \\
        $STUB \\
        -profile $PROFILE \\
        -params-file $PARAMETERS
EOF

LAUNCH_COMMAND=$(grep -v '^\s*\\' <<< "$LAUNCH_COMMAND")

echo -e "\nEXECUTING:\n\n$LAUNCH_COMMAND\n"



# LAUNCH

if [ "$QSUB" ]; then

    # RESUBMIT

    # remove qsub flag
    QSUBARGS=$(sed 's/ -q//g' <<< "$OPTARGS")

    # set to resume
    if [ -z "$DIR2RESUME" ]; then

        QSUBARGS+=" -r $(basename $NF_LAUNCH_SUBDIR)"

    fi

    # specify wrapper resubmission command
    IFS='' read -r -d '' RESUBMIT_COMMAND << EOF
    qsub \\
        -N launch \\
        -P applications \\
        -q all.q \\
        -l m_mem_free=2G \\
        -j y \\
        -b y \\
        -wd $NF_LAUNCH_SUBDIR \\
        $LAUNCHER \\
        $QSUBARGS 
EOF

    echo -e "\nRESUBMITTING:\n\n$RESUBMIT_COMMAND\n"

    exec "$RESUBMIT_COMMAND"

    echo -e "\n>>> Re-Launched via qsub.\n"

else

    # LAUNCH

    # move to launch directory
    exec "cd $NF_LAUNCH_SUBDIR"

    echo -e "\n>>> LaunchDir: $(basename $(pwd))\n"

    # launch pipeline
    exec "$LAUNCH_COMMAND"


    # PLOT DAG

    DOT=$(which dot) # check graphviz installed

    DAG=$(ls -t logs/*/*.dot 2> /dev/null | head -n 1) # find latest dag; error suppressed

    if [ -z $DOT ] || [ -z $DAG ]; then # DAG dependencies missing

        echo -e "\n*** Unable to plot DAG ***"

    else # Graphiv installed & DAG found

        echo -e "\n>>> Generating DAG..."

        exec "dot -Tpdf $DAG -O" # execute graphviz
        
        exec "cp ${DAG}.pdf $WORKDIR/dag_latest.pdf" # publish latest dag

    fi # checks; plot


    # CLEAN UP

    if [ $CLEAN ]; then
        
        echo -e "\n>>> Cleaning up workflow directory..."

        exec "nextflow clean -force -keep-logs -quiet -but none" # execute clean

        exec "tar -cf workClean.tar work" # archive .command files

        exec "rm -r work" # remove cleaned work directory

        # remove singularity cache directory layers; ~/.singularity/cache
        # singularity cache clean -f

        # remove nextflow singularity cache images; cacheDir
        # rm -r ./singularity

    fi # checks; clean

    echo -e "\n>>> ResultDir: $(basename $NF_LAUNCH_SUBDIR)"

    echo -e "\nDONE\n"

fi # CHECK; LAUNCH NEXTFLOW
