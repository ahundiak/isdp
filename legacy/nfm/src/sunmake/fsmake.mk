CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
USR5LIB=/usr/5lib
TARGSTR=
OBJEXT=6


OBJECTS=\
        $(LIBDIR)/libfserver.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libacad.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a  \
	$(LIBDIR)/marcomp.a \
	$(LIBDIR)/alter.a

LIBRARIES=\
	-lnsl \
	-lUMS \
	-lxcmalloc \
	$(USR5LIB)/libc.a \
	-lm

NFMINCL=../include
NFMEXEC=$(BINDIR)/NFMfileserver

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
