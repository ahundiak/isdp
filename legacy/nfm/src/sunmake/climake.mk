CFLAGS=
LIBDIR=../sunlib
BINDIR=../sunbin
USR5LIB=/usr/5lib
TARGSTR=
OBJEXT=6

NFMLIB=$(LIBDIR)/NFMversion.a \
      $(LIBDIR)/libnfmr.a \
      $(LIBDIR)/libfilexfer.a \
      $(LIBDIR)/libdbtools.a \
      $(LIBDIR)/libnfmtools.a \
      $(LIBDIR)/libsystools.a \
      $(LIBDIR)/libnfmnet.a \
      $(LIBDIR)/libnfmmem.a \
      $(LIBDIR)/libtli.a \
      $(LIBDIR)/libnfmerr.a \
      $(LIBDIR)/alter.a

NFMCLILIB = $(LIBDIR)/libnfmcli.a

EXECUTABLE = $(BINDIR)/Nfmcli

$(EXECUTABLE) : $(NFMCLILIB) $(NFMLIB)
	acc $(CFLAGS) $(TARGSTR) \
	$(NFMCLILIB) $(NFMLIB) \
	-lUMS -lhlib -lnsl -lm \
	-lxc -lxcmalloc $(USR5LIB)/libc.a \
	-o $(EXECUTABLE)
	@/usr/5bin/echo ""
	@ls -ls $(EXECUTABLE)
	@/usr/5bin/echo ""

