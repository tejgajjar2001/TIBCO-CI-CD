# ############################################################
# Author:   Tejas Gajjar
# ===========================================================
# Executes the deployment framwork option for BatchStop
# ############################################################
#!/bin/sh
if [ $# != 4 ]
    then
        echo "USAGE:\ <uDeploy_WorkingDir> <DOMAIN_NAME> <cred_file> <UNDEPLOY.batch>"
        exit 1
fi

TIBDF_SCRIPT=$TIB_HOME/udeploy/scripts; export TIBDF_SCRIPT
UD_DIR=$1; export UD_DIR
COMP_NAME=`echo $1|awk -F/ '{print $(NF-1)}'`; export COMP_NAME
COMP_NAME=$1; export COMP_NAME
DOM_NAME=$2; export DOM_NAME
CRED_FILE=$TRA_HOME/bin/creds/$3; export CRED_FILE

 . $TIBDF_SCRIPT/deploy.env.sh
echo -e "------------------------------------------------------"
echo -e " DF HOME: $DF_HOME    SCRIPTS: ${DF_SCRIPT:(-10)}  DF_TIB: $DF_TIB"

scriptloc=$TIBDF_SCRIPT; export scriptloc
#master_cred=$TRA_HOME/bin/$3; export master_cred
master_cred=$CRED_FILE; export master_cred
workingdir=$UD_DIR/artifacts


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
adminlog="$TIB_HOME/tra/domain/${DOM_NAME}/logs/ApplicationManagement.log"
$scriptloc/batchundeploy.sh ${UD_DIR} ${DOM_NAME} ${master_cred} ${4} >> $workingdir/logs/scripted_deploy.log
   if [ $? -eq 0 ]
        then
        echo -e "BatchUndeploy completed successfully."
        cat $workingdir/logs/scripted_deploy.log >> $workingdir/logs/batchexecution.log
        echo -e " -------------------------------------------------------- " >> $workingdir/logs/batchexecution.log
        sleep 3;
        echo -e "INFO:\t $0 Application Management log details." >> $workingdir/logs/appmgmt.log.archive
        echo -e "--------------------------------------------------------- " >> $workingdir/logs/appmgmt.log.archive
        cat $adminlog >> $workingdir/logs/appmgmt.log.archive
        #cat $workingdir/logs/appmgmt.log >> $workingdir/logs/appmgmt.log.archive
        echo -e "---------------------------------------------------------\n\n " >> $workingdir/logs/appmgmt.log.archive
        rm -f $adminlog
        exit 0;
   else
        echo -e "there were somthing wrong while batchUndeploy, please investigate."
        cat $workingdir/logs/scripted_deploy.log >> $workingdir/logs/batchexecution.log
        echo -e " -------------------------------------------------------- " >> $workingdir/logs/batchexecution.log
        echo -e " -------------------------------------------------------- " >> $workingdir/logs/appmgmt.log.archive
        echo -e "INFO:\t $0 Application Management log details." >> $workingdir/logs/appmgmt.log.archive
        cat $adminlog >> $workingdir/logs/appmgmt.log.archive
        #cat $workingdir/logs/appmgmt_${exec_dt}.log >> $workingdir/logs/appmgmt.log.archive
        echo -e "---------------------------------------------------------\n\n " >> $workingdir/logs/appmgmt.log.archive
        rm -f $adminlog
        exit 1
   fi
