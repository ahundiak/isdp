CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100

OBJECTS=\
        $(LIBDIR)/libv_nfms.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libnfmerr.a \
	$(LIBDIR)/libtli.a 

LIBRARIES=\
	-lbsd \
	-linc \
	-lnsl_s \
	-ltools_s \
	-lUMS \
	-lxcmalloc \
	-lc_s

NFMINCL=../include
NFMEXEC=$(BINDIR)/NFMV_Server

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

