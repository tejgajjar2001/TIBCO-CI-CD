#!/bin/sh
# Author: Tejas Gajjar
#================================================================
if [ $# != 3 ]
    then
        echo "USAGE:\ <uDeploy_WorkingDir> <domain_name> <cred_file>"
        exit 1
fi
exec_dt=`date +"%Y%m%d%H%M%S"`
TIBDF_SCRIPT=$TIB_HOME/udeploy/scripts;export TIBDF_SCRIPT
UD_DIR=$1; export UD_DIR
COMP_NAME=`echo $1|awk -F/ '{print $(NF-1)}'`; export COMP_NAME
DOM_NAME=$2; export DOM_NAME
CRED_FILE=$TRA_HOME/bin/creds/$3; export CRED_FILE
exportdir=/tibcodeploy/exports/${DOM_NAME}; export exportdir
export_dir=${exportdir}/export_${exec_dt}; export export_dir
EXPORT_FLAG="yes"; export EXPORT_FLAG
 . $TIBDF_SCRIPT/deploy.env.sh
echo -e "------------------------------------------------------"
echo -e " DF HOME: $DF_HOME    SCRIPTS: ${DF_SCRIPT:(-10)}  DF_TIB: $DF_TIB"


workingdir=$UD_DIR/artifacts
scriptloc=$DF_SCRIPT

# Check working directory log exists - create if necessary
# working dir exists as ant-hill copies the relevant artifacts there
if [ ! -d "${exportdir}" ]
then
mkdir -p ${exportdir}
echo -e "INFO :\t export Home directory created."
fi

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
$scriptloc/backuprepo.sh ${DOM_NAME} ${CRED_FILE} ${exportdir} >> $workingdir/logs/scripted_deploy.log
   if [ $? -eq 0 ]
        then
        sleep 3;
        echo -e "INFO:\t $0 Application Management log details." >> $workingdir/logs/appmgmt.log.archive
        echo -e "--------------------------------------------------------- " >> $workingdir/logs/appmgmt.log.archive
        cat $workingdir/logs/appmgmt.log >> $workingdir/logs/appmgmt.log.archive
        echo -e "--------------------------------------------------------- " >> $workingdir/logs/appmgmt.log.archive
        $LogFile >> $workingdir/logs/appmgmt.log.archive
        #cat $adminlog >> $workingdir/logs/appmgmt.log.archive
        #rm -f $adminlog
        echo -e "Export completed successfully."
        echo -e " -------------------------------------------------------- " >> $workingdir/logs/batchexecution.log
                if [[ $DOM_NAME =~ "_PRD" || $DOM_NAME =~ "_DRC" ]]; then
                        echo -e "Working on Scrubbing AppSecurity values for the export."
                        cd $export_dir
                        UD_DIR=$export_dir; export UD_DIR
                        $TIBDF_SCRIPT/AppSecurity.sh AppManage.batch ${appmanagedir}/AppSecurity.${DOM_NAME}.cred.proxy
                        exit 0;
                else
                        echo -e " Export completed for non production domain."
                        exit 0;
                fi
   else
        echo -e " -------------------------------------------------------- " >> $workingdir/logs/appmgmt.log.archive
        echo -e "INFO:\t $0 Application Management log details." >> $workingdir/logs/appmgmt.log.archive
        cat $adminlog >> $workingdir/logs/appmgmt.log.archive
        rm -f $adminlog
        echo -e "--------------------------------------------------------- " >> $workingdir/logs/appmgmt.log.archive
        echo -e "there were somthing wrong while export, please investigate."
        exit 1
    fi
