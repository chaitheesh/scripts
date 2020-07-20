#!/bin/bash
#purpose - ssh against host, listof hosts and ranges
#version-2
#added range check before execution
#author - chait
if [ $1 == -r ]; then
	eh -e $2 1> /tmp/null
 	if [ `echo $?` == 0 ]
 	then
		echo "------------------------"
        	echo "RANGE DEF VALIDATED - $2"
		echo "------------------------\n"
 	else
        	echo "Got exception - NOCLUSTERDEF"
		exit 1
 	fi
fi
# exit when any command fails
set -e
case $1 in
	-h)
		#echo "host"
		ssh $2 "$3" 2> /dev/null
	;;
	-f)
		#echo "file"
		for i in `cat $2`
		do
			echo $i
			ssh $i "$3"
		done 2> /dev/null
 	;;
 	-r)
		#echo "range"
			#for i in `cat /tmp/hostlist-tmp`
			for i in `eh -e $2`
			do
				echo $i;
				ssh $i "$3";
			done 2> /dev/null
  	;;
 	*)
 		echo "INVALID OPTION! Exiting... "
 	;;
 esac
