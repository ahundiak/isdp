SRC
$(GRNUC)/src/co/rfco

#ifndef NT
LIB
$(GRLIB)/lib/refco.o
#else
ARCHIVE
$(GRLIB)/lib/refco.lib
#endif


SOURCE
COrefi.I
COreviewelei.I
COstrfnci.I
COrvforminp.I
COrvinqmain.I
COrvsubupd.I
DYrfclmod.I

SPEC
$(GRNUC)/spec
$(EXNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr
