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
$(GRNUC)/src/co/symbco

#ifdef IDRAW

LIB
$GRMDS/lib/symbcosp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/symbcosp.o
#else
ARCHIVE
$(GRLIB)/lib/symbcosp.lib
#endif

#endif

SOURCE
COdefactsm.S
COdefsymlib.S
COreplace.S
COrevcell.S
COsdcreate.S
COsdrename.S
COsmtocl.S
COsymplace.S
