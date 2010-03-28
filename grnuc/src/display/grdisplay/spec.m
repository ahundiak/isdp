SOURCE

IGEgragad.S
IGEwinsup.S
IGEdisplay.S

IGEsavedvw.S
DPlvldir.S
DPstartup.S
DPusrlnstl.S
DPcodpb.S

#ifndef IDRAW
GRviewdyn.S
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

CC
acc -knr

COPT
-ga

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SRC
$(GRNUC)/src/display/grdisplay

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/grdisplaysp.o
#else
ARCHIVE
$(GRLIB)/lib/grdisplaysp.lib
#endif
#else
LIB
$GRMDS/lib/grdisplaysp.o
#endif
