# mkgrsrc.sh - Compiles the source files for the $GRNUC product
#
#
#    Usage       : mkgrsrc.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grmksrc.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:53  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.2  1996/08/08  19:59:58  grnuc33
# COMMENT : Changed -K PIC to newer -KPIC compiler option
#
# Revision 330.1  1996/04/15  19:44:19  scott
# COMMENT : Changed make configuration to work around Solaris 2.5 bug
#
# Revision 330.0  1996/01/11  20:22:34  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1995/01/20  12:02:58  grnuc32
# COMMENT : Made changes for XGL builds
#
# Revision 320.0  1994/12/12  16:57:00  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.8  1993/10/18  22:15:51  grnuc20
# COMMENT : Fix for compiling the tranos stuff on Solaris - JSD
#
# Revision 240.7  1993/09/03  13:50:26  jjm
# COMMENT : Changes for Solaris
#
# Revision 240.6  1993/08/30  18:57:30  jjm
# COMMENT : added code to use new solaris makefile for transos
#
# Revision 240.5  1993/06/17  15:50:40  grnuc20
# COMMENT : added special processing to compile IGRdir/src/DIstring.o
#
# Revision 240.4  1993/04/20  18:42:50  grnuc20
# COMMENT : added startup commands back in Grnuc
#


# verify that all environment variables used in this script are defined.

verifyenv GRNUC GRTARG TBLDLOG SUN SUNZX SGI EXNUC EXTARG MKDOPT COMPOPT ERRNOTI
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

# compile the config directory
necho "compiling config directory ......."
cd $GRTARG/config
grmake -rk -f $GRNUC/config/Makefile > /tmp/$TBLDLOG 2>&1
if [ "$ERRNOTI" = "on" ]
 then
   grmake -rk -f $GRNUC/config/Makefile > /tmp/$TBLDLOG 2>&1
   errchk /tmp/$TBLDLOG $dir
fi

if [ "$UNIT_TEST" = "on" ]
then
  echo "src/co/csco
        src/go/undogo
        src/query/parser" > /usr/tmp/grmksrc.list
  FILE_LIST=/usr/tmp/grmksrc.list
  for dir in `cat $FILE_LIST`
  do
    mkdir -p /usr/tmp/$dir
    cp $GRTARG/$dir/*ake* /usr/tmp/$dir
    ls -ong $GRTARG/$dir/* > /usr/tmp/$dir/old
  done
  mkdir /usr/tmp/lib
  export SVGRLIB=$GRLIB
  export SVGRTARG=$GRTARG
  export GRLIB=/usr/tmp
  export GRTARG=/usr/tmp
else
  FILE_LIST=$GRNUC/integ/makelist
fi

if [ "$SUN" = "y" ]
then
  necho "\nSpecially compiling $GRNUC/src/IGRdir/src/DIstring.o\n"
  cd $GRTARG/src/IGRdir/src
  make -rk -f makeimp FAST="$FAST" WHY="$WHY" CC="/usr/5bin/cc" COPT="$COMPOPT" DOPT1="$MKDOPT" DIstring.o > /tmp/$TBLDLOG 2>&1
fi

for dir in `cat $FILE_LIST`
do
  necho "\n------------------$UNIT_MESS $dir ---------------------\n"
  cd $GRTARG/$dir
  if [ "$dir" = "src/transos" ] 
  then
    cd $GRTARG/src/transos
    if [ "$SUNZX" = "y" ] || [ "$SGI" = "y" ] || [ "$SUN5" = "y" ]
    then
      if [ "$SUN5" = "y" ]
      then
        cd $GRNUC/src/transos
        $EXTARG/bin/makemake ${MKMKOPT} imp.m.sol ${GRTARG}/src/transos/makeimp > /tmp/$TBLDLOG 2>&1
        ncat /tmp/$TBLDLOG
        cd $GRTARG/src/transos
        nrm $GRTARG/config/dload/port/grsp_proc.so
        TRANSOSCC="cc -KPIC"
      fi

      if [ "$SUNZX" = "y" ]
      then
        cd $GRNUC/src/transos
        $EXTARG/bin/makemake ${MKMKOPT} imp.m.zx ${GRTARG}/src/transos/makeimp > /tmp/$TBLDLOG 2>&1
        ncat /tmp/$TBLDLOG
        cd $GRTARG/src/transos
        nrm $GRTARG/config/dload/port/grsp_proc.so
        TRANSOSCC="cc -KPIC"
      fi

      if [ "$SGI" = "y" ]
        then
        cd $GRNUC/src/transos
        $EXTARG/bin/makemake ${MKMKOPT} imp.m.sgi ${GRTARG}/src/transos/makeimp > /tmp/$TBLDLOG 2>&1
        ncat /tmp/$TBLDLOG
        cd $GRTARG/src/transos
	TRANSOSCC="cc"
      fi

      make -rk -f makeimp FAST="$FAST" WHY="$WHY" CC="$TRANSOSCC" COPT="$COMPOPT" DOPT1="$MKDOPT" > /tmp/$TBLDLOG 2>&1
      ncat /tmp/$TBLDLOG 
      if [ "$ERRNOTI" = "on" ]
      then
        make -rk -f makeimp FAST="$FAST" WHY="$WHY" CC="$TRANSOSCC" COPT="$COMPOPT" DOPT1="$MKDOPT" > /tmp/$TBLDLOG 2>&1
        errchk /tmp/$TBLDLOG $dir
      fi
    fi
  else
    if [ -f Makefile.sun ] && [ "${SUN}" = "y" ]
    then
      make WHY=$WHY DOPT1="$MKDOPT" -rk -f Makefile.sun > /tmp/$TBLDLOG 2>&1
      ncat /tmp/$TBLDLOG 
      if [ "$ERRNOTI" = "on" ]
      then
        make WHY=$WHY DOPT1="$MKDOPT" -rk -f Makefile.sun > /tmp/$TBLDLOG 2>&1
        errchk /tmp/$TBLDLOG $dir
      fi
    else
      if [ -f Makefile ]
      then
        make WHY=$WHY DOPT1="$MKDOPT" -rk -f Makefile > /tmp/$TBLDLOG 2>&1
        ncat /tmp/$TBLDLOG 
        if [ "$ERRNOTI" = "on" ]
        then
          make WHY=$WHY DOPT1="$MKDOPT" -rk -f Makefile > /tmp/$TBLDLOG 2>&1
          errchk /tmp/$TBLDLOG $dir
        fi
      else
        make WHY=$WHY DOPT1="$MKDOPT" -rk -f $GRNUC/src/makefile > /tmp/$TBLDLOG 2>&1
        ncat /tmp/$TBLDLOG 
        if [ "$ERRNOTI" = "on" ]
        then
          make WHY=$WHY DOPT1="$MKDOPT" -rk -f $GRNUC/src/makefile > /tmp/$TBLDLOG 2>&1
          errchk /tmp/$TBLDLOG $dir
        fi
      fi
    fi
  fi
done

if [ "$UNIT_TEST" = "on" ]
then
  cd $GRNUC
  for dir in `cat $FILE_LIST`
  do
    ls -ong $SVGRTARG/$dir/* > /usr/tmp/$dir/old2
    diff /usr/tmp/$dir/old /usr/tmp/$dir/old2 2>&1
    if [ $? != 0 ]
    then
      errrpt $0 "$SVGRTARG/$dir should not have been modified" >> /usr2/tmp/$MASBLDLOG
    else
      necho "All data on $SVGRTARG was preserved"
    fi
  done
  rm -r /usr/tmp/src
  rm -r /usr/tmp/lib
  export GRLIB=$SVGRLIB
  export GRTARG=$SVGRTARG
fi
