CC=/opt/SUNWspro/bin/cc
CFLAGS=-g
LIBDIR=../tdlib
BINDIR=../tdbin
DBASRVLIB=./tdlib
TARGSTR=
OSFLAG=-Dsolaris

RISLIB=/opt/ingr/ris/risdp/lib
FTRDIR=/opt/ingr/lib

OBJECTS=\
        ./dbasrv.9\
        ./nfmcalls.9\
        ./srv_util.9\
        ./nfm/dbnfm.9\
        $(DBASRVLIB)/libdbnuc.a\
        $(DBASRVLIB)/libnucleus.a\
        $(RISLIB)/rislduld.a\
        $(LIBDIR)/libnfmr.a\
        $(LIBDIR)/libnfma.a\
        $(LIBDIR)/libnfmsuti.a\
        $(LIBDIR)/libnfmu.a\
        $(LIBDIR)/libnfmlists.a\
        $(LIBDIR)/libcmdtools.a\
        $(LIBDIR)/libnfmwf.a\
        $(LIBDIR)/libdbtools.a\
        $(LIBDIR)/libnfmtools.a\
	$(LIBDIR)/libfilexfer.a\
        $(LIBDIR)/libsystools.a\
        $(LIBDIR)/libnfmsql.a\
        $(LIBDIR)/libnfmnet.a\
        $(LIBDIR)/libtli.a\
        $(LIBDIR)/libnfmmem.a\
        $(LIBDIR)/libnfmerr.a\
        $(LIBDIR)/libnfmftr.a\
        $(RISLIB)/ris.a\
        $(DBASRVLIB)/dba_nfm_calls.a\
        $(LIBDIR)/libalter.a

LIBRARIES=\
	-lnsl \
	-lUMS \
	-lmalloc \
        -lsocket \
        -ldl

NFMINCL=../include
NFMEXEC=$(BINDIR)/dbasrv

image : 
	@echo ""
	$(CC)  $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
