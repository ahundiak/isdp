CFLAGS=
LIBDIR=../sollib
BINDIR=../solbin
SCBINDIR=../solbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=7
RISLIB=/usr/ip32/ris/rispsuc/lib/Sol2

OBJECTS=\
	$(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libnfmmonitor.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a \
	$(RISLIB)/ris.a

LIBRARIES=\
	-lnsl \
	-lcurses \
	-lUMS \
	-lsocket \
	-lc

NFMALPHA=../nfmmonitor
NFMINCL=../include
NFMEXEC=$(BINDIR)/NFMmonitor

image : 
	@echo ""
	cc -g $(CFLAGS) $(OSFLAG) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

