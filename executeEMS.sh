#!/bin/sh
# ############################################################
# Author:   Tejas Gajjar
# ===========================================================
# Script to execute ems scripts
# ############################################################

exec_dt=`date +"%Y%m%d%H%M%S"`

# Echo Usage if prompted
chelp=`echo ${1} | tr '[A-Z]' '[a-z]'`
case ${chelp} in
  "help"|"-help"|"--help"|"?"|"-?"|"usage"|"-usage"|"-h")
   echo -e " \t ----------------------------------------------------------"
   echo -e " USAGE: $0 <emsscript> <emsurl> <emsuser> <emspwd> "
   echo -e " \t\t    <emsscript>:\t <app_id>-<script_name>-<version>.ems"
   echo -e " \t\t    <emsurl>:   \t "
   echo -e " \t\t    <emsuser>:  \t "
   echo -e " \t\t    <emspwd>:   \t "
   echo -e " \t ----------------------------------------------------------"
   exit 0
   ;;
  *)
   ;;
esac

emscmddir=$EMS_HOME/bin
emsurl=${2}
emsuser=$3
emspwd=$4
scriptfile=$1
#scriptpath=$DF_HOME/artifacts/appscripts
scriptpath=${appscriptloc}

if [ ! -e "${emscmddir}" ]; then
  echo -e "ERROR: Unable to find ${emscmddir}"
  exit 1
fi

if [ ! -e "${scriptpath}/${scriptfile}" ]; then
  echo -e "ERROR: Unable to find script file ${scriptfile} in approved script"
  exit 1
else
  # read the right 4 chars to check the script naming
  if [ ! "${scriptfile:(-4)}" = ".ems" ]; then
     echo - e "ERROR: ${scriptfile} does not have valid ems extension."
     exit 1
  fi
fi

#connect [server-url {admin|user_name} password]
# set server parameter=value [parameter=value ...]
#    authorization=enabled|disabled,
#    log_trace=trace-items, max_msg_memory=value,
# compact store_name max_time
# tibemsadmin -script <script-file> -server server-url
currdir=`pwd`
cd ${emscmddir}
if [[ ${emsurl} =~ "tcp" ]]; then
echo "tibemsadmin -server ${emsurl} -user ${emsuser} -password 'pwd...' -script ${scriptfile}"
eval ${emscmddir}/tibemsadmin -server ${emsurl} -user ${emsuser} -password ${emspwd} -script ${scriptpath}/${scriptfile} -ignore > $TIBDF_HOME/emsexec.log
else if [[  ${emsurl} =~ "ssl" ]]; then
echo "tibemsadmin -server ${emsurl} -user ${emsuser} -password 'pwd...' -script ${scriptfile}"
eval ${emscmddir}/tibemsadmin -server ${emsurl} -ssl_identity "${cert_path}/messserv.p12" -ssl_password "badpassword1" -user ${emsuser} -password ${emspwd} -script ${scriptpath}/${scriptfile} -ignore > $TIBDF_HOME/emsexec.log
fi
fi
if [ $? -eq 0 ]
then
cat $TIBDF_HOME/emsexec.log >> ${workingdir}/logs/batchexecution.log
mv $TIBDF_HOME/emsexec.log ${workingdir}/logs
#eval ${emscmddir}/tibemsadmin -server ${emsurl} -user ${emsuser} -password ${emspwd} -script ${scriptpath}/${scriptfile} -ignore
echo -e "DEBUG, EMS Script executed ${scriptfile}... ${exec_dt}"

cd $currdir
else
echo -e " ems script execution failed , please investigate."
cat $TIBDF_HOME/emsexec.log >> ${workingdir}/logs/batchexecution.log
mv $TIBDF_HOME/emsexec.log ${workingdir}/logs
#eval ${emscmddir}/tibemsadmin -server ${emsurl} -user ${emsuser} -password ${emspwd} -script ${scriptpath}/${scriptfile} -ignore
echo -e "DEBUG, EMS Script executed ${scriptfile}... ${exec_dt}"

exit 1;
fi
