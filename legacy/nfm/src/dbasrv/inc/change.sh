/* $Revision: 1.1 $ */
for file in /usr3/dba/source/*/*c
do
	retstatus=0
	grep -l "$1" $file
	retstatus=$?

        if [ $retstatus -eq 0 ]
        then
	  cat $file | sed s/"$1"/"$2"/g > /usr/tmp/change.c
          mv /usr/tmp/change.c $file
        fi
done
