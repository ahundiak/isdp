SOURCE
QYnpt.S
QYnpti.I
QYnptfrm.I
ACqueri.I
QYlocact.I
QYselect.I
QYnames.I

SRC
$(GRNUC)/src/query/sl

#ifndef NT
LIB
$(GRLIB)/lib/sl.o
#else
ARCHIVE
$(GRLIB)/lib/sl.lib
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
acc -knr
