INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
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

COPT
-ga

SRC
$(GRNUC)/src/co/attrco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/attrcosp.o
#else
ARCHIVE
$(GRLIB)/lib/attrcosp.lib
#endif

#else

LIB
$(GRMDS)/lib/attrcosp.o

#endif

SOURCE
COattr.S
COcpattr.S
