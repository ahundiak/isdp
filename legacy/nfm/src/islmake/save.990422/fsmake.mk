CC=/opt/SUNWspro/bin/cc
CFLAGS=-g
LIBDIR=../tdlib
#LIB5DIR=/usr/lib
BINDIR=../tdbin
OSFLAG=-Dsolaris
TARGSTR=

NFMINCL=../include  
NFMEXEC=$(BINDIR)/NFMfileserver


OBJECTS=\
        $(LIBDIR)/libfserver.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libacad.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmerr.a  \
	$(LIBDIR)/libalter.a \
	$(LIBDIR)/libmarcomp.a 
	

LIBRARIES=\
	-lnsl \
	-lUMS \
	-lsocket\
	-ldl \
	-lc \
	-lm

image : 
	@echo ""
	$(CC) -Xa $(CFLAGS) $(TARGSTR) $(OSFLAG) \
	$(OBJECTS) \
	$(LIBRARIES) \
	-o $(NFMEXEC) 
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
