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
$(GRNUC)/src/co/plotco

#ifdef IDRAW
#if defined( NT )
ARCHIVE
$GRMDS/lib/plotcosp.lib
#else
LIB
$GRMDS/lib/plotcosp.o
#endif

#else

#if defined( NT )
ARCHIVE
$(GRLIB)/lib/plotcosp.lib
#else
LIB
$(GRLIB)/lib/plotcosp.o
#endif

#endif

SOURCE
COplot.S
