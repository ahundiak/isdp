CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100
RISLIB=/usr2/ip32/ris/risdp/lib/c100
FTRDIR=/usr/ip32/ftrdp/lib/c100

NFMLIB=\
      $(LIBDIR)/NFMversion.o \
      $(LIBDIR)/libnfmwfg.a \
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
        $(FTRDIR)/FTRlib.a \
      $(LIBDIR)/libnfmerr.a

NFMWFF = ../wff

NFMWFFLIB = $(LIBDIR)/libnfmwff.a

EXECUTABLE = $(BINDIR)/Nfmwff

$(EXECUTABLE) : $(NFMWFF) $(NFMWFFLIB) $(NFMLIB) 
	acc -O3 -Dclipper $(CFLAGS) $(TARGSTR) \
	$(NFMWFFLIB) $(NFMLIB) \
        $(RISLIB)/ris.a \
	-lforms_s -lUMS -lhlibEV -lbsd -linc -lnsl_s -ltools_s -lmath \
        -lxc -lix -lxcmalloc -ll -lm -lPW -lc_s \
	-o $(EXECUTABLE)
	@echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

