CC=/opt/SUNWspro/bin/cc
CFLAGS=-g
OBJEXT=9
LIBDIR=../tdlib
BINDIR=../tdbin
OSFLAG=-Dsolaris
TARGSTR=

NFMINCL=../include
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
        $(LIBDIR)/libalter.a

LIBRARIES=\
        -lUMS \
	-lsocket \
        -lnsl \
	-ldl \
        -lmalloc 

image :
	@echo ""
	$(CC)  -Xa $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
