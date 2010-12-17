CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
USR5LIB=/usr/5lib
TARGSTR=
OBJEXT=6

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
      $(LIBDIR)/alter.a

NFMFI = ../nfmfi_x
NFMFILIB = $(LIBDIR)/libnfmfi_x.a

EXECUTABLE = $(BINDIR)/Nfmfix

$(EXECUTABLE) : $(NFMFI)/NFFmain.$(OBJEXT) $(NFMFILIB) $(NFMLIB)
	acc -DXWINDOWS $(CFLAGS) $(TARGSTR) $(NFMFI)/NFFmain.$(OBJEXT) \
	$(NFMFILIB) $(NFMLIB) \
	-lhlib  -lXFI -lXFS -lX11 \
	-lnsl -lm -lUMS -lxc \
	$(USR5LIB)/libc.a -lxcmalloc -o $(EXECUTABLE)
	@/usr/5bin/echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@/usr/5bin/echo ""

