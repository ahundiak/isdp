CFLAGS=
LIBDIR=../sollib
BINDIR=../solbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=7
RISLIB=/usr/ip32/ris/rispsuc/lib/Sol2

NFMEXEC = $(BINDIR)/NFMserver

OBJECTS=\
	$(LIBDIR)/libnfms.a \
	$(LIBDIR)/libnfma.a \
	$(LIBDIR)/libnfmsuti.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmlists.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libnfmwf.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmerr.a \
	$(LIBDIR)/alter.a \
	$(RISLIB)/ris.a

LIBRARIES=\
	-lnsl\
	-lUMS \
	-lmalloc \
	-lsocket \
	-ldl

image : 
	@echo ""
	acc $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

