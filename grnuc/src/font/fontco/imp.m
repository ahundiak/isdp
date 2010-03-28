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
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/font/fontco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/fontco.o
#else
ARCHIVE
$(GRLIB)/lib/fontco.lib
#endif

#else

ARCHIVE
$GRMDS/lib/fontco.a

#endif

SOURCE
COdelfnti.I
COfonti.I
COfstfnti.I
COretfnti.I
COrevfnti.I

#ifndef IDRAW
COrplfnti.I
#endif  /* IDRAW */
