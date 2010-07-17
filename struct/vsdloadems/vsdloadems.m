SOURCE
ECprfwfrcons.I
EMplFmtSf.I
EMssmkwrfrm.I
GRpallib.I

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(MODEL)/include
$(STRUCT)/include
$(STRUCT)/include/prototypes

OMCPP
$(EXNUC)/bin/omcpp

OPP
$(EXNUC)/bin/opp

LIB
$(STRUCT)/lib/vsdloadems.o

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN __APGE__ _INGR_EXTENSIONS

CC
acc -ansi -O3
