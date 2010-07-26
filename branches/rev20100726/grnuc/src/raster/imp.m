CC acc -ansi -O3

SRC
$(GRNUC)/src/raster

SOURCE
IMdload.I
RScalibsup.c
RSstubs.c
#ifdef X11
RSgetxinfo.c
#endif

SPEC
$(GRNUC)/spec
$(EXNUC)/om/spec
$(EXNUC)/exec/spec
$(EXNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

LIB
$(GRLIB)/lib/raststub.o


