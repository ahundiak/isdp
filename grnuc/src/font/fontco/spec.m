INCLUDE
$(INGRHOME)/include
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

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
$(GRLIB)/lib/fontcosp.o
#else
ARCHIVE
$(GRLIB)/lib/fontcosp.lib
#endif

#else

LIB
$GRMDS/lib/fontcosp.o

#endif

SOURCE
COdelfnt.S
COfont.S
COfstfnt.S
COretfnt.S
COrevfnt.S

#ifndef IDRAW
COrplfnt.S
#endif  /* IDRAW */
