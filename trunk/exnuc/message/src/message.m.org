SRC
$(EXNUC)/message/src

SOURCE
MSmsg.C
MSfile.C
MSretmsg.C
MSonoff.C
MSdismsg.C
MSgmessage.C


SPEC
$(EXNUC)/om/spec

INCLUDE
$(EXNUC)/include
$(INGRHOME)/include
$(FONTSERVE_INC_PATH)
$(UMS_INC_PATH)
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

#if defined( NT )
ARCHIVE
$(TARGET)/message/lib/message.lib
#else
LIB
$(TARGET)/message/lib/message.o
#endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

