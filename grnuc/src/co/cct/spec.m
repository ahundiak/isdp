SRC 
$(GRNUC)/src/co/cct

#ifndef NT
ARCHIVE
$(GRLIB)/lib/cct_spec.a
#else
ARCHIVE
$(GRLIB)/lib/cct_spec.lib
#endif


COPT
-ga

SOURCE
COcctform.S

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
