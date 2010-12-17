CFLAGS=
LIBDIR=../scolib
BINDIR=../scobin
SCBINDIR=../scobin
TARGSTR=
OBJEXT=5
RISLIB=/usr/ip32/ris/risdp/lib

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
	-lnsl_s \
	-lcurses \
	-lUMS \
	-lmalloc \
	-lsocket \
	-lc

NFMALPHA=../update_utility
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmupdate

image : 
	@echo ""
	cc  $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

