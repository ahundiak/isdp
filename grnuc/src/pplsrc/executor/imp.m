SRC
$(GRNUC)/src/pplsrc/executor

SOURCE
ci_executor.S
ci_executori.I

#ifndef NT
LIB
$(GRLIB)/lib/ci_executor.o
#else
ARCHIVE
$(GRLIB)/lib/ci_executor.lib
#endif

SPEC
$(GRNUC)/spec
$(EXNUC)/spec

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

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
