CFLAGS=
LIBDIR=../scolib
BINDIR=../scobin
TARGSTR=
OBJEXT=5


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
	-lnsl_s \
	-lUMS \
	-lsocket\
	-lm

NFMINCL=../include
NFMEXEC=$(BINDIR)/NFMfileserver

image : 
	@echo ""
	cc -g $(CFLAGS) $(TARGSTR) \
	$(OBJECTS) \
	$(LIBRARIES) \
	-o $(NFMEXEC) 
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""
