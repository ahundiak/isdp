SRC
$(EXNUC)/icob/trans

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
do_it_t.I
set_t.I

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
LIB
$(TARGET)/icob/lib/trans.o
#elif defined (NT)
ARCHIVE
$(TARGET)/icob/lib/trans.lib
#endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

