
SRC
$(GRNUC)/src/go/grdglobal

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/grdglobal.a

SOURCE
goglobal.C

#else

#ifndef NT
LIB
$(GRLIB)/lib/grdglobal.o
#else
ARCHIVE
$(GRLIB)/lib/grdglobal.lib
#endif


SOURCE
goglobal.C

#endif
 
SPEC
$(EXNUC)/spec
$(EXNUC)/icob/spec
$(EXNUC)/message/spec
$(EXNUC)/fi/spec
$(GRNUC)/spec
 
INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
 
OPP
$(EXTARG)/bin/opp
 
OMCPP
$(EXTARG)/bin/omcpp
 
CC
acc -knr -o3
