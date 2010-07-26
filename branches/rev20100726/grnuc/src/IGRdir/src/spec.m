
SRC
$(GRNUC)/src/IGRdir/src

#ifdef IDRAW
LIB
$GRMDS/lib/srcS.o

SOURCE
GRlink.S      super_dir.S   FIdirform.S

VERSION
$GRMDS/lib/srcS.o	1.3.0

#else

#ifndef NT
LIB
$(GRLIB)/lib/srcS.o
#else
ARCHIVE
$(GRLIB)/lib/srcS.lib
#endif

SOURCE
FIdirform.S   FIlstform.S   GRlink.S      super_dir.S

#endif
 
SPEC
$(EXNUC)/spec
$(GRNUC)/spec
 
INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
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
