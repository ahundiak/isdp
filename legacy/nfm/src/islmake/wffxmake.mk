# 22 April 1999 Art Hundiak
# tweaked path to libXFI.a

CFLAGS=
LIBDIR=../tdlib
BINDIR=../tdbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=9
RISLIB=/opt/ingr/ris/risdp/lib

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
      $(LIBDIR)/libnfmftr.a \
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
	/opt/SUNWspro/bin/cc  -DXWINDOWS $(CFLAGS) $(TARGSTR) $(OSFLAG) \
        /opt/ingr/lib/libXFS.so \
	$(NFMWFFLIB) $(NFMLIB) \
        $(RISLIB)/ris.a \
        -lhlib \
	/usr/lib/libXFI.a \
	-lXFS -lX11 \
        -lnsl -lm -lUMS  \
        -lmalloc -ldl -lsocket -g -o $(EXECUTABLE)
	@echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

