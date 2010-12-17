CC=/opt/SUNWspro/bin/cc
CFLAGS=-g
LIBDIR=../tdlib
BINDIR=../tdbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=9

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

OBJECTS=\
      -lUMS \
      -lnsl \
      -lsocket \
      -lm \
      -ldl
	

NFMCLILIB = $(LIBDIR)/libnfmcli.a

EXECUTABLE = $(BINDIR)/Nfmcli

$(EXECUTABLE) : $(NFMCLILIB) $(NFMLIB)
	$(CC) $(CFLAGS) $(TARGSTR) $(OSFLAG) \
	$(NFMCLILIB) $(NFMLIB) \
	-lUMS -lnsl -lm \
	-lsocket -ldl \
	-o $(EXECUTABLE)
	@echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

