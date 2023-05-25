#! /bin/sh
# Author: Tejas Gajjar
#============================================================
if [ $# != 6 ]
    then
        echo "USAGE:\ <uDeploy_Dir> <DOMAIN_NAME> <EMS_SCRIPT_FILE.ems> <EMS_CRED_FILE> <EMS URL> <CERT_PATH>"
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

exec_dt=`date +"%Y%m%d%H%M%S"`
workingdir=$releasetag/artifacts; export workingdir
scriptloc=${TIBDF_SCRIPT}
appscriptloc=${workingdir}/Appscripts; export appscriptloc
scrname=$3
cred_file=${TRA_HOME}/bin/creds/$4
ems_url=$5
cert_path=$6; export cert_path
# Check working directory log exists - create if necessary
# working dir exists as ant-hill copies the relevant artifacts there
if [ ! -d "${workingdir}/logs" ]; then
  mkdir ${workingdir}/logs
  echo -e "INFO : \t Log directory created at ${workingdir}/logs "
else
  # move scripted ems execute logs to backup [ relevant in terms of repeat ]
  if [ -e "$workingdir/logs/scripted_deploy.log" ]; then
    cat $workingdir/logs/scripted_deploy.log >> $workingdir/logs/scripted_deploy.archive
    cat /dev/null > $workingdir/logs/scripted_deploy.log
    cat $workingdir/logs/batchexecution.log >> $workingdir/logs/batchexecution.archive
    cat /dev/null > $workingdir/logs/batchexecution.log
  fi
fi

if [ -e "${appscriptloc}/${scrname}" ]; then
         echo -e "INFO : \t $currtime Executing ... ${scrname}"
         echo -e "INFO : \t $currtime Executing ... ${scrname}" >> $workingdir/logs/script.${exec_dt}.log
         echo -e "INFO : \t $currtime Executing ... ${scrname}" >> $workingdir/logs/scripted_deploy.log
         echo -e "INFO : \t $currtime Executing ... ${scrname}" >> $workingdir/logs/batchexecution.log
       #echo " find credential and execute script"
       #ems credential file user=<uname> pwd=<pwd>
while read credline; do
          rdvar="${credline}"
           #  echo "0. DEBUG, ${rdvar}"
          chkuser="${rdvar:0:4}"
          #echo "checkUser: ${chkuser}"
          if [ "${chkuser}" = 'user' ]; then
             scrusr="${rdvar:5}"
            # echo "1. DEBUG, user-${rdvar} extracted: $scrusr"
          fi
          if [ "${chkuser}" = 'pwd=' ]; then
             scrpwd="${rdvar:4}"
            # echo "2. DEBUG, pwd-${rdvar} extracted: $scrpwd"
          fi
          chkuser=""
          rdvar=""
       done < ${cred_file}

${scriptloc}/executeEMS.sh ${scrname} ${ems_url} ${scrusr} ${scrpwd} >> "$workingdir/logs/script.${exec_dt}.log"
if [ $? -ne 0 ]; then
   echo -e  " EMS script execution failed , Please investigate."
   currtime=`date +"%Y%m%d %H:%M:%S"`
   echo -e "ERROR : \t $currtime << Executed    ${scrname} - with logs: $workingdir/logs/script.${exec_dt}.log"
   echo -e "ERROR : \t $currtime << Executed    ${scrname}" >> $workingdir/logs/scripted_deploy.log
   cat $workingdir/logs/script.${exec_dt}.log >> $workingdir/logs/batchexecution.log
   cat $workingdir/logs/batchexecution.log >> $workingdir/logs/batchexecution.archive
   exit 1;

else
    echo -e  " EMS script execution completed successfully."
    currtime=`date +"%Y%m%d %H:%M:%S"`
    echo -e "INFO : \t $currtime << Executed    ${scrname} - with logs: $workingdir/logs/script.${exec_dt}.log"
    echo -e "INFO : \t $currtime << Executed    ${scrname}" >> $workingdir/logs/scripted_deploy.log
    cat $workingdir/logs/script.${exec_dt}.log >> $workingdir/logs/batchexecution.log
    cat $workingdir/logs/batchexecution.log >> $workingdir/logs/batchexecution.archive

fi

else
   currtime=`date +"%Y%m%d %H:%M:%S"`
   echo -e "ERROR : \t $currtime Executing ... ${scrname} - not found in approved location." >> $workingdir/logs/script.${exec_dt}.log
   echo -e "ERROR : \t $currtime Executing ... ${scrname} not found in approved location." >> $workingdir/logs/batchexecution.log
   cat $workingdir/logs/script.${exec_dt}.log >> $workingdir/logs/batchexecution.log
   cat $workingdir/logs/batchexecution.log >> $workingdir/logs/batchexecution.archive
fi
