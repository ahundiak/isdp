SRC
$(EXNUC)/icob/util

INCLUDE
$(EXNUC)/include
$(EXNUC)/icob/util
$(UMS_INC_PATH)

SOURCE
util_all.C

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
LIB
$(TARGET)/icob/lib/util.o
#elif defined (NT)
ARCHIVE
$(TARGET)/icob/lib/util.lib
#endif

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

