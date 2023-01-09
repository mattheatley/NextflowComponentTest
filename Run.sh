

# check module
if [ -z $1 ]; then 

    echo "NO MODULE SELECTED; EXITING..."
    exit 0

# specify command
else 

    WORKDIR="/Users/matt/Desktop/x.DEVOPS/Test"
    WORKFLOW="$WORKDIR/Workflow.nf"
    CONFIG="$WORKDIR/Settings.config"
    PROFILE="local"
    MODULE="$1"

    COMMAND="nextflow run $WORKFLOW -c $CONFIG -profile $PROFILE --mod $MODULE"

fi


# execute
echo "EXECUTING: $COMMAND"
eval $COMMAND
