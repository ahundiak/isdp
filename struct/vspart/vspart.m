SOURCE
VSpart.S
VSprifsrcsnd.I
VSprnamehold.I
VSprorient.I
VSprsubcmpid.I
VSprsubcmpix.I
VSprsubcmpnm.I
VSprtrnmtoix.I
VSprtrixtonm.I
/*
	Parts with DPR graphics.
*/
VSdprPart.S
VSdpgetipath.I
VSdpbldipath.I
VSdpsubcmpix.I

LIB
$(STRUCT)/lib/vspart.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
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
