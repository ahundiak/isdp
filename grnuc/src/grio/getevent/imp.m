
SRC
$(GRNUC)/src/grio/getevent

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/getevent.a

SOURCE
COepp.C        COgetevent.C   GRgetevent.C   GRvsdinit.C

#else

#ifndef NT
LIB
$(GRLIB)/lib/getevent.o
#else
ARCHIVE
$(GRLIB)/lib/getevent.lib
#endif

SOURCE
COepp.C        COgetevent.C   GRgetevent.C   GRvsdinit.C

#endif
 
SPEC
$(EXNUC)/spec
$(GRNUC)/spec
 
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
 
OPP
$(EXTARG)/bin/opp
 
OMCPP
$(EXTARG)/bin/omcpp
 
CC
acc -knr -O3
