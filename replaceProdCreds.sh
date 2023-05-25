#! /bin/sh
# Author: Tejas Gajjar
------------------------------------
sourcefile=$1
mastercred=$2
buildtag=$3
if [ ! -z $EXPORT_FLAG ]; then
srcfile=${buildtag}/$1
else
srcfile=${buildtag}/artifacts/$1
fi
#iapicred=$3

if [ -z $mastercred ]; then
   echo "USAGE, $0 source.xml master.cred iapi.cred"
   echo "     source.xml - application xml file"
   echo "     master.cred - master credentials for application"
   echo "   THIS SUBSTITUTES THE APPLICATION CREDENTIALS AT DEPLOY-TIME FROM MASTER CRED FILE"
   exit 1
fi

#if [ -z "$TIBDF_HOME" ]; then
   #TIBDF_HOME=/apps/tibco/TIBDF_110
#   echo " REMOTE INVOCATION - SET LOCAL TIBDF_HOME=/apps/tibco/TIBDF_110"
#   . ~/.bash_profile
#fi

filelength=`cat ${srcfile} | wc -l`
sublength=`cat $mastercred | wc -l`
if [ ! -z $EXPORT_FLAG ]; then
cd $buildtag
else
cd $buildtag/artifacts
fi
$TIBDF_SCRIPT/subAppSecurity.sh $srcfile $mastercred
#$TIBDF_HOME/deploy/scripts/subAppSecurity.sh $sourcefile $mastercred
finallength=`cat ${srcfile} | wc -l`
if [ "$iapicred" != "" ]
then
echo "$TIBDF_HOME/deploy/scripts/subiAPI.sh $srcfile $iapicred"
#$TIBDF_HOME/deploy/scripts/subiAPI.sh $sourcefile $iapicred
fi
echo "`basename $sourcefile` updated.  Orginal Len: $filelength,  Cred Len: $sublength,  Final Len: $finallength"

filelen=`echo "$filelength"`
newlen=`echo "$finallength"`

len1=$(($filelen))
len2=$(($newlen))

if [ $len2 -lt $len1 ]; then
   echo "ERROR:  Master Credential may be missing new creds."
fi
