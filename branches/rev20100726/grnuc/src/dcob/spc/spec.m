OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

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

SRC
$(GRNUC)/src/dcob/spc

#ifdef IDRAW

LIB
$GRMDS/lib/libcobdrafts.o

#else


#ifndef NT
LIB
$(GRLIB)/lib/libcobdrafts.o
#else
ARCHIVE
$(GRLIB)/lib/libcobdrafts.lib
#endif

#endif

SOURCE
CEO_LOCATE.S
CEO_GSLOCATE.S

