# returns the version number of a given product on a given node

PDIR=.
RNODE=LOCAL

if [ $# -gt 0 ] 
then
 if [ $1 = -? ]
  then
   echo Usage : $0 [directory [remote node]]
   exit
 fi
 if [ $# = 1 ]
  then
    PDIR=$1
 else
    PDIR=$1
    shift
    RNODE=$1
 fi     
fi

if [ $RNODE = LOCAL ]
then
 if [ -f ${PDIR}/product.def ]
  then
    grep IDversion ${PDIR}/product.def | cut -d'=' -f2
 else
    echo NONE
 fi
else
  if [ "$SUN" = "y" ]
   then
    RLOGIN=`echo $RNODE | cut -d'.' -f2`
    RNODE=`echo $RNODE | cut -d'.' -f1`
    rsh -l $RLOGIN $RNODE grep IDversion ${PDIR}/product.def | cut -d'=' -f2
  else
    fmu $RNODE comm grep IDversion ${PDIR}/product.def | cut -d'=' -f2
  fi
fi
