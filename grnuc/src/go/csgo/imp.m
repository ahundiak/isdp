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
acc -knr -O3

COPT
-ga

SRC
$(GRNUC)/src/go/csgo

#ifdef IDRAW

ARCHIVE
$(GRMDS)/lib/csgo.a

#else
#ifndef NT
LIB
$(GRLIB)/lib/csgo.o
#else
ARCHIVE
$(GRLIB)/lib/csgo.lib
#endif

#endif

SOURCE
GRcsbasei.I
GRcscopy.I
GRcsdisyours.I
GRcsfunc.I
GRcsgenabsg.I
GRcsgetobjin.I
GRcsmacsinfo.I
GRcsmgri.I
GRcsmquery.I
GRcsmrgcon.I
GRcsmsetacs.I
GRcsmtoggle.I
GRcspostabsg.I
GRgcsconst.I
GRgcscvt.I
GRgcsgetinfo.I
GRgcsquery.I
GRgcsxform.I
GRgencsi.I
GRcsanalyze.I
#ifndef IDRAW
GRcsconst.I
#endif
GRcsinfo.c
