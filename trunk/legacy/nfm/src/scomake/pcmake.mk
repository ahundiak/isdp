CFLAGS=
LIBDIR=../scolib
BINDIR=../scobin
TARGSTR=
RISLIB=/usr/ip32/ris/risdp/lib
FTRDIR=/usr/ip32/ftrdp/lib/i386

RIS = /usr/ip32/ris
NFMEXEC = $(BINDIR)/PCserver

OBJECTS=\
	$(LIBDIR)/libpcnfms.a \
	$(LIBDIR)/libnfmsuti.a \
	$(LIBDIR)/libnfma.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmlists.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libnfmwf.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libnfmftr.a \
	$(FTRDIR)/FTRlib.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmerr.a \
	$(LIBDIR)/libalter.a \
	$(RISLIB)/ris.a

LIBRARIES=\
	-lnsl_s \
	-lUMS \
	-lsocket\
	-lmalloc\
	-lc \
	-ll \
        -lm

image : 
	@echo ""
	cc  $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

