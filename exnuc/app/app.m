TARGET
Exnuc

/* =========================================== */
SOURCE=Exnuc
APP_main.C

EXEC=Exnuc
Exnuc

LINKLIB=Exnuc
-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext
$UMS/src10/ums.o
$XFS/src/src10/xfs.o
$FORMS/src10/xfi.o
$LIBXC/src10/xc.o
$EXNUC/lib/exnuc.o
OMclassinit.o
        
/* ============================================
 * Usual stuff
 */
SPEC
$EXNUC/spec

INCLUDE
$EXNUC/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
