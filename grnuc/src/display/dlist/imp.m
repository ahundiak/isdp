SOURCE
DPdl_global.c
DPdl_display.I
DPdl_init.I
DPdl_notify.I
DPdl_misc.I
DPdl_hash.c
DPdl_add.c
DPdl_mem.c
DPdl_delete.c
DPdl_debug.c

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
#ifdef X11
$(XINC)
#endif
$(INGRHOME)/include
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

CC
acc -knr

COPT
-ga

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SRC
$(GRNUC)/src/display/dlist

LIB
$(GRLIB)/lib/dlist.o
