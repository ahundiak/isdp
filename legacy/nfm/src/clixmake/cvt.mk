CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100
RISLIB=/usr2/ip32/risdp/lib/c100
RISPCUCLIB=/usr2/ip32/ris/risdp/lib/c100
FTRDIR=/usr/ip32/ftrdp/lib/c100

NFM=..
RIS=/usr2/ip32/ris

NFMCONVERT=$(NFM)/convert
NFMINCL=$(NFM)/include
NFMEXEC=$(BINDIR)/Nfmconvert
SOURCEFILES=$(NFM)/convert/CVTmain.c

OBJECTS=\
	$(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libnfmcvt.a \
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
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmerr.a \
	$(RISPCUCLIB)/rislduld.a \
	$(FTRDIR)/FTRlib.a \
	$(RISPCUCLIB)/ris.a

LIBRARIES=\
	-lcurses \
	-lbsd \
	-linc \
	-lnsl_s \
	-ltools_s \
	-lUMS \
	-lc_s \
	-ll \
	-lm \
	-lPW \
	-lxc \
	-lxcmalloc 

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

