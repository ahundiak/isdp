CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100
RISPCUCLIB=/usr2/ip32/ris/risdp/lib/c100
RIS = /usr2/ip32/ris
FTRDIR=/usr/ip32/ftrdp/lib/c100

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
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmerr.a \
        $(LIBDIR)/libnfmftr.a \
        $(FTRDIR)/FTRlib.a \
	$(RISPCUCLIB)/ris.a

LIBRARIES=\
	-lbsd \
	-linc \
	-lnsl_s \
	-ltools_s \
	-lUMS \
	-lxcmalloc \
	-lxc \
	-ll \
	-lm \
	-lPW \
	-lc_s

image : 
	@echo ""
	acc -O3 -Dclipper $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

