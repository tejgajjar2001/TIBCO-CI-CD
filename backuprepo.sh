# ===========================================================
# Executes the deployment framwork option to batchExport
# the entire repository
# Syntax:
#     AppManage -batchExport -domain $0 -cred $1 -dir $2
# ############################################################
if [ $# != 3 ]
    then
        echo "USAGE:\ <DOMAIN_NAME> <ADMIN_CRED_FILE> <Export_DIR>"
        exit 1
fi

#exec_dt=`date +"%Y%m%d%H%M%S"`
domain_name=$1
cred_file=$2
#export_dir=$3/export_${exec_dt}; export export_dir
applist_loc="${DF_HOME}/artifacts/logs"

# Delete any exports which are older than last 10 exports.
echo -e "Checking for old exports and removing old export."
echo -e "Only Last 10 exports will be available all the time."
echo -e "Removing...."

echo -e "rm -Rf $(ls -1t $3 | tail -n +11)"
currdir=`pwd`
cd $3
rm -Rf $(ls -1t $3 | tail -n +11)
cd $currdir

if [ $? != 0 ]
then
echo -e "warning: old exports were not removed successfully. Please check."
else
echo " Old exports removed successfully."
fi

echo "INFO:\t$exec_dt : \tBACKUP REPO (BatchExport): $domain_name \t $cred_file - destination: $export_dir"

currdir=`pwd`
# Execute the AppManage command
#cd $appmanagedir
cd $TRA_HOME/bin
echo " $appmanagedir - out  $TRA_HOME"
eval ./AppManage_${domain_name} -batchExport -domain ${domain_name} -cred \"${cred_file}\" -dir \"${export_dir}\" -serialize >> "${applist_loc}/${exec_dt}.batchExport.log"
chmod -R 775 $export_dir
cd ${currdir}
cat ${applist_loc}/${exec_dt}.batchExport.log >> ${applist_loc}/batchexecution.log
#mv ${applist_loc}/${exec_dt}.batchExport.log ${export_dir}/logs/


exec_dt=`date +"%Y%m%d%H%M%S"`
echo "INFO:\t$exec_dt : \tBatchExport CMD EXECUTED:  $domain_name "

echo " ------------------------------------------------------------- "
# -------------------------------------------------------------
