SRC
$(EXNUC)/igefei

INCLUDE
$(EXNUC)/include
$(FONTSERVE_INC_PATH)
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

SPEC
$(EXNUC)/spec

SOURCE
igefei.I

LIB
$(TARGET)/lib/igefei.o

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

