for dir in $*
do
 cd $dir
 echo "------ $dir -----"
 grep getfile install.sh | tr -s' ' ' ' | cut -d' ' -f3 | grep -v SUFF > /tmp/nonSUFF
 for file in `cat /tmp/nonSUFF`
 do 
  ls -al $file > /dev/null
 done
 grep getfile install.sh | tr -s' ' ' ' | cut -d' ' -f3 | grep SUFF | cut -d'.' -f1 > /tmp/SUFF
 for file in `cat /tmp/SUFF`
 do
  ls -al ${file}.p > /dev/null
  ls -al ${file}.p4 > /dev/null
  ls -al ${file}.sun > /dev/null
  ls -al ${file}.sgi > /dev/null
 done
 rm /tmp/nonSUFF /tmp/SUFF
 cd ~
done
  
