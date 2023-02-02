

# check module name parsed
if [ -z $1 ]; then 

    echo "!!! NO MODULE SELECTED !!!"
    echo "EXITING..."
    exit 0

# specify command
else 

    WORKDIR="$(pwd)"
    WORKFLOW="$WORKDIR/Workflow.nf"
    CONFIG="$WORKDIR/Settings.config"
    PROFILE="local"
    MODULE="$1"

    COMMAND="nextflow run $WORKFLOW -c $CONFIG -profile $PROFILE --mod $MODULE"

fi

if [ -z $2 ]; then 

    echo "*** STARTING NEW RUN ***"

else

    if [ $2 != "resume" ]; then

        echo "!!! UNRECOGNISED ARGUMENT \"$2\" !!! "
        echo "EXITING..."
        exit 0

    else

        echo "*** RESUMING PREVIOUS RUN ***"

        COMMAND="$COMMAND -resume"
    fi
fi


# execute
echo "EXECUTING: $COMMAND"
eval $COMMAND
