INCLUDE
$(INGRHOME)/include
$(XINC)
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

CC
acc -knr -O3

COPT
-ga

#ifndef NT
LIB
$(GRLIB)/lib/partco.o
#else
ARCHIVE
$(GRLIB)/lib/partco.lib
#endif

SRC
$(GRNUC)/src/co/partco

SOURCE
COparti.I
COprtcmd.I
COprtfrm.I
COprtmod.I
COprtattr.I
COprtconstr.I
COprtplace.I
COprtpart.I
COprtlist.I
COprtfunc.I
