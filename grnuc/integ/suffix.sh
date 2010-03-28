#
#   Script to perform post processing on a build
#
# $Log: suffix.sh,v $
# Revision 1.2  2002/02/07 22:58:33  hans
# *** empty log message ***
#
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.2  1997/07/21  22:07:19  scott
# COMMENT : Removed obsolete products/components from suffix build list
#
# Revision 340.1  1997/05/29  15:42:37  scott
# COMMENT : Version upgrade for 3.4
#
# Revision 340.0  1997/05/27  22:07:41  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
#

SSLNODE=integsp2
ZXNODE=integ4u
ISLNODE=integx86
SGINODE=integsgi

verifyenv WORKDIR HOME SGI ISL SUN5 SUNZX PROD PRODUCT GRNUC VERSNO
if [ $? != 0 ]
then
   errrpt $0 "Some environment variables are NOT defined....exiting.."
   exit 1
fi

VERS=$VERSNO
MVERS=$VERSNO
FIXDIR=/usr2/fixdir

cd $WORKDIR
echo "\n\n\n"
echo "****** suffix.sh ******"
echo "\n\n\n"
if [ -f $HOME/Mail/pending ]
then
  if [ $# != 2 ]
  then
    echo "Increasing version number to ${VERS}"
    echo $VERS > $WORKDIR/versinfo
  fi

  echo "Gathering README info for version ${VERS}"
  echo "===============================================================================" > newprod/R
  echo "=== Clipper ==================================================================="  >> newprod/R
  depend.sh >> newprod/R
  echo "=== Sparc Solaris =============================================================" >> newprod/R
  rcmd $SSLNODE /GRNUCSRC/ip32/grnucsource/integ/depend.sh >> newprod/R
  echo "=== Sun Solaris (zx) ==========================================================" >> newprod/R
  rcmd $ZXNODE /GRNUCSRC/ip32/grnucsource/integ/depend.sh >> newprod/R
  echo "=== Intel Solaris =============================================================" >> newprod/R
  rcmd $ISLNODE /GRNUCSRC/ip32/grnucsource/integ/depend.sh >> newprod/R
  echo "=== Mips Irix =================================================================" >> newprod/R
  rcmd $SGINODE /GRNUCSRC/ip32/grnucsource/integ/depend.sh >> newprod/R
  echo "===============================================================================" >> newprod/R
  getfixfields -t REFERENCE DESCRIPTION FILES $HOME/Mail/pending >> newprod/R

#  This is no longer necessary as we are taking VERSNO from keyin and
#  not from versinfo file. Leading '0' has already been prefixed.
#  MVERS=`wc -c $WORKDIR/versinfo | tr -s ' ' ' ' | cut -d' ' -f2`
#  if [ $MVERS -lt 3 ]
#  then
#    MVERS=0${VERS}
#  else
#    MVERS=$VERS
#  fi
  cat $HOME/Mail/pending >> $HOME/Mail/fixes340.${MVERS}
  if [ -s $HOME/Mail/fixes340.${MVERS} ]
  then
    rm -f $HOME/Mail/pending
  fi
fi

#  This is no longer necessary as we are taking VERSNO from keyin and
#  not from versinfo file. Leading '0' has already been prefixed.
#MVERS=`wc -c $WORKDIR/versinfo | tr -s ' ' ' '| cut -d' ' -f2`
#if [ $MVERS -lt 3 ]
#then
#  MVERS=0${VERS}
#else
#  MVERS=$VERS
#fi
cd ${WORKDIR}/newprod
upproduct.sh -s -v 03.04.00.${MVERS} $PROD
upREADME.sh -q $PROD 03.04.00.${MVERS}

if [ "$PROD" = "MODEL" ]
then
  ln $MODEL/newprod/model/README $MODEL/newprod/modeldp/README
  ln $MODEL/newprod/model/README $MODEL/newprod/modelsrc/README
  export SAVEWORKDIR=$WORKDIR
  for file in ems emsplt emsppp emspcs mds
  do
    export WORKDIR=$MODEL/$file
    cd ${WORKDIR}/newprod
    upproduct.sh -s -v 03.04.00.${MVERS} $file
    upREADME.sh -q $file 03.04.00.${MVERS}
  done
  export WORKDIR=$SAVEWORKDIR
else
  if [ "$PROD" = "GRNUC" ]
  then
    ln $GRNUC/newprod/grnuc/README $GRNUC/newprod/grnucdp/README
    ln $GRNUC/newprod/grnuc/README $GRNUC/newprod/grnucsrc/README
  else
    if [ "$PROD" = "MDS" ]
    then
      ln $MDS/newprod/mdsdp/README $MDS/newprod/mdsdp/README
    fi
  fi
fi
