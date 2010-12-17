CFLAGS=-g -D_M_TERMINFO
LIBDIR=../scolib
BINDIR=../scobin
SCBINDIR=../scobin
TARGSTR=
OBJEXT=5
RISLIB=/usr/ip32/ris/risdp/lib

SOURCEFILES=../admin/ADMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmadmin.a \
	$(LIBDIR)/NFMversion.a\
	$(LIBDIR)/libnfmsuti.a \
	$(LIBDIR)/libnfma.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmlists.a \
	$(LIBDIR)/libnfmwf.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmerr.a \
        $(LIBDIR)/libnfmsc.a \
	$(RISLIB)/ris.a \
	$(LIBDIR)/libalter.a

LIBRARIES=\
	-lnsl_s \
	-lcurses \
	-lUMS \
	-lsocket

NFMADMIN=../admin
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmadmin

SCPP=$(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMADMIN)/SCatofn.c
	@echo "char *nfm_path = \"$(NFMADMIN)\";" >> $(NFMADMIN)/SCatofn.c
	@cc -c $(CFLAGS) $(TARGSTR) -I$(NFMINCL) $(NFMADMIN)/SCatofn.c 

image : 
	@echo ""
	cc $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) ../sc/SCmain.$(OBJEXT) \
	SCatofn.o $(OBJECTS) $(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

