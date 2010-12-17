LIBDIR=../libc100
BINDIR=../binc100
DBASRVLIB=./libc100
TARGSTR=-Atarg=c100

RISLIB=/usr/ip32/ris/risdp/lib/c100
FTRDIR=/usr/ip32/ftrdp/lib/c100

OBJECTS=\
        ./dbasrv.1\
        ./nfmcalls.1\
        ./srv_util.1\
        ./nfm/dbnfm.1\
        $(DBASRVLIB)/libdbnuc.a\
        $(DBASRVLIB)/libnucleus.a\
        $(RISLIB)/rislduld.a\
        $(RISLIB)/ris.a\
        $(LIBDIR)/libnfmr.a\
        $(LIBDIR)/libfilexfer.a\
        $(LIBDIR)/libsystools.a\
        $(LIBDIR)/libnfmnet.a\
        $(LIBDIR)/libtli.a\
        $(LIBDIR)/libnfmmem.a\
        $(LIBDIR)/libnfmerr.a\
        $(DBASRVLIB)/dba_nfm_calls.a

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
NFMEXEC=$(BINDIR)/dbasrv

image : 
	@echo ""
	acc -O3 -Dclipper $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	#strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
