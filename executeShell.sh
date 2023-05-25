#!/bin/sh
# ############################################################
# Author:   Tejas Gajjar
# ===========================================================
# Script to execute shell scripts on target hosts
# ############################################################


exec_dt=`date +"%Y%m%d%H%M%S"`

# Echo Usage if prompted
chelp=`echo ${1} | tr '[A-Z]' '[a-z]'`
case ${chelp} in
  "help"|"-help"|"--help"|"?"|"-?"|"usage"|"-usage"|"-h")
   echo -e " \t ----------------------------------------------------------"
   echo -e " USAGE: $0 <COMP_NAME> <DOMAIN_NAME> <shellscript> <target_host> "
   echo -e " \t\t    <shellscript>:\t <app_id>-<script_name>-<version>.sh"
   echo -e " \t\t    <target_host>:\t  hostname - need to be tib* name"
   echo -e " \t ----------------------------------------------------------"
   exit 0
   ;;
  *)
   ;;
esac

sh_cmddir=${TIBDF_SCRIPT}
scrname=${1}
hosturl=${2}
workingdir=$UD_DIR/artifacts
scriptpath=${workingdir}
#scriptpath=${SCRIPT_PATH}
remotedir=/tibcoapps/udeploy

if [ -e "${scriptpath}/${scrname}" ]; then
   echo -e "INFO : \t $currtime Executing ... ${scrname}"
   echo -e "INFO : \t $currtime Executing ... ${scrname}" >> $workingdir/logs/script.${exec_dt}.log
   echo -e "INFO : \t $currtime Executing ... ${scrname}" >> $workingdir/logs/scripted_deploy.log
   echo -e "INFO : \t $currtime Executing ... ${scrname}" >> $workingdir/logs/batchexecution.log
fi


if [ ! -e "${sh_cmddir}" ]; then
  echo -e "ERROR: Unable to find ${sh_cmddir}"
  exit 1
fi

if [ ! -e "${scriptpath}/${scrname}" ]; then
  echo -e "ERROR: Unable to find script file ${scrname} in approved script"
  exit 1
else
  # read the right 4 chars to check the script naming
  if [ ! "${scrname:(-3)}" = ".sh" ]; then
     echo - e "ERROR: ${scrname} does not have valid sh extension."
     exit 1
  fi
fi

currdir=`pwd`
cd ${sh_cmddir}
#if [ -d "${workingdir}/$remotedir" ]; then
if [ -d "${workingdir}" ]; then
   echo -e "INFO : \t $currtime Executing ... ${scrname}"
scpstring="scp -prC "${UD_DIR}" ${OWNER}@${hosturl}:${remotedir}"
#scpstring="scp -prC "${workingdir}" ${OWNER}@${hosturl}:${remotedir}"
eval ${scpstring} >> $workingdir/logs/script.${exec_dt}.log
if [ $? -ne 0 ]; then
echo " O O... something went wrong while downloading package to target host, ${hosturl}. Please investigate."
exit 1;
fi
sleep 5;
#sshstring="ssh ${OWNER}@${hosturl} 'bash -s' < ${scriptpath}/${scrname}"
sshstring="ssh ${OWNER}@${hosturl} 'sh ${remotedir}/${DOM_NAME}/artifacts/runShell.sh'"
eval ${sshstring} >> $workingdir/logs/script.${exec_dt}.log
if [ $? -ne 0 ]; then
echo " O O... something went wrong while executing sh script on ${hosturl}. Please investigate."
exit 1;
fi
#ssh ${OWNER}@${hosturl} "rm -Rf /${remotedir}/artifacts"
echo "DEBUG, SHELL Script executed ${scriptfile}... ${exec_dt} - host: $hosturl " >> $workingdir/logs/scripted_deploy.log
         currtime=`date +"%Y%m%d %H:%M:%S"`
           echo -e "INFO : \t $currtime << Executed    ${scrname}"
           echo -e "INFO : \t $currtime << Executed    ${scrname}" >> $workingdir/logs/script.${exec_dt}.log
        cat $workingdir/logs/script.${exec_dt}.log >> $workingdir/logs/batchexecution.log
fi
#else
#sshstring="ssh ${OWNER}@${hosturl} 'bash -s' < ${scriptpath}/${scrname}"
#eval ${sshstring} >> $workingdir/logs/script.${exec_dt}.log
#if [ $? -ne 0 ]; then
#echo " O O... something went wrong while executing sh script on ${hosturl}. Please investigate."
#exit 1;
#fi
echo "DEBUG, SHELL Script executed ${scriptfile}... ${exec_dt} - host: $hosturl " >> $workingdir/logs/scripted_deploy.log
         currtime=`date +"%Y%m%d %H:%M:%S"`
           echo -e "INFO : \t $currtime << Executed    ${scrname}"
           echo -e "INFO : \t $currtime << Executed    ${scrname}" >> $workingdir/logs/script.${exec_dt}.log
        cat $workingdir/logs/script.${exec_dt}.log >> $workingdir/logs/batchexecution.log
cd $currdir
