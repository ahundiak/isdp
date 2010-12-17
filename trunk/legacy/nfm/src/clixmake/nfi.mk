CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100
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

NFMFI = ../nfmfi
NFMFILIB = $(LIBDIR)/libnfmfi.a

EXECUTABLE = $(BINDIR)/Nfmfi

$(EXECUTABLE) : $(NFMFI)/NFFmain.$(OBJEXT) $(NFMFILIB) $(NFMLIB) $(LIBDIR)/NFMversion.o
	acc -O3 -Dclipper $(CFLAGS) $(TARGSTR) $(NFMFI)/NFFmain.$(OBJEXT) \
	$(LIBDIR)/NFMversion.o $(NFMFILIB) $(NFMLIB) \
	-lforms_s -lUMS -lhlibEV -lbsd -linc -lnsl_s -ltools_s -lmath \
	-lxc -lix -lxcmalloc -lc_s -o $(EXECUTABLE)
	@echo ""
	strip $(EXECUTABLE)
	chmod +s $(EXECUTABLE)
	@ls -ls $(EXECUTABLE)
	@echo ""

