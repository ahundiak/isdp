CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
SCBINDIR=../sunbin
USR5LIB=/usr/5lib
TARGSTR=
OBJEXT=6
RISLIB=/usr/ip32/ris/rispsuc/lib/sun

OBJECTS=\
	$(LIBDIR)/libupdnfm.a \
	$(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a \
	$(RISLIB)/ris.a \
	$(LIBDIR)/alter.a

LIBRARIES=\
	-lnsl \
	$(USR5LIB)/libcurses.a \
	-lxc \
	-lUMS \
	-lxcmalloc \
	$(USR5LIB)/libc.a

NFMALPHA=../update_utility
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmupdate

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

