CC=/opt/SUNWspro/bin/cc
CFLAGS=-g
LIBDIR=.
#USR5LIB=/usr/lib
BINDIR=/usr2/nfm352/src/tdbin
OSFLAG=-Dsolaris
TARGSTR=

OBJECTS=\
	dbasrv.o\
	nfmcalls.o\
	srv_util.o\
	/usr2/nfm352/src/dbasrv/nfm/dbnfm.o\
	/usr2/nfm352/src/dbasrv/dbnuc/libdbnuc.a\
	/usr2/nfm352/src/dbasrv/nucleus/libnucleus.a\
	/opt/ingr/ris/risdp/lib/rislduld.a\
	/opt/ingr/ris/risdp/lib/ris.a\
	/usr2/nfm352/src/tdlib/libnfmr.a\
	/usr2/nfm352/src/tdlib/libfilexfer.a\
	/usr2/nfm352/src/tdlib/libsystools.a\
	/usr2/nfm352/src/tdlib/libnfmnet.a\
	/usr2/nfm352/src/tdlib/libtli.a\
	/usr2/nfm352/src/tdlib/libnfmmem.a\
	/usr2/nfm352/src/tdlib/libnfmerr.a\
	/usr2/nfm352/src/dbasrv/stub/dba_nfm_calls.a\
	/usr2/nfm352/src/tdlib/alter.a
	

LIBRARIES=\
	-lnsl \
	-lUMS \
	-lsocket

NFMEXEC=$(BINDIR)/dbasrv

image : 
	@echo ""
	$(CC) -Xa $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
