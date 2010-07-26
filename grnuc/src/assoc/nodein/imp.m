SRC
$(GRNUC)/src/assoc/nodein

CC
acc -knr

SOURCE

NDnodein.S
NDfather.S
NDchildren.S
NDnode_over.I
NDchannel.I
NDmacro_over.I



#ifndef NT
LIB
$(GRLIB)/lib/nodein.o
#else
ARCHIVE
$(GRLIB)/lib/nodein.lib
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
