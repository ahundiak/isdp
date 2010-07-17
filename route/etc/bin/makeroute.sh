#	I/ROUTE
#	Building procedure
#
if [ $# -ne 0 ] ; then
	MAKEOPT="$*"
else
	MAKEOPT="COPT=-DDEBUG=0"
fi
RC=0
ERROR=""
if [ blob$ROUTE = blob ] ; then
	/bin/echo "'\$ROUTE not set'"
else
	for i in	$ROUTE/*
	  do
	      if [ -f ${i}/`/bin/basename ${i}`.m ]
	       then 
		/bin/echo "\n\t\t* * * Making $i with \"${MAKEOPT}\"\n"

		\cd $i
		DOT_M=`/bin/basename ${i}`.m
		if [ "${i}/${DOT_M}" -nt "./makefile" ] ; then
			/bin/rm ./makefile > /dev/null 2>&1
		fi
		skip=0
		if [ ! -r ./makefile ] ; then
			/bin/echo "\n\t${DOT_M} -> makefile\n"
			if /bin/ls *.u > /dev/null 2>&1 ; then
				MAKEMAKE=$ROUTE/etc/bin/mkmkppl
				PRODUCT="ROUTE"
			else
				MAKEMAKE=d_makemake
				PRODUCT=""
			fi
			if $MAKEMAKE ./${DOT_M} ./makefile $PRODUCT; then
				:
			else
				ERROR=$ERROR" \t--> Makemake failed in $i\n"
				skip=1
			fi
		fi
		if [ ${skip} = 0 ] ; then
			TMP=/usr/tmp/VS$RANDOM
			if /bin/make -rk ${MAKEOPT} | /bin/tee $TMP ; then
				if /bin/grep	"not remade because of errors" \
						$TMP > /dev/null ; then
					ERROR=$ERROR" \t--> Make failed in $i\n"
				fi
			else
				ERROR=$ERROR" \t--> Make failed in $i\n"
			fi
			/bin/rm $TMP
		fi
	    fi
	done
	if [ "blob$ERROR" != "blob" ] ; then
		/bin/echo "\n$ERROR"
		/usr/bin/tput bel
		RC=1
	else
#		$ROUTE/etc/makearch
		RC=0
		
	fi
fi
		
exit $RC
