
INCLUDE
$(INGRHOME)/include
$(INGRHOME)/include
/usr/ip32/lgdev/lg_libs
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/lg/lastprod

EXEC
$(GRLIB)/bin/.lglastprod

SOURCE
lglastprod.c
