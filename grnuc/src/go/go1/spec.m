CC
acc -knr

SOURCE

GRbspline.S
GRcirarc.S
GRcircle.S
GRconic.S
GRcurve.S
GRellarc.S
GRellipse.S
GRinfline.S
GRlbsys.S
GRlinear.S
GRlineseg.S
GRlinestr.S
GRorthlnst.S
GRorthogonal.S
GRorthpoly.S
GRplanar.S
GRpllnstr.S
GRpoint.S
GRpolygon.S

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SRC
$(GRNUC)/src/go/go1

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/go_S.o
#else
ARCHIVE
$(GRLIB)/lib/go_S.lib
#endif


#else

LIB
$GRMDS/lib/go_S.o

#endif	

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
