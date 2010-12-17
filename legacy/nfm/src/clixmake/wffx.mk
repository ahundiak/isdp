CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100
RISLIB=/usr/ip32/ris/risdp/lib/c100
XLIB=/usr/ip32/xformsdp/xfi/lib/c100
FTRDIR=/usr/ip32/ftrdp/lib/c100

NFMLIB=\
      $(LIBDIR)/NFMversion.a \
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

NFMWFF = ../wff_x

NFMWFFLIB = $(LIBDIR)/libnfmwff_x.a

EXECUTABLE = $(BINDIR)/Nfmwffx

$(EXECUTABLE) : $(NFMWFF) $(NFMWFFLIB) $(NFMLIB) 
	acc -O3 -Dclipper -DXWINDOWS $(CFLAGS) $(TARGSTR) \
	$(NFMWFFLIB) $(NFMLIB) \
        $(RISLIB)/ris.a \
        -lhlib -lXFI_s  -lXFS_s -lX11_s \
        -lbsd -linc -lnsl_s -lmath -lUMS -lxc -lix \
        -ll -lm -lPW -lc_s -lxcmalloc -o $(EXECUTABLE)
	@echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

