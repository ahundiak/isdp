 #-----  LIBXC.A

SOURCE
blkalloc.c
blkinfo.c
dload.c
exefile.c
exfilnam.c
exit.c
expshell.c
getargs.c
hashadd.c
hashc.c
hashdel.c
hashdelrec.c
hashfree.c
hashinit.c
hashinfo.c
hashlookup.c
hashdlookup.c
hashnext.c
hashrpl.c
ipcl.c
objaccess.c
report_error.c
stralloc.c
vla.c
whence.c
xcsyscall.c
#	if defined(sparc)
SUN4_trapret.s
#	endif
#	if defined(clipper)
CLIP_trapret.s
#		if !defined(__APGE__)
stackalloc.s
#		endif
#	endif

ARCHIVE
$(LIB)/libxc.a

 #-----  LIBXCMALLOC.A

SOURCE=malloc
malloc.c

DEPLIB=malloc
blkalloc.o
blkinfo.o
#	if defined(clipper) & !defined(__APGE__)
stackalloc.o
#	endif

ARCHIVE=malloc
$(LIB)/libxcmalloc.a

 #-----  LIBDXCMALLOC.A

SOURCE=dmalloc
blkdebug.c

DEPLIB=dmalloc
Dblkalloc.o
Dblkinfo.o
Dmalloc.o
#	if defined(sparc)
SUN4_trapret.o
#	endif
#	if defined(clipper)
CLIP_trapret.o
#		if !defined(__APGE__)
stackalloc.o
#		endif
#	endif

ARCHIVE=dmalloc
$(LIB)/libdxcmalloc.a


 #--------------------------  START CLIPPER ONLY  -----
#if defined(clipper)

 #-----  MKSTUBS

SOURCE=mkstubs
mkstubs.c

DEPLIB=mkstubs
$(LIB)/libxc.a

EXEC=mkstubs
$(BIN)/mkstubs

LINKLIB=mkstubs
-lc_s

 #----------------------------  END CLIPPER ONLY  -----
#endif

TARGET
#	if defined(clipper)
DLOAD
$(BIN)/mkstubs
#	endif
$(LIB)/libxc.a
$(LIB)/libxcmalloc.a
#	if defined(clipper) | defined(sparc)
$(LIB)/libdxcmalloc.a
#	endif

 #-----  DLHELPER

#	if defined(mips)
SOURCE=dlhelper
dlhelper.c

EXEC=dlhelper
$(BIN)/dlhelper

TARGET
$(BIN)/dlhelper
#	endif

SRC
$LSRC

INCLUDE
$INC_PVT
$INC_PUB


POST_SPECIAL
Dmalloc.o: $(SRC)/malloc.c
	@echo "\t$(SRC)/malloc.c -> $(TARGET)/src/Dmalloc.o"
	@cp $(SRC)/malloc.c $(TARGET)/src/Dmalloc.c
	@$(CC) -DDEBUG $(MOPT) $(IPATH) $(COPT) -c $(TARGET)/src/Dmalloc.c
	@rm -f $(TARGET)/src/Dmalloc.c

Dblkalloc.o: $(SRC)/blkalloc.c
	@echo "\t$(SRC)/blkalloc.c -> $(TARGET)/src/Dblkalloc.o"
	@cp $(SRC)/blkalloc.c $(TARGET)/src/Dblkalloc.c
	@$(CC) -DDEBUG $(MOPT) $(IPATH) $(COPT) -c $(TARGET)/src/Dblkalloc.c
	@rm -f $(TARGET)/src/Dblkalloc.c

Dblkinfo.o: $(SRC)/blkinfo.c
	@echo "\t$(SRC)/blkinfo.c -> $(TARGET)/src/Dblkinfo.o"
	@cp $(SRC)/blkinfo.c $(TARGET)/src/Dblkinfo.c
	@$(CC) -DDEBUG $(MOPT) $(IPATH) $(COPT) -c $(TARGET)/src/Dblkinfo.c
	@rm -f $(TARGET)/src/Dblkinfo.c

#	if defined(clipper)
DLOAD:	dload.o $(SRC)/dload.ld
	@ld -r -o temp.o dload.o $(SRC)/dload.ld
	@mv temp.o dload.o
	@touch DLOAD
#	endif

END_SPECIAL
