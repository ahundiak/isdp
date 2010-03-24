SRC
$(EXNUC)/exec/cm

SOURCE
cm.I
cm_forms.C

SPEC
$(EXNUC)/spec

INCLUDE
$(EXNUC)/include
$(EXNUC)/exec/wl
#if defined (X11)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

DEFINE
CCDEF

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp
