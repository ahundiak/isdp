SOURCE

DMtext.S
text.I
DMfields.I
DMfun.I

CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_text

#ifndef NT
LIB
$(GRLIB)/lib/dim_text.o
#else
ARCHIVE
$(GRLIB)/lib/dim_text.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
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
