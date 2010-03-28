
SRC
$(GRNUC)/src/co/pt

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/pt.a

SOURCE
 
COniesppt.I   COnipoint.C   COnitenpt.C

#else

#ifndef NT
LIB
$(GRLIB)/lib/pt.o
#else
ARCHIVE
$(GRLIB)/lib/pt.lib
#endif

SOURCE
 
COniesppt.I   COnipoint.C   COnitenpt.C

#endif

SPEC
$(EXNUC)/spec
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
acc -knr -O3
