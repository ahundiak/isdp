sleep 2
/bin/ksh $1
retsts=$?
echo "Press RETURN to continue"
read key
exit $retsts
