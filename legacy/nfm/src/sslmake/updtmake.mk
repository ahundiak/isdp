CFLAGS=
LIBDIR=../sollib
BINDIR=../solbin
SCBINDIR=../solbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=5
RISLIB=/usr/ip32/ris/rispsuc/lib/Sol2

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
	$(LIBDIR)/alter.a \
	$(RISLIB)/ris.a

LIBRARIES=\
	-lnsl \
	-lcurses \
	-lUMS \
	-lmalloc \
	-ldl \
	-lsocket \
	-lc

NFMALPHA=../update_utility
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmupdate

image : 
	@echo ""
	acc  $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

