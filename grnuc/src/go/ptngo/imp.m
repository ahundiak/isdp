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
$(GRNUC)/src/go/ptngo

#ifndef NT
LIB
$(GRLIB)/lib/ptngo.o
#else
ARCHIVE
$(GRLIB)/lib/ptngo.lib
#endif


SOURCE
GRapagrid.C
GRapclpprism.C
GRapconstr.I
GRapgen.I
GRapgrid.C
GRclipconn.I
GRepbldbox.C
GRepconstr.I
GRepgen.I
GRepudir.C
GRpaaddwrng.I
GRpachsym.I
GRpaconstr.I
GRpacopy.I
GRpadelcomp.I
GRpadelete.I
GRpadrop.I
GRpagetcv.I
GRpagetlp.I
GRpagetsdh.I
GRpagetvwmx.C
GRpalocate.I
GRpapassgeo.I
/*
GRparemove.I
*/
GRparemwrng.I
GRpaupdyours.I
GRpaxform.I
GRpaclip.I

