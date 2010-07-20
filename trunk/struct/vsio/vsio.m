SOURCE
VSdotsinsts.C
VSdfltvalsfm.C
VSdspsfnorml.I
VSfileform.C
VSfmcpypaste.C
VSformUtil.C
VSgetpath.C
VSgetUOMtbl.C
VSgetUnit.C
VSgraphicenv.C
VSmsgkey2str.C
VSputobject.C
VSsys2unit.C
VSspsys2unit.C
VSunit2sys.C
VSunixUtil.C
VSscrap.C

LIB
$(STRUCT)/lib/vsio.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(STRUCT)/spec

INCLUDE
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(FORMS)/include
$(VDS)/include
$(STRUCT)/include
$(STRUCT)/include/prototypes

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

/*
 * "CLIX" : -D switch for operating system
 * "ENV5" : -D switch for windowing system
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN __APGE__

CC
acc -ansi -O3
