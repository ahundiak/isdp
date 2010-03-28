
SRC
$(GRNUC)/src/grio/grio_sp

#ifdef IDRAW
LIB
$GRMDS/lib/grio_sp.o

SOURCE
GRgnunit.S   GRunit.S     GRvar.S

#else

#ifndef NT
LIB
$(GRLIB)/lib/grio_sp.o
#else
ARCHIVE
$(GRLIB)/lib/grio_sp.lib
#endif

SOURCE
GRgnunit.S   GRunit.S     GRvar.S

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
