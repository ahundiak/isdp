CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
SCBINDIR=../binc100
TARGSTR=-Atarg=c100
RISLIB=/usr2/ip32/ris/rispcuc/lib/c100

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
	-lbsd \
	-linc \
	-lnsl_s \
	-lcurses \
	-ltools_s \
	-lxc \
	-lix \
	-lUMS \
	-lxcmalloc \
	-lc_s

NFMALPHA=../nfmmonitor
NFMINCL=../include
NFMEXEC=$(BINDIR)/NFMmonitor

image : 
	@echo ""
	acc -O4 -Dclipper $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

