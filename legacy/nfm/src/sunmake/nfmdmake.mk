CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
USR5LIB=/usr/5lib
TARGSTR=
OBJEXT=6

OBJECTS=\
	$(LIBDIR)/libnfmd.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a 

LIBRARIES=\
	-lnsl \
	-lUMS \
	-lxcmalloc \
	$(USR5LIB)/libc.a

NFMINCL=../include
NFMEXEC=$(BINDIR)/NFMdaemon

image : 
	@/usr/5bin/echo ""
	acc $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@/usr/5bin/echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@/usr/5bin/echo ""
