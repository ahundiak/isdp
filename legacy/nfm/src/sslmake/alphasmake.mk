CFLAGS=
LIBDIR=../sollib
BINDIR=../solbin
SCBINDIR=../solbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=7
RISLIB=/usr/ip32/ris/rispsuc/lib/Sol2

SOURCEFILES=../alphas/FMcommands.c

OBJECTS=\
	$(LIBDIR)/libnfmfms.a \
	$(LIBDIR)/NFMversion.a \
	$(LIBDIR)/libnfmruti.a \
	$(LIBDIR)/libnfma.a \
	$(LIBDIR)/libnfmsuti.a \
	$(LIBDIR)/libnfmu.a \
	$(LIBDIR)/libnfmlists.a \
	$(LIBDIR)/libnfmwf.a \
	$(LIBDIR)/libcmdtools.a \
	$(LIBDIR)/libdbtools.a \
	$(LIBDIR)/libnfmtools.a \
	$(LIBDIR)/libfilexfer.a \
	$(LIBDIR)/libsystools.a \
	$(LIBDIR)/libnfmsql.a \
	$(LIBDIR)/libnfmmem.a \
	$(LIBDIR)/libnfmnet.a \
	$(LIBDIR)/libtli.a \
	$(LIBDIR)/libnfmerr.a \
	$(RISLIB)/ris.a \
	$(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/alter.a

LIBRARIES=\
	-lnsl \
	-lcurses \
	-lUMS \
	-lsocket \
	-ldl

NFMALPHA=../alphas
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmalphas

SCPP = $(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMALPHA)/SCatofn.c
	@echo "char *nfm_path = \"$(NFMALPHA)\";" >> $(NFMALPHA)/SCatofn.c
	@acc -c $(CFLAGS) $(TARGSTR) -I$(NFMINCL) $(NFMALPHA)/SCatofn.c 

image : 
	@echo ""
	acc $(CFLAGS) $(TARGSTR) $(OSFLAG) -o $(NFMEXEC) \
	../sc/SCmain.$(OBJEXT) \
	SCatofn.o \
	$(OBJECTS) \
	$(LIBRARIES)
	@echo ""
	strip $(NFMEXEC)
	chmod +s $(NFMEXEC)
	@ls -ls $(NFMEXEC)
	@echo ""

