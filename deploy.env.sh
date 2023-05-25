#! /bin/sh
# Author: Tejas Gajjar
#==========================================================
# Execution Date YYYYMMDDHHMM
exec_dt=`date +"%Y%m%d%H%M"`
# extract tibconum from current location /apps/tibco#/startup or /home/tibco#/sw
currdir=`pwd`
startpos=`echo $currdir | awk -Ft '{ print $1 }'`
secpos=`echo ${currdir:${#startpos}:6}`
tibcoidx=${secpos:5:1}

if [ "${tibcoidx}" = "/" ]; then
  tibconum=${secpos:0:5}
else
  tibconum=${secpos}
fi

TIBDF_HOME=$UD_DIR; export TIBDF_HOME
#TIBDF_SCRIPT=$TIB_HOME/udeploy/scripts; export TIBDF_SCRIPT

# Check for DF_HOME - deployment framework home
if [ -z "$DF_HOME" ]; then
   export DF_HOME=$TIBDF_HOME
   export DF_SCRIPT=$TIBDF_SCRIPT
   export DF_TIB=$TIB_HOME
else
  # check for valid directory
   if [ ! -d "$DF_HOME" ]; then
      echo "WARNING : DF_HOME does not exist as a valid directory: ${DF_HOME}"
   fi
fi

# Check for TRA_HOME - TRA home - if empty use default tra_home
if [ -z "$TRA_HOME" ]; then
   #appmanagedir=/apps/tibco/tra/5.7/bin
   # add code for getting max tra version
   appmanagedir=$TRA_HOME/bin
else
   export appmanagedir=$TRA_HOME/bin
echo $appmanagedir
fi
#export appmanagedir
# Create App deploy date YYYYMMddHHmm with the start deploy action
# any archives will use the above appdeploystarttime
appdeploystarttime=$exec_dt

# -------------------------------------------------------------
echo "INFO :  APP DEPLOY START: ${appdeploystarttime} "
echo "INFO :  Verified environment params to support Deployment Framework"
# -------------------------------------------------------------
