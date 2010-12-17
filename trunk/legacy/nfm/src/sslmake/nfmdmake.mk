CFLAGS=-g
LIBDIR=../sollib
#USR5LIB=/usr/lib
BINDIR=../solbin
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
	acc -Xa $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
