# grmkmk.sh - Makes the makefiles
#
#
#    Usage       : grmkmk.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grmkmk.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:51  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/08/01  13:58:47  grnuc33
# COMMENT : Removed UNIT_TEST stuff
#
# Revision 330.0  1996/01/11  20:22:31  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1995/08/28  06:05:21  grnuc32
# COMMENT : Corrected error mailing problems for TD and xgl
#
# Revision 320.0  1994/12/12  16:56:58  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.9  1994/08/09  19:52:11  grnuc40
# COMMENT : PotrPorted to Intel Solaris
#
# Revision 240.8  1994/08/06  06:32:47  samuel
# COMMENT : Modified scripts from remote integration and redirected compiling banner->logfile
#
# Revision 240.6  1993/10/14  21:12:36  dodd
# COMMENT : Removing lg, gde, and gpipe references from Solaris and Irix5 builds - JSD
#
# Revision 240.5  1993/05/05  19:56:13  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#


# verify that all environment variables used in this script are defined.

verifyenv GRNUC GRTARG SGI MASBLDLOG TBLDLOG
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

if [ "$CLIPPER" = "y" -o "$C400" = "y" ]
then
  MAILER=elm
else
  MAILER=Mail
fi

OTHER_LIST="src/fontbuilder/fconv/FF_src
            src/fontbuilder/fconv/FS_src
            src/fontbuilder/fconv/Flib_src
            src/fontbuilder/fconv/UT_src
            src/fontbuilder/fconv/EX_src
            src/fontbuilder/fconv/CF_src
            src/pplsrc/com
            src/pplsrc/src
            src/pplsrc/setup
            src/pplsrc/cinotify
            src/pplsrc/ciexpr
            src/pplsrc/listener
            src/pplsrc/executor
            src/pplsrc/user_data
            src/pplsrc/cci"

MAKELIST="`cat $GRNUC/integ/makelist` $OTHER_LIST"

banner ""
banner "COMPILING"
banner ""

banner "Compiling" | $MAILER -s "Compiling Banner" $BUILDER
banner "COMPILING" >> /usr2/tmp/$MASBLDLOG

necho "\n----------$UNIT_MESS making the makefiles ----------\n"

for dir in $MAKELIST
do
  # some directories do not exist on foreign boxes

  if [ "$SGI" = "y" -o "$SUN5" = "y" -o "$ISL" = "y" -o "$SUNZX" = "y" ]
  then
    case "$dir" in
      "src/lg/options"    | \
      "src/lg/lastprod"   | \
      "src/lg/copyos"     ) continue ;;
    esac
  fi

  if [ ! -d $GRNUC/$dir ]
  then
    errrpt $0 "$GRNUC/$dir does not exist" >> /usr2/tmp/$MASBLDLOG
    continue
  fi

  cd $GRNUC/$dir
  export MSRC=$dir

  if [ -f imp.m ]
  then
    make -f $GRNUC/integ/mkmakefile ${GRTARG}/${MSRC}/makeimp >> /tmp/$TBLDLOG 2>&1
    ncat /tmp/$TBLDLOG
  fi

  if [ -f spec.m ]
  then
    make -f $GRNUC/integ/mkmakefile ${GRTARG}/${MSRC}/makespec >> /tmp/$TBLDLOG 2>&1
    ncat /tmp/$TBLDLOG
  fi
done
