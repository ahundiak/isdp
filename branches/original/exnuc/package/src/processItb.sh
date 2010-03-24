set -e

ITB=$1

#$filename $type $scid $src $srccfg $dp $dpcfg $rt $rtcfg $fuid
#$rsvcfg $mkmk $atp

echo "$0: $ITB" >&2
FOUND=
for FILE in `column filename < $ITB | strip_head`
do
	eval `row "filename == \"$FILE\"" <$ITB | rowtosh`
	if test $rt = y -o $dp = y
	then
		FOUND=1
		echo $fuid
	fi
done

if test -z "$FOUND"
then
	echo "$0: $ITB: none" >&2
fi
