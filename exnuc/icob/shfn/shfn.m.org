SRC
$(EXNUC)/icob/shfn

INCLUDE
$(EXNUC)/include
$(EXNUC)/icob/sli
#if defined (X11)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SOURCE
find_file.C
shellvar.C

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
LIB
$(TARGET)/icob/lib/shfn.o
#elif defined (NT)
ARCHIVE
$(TARGET)/icob/lib/shfn.lib
#endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

