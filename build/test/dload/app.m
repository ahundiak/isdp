SOURCE
main.c
math.c

EXEC
dload

LINKLIB
-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext
-lxml2 -lxslt -lz -lglib
-lIGbspmath
-lmodel
$LIBXC/src10/xc.o

#if 0
-lPDUimage
$UMS/src10/ums.o
$XFS/src/src10/xfs.o
$FORMS/src10/xfi.o
$LIBXC/src10/xc.o
$EXNUC/lib/exnuc.o
$GRNUC/lib/grnuc.o
$MODEL/lib/model.o
$VDS/lib/vds.o
OMclassinit.o
#endif
        
INCLUDE
$BS/include
$BS/include/prototypes
$LIBXC/include
$EXNUC/include
$GRNUC/include
