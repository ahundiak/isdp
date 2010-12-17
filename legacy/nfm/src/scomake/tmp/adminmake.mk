CFLAGS=-g -D_M_TERMINFO
LIBDIR=../scolib
BINDIR=../scobin
SCBINDIR=../scobin
TARGSTR=
OBJEXT=5
RISLIB=/usr/ip32/ris/risdp/lib
FTRLIB=/usr/ip32/ftrdp/lib/i386

SOURCEFILES=../admin/ADMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmadmin.a \
	$(LIBDIR)/NFMversion.a\
	$(LIBDIR)/libnfmsuti.a \
	$(LIBDIR)/libnfma.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmftr.a \
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
	$(RISLIB)/ris.a \
	$(FTRLIB)/FTRlib.a \
        $(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/libalter.a

LIBRARIES=\
	-lnsl_s \
	-lcurses \
	-lUMS \
	-lsocket \
	-lm

NFMADMIN=../admin
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmadmin

SCPP=$(SCBINDIR)/SCcpp

product: $(NFMADMIN)/SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMADMIN)/SCatofn.c
	@echo "char *nfm_path = \"$(NFMADMIN)\";" >> $(NFMADMIN)/SCatofn.c
	@cc -g -c $(CFLAGS) $(TARGSTR) -I$(NFMINCL) $(NFMADMIN)/SCatofn.c 
	@mv SCatofn.o $(NFMADMIN)

image : 
	@echo ""
	cc -g $(CFLAGS) $(TARGSTR) -o $(NFMEXEC) ../sc/SCmain.$(OBJEXT) \
	$(NFMADMIN)/SCatofn.o $(OBJECTS) $(LIBRARIES)
	@echo ""
#	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

