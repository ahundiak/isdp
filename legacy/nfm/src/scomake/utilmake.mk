CFLAGS=-g
LIBDIR=../scolib
BINDIR=../scobin
TARGSTR=
OBJEXT=5

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
        -lnsl_s \
	-lsocket\
        -lUMS \
        -lmalloc 

NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmutil

image :
	@echo ""
	cc  $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

