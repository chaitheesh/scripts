#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
#cheking whether the host is part of any CF3 ranges
#installing gnu-sed for MAC usage
#brew install gnu-sed;
#exporting gnu_sed path
#export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH";
tr "," "\n" < $1 | awk -F "'" '{print $2}' > tmp-file
mv tmp-file $1 ;
#cat $1;
read -p "Enter your home directory location = " hmdir
read -p "Enter your full SVN repo path = " repodir
echo "\n==================================================================="
svn up $repodir;
svn info $repodir;
echo "\n======================== svn updated ==============================";
sleep 0.2;
for i in `cat $1`;do
        eh -e %index:$i > $hmdir/tmp-out-cf3-$1;
        cat $hmdir/tmp-out-cf3-$1 | grep cf3 > /dev/null ; # >> $hmdir/tmp-all-cf3-foundin-file-$1 ;
        if [ `echo $?` == 0 ]; then
		#cd /export/home/eng/cthamaba/mysvn/trunk;
		cd $repodir;
		#svn info;
		#svn up;
		#echo -e "\n Host $i is part of cf3 ranges";
		for j in `cat $hmdir/tmp-out-cf3-$1 | grep cf3`;do
			echo $j;
			grep -in -w $i $j.yaml > /dev/null;
				if [ `echo $?` == 0 ];then
					echo "*";
					#grep -in -w $i /export/home/eng/cthamaba/mysvn/trunk/$j.yaml  >> tmp-found-host-asitisin-cf3-rangefile-$1;
					#grep -in -w $i $j.yaml  >> $hmdir/tmp-found-host-asitisin-cf3-rangefile-$1;
					echo  "$i hostname found as it is in range $j" >> $hmdir/HOST-found-asitisin-cf3range-file-$1;
				fi
			#for k in `cat tmp-out-cf3 | grep -v cf3`; do
			#	grep $k /export/home/eng/cthamaba/mysvn/trunk/$j.yaml
			#	if [ `echo $?` == 0 ];then
			#		echo "tmp-found-subrange-asitisin-rangefile";
			#		#grep $k /export/home/eng/cthamaba/mysvn/trunk/$j.yaml >> tmp-found-subrange-asitisin-rangefile-$1;
			#		echo -e "$i hostname found in subrange $k  as it is in range $j" >> tmp-found-subrange-asitisin-rangefile-$1;
			#	fi
			#done
			for l in `grep "%" $j.yaml | grep -v cf3`; do
				eh -e $l | grep $i ;
				if [ `echo $?` == 0 ]; then
					echo "*";
					#echo "tmp-found-subrange-of-sub-rangefile";
					echo  "$i hostname found in subrange $l and part of $j" >> $hmdir/HOST-foundin-subrange-file-$1;
				fi
			done
			#for m in `cat $hmdir/series-ranges `;do
				#if [ $j == $m ] ; then
			grep  "\.\." $j.yaml ; # > /dev/null;
				if [ `echo $?` == 0 ]; then
					eh -e %"$j" | grep $i ;
					if [ `echo $?` == 0 ]; then
						echo "*";
						#echo "Range $j is part of series ";
						echo  "$i hostname found in $j range and in series entries" >>  $hmdir/HOST-foundin-series-file-$1;
					fi
				fi
			#done
		done
	else
		echo  "Host $i not found in any of cf3 ranges" >> $hmdir/HOST-notfoundin-any-cf3-ranges-$1;
	fi
	rm $hmdir/tmp-out-cf3-$1;
done
cd;
#fucntion declaration
remove_hosts ()
{
	file_asitis=`echo $1`;
	cd $repodir;
	while IFS= read line
	do
        	# display $line or do something with $line
		#echo "$line"
		hst=`echo "$line" | awk -F " " '{print $1}'`;
		range=`echo "$line" |awk -F " " '{print $9}'`;
		#echo $hst,$range;
		sed -i '/'"$hst"'/d' $range.yaml;
		sleep 2;
		#echo "${RED} Deleted entry $hst from $range  ${NC}";
	done <"$hmdir/$file_asitis"
	echo "\n ${RED} Removed hosts from respective cf3 ranges, please get this reviewed by ypur peer and commit the change  ${NC}";
	svn diff $repodir;
	cd;
}
echo "\n========================= Range details ==========================="
for n in `ls $hmdir | grep $1| grep -v ^$1`;do
	echo "\n * $n *  \n";
	cat $n;
	if [ $n == "HOST-found-asitisin-cf3range-file-$1" ];then
		count=`wc -l $n | awk '{print $1}'`;
	        #echo "count $count";
		if [ $count -ge 10 ];then
			echo "\n ${RED}  Host as it is entries are more than 10, so please do it manually. Host details are in file $hmdir/$n ${NC}";
		else
			#echo "\n less than 10"
			remove_hosts $n;
		fi
	elif [ $n == "HOST-foundin-subrange-file-$1" ] ; then
		echo "\n ${RED} Check subranges are managed by SYSOPS or not and act accordingly ${NC}";
	elif [ $n == "HOST-foundin-series-file-$1" ] ;then
		echo "\n ${RED} Series entries need manual intervention , check file $hmdir/$n ${NC}";
	fi
	echo "\n==================================================================="
done
