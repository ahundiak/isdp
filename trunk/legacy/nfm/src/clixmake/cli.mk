CFLAGS=-D__cpu_c100__-DUNIX
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100

NFMLIB=$(LIBDIR)/libnfmr.a \
      $(LIBDIR)/libfilexfer.a \
      $(LIBDIR)/libdbtools.a \
      $(LIBDIR)/libnfmtools.a \
      $(LIBDIR)/libsystools.a \
      $(LIBDIR)/libnfmnet.a \
      $(LIBDIR)/libnfmmem.a \
      $(LIBDIR)/libtli.a \
      $(LIBDIR)/libnfmerr.a 

NFMCLILIB = $(LIBDIR)/libnfmcli.a

EXECUTABLE = $(BINDIR)/Nfmcli

$(EXECUTABLE) : $(NFMCLILIB) $(NFMLIB) $(LIBDIR)/NFMversion.o
	acc -Dclipper $(CFLAGS) $(TARGSTR) \
	$(LIBDIR)/NFMversion.o $(NFMCLILIB) $(NFMLIB) \
	-lUMS -lhelp -lbsd -linc -lnsl_s -ltools_s -lmath \
	-lxc -lix -lxcmalloc -lc_s \
	-o $(EXECUTABLE)
	@echo ""
	strip $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

