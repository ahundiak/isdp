CFLAGS=
LIBDIR=../scolib
BINDIR=../scobin
TARGSTR=
OBJEXT=5

OBJECTS=\
	$(LIBDIR)/libnfmd.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a 

LIBRARIES=\
	-lnsl_s \
	-lUMS \
	-lsocket

NFMINCL=../include
NFMEXEC=$(BINDIR)/NFMdaemon

image : 
	@echo ""
	cc $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
