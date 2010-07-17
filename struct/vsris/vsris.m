SOURCE
VScmpprfData.C
VScmpprfparm.I
VSldParmPart.I
VSexdstfrRDB.C
VSexgrdfrRDB.C
VSexmatfrRDB.C
VSexpltfrRDB.C
VSexprmfrRDB.C
VSexprtfrRDB.C
VSexshpfrRDB.C
VSextrParams.C
VSfdthkinRDB.C
VSgPpartData.C
VSisloggedin.C
VSldprtfrRDB.C
VSmbclsfrRDB.C
VSmbtypfrRDB.C
VSprtcachenm.C
VStmpltnames.I

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(VDS)/spec
$(STRUCT)/spec

LIB
$(STRUCT)/lib/vsris.o

INCLUDE
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(VDS)/include
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
