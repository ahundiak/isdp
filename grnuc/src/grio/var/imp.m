
SRC
$(GRNUC)/src/grio/var

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/var.a

SOURCE
 
GRaddvar.I     GRdelvar.I     GRvarcvrt.I
GRcvttovar.I   GRvaradd.I     GRvardel.I
GRvardebug.I

#else

#ifndef NT
LIB
$(GRLIB)/lib/var.o
#else
ARCHIVE
$(GRLIB)/lib/var.lib
#endif

SOURCE
 
GRaddvar.I     GRdelvar.I     GRvarcvrt.I
GRcvttovar.I   GRvaradd.I     GRvardel.I
GRvardebug.I
 
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
