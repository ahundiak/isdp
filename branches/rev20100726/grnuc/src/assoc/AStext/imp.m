
CC
acc -knr

SRC
$(GRNUC)/src/assoc/AStext

SOURCE
ASsrctext.S
ASsrctexti.I
AStxoverride.I

AStextpm.S
AStextpmi.I

ASboxpt.S
ASboxpti.I

ASfieldpt.S
ASfieldpti.I

text_util.I

#ifndef NT
LIB
$(GRLIB)/lib/AStext.o
#else
ARCHIVE
$(GRLIB)/lib/AStext.lib
#endif

SPEC
$(EXNUC)/om/spec
$(EXNUC)/spec
$(EXNUC)/exec/spec
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
