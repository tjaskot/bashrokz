#!/bin/bash

#s=$(find . -type f -ctime 0)

for c in * 
do
	#echo "$c"
	#v=$(echo "$c" | grep '-')
	#if [ ! -z "$c" ] ;
	v=$(find . -type f -iname "$c" -ctime 0)
	if [ ! -z "$v" ]
	then
		s=$(echo "$c" | sed -e "s/- /&\n/;s/.*\n//")
		mv "$c" "$s" 	
	fi
done
