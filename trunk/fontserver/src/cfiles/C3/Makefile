CC	=acc
CFLAGS	= -O3 -Abss=0  -Atarg=c300 -D__cpu_c300__

TOOLSLIB	=$(ENVIRONV)/src/cfiles/libtools_s.a3
CLIB	=/usr/lib/c300/libc_s.a
LIBBSD	=/usr/lib/c300/libbsd.a
LIBM	=/usr/lib/c300/libm.a
TARGET	= libFS2_s3

$(TARGET) libFS_s.a3:	objects

# First line of automatic makefile generation.

# Lines in this section of the file are generated automatically.
# Any changes made will be lost the next time the Makefile is
# made.   You may add lines either before or after this section.

OBJECTS=\
	version.o \
	Daemon.o \
	FSAlloc.o \
	FSBitmap.o \
	FSBmapCach.o \
	FSCharMap.o \
	FSConvert.o \
	FSCrypt.o \
	FSDaemon.o \
	FSDoFunc.o \
	FSDraw.o \
	FSEnter.o \
	FSFontCach.o \
	FSGenCache.o \
	FSGetBmap.o \
	FSGetFont.o \
	FSGetOutl.o \
	FSGetRec.o \
	FSGetTF.o \
	FSIO.o \
	FSInterpro.o \
	FSKern.o \
	FSLoadTF.o \
	FSMakeFont.o \
	FSModes.o \
	FSNewFont.o \
	FSOutlCach.o \
	FSPixCache.o \
	FSPutBmap.o \
	FSReadFont.o \
	FSRules.o \
	FSScanConv.o \
	FSSplitArc.o \
	FSSym.o \
	FSTFCache.o \
	FSUtil.o \
	FSWriteFnt.o \
	import.o

SOURCES=\
	version.c \
	Daemon.c \
	FSAlloc.c \
	FSBitmap.c \
	FSBmapCach.c \
	FSCharMap.c \
	FSConvert.c \
	FSCrypt.c \
	FSDaemon.c \
	FSDoFunc.c \
	FSDraw.c \
	FSEnter.c \
	FSFontCach.c \
	FSGenCache.c \
	FSGetBmap.c \
	FSGetFont.c \
	FSGetOutl.c \
	FSGetRec.c \
	FSGetTF.c \
	FSIO.c \
	FSInterpro.c \
	FSKern.c \
	FSLoadTF.c \
	FSMakeFont.c \
	FSModes.c \
	FSNewFont.c \
	FSOutlCach.c \
	FSPixCache.c \
	FSPutBmap.c \
	FSReadFont.c \
	FSRules.c \
	FSScanConv.c \
	FSSplitArc.c \
	FSSym.c \
	FSTFCache.c \
	FSUtil.c \
	FSWriteFnt.c \
	import.c

# Last line of automatic makefile generation.

objects:	$(OBJECTS)
	mkshlib -t $(TARGET) -h libFS_s.a3 -c c300 \
		-s $(FONTSERVER)/src/afiles/libFS2.sl -q \
		-L $(ENVIRONV)/src/cfiles
	@ln $(TARGET) $(FONTSERVER)/src/cfiles/$(TARGET)
	@ln libFS_s.a3 $(FONTSERVER)/src/cfiles/libFS_s.a3

fsdaemon3:	Daemon.o 
	$(CC) Daemon.o $(CFLAGS) \
		$(FONTSERVER)/src/cfiles/libFS_s.a3 \
		$(LIBM) $(TOOLSLIB) $(CLIB) $(LIBBSD) $(CFLAGS) -o $@
