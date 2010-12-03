SOURCE
APP_main.C

EXEC
Vds

LINKLIB
-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext
-L /opt/ingr/lib -R /opt/ingr/lib
-lxml2 -lxslt -lz -lglib -lgtk -lgdk
-lIGbspmath -lPDUimage -lmodel
$UMS/lib/ums.o
$XFS/src/src10/xfs.o
$FORMS/src10/xfi.o
$LIBXC/src10/xc.o

$RIS/lib/ris.o

$NFM/lib/nfm.o
$GRNUC/src/pplsrc/src/X86_fcall.o
$VDS/lib/vds.o
OMclassinit.o

INCLUDE
$EXNUC/include
$GRNUC/include
