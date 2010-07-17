SOURCE
env_access.c
sef_access.c
uncvt_comp.c
uncvt_sys.c
uncvtshape.c
env.I
VSEnvIgds.S
VSEnvIgdsi.I

LIB
$(STRUCT)/lib/vsigds.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec


INCLUDE
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/src/assoc/include_priv
$(MODEL)/include
$(VDS)/include
$(STRUCT)/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi -03

