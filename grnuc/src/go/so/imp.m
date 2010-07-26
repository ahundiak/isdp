CC 
acc -knr

SOURCE

DEsoi.I
DEsuper.I
DEinit.I
DEview.I
DEcontext.I
DEmac.I
DEdisyours.I
DEdistext.I
DEcvdisel.C
DEbdrys.C
DEglob.C

SRC
$(GRNUC)/src/go/so

#ifndef NT
LIB
$(GRLIB)/lib/DEso.o
#else
ARCHIVE
$(GRLIB)/lib/DEso.lib
#endif


SPEC
$(EXNUC)/spec
$(GRNUC)/spec

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

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
