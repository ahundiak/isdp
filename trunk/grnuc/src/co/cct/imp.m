SRC
$(GRNUC)/src/co/cct

#ifndef NT
LIB
$(GRLIB)/lib/cct.o
#else
ARCHIVE
$(GRLIB)/lib/cct.lib
#endif

COPT
-ga

SOURCE
COcct_ctbl.I
COcct_hls.I
COcct_init.I
COcct_input.I
COcct_menu.I
COcct_msg.I
COcct_option.I
COcct_pallet.I


CC
acc -knr

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
#ifdef X11 
$(XINC)
#endif
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
