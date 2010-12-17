CFLAGS=
LIBDIR=../sollib
BINDIR=../solbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=7
RISLIB=/usr/ip32/ris/rispsuc/lib/Sol2

NFMLIB=\
      $(LIBDIR)/NFMversion.a \
      $(LIBDIR)/libnfmwfg.a \
      $(LIBDIR)/libnfmu.a \
      $(LIBDIR)/libnfmlists.a \
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
      $(LIBDIR)/alter.a 

NFMWFF = ../wff_x

NFMWFFLIB = $(LIBDIR)/libnfmwff_x.a

EXECUTABLE = $(BINDIR)/Nfmwffx

$(EXECUTABLE) : $(NFMWFF) $(NFMWFFLIB) $(NFMLIB) 
	acc  -DXWINDOWS $(CFLAGS) $(TARGSTR) $(OSFLAG) \
	$(NFMWFFLIB) $(NFMLIB) \
        $(RISLIB)/ris.a \
        -lhlib -lXFI  -lXFS -lX11 \
        -lnsl -lm -lUMS  \
        -lmalloc -ldl -lsocket -g -o $(EXECUTABLE)
	@echo ""
#	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

