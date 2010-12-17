#	The following changes were made by Raj on 28/Dec/94.
#	1. Replaced all calls to 'make' with 'grmake'.
#	2. Added statements to remove makefile before generating
#	   it with 'grmakemake'.
#	3. Added a call to 'grmakemake' for directory
#	   $NORM/pdmnormdp/util/src
#	4. Commented out statement "make -f makespec" for directory
#	   $NORM/pdmnormdp/spec, since 'makefile' and 'makespec' are
#	   identical.
#	5. Commented out statement "make -f makeimp" for directory
#	   $NORM/pdmnormdp/imp, since 'makefile' and 'makeimp' are
#	   identical.


#
#		Run the .profile
#
		. $NORM/.profile
		. $NORM/.env
#
#		Create the DINLOAD executable.
#
		echo 	"cd $NORM/pdmnormdp/util/src"
		cd $NORM/pdmnormdp/util/src
		if [ "$REMOVEOBJ" = "y" ]
		then
		  echo 	"rm $NORM/pdmnormdp/util/src/*.o"
		  rm $NORM/pdmnormdp/util/src/*.o
		fi
###		Added by Raj.
		rm makefile
		$GRNUC/bin/grmakemake -i $PDU/include/clip_igno PDMNORM.m makefile
		echo	"grmake"
		grmake

		echo 	"cd /usr3/pdmnorm/pdmnormdp/spec"
		cd $NORM/pdmnormdp/spec
		if [ "$REMOVEOBJ" = "y" ]
		then
		  echo 	"rm /usr3/pdmnorm/pdmnormdp/spec/*.o"
		  rm $NORM/pdmnormdp/spec/*.o
		fi
		rm makefile
		$GRNUC/bin/grmakemake -i $PDU/include/clip_igno spec.m makefile
		echo	"grmake"
		grmake
###		Commented out by Raj.
#               make -f makespec

		echo 	"cd /usr3/pdmnorm/pdmnormdp/imp"
		cd $NORM/pdmnormdp/imp
		if [ "$REMOVEOBJ" = "y" ]
		then
		  echo 	"rm /usr3/pdmnorm/pdmnormdp/imp/*.o"
		  rm $NORM/pdmnormdp/imp/*.o
		fi
		rm makefile
		$GRNUC/bin/grmakemake -i $PDU/include/clip_igno imp.m makefile
		echo	"grmake"
		grmake
###		Commented out by Raj.
#               make -f makeimp

		echo 	"cd /usr3/pdmnorm/pdmnormdp/lib"
		cd $NORM/pdmnormdp/lib
		if [ "$REMOVEOBJ" = "y" ]
		then
		  echo 	"rm /usr3/pdmnorm/pdmnormdp/lib/*.o"
		  rm $NORM/pdmnormdp/lib/*.o
		fi
		echo	"grmake"
		grmake

#
#		Compile the PPL files.
#
		echo	"cd /usr3/pdmnorm/pdmnormdp/src/ppl"
		cd $NORM/pdmnormdp/src/ppl
		echo	"rm /usr3/pdmnorm/pdmnormrt/ppl/bin/*.e"
		rm $NORM/pdmnormrt/ppl/bin/*.e
		echo	"mkppl Vdaps.u"
		mkppl Vdaps.u
		echo	"mkppl edit_vdaps.u"
		mkppl edit_vdaps.u
		echo	"mkppl setvis.u"
		mkppl setvis.u
		echo	"mkppl sv.u"
		mkppl sv.u
		echo	"mkppl select.u"
		mkppl select.u
                echo    "mkppl selectall.u"
                mkppl selectall.u
                echo    "mkppl cs2lin.u"
                mkppl cs2lin.u
                echo    "mkppl cscirc.u"
                mkppl cscirc.u
                echo    "mkppl NORMdynattr.u"
                mkppl NORMdynattr.u
#
#		Create the pdmnorm graphics library.
#
		echo	"cd /usr3/pdmnorm/pdmnormdp/src/funk"
		cd $NORM/pdmnormdp/src/funk
		if [ "$REMOVEOBJ" = "y" ]
		then
		  echo	"rm /usr3/pdmnorm/pdmnormdp/src/funk/*.o"
		  rm $NORM/pdmnormdp/src/funk/*.o
		fi
                rm makefile
                if [ "$TARG" = "c100" ]
                then
                echo "Compile for c100"
                echo ""
		grmakemake is used due to constraints from GRNUC
		echo "PDMNORM - GRMAKEMAKE on CLIPPER for PDMNORMDP/SRC/FUNK"
		$GRNUC/bin/grmakemake -i $PDU/include/clip_igno funk.m
#                cp makefile.b makefile
                fi

                if [ "$TARG" = "c400" ]
                then
                echo "Compile for c400"
                echo ""
		grmakemake is used due to constraints from GRNUC
		echo "PDMNORM - GRMAKEMAKE on CLIPPER for PDMNORMDP/SRC/FUNK"
		$GRNUC/bin/grmakemake -Dc4 -i $PDU/include/clip_igno funk.m
#                cp makefile.b makefile
                fi

                if [ "$TARG" = "sparc" ]
                then
                echo "Compile for sparc"
                echo ""
                $EXNUC/bin/makemake -Dsparc funk.m
                fi
		echo "Run $GRNUC/bin/grmake in PDMNORMDP/SRC/FUNK"
		echo
		#grmake is used due to constraints from GRNUC
		$GRNUC/bin/grmake
#
#		Make the NEWPRODable cut and send it across to 'pdmdel'.
#
		echo	"cd /usr3/pdmnorm/pdmnormdp/util/bin"
		cd $NORM/pdmnormdp/util/bin
                if [ "$TARG" = "c100" ]
                then
                echo "Call pdmnorm.delv"
                echo ""
		pdmnorm.delv
                fi

                if [ "$TARG" = "c400" ]
                then
                echo "Call pdmnormc4.delv"
                echo ""
		pdmnormc4.delv
                fi

