#! bin/sh
# Author: Tejas Gajjar
#===================================================================
# This file is to substitute TIBCO GV - AppSecurity
#===================================================================
infile=$1
bkfile=${infile}.tmp
outfile=${infile}
masterfile=$2

pattern1="AppSecurity"

cp -p $infile ap.in
cp -p $masterfile master.in
cp -p $infile $bkfile

#startline=`cat -n $infile | grep $pattern1 -m 1 | awk {print $1}`
#endline=`tac -n $infile | grep $pattern1 -m 1 | awk {print $1}`
cat -n ap.in | grep "AppSecurity" > 1.in
startlinenum=`cat 1.in | awk 'NR==1 {print $1}'`
appendline=`tac 1.in | awk 'NR==1 {print $1}'`
endlinenum=( ${appendline} )
startline=$(($startlinenum - 1))
#endline=(2+($endlinenum))
endline=$((2 + $endlinenum))

#echo "appendline: $appendline  endline: $endline"

echo  "Substituting AppSecurity lines:  $startline to $endline with $masterfile"
sedcmd="'${startline},${endline}d'"
echo "NR==${startline} {system(\"cat master.in\")}1" > awk.in

#echo $sedcmd
#cat awk.in
eval sed -e $sedcmd ap.in > ap2.in
eval awk -f awk.in ap2.in > final.in
#cat final.in

mv final.in $infile

# cleanup
rm *.in

echo "${infile} updated with ${masterfile}"
