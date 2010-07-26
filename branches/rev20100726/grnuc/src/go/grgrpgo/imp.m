INCLUDE
$(INGRHOME)/include
#ifdef X11
$(XINC)
#endif
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/go/grgrpgo

#ifdef IDRAW

ARCHIVE
$GRMDS/lib/grgrpgo.a

#else

#ifndef NT
LIB
$(GRLIB)/lib/grgrpgo.o
#else
ARCHIVE
$(GRLIB)/lib/grgrpgo.lib
#endif


#endif

SOURCE
GRggconstr.I
GRggflexconn.I
GRgggetobjin.I
GRggrigidcon.I
GRggactown.I
GRgrpanalyze.I
#ifndef IDRAW
GRggunion.I
GRggdiff.I
GRgginter.I
#endif
