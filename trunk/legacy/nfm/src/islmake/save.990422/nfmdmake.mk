CC=/opt/SUNWspro/bin/cc
CFLAGS=-g
LIBDIR=../tdlib
#USR5LIB=/usr/lib
BINDIR=../tdbin
OSFLAG=-Dsolaris
TARGSTR=

OBJECTS=\
	$(LIBDIR)/libnfmd.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a 

LIBRARIES=\
	-lnsl \
	-lUMS \
	-lsocket

NFMEXEC=$(BINDIR)/NFMdaemon

image : 
	@echo ""
	$(CC) -Xa $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
