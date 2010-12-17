CFLAGS=
LIBDIR=../tdlib
BINDIR=../tdbin
SCBINDIR=../tdbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=9
RISLIB=/opt/ingr/ris/risdp/lib

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
	$(LIBDIR)/libalter.a \
	$(RISLIB)/ris.a

LIBRARIES=\
	-lnsl \
	/usr/ccs/lib/libcurses.a \
	-lUMS \
	-lmalloc \
	-ldl \
	-lsocket \
	-lelf

NFMALPHA=../update_utility
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmupdate

image : 
	@echo ""
	cc  $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

