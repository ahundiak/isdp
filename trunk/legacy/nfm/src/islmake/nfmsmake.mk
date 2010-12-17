CC=/opt/SUNWspro/bin/cc
CFLAGS=
LIBDIR=../tdlib
BINDIR=../tdbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=9
RISLIB=/opt/ingr/ris/risdp/lib
FTRDIR=/opt/ingr/lib

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
	$(LIBDIR)/libalter.a \
	$(LIBDIR)/libnfmftr.a \
	$(RISLIB)/ris.a

LIBRARIES=\
	-lnsl\
	-lUMS \
	-lmalloc \
	-lsocket \
	-ldl 

image : 
	@echo ""
	$(CC) -g -L/opt/ingr/lib $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

