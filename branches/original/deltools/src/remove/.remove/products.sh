#!/bin/ksh

TEMP=/usr/tmp/rm.$SESSION
typeset -R6 size
typeset -L9 name

case $PLATFORM in
Solaris)
    CONFIG=$INGRHOME/ingrconfig
    case `uname -p` in
    sparc)
	RMSCRIPT=remove.ssl
	;;
    i386)
	RMSCRIPT=remove.isl
	;;
    esac
    SLFLAG='-L'
    DU=/usr/bin/du
    ;;
SunOS_4)
    CONFIG=/usr/ip32/ingrconfig
    RMSCRIPT=remove.sun
    SLFLAG='-h'
    DU=/usr/bin/du
    ;;
CLIX)
    CONFIG=/usr/ip32/ingrconfig
    RMSCRIPT=remove.sh
    SLFLAG='-L'
    DU=/bin/du
    ;;
IRIX)
    CONFIG=/usr/ip32/ingrconfig
    RMSCRIPT=remove.sgi
    SLFLAG='-L'
    DU=/bin/du
    ;;
# mvr:04/30/94
HP_UX)
    CONFIG=/usr/ip32/ingrconfig
    RMSCRIPT=remove.hp
    SLFLAG='-h'
    DU=/bin/du
    ;;
esac

if [ "$1" = "-q" ]
then
    # call the dates command, it does cleanup/sorting of the ingrconfig file
    dates >/dev/null 2>&1

    [ ! -s $CONFIG ] && exit 1

    while IFS="#" read num name title version date dir itime imedia
    do
	# skip directories that are symlinks
	[ $SLFLAG $dir ] && continue

	# skip products without remove scripts
	[ ! -f $dir/$RMSCRIPT ] && continue

	echo "name=\"$name ($num)\""
	echo "lininfo=\"$name $dir 0\""
	echo "description=\"installed in $dir\""
	echo "itemmsg=\"Remove \\\"$title\\\" -- Version $version $date\""
    done < $CONFIG

else
    if [ -s $TEMP ]
    then
	while IFS="#" read num nm title version date dir s
	do
	    [ -d $dir ] && echo "$num#$nm#$title#$version#$date#$dir#$s"
	done <$TEMP >$TEMP~
	mv $TEMP~ $TEMP
    else
	# call the dates command, it does cleanup/sorting of the ingrconfig file
	dates >/dev/null 2>&1

	[ ! -s $CONFIG ] && exit 1

	while IFS="#" read num nm title version date dir itime imedia
	do
	    # skip directories that are symlinks
	    [ $SLFLAG $dir ] && continue

	    # skip products without remove scripts
	    [ ! -f $dir/$RMSCRIPT ] && continue

	    # get the size of the product
	    IFS=" 	" 
	    set -- `$DU -s $dir`
	    s=$1

	    [ $PLATFORM = SunOS_4 ] && s=`expr $s \* 2`

	    echo "$num#$nm#$title#$version#$date#$dir#$s"
	done <$CONFIG >$TEMP
    fi

    while IFS="#" read num name title version date dir size
    do
	echo "name=\"$name ($num)\""
	echo "lininfo=\"$name $dir $size\""
	echo "description=\"$size blocks in $dir\""
	echo "itemmsg=\"Remove \\\"$title\\\" -- Version $version $date\""
    done <$TEMP
fi

exit 0
