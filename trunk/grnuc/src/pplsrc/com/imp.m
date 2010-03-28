SRC
$(GRNUC)/src/pplsrc/com

OMCPP
$(EXTARG)/bin/omcpp

SOURCE
cistore.C
cifentry.C
cimem.C

#ifndef NT
LIB
$(GRLIB)/lib/cicom.o
#else
ARCHIVE
$(GRLIB)/lib/cicom.lib
#endif

INCLUDE
$(INGRHOME)/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
