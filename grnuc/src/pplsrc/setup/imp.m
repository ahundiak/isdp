SRC
$(GRNUC)/src/pplsrc/setup

SOURCE
COcisetup.S
COcisetupi.I
cifiutil.I
cisetup.I
ciwait.I
cierror.I
cierrexc.C
ciomerr.C
cisrcls.I
cimatherr.C
cipath.C
ciparse.C

#ifndef NT
LIB
$(GRLIB)/lib/cisetup.o
#else
ARCHIVE
$(GRLIB)/lib/cisetup.lib
#endif

SPEC
$(GRNUC)/spec
$(EXNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
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
