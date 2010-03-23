# This program exercises the shared font capability of the Font Server.
# It executes a number of instances of the shwrite program, each with a
# different font and/or size.

if [ -z "$*" ]
then
	echo "Usage:  $0 {n}		(1 <= n <= 4)"
	exit -1
fi


integer n t

let t=$1*$1
let n=0
while [ "$n" -lt "$t" ]
do
	case $n in
	0 | 4 | 10)
		tf=swiss742
		size=20 ;;
	1 | 5)
		tf=dutch801
		size=24 ;;
	2 | 9 | 15)
		tf=mono821
		size=32 ;;
	3 | 11)
		tf=swiss742b
		size=16 ;;
	6 | 12)
		tf=dutch801b
		size=28 ;;
	7 | 14)
		tf=mono821bi
		size=14 ;;
	8 | 13)
		tf=swiss742i
		size=36 ;;
	*)
		tf=dutch801bi
		size=26 ;;
	esac

	shwrite $1 $n $tf $size < shwrite.txt &
	let n=$n+1
done
