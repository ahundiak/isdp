SRC
$(GRNUC)/src/assoc/source

CC
acc -knr

SOURCE
ASsource.S
ASsourcei.I
ASsourcenoti.I
NDtrans_over.I
NDmacro_over.I

ASsourcein.S
ASsourceini.I

#ifndef NT
LIB
$(GRLIB)/lib/source.o
#else
ARCHIVE
$(GRLIB)/lib/source.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/src/assoc/include_priv
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

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
