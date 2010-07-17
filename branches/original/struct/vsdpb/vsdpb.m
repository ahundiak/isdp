SOURCE
VSdpb.S
VSdpb_const.I
VSdpb_func.I
VSdpb_get.I
VSdpb_put.I
VSdpb_sleep.I
VSdpb_wakeup.I
VSdpbhavdata.I
VSdpbColl.I
VSglobals.C
VSactjnattr.C

VSvrsnStamp.S
VSvssleep.I
VSvsfunction.I

LIB
$(STRUCT)/lib/vsdpb.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(STRUCT)/spec

INCLUDE
$(BS)/include
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
