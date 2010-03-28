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

SRC
$(GRNUC)/src/co/grgrpco

#ifdef IDRAW

ARCHIVE
$GRMDS/lib/grgrpco.a

#else

#ifndef NT
LIB
$(GRLIB)/lib/grgrpco.o
#else
ARCHIVE
$(GRLIB)/lib/grgrpco.lib
#endif

#endif

SOURCE
COdropi.I
COggaddi.I
COggcreatei.I
COggremovei.I
COlcggmem.I
