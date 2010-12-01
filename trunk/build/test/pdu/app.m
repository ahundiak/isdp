SOURCE
main.c

EXEC
pdu

LINKLIB
-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext
-lxml2 -lxslt -lz -lglib
-lIGbspmath
-lPDUimage
$UMS/src10/ums.o
$XFS/src/src10/xfs.o
$FORMS/src10/xfi.o
$LIBXC/src10/xc.o
$EXNUC/lib/exnuc.o
$GRNUC/lib/grnuc.o
$GRNUC/lib/ems_stubs.o
$GRNUC/lib/gr_perm_stubs.o
$GRNUC/lib/gr_temp_stubs.o
$GRNUC/src/pplsrc/src/X86_fcall.o
OMclassinit.o

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
