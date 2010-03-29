## -*- Makefile -*-
##
## User: impd
## Time: Mar 23, 2010 11:50:52 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##
## And was then massaged by hand for the impd set of projects.

#### Makefile for the fontserver project in src/cfiles directory to create libXFS.so

#### Compiler and tool definitions shared by all build targets #####
ISDP_C_CC	= cc
ISDP_C_DEFINES	=
C_DEFINES	= $(ISDP_C_DEFINES) -DSHFONT -DSHLIB -DNDEBUG
# Additional defines that can be used: GC_DEBUG MEM_DEBUG
ISDP_C_FLAGS	= -g -xCC -Xa -Kpic -m32
CC		= $(ISDP_C_CC)
CPPFLAGS	= -I../hfiles
CFLAGS		= $(CPPFLAGS) $(ISDP_C_FLAGS) $(C_DEFINES)


# Define the target directories.
ISDP_TARGET	= $(HOME)/target
TARGETDIR	= $(ISDP_TARGET)/fontserver/src
TARGETDIR_OBJ	= $(TARGETDIR)/obj
TARGETDIR_LIB	= $(TARGETDIR)/lib

ISDP_INSTALL   = $(HOME)/install
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib

SHAREDLIB_NAME      = libXFS.so
SHAREDLIB_NAME_VER  = libXFS.so.1.1
ISDP_SHAREDLIB_FLAGS= -g -G -norunpath
SHAREDLIB_FLAGS     = $(ISDP_SHAREDLIB_FLAGS) -h $(SHAREDLIB_NAME_VER)


# Target: XFS
OBJS_XFS =  \
	FSAlloc.o	\
	FSBitmap.o	\
	FSBmapCach.o	\
	FSCharMap.o	\
	FSConvert.o	\
	FSCrypt.o	\
	FSDaemon.o	\
	FSDoFunc.o	\
	FSDraw.o	\
	FSEnter.o	\
	FSFontCach.o	\
	FSGenCache.o	\
	FSGetBmap.o	\
	FSGetFont.o	\
	FSGetOutl.o	\
	FSGetRec.o	\
	FSGetTF.o	\
	FSIO.o		\
	FSInterpro.o	\
	FSKern.o	\
	FSLoadTF.o	\
	FSMakeFont.o	\
	FSModes.o	\
	FSNewFont.o	\
	FSOutlCach.o	\
	FSPixCache.o	\
	FSPutBmap.o	\
	FSReadFont.o	\
	FSRules.o	\
	FSScanConv.o	\
	FSSplitArc.o	\
	FSSym.o		\
	FSTFCache.o	\
	FSUtil.o	\
	FSWriteFnt.o	\
	import.o

SRCS_XFS = \
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

#	Daemon.c \	Not included because we are not building the daemon
#	FSDaemon.c \	Not included because we are not building the daemon
#	version.c \	Not included because there is no version.h for Solaris

all: $(TARGETDIR_LIB) $(TARGETDIR_OBJ) $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER)

$(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER): \
		Makefile \
		$(OBJS_XFS)
	$(CC) -o $@ $(OBJS_XFS) $(SHAREDLIB_FLAGS)
	mv $(OBJS_XFS) $(TARGETDIR_OBJ)
	rm -f $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)
	ln -s $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER) $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)


# Install
install: \
	all \
	$(INSTALLDIR_LIB) \
	$(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER)

$(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER): $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER) $(INSTALLDIR_LIB)
	cp $(TARGETDIR_LIB)/$(SHAREDLIB_NAME_VER)  $(INSTALLDIR_LIB)
	rm -f $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME)
	ln -s $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME_VER) $(INSTALLDIR_LIB)/$(SHAREDLIB_NAME)


#### Clean target deletes all generated files ####
clean:
	rm -f $(TARGETDIR_LIB)/$(SHAREDLIB_NAME)*
	rm -f -r $(TARGETDIR_OBJ)


# Create the target directory (if needed)
$(TARGETDIR_OBJ): $(TARGETDIR)
	@mkdir -p $(TARGETDIR_OBJ)

$(TARGETDIR_LIB): $(TARGETDIR)
	@mkdir -p $(TARGETDIR_LIB)

$(TARGETDIR): $(ISDP_TARGET)
	mkdir -p $(TARGETDIR)

$(ISDP_TARGET):
	mkdir -p $(ISDP_TARGET)

$(INSTALLDIR_LIB): $(INSTALLDIR)
	mkdir -p $(INSTALLDIR_LIB)

$(INSTALLDIR):
	mkdir -p $(INSTALLDIR)
	
# Compile source files into .o files
version.o: \
	version.c
	$(COMPILE.c) $< -o $@

Daemon.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSCharMap.h \
	./../hfiles/FSDaemon.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	Daemon.c
	$(COMPILE.c) $< -o $@

FSAlloc.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSTypes.h \
	./../hfiles/import.h \
	FSAlloc.c
	$(COMPILE.c) $< -o $@

FSBitmap.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSTypes.h \
	./../hfiles/import.h \
	FSBitmap.c
	$(COMPILE.c) $< -o $@

FSBmapCach.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSBmapCach.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSGenCache.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSBmapCach.c
	$(COMPILE.c) $< -o $@

FSCharMap.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSCharMap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSCharMap.c
	$(COMPILE.c) $< -o $@

FSConvert.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSTypes.h \
	./../hfiles/import.h \
	FSConvert.c
	$(COMPILE.c) $< -o $@

FSCrypt.o: \
	./../hfiles/FS.h \
	./../hfiles/FSTypes.h \
	./../hfiles/import.h \
	FSCrypt.c
	$(COMPILE.c) $< -o $@

FSDaemon.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSCharMap.h \
	./../hfiles/FSDaemon.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSDaemon.c
	$(COMPILE.c) $< -o $@

FSDoFunc.o: \
	./../hfiles/FSDef.h \
	./../hfiles/FSTypes.h \
	./../hfiles/import.h \
	FSDoFunc.c
	$(COMPILE.c) $< -o $@

FSDraw.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSBmapCach.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSOutlCach.h \
	./../hfiles/FSSize.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSDraw.c
	$(COMPILE.c) $< -o $@

FSEnter.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSGenCache.h \
	./../hfiles/FSTypes.h \
	./../hfiles/import.h \
	FSEnter.c
	$(COMPILE.c) $< -o $@

FSFontCach.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSCharMap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSGenCache.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSFontCach.c
	$(COMPILE.c) $< -o $@

FSGenCache.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSGenCache.h \
	./../hfiles/FSTypes.h \
	./../hfiles/import.h \
	FSGenCache.c
	$(COMPILE.c) $< -o $@

FSGetBmap.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSBmapCach.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSSize.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSGetBmap.c
	$(COMPILE.c) $< -o $@

FSGetFont.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSSize.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSGetFont.c
	$(COMPILE.c) $< -o $@

FSGetOutl.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSOutlCach.h \
	./../hfiles/FSSize.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSGetOutl.c
	$(COMPILE.c) $< -o $@

FSGetRec.o: \
	./../hfiles/FSDef.h \
	./../hfiles/FSTypes.h \
	./../hfiles/import.h \
	FSGetRec.c
	$(COMPILE.c) $< -o $@

FSGetTF.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSCharMap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSTFCache.h \
	./../hfiles/FSTypeface.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSGetTF.c
	$(COMPILE.c) $< -o $@

FSIO.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSCharMap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSIO.c
	$(COMPILE.c) $< -o $@

FSInterpro.o: \
	./../hfiles/FSTypes.h \
	./../hfiles/import.h \
	FSInterpro.c
	$(COMPILE.c) $< -o $@

FSKern.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSCharMap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSMakeFont.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTFCache.h \
	./../hfiles/FSTypeface.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSKern.c
	$(COMPILE.c) $< -o $@

FSLoadTF.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSTFCache.h \
	./../hfiles/FSTypeface.h \
	./../hfiles/FSTypes.h \
	./../hfiles/import.h \
	FSLoadTF.c
	$(COMPILE.c) $< -o $@

FSMakeFont.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSBmapCach.h \
	./../hfiles/FSCharMap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSMakeFont.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSOutlCach.h \
	./../hfiles/FSTFCache.h \
	./../hfiles/FSTypeface.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSMakeFont.c
	$(COMPILE.c) $< -o $@

FSModes.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSModes.c
	$(COMPILE.c) $< -o $@

FSNewFont.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSCharMap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSMakeFont.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTFCache.h \
	./../hfiles/FSTypeface.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSNewFont.c
	$(COMPILE.c) $< -o $@

FSOutlCach.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSGenCache.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSOutlCach.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSOutlCach.c
	$(COMPILE.c) $< -o $@

FSPixCache.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSMakeFont.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTFCache.h \
	./../hfiles/FSTypeface.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSPixCache.c
	$(COMPILE.c) $< -o $@

FSPutBmap.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSBmapCach.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSSize.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSPutBmap.c
	$(COMPILE.c) $< -o $@

FSReadFont.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSBmapCach.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSIO.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSOutlCach.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSReadFont.c
	$(COMPILE.c) $< -o $@

FSRules.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSMakeFont.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTFCache.h \
	./../hfiles/FSTypeface.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSRules.c
	$(COMPILE.c) $< -o $@

FSScanConv.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSBmapCach.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSGenCache.h \
	./../hfiles/FSMakeFont.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSOutlCach.h \
	./../hfiles/FSPolyFill.h \
	./../hfiles/FSSize.h \
	./../hfiles/FSTFCache.h \
	./../hfiles/FSTypeface.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSScanConv.c
	$(COMPILE.c) $< -o $@

FSSplitArc.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSMakeFont.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSPolyFill.h \
	./../hfiles/FSTFCache.h \
	./../hfiles/FSTypeface.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSSplitArc.c
	$(COMPILE.c) $< -o $@

FSSym.o: \
	./../hfiles/FS.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSBmapCach.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSSym.c
	$(COMPILE.c) $< -o $@

FSTFCache.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSTFCache.h \
	./../hfiles/FSTypeface.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSTFCache.c
	$(COMPILE.c) $< -o $@

FSUtil.o: \
	./../hfiles/FSDef.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSUtil.c
	$(COMPILE.c) $< -o $@

FSWriteFnt.o: \
	./../hfiles/FS.h \
	./../hfiles/FSAlloc.h \
	./../hfiles/FSBmap.h \
	./../hfiles/FSBmapCach.h \
	./../hfiles/FSDef.h \
	./../hfiles/FSFont.h \
	./../hfiles/FSFontCach.h \
	./../hfiles/FSIO.h \
	./../hfiles/FSOutl.h \
	./../hfiles/FSOutlCach.h \
	./../hfiles/FSTypes.h \
	./../hfiles/FSUtil.h \
	./../hfiles/import.h \
	FSWriteFnt.c
	$(COMPILE.c) $< -o $@

import.o: \
	import.c
	$(COMPILE.c) $< -o $@

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
