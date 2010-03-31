if [ "$CLIPPER" = "y" ]
then
   makeEMSver.sh EMS_Cornerstone EMSCS "SM**230" $MODEL/emspcs/EMSCSver.c
   makeEMSver.sh EMS_PowerPak EMSPP "SM**236" $MODEL/emsppp/EMSPPver.c
   makeEMSver.sh EMS_Lite EMSLT "SM**285" $MODEL/emsplt/EMSLTver.c
   makeEMSver.sh MDS MDS "SM**082" $MODEL/mds/MDSver.c
fi

cd $MDTARG
for file in emspcs emsppp emsplt mds
do
 cd $file

 if [ ! -d config/dload/init ]
 then 
   mkdir -p config/dload/init
 fi

 if [ "$SUN5" = "y" ]
 then
   $COMPILER $COMPOPT -c -K PIC -I${EXNUC}/include $MODEL/$file/*ver.c
   ${EXTARG}/bin/omcpp -I${EXNUC}/include $MODEL/$file/OMprodinit.C > ./OMprodinit.c
   $COMPILER $COMPOPT -c -K PIC -I${EXNUC}/include OMprodinit.c
   VERSFILE=`\ls *ver.o`
   ld -z text -G -o config/dload/init/${VERSFILE%.o}.so ${VERSFILE} OMprodinit.o
 fi

 if [ "$SUNZX" = "y" ]
 then
   $COMPILER $COMPOPT -c -KPIC -I${EXNUC}/include $MODEL/$file/*ver.c
   ${EXTARG}/bin/omcpp -I${EXNUC}/include $MODEL/$file/OMprodinit.C > ./OMprodinit.c
   $COMPILER $COMPOPT -c -KPIC -I${EXNUC}/include OMprodinit.c
   VERSFILE=`\ls *ver.o`
   ld -z text -G -o config/dload/init/${VERSFILE%.o}.so ${VERSFILE} OMprodinit.o
 fi

 if [ "$ISL" = "y" ]
 then
   $COMPILER $COMPOPT -c -K PIC -I${EXNUC}/include $MODEL/$file/*ver.c
   ${EXTARG}/bin/omcpp -I${EXNUC}/include $MODEL/$file/OMprodinit.C > ./OMprodinit.c
   $COMPILER $COMPOPT -c -K PIC -I${EXNUC}/include OMprodinit.c
   VERSFILE=`\ls *ver.o`
   ld -z text -G -o config/dload/init/${VERSFILE%.o}.so ${VERSFILE} OMprodinit.o
 fi

 if [ "$SGI" = "y" ]
 then
    $COMPILER -common $COMPOPT -c -I${EXNUC}/include ${MODEL}/$file/*ver.c
    $EXTARG/bin/omcpp -I$EXNUC/include $MODEL/$file/OMprodinit.C > OMprodinit.c
    $COMPILER -common $COMPOPT -c OMprodinit.c
    VERSFILE=`\ls *ver.o`
    ld -shared -o config/dload/init/${VERSFILE%.o}.so ${VERSFILE} OMprodinit.o
 fi

 if [ "$CLIPPER" = "y" -o "$C400" = "y" ]
 then
    $COMPILER $COMPOPT -I$EXNUC/include -c $MODEL/$file/*ver.c
    $EXTARG/bin/omcpp -I$EXNUC/include $MODEL/$file/OMprodinit.C > OMprodinit.c
    $COMPILER $COMPOPT -c OMprodinit.c
    ln OMprodinit.o config/dload/init
    ln *ver.o config/dload/init
 fi
 cd $MDTARG
done
