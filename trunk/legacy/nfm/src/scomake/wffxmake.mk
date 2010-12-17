CFLAGS=
LIBDIR=../scolib
BINDIR=../scobin
TARGSTR=
OBJEXT=5
RISLIB=/usr/ip32/ris/risdp/lib

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
      $(LIBDIR)/libalter.a 

NFMWFF = ../wff_x

NFMWFFLIB = $(LIBDIR)/libnfmwff_x.a

EXECUTABLE = $(BINDIR)/Nfmwffx

$(EXECUTABLE) : $(NFMWFF) $(NFMWFFLIB) $(NFMLIB) 
	cc  -DXWINDOWS $(CFLAGS) $(TARGSTR) \
	$(NFMWFFLIB) $(NFMLIB) \
        $(RISLIB)/ris.a \
        -lXFI  -lX11 \
        -lnsl_s -lm -lUMS -lsocket \
        -g -o $(EXECUTABLE)
	@echo ""
#	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

