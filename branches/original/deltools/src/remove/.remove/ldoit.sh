case $PLATFORM in
Solaris | SunOS_4)
    DU=/usr/bin/du
    ;;
CLIX | IRIX)
    DU=/bin/du
    ;;
esac 

while [ $# -gt 0 ]
do
    name=$1
    dir=$2
    size=$3
    shift 3

    size=`$DU -s $dir | cut -f 1`
    [ $PLATFORM = SunOS_4 ] && size=`expr $size \* 2`

    $RM/doit.sh $name $dir $size
done
