# ############################################################
# Author:   Tejas Gajjar
# ===========================================================
# Executes the deployment framwork option for AppSecurity
# the entire repository
# ############################################################
#!/bin/sh
if [ $# != 4 ]
    then
        echo "USAGE:\ <COMP_NAME> <DOMAIN_NAME> <AppManage.batch> <APP_SECURITY.cred>"
        exit 1
fi

TIBDF_SCRIPT=$TIB_HOME/udeploy/scripts; export TIBDF_SCRIPT
UD_DIR=$1; export UD_DIR
COMP_NAME=`echo $1|awk -F/ '{print $(NF-1)}'`; export COMP_NAME
DOM_NAME=$2; export DOM_NAME

#CRED_FILE=$TRA_HOME/bin/$3; export CRED_FILE
#exportdir=/tibcoapps/${DOM_NAME}/${COMP_NAME}; export exportdir

 . $TIBDF_SCRIPT/deploy.env.sh
echo -e "------------------------------------------------------"
echo -e " DF HOME: $DF_HOME    SCRIPTS: ${DF_SCRIPT:(-10)}  DF_TIB: $DF_TIB"


workingdir=$UD_DIR/artifacts;  export workingdir
scriptloc=$DF_SCRIPT; export scriptloc
master_cred=$TRA_HOME/bin/creds/$4; export master_cred


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
$scriptloc/AppSecurity.sh ${3} ${master_cred} >> $workingdir/logs/scripted_deploy.log
if [ $? -eq 0 ]
then
echo -e "AppSecurity value replacement completed successfully."
cat $workingdir/logs/scripted_deploy.log >> $workingdir/logs/batchexecution.log
echo -e " -------------------------------------------------------- " >> $workingdir/logs/batchexecution.log
else
echo -e "there were somthing wrong while AppSecurity value replacement, please investigate."
cat $workingdir/logs/scripted_deploy.log >> $workingdir/logs/batchexecution.log
echo -e " -------------------------------------------------------- " >> $workingdir/logs/batchexecution.log
exit 1
fi
