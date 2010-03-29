## -*- Makefile -*-
##
## User: impd
## Time: Mar 23, 2010 10:07:11 AM
## Makefile created by Sun Studio.
##
## This file is generated automatically.
##
## And was then massaged by hand for the impd set of projects.

#### Makefile for the libxc project in src directory to create:
####	libxc.so, libxcmalloc.so, libxcmalloc_debug.so


#### Compiler and tool definitions shared by all build targets #####
ISDP_C_CC	= cc
ISDP_C_DEFINES	=
C_DEFINES	= $(ISDP_C_DEFINES) -DRUN_X=1 -DX11=1 -DLITTLE_ENDIAN=1 -DSYSV=1 -DSYS5=1 -DSVR4=1 -DSUNOS=1 -DSUNOS5=1 -DSUNOS58=1 -Di386=1 -D__i386=1 -DINTEL=1 -DUNIX=1 -DSunOS_5x=1 -D__i386__=1 -DSunOS=1
ISDP_C_FLAGS	= -g -xCC -Xa -Kpic -m32
CC		= $(ISDP_C_CC)
CPPFLAGS	= -I../inc.pvt -I../include
CFLAGS		= $(CPPFLAGS) $(ISDP_C_FLAGS) $(C_DEFINES)


# Define the target directories.
ISDP_TARGET = $(HOME)/target
TARGETDIR     = $(ISDP_TARGET)/libxc
TARGETDIR_OBJ = $(TARGETDIR)/obj
TARGETDIR_LIB = $(TARGETDIR)/lib

ISDP_INSTALL   = $(HOME)/install
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib

SHAREDLIB_xc			= libxc.so
SHAREDLIB_xc_VER		= libxc.so.1
SHAREDLIB_xcmalloc		= libxcmalloc.so
SHAREDLIB_xcmalloc_VER		= libxcmalloc.so.1
SHAREDLIB_xcmalloc_debug	= libxcmalloc_debug.so
SHAREDLIB_xcmalloc_debug_VER	= libxcmalloc_debug.so.1
ISDP_SHAREDLIB_FLAGS= -g -G -norunpath
SHAREDLIB_xc_FLAGS		= $(ISDP_SHAREDLIB_FLAGS) -h $(SHAREDLIB_xc_VER)
SHAREDLIB_xcmalloc_FLAGS	= $(ISDP_SHAREDLIB_FLAGS) -h $(SHAREDLIB_xcmalloc_VER)
SHAREDLIB_xcmalloc_debug_FLAGS	= $(ISDP_SHAREDLIB_FLAGS) -h $(SHAREDLIB_xcmalloc_debug_VER)

## Target: xc


ISDP_INSTALL   = $(HOME)/install
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib

SRCS =	blkalloc.c	\
	blkdebug.c	\
	blkinfo.c	\
	blksanity.c	\
	dlhelper.c	\
	dload.c		\
	dloadinit.c	\
	exefile.c	\
	exfilnam.c	\
	exit.c		\
	expshell.c	\
	getargs.c	\
	hashadd.c	\
	hashc.c		\
	hashdel.c	\
	hashdelrec.c	\
	hashdlookup.c	\
	hashfree.c	\
	hashinfo.c	\
	hashinit.c	\
	hashlookup.c	\
	hashnext.c	\
	hashrpl.c	\
	ipcl.c		\
	malloc.c	\
	mkstubs.c	\
	namecache.c	\
	nlist.c		\
	objaccess.c	\
	report_error.c	\
	stralloc.c	\
	vla.c		\
	whence.c	\
	xcsyscall.c

OBJS =	blkalloc.o	\
	blkdebug.o	\
	blkinfo.o	\
	blksanity.o	\
	dlhelper.o	\
	dload.o		\
	dloadinit.o	\
	exefile.o	\
	exfilnam.o	\
	exit.o		\
	expshell.o	\
	getargs.o	\
	hashadd.o	\
	hashc.o		\
	hashdel.o	\
	hashdelrec.o	\
	hashdlookup.o	\
	hashfree.o	\
	hashinfo.o	\
	hashinit.o	\
	hashlookup.o	\
	hashnext.o	\
	hashrpl.o	\
	ipcl.o		\
	malloc.o	\
	mkstubs.o	\
	namecache.o	\
	nlist.o		\
	objaccess.o	\
	report_error.o	\
	stralloc.o	\
	vla.o		\
	whence.o	\
	xcsyscall.o

LIBXCOBJS =		\
	$(TARGETDIR_OBJ)/blkalloc.o	\
	$(TARGETDIR_OBJ)/blkinfo.o	\
	$(TARGETDIR_OBJ)/dload.o	\
	$(TARGETDIR_OBJ)/exefile.o	\
	$(TARGETDIR_OBJ)/exfilnam.o	\
	$(TARGETDIR_OBJ)/exit.o		\
	$(TARGETDIR_OBJ)/expshell.o	\
	$(TARGETDIR_OBJ)/getargs.o	\
	$(TARGETDIR_OBJ)/hashadd.o	\
	$(TARGETDIR_OBJ)/hashc.o	\
	$(TARGETDIR_OBJ)/hashdel.o	\
	$(TARGETDIR_OBJ)/hashdelrec.o	\
	$(TARGETDIR_OBJ)/hashfree.o	\
	$(TARGETDIR_OBJ)/hashinfo.o	\
	$(TARGETDIR_OBJ)/hashinit.o	\
	$(TARGETDIR_OBJ)/hashlookup.o	\
	$(TARGETDIR_OBJ)/hashdlookup.o	\
	$(TARGETDIR_OBJ)/hashnext.o	\
	$(TARGETDIR_OBJ)/hashrpl.o	\
	$(TARGETDIR_OBJ)/ipcl.o		\
	$(TARGETDIR_OBJ)/namecache.o	\
	$(TARGETDIR_OBJ)/objaccess.o	\
	$(TARGETDIR_OBJ)/report_error.o	\
	$(TARGETDIR_OBJ)/stralloc.o	\
	$(TARGETDIR_OBJ)/vla.o		\
	$(TARGETDIR_OBJ)/whence.o	\
	$(TARGETDIR_OBJ)/xcsyscall.o	\
	$(TARGETDIR_OBJ)/XCinit_x86.o

LIBXCMALLOCOBJS =	\
	$(TARGETDIR_OBJ)/blkalloc.o	\
	$(TARGETDIR_OBJ)/blkinfo.o	\
	$(TARGETDIR_OBJ)/malloc.o

LIBXCMALLOCDEBUGOBJS =	\
	$(TARGETDIR_OBJ)/Dblkalloc.o	\
	$(TARGETDIR_OBJ)/Dblkinfo.o	\
	$(TARGETDIR_OBJ)/Dmalloc.o

all:	\
	$(TARGETDIR_LIB)/$(SHAREDLIB_xc_VER) \
	$(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc_VER) \
	$(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc_debug_VER)

$(TARGETDIR_LIB)/$(SHAREDLIB_xc_VER):	$(TARGETDIR_OBJ) $(TARGETDIR_LIB) $(LIBXCOBJS)
	$(CC) -o $@ $(LIBXCOBJS) $(SHAREDLIB_xc_FLAGS)
	rm -f $(TARGETDIR_LIB)/$(SHAREDLIB_xc)
	ln -s $@ $(TARGETDIR_LIB)/$(SHAREDLIB_xc)

$(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc_VER):	$(TARGETDIR_OBJ) $(TARGETDIR_LIB) $(LIBXCMALLOCOBJS)
	$(CC) -o $@ $(LIBXCMALLOCOBJS) $(SHAREDLIB_xcmalloc_FLAGS)
	rm -f $(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc)
	ln -s $@ $(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc)

$(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc_debug_VER):	$(TARGETDIR_OBJ) $(TARGETDIR_LIB) $(LIBXCMALLOCDEBUGOBJS)
	$(CC) -o $@ $(LIBXCMALLOCDEBUGOBJS) $(SHAREDLIB_xcmalloc_debug_FLAGS)
	rm -f $(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc_debug)
	ln -s $@ $(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc_debug)

# Install
install: \
	$(INSTALLDIR_LIB)/$(SHAREDLIB_xc_VER) \
	$(INSTALLDIR_LIB)/$(SHAREDLIB_xcmalloc_VER) \
	$(INSTALLDIR_LIB)/$(SHAREDLIB_xcmalloc_debug_VER)

$(INSTALLDIR_LIB)/$(SHAREDLIB_xc_VER) : $(INSTALLDIR_LIB) $(TARGETDIR_LIB)/$(SHAREDLIB_xc_VER)
	cp $(TARGETDIR_LIB)/$(SHAREDLIB_xc)* $(INSTALLDIR_LIB)

$(INSTALLDIR_LIB)/$(SHAREDLIB_xcmalloc_VER) : $(INSTALLDIR_LIB) $(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc_VER)
	cp $(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc)* $(INSTALLDIR_LIB)

$(INSTALLDIR_LIB)/$(SHAREDLIB_xcmalloc_debug_VER) : $(INSTALLDIR_LIB) $(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc_debug_VER)
	cp $(TARGETDIR_LIB)/$(SHAREDLIB_xcmalloc_debug)* $(INSTALLDIR_LIB)


# Clean up
clean:
	rm -f -r $(TARGETDIR_LIB)
	rm -f -r $(TARGETDIR_OBJ)


# Create the target directory (if needed)
$(TARGETDIR_OBJ): $(TARGETDIR)
	mkdir -p $(TARGETDIR_OBJ)

$(TARGETDIR_LIB): $(TARGETDIR)
	mkdir -p $(TARGETDIR_LIB)

$(TARGETDIR): $(ISDP_TARGET)
	mkdir -p $(TARGETDIR)

$(ISDP_TARGET):
	mkdir -p $(ISDP_TARGET)

$(INSTALLDIR_LIB): $(INSTALL_DIR)
	mkdir -p $(INSTALLDIR_LIB)

$(INSTALLDIR):
	mkdir -p $(INSTALLDIR)


# Compile source files into .o files
$(TARGETDIR_OBJ)/blkalloc.o:	blkalloc.c
	$(COMPILE.c) blkalloc.c -o $@

$(TARGETDIR_OBJ)/blkinfo.o:	blkinfo.c
	$(COMPILE.c) blkinfo.c -o $@

$(TARGETDIR_OBJ)/dload.o:	dload.c
	$(COMPILE.c) dload.c -o $@

$(TARGETDIR_OBJ)/exefile.o:	exefile.c
	$(COMPILE.c) exefile.c -o $@

$(TARGETDIR_OBJ)/exfilnam.o:	exfilnam.c
	$(COMPILE.c) exfilnam.c -o $@

$(TARGETDIR_OBJ)/exit.o:	exit.c
	$(COMPILE.c) exit.c -o $@

$(TARGETDIR_OBJ)/expshell.o:	expshell.c
	$(COMPILE.c) expshell.c -o $@

$(TARGETDIR_OBJ)/getargs.o:	getargs.c
	$(COMPILE.c) getargs.c -o $@

$(TARGETDIR_OBJ)/hashadd.o:	hashadd.c
	$(COMPILE.c) hashadd.c -o $@

$(TARGETDIR_OBJ)/hashc.o:	hashc.c
	$(COMPILE.c) hashc.c -o $@

$(TARGETDIR_OBJ)/hashdel.o:	hashdel.c
	$(COMPILE.c) hashdel.c -o $@

$(TARGETDIR_OBJ)/hashdelrec.o:	hashdelrec.c
	$(COMPILE.c) hashdelrec.c -o $@

$(TARGETDIR_OBJ)/hashfree.o:	hashfree.c
	$(COMPILE.c) hashfree.c -o $@

$(TARGETDIR_OBJ)/hashinfo.o:	hashinfo.c
	$(COMPILE.c) hashinfo.c -o $@

$(TARGETDIR_OBJ)/hashinit.o:	hashinit.c
	$(COMPILE.c) hashinit.c -o $@

$(TARGETDIR_OBJ)/hashlookup.o:	hashlookup.c
	$(COMPILE.c) hashlookup.c -o $@

$(TARGETDIR_OBJ)/hashdlookup.o:	hashdlookup.c
	$(COMPILE.c) hashdlookup.c -o $@

$(TARGETDIR_OBJ)/hashnext.o:	hashnext.c
	$(COMPILE.c) hashnext.c -o $@

$(TARGETDIR_OBJ)/hashrpl.o:	hashrpl.c
	$(COMPILE.c) hashrpl.c -o $@

$(TARGETDIR_OBJ)/ipcl.o:	ipcl.c
	$(COMPILE.c) ipcl.c -o $@

$(TARGETDIR_OBJ)/namecache.o:	namecache.c
	$(COMPILE.c) namecache.c -o $@

$(TARGETDIR_OBJ)/objaccess.o:	objaccess.c
	$(COMPILE.c) objaccess.c -o $@

$(TARGETDIR_OBJ)/report_error.o:	report_error.c
	$(COMPILE.c) report_error.c -o $@

$(TARGETDIR_OBJ)/stralloc.o:	stralloc.c
	$(COMPILE.c) stralloc.c -o $@

$(TARGETDIR_OBJ)/vla.o:	vla.c
	$(COMPILE.c) vla.c -o $@

$(TARGETDIR_OBJ)/whence.o:	whence.c
	$(COMPILE.c) whence.c -o $@

$(TARGETDIR_OBJ)/xcsyscall.o:	xcsyscall.c
	$(COMPILE.c) xcsyscall.c -o $@

$(TARGETDIR_OBJ)/XCinit_x86.o:	XCinit_x86.s
	$(AS) XCinit_x86.s -o $@

$(TARGETDIR_OBJ)/malloc.o:	malloc.c
	$(COMPILE.c) malloc.c -o $@

$(TARGETDIR_OBJ)/Dblkalloc.o:	blkalloc.c
	$(COMPILE.c) -DDEBUG blkalloc.c -o $@

$(TARGETDIR_OBJ)/Dblkinfo.o:	blkinfo.c
	$(COMPILE.c) -DDEBUG blkinfo.c -o $@

$(TARGETDIR_OBJ)/Dmalloc.o:	malloc.c
	$(COMPILE.c) -DDEBUG malloc.c -o $@

# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-x86-Solaris
