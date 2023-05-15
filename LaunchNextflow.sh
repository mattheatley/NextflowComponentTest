#!/usr/bin/env bash


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

# specify help message

showHelp() {
    
cat << EOF  

$1

Usage: $(basename $0) -s <system> -p <settings> [-r <directory>]

-h     Display help.

-s     Specify nextflow config profile

-p     Specify nextflow params-file

-r     Specify previous directory to resume pipeline from

EOF
exit 0 
}


# specify defaults

SETTINGS="default"


# parse arguments

while getopts ':hs:p:r:' OPT; do

    case "$OPT" in

        h) showHelp "Launch script to run & resume nextflow pipelines" ;;

        s) PROFILE="$OPTARG" ;;

        p) SETTINGS="$OPTARG" ;;

        r) DIR2RESUME="$OPTARG" ;;

        ?) showHelp "Error ~ Incorrect arguments provided" ;;
    
    esac

done; shift "$(($OPTIND -1))"


# extract directory label info

if [ $DIR2RESUME ]; then

    IFS=_ read -r TAG PROFILE SETTINGS DATETIME <<< "$DIR2RESUME"

fi


# specify working directory & pipeline struture

WORKDIR="$(pwd)"

PIPEDIR="$WORKDIR/pipeline"

WORKFLOW="$PIPEDIR/main.nf"

CONFIG="$PIPEDIR/nextflow.config"

PARAMDIR="$PIPEDIR/params"


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
            
    NF_LAUNCH_SUBDIR="${NF_LAUNCH_DIR_NEW}_$(date '+%Y%m%d%H%M%S')" # label launch directory with datetime

else

    echo -e "\n*** Resuming Old Run ***"

    if [ ! -d $NF_LAUNCH_DIR_OLD ]; then # previous launch directory not found

        showHelp "Error ~ Directory not found: Check working directory for available options; $WORKDIR"
            
    elif [ ! $NF_LAUNCH_DIR_OLD == ${NF_LAUNCH_DIR_NEW}_* ]; then # previous launch directory format unexpected

        showHelp "Error ~ Directory format unexpected: Check prefix matches \"$(basename $NF_LAUNCH_DIR_NEW)\"; $NF_LAUNCH_DIR_OLD"
        
    else

        NF_LAUNCH_SUBDIR=$NF_LAUNCH_DIR_OLD # specify relevant launch directory

    fi # checks; RESUME

fi # mode; NEW|RESUME


####################
# LAUNCH PIPELINE
####################

# create & move to launch directory as required
echo -e "\n>>> Changing To: $NF_LAUNCH_SUBDIR"
mkdir -p $NF_LAUNCH_SUBDIR; cd $NF_LAUNCH_SUBDIR
echo -e "\n>>> Launching From: $(pwd)"

# specify launch command
IFS='' read -r -d '' CMD << EOF
    nextflow \\
    -C $CONFIG \\
    run $WORKFLOW \\
    -profile $PROFILE \\
    -params-file $PARAMETERS
EOF

# execute nextflow 
echo -e "\nEXECUTING:\n\n$CMD\n"
eval "$CMD"


# PLOT DAG

DOT=$(which dot) # check graphviz installed

DAG=$(ls -t logs/reports*/*.dot 2> /dev/null | head -n 1) # fin latest dag; error suppressed

if [ -z $DOT ] || [ -z $DAG ]; then # DAG dependencies missing

    echo -e "\n*** Unable to plot DAG ***\n"; exit 0

else # Graphiv installed & DAG found

    echo -e "\nGenerating DAG\n"

    # execute graphviz
    COMMAND="dot -Tpdf $DAG -O"
    eval $COMMAND

    # publish latest dag
    COMMAND="cp ${DAG}.pdf $WORKDIR/dag_latest.pdf"
    eval $COMMAND

fi # checks; DAG
