# script to do a total remake of the dict directory

find dict -name '*.[So]' -print > /tmp/dict.$$

for file in `cat /tmp/dict.$$`
do
  if [ "$UNIT_TEST" = "on" ]
   then
     mv $file old.`basename $file`
  fi    
  nrm $file
  if [ "$UNIT_TEST" = "off" ]
   then 
     mv old.`basename $file` $file
  fi
done
