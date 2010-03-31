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
  fmu $RNODE comm grep IDversion ${PDIR}/product.def | cut -d'=' -f2
fi
