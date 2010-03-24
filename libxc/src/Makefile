# ========================================
# 24 Mar 2010
# Handcrafted make file for libxc
# Libraries are buit in target, object local for now
#
MAKEFLAGS=e
#DOPT=-DRUN_X -DX11 -DLITTLE_ENDIAN -DSYSV -DSYS5 -DSVR4 -DSUNOS -DSUNOS5 -DSUNOS58 -Di386 -D__i386 -DINTEL -DUNIX -DSunOS_5x -D__i386__ -DSunOS
DOPT=-DRUN_X=1 -DX11=1 -DLITTLE_ENDIAN=1 -DSYSV=1 -DSYS5=1 -DSVR4=1 -DSUNOS=1 -DSUNOS5=1 -DSUNOS58=1 -Di386=1 -D__i386=1 -DINTEL=1 -DUNIX=1 -DSunOS_5x=1 -D__i386__=1 -DSunOS=1
INC_PVT=../inc.pvt
INC_PUB=../include
BIN=../bin
LIB=../lib

ISDP_TARGETDIR= $(HOME)/target
TARGETDIR     = $(ISDP_TARGETDIR)/libxc
TARGETDIR_OBJ = $(TARGETDIR)/obj
TARGETDIR_LIB = $(TARGETDIR)/lib

ISDP_INSTALL   = $(HOME)/ingr
INSTALLDIR_LIB = $(ISDP_INSTALL)/lib

CC=cc
COPT=-g -Xa -xCC -m32 -Kpic -c -I$(INC_PVT) -I$(INC_PUB) $(DOPT)

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
	blkalloc.o	\
	blkinfo.o	\
	dload.o		\
	exefile.o	\
	exfilnam.o	\
	exit.o		\
	expshell.o	\
	getargs.o	\
	hashadd.o	\
	hashc.o		\
	hashdel.o	\
	hashdelrec.o	\
	hashfree.o	\
	hashinfo.o	\
	hashinit.o	\
	hashlookup.o	\
	hashdlookup.o	\
	hashnext.o	\
	hashrpl.o	\
	ipcl.o		\
	namecache.o	\
	objaccess.o	\
	report_error.o	\
	stralloc.o	\
	vla.o		\
	whence.o	\
	xcsyscall.o	\
	XCinit_x86.o

LIBXCMALLOCOBJS =	\
	blkalloc.o	\
	blkinfo.o	\
	malloc.o

LIBDXCMALLOCOBJS =	\
	Dblkalloc.o	\
	Dblkinfo.o	\
	Dmalloc.o

all:			\
	$(TARGETDIR_OBJ) \
	$(TARGETDIR_LIB) \
	$(TARGETDIR_LIB)/libxc.so	\
	$(TARGETDIR_LIB)/libxcmalloc.so	\
	$(TARGETDIR_LIB)/libxcmalloc_debug.so \
	install

XCinit_x86.o:	XCinit_x86.s

# $(OBJS):	$(SRCS)
.c.o:
	$(CC) $(COPT) $<

Dblkalloc.o:	blkalloc.c
	$(CC) $(COPT) -DDEBUG blkalloc.c -o $@

Dblkinfo.o:	blkinfo.c
	$(CC) $(COPT) -DDEBUG blkinfo.c -o $@

Dmalloc.o:	malloc.c
	$(CC) $(COPT) -DDEBUG malloc.c -o $@

$(TARGETDIR_LIB)/libxc.so:	$(LIBXCOBJS)
	$(CC) $(LIBXCOBJS) -o $@ -G

$(TARGETDIR_LIB)/libxcmalloc.so:	$(LIBXCMALLOCOBJS)
	$(CC) $(LIBXCMALLOCOBJS) -o $@ -G

$(TARGETDIR_LIB)/libxcmalloc_debug.so:	$(LIBDXCMALLOCOBJS)
	$(CC) $(LIBDXCMALLOCOBJS) -o $@ -G

# Install
install: \
	$(INSTALLDIR_LIB) \
	$(INSTALLDIR_LIB)/libxc.so \
	$(INSTALLDIR_LIB)/libxcmalloc.so \
	$(INSTALLDIR_LIB)/libxcmalloc_debug.so

$(INSTALLDIR_LIB)/libxc.so : $(TARGETDIR_LIB)/libxc.so
	cp -p $(TARGETDIR_LIB)/libxc.so $(INSTALLDIR_LIB)

$(INSTALLDIR_LIB)/libxcmalloc.so : $(TARGETDIR_LIB)/libxcmalloc.so
	cp -p $(TARGETDIR_LIB)/libxcmalloc.so $(INSTALLDIR_LIB)

$(INSTALLDIR_LIB)/libxcmalloc_debug.so : $(TARGETDIR_LIB)/libxcmalloc_debug.so
	cp -p $(TARGETDIR_LIB)/libxcmalloc_debug.so $(INSTALLDIR_LIB)


# Clean up
clean:
	rm -f \
		 $(TARGETDIR_LIB)/libxc.so \
		 $(TARGETDIR_LIB)/libxcmalloc.so \
		 $(TARGETDIR_LIB)/libxcmalloc_debug.so
	rm -f -r $(TARGETDIR_OBJ)
	rm -f *.o core


# Create the target directory (if needed)
$(TARGETDIR_OBJ):
	mkdir -p $(TARGETDIR_OBJ)

$(TARGETDIR_LIB):
	mkdir -p $(TARGETDIR_LIB)

$(INSTALLDIR_LIB):
	mkdir -p $(INSTALLDIR_LIB)
