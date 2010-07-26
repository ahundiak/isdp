
SRC
$(GRNUC)/src/co/rfco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/refcosp.o
#else
ARCHIVE
$(GRLIB)/lib/refcosp.lib
#endif

#else

LIB
$GRMDS/lib/refcosp.o

#endif

SOURCE

COref.S
COreviewele.S
COstrfnc.S

SPEC
$(GRNUC)/spec
$(EXNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/include
$(EXNUC)/include
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

CC
acc -knr

