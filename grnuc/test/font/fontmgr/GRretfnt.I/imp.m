INCLUDE
$(INGRHOME)/include
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include

SPEC
$(EXNUC)/spec
$(EXNUC)/cob/spec
$(EXNUC)/fi/spec
$(EXNUC)/message/spec
$(EXNUC)/icob/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

COPT
-g

OPPFLAGS
-l

LIB
$(GRNUC)/test/lib/GRfontmgrtst.o

SOURCE
GRloadfnts.C
