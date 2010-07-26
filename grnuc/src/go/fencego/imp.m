INCLUDE
$(INGRHOME)/include
$(XINC)
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
$(GRNUC)/src/go/fencego

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/fencego.o
#else
ARCHIVE
$(GRLIB)/lib/fencego.lib
#endif


#else

ARCHIVE
$GRMDS/lib/fencego.a

#endif

SOURCE
GRfnclip.I
GRfncopy.I
GRfncptform.I
GRfndelete.I
GRfndyself.I
GRfnflexconn.I
GRfngetext.I
GRfngetobjin.I
GRfngetprism.I
GRfngetsize.I
GRfnlocate.I
GRfnpass.I
GRfnplot.I
GRfnpreclip.I
GRfnrigidcon.I
GRfnwinsup.I
GRgsmgr_fun.I
GRgsmgri.I
GRfnanalyze.I
