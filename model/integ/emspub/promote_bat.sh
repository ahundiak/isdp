NHOME=$1
shift
echo "promoting $* to $NHOME"
cd `dirname $1`
LIST=
for file in $*
do
 LIST="`basename $file` $LIST"
done
find $LIST -depth -print | cpio -pmduv $NHOME
