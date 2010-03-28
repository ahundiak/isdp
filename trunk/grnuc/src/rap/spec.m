SRC
$(GRNUC)/src/rap

#ifdef IDRAW

LIB
$GRMDS/lib/rap_sp.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/rap_sp.o
#else
ARCHIVE
$(GRLIB)/lib/rap_sp.lib
#endif

#endif

SOURCE
RAPcobCO.S
RAPinlisnr.S

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
 
INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/om/include
$(EXNUC)/include
$(BS)/include
$(GRNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#ifdef SUNOS5
/usr/ucbinclude
#endif
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
