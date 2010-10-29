SRC
$(EXNUC)/exec/module

SOURCE
modulei.I
modinit.I
modswitch.I

SPEC
$(EXNUC)/spec

INCLUDE
$(EXNUC)/include
#if defined (ENV5)
$(FORMS_INC_PATH)
#elif defined (X11)
$(XFORMSDP_INC_PATH)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

