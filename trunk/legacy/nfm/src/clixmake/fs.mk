CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100

OBJECTS=\
        $(LIBDIR)/libfserver.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libacad.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a \
	$(LIBDIR)/libmarcomp.a

LIBRARIES=\
        -lbsd \
	-linc \
	-lnsl_s \
	-ltools_s \
	-lUMS \
	-lxcmalloc \
	-lxc \
	-lc_s \
	-lm

NFMINCL=../include
NFMEXEC=$(BINDIR)/NFMfileserver

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
