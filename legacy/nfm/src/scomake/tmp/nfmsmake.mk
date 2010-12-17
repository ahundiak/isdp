CFLAGS=
LIBDIR=../scolib
BINDIR=../scobin
TARGSTR=
OBJEXT=5
RISLIB=/usr/ip32/ris/risdp/lib
FTRDIR=/usr/ip32/ftrdp/lib/i386

NFMEXEC = $(BINDIR)/NFMserver

OBJECTS=\
	$(LIBDIR)/libnfms.a \
	$(LIBDIR)/libnfma.a \
	$(LIBDIR)/libnfmsuti.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmftr.a \
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
	$(LIBDIR)/libalter.a \
	$(FTRDIR)/FTRlib.a \
	$(RISLIB)/ris.a

LIBRARIES=\
	-lnsl_s \
	-lUMS \
     	-lsocket \
	-lm

image : 
	@echo ""
	cc -g  $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

