SRC
$(EXNUC)/icob/state

INCLUDE
$(EXNUC)/include
$(UMS_INC_PATH)
#if defined (X11)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SPEC
$(EXNUC)/spec

SOURCE
do_it_s.I

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
LIB
$(TARGET)/icob/lib/state.o
#elif defined (NT)
ARCHIVE
$(TARGET)/icob/lib/state.lib
#endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

