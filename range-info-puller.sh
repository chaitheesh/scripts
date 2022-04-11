#!/bin/bash
#Below script will check whether the host is part of any CF3 ranges or not
#Criteria of checking 1) Host mentioned as it is, 2) Host added by subrange, 3) Host added in series cf3 yaml file
#installing gnu-sed for using sed in MAC 
#brew install gnu-sed;
#exporting gnu_sed path
#export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH";
#Below 3 steps will cut and arrange the hosts sequentially, avoid if you prepare the hostlist one by one
#Copy the hosts from the ticket with ' ( single inverted coma )
#tr "," "\n" < $1 | awk -F "'" '{print $2}' > tmp-file
#mv tmp-file $1 ;
#cat $1;
read -p "Enter your home directory location = " hmdir
read -p "Enter your full SVN repo path = " repodir
echo "\n==================================================================="
svn info $repodir;
svn up $repodir;
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
			grep -in -w $i $j.yaml;
				if [ `echo $?` == 0 ];then
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
echo "\n========================= Range details ==========================="
for n in `ls $hmdir | grep $1| grep -v ^$1`;do
	echo "\n $n \n";
	cat $n;
	echo "\n==================================================================="
done
read  -n 1 -s -r -p "Press [y] to remove host found as it is in range file or [n] to exit " key
echo "\n"
if [ $key == "y" ];then
	cd $repodir;
	file=$hmdir/HOST-found-asitisin-cf3range-file-$1;
	while IFS= read line
	do
        	# display $line or do something with $line
		#echo "$line"
		hst=`echo "$line" | awk -F " " '{print $1}'`;
		range=`echo "$line" |awk -F " " '{print $9}'`;
		#echo $hst,$range;
		sed -i '/'"$hst"'/d' $range.yaml;
		sleep 2; echo "Deleted entry $hst from $range";
	done <"$file"
	svn diff $repodir;
	cd;
else
	echo  "\nEXIT"
	exit;
fi
