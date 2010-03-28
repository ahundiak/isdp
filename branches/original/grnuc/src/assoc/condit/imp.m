SRC
$(GRNUC)/src/assoc/condit

CC
acc -knr

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

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SOURCE
ACcond_def.S
ACcond_defi.I
ACcond_copi.I
ACsymb_hold.S
ACsymb_holdi.I

COm_condit.S
COm_condit1.I
COm_condit2.I
COm_condit3.I
COm_condit4.I

#ifndef NT
LIB
$(GRLIB)/lib/condit.o
#else
ARCHIVE
$(GRLIB)/lib/condit.lib
#endif
