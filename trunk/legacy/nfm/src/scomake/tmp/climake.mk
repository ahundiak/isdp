CFLAGS=-g
LIBDIR=../scolib
BINDIR=../scobin
TARGSTR=
OBJEXT=5

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
      $(LIBDIR)/libalter.a

NFMCLILIB = $(LIBDIR)/libnfmcli.a

EXECUTABLE = $(BINDIR)/Nfmcli

$(EXECUTABLE) : $(NFMCLILIB) $(NFMLIB)
	cc -g $(CFLAGS) $(TARGSTR) \
	$(NFMCLILIB) $(NFMLIB) \
	-lUMS -lnsl_s -lsocket -lm  \
	-o $(EXECUTABLE)
	@echo ""
	@ls -ls $(EXECUTABLE)
	@echo ""

