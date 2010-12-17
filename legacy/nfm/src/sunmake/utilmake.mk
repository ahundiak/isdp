CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
USR5LIB=/usr/5lib
TARGSTR=
OBJEXT=6

OBJECTS=\
        $(LIBDIR)/libnfmcuti.a \
	$(LIBDIR)/libnfmr.a \
	$(LIBDIR)/libdbtools.a \
        $(LIBDIR)/libfilexfer.a \
        $(LIBDIR)/libnfmtools.a \
        $(LIBDIR)/libsystools.a \
        $(LIBDIR)/libnfmnet.a \
        $(LIBDIR)/libtli.a \
        $(LIBDIR)/libnfmmem.a \
        $(LIBDIR)/libnfmerr.a \
        $(LIBDIR)/alter.a

LIBRARIES=\
        -lnsl \
        -lxc \
        -lUMS \
        -lxcmalloc \
	$(USR5LIB)/libc.a

NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmutil

image :
	@/usr/5bin/echo ""
	acc  $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@/usr/5bin/echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@/usr/5bin/echo ""

