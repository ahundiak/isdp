echo "src/co/csco src/go/undogo src/query/parser" > /usr/tmp/grmksrc.list

FILE_LIST=/usr/tmp/grmksrc.list

for dir in `cat $FILE_LIST`
do
   echo $dir
done
