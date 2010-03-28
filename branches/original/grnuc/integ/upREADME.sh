#
# script to automatically mail the new version info and update the README file
#  expects the file R to be in $PROD/newprod (hold fixes info)
#
#  Tim Mckee 02/23/90
#
# $Log: upREADME.sh,v $
# Revision 1.2  2002/02/06 23:29:28  hans
# *** empty log message ***
#
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:47  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:23:25  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:52  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1993/04/29  14:11:24  tim
# COMMENT : upREADME.sh now handles case when README file is empty and when no fixes are listed (repackage, etc.)
#
#


if [ $# -gt 3 ]
 then
  echo " * USAGE IS     upREADME.sh [-q] product version_number"
  exit
fi

verifyenv GRNUC WORKDIR

QUIET=off
if [ "$1" = "-q" ]
 then
  QUIET=on
  shift
fi

# $1 is now the product name   ex: GRNUC
PROD=`echo $1 | tr "[A-Z]" "[a-z]"`
UPROD=`echo $1 | tr "[a-z]" "[A-Z]"`
shift

# WORKDIR defined in deliver20 ex: WORKDIR=/usr2/ip32/grnuc20
TOPPRODFILE=${WORKDIR}/newprod/${PROD}/product.def

WS_DIR=${WORKDIR}/newprod
cd ${WS_DIR}
cp ./${PROD}/README README 2>/dev/null

#
# make sure needed files exist and have data
#
if [ ! -s "R" ]
 then
  echo "WARNING -- R does not exist or is empty"
  echo > R
fi
if [ ! -s "README" ]
 then
  echo "WARNING -- README does not exist or is empty"
  VERS=999
else
  #
  # get last version number entered into README
  #
  grep "VERSION" README | cut -f9 -d" " > tmp1
  read LVERS < tmp1
  VERS=`echo $LVERS | cut -f2 -d" "`
  echo "Last version listed in ${UPROD} README" $VERS
fi


#
# if version number is the same as the last one entered just cat R onto the
# end of README
#      SUBPRODS defined in deliver20 ex: SUBPRODS=exnuc bspmath
#      $1 now equals the version number ex: 02.00.01.00
#
if [ "$VERS" = "$1" ]
 then
  echo "Adding additional README info. for version "$1
  cat R >> README
else 		# regenerate README
  echo "Creating README for version "$1

  echo ";"                                 > README
  echo ";   PRODUCT NUMBER:     "`grep IDnumber  $TOPPRODFILE \
                         | cut -f2 -d"="`  >> README
  echo ";   PRODUCT NAME:       "`grep IDtitle   $TOPPRODFILE \
                         | cut -f2 -d"="   \
                         | cut -f1-2 -d" " \
                         | cut -f2 -d'"'`  >> README
  echo ";   PRODUCT DIRECTORY:  "$UPROD  >> README
  echo ";"                                 >> README
  echo ";   DATE:               "`date +"%e-%h-%Y" | tr "[a-z]" "[A-Z]"` >> README
  echo ";   PRODUCT VERSION:    "$1 >> README
  echo ";"                                 >> README
  echo ";       Built on:"                 >> README

  for subpr in $SUBPRODS
  do
     upprod=`echo ${subpr} | tr "[a-z]" "[A-Z]"`
     echo ";           ${upprod}:\t"`dates ${upprod} | tr -s ' ' ' ' | cut -d' ' -f4` >> README
  done

  echo ""                                  >> README
  echo "==================================================================="\
                                           >> README
  echo ""                                  >> README
  echo ""                                  >> README
  cat R                                    >> README
fi

#
# clean up files
#
cp README ./${PROD}/README
rm -f R
rm -f README
