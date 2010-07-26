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
$(GRNUC)/src/co/toolco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/toolco.o
#else
ARCHIVE
$(GRLIB)/lib/toolco.lib
#endif

#else
ARCHIVE
$GRMDS/lib/toolco.a

#endif

SOURCE
COtoolsi.I
COtoolassgn.I
COtoolcomp.I
COtoolfile.I
COtoollib.I
COtoolset.I
COtooldir.I
