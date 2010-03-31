#
# maincompile.sh - main compilation script
# 
#    Usage  : maincompile.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: maincompile.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:07:28  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/04/17  14:25:46  scott
# COMMENT : Made modifications to make switches to work around Solaris 2.5 bug
#
# Revision 330.0  1996/01/11  23:15:20  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  22:47:58  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.8  1994/10/29  04:41:18  scott
# COMMENT : Added SUNZX platform 3.2 ports
#
# Revision 240.7  1994/08/13  16:43:31  model40
# COMMENT : upgrade for v3.1 / Intel Solaris port
#
# Revision 240.6  1993/11/23  14:37:25  scott
# COMMENT : Correction for src_util/graph directory on the C400 box
#
# Revision 240.5  1993/09/20  14:16:29  model20
# COMMENT : Added conditional for c400
#
# Revision 240.4  1993/09/17  13:58:00  scott
# COMMENT : Added support for the integration and delivery of a Sparc Solaris platform
#
# Revision 240.3  1993/06/21  12:30:31  model20
# COMMENT : fixed problem with running maincompile.sh via nohup
#
# Revision 240.1  1993/04/20  14:17:34  model20
# COMMENT : putting startup commands in model
#
# Revision 220.4  1993/02/22  16:17:21  model22
# COMMENT : added capability to exclude some files for sun/sgi compilation
#
# Revision 220.3  1993/02/16  00:01:21  model22
# COMMENT : fixes for unit testing
#
# Revision 220.1  1993/02/14  20:26:35  tim
# COMMENT : put in unit test code
#
# Revision 220.0  1993/02/13  23:07:50  tim
# COMMENT : changes to integration scripts to do unit testing
#
#
trap 'cat /usr2/tmp/$MASBLDLOG >> ${LOGFILE}; rm /usr2/tmp/$MASBLDLOG; exit' 2
trap 'cat /usr2/tmp/$MASBLDLOG >> ${LOGFILE}; rm /usr2/tmp/$MASBLDLOG; exit' 9

verifyenv MDTARG MODEL COMPILER COMPOPT MKDOPT MAKEFILE SUN5 SUNZX ISL

cd $MDTARG/config
necho "making config directory....."
grmake -rk -f $MODEL/config/Makefile > /tmp/bldlog 2>&1
ncat /tmp/bldlog
if [ "$ERRNOTI" = "on" ]
then
  grmake -rk -f $MODEL/config/Makefile > /tmp/bldlog 2>&1
  errchk /tmp/bldlog $file
fi

if [ "$ISL" = "y" ]
then
  LIST=`cat $MODEL/integ/makelist | fgrep -v -f $MODEL/integ/islnomake`
fi

if [ "$SUN5" = "y" -o "$SUNZX" = "y" ]
then
  LIST=`cat $MODEL/integ/makelist | fgrep -v -f $MODEL/integ/sunnomake`
fi

if [ "$SGI" = "y" ]
then
  LIST=`cat $MODEL/integ/makelist | fgrep -v -f $MODEL/integ/sginomake`
fi

if [ "$CLIPPER" = "y" -o "$C400" = "y" ]
then
  LIST=`cat $MODEL/integ/makelist`
fi

cd $MDTARG
for file in $LIST
do
 
  cd $file
  pwd

  MFILE=

  necho " - - - - - - - - - - - - - - $file - - - - - - - - - - - - - - - "
  if [ -f make.sl ]
  then
    make -rk -f make.sl > /tmp/bldlog 2>&1
    ncat /tmp/bldlog
    if [ "$ERRNOTI" = "on" ]
    then
       make -rk -f make.sl > /tmp/bldlog 2>&1
       errchk /tmp/bldlog $file
    fi
       
  fi
 
  if [ -f Makefile ]
  then
    if [ -f Makefile.sun ] && ([ "${SUN5}" = "y" ] || [ "${SUNZX}" = "y" ] || [ "${ISL}" = "y" ])
    then
      make -rk -f Makefile.sun $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
      ncat /tmp/bldlog
      if [ "$ERRNOTI" = "on" ]
      then
        make -rk -f Makefile.sun $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
        errchk /tmp/bldlog $file
      fi
    else
      make -rk -f Makefile $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
      ncat /tmp/bldlog
      if [ "$ERRNOTI" = "on" ]
      then
        make -rk -f Makefile $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
        errchk /tmp/bldlog $file
      fi
    fi
  fi
 
  if [ -f makespec ]
  then
    make -rk -f makespec $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
    ncat /tmp/bldlog
    if [ "$ERRNOTI" = "on" ]
    then
      make -rk -f makespec $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
      errchk /tmp/bldlog $file
    fi
  fi
  if [ -f makeimp ]
  then
    make -rk -f makeimp $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
    ncat /tmp/bldlog
    if [ "$ERRNOTI" = "on" ]
    then
      make -rk -f makeimp $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
      errchk /tmp/bldlog $file
    fi
  fi
  if [ -f makefile ]
  then
   
    make -rk -f $MAKEFILE $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
 
    ############
    ## Special casing for C400 box
    ############
    if [ "$C400" = "y" ] && [ "$file" = "src_util/graph" ]
    then
      cp $MODEL/src_util/graph/Makefile $MDTARG/src_util/graph/
      make -rk -f Makefile $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" >> /tmp/bldlog 2>&1
      ncat /tmp/bldlog
      if [ "$ERRNOTI" = "on" ]
      then
        make -rk -f Makefile $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" >> /tmp/bldlog 2>&1
        errchk /tmp/bldlog $file
      fi
    fi
    ############
    ## End special casing for C400
    ############
 
    ncat /tmp/bldlog
    if [ "$ERRNOTI" = "on" ]
    then
      make -rk -f $MAKEFILE $MFILE CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
      errchk /tmp/bldlog $file
    fi
  fi
  if [ -f make.ppl ]
  then
    make -rk -f make.ppl $MFILE > /tmp/bldlog 2>&1
    ncat /tmp/bldlog
    if [ "$ERRNOTI" = "on" ]
    then
      make -rk -f make.ppl $MFILE > /tmp/bldlog 2>&1
      errchk /tmp/bldlog $file
    fi
  fi
  cd $MDTARG
done

