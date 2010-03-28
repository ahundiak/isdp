#
#  upproduct.sh - update the version number and date in the product.def files
#                 in ${prod}, ${prod}src, ${prod}dp
#
#   Tim McKee    27 Feb 1990
#   scw          13 Sep 1994  Added intel solaris platform
#   sam          28 Feb 1995  Removed mds from dp - now it is an app on model
#
SYSVERS=off
SYSDATE=off
GPATH=${WORKDIR}/newprod

#
#  get new version and new date
#
while [ $# -gt 1 ]
do
  case $1 in
    -s) SYSDATE=on
        shift;;
    -v) SYSVERS=on
        shift
        if [ $# -gt 0 ]
         then
          DEFVERS=$1
        else
         echo "ERROR no version number given"
         exit
        fi
        shift;;
     *) echo "ERROR in command line"
        exit;;
  esac
done

prod=`echo $1 | tr "[A-Z]" "[a-z]"`

#DEFDATE=`date '+%d-%h-19%y' | tr "[a-z]" "[A-Z]"`
DEFDATE=`date '+%d-%h-%Y'`
echo "\n\n"
echo "Previous Version : \c"
fgrep IDversion ${GPATH}/${prod}/product.def | grep -v SUN_IDversion | cut -d'=' -f2
if [ $SYSVERS = off ]
 then
  echo "\n\n"
  echo "Enter New Version [           ]\b\b\b\b\b\b\b\b\b\b\b\b\c"
  read NEWVERS
else
  NEWVERS=$DEFVERS
fi

if [ $SYSDATE = off ]
 then
  echo
  echo "Enter Version Date [$DEFDATE]\b\b\b\b\b\b\b\b\b\b\b\b\c"
  read NEWDATE; : ${NEWDATE:=$DEFDATE}
else
  NEWDATE=$DEFDATE
fi
NEWDATE=`echo $NEWDATE | tr "[a-z]" "[A-Z]"`


for pdeffile in product.def product.sgi product.clip product.ssl product.isl
do
  #
  # update ${pdeffile} in ${prod}
  #
  OLDVERS=`fgrep IDversion= $GPATH/${prod}/${pdeffile} | grep -v SUN_IDversion`
  OLDDATE=`fgrep IDdate= $GPATH/${prod}/${pdeffile}`
  echo "\n . . . changing version number to $NEWVERS"
  echo "          and date to $NEWDATE in $GPATH/${prod}/${pdeffile}"
  sed "s/$OLDVERS/IDversion=$NEWVERS/1" $GPATH/${prod}/${pdeffile} > $GPATH/${prod}/${pdeffile}.new
  sed "s/$OLDDATE/IDdate=$NEWDATE/1" $GPATH/${prod}/${pdeffile}.new > $GPATH/${prod}/${pdeffile}
  rm $GPATH/${prod}/${pdeffile}.new
done
pdeffile=product.def

  if [ "${prod}" = "model" ] || [ "${prod}" = "grnuc" ]
   then
  #
  # update ${pdeffile} in ${prod}dp
  #
  OLDVERS=`fgrep IDversion= $GPATH/${prod}dp/${pdeffile} | grep -v SUN_IDversion`
  OLDDATE=`fgrep IDdate= $GPATH/${prod}dp/${pdeffile}`
  echo "\n . . . changing version number to $NEWVERS"
  echo "          and date to $NEWDATE in $GPATH/${prod}dp/${pdeffile}\n"
  sed "s/$OLDVERS/IDversion=$NEWVERS/1" $GPATH/${prod}dp/${pdeffile} > $GPATH/${prod}dp/${pdeffile}.new
  sed "s/$OLDDATE/IDdate=$NEWDATE/1" $GPATH/${prod}dp/${pdeffile}.new > $GPATH/${prod}dp/${pdeffile}
  rm $GPATH/${prod}dp/${pdeffile}.new

  if [ "${prod}" = "model" -o "${prod}" = "grnuc" ]
   then
  #
  # update ${pdeffile} in ${prod}src
  #
   OLDVERS=`fgrep IDversion= $GPATH/${prod}src/${pdeffile} | grep -v SUN_IDversion`
   OLDDATE=`fgrep IDdate= $GPATH/${prod}src/${pdeffile}`
   echo "\n . . . changing version number to $NEWVERS"
   echo "          and date to $NEWDATE in $GPATH/${prod}src/${pdeffile}"
   sed "s/$OLDVERS/IDversion=$NEWVERS/1" $GPATH/${prod}src/${pdeffile} > $GPATH/${prod}src/${pdeffile}.new
   sed "s/$OLDDATE/IDdate=$NEWDATE/1" $GPATH/${prod}src/${pdeffile}.new > $GPATH/${prod}src/${pdeffile}
   rm $GPATH/${prod}src/${pdeffile}.new
  fi
 fi
