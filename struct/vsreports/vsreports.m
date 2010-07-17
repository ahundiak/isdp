SOURCE
VSreportobjs.C
VSvalfrreprt.I

LIB
$(STRUCT)/lib/vsreports.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(VDS)/include
$(VDS)/vdinclude
$(STRUCT)/include

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN __APGE__

CC
acc -ansi -O3
