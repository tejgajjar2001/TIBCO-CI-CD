#! /bin/sh
# Author: Tejas Gajjar
##########################################################
# Executes the deployment framwork option to batchDeploy
# the entire repository
# Syntax:
#     AppManage -batchStart -domain $1 -cred $2 -dir $3
#     $4=AppManage.batch or other name of the batched app list
# ############################################################
echo -e " input params:\n\t\t 0: $0  \t 1:$1 \t 2:$2 \t 3:$3 \t 4:$4 "
# Execution Date YYYYMMDDHHMM
exec_dt=`date +"%Y%m%d%H%M%S"`
currdir=`pwd`
applist_name=$4
applist_loc=$1/artifacts
domain_name=$2
cred_file=$3
workingdir=${applist_loc}

# Check if custom appplication list name provided or default used
#if [ -z "$applist_name" ]; then
if [ -z "$applist_name" ] || [ $applist_name == "AppManage.batch" ]; then
   echo -e "INFO:\t Use default AppManage.batch list for batch operations."
   applist_name=AppManage.batch
else
   echo -e "INFO:  Copy $applist_name as AppManage.batch"
   if [ -e "$applist_loc/AppManage.batch" ]; then
      # backup existing file
      echo -e "INFO: backup existing AppManage.batch file"
      cp $applist_loc/AppManage.batch $applist_loc/AppManage.batch.$exec_dt
      echo -e "$applist_loc/AppManage.batch found. Proceed to start."
  fi
  cp $applist_loc/$applist_name $applist_loc/AppManage.batch
        if [ $? != 0 ]; then
        echo "error while copying batch file."
        exit 1;
        fi
fi

# printAppName function to print each application in the list
function printAppList {
inputfile=$applist_loc/$applist_name
# Application list should be in following location
# DF_HOME/ReleaseTag/artifacts/AppManage.batch (for now)
# check if the inputfile exists
if [ ! -e "$inputfile" ]; then
   echo -e "WARNING:\t File ${inputfile} not found."
   exit 0
fi
# link filedescriptors 10 wih stdin
exec 10<&0
# array fields - f_appname, f_ear, f_xml

echo -e " >>>>> APP-BATCH-LIST -- "
echo -e " ------------------------------------------------------------- "
exec < $inputfile
let count=0
let name_idx=0
let ear_idx=0
let xml_idx=0
while read f_ignore1 f_appname f_ear f_xml ; do
   # line_element=$LINE
    # check if name=, ear=, and xml= are applicable from line_read
    name_idx=`expr index "$f_appname" name`
    ear_idx=`expr index "$f_ear" ear`
    xml_idx=`expr index "$f_xml" xml`
    #echo -e " >>> Found index: $name_idx earindex: $ear_idx  xmlindex: $xml_idx"
    if [ $name_idx -gt 0 -a $ear_idx -gt 0 -a $xml_idx -gt 0 ]; then
       ((count++))
       #echo -e " ${count}. ${f_appname:(name_idx+5)} ${f_ear:(ear_idx+4)} ${f_xml:(xml_idx+4)} "
       var1=${f_appname:(name_idx+5)}
       var2=${f_ear:(ear_idx+4)}
       var3=${f_xml:(xml_idx+4)}
       echo -e "INFO:  ${count}. app:${var1/\"/ } ear:${var2/\"/ }  xml:${var3/\"\/>/ } "
    fi
   # name_idx=0
done
# close filedescriptors
exec 0<&10 10<&-

echo -e " ------------------------------------------------------------- "
#echo -e "INFO:\t\t\t$0\t   app_name"
}
# ---- end function printAppList() --------

echo -e "INFO:\t $exec_dt : \tBATCH DEPLOY (BatchStart): $domain_name - artifacts: $applist_loc"
printAppList

# Execute the AppManage command
#cd $appmanagedir
cd $TRA_HOME/bin
eval ./AppManage_${domain_name} -batchStart -domain ${domain_name} -cred \"${cred_file}\" -dir \"${applist_loc}\" -serialize >> "${applist_loc}/${exec_dt}.batchStart.log"

cd ${applist_loc}
cat ${applist_loc}/${exec_dt}.batchStart.log >> ${workingdir}/logs/batchexecution.log
mv ${applist_loc}/${exec_dt}.batchStart.log ${workingdir}/logs/
#cd $DF_HOME/scripts
cd $currdir

exec_dt=`date +"%Y%m%d%H%M%S"`
echo -e "INFO:\t ${exec_dt} : \tBatchStart CMD EXECUTED:  $domain_name "

echo -e " ------------------------------------------------------------- "
# -------------------------------------------------------------
