CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100
OBJEXT=1
RISLIB=/usr2/ip32/ris/rispcuc/lib/c100
FTRDIR=/usr/ip32/ftrdp/lib/c100

NFMLIB = \
	$(LIBDIR)/libquis.a \
	$(LIBDIR)/libnfmruti.a \
	$(LIBDIR)/libnfma.a \
	$(LIBDIR)/libnfmsuti.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmlists.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libnfmwf.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libnfmftr.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmerr.a \
	$(FTRDIR)/FTRlib.a \
	$(RISLIB)/ris.a

NFMFI = ../nfmfis
NFMFILIB = $(LIBDIR)/libnfmfis.a

EXECUTABLE = $(BINDIR)/Nfmfis

$(EXECUTABLE) : $(NFMFI)/NFFmain.$(OBJEXT) $(NFMFILIB) $(NFMLIB) $(LIBDIR)/NFMversion.o
	acc -O3 -Dclipper $(CFLAGS) $(TARGSTR) $(NFMFI)/NFFmain.$(OBJEXT) \
	$(LIBDIR)/NFMversion.o $(NFMFILIB) $(NFMLIB) \
	-lforms_s -lUMS -lhlibEV -lbsd -linc -lnsl_s -ltools_s -lmath \
        -lxc -lix -lxcmalloc -ll -lm -lPW -lc_s \
	-o $(EXECUTABLE)
	@echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

