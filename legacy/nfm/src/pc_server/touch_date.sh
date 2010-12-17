#get month, date
ls -ls $1>temp.file   # generate ls
exec 0<temp.file    # open file
IFS=' '
read var1 var2 var3 var4 var5 var6 months days therest arg2    # read line
#print "changing data of pc file to $months $days"
case "$months" in
 "Jan")
	arg=01
	;;
 "Feb")
	arg=02
	;;
 "Mar")
	arg=03
	;;
 "Apr")
	arg=04
	;;
 "May")
	arg=05
	;;
 "Jun")
	arg=06
	;;
 "Jul") 
	arg=07
	;;
 "Aug")
	arg=08
	;;
 "Sep")
	arg=09
	;;
 "Oct")
	arg=10
	;;
 "Nov")
	arg=11
	;;
 "Dec")
	arg=12
	;;
  esac	

year=""

case "$therest" in
 "1988")
	year=88
	;;
 "1989")
	year=89
	;;
 "1990")
	year=90
	;;
 "1991")
	year=91
	;;
 "1992")
	year=92
	;;
"1993")
	year=93
	;;
  esac	

#convert to touch command
if [ "$days" -lt 10 ] 
then days="0"$days
fi
if [ "$year" = "" ]
then arg=$arg$days"0000"
else arg=$arg$days"0000"$year
fi

#touch mmddhhmm filename
#print "touch $arg $2"
touch $arg $2
rm temp.file







