CFLAGS=
LIBDIR=../scolib
BINDIR=../scobin
TARGSTR=
OBJEXT=5

NFMLIB=$(LIBDIR)/libqui.a \
      $(LIBDIR)/libnfmr.a \
      $(LIBDIR)/libfilexfer.a \
      $(LIBDIR)/libnfmtools.a \
      $(LIBDIR)/libsystools.a \
      $(LIBDIR)/libnfmnet.a \
      $(LIBDIR)/libnfmmem.a \
      $(LIBDIR)/libtli.a \
      $(LIBDIR)/libnfmerr.a \
      $(LIBDIR)/NFMversion.a \
      $(LIBDIR)/libalter.a

NFMFI = ../nfmfi_x
NFMFILIB = $(LIBDIR)/libnfmfi_x.a

EXECUTABLE = $(BINDIR)/Nfmfix

$(EXECUTABLE) : 
	cc -g  -DXWINDOWS $(CFLAGS) $(TARGSTR) $(NFMFI)/NFFmain.$(OBJEXT) \
	$(NFMFILIB) $(NFMLIB) \
	-lXFI -lX11 \
	-lnsl_s -lsocket -lm -lUMS \
	-o $(EXECUTABLE)
	@echo ""
#	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

