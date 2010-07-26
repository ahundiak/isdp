# This shell script is used to change the version number and date of PROD

if [ $# -lt 1 ]
then
 echo "usage : makever.sh product_path product_name version date"
 exit 9
fi

if [ $# = 4 ]
 then
  PROD=$1
  PRODNAM=$2
  VER=$3
  DATE=$4
  CMDLN="y"
else
  errrpt $0 "incorrect arguments"
  exit 1
fi

PRODver=${PRODNAM}ver

OLDVER=`grep INGR_S_PRODUCT_DEF ${PROD}/${PRODver}.c | cut -d' ' -f5-6`
NEWVER="$VER $DATE\","

replace "${OLDVER}" "${NEWVER}" ${PROD}/${PRODver}.c 

if [ ! -d config/dload/init ]
  then
   echo "config/dload/init did not exist, creating......"
   mkdir -p config/dload/init
fi

if [ "$SUN5" = "y" ]
then 
  $COMPILER -c -KPIC -xildoff -I${EXNUC}/include ${PROD}/${PRODver}.c
  ${EXTARG}/bin/omcpp -I${EXNUC}/include ${PROD}/OMprodinit.C > ./OMprodinit.c
  $COMPILER -c -KPIC -xildoff -I${EXNUC}/include OMprodinit.c
  ld -z text -G -o config/dload/init/${PRODver}.so ${PRODver}.o OMprodinit.o
fi

if [ "$SUNZX" = "y" ]
then
  $COMPILER -c -KPIC -xildoff -I${EXNUC}/include ${PROD}/${PRODver}.c
  ${EXTARG}/bin/omcpp -I${EXNUC}/include ${PROD}/OMprodinit.C > ./OMprodinit.c
  $COMPILER -c -KPIC -xildoff -I${EXNUC}/include OMprodinit.c
  ld -z text -G -o config/dload/init/${PRODver}.so ${PRODver}.o OMprodinit.o
fi

if [ "$ISL" = "y" ]
then
  $COMPILER -c -KPIC -I${EXNUC}/include ${PROD}/${PRODver}.c
  ${EXTARG}/bin/omcpp -I${EXNUC}/include ${PROD}/OMprodinit.C > ./OMprodinit.c
  $COMPILER -c -KPIC -I${EXNUC}/include OMprodinit.c
  ld -z text -G -o config/dload/init/${PRODver}.so ${PRODver}.o OMprodinit.o
fi

if [ "$SGI" = "y" ]
then
  $COMPILER -common $COMPOPT -c -I${EXNUC}/include ${PROD}/${PRODver}.c
  $EXTARG/bin/omcpp -I$EXNUC/include ${PROD}/OMprodinit.C > OMprodinit.c
  $COMPILER -common $COMPOPT -c OMprodinit.c
  ld -shared -o config/dload/init/${PRODver}.so ${PRODver}.o OMprodinit.o
fi

if [ "$CLIPPER" = "y" -o "$C400" = "y" ]
then
  $COMPILER $COMPOPT -c -I${EXNUC}/include ${PROD}/${PRODver}.c
  $EXTARG/bin/omcpp -I$EXNUC/include ${PROD}/OMprodinit.C > OMprodinit.c
  $COMPILER $COMPOPT -c OMprodinit.c
  ln ${PRODver}.o config/dload/init
  ln OMprodinit.o config/dload/init
fi
