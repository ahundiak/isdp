CFLAGS=-g
LIBDIR=../sollib
#LIB5DIR=/usr/lib
BINDIR=../solbin
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
	$(LIBDIR)/alter.a \
	$(LIBDIR)/marcomp.a 
	

LIBRARIES=\
	-lnsl \
	-lUMS \
	-lsocket\
	-ldl \
	-lc \
	-lm

image : 
	@echo ""
	acc -Xa $(CFLAGS) $(TARGSTR) $(OSFLAG) \
	$(OBJECTS) \
	$(LIBRARIES) \
	-o $(NFMEXEC) 
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
