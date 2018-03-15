#!/bin/bash

#for `cat hostlist.txt in $(host)`

for host in `cat hostlist.txt`

do

id_name=`echo $host | cut -c 4-7` 
echo $id_name
#echo $host| awk -F "." '{ print $1}' | awk '{ print substr( $0, length($0) - 5, length($0) ) }' 

case $id_name in

	'uuix')
		echo "start Livecycle Application";
		#ssh lbsadm@*uuix* "cd /patching; ./startAll.sh"
;;

	'qvcm')
		echo "start QVCM Application";
		#ssh qvuadm@*qvcm* "cd /patching; ./startAll.sh"
;;

esac

echo $host;
done


