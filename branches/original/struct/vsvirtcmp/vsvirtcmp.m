SOURCE
VSvirtcmp.S
VSvcgetvrown.I
VSvcmakesrc.I
VSvcputvrown.I

VSvirtcmpref.S
VSvcmkvrtcmp.I

LIB
$(STRUCT)/lib/vsvirtcmp.o

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
$(MODEL)/include
$(VDS)/include
$(VDS)/vdinclude
$(STRUCT)/include
$(STRUCT)/include/prototypes

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN

CC
acc -ansi -O3