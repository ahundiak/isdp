SRC
$(GRNUC)/src/assoc/super_para

CC
acc -knr -O3 

SOURCE

super_para.S
super_parai.I
super_option.I


#ifndef NT 
LIB
$(GRLIB)/lib/super_para.o
#else
ARCHIVE
$(GRLIB)/lib/super_para.lib
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
