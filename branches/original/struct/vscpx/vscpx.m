SOURCE
VScpx.S
VScxalwstrue.I
VScxattach.I
VScxcreatdef.I
VScxdescfoot.I
VScxevaluate.I
VScxgiveoutp.I
VScxgrinput.I
VScxpreconst.I
VScxwhosdyin.I
VSrtdescfoot.I

VShelper.S
VShrconst.I
VShrobjinfo.I

LIB
$(STRUCT)/lib/vscpx.o

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
