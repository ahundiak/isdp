#!/bin/ksh
# This is a quick trick for updating the prototype files in the
# Source Platform from those generated in the Build Platform.
# NOTE: There may be some restrictions on when it can be run.
# For instance, it should be run after a build when prototype file
# changes are acceptable, but not after a build where prototype file
# changes are found which are not acceptable. The updated files must
# be put into SPC somehow, or the same problem will re-appear after
# the next fetch.

cd $SYSBLD

echo "Updating include files in $SYSSRC from $SYSBLD"

# Testing: Method 1
#find . -mtime -1 -name '*.h' -print

# Testing: Method 2
#for file in `find * -name '*.h' -print`
#for file in `find * \( -name '*p.h' -o -name '*proto*.h' \) -print`
for file in `find * -name '*proto*.h' -print`
do
  if [ -f $file -a -f $SYSSRC/$file ]
  then
    if [ $file -nt $SYSSRC/$file ]
    then
  #    ls -ls $SYSBLD/$file $SYSSRC/$file
      echo $file is NEWER THAN $SYSSRC/$file.
  
      if cmp -s $file $SYSSRC/$file
      then
        :
      else
        echo $file is DIFFERENT FROM $SYSSRC/$file.
        diff $file $SYSSRC/$file
        echo "cp $file $SYSSRC/$file"
        cp $file $SYSSRC/$file
      fi
    fi
  fi
done

exit

# The Real Thing
find . -mtime -1 -name '*.h' -print |
 cpio -pvmud $SYSSRC
