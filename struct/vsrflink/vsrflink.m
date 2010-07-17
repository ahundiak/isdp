SOURCE
VSrflPlate.S
VSrpcnstfeet.I
VSrpgetedatt.I
VSrpgetobjdf.I
VSrpgetspprt.I
VSrpimprtdat.I
VSrptopbotmp.I

VSrfvPlate.S
VSrvgetedatt.I
VSrvgetobjdf.I

VSrflBeam.S
VSrbcnstfeet.I
VSrbcnstline.I
VSrbgetedatt.I
VSrbgetobjdf.I
VSrbgetspprt.I
VSrbimprtdat.I
VSrbrgenaxis.I

VSrfsBeam.S
VSrsgetedatt.I
VSrsgetobjdf.I
VSrsimprtdat.I
VSrsxdirCS.I

VScopybmface.I
VScstRflElem.I
VSfndRflName.I
VSgetvcfrcol.I

LIB
$(STRUCT)/lib/vsrflink.o

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
