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
		#sed -e 's/\[^]]*\]//'
	fi
done

#echo 'current dir: '${PWD##*/}
echo 'checking cur dir'
misdir="/mnt/c/Users/trevo/Documents/mis/test"
if [[ $misdir != $PWD ]]; then
        echo 'go to mis/test dir'
        exit 1
fi
echo 'copying * from ../'
for upf in ../*; do
        #echo $upf
        if [[ $upf != '../test' ]]; then
                cp $upf .
        fi
done
echo 'mv names'
for i in *; do
        #echo $i
        if [[ $i == *.ts ]]; then
                mv $i $i't'
        fi
done
