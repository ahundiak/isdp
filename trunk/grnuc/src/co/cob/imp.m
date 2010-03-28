
SRC
$(GRNUC)/src/co/cob

#ifdef IDRAW
ARCHIVE 
$GRMDS/lib/cob.a

SOURCE
COexpi.I
COFunInRan.C
COconsti.I
COcoordi.I
COmeas1.I
COmeas2.I
COmeas3.I
COnptBas.I
COnptDir.I
COnptDisp.I
COnptGr.I
COnptMisc.I
COnptOvrd.I
COnptSM.I
COrooti.I
strindex.C
DEselect.I
DElocact.I
COmoddtl.I
extlocact.I
#else

#ifndef NT
LIB
$(GRLIB)/lib/cob.o
#else
ARCHIVE
$(GRLIB)/lib/cob.lib
#endif

SOURCE
COexpi.I
COFunInRan.C
COconsti.I
COcoordi.I
COmeas1.I
COmeas2.I
COmeas3.I
COnptBas.I
COnptDir.I
COnptDisp.I
COnptGr.I
COnptMisc.I
COnptOvrd.I
COnptSM.I
COrooti.I
strindex.C
DEselect.I
DElocact.I
DEnpti.I
COmoddtl.I
extlocact.I
#endif

INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr -O3
