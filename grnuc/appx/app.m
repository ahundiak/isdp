TARGET
Grnuc

/* =========================================== */
SOURCE=Grnuc
APP_main.C

EXEC=Grnuc
Grnuc

LINKLIB=Grnuc
-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext -lIGbspmath
$UMS/src10/ums.o
$XFS/src/src10/xfs.o
$FORMS/src10/xfi.o
$LIBXC/src10/xc.o
$EXNUC/lib/exnuc.o
$GRNUC/lib/grnuc.o
$GRNUC/lib/ems_stubs.o
$GRNUC/lib/gr_perm_stubs.o
OMclassinit.o
        
/* ============================================
 * Usual stuff
 */
SPEC
$EXNUC/spec
$GRNUC/spec

INCLUDE
$EXNUC/include
$GRNUC/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
