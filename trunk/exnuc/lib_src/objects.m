#ifdef X11
SRC
$(EXNUC)/lib

TARGET
all

SOURCE
exnucXstub.c

INCLUDE
$(EXNUC)/include
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
#if defined (X11)
$(X11_INC_PATH)
#endif

SPECIAL
#if defined(SUNOS4)
SED=$(EXNUC)/build/exnucSUNsed
#elif defined (INTEL)
SED=$(EXNUC)/build/exnucSOLPC
#elif defined(IRIX) || defined (SUNOS5)
SED=$(EXNUC)/build/exnucIRIXsed2
#elif defined(ENV5)
SED=$(EXNUC)/build/exnucENV5sed
#elif defined(CLIX) && defined (X11)
SED=$(EXNUC)/build/exnucXsed
#endif
END_SPECIAL

#if defined(CLIX) || defined(SUNOS4)
POST_SPECIAL
all: $(SED) $(EXNUC)/build/exnucobjects $(objects)
	sed -f $(SED) $(EXNUC)/build/exnucobjects > $(TARGET)/lib/exnucobjects
END_SPECIAL
#elif defined (IRIX) || defined(SUNOS5)
POST_SPECIAL
all: $(SED) $(EXNUC)/build/exnucobjects $(objects)
	sed -f $(SED) $(EXNUC)/build/exnucobjects > $(TARGET)/lib/exnucobjects
	sed -f $(EXNUC)/build/exnucIRIXsed $(TARGET)/lib/exnucobjects | \
	sed -e "s:\$$TARGET:$$TARGET:g" > $(TARGET)/lib/objectlist
	echo $(TARGET)/lib/EXNUCver.o >> $(TARGET)/lib/objectlist
END_SPECIAL
#endif

#elif defined(ENV5)
SPECIAL
#if defined(CLIX)
SED=$(EXNUC)/build/exnucENV5sed
target: $(EXNUC)/build/exnucobjects
	sed -f $(SED) $(EXNUC)/build/exnucobjects > $(TARGET)/lib/exnucobjects
#elif defined(SUNOS) || defined(IRIX)
target: $(EXNUC)/build/exnucobjects
	cp $(EXNUC)/build/exnucobjects $(TARGET)/lib
#endif
END_SPECIAL
#endif
