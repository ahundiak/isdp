SRC
$(EXNUC)/exec/locale

SPEC
$(EXNUC)/om/spec

INCLUDE
$(EXNUC)/include
#if defined (X11)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SOURCE
exlocale.C
exlocinit.C
exreadloc.C
exfont.C
exset_inq.C
exlogkbd.C
exlanguage.C

LIB
$(TARGET)/exec/lib/locale.o

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

