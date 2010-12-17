CFLAGS=-g
OBJEXT=7
LIBDIR=../sollib
BINDIR=../solbin
OSFLAG=-Dsolaris
TARGSTR=

NFMINCL=/export/home/nfmsrc/src/include
NFMEXEC=$(BINDIR)/Nfmutil

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
        $(LIBDIR)/libnfmerr.a \
        $(LIBDIR)/alter.a

LIBRARIES=\
        -lUMS \
	-lsocket \
        -lnsl \
	-ldl \
        -lmalloc 

image :
	@echo ""
	acc  -Xa $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
