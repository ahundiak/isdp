CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100
XLIB=/usr2/ip32/xformsdp/xfi/lib/c100/
OBJEXT=1

NFMLIB=$(LIBDIR)/libqui.a \
      $(LIBDIR)/libnfmr.a \
      $(LIBDIR)/libfilexfer.a \
      $(LIBDIR)/libnfmtools.a \
      $(LIBDIR)/libsystools.a \
      $(LIBDIR)/libnfmnet.a \
      $(LIBDIR)/libnfmmem.a \
      $(LIBDIR)/libtli.a \
      $(LIBDIR)/libnfmerr.a 

NFMFI = ../nfmfi_x
NFMFILIB = $(LIBDIR)/libnfmfi_x.a

EXECUTABLE = $(BINDIR)/Nfmfix

$(EXECUTABLE) : $(NFMFI)/NFFmain.$(OBJEXT) $(NFMFILIB) $(NFMLIB) $(LIBDIR)/NFMversion.o
	acc -O3 -Dclipper -DXWINDOWS $(CFLAGS) $(TARGSTR) $(NFMFI)/NFFmain.$(OBJEXT) \
	$(LIBDIR)/NFMversion.o $(NFMFILIB) $(NFMLIB) \
	-lhlib $(XLIB)libXFI.a -lXFS_s -lX11_s \
	-lbsd -linc -lnsl_s -lmath -lUMS -lxc -lix \
	-lxcmalloc -lc_s -o $(EXECUTABLE)
	@echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

