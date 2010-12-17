CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100

OBJECTS=\
        $(LIBDIR)/libnfmcuti.a \
	$(LIBDIR)/libnfmr.a \
	$(LIBDIR)/libdbtools.a \
        $(LIBDIR)/libfilexfer.a \
        $(LIBDIR)/libnfmtools.a \
        $(LIBDIR)/libsystools.a \
        $(LIBDIR)/libnfmnet.a \
        $(LIBDIR)/libtli.a \
        $(LIBDIR)/libnfmmem.a \
        $(LIBDIR)/libnfmerr.a

LIBRARIES=\
        -lbsd \
        -linc \
        -lnsl_s \
        -ltools_s \
        -lxc \
        -lUMS \
        -lxcmalloc \
        -lc_s

NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmutil

image :
	@echo ""
	acc -O3 -Dclipper $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

