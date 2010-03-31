for i in `cat $MODEL/integ/makelist`
do
 echo Removing dependencies in $i/makefile
 ed $i/makefile < $MODEL/integ/rmdeped > /dev/null
 echo 
 echo 
done

