SOURCE
VSsharedData.S
VSsdputdata.I
VSsdgetdata.I
VSsdmemcnt.I
VSsdgivestrc.I
VSsdcptoroot.I
VSsdreturngo.I
VSsddebug.I
VSsdutil.C
VSdataMgr.S
VSdmgetcoll.I
VSdmfindcoll.I
VSdminscoll.I
VSdmdebug.I
VSdmutil.I

LIB
$(STRUCT)/lib/vsdata.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(STRUCT)/spec

INCLUDE
$(GRNUC)/include/$(CPUTYPE)
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
