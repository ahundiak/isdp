#---------------------------------------------------------------------
#	This shell compiles the trsav/ and trret/ directories
#	to generate TRcmd.o, necessary for the ineractive
#	activation of Translator Products from EMS.
#---------------------------------------------------------------------
	set +e

	#-------------------------------------
	# Define the GRNUC path here
 	#-------------------------------------
	if [ "$GRTARG" = "" ]
	then
	   export GRNUC_PATH=`echopath GRNUC`
	else
	   export GRNUC_PATH=$GRTARG
	fi

	#--- Compile messages and place in GRNUC directory ---
	cd  $TRANSLATE/config/message_source
	compile ems

	echo *----------- Compiling tr/grnuc/ -------------*
	cd $TRANSLATE/grnuc
	$GRNUC/bin/grmakemake *.m makefile
	$GRNUC/bin/grmake


	echo *----------- Compiling trsav/ -------------*
	cd $TRANSLATE/trsav
	$GRNUC/bin/grmakemake *.m makefile
	$GRNUC/bin/grmake

	echo *----------- Compiling trret/ -------------*
	cd $TRANSLATE/trret
	$GRNUC/bin/grmakemake *.m makefile
	$GRNUC/bin/grmake



