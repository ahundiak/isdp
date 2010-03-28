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

LIB
$GRMDS/lib/grgrpcosp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/grgrpcosp.o
#else
ARCHIVE
$(GRLIB)/lib/grgrpcosp.lib
#endif

#endif

SOURCE
COdrop.S
COggadd.S
COggcreate.S
COggremove.S
