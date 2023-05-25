# ############################################################
# Author: Tejas Gajjar
# ===========================================================
# Executes the deployment framwork option for BatchStop
# ############################################################
#!/bin/sh
if [ $# != 4 ]
    then
        echo "USAGE:\ <COMP_NAME_DIR_PATH> <DOMAIN_NAME> <SCRIPT_NAME> <HOST_NAME>"
        exit 1
fi

TIBDF_SCRIPT=$TIB_HOME/udeploy/scripts; export TIBDF_SCRIPT
UD_DIR=$1; export UD_DIR
COMP_NAME=`echo $1|awk -F/ '{print $(NF-1)}'`; export COMP_NAME
DOM_NAME=$2; export DOM_NAME

 . $TIBDF_SCRIPT/deploy.env.sh
echo -e "------------------------------------------------------"
echo -e " DF HOME: $DF_HOME    SCRIPTS: ${DF_SCRIPT:(-10)}  DF_TIB: $DF_TIB"
releasetag=$DF_HOME

scriptloc=$DF_SCRIPT; export scriptloc
workingdir=$releasetag/artifacts; export workingdir
#workingdir=$UD_DIR/artifacts
SCRIPT_PATH=${workingdir}/Appscripts; export SCRIPT_PATH
SCRIPT_FILE=${3}
HOST_NAME=${4}
OWNER=${tibconum}; export OWNER

# Check working directory log exists - create if necessary
# working dir exists as ant-hill copies the relevant artifacts there

if [ ! -d "${workingdir}/logs" ]; then
  mkdir ${workingdir}/logs
  echo -e "INFO : \t Log directory created at ${workingdir}/logs "

else
  # move scripted deploy logs to backup [ relevant in terms of repeat ]
  if [ -e "$workingdir/logs/scripted_deploy.log" ]; then
    cat $workingdir/logs/scripted_deploy.log >> $workingdir/logs/scripted_deploy.archive
    cat /dev/null > $workingdir/logs/scripted_deploy.log
    cat $workingdir/logs/batchexecution.log >> $workingdir/logs/batchexecution.archive
    cat /dev/null > $workingdir/logs/batchexecution.log
  fi
fi

echo -e " -------------------------------------------------------- " >> $workingdir/logs/scripted_deploy.log
echo " $appmanagedir - out  $TRA_HOME"
sh -x $scriptloc/executeShell.sh ${SCRIPT_FILE} ${HOST_NAME} >> $workingdir/logs/scripted_deploy.log
if [ $? -eq 0 ]
then
echo -e "script execution completed successfully."
cat $workingdir/logs/scripted_deploy.log >> $workingdir/logs/batchexecution.log
echo -e " -------------------------------------------------------- " >> $workingdir/logs/batchexecution.log
else
echo -e "there were somthing wrong while executing script, please investigate."
cat $workingdir/logs/scripted_deploy.log >> $workingdir/logs/batchexecution.log
echo -e " -------------------------------------------------------- " >> $workingdir/logs/batchexecution.log
exit 1
fi
