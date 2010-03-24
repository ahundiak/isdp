set -e

ITB=$1

#$filename $type $scid $src $srccfg $dp $dpcfg $rt $rtcfg $fuid
#$rsvcfg $mkmk $atp

function cvrtMode {
	case $1
	in
	d4)	echo 444;;
	d5)	echo 555;;
	d6)	echo 666;;
	d7)	echo 777;;
	d7s)	echo 4777;;
	r4)	echo 444;;
	r5)	echo 555;;
	r5s)	echo 4555;;
	r6)	echo 666;;
	r7)	echo 777;;
	*)	echo "$0: $1: unknown file mode" >&2; exit 2;;
	esac
}

function cvrtFuid {
	case $1
	in
	cfg)	echo config;;
	dir)	echo dir;;
	doc)	echo doc;;
	exe)	echo bin;;
	msgsrc)	echo msgsrc;;
	help)
	*)	echo "$0: $1: unknown fuid" >&2; exit 2;;
	esac
}

echo "filename	cpio	rtmode	dpmode	build"
echo "--------	----	------	------	-----"

for FILE in $(column filename < $ITB | strip_head)
do
	eval $(row "filename == \"$FILE\"" <$ITB | rowtosh)
	if test $rt = y -o $dp = y
	then
		echo "$filename\c"
		echo "\t$(cvrtFuid $fuid)\c"
		if test $rt = y
		then
			echo "\t$(cvrtMode $rtcfg)\c"
		else
			echo "\t---\c"
		fi
		if test $dp = y
		then
			echo "\t$(cvrtMode $dpcfg)\c"
		else
			echo "\t---\c"
		fi
		echo "\t$rt$dp$rt$dp$rt$dp$rt$dp$rt$dp"
	fi
done

