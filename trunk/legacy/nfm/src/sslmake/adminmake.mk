CFLAGS=
LIBDIR=../sollib
BINDIR=../solbin
SCBINDIR=../solbin
OSFLAG=-Dsolaris
TARGSTR=
OBJEXT=7
RISLIB=/usr/ip32/ris/rispsuc/lib/Sol2

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
	$(RISLIB)/ris.a \
        $(LIBDIR)/libnfmsc.a \
	$(LIBDIR)/alter.a

LIBRARIES=\
	-lnsl \
	-lcurses \
	-lUMS \
	-ldl \
	-lsocket

NFMADMIN=../admin
NFMINCL=../include
NFMEXEC=$(BINDIR)/Nfmadmin

SCPP=$(SCBINDIR)/SCcpp

product: SCatofn.o image

SCatofn.o: $(SOURCEFILES)
	@echo "\n\n\n\t...SCcpp\n"
	@$(SCPP) $(SOURCEFILES) > $(NFMADMIN)/SCatofn.c
	@echo "\nchar *nfm_path = \"$(NFMADMIN)\";" >> $(NFMADMIN)/SCatofn.c
	@acc -c $(CFLAGS) $(TARGSTR) -I$(NFMINCL) $(NFMADMIN)/SCatofn.c 

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

