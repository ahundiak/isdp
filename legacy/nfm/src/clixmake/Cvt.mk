CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100
RISLIB=/usr2/ip32/ris/lib/c100
RISPCUCLIB=/usr2/ip32/ris/rispcuc/lib/c100

NFM=..
RIS=/usr2/ip32/ris

NFMCONVERT=$(NFM)/convert
NFMINCL=$(NFM)/include
NFMEXEC=$(BINDIR)/Nfmconvert
SOURCEFILES=$(NFM)/convert/CVTmain.c
FTRDIR=/usr/ip32/ftrdp/lib/c100

OBJECTS=\
	$(LIBDIR)/NFMversion.o \
	$(LIBDIR)/libnfmcvt.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmlists.a \
	$(LIBDIR)/libnfmwf.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a \
	$(RISPCUCLIB)/rislduld.a \
	$(LIBDIR)/libnfmftr.a \
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

