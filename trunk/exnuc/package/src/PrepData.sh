ARGV0=`basename $0`
set -e
OS=`uname -s`
echo
echo "Prepare fixes data for fetches"
echo
echo "1) cat (all request files) > all.reqs"
echo "2) remove the lines with \"#\" in them > all.files"
echo "   (check for mispellings and basic errors)"
echo "3) cp all.files files.fetches"
#echo "4) manually edit the files.fetches to remove any lower sid files"
#echo "5) Verify the files to be fetched."
echo
echo "Enter a list of selections separated by blanks: \c"
read
if test -z "$REPLY"
then
	exit 2
fi

	case $REPLY
	in
	1)	cat EX*.0* > $BLD/all.reqs
		;;
	2)	sed '/#/d' $BLD/all.reqs | sort -u > $BLD/all.files
		;;
#	3)	cat $BLD/all.files | awk '{FS=" ";print $1":"$2}' > $BLD/files.fetched
	3)	cp $BLD/all.files $BLD/files.fetched
		;;
	4)	em $BLD/files.fetched
		;;
	5)	cd $REL
	#	sopen exnuc . -ver 2.0.0 -emp 1054
		$HOME/VerifyFet.sh < $BLD/files.fetched
		;;
	*)	exit 2;;
	esac

echo
echo "SUCCESS"
echo "Finished on `date`"
echo
