CFLAGS=-D__cpu_c100__
LIBDIR=../libc100
BINDIR=../binc100
TARGSTR=-Atarg=c100

OBJECTS=\
	$(LIBDIR)/libnfmd.a \
	$(LIBDIR)/libnfmnet.a \
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
NFMEXEC=$(BINDIR)/NFMdaemon

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
