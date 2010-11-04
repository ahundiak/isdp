COPT
-DBASE_EMS

TARGET
common.o
OMTdelete.x
OMTSendTime.x
OMTab.x
OMTparent.x

/* =========================================== */
SOURCE=OMTbdump
OMTbdump.C

EXEC=OMTbdump
OMTbdump.x

LINKLIB=OMTbdump
-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext -lXFI -lXFS -lUMS -lxc
common.o $EXNUC/lib/exnuc.o objects/objects.o objects/OMclassinit.o

/* =========================================== */
SOURCE=OMTdelete
OMTdelete.C

EXEC=OMTdelete
OMTdelete.x

LINKLIB=OMTdelete
-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext -lXFI -lXFS -lUMS
$LIBXC/src10/xc.o
common.o $EXNUC/lib/exnuc.o $EXNUC/lib/rapstub.o objects/objects.o objects/OMclassinit.o

/* =========================================== */
SOURCE=OMTab
OMTab.C

EXEC=OMTab
OMTab.x

LINKLIB=OMTab
-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext -lXFI -lXFS -lUMS $LIBXC/src10/xc.o
common.o
$EXNUC/lib/exnuc.o 
$EXNUC/lib/rapstub.o
objects/objects.o
objects/OMclassinit.o

/* =========================================== */
SOURCE=OMTSendTime
OMTSendTime.C

EXEC=OMTSendTime
OMTSendTime.x

LINKLIB=OMTSendTime
-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext -lXFI -lXFS -lUMS $LIBXC/src10/xc.o
common.o
$EXNUC/lib/exnuc.o 
$EXNUC/lib/rapstub.o
objects/objects.o objects/OMclassinit.o

/* ===========================================
 * Message send to parent
 */
SOURCE=OMTparent
OMTparent.C

EXEC=OMTparent
OMTparent.x

LINKLIB=OMTparent
-lm -lc -lsocket -ldl -lnsl -lX11 -lXt -lXext -lXFI -lXFS -lUMS $LIBXC/src10/xc.o
common.o
$EXNUC/lib/exnuc.o
$EXNUC/lib/rapstub.o
objects/objects.o objects/OMclassinit.o

/* ===========================================
 * Shared library stuff
 */
SOURCE=common
OMTdumprel.C

LIB=common
common.o

/* ============================================
 * Usual stuff
 */
SPEC
$EXNUC/spec
$EXNUC/om/spec

INCLUDE
$EXNUC/include
$EXNUC/om/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp -l
