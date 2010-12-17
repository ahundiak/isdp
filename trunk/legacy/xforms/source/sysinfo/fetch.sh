echo "$0 $*"

echo "Begin $SYSTEM_NAME Fetch." `date`
time ( spc fetch proj ) 2>&1
echo "End $SYSTEM_NAME Fetch." `date`
return 0
