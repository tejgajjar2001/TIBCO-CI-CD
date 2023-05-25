#! /bin/sh
# Author: Tejas Gajjar
#====================================================
COMP_NAME=$1
DOMAIN_NAME=$2
if [ $# != 2 ]
then
echo "USAGE:\<COMPONENT NAME> <DOMAIN NAME>"
exit 1
fi

LOG=/apps/tibco2/udeploy/agent/var/work/${COMP_NAME}/${DOMAIN_NAME}/logs/batchexecution.log

if `grep -q 'Failed\|error' $LOG`
then
echo error found.
exit 1
else
exit 0
fi
