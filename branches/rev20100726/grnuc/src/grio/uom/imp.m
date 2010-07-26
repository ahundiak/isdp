SRC
$(GRNUC)/src/grio/uom

SOURCE
UOMsuperi.I
UOMfree.C
UOMinit.C
UOMreadout.C
UOMutils.C
COedtuomi.I
uomgetunit.I

INCLUDE
$(INGRHOME)/include
$(INGRHOME)/include/xc
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

#ifndef NT
LIB
$(GRLIB)/lib/uom.o
#else
ARCHIVE
$(GRLIB)/lib/uom.lib
#endif

CC
acc

COPT
-ga -knr -O3

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

