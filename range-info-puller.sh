#!/bin/bash
#cheking whether the host is part of any CF3 ranges
tr "," "\n" < $1 | awk -F "'" '{print $2}' > tmp-file
mv tmp-file $1 ;
#cat $1;
read -p "Enter your home directory location = " hmdir
read -p "Enter your full SVN repo path = " repodir
svn info $repodir;
svn up $repodir;
echo "==================== svn updated =========================";
sleep 0.2;
for i in `cat $1`;do
        eh -e %index:$i > $hmdir/tmp-out-cf3-$1;
        cat $hmdir/tmp-out-cf3-$1 | grep cf3 >> $hmdir/tmp-all-cf3-foundin-file-$1 ;
        if [ `echo $?` == 0 ]; then
		#cd /export/home/eng/cthamaba/mysvn/trunk;
		cd $repodir;
		#svn info;
		#svn up;
		echo -e "\n Host $i is part of cf3 ranges";
		for j in `cat $hmdir/tmp-out-cf3-$1 | grep cf3`;do
			echo $j;
			grep -in -w $i $j.yaml;
				if [ `echo $?` == 0 ];then
					#grep -in -w $i /export/home/eng/cthamaba/mysvn/trunk/$j.yaml  >> tmp-found-host-asitisin-cf3-rangefile-$1;
					grep -in -w $i $j.yaml  >> $hmdir/tmp-found-host-asitisin-cf3-rangefile-$1;
					echo -e "$i hostname found as it is in range $j" >> $hmdir/tmp-found-host-asitisin-cf3-rangefile-$1;
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
					#echo "tmp-found-subrange-of-sub-rangefile";
					echo -e "$i hostname found in subrange $l and part of $j" >> $hmdir/tmp-found-subrange-of-sub-rangefile-$1;
				fi
			done
			#for m in `cat $hmdir/series-ranges `;do
				#if [ $j == $m ] ; then
			grep  "\.\." $j.yaml ; # > /dev/null;
				if [ `echo $?` == 0 ]; then
					eh -e %"$j" | grep $i ;
					if [ `echo $?` == 0 ]; then
						#echo "Range $j is part of series ";
						echo -e "$i hostname found in $j range and in series entries" >>  $hmdir/tmp-foundin-series-file-$1;
					fi
				fi
			#done
		done
	else
		echo -e "\n Host $i not found in any of cf3 ranges" >> $hmdir/tmp-notfoundin-any-cf3-ranges-$1;
	fi
	rm $hmdir/tmp-out-cf3-$1;
done
cd;
